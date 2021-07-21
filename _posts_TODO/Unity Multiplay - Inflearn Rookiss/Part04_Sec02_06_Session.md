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

그리고 서버 클래스의 `OnAcceptHandler()` 메소드를

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


# Send 기능 작성
---








# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







