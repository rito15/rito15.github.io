TITLE : Connector, ClientSession, 비동기 TCP 클라이언트

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# Connector 클래스
---

소켓 서버측에서 `Listener`를 통해 비동기로 클라이언트의 연결을 기다리고 받아들이듯,

클라이언트 측에서 비동기로 서버에 연결하는 `Connector` 클래스를 작성한다.

`Listener` 클래스처럼, 생성되는 소켓을 필드로 사용할 수도 있지만

하나의 `Connector`를 이용해 여러 개의 연결을 생성할 수 있도록

소켓 객체는 메소드 내에서 생성하여 다른 메소드로 전달하는 방식을 사용한다.

<br>

그리고 `Listener`와 마찬가지로 연결이 성사되면 생성할 `Session`이 필요한데,

하나의 `Connector` 객체로 서로 다른 여러가지 연결을 생성할 수 있기 때문에

`Session` 객체를 필드로 사용하면 `Session`이 공유되므로 안된다.

대신 `Func<Session>` 타입의 필드를 사용하여

하나의 연결마다 새로운 `Session` 객체를 생성하는 방식을 사용한다.

<br>

```cs
public class Connector
{
    private Func<Session> _sessionFactory;

    /// <summary> 서버에 연결 시도하기 </summary>
    public void Connect(IPEndPoint endPoint, Func<Session> sessionFactory)
    {
        Socket socket = new Socket(endPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
        _sessionFactory = sessionFactory;

        SocketAsyncEventArgs args = new SocketAsyncEventArgs();
        args.Completed += OnConnectCompleted;
        args.RemoteEndPoint = endPoint;
        args.UserToken = socket;

        BeginConenct(args, socket);
    }

    private void BeginConenct(SocketAsyncEventArgs args, Socket socket)
    {
        bool pending = socket.ConnectAsync(args);
        if (pending == false)
        {
            OnConnectCompleted(null, args);
        }
    }

    private void OnConnectCompleted(object sender, SocketAsyncEventArgs args)
    {
        if (args.SocketError == SocketError.Success)
        {
            Session session = _sessionFactory.Invoke();
            session.Init(args.ConnectSocket);
        }
        else
        {
            Console.WriteLine($"{nameof(OnConnectCompleted)} Failed : {args.SocketError}");
        }
    }
}
```

<br>


# ClientSession 클래스 작성
---

서버 측에서 `GameSession` 클래스를 작성했듯이,

클라이언트 측에서도 `Session` 클래스를 상속받는 `ClientSession` 클래스를 작성한다.

```cs
class ClientSession : Session
{
    protected override void OnConnected(EndPoint endPoint)
    {
        Console.WriteLine($"Session Connected : {endPoint}\n");

        EchoTestAsync();
    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        Console.WriteLine($"Session Disconnected : {endPoint}\n");
    }

    protected override void OnReceived(ArraySegment<byte> buffer)
    {
        string recvData = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
        Console.WriteLine($"[From Server] {recvData}");
    }

    protected override void OnSent(int numOfBytes)
    {
        Console.WriteLine($"[To Server] Transferred Bytes : {numOfBytes}");
    }

    private async void EchoTestAsync(int maxCount = 100)
    {
        await Task.Run(async () => 
        {
            for (int i = 0; i < maxCount; i++)
            {
                Send($"Echo {i}");
                await Task.Delay(1000);
            }
        });
    }
}
```

지금은 테스트 용도로 위와 같이 작성한다.

<br>

# 클라이언트 소스 코드 변경
---

클라이언트에서 사용할 `Connector`와 `Session`이 모두 준비되었으므로

기존의 동기식 코드를 전부 비동기로 대체할 수 있다.

```cs
class TcpClientAsync
{
    private Connector _connector;

    public void Run()
    {
        // 연결할 대상 서버의 정보를 정의한다.
        string host = Dns.GetHostName();
        IPInformation serverInfo = new IPInformation(host, 7777);

        // Connector를 통해 서버에 연결한다.
        _connector = new Connector();
        _connector.Connect(serverInfo.EndPoint, () => new ClientSession());

        // Wait
        while (true) ;
    }
}
```

이렇게 간략하게 작성하면 단순 테스트용 TCP 비동기 클라이언트가 일단 완성된다.


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







