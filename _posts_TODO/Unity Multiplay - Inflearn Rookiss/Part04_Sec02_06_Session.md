TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# 세션(Session) 클래스
---

- 대상(클라이언트 또는 서버)과 연결된 후, 대상과의 송신 및 수신을 담당한다.

```cs
public class Session
{
    private Socket _socket;

    public Session(Socket socket)
    {
        _socket = socket;
    }

    public void Disconnect()
    {
        _socket.Shutdown(SocketShutdown.Both);
        _socket.Close();
    }
}
```

<br>

# Receive 기능 작성
---

## **비동기 Receive 작성하기**

```cs
public void Start()
{
    // Receive
    SocketAsyncEventArgs recvArgs = new SocketAsyncEventArgs();
    recvArgs.Completed += OnReceiveCompleted;
    recvArgs.SetBuffer(new byte[1024], 0, 1024);

    BeginReceive(recvArgs);
}

private void BeginReceive(SocketAsyncEventArgs args)
{
    bool pending = _socket.ReceiveAsync(args);
    if (pending == false)
    {
        // 동기식 처리
        OnReceiveCompleted(null, args);
    }
}

private void OnReceiveCompleted(object sender, SocketAsyncEventArgs args)
{
    int byteTransferred = args.BytesTransferred;

    if (byteTransferred > 0 && args.SocketError == SocketError.Success)
    {
        try
        {
            string recvData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
            Console.WriteLine($"[From Client] {recvData}");

            // Receive 재시작
            BeginReceive(args);
        }
        catch (Exception e)
        {
            Console.WriteLine($"{nameof(OnReceiveCompleted)}() Error : {e}");
        }
    }
}
```

`Listener` 클래스와 동일한 방식으로 작성된다.

비동기 수행을 위해 `SocketAsyncEventArgs` 객체가 필요하며,

`BeginReceive()`를 통해 비동기 **Receive** 기능이 시작되고

**Receive** 수행 완료 시 `OnReceiveCompleted()` 메소드가 호출된다.

<br>

`Listener` 클래스와 다른 점은

`.SetBuffer()` 메소드를 통해 `SocketAsyncEventArgs` 객체에 버퍼를 할당하고,

연결 대상으로부터 전달받은 내용이 `.Buffer` 내에 저장된다는 것이다.

<br>

## **기존 서버 코드 변경**

서버 클래스의 `OnAcceptHandler()` 메소드를

```cs
private void OnAcceptHandler(Socket clientSocket)
{
    try
    {
        Console.WriteLine($"\nClient Accepted : {clientSocket.RemoteEndPoint}");

        // 클라이언트로부터 데이터를 수신한다.
        byte[] receiveBuffer = new byte[1024];
        int receivedLen = clientSocket.Receive(receiveBuffer);
        string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedLen);

        Console.WriteLine($"From Client : {receivedString}");

        /* Send */

        // 연결을 종료한다.
        clientSocket.Shutdown(SocketShutdown.Both);
        clientSocket.Close();
    }
    catch (Exception e)
    {
        Console.WriteLine(e);
    }
}
```

위의 기존 코드에서

```cs
private void OnAcceptHandler(Socket clientSocket)
{
    try
    {
        Console.WriteLine($"\nClient Accepted : {clientSocket.RemoteEndPoint}");

        Session session = new Session(clientSocket);
        session.Start();

        /* Send */

        session.Disconnect();
    }
    catch (Exception e)
    {
        Console.WriteLine(e);
    }
}
```

이렇게 세션을 사용하도록 변경할 수 있다.


<br>

## **멀티스레드 고려하기**

비동기를 이용해 구현하게 되면 기능 수행 및 완료 처리가

모두 다른 스레드에서 동작하게 된다.

따라서 `OnReceiveCompleted()` 메소드에서 공유 변수에 접근할 때는

반드시 락을 통한 메모리 동기화가 필수적이다.

<br>

## **Disconnect() 메소드 작성**

세션의 연결을 끊고 종료하는 `Disconnect()` 메소드를 다음과 같이 작성할 수 있다.

```cs
public void Disconnect()
{
    _socket.Shutdown(SocketShutdown.Both);
    _socket.Close();
}
```

하지만 여기서 두 가지를 고려할 필요가 있다.

1. `Disconnect()`를 여러 번 호출하는 경우
2. 서로 다른 스레드에서 함께 호출하는 경우

이를 고려하여 다음과 같이 변경해준다.

```cs
private const int TRUE = 1;
private const int FALSE = 0;

private int _isDisconnected = FALSE;

public void Disconnect()
{
    // 이미 연결이 끊긴 경우 확인
    if (Interlocked.Exchange(ref _isDisconnected, TRUE) == TRUE)
        return;

    _socket.Shutdown(SocketShutdown.Both);
    _socket.Close();

    Console.WriteLine("Session Disconnected.\n");
}
```

<br>

그리고 `OnReceiveCompleted()` 메소드의 `if-else` 구문 중 `else`를 다음과 같이 작성해준다.

```cs
private void OnReceiveCompleted(object sender, SocketAsyncEventArgs args)
{
    int byteTransferred = args.BytesTransferred;

    if (byteTransferred > 0 && args.SocketError == SocketError.Success)
    {
        try
        {
            string recvData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
            Console.WriteLine($"[From Client] {recvData}");

            // Receive 재시작
            BeginReceive(args);
        }
        catch (Exception e)
        {
            Console.WriteLine($"{nameof(OnReceiveCompleted)}() Error : {e}");
        }
    }
    else
    {
        Disconnect(); // 소켓 에러 발생 시 세션 종료
    }
}
```

<br>


# Send 기능 작성
---

## **비동기 Send 작성하기**

`Receive`와 유사한 형태로 작성한다.

하지만 `Send`는 자동으로 시작되는 것이 아니라

사용자가 원하는 타이밍마다 호출되는 것임을 유의한다.

```cs
public void Send(byte[] sendBuffer)
{
    SocketAsyncEventArgs sendArgs = new SocketAsyncEventArgs();
    sendArgs.Completed += OnSendCompleted;
    sendArgs.SetBuffer(sendBuffer, 0, sendBuffer.Length);
}

private void BeginSend(SocketAsyncEventArgs args)
{
    bool pending = _socket.SendAsync(args);
    if (pending == false)
    {
        // 즉시 수행되는 경우
        OnSendCompleted(null, args);
    }
}

private void OnSendCompleted(object sender, SocketAsyncEventArgs args)
{
    int byteTransferred = args.BytesTransferred;

    if (byteTransferred > 0 && args.SocketError == SocketError.Success)
    {
        try
        {
            string sentData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
            Console.WriteLine($"[To Client] {sentData}");
        }
        catch (Exception e)
        {
            Console.WriteLine($"{nameof(OnSendCompleted)}() Error : {e}");
        }
    }
    else
    {
        Disconnect(); // 소켓 에러 발생 시 세션 종료
    }
}
```

<br>

## **SocketAsyncEventArgs 재사용하기**

문제점이 하나 있다.

`Send()` 메소드가 호출될 때마다

`SocketAsyncEventArgs` 객체가 항상 새롭게 생성된다는 점이다.

따라서 이를 필드로 만들어 재사용하도록 바꿔준다.

```cs
private SocketAsyncEventArgs _sendArgs = new SocketAsyncEventArgs();

public void Start()
{
    // Receive
    SocketAsyncEventArgs recvArgs = new SocketAsyncEventArgs();
    recvArgs.Completed += OnReceiveCompleted;
    recvArgs.SetBuffer(new byte[1024], 0, 1024);

    BeginReceive(recvArgs);

    // Send
    _sendArgs.Completed += OnSendCompleted;
}

public void Send(byte[] sendBuffer)
{
    _sendArgs.SetBuffer(sendBuffer, 0, sendBuffer.Length);
}

private void BeginSend()
{
    bool pending = _socket.SendAsync(_sendArgs);
    if (pending == false)
    {
        // 즉시 수행되는 경우
        OnSendCompleted(null, _sendArgs);
    }
}
```

<br>

## **Send Queue 사용하기**

그리고 여기서 두 가지 문제점을 찾을 수 있다.

1. 여러 스레드에서 동시에 `Send`를 수행할 경우, `_sendArgs`를 공유하기 때문에 경쟁 조건이 발생할 수 있다.
2. 소켓의 `Send` 기능은 부하가 작지 않으므로 자주 호출되는 것을 피해야 한다.

이를 해결하기 위해 다음과 같이 구현한다.

1. `Send Queue`를 만들어, 보낼 패킷을 일단 큐에 담아 놓는다.
2. `Send`를 수행 중인 다른 스레드가 없을 경우, `SendAsync()`를 호출한다.
3. `Send`를 모두 마치고 `Send Queue`에 패킷이 남아있다면 다시 `Send`를 수행한다.

`SendQueue`의 접근과 `Send` 처리는 모두 `lock`을 걸고 수행한다.

<br>

이렇게 구현할 경우,

완전히 동시에 `Send`가 이루어지는 경우는 존재하지 않으므로

`_sendArgs`를 재사용할 수 있고,

동시다발적 `Send`로 인한 과부하를 방지할 수 있다.

<br>

소스 코드는 다음과 같다.

```cs
private SocketAsyncEventArgs _sendArgs = new SocketAsyncEventArgs();
private Queue<byte[]> _sendQueue = new Queue<byte[]>(16);
private bool _isWaitingForSend = false;
private object _sendLock = new object();

public void Send(byte[] sendBuffer)
{
    lock (_sendLock)
    {
        _sendQueue.Enqueue(sendBuffer);

        if (_isWaitingForSend == false)
            BeginSend();
    }
}

private void BeginSend()
{
    // 1. Send Queue 확인
    _isWaitingForSend = true;
    byte[] buffer = _sendQueue.Dequeue();
    _sendArgs.SetBuffer(buffer, 0, buffer.Length);

    // 2. Send 수행
    bool pending = _socket.SendAsync(_sendArgs);
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
                // 기록 남기기
                string sentData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
                Console.WriteLine($"[To Client] {sentData}");

                // 1. 큐에 버퍼가 더 남아있으면 Send 이어서 수행
                if (_sendQueue.Count > 0)
                {
                    Console.WriteLine($"QUEUE IS NOT EMPTY : {_sendQueue.Count}");
                    BeginSend();
                }
                // 2. 큐가 비어있으면 종료
                else
                    _isWaitingForSend = false;
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
```

<br>

# 코드 정리
---

- 필드를 초기화하는 부분은 생성자와 `Start()` 메소드 내부로 적절히 배분하여 옮긴다.
- `Start()` 내부의 `recvArgs` 객체는 `Session` 클래스 내에서 계속 재사용되므로, 필드로 옮긴다.
- 디버그 전용 코드를 추가한다.

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

namespace ServerCore
{
    public class Session
    {
        private const int TRUE = 1;
        private const int FALSE = 0;

        private Socket _socket;
        private int _isDisconnected;

        // Sending Fields
        private SocketAsyncEventArgs _sendArgs;
        private Queue<byte[]> _sendQueue;
        private bool _isWaitingForSend;
        private object _sendLock;

        // Receiving Fields
        private SocketAsyncEventArgs _recvArgs;

        public Session(Socket socket)
        {
            _socket = socket;
            _isDisconnected = FALSE;

            _sendLock = new object();
            _isWaitingForSend = false;
            _sendQueue = new Queue<byte[]>(16);
        }

        /***********************************************************************
        *                               DEBUG
        ***********************************************************************/
        #region .
#if DEBUG
        private bool _debug_isStarted = false;
#endif

        [System.Diagnostics.Conditional("DEBUG")]
        private void Debug_SetStarted()
        {
#if DEBUG
            _debug_isStarted = true;
#endif
        }

        [System.Diagnostics.Conditional("DEBUG")]
        private void Debug_CheckAlreadyStarted()
        {
#if DEBUG
            if (!_debug_isStarted)
                throw new Exception("[DEBUG] Start()가 아직 호출되지 않았습니다.");
#endif
        }
        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .

        public void Start()
        {
            // Receive
            _recvArgs = new SocketAsyncEventArgs();
            _recvArgs.Completed += OnReceiveCompleted;
            _recvArgs.SetBuffer(new byte[1024], 0, 1024);

            BeginReceive();

            // Send
            _sendArgs = new SocketAsyncEventArgs();
            _sendArgs.Completed += OnSendCompleted;

            Debug_SetStarted();
        }

        /// <summary> 클라이언트 소켓과의 연결 종료하기 </summary>
        public void Disconnect()
        {
            // 이미 연결이 끊긴 경우 확인
            if (Interlocked.Exchange(ref _isDisconnected, TRUE) == TRUE)
                return;

            _socket.Shutdown(SocketShutdown.Both);
            _socket.Close();

            Console.WriteLine("Session Disconnected.\n");
        }

        /// <summary> UTF-8 인코딩으로 메시지 전송하기 </summary>
        public void Send(string message)
        {
            byte[] sendBuffer = Encoding.UTF8.GetBytes(message);
            Send(sendBuffer);
        }

        /// <summary> 연결된 클라이언트 소켓에 데이터 전송하기 </summary>
        public void Send(byte[] sendBuffer)
        {
            Debug_CheckAlreadyStarted();

            lock (_sendLock)
            {
                _sendQueue.Enqueue(sendBuffer);

                if (_isWaitingForSend == false)
                    BeginSend();
            }
        }
        #endregion
        /***********************************************************************
        *                               Send Methods
        ***********************************************************************/
        #region .
        private void BeginSend()
        {
            // 1. Send Queue 확인
            _isWaitingForSend = true;
            byte[] buffer = _sendQueue.Dequeue();
            _sendArgs.SetBuffer(buffer, 0, buffer.Length);

            // 2. Send 수행
            bool pending = _socket.SendAsync(_sendArgs);
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
                        // 기록 남기기
                        string sentData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
                        Console.WriteLine($"[To Client] {sentData}");

                        // 1. 큐에 버퍼가 더 남아있으면 Send 이어서 수행
                        if (_sendQueue.Count > 0)
                        {
                            Console.WriteLine($"QUEUE IS NOT EMPTY : {_sendQueue.Count}");
                            BeginSend();
                        }
                        // 2. 큐가 비어있으면 종료
                        else
                            _isWaitingForSend = false;
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
        private void BeginReceive()
        {
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
                    string recvData = Encoding.UTF8.GetString(args.Buffer, args.Offset, byteTransferred);
                    Console.WriteLine($"[From Client] {recvData}");

                    // Receive 재시작
                    BeginReceive();
                }
                catch (Exception e)
                {
                    Console.WriteLine($"{nameof(OnReceiveCompleted)}() Error : {e}");
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
}
```

<br>


# Send 최적화 - 패킷 모아보내기
---

`SocketAsyncEventArgs`에는 `Buffer`도 존재하지만, `BufferList`도 존재한다.

`Socket.SendAsync(args)` 메소드는 `args`의 `Buffer`, `BufferList`를 확인하여

둘 중 `null`이 아닌 것을 전송한다.

둘 다 `null`이 아니면 `ArgumentException`이 발생하므로, 둘 중 하나만 할당해야 한다.

<br>

이를 이용해 여러 개의 버퍼(패킷)를 동시에 한 번에 전송하는 방식으로 최적화를 할 수 있다.

대신 `BufferList`의 내용을 하나의 패킷으로 합쳐서 전송하기 때문에

전송받는 경우 패킷 구분을 해줘야 할 필요가 있다.

<br>

이제`Send` 수행 절차를 다음과 같이 정의할 수 있다.

1. 전송할 패킷을 `Send Queue`에 담는다.
2. `Send`를 수행 중인 다른 스레드가 없을 경우, `Send Queue`의 내용을 모두 `BufferList`에 넣고 `SendAsync()`를 호출한다.
3. `Send`를 모두 마치고 `Send Queue`에 패킷이 남아있다면 다시 `Send`를 수행한다.

그리고 `Send` 수행 중인지 여부를 기록하기 위해 `_isWaitingForSend` 필드를 사용했었지만,

이제는 그 대신 `BufferList`의 크기가 `0`인지 여부를 이용하면 되기 때문에

`_isWaitingForSend` 필드를 제거해도 된다.

<br>

```cs
private List<ArraySegment<byte>> _sendBufferList;

public Session(Socket socket)
{
    // ...
    
    _sendBufferList = new List<ArraySegment<byte>>(8);
}

public void Send(byte[] sendBuffer)
{
    Debug_CheckAlreadyStarted();

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
    //_sendBufferList.Clear(); -> OnSendCompleted()에서 호출
    while (_sendQueue.Count > 0)
    {
        byte[] buffer = _sendQueue.Dequeue();
        _sendBufferList.Add(new ArraySegment<byte>(buffer, 0, buffer.Length));
    }
    _sendArgs.BufferList = _sendBufferList;

    // 2. Send 수행
    bool pending = _socket.SendAsync(_sendArgs);
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
                // 기록 남기기
                Console.WriteLine($"[To Client] Transferred Bytes : {byteTransferred}");
                
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
```

<br>

## **참고**

`Send(byte[])` 메소드 내에서 `_sendQueue.Enqueue(sendBuffer)`만 수행하고 `BeginSend()`로 이어지지 않고 종료되는 경우는 언제일까?

이런 상황을 가정해볼 수 있다.

1. `Send()` - `BeginSend()`를 통해 `SendAsync()`가 호출되고, 전송이 아직 끝나지 않아 `OnSendCompleted()`가 실행되지 않은 상태이다.
2. 이 때 새롭게 `Send()`가 호출되고 `_sendQueue.Enqueue(sendBuffer)`가 실행된다.
3. `_sendBufferList`에 아직 전송되지 않은 버퍼들이 남아있으므로 `Count`가 `0`보다 크다.
4. 따라서 `BeginSend()`로 이어지지 않고 `SendQueue`에만 버퍼를 담고 종료된다.

<br>


TODO : 이벤트 콜백 방식 구현


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







