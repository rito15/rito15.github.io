---
title: TCP 비동기 소켓 서버, 클라이언트 기본
author: Rito15
date: 2021-08-02 00:05:00 +09:00
categories: [C#, C# Socket]
tags: [csharp, thread]
math: true
mermaid: true
---

# 비동기 소켓 통신 방식
---

`Socket` 객체에는 `~Async()` 형태로 명명된 비동기 메소드들이 존재한다.

- `AcceptAsync(SocketAsyncEventArgs)`
- `ConnectAsync(SocketAsyncEventArgs)`
- `DisconnectAsync(SocketAsyncEventArgs)`
- `ConnectAsync(SocketAsyncEventArgs)`
- `ReceiveAsync(SocketAsyncEventArgs)`
- `ReceiveFromAsync(SocketAsyncEventArgs)`
- `SendAsync(SocketAsyncEventArgs)`
- `SendToAsync(SocketAsyncEventArgs)`

이런 비동기 메소드들은 모두 내부적으로 워커 스레드에서 동작한다.

<br>

소켓의 비동기 처리는 모두 다음과 같은 방식으로 구현된다.

1. `SocketAsyncEventArgs` 객체 생성
2. 비동기 수행 완료 처리 메소드(`On~Completed()`) 작성 및 등록
3. 비동기 수행 메소드 호출(`Socket.~Async()`)
4. 수행 완료 시 `On~Completed()` 내부적으로 자동 호출

<br>

예시 소스 코드로 정리하자면 다음과 같다.

`~` 부분은 임의적으로 `Function`이라고 명명한다.

```cs
Socket socket;

void Run()
{
    // 기능 실행 준비
    socket = new Socket(/* ... */);

    // 기능 시작
    SocketAsyncEventArgs args = new SocketAsyncEventArgs();
    args.Completed += OnFunctionCompleted;
    BeginFunction(args);
}

// 비동기 기능 수행 시작
void BeginFunction(SocketAsyncEventArgs args)
{
    // => 필요하다면 args에 대한 초기 설정 필요

    // 동기적으로 수행되는지 여부
    bool pending = socket.AcceptAsync(args);

    // 동기적으로 수행된 경우(대기 없이 즉시 실행) 처리
    if (!pending)
    {
        OnAcceptCompleted(null, args);
    }
}

// 완료 처리 콜백
private void OnFunctionCompleted(object sender, SocketAsyncEventArgs args)
{
    // Function 처리 성공 시
    if (args.SocketError == SocketError.Success)
    {
        // Do Something
    }
    // 에러 발생
    else
    {
        Console.WriteLine(args.SocketError.ToString());
    }

    // 처리를 모두 끝낸 후 다시 비동기 수행 시작
    BeginFunction(args);
}
```

<br>

# 클래스 구조
---

## **[1] 공통(Core)**

### **IPInformation**
- 호스트명, 포트 번호를 입력받아 IP 주소, EndPoint 정보를 생성한다.

<br>

### **Session**
- 소켓 연결 시 생성되어, 비동기 송수신 기능을 담당한다.

- 내부에 소켓 객체를 보유한다.
- 이 클래스를 상속하고 이벤트 핸들러를 구현하여 소켓 통신의 모든 동작을 작성한다.
- 서버 측에는 클라이언트의 세션이, 클라이언트 측에는 서버의 세션이 생성되는 개념이다.

<br>


## **[2] 서버**

### **Listener**
- 클라이언트와의 새로운 연결을 생성하는 역할을 수행한다.

- 내부에 리스너 소켓으로 사용될 소켓 객체를 보유한다.
- 서버의 `EndPoint` 객체와 `Func<Session>` 델리게이트를 입력받는다.
- 리스너 소켓을 생성하여 입력받은 서버 엔드포인트에 바인드한다.
- 비동기 `Accept`를 수행하여 클라이언트의 접속을 대기한다.
- 연결이 성사될 경우, 새로운 세션을 생성하여 실행시킨다.

<br>

### **ClientSession**
- 클라이언트와의 연결 성공 시 서버 측에 생성되는 객체
- `Session` 클래스를 상속받는다.
- 연결 성공, 연결 종료, 패킷 송신, 패킷 수신 시 동작을 구현한다.

<br>

### **ServerProgram**
- 서버 프로그램의 진입점
- 서버의 `IPInformation`, `Listener` 객체를 생성한다.
- `Listener` 객체를 통해 클라이언트의 연결을 대기한다.

<br>


## **[3] 클라이언트**

### **Connector**
- 서버와의 새로운 연결을 생성하는 역할을 수행한다.

- 서버에 대한 `EndPoint` 객체와 `Func<Session>` 델리게이트를 입력받는다.
- 비동기 `Connect`를 수행하여 서버에 연결을 시도한다.
- 연결이 성사될 경우, 새로운 세션을 생성하여 실행시킨다.

<br>

### **ServerSession**
- 서버와의 연결 성공 시 클라이언트 측에 생성되는 객체
- `Session` 클래스를 상속받는다.
- 연결 성공, 연결 종료, 패킷 송신, 패킷 수신 시 동작을 구현한다.

<br>

### **ClientProgram**
- 서버 프로그램의 진입점
- 연결할 서버의 정보를 담은 `IPInformation` 객체를 생성한다.
- `Connector` 객체를 생성하여 서버에 접속을 시도한다.

<br>

# 소스코드
---

## **[1] 공통**

<details>
<summary markdown="span"> 
IPInformation.cs
</summary>

```cs
using System.Net;
using System.Net.Sockets;

public class IPInformation
{
    public IPAddress Address { get; private set; }
    public AddressFamily AddressFamily { get; private set; }
    public IPEndPoint EndPoint { get; private set; }

    public IPInformation(string hostNameOrAddress, int portNumber)
    {
        IPHostEntry ipHost = Dns.GetHostEntry(hostNameOrAddress);

        // 호스트가 보유한 IP 주소 중 첫 번째를 가져온다.
        Address = ipHost.AddressList[0];

        // IP 주소와 포트 번호를 통해 IP 연결 말단 객체를 생성한다.
        EndPoint = new IPEndPoint(Address, portNumber);

        AddressFamily = EndPoint.AddressFamily;
    }
}
```

</details>


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

    private SocketAsyncEventArgs _sendArgs;
    private SocketAsyncEventArgs _recvArgs;

    // Event Handlers
    protected abstract void OnConnected(EndPoint endPoint);
    protected abstract void OnDisconnected(EndPoint endPoint);
    protected abstract void OnReceived(ByteSegment buffer);
    protected abstract void OnSent(ByteSegment buffer);

    public Session()
    {
        _isConnected = FALSE;
    }
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 세션 시작하기 </summary>
    public void Init(Socket socket)
    {
        _socket = socket;
        _isConnected = TRUE;

        // Receive
        _recvArgs = new SocketAsyncEventArgs();
        _recvArgs.Completed += OnReceiveCompleted;
        _recvArgs.SetBuffer(new byte[1024], 0, 1024);

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
        _sendArgs.SetBuffer(sendBuffer.Array, sendBuffer.Offset, sendBuffer.Count);
        BeginSend();
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
        int byteTransferred = args.BytesTransferred;

        if (byteTransferred > 0 && args.SocketError == SocketError.Success)
        {
            try
            {
                OnSent(new ByteSegment(args.Buffer, args.Offset, byteTransferred));
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
    #endregion
    /***********************************************************************
    *                               Receive Methods
    ***********************************************************************/
    #region .
    // NOTE : Receive는 한 번의 수신이 완료되어야만 다음 수신을 준비하므로
    //        스레드 동기화 필요 X
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
                OnReceived(new ByteSegment(args.Buffer, 0, byteTransferred));

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



## **[2] 서버**

<details>
<summary markdown="span"> 
Listener.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

/// <summary> TCP 서버 리스너 </summary>
public class Listener
{
    private Socket _listenSocket;
    private Func<Session> _sessionFactory;

    public void Init(IPEndPoint endPoint, Func<Session> sessionFactory, int backlog = 10)
    {
        // 리스너 소켓 생성 및 동작
        _listenSocket = new Socket(endPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
        _listenSocket.Bind(endPoint);
        _listenSocket.Listen(backlog);

        // 사용할 세션 등록
        _sessionFactory = sessionFactory;

        // Accept 시작
        SocketAsyncEventArgs args = new SocketAsyncEventArgs();
        args.Completed += OnAcceptCompleted;
        BeginAccept(args);
    }

    /// <summary> 비동기 Accept 시작 </summary>
    private void BeginAccept(SocketAsyncEventArgs args)
    {
        // Accept Socket을 비워놓지 않으면 예외 발생
        args.AcceptSocket = null;

        bool pending = _listenSocket.AcceptAsync(args);

        // 대기 없이 Accept를 즉시 성공한 경우 처리
        if (!pending)
        {
            OnAcceptCompleted(null, args);
        }
    }

    /// <summary> Accept 완료 처리 </summary>
    private void OnAcceptCompleted(object sender, SocketAsyncEventArgs args)
    {
        // Accept 성공
        if (args.SocketError == SocketError.Success)
        {
            Session session = _sessionFactory?.Invoke();
            session.Init(args.AcceptSocket);
        }
        // 에러 발생
        else
        {
            Console.WriteLine(args.SocketError.ToString());
        }

        // 처리를 모두 끝낸 후 다시 Accept 시작
        BeginAccept(args);
    }
}
```

</details>


<details>
<summary markdown="span"> 
ClientSession.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;

using ByteSegment = System.ArraySegment<byte>;

class ClientSession : Session
{
    protected override void OnConnected(EndPoint endPoint)
    {
        Console.WriteLine($"Conntected To {endPoint}");

    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        Console.WriteLine($"Disconntected From {endPoint}");
    }

    protected override void OnReceived(ByteSegment buffer)
    {
        string str = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
        Console.WriteLine($"{GetTimeStamp()} From Client - Len : {buffer.Count},  String : {str}\n");

        // 자동 응답
        SendUTF8String($"{str} - Receive Completed");
    }

    protected override void OnSent(ByteSegment buffer)
    {
        string str = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
        Console.WriteLine($"{GetTimeStamp()} To Client : {str}");
    }
}
```

</details>


<details>
<summary markdown="span"> 
ServerProgram.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;

class ServerProgram
{
    static void Main(string[] args)
    {
        Console.WriteLine("SERVER RUNNING..\n");

        IPInformation ipInfo = new IPInformation(Dns.GetHostName(), 12345);
        Listener listener = new Listener();

        listener.Init(ipInfo.EndPoint, () => new ClientSession());

        while (true) ;
    }
}
```

</details>

<br>



## **[3] 클라이언트**

<details>
<summary markdown="span"> 
Connector.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

/// <summary> 클라이언트에서 서버에 TCP 소켓 연결 생성 </summary>
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
            Session session = _sessionFactory?.Invoke();
            session.Init(args.ConnectSocket);

            // Note : Connect()에서 생성한 소켓과 args.ConnectSocket은 동일 객체이다.
        }
        else
        {
            Console.WriteLine($"{nameof(OnConnectCompleted)} Failed : {args.SocketError}");
        }
    }
}
```

</details>


<details>
<summary markdown="span"> 
ServerSession.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;

using ByteSegment = System.ArraySegment<byte>;

class ServerSession : Session
{
    private void Body()
    {
        for (int i = 0; i < 5; i++)
        {
            string str = $"Hi {i}";
            SendUTF8String(str);

            Thread.Sleep(1000);
        }
    }

    protected override void OnConnected(EndPoint endPoint)
    {
        Console.WriteLine($"Conntected To {endPoint}");

        Body();
    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        Console.WriteLine($"Disconntected From {endPoint}");
    }

    protected override void OnReceived(ByteSegment buffer)
    {
        string str = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
        Console.WriteLine($"{GetTimeStamp()} From Server - Len : {buffer.Count},  String : {str}\n");
    }

    protected override void OnSent(ByteSegment buffer)
    {
        string str = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
        Console.WriteLine($"{GetTimeStamp()} To Server : {str}");
    }
}
```

</details>


<details>
<summary markdown="span"> 
ClientProgram.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;

class ClientProgram
{
    static void Main(string[] args)
    {
        Console.WriteLine("CLIENT RUNNING..\n");

        IPInformation ipInfo = new IPInformation(Dns.GetHostName(), 12345);
        Connector connector = new Connector();

        connector.Connect(ipInfo.EndPoint, () => new ServerSession());

        while (true) ;
    }
}
```

</details>



<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







