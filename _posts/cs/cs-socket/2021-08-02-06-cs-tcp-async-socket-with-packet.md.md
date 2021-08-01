---
title: TCP 비동기 소켓 서버, 클라이언트 - 패킷 고려하기
author: Rito15
date: 2021-08-02 00:06:00 +09:00
categories: [C#, C# Socket]
tags: [csharp, thread]
math: true
mermaid: true
---

* 이전 포스팅으로부터 내용이 이어집니다.

<br>

# ReceiveBuffer, SendBuffer
---

- 소켓 통신을 통한 데이터 전달 시 단순히 `byte[]`를 주고 받는 것에서 그치지 않고, 정말로 '패킷'을 주고 받기 위해 필요하다.


<br>

# ReceiveBuffer 클래스
---

- 각 세션마다 하나의 `ReceiveBuffer` 객체를 갖는다.

- TCP 소켓 통신을 통해 수신한 패킷이 완전하지 않을 경우를 대비해 사용된다.

- 패킷을 수신하자마자 이를 완전히 처리하는 것이 아니라, `ReceiveBuffer`에 차례로 저장한다.

- `ReceiveBuffer` 앞부분부터 패킷의 헤더를 확인하여, 지정된 길이만큼 패킷이 완전히 도착한 것이 확인된 경우에만 해당 패킷을 처리하고 `ReceiveBuffer`에서 제거한다.

- `Read Cursor`와 `Write Cursor`를 갖는다.

- 새로운 데이터를 버퍼 내에 저장하면, 그 길이만큼 `Write Cursor`를 뒤로 이동한다.

- 버퍼 내의 데이터를 읽으면, 그 길이만큼 `Read Cursor`를 뒤로 이동한다.

- `Read Cursor`의 항상 `Write Cursor`와 같거나 더 앞에 위치한다.

<br>

<details>
<summary markdown="span"> 
ReceiveBuffer.cs
</summary>

```cs
using System;

/// <summary> 수신된 패킷을 완성하기 위한 임시 버퍼 </summary>
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

public class ReceiveBufferException : Exception
{
    private readonly string _message;
    public override string Message => _message;

    public ReceiveBufferException(string msg)
    {
        _message = msg;
    }
}
```

</details>

<br>


# SendBuffer 클래스
---

- 전송할 패킷을 완성하기 위한 임시 버퍼로 사용된다.

- `byte[]` 타입의 데이터들을 `SendBuffer`에 순서대로 저장한 후, 하나의 패킷으로 전송하게 된다.

- `Read Cursor`와 `Write Cursor`를 갖는다.

- 새로운 데이터를 버퍼 내에 저장하면, 그 길이만큼 `Write Cursor`를 뒤로 이동한다.

- 버퍼 내의 데이터를 읽으면, 그 길이만큼 `Read Cursor`를 뒤로 이동한다.

- `Read Cursor`의 항상 `Write Cursor`와 같거나 더 앞에 위치한다.

- `Receive`와 달리 `Send`는 여러 스레드가 동시에 수행할 수 있으므로, `SendBuffer`를 `TLS`에 저장하여 각각의 스레드마다 고유의 `SendBuffer`를 갖도록 한다.

- `TLS`를 간편히 사용하기 위해 중첩 정적 클래스 `Factory`를 제공한다.

<br>

<details>
<summary markdown="span"> 
SendBuffer.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Threading;

using ByteSegment = System.ArraySegment<byte>;

/// <summary> 전송 시 패킷을 조립하기 위한 임시 버퍼 </summary>
public class SendBuffer
{
    /// <summary> Send Buffer를 TLS로 간편히 제공하기 위한 정적 클래스 </summary>
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

        public static void Write(params byte[][] data)
        {
            foreach (var item in data)
            {
                Write(item);
            }
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

</details>

<br>


# Session 클래스 수정
---

## **[1] SendQueue를 통한 혼잡 제어**

- `Connect`, `Receive` 등의 기능과 달리 `Send`는 같은 순간에 수많은 스레드가 동시에 실행할 수 있다.

- 이렇게 되면 극심한 성능 저하가 발생할 수 있으므로, 한 번에 한 스레드만 전송하도록 제한한다.

- `lock`을 통해 메모리 동기화를 수행한 뒤, `Send`를 시도할 때 일단 `SendQueue`에 저장한다.

- `SendQueue`에 저장하는 데 성공한 스레드는 이어 `SendQueue`를 확인하여, 큐에 담긴 내용을 모두 전송하도록 구현한다.

<br>

## **[2] SendBufferList를 통한 묶음 전송**

- `SendQueue`를 통해 한 번에 하나의 스레드만 전송하도록 할 경우, 혼잡으로 인한 성능 저하는 해결되지만 오히려 전송이 딜레이가 발생할 수 있다는 큰 문제점이 생긴다.

- 소켓에는 한 번에 하나의 `byte[]`만 전송하는 기능 뿐만 아니라 `BufferList`를 통해 여러 개의 `byte[]`를 하나로 묶어 전송하는 기능도 제공한다.

- 이를 이용해, 전송을 시도하는 스레드가 `SendQueue`를 확인하여 전송할 때 큐 내부의 모든 내용을 `BufferList`에 옮겨담아 한 번에 전송하도록 구현한다.

<br>

## **[3] ReceiveBuffer의 사용**

- TCP 통신에서는 하나의 패킷을 한 번에 완전히 전송하지 못하고, 나누어 전송하는 경우가 발생할 수 있다.

- 그런데 지금은 전송 받은 즉시 처리하므로, 나누어 수신한 패킷이 완성되지 못하고 따로따로 처리될 수 있다는 문제점이 존재한다.

- 따라서 `ReceiveBuffer`를 사용하여 패킷을 일단 버퍼에 담아놓고, 패킷이 일부만 도착한 경우에는 다음에 전송되는 패킷을 버퍼에 이어 받아 완성할 수 있도록 구현한다.

<br>


<details>
<summary markdown="span"> 
Session.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

using ByteSegment = System.ArraySegment<byte>;

public abstract class Session
{
    private const int TRUE = 1;
    private const int FALSE = 0;

    private Socket _socket;
    private int _isConnected;

    // Sending Fields
    private SocketAsyncEventArgs _sendArgs;
    private Queue<ByteSegment> _sendQueue;     // 동시 전송 방지를 위한 큐
    private List<ByteSegment> _sendBufferList; // 묶음 전송을 위한 리스트
    private object _sendLock;

    // Receiving Fields
    private SocketAsyncEventArgs _recvArgs;
    private ReceiveBuffer _recvBuffer;

    // Event Handlers
    protected abstract void OnConnected(EndPoint endPoint);
    protected abstract void OnDisconnected(EndPoint endPoint);
    protected abstract int OnReceived(ByteSegment buffer);
    protected abstract void OnSent(ByteSegment buffer);

    public Session()
    {
        _isConnected = FALSE;

        _sendLock = new object();
        _sendQueue = new Queue<ByteSegment>(8);
        _sendBufferList = new List<ByteSegment>(8);

        _recvBuffer = new ReceiveBuffer(1024);
    }
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .

    public void Init(Socket socket)
    {
        _socket = socket;
        _isConnected = TRUE;

        // Receive
        _recvArgs = new SocketAsyncEventArgs();
        _recvArgs.Completed += OnReceiveCompleted;
        //_recvArgs.SetBuffer(new byte[1024], 0, 1024);

        BeginReceive();

        // Send
        _sendArgs = new SocketAsyncEventArgs();
        _sendArgs.Completed += OnSendCompleted;

        // 연결 완료 통보하기
        // 반드시 Init 끝자락에서 호출
        OnConnected(socket.RemoteEndPoint);
    }

    /// <summary> 대상 소켓과의 연결 종료하기 </summary>
    public void Disconnect()
    {
        // 이미 연결이 끊긴 경우 확인
        if (Interlocked.Exchange(ref _isConnected, FALSE) == FALSE)
            return;

        OnDisconnected(_socket.RemoteEndPoint);

        _socket.Shutdown(SocketShutdown.Both);
        _socket.Close();
    }

    /// <summary> 연결된 대상 소켓에 데이터 전송하기 </summary>
    public void Send(ByteSegment sendBuffer)
    {
        lock (_sendLock)
        {
            _sendQueue.Enqueue(sendBuffer);

            // Send를 수행 중인 스레드가 없을 경우, Send 수행
            if (_sendBufferList.Count == 0)
                BeginSend();
        }
    }

    /// <summary> UTF-8 인코딩으로 메시지 전송하기 </summary>
    public void SendUTF8String(string message)
    {
        byte[] sendBuffer = Encoding.UTF8.GetBytes(message);
        Send(new ByteSegment(sendBuffer, 0, sendBuffer.Length));
    }
    #endregion
    /***********************************************************************
    *                               Protected Methods
    ***********************************************************************/
    #region .
    protected string GetTimeStamp()
    {
        return DateTime.Now.ToString("[HH:mm:ss]");
    }
    #endregion
    /***********************************************************************
    *                               Send Methods
    ***********************************************************************/
    #region .
    private void BeginSend()
    {
        // 1. Send Queue -> Buffer List에 모두 옮겨 담기
        //_sendBufferList.Clear(); -> OnSendCompleted()에서 호출
        while (_sendQueue.Count > 0)
        {
            ByteSegment buffer = _sendQueue.Dequeue();
            _sendBufferList.Add(buffer);
        }
        _sendArgs.BufferList = _sendBufferList;

        // 2. Send 수행
        bool pending = true;
        try
        {
            pending = _socket.SendAsync(_sendArgs);
        }
        catch (ObjectDisposedException)
        {
            Console.WriteLine($"대상이 연결을 강제로 종료하였습니다.");
            Disconnect();
        }

        if (pending == false)
        {
            // 즉시 수행되는 경우
            OnSendCompleted(null, _sendArgs);
        }
    }

    private void OnSendCompleted(object sender, SocketAsyncEventArgs args)
    {
        lock (_sendLock)
        {
            int byteTransferred = args.BytesTransferred;

            if (byteTransferred > 0 && args.SocketError == SocketError.Success)
            {
                try
                {
                    foreach (var buffer in _sendBufferList)
                    {
                        OnSent(buffer);
                    }

                    // 버퍼 리스트 비워주기(Send 수행 종료를 알리는 것과 상통)
                    _sendBufferList.Clear();

                    // 큐에 버퍼가 더 남아있으면 Send 이어서 수행
                    if (_sendQueue.Count > 0)
                    {
                        Console.WriteLine($"QUEUE IS NOT EMPTY : {_sendQueue.Count}");
                        BeginSend();
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine($"{nameof(OnSendCompleted)}() Error : {e}");
                }
            }
            else
            {
                string msg = $"{nameof(OnSendCompleted)}() Error : "
                    + $"Byte Transferred [{byteTransferred}], "
                    + $"Error Type [{args.SocketError}]\n";
                Console.WriteLine(msg);

                Disconnect(); // 소켓 에러 발생 시 세션 종료
            }
        }
    }
    #endregion
    /***********************************************************************
    *                               Receive Methods
    ***********************************************************************/
    #region .
    // NOTE : Receive는 한 번의 수신이 완료되어야만 다음 수신을 준비하므로
    //        스레드 동기화 필요 X
    private void BeginReceive()
    {
        // 1. Receive Buffer의 여유 공간 참조
        _recvBuffer.Refresh();
        ByteSegment segment = _recvBuffer.WritableSegment;
        _recvArgs.SetBuffer(segment.Array, segment.Offset, segment.Count);

        // 2. Receive 수행
        bool pending = _socket.ReceiveAsync(_recvArgs);
        if (pending == false)
        {
            // 즉시 수행되는 경우
            OnReceiveCompleted(null, _recvArgs);
        }
    }

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
                    throw new ReceiveBufferException($"버퍼에 쓸 수 있는 잔여 공간이 없습니다 - " +
                        $"Writable Size : {_recvBuffer.WritableSize}, Byte Transferred : {byteTransferred}");
                }

                // 2. 컨텐츠 쪽에 데이터를 넘겨주고, 처리된 데이터 길이 반환받기
                // OnReceived() 메소드에서 패킷을 분석하여, 불완전한 패킷인 경우 0을 반환한다.
                int processedLen = OnReceived(_recvBuffer.ReadableSegment);
                if (processedLen < 0 || processedLen > _recvBuffer.ReadableSize)
                {
                    throw new ReceiveBufferException($"버퍼를 읽는 데 실패하였습니다 - " +
                        $"Readable Size : {_recvBuffer.ReadableSize}, 읽으려는 길이 : {processedLen}");
                }

                // 3. 처리된 데이터 길이만큼 Receive Buffer의 Read 커서 이동
                if (_recvBuffer.OnRead(processedLen) == false)
                {
                    throw new ReceiveBufferException($"버퍼에서 읽을 수 있는 데이터 길이보다 입력한 길이가 더 큽니다 - " +
                        $"Readable Size : {_recvBuffer.ReadableSize}, 읽으려는 길이 : {processedLen}");
                }

                // Receive 재시작
                BeginReceive();
            }
            catch (Exception e)
            {
                Console.WriteLine($"{nameof(OnReceiveCompleted)}() Error : {e}");
                Disconnect();
            }
        }
        else
        {
            string msg = $"{nameof(OnReceiveCompleted)}() Error : "
                    + $"Byte Transferred [{byteTransferred}], "
                    + $"Error Type [{args.SocketError}]\n";
            Console.WriteLine(msg);

            Disconnect(); // 소켓 에러 발생 시 세션 종료
        }
    }
    #endregion

}
```

</details>


<br>

# Packet 클래스
---

- 패킷의 맨 앞부분에는 크기 정보, 바로 뒤에 패킷의 `id`를 넣어준다.

- 두 데이터의 타입을 `2byte`인 `ushort`로 지정하여 패킷의 크기를 최대한 줄여준다.

- 다양한 종류의 패킷을 만들더라도, 이 클래스를 상속하여 공통 부분은 유지한 채로 구현한다.

```cs
public class Packet
{
    public ushort size;
    public ushort id;
}
```

<br>


# PacketSession 클래스
---

- 세션 중에서도 패킷을 사용하는 세션을 따로 구분하여 작성한다.

- 전달받은 내용을 `OnReceived()` 메소드에서 확인하여, 완전한 패킷을 조립할 수 있는 경우에만 `OnReceivePacket()` 메소드로 넘겨 처리한다.


```cs
using System;

using ByteSegment = System.ArraySegment<byte>;

/// <summary> 패킷을 사용하는 세션 </summary>
public abstract class PacketSession : Session
{
    /// <summary> 패킷 헤더 길이 </summary>
    public static readonly ushort HeaderSize = 2;

    protected sealed override int OnReceived(ByteSegment buffer)
    {
        // 처리한 데이터 길이
        int processedLen = 0;

        while (true)
        {
            // 1. 헤더 파싱조차 불가능하게 작은 데이터가 온 경우, 처리 X
            if (buffer.Count < HeaderSize)
                break;

            // 헤더를 확인하여 패킷이 완전히 도착했는지 여부 확인
            ushort dataLen = BitConverter.ToUInt16(buffer.Array, buffer.Offset);

            // 2. 아직 완전한 패킷이 도착한 것이 아닌 경우, 처리 X
            if (buffer.Count < dataLen)
                break;

            // 3. 완전한 패킷 처리
            OnReceivePacket(new ByteSegment(buffer.Array, buffer.Offset, dataLen));
            processedLen += dataLen;

            // 4. 다음 패킷 확인(Offset 이동)
            buffer = new ByteSegment(buffer.Array, buffer.Offset + dataLen, buffer.Count - dataLen);
        }

        return processedLen;
    }

    /// <summary> 완전한 하나의 패킷 처리 </summary>
    protected abstract void OnReceivePacket(ByteSegment buffer);
}
```

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







