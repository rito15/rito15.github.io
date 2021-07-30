TITLE : Send Buffer

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 간단 정리
---

## `Send Buffer` 사용 이유
- 전송을 위한 패킷 조립

<br>

# 개념
---

`Receive Buffer`는 쪼개져 전달될 수 있는 패킷을 버퍼에 임시 보관하고

원하는 길이를 읽어낼 수 있도록 하는 역할을 수행하며, 세션마다 하나씩 존재한다.

<br>

`Send Buffer`는 전송할 패킷을 완성하기 위한 임시 버퍼로 사용되며, 역시 세션마다 하나씩 존재할 수도 있다.

그런데 세션은 서버-클라이언트 연결 당 하나씩 존재한다.

따라서 내부에서 `Send Buffer`를 이용해 패킷을 조립하게 될 경우

동일한 패킷을 클라이언트의 수만큼 중복 생성해야 하는 문제가 발생한다.

이를 방지하기 위해서는 `Send Buffer`를 세션마다 하나씩 사용하는 대신

세션 외부에서 미리 조립해서 완성하고,

완성된 `Send Buffer`를 세션으로 가져와 전송하는 방식을 택해야 한다.

<br>

`Send Buffer` 역시 `Receive Buffer`와 마찬가지로, 커서 방식을 사용한다.

버퍼에 새로운 데이터를 작성하면 해당 길이만큼 `Write Cursor`가 뒤로 이동하며,

버퍼의 데이터를 읽으려 시도할 경우 `Read Cursor`와 `Write Cursor` 사이의 데이터를 한번에 읽어온다.

지정된 길이만큼 읽어오는 `Receive Buffer`와는 여기서 차이가 있다.

<br>

그리고 `Send`는 여러 스레드가 동시에 수행할 수 있으므로, 스레드 동기화 처리가 필요하다.

`Send Buffer` 자체에 락을 사용하면 동시 전송이 불가능해지며,

하나의 버퍼를 공유하고 스레드마다 각자의 커서를 사용하면 관리가 힘들어진다.

따라서 `TLS`를 이용해 스레드마다 각자의 `Send Buffer`를 갖는 형태로 사용한다.

<br>

# Send Buffer 클래스
---

- `SendBuffer` 클래스에 버퍼의 기능을 작성하되, <br>
  `Factory`라는 내부 클래스를 만들어서 `TLS` 기능을 제공한다.

- `ArraySegment<byte>`는 편의상 `ByteSegment`라는 이름으로 사용한다.

<br>

```cs
using ByteSegment = ArraySegment<byte>;

public class SendBuffer
{
    public static class Factory
    {
        public static ThreadLocal<SendBuffer> CurrentBuffer = new ThreadLocal<SendBuffer>(() => null);

        public static int ChunkSize { get; set; } = 4096 * 100;

        /// <summary> 버퍼에 새로운 데이터 작성하기 </summary>
        public static void Write(byte[] data)
        {
            // 초기 접근 시 버퍼 새로 생성
            if (CurrentBuffer.Value == null)
                CurrentBuffer.Value = new SendBuffer(ChunkSize);

            // 여유 공간이 없는 경우 버퍼 새로 생성
            if (CurrentBuffer.Value.CheckWritableSize(data.Length) == false)
                CurrentBuffer.Value = new SendBuffer(ChunkSize);

            // 버퍼에 쓰기
            CurrentBuffer.Value.Write(data);
        }

        /// <summary> 버퍼에서 읽을 수 있는 모든 데이터 읽어오기 </summary>
        public static ByteSegment Read()
        {
            if (CurrentBuffer.Value == null)
                throw new InvalidOperationException($"Read 이전에 Write를 먼저 수행해야 합니다.");

            return CurrentBuffer.Value.Read();
        }
    }

    // [][][r][][][][w][][][]
    private readonly byte[] _buffer;
    private int _readPos;
    private int _writePos;

    /// <summary> 데이터를 새롭게 추가할 수 있는 여유 공간 </summary>
    public int WritableSize => _buffer.Length - _writePos;

    /// <summary> 데이터를 읽을 수 있는 길이 </summary>
    public int ReadableSize => _writePos - _readPos;

    public SendBuffer(int bufferSize)
    {
        _buffer = new byte[bufferSize];
        _readPos = _writePos = 0;
    }

    /// <summary> 해당 길이만큼 버퍼에 쓸 수 있는지 검사 </summary>
    public bool CheckWritableSize(int len)
    {
        return WritableSize >= len;
    }

    /// <summary> Send Buffer에 새로운 데이터 작성하기 </summary>
    public void Write(byte[] data)
    {
        int len = data.Length;
        if (len > WritableSize)
            throw new ArgumentOutOfRangeException($"Send Buffer에 쓰려는 데이터의 길이({len})가" +
                $" 버퍼의 여유 길이({_buffer.Length})보다 큽니다.");

        // Write Pos부터 len 길이만큼 버퍼에 쓰기
        Array.Copy(data, 0, _buffer, _writePos, len);

        // Write Pos 이동
        _writePos += len;
    }

    /// <summary> 버퍼에 가장 최근에 작성된 데이터 모두 읽어오기 </summary>
    public ByteSegment Read()
    {
        if (ReadableSize <= 0)
            throw new IndexOutOfRangeException($"Send Buffer에서 읽을 수 있는 데이터가 없습니다." +
                $" (Read Pos : {_readPos}, Write Pos : {_writePos})");

        // 이전의 데이터 캐싱
        int readPos = _readPos;
        int readableSize = ReadableSize;

        // Read Pos 이동
        _readPos = _writePos;

        return new ByteSegment(_buffer, readPos, readableSize);
    }
}
```

<br>

# Session 클래스 수정
---

- `Send` 수행 시 `byte[]`를 전달받던 부분을 모두 `ByteSegment`를 전달받도록 수정한다.

```cs
public class Session
{
    // Fields
    private Queue<ByteSegment> _sendQueue; // 수정
    
    // Constructor
    public Session()
    {
        _sendQueue = new Queue<ByteSegment>(8); // 수정
    }
    
    public void Send(ByteSegment sendBuffer) // 수정
    {
        lock (_sendLock)
        {
            _sendQueue.Enqueue(sendBuffer);

            // Send를 수행 중인 스레드가 없을 경우, Send 수행
            if (_sendBufferList.Count == 0)
                BeginSend();
        }
    }
    
    private void BeginSend()
    {
        // 1. Send Queue -> Buffer List에 모두 옮겨 담기
        while (_sendQueue.Count > 0)
        {
            ByteSegment buffer = _sendQueue.Dequeue(); // 수정
            _sendBufferList.Add(buffer); // 수정
        }
        _sendArgs.BufferList = _sendBufferList;

        // 2. Send 수행
        bool pending = _socket.SendAsync(_sendArgs);
        if (pending == false)
        {
            OnSendCompleted(null, _sendArgs);
        }
    }
}
```









# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







