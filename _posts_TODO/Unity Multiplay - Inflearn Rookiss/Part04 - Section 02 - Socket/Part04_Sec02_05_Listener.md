TITLE :

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 목표
---

- 동기식 서버로부터 Listener 기능 분리하기
- 비동기 Accept 구현하기

<br>

# 비동기 방식 사용하기
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


# IPInformation 클래스 작성
---

<details>
<summary markdown="span">
IPInformation.cs
</summary>

IP와 포트 번호를 받아 `IPEndPoint`를 생성해주는 간단한 클래스를 작성한다.

```cs
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

<br>

이를 이용하여, 기존 소켓 서버 코드의

```cs
// 로컬 호스트의 이름을 통해 IP Host Entry 정보를 가져온다.
string host = Dns.GetHostName();
IPHostEntry ipHost = Dns.GetHostEntry(host);

// 호스트가 보유한 IP 주소 중 첫 번째를 가져온다.
IPAddress ipAddr = ipHost.AddressList[0];
const int PortNumber = 7777;

// IP 주소와 포트 번호를 통해 IP 연결 말단 객체를 생성한다.
IPEndPoint endPoint = new IPEndPoint(ipAddr, PortNumber);
```

이 부분을

```cs
string host = Dns.GetHostName();
IPInformation serverInfo = new IPInformation(host, 7777);
```

이렇게 간단히 작성할 수 있다.

</details>

<br>


# Listener 클래스 작성
---

기존 소켓 서버 프로그램의 리스너 소켓 기능을 모두 담당할 `Listener` 클래스를 작성한다.

<details>
<summary markdown="span">
Listener.cs
</summary>

```cs
public class Listener
{
    private Socket _listenSocket;
    private Action<Socket> _onAcceptHandler;

    public void Init(IPEndPoint endPoint, Action<Socket> onAcceptHandler)
    {
        // 리스너 소켓 생성 및 동작
        _listenSocket = new Socket(endPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
        _listenSocket.Bind(endPoint);
        _listenSocket.Listen(10);

        _onAcceptHandler = onAcceptHandler;

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
            _onAcceptHandler.Invoke(args.AcceptSocket);
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

<br>

`Accept` 성공 시 수행할 동작을 외부에서 추가할 수 있도록

`Action<Socket> _onAcceptHandler` 델리게이트를 작성하고,

`Init()` 메소드에서 인자로 받아 등록하도록 구현하였다.

그리고 `OnAcceptCompleted()` 내에서 `Accept` 성공 시 호출된다.

<br>


# 소켓 서버 코드 변경
---

<details>
<summary markdown="span">
TcpServerBasic.cs
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

class TcpServerBasic
{
    public static void Run()
    {
        // 로컬 호스트의 이름을 통해 IP Host Entry 정보를 가져온다.
        string host = Dns.GetHostName();
        IPHostEntry ipHost = Dns.GetHostEntry(host);

        // 호스트가 보유한 IP 주소 중 첫 번째를 가져온다.
        IPAddress ipAddr = ipHost.AddressList[0];
        const int PortNumber = 7777;

        // IP 주소와 포트 번호를 통해 IP 연결 말단 객체를 생성한다.
        IPEndPoint endPoint = new IPEndPoint(ipAddr, PortNumber);

        // TCP 리스너 소켓을 생성한다.
        Socket listenSocket = new Socket(endPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

        try
        {
            // Bind : 서버 주소와 포트 정보를 소켓에 연동한다.
            listenSocket.Bind(endPoint);

            // Listen : 클라이언트 대기열을 정의한다.
            // backlog(int) : 최대 클라이언트 동시 대기 허용 수
            listenSocket.Listen(10);

            while (true)
            {
                Console.WriteLine("\nListening..");

                // 클라이언트 소켓의 연결을 수용한다.
                // 블로킹 방식
                Socket clientSocket = listenSocket.Accept();

                Console.WriteLine($"Client Accepted : {clientSocket.RemoteEndPoint}");

                // 클라이언트로부터 데이터를 수신한다.
                byte[] receiveBuffer = new byte[1024];
                int receivedLen = clientSocket.Receive(receiveBuffer);
                string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedLen);

                Console.WriteLine($"From Client : {receivedString}");

                // 클라이언트에 데이터를 전송한다.
                string stringToSend = "Hi Hi Client !";
                byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
                clientSocket.Send(sendBuffer);

                Console.WriteLine($"Send To Client : {stringToSend}");

                // 연결을 종료한다.
                clientSocket.Shutdown(SocketShutdown.Both);
                clientSocket.Close();
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
    }
}
```

</details>

이랬던 코드를

<br>

<details>
<summary markdown="span">
TcpServerAsync.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;
using ServerCore;

namespace Server
{
    class TcpServerAsync
    {
        private Listener _listener;

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

                // 클라이언트에 데이터를 전송한다.
                string stringToSend = "Server Replied";
                byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
                clientSocket.Send(sendBuffer);

                Console.WriteLine($"Send To Client : {stringToSend}");

                // 연결을 종료한다.
                clientSocket.Shutdown(SocketShutdown.Both);
                clientSocket.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        public void Run()
        {
            Console.WriteLine("TCP SERVER RUNNING..");

            // 서버 측의 IP 정보를 정의한다.
            string host = Dns.GetHostName();
            IPInformation serverInfo = new IPInformation(host, 7777);

            // TCP 리스너 소켓을 생성한다.
            _listener = new Listener();

            // 리스너 소켓 동작 - Bind(), Listen()
            _listener.Init(serverInfo.EndPoint, OnAcceptHandler);

            Console.WriteLine("\nListening..");

            while (true)
            {
                // Wait
            }
        }
    }
}
```

</details>

위와 같이 변경한다.

변경하는 김에 `static` 키워드를 제거하고,

직접 서버 객체를 생성하도록 변경하였다.

<br>

리스너 소켓을 직접 만들고 `.Bind()`, `.Listen()`을 호출하던 부분은

`Listener` 객체를 생성하여 `.Init()`을 호출하도록 변경하였으며,

<br>

`while(true){}`를 통해 반복하던 부분은

`OnAcceptHandler()` 메소드에 작성하여 `Listener.Init()`으로 전달한다.


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







