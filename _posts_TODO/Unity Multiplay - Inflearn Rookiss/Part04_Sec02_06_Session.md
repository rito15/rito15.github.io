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

하지만 여기서 문제점이 하나 있다.

`Send()` 메소드가 호출될 때마다

`SocketAsyncEventArgs` 객체가 항상 새롭게 생성된다는 점이다.






<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







