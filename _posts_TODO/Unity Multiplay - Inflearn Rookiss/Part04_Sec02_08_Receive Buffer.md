TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# TCP의 특성
---

전송할 패킷의 길이를 `100`이라고 할 때,

연결 문제, 혼잡 등의 이유로 우선 `80`을 전송하고

이어서 나머지 `20`을 전송하는 일이 발생할 수 있다.

따라서 수신자 입장에서는 현재 받아야 할 패킷을 전부 받았는지 여부를 확인하고

패킷 전체를 받은 경우에만 이를 분석하여 처리해줄 필요가 있다.

<br>

# Receive Buffer 개념
---

- `Read`, `Write` 두 가지 커서가 존재한다.
- `Write` 커서는 `Read` 커서보다 앞에 올 수 없다.
- 버퍼 내에 새로운 데이터를 작성했을 경우, 그 길이만큼 `Write` 커서를 뒤로 이동한다.
- 버퍼 내에 존재하는 데이터를 읽을 경우, 읽은 길이만큼 `Read` 커서를 뒤로 이동한다.
- 이를 이용하여 데이터를 버퍼 내에 연속적으로 담아내고, 원하는 길이만큼 읽을 수 있다.


<br>

# ReceiveBuffer 클래스
---

```cs
public class ReceiveBuffer
{
    // * Example
    // [][][][r][][][][w][][] Read : 3, Write : 7
    //       [r][][][]        Readable Size   : 4
    //                [w][][] Writable Size   : 3
    private ArraySegment<byte> _buffer;

    private int _readPos;
    private int _writePos;
    private int _bufferSize;

    public ReceiveBuffer(int bufferSize)
    {
        _bufferSize = bufferSize;
        _buffer = new ArraySegment<byte>(new byte[bufferSize], 0, bufferSize);
    }

    /// <summary> 읽을 수 있는 실제 데이터 길이 </summary>
    public int ReadableSize => _writePos - _readPos;

    /// <summary> 새롭게 쓸 수 있는 여유 버퍼 길이 </summary>
    public int WritableSize => _bufferSize - _writePos;

    /// <summary> 읽을 수 있는 실제 데이터 영역 </summary>
    public ArraySegment<byte> ReadableSegment
    {
        get => new ArraySegment<byte>(_buffer.Array, _buffer.Offset + _readPos, ReadableSize);
    }

    /// <summary> 새로운 데이터를 작성할 수 있는 빈 영역 </summary>
    public ArraySegment<byte> WritableSegment
    {
        get => new ArraySegment<byte>(_buffer.Array, _buffer.Offset + _writePos, WritableSize);
    }

    /// <summary> Read, Write 커서를 모두 맨 앞으로 당겨오기 </summary>
    public void Refresh()
    {
        int dataSize = ReadableSize;

        // readPos, writePos가 같은 위치에 있는 경우
        // 잔여 데이터 건들 필요 없이 두 커서만 모두 가장 앞으로 이동
        if (dataSize == 0)
        {
            _readPos = _writePos = 0;
        }
        // 읽을 수 있는 데이터가 존재할 경우
        else
        {
            // _readPos로부터 dataSize만큼의 길이를 시작 위치(Offset)로 복사
            Array.Copy(_buffer.Array, _buffer.Offset + _readPos, _buffer.Array, _buffer.Offset, dataSize);

            // 커서 위치를 앞으로 당겨주기
            _readPos = 0;
            _writePos = dataSize;
        }
    }

    /// <summary> 원하는 크기만큼 읽을 수 있는지 여부 </summary>
    public bool IsReadable(int desiredSize)
    {
        return desiredSize >= ReadableSize;
    }

    /// <summary> 원하는 크기만큼 쓸 수 있는지 여부 </summary>
    public bool IsWritable(int desiredSize)
    {
        return desiredSize >= WritableSize;
    }

    /// <summary> 입력한 길이만큼 Read 커서를 이동시키고, 성공 여부 반환 </summary>
    public bool OnRead(int numOfBytes)
    {
        if (numOfBytes > ReadableSize) 
            return false;

        _readPos += numOfBytes;
        return true;
    }

    /// <summary> 입력한 길이만큼 Write 커서를 이동시키고, 성공 여부 반환 </summary>
    public bool OnWrite(int numOfBytes)
    {
        if (numOfBytes > WritableSize)
            return false;

        _writePos += numOfBytes;
        return true;
    }
}
```


<br>

# Session 클래스 변경
---

## **필드**

```cs
private ReceiveBuffer _recvBuffer;
```

## **생성자**

```cs
public Session()
{
    // ...
    
    _recvBuffer = new ReceiveBuffer(1024); // 추가
}
```

## **Start(Socket)**

```cs
public void Init(Socket socket)
{
    // ...

    // Receive
    _recvArgs = new SocketAsyncEventArgs();
    _recvArgs.Completed += OnReceiveCompleted;
    //_recvArgs.SetBuffer(new byte[1024], 0, 1024); // 제거

    // ...
}
```

## **BeginReceive()**

```cs
private void BeginReceive()
{
    // 1. Receive Buffer의 여유 공간 참조
    _recvBuffer.Refresh();
    ArraySegment<byte> segment = _recvBuffer.WritableSegment;
    _recvArgs.SetBuffer(segment.Array, segment.Offset, segment.Count);

    // 2. Receive 수행
    bool pending = _socket.ReceiveAsync(_recvArgs);
    if (pending == false)
    {
        // 즉시 수행되는 경우
        OnReceiveCompleted(null, _recvArgs);
    }
}
```

## **OnReceiveCompleted(object, SocketAsyncEventArgs)**

```cs
private void OnReceiveCompleted(object sender, SocketAsyncEventArgs args)
{
    int byteTransferred = args.BytesTransferred;

    if (byteTransferred > 0 && args.SocketError == SocketError.Success)
    {
        try
        {
            // 1. Receive Buffer의 Write 커서 이동
            if (_recvBuffer.OnWrite(byteTransferred) == false)
            {
                throw new Exception($"Receive Buffer : Write Error");
            }

            // 2. 컨텐츠 쪽에 데이터를 넘겨주고, 처리된 데이터 길이 반환받기
            int processedLen = OnReceived(_recvBuffer.ReadableSegment);
            if (processedLen < 0 || processedLen > _recvBuffer.ReadableSize)
            {
                throw new Exception($"Receive Buffer : Read Error 1");
            }

            // 3. Receive Buffer의 Read 커서 이동
            if (_recvBuffer.OnRead(processedLen) == false)
            {
                throw new Exception($"Receive Buffer : Read Error 2");
            }

            BeginReceive();
        }
        catch (Exception e)
        {
            Console.WriteLine($"{nameof(OnReceiveCompleted)}() Error : {e}");
        }
    }
    else
    {
        // ...
    }
}
```

## **OnReceived(ArraySegment&lt;byte&gt;)**

- 리턴타입을 `void`에서 `int`로 바꾼다.
- 구현 시, 성공적으로 처리된 데이터의 길이를 리턴한다.

```cs
protected abstract int OnReceived(ArraySegment<byte> buffer);

// 구현 예시
protected override int OnReceived(ArraySegment<byte> buffer)
{
    string recvData = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
    Console.WriteLine($"[From Client] {recvData}");

    // 처리한 데이터 길이 반환
    return buffer.Count;
}
```

<br>

# 추가 수정
---

- 버퍼를 굳이 `byte[]`가 아닌 `ArraySegment<byte>`로 만들 이유가 없어보인다.
- 어차피 `_buffer`가 참조하는 배열의 실체도 외부에서 오는 것이 아니라 생성자를 통해 만들어진다.
- 따라서 `_buffer`를 `byte[]` 타입으로 변경한다.

```cs
public class ReceiveBuffer
{
    // * Example
    // [][][][r][][][][w][][] Read : 3, Write : 7
    //       [r][][][]        Readable Size   : 4
    //                [w][][] Writable Size   : 3
    private byte[] _buffer;

    private int _readPos;
    private int _writePos;
    private int _bufferSize;

    public ReceiveBuffer(int bufferSize)
    {
        _bufferSize = bufferSize;
        //_buffer = new ArraySegment<byte>(new byte[bufferSize], 0, bufferSize);
        _buffer = new byte[bufferSize];
    }

    /// <summary> 읽을 수 있는 실제 데이터 길이 </summary>
    public int ReadableSize => _writePos - _readPos;

    /// <summary> 새롭게 쓸 수 있는 여유 버퍼 길이 </summary>
    public int WritableSize => _bufferSize - _writePos;

    /// <summary> 읽을 수 있는 실제 데이터 영역 </summary>
    public ArraySegment<byte> ReadableSegment
    {
        get => new ArraySegment<byte>(_buffer, _readPos, ReadableSize);
    }

    /// <summary> 새로운 데이터를 작성할 수 있는 빈 영역 </summary>
    public ArraySegment<byte> WritableSegment
    {
        get => new ArraySegment<byte>(_buffer, _writePos, WritableSize);
    }

    /// <summary> Read, Write 커서를 모두 맨 앞으로 당겨오기 </summary>
    public void Refresh()
    {
        int dataSize = ReadableSize;

        // readPos, writePos가 같은 위치에 있는 경우
        // 잔여 데이터 건들 필요 없이 두 커서만 모두 가장 앞으로 이동
        if (dataSize == 0)
        {
            _readPos = _writePos = 0;
        }
        // 읽을 수 있는 데이터가 존재할 경우
        else
        {
            // _readPos로부터 dataSize만큼의 길이를 시작 위치(Offset)로 복사
            Array.Copy(_buffer, _readPos, _buffer, 0, dataSize);

            // 커서 위치를 앞으로 당겨주기
            _readPos = 0;
            _writePos = dataSize;
        }
    }

    /// <summary> 원하는 크기만큼 읽을 수 있는지 여부 </summary>
    public bool IsReadable(int desiredSize)
    {
        return desiredSize >= ReadableSize;
    }

    /// <summary> 원하는 크기만큼 쓸 수 있는지 여부 </summary>
    public bool IsWritable(int desiredSize)
    {
        return desiredSize >= WritableSize;
    }

    /// <summary> 입력한 길이만큼 Read 커서를 이동시키고, 성공 여부 반환 </summary>
    public bool OnRead(int numOfBytes)
    {
        if (numOfBytes > ReadableSize) 
            return false;

        _readPos += numOfBytes;
        return true;
    }

    /// <summary> 입력한 길이만큼 Write 커서를 이동시키고, 성공 여부 반환 </summary>
    public bool OnWrite(int numOfBytes)
    {
        if (numOfBytes > WritableSize)
            return false;

        _writePos += numOfBytes;
        return true;
    }
}
```

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







