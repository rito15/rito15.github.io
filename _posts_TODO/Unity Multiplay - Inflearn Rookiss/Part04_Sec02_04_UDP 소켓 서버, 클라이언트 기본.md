TITLE : TCP 소켓 서버, 클라이언트 기본

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 소켓 정의
---

## **프로토콜**
- 데이터 전송을 위한 규약이며, 대표적으로 TCP와 UDP가 있다.

## **IP**
- 컴퓨터에 부여된 논리적 식별 주소

## **Port**
- 네트워크 상에서 통신하기 위해 호스트 내부적으로 프로세스가 할당받는 고유 번호
- 같은 컴퓨터 내에서 프로세스를 식별하기 위한 번호

<br>

# 소켓 통신 과정
---

## 서버
 - Listener 소켓 객체 생성
 - Bind(서버 주소와 포트를 소켓에 연동)
 - Listen(클라이언트 대기열 생성)
 - Accept(클라이언트 연결 수용)
 - Send, Receive(데이터 송수신)
 - Close

## 클라이언트
 - 소켓 객체 생성
 - Connect(서버 주소와 포트를 통해 연결)
 - Send, Receive
 - Close

<br>

# 서버 소켓 기본(블로킹 방식)
---

## **[1] 소켓 정보 정의**

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

## **[2] 리스너 소켓**

```cs
// TCP 리스너 소켓을 생성한다.
Socket listenSocket = new Socket(endPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

// Bind : 서버 주소와 포트 정보를 소켓에 연동한다.
listenSocket.Bind(endPoint);

// Listen : 클라이언트 대기열을 정의한다.
// backlog(int) : 최대 클라이언트 동시 대기 허용 수
listenSocket.Listen(10);
```

<br>

## **[3] 연결 및 데이터 송수신**

```cs
while (true)
{
    Console.WriteLine("Listening..");

    // 클라이언트 소켓의 연결을 수용한다.
    // 블로킹 방식
    Socket clientSocket = listenSocket.Accept();

    // 클라이언트로부터 데이터를 수신한다.
    byte[] receiveBuffer = new byte[1024];
    int receivedLen = clientSocket.Receive(receiveBuffer);
    string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedLen);

    Console.WriteLine($"From Client : {receivedString}");

    // 클라이언트에 데이터를 전송한다.
    string stringToSend = "Hi Hi Client !";
    byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
    clientSocket.Send(sendBuffer);

    // 연결을 종료한다.
    clientSocket.Shutdown(SocketShutdown.Both);
    clientSocket.Close();
}
```


<br>

# 클라이언트 소켓 기본
---

## **[1] 소켓 생성**

```cs
// 연결할 대상 서버의 정보를 정의한다.
string host = Dns.GetHostName();
IPHostEntry ipHost = Dns.GetHostEntry(host);
IPAddress ipAddr = ipHost.AddressList[0];
const int PortNumber = 7777;

// IP 주소와 포트 번호를 통해 IP 연결 말단 객체를 생성한다.
IPEndPoint serverEndPoint = new IPEndPoint(ipAddr, PortNumber);

// TCP 소켓을 생성한다.
Socket socket = new Socket(serverEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
```

<br>

## **[2] 연결 및 데이터 송수신**

```
// 서버에 연결한다.
socket.Connect(serverEndPoint);

Console.WriteLine($"Connected To {socket.RemoteEndPoint.ToString()}");

// 서버에 데이터를 전송한다.
string stringToSend = "Hello Server";
byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
socket.Send(sendBuffer);

// 서버로부터 데이터를 수신한다.
byte[] receiveBuffer = new byte[1024];
int receivedLen = socket.Receive(receiveBuffer);
string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedLen);

Console.WriteLine($"From Server : {receivedString}");

// 연결을 종료한다.
socket.Shutdown(SocketShutdown.Both);
socket.Close();
```

<br>

# 전체 소스 코드
---

<details>
<summary markdown="span"> 
Server.cs
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

class Server
{
    static void Main(string[] args)
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
                Console.WriteLine("Listening..");

                // 클라이언트 소켓 수용
                // 블로킹 방식
                Socket clientSocket = listenSocket.Accept();

                // 클라이언트로부터 데이터 수신
                byte[] receiveBuffer = new byte[1024];
                int receivedBytes = clientSocket.Receive(receiveBuffer);
                string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedBytes);

                Console.WriteLine($"From Client : {receivedString}");

                // 클라이언트에 데이터 전송
                string stringToSend = "Hi Hi Client !";
                byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
                clientSocket.Send(sendBuffer);

                // 연결 종료
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

<details>
<summary markdown="span"> 
Client.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

class Client
{
    static void Main(string[] args)
    {
        // 연결할 대상 서버의 정보를 정의한다.
        string host = Dns.GetHostName();
        IPHostEntry ipHost = Dns.GetHostEntry(host);
        IPAddress ipAddr = ipHost.AddressList[0];
        const int PortNumber = 7777;

        // IP 주소와 포트 번호를 통해 IP 연결 말단 객체를 생성한다.
        IPEndPoint serverEndPoint = new IPEndPoint(ipAddr, PortNumber);

        // TCP 소켓을 생성한다.
        Socket socket = new Socket(serverEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

        try
        {
            // 서버에 연결한다.
            socket.Connect(serverEndPoint);
            Console.WriteLine($"Connected To {socket.RemoteEndPoint.ToString()}");

            // 서버에 데이터를 전송한다.
            string stringToSend = "Hello Server";
            byte[] sendBuffer = Encoding.UTF8.GetBytes(stringToSend);
            socket.Send(sendBuffer);

            // 서버로부터 데이터를 수신한다.
            byte[] receiveBuffer = new byte[1024];
            int receivedLen = socket.Receive(receiveBuffer);
            string receivedString = Encoding.UTF8.GetString(receiveBuffer, 0, receivedLen);

            Console.WriteLine($"From Server : {receivedString}");

            // 연결을 종료한다.
            socket.Shutdown(SocketShutdown.Both);
            socket.Close();
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
    }
}
```

</details>


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







