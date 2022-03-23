TITLE : UDP 소켓 서버, 클라이언트 기본

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# UDP 소켓 통신의 특징
---

- 서버와 클라이언트 간의 1:1 연결이 생성되지 않는다.
- 리스너 소켓이 필요하지 않다.
- `Listen()`, `Connect()` 과정이 없다.
- 소켓의 `.ReceiveFrom()`, `.SendTo()` 메소드를 통해 엔드포인트와 데이터를 주고 받는다.

<br>

# 소켓 통신 과정
---

## **서버**
 - 서버 IP 주소, 포트를 통해 서버 엔드포인트 생성
 - 서버 소켓 객체 생성
 - Bind(서버 엔드포인트 정보를 서버 소켓에 연동)
 - 클라이언트에 대응할 리모트 엔드포인트 생성
 - Send `=>` 리모트 엔드포인트
 - Receive `<=` 리모트 엔드포인트
 - Close

## **클라이언트**
 - 서버 IP 주소, 포트를 통해 서버 엔드포인트 생성
 - 클라이언트 소켓 객체 생성
 - 리모트 엔드포인트 생성
 - Send `=>` 서버 엔드포인트
 - Receive `<=` 리모트 엔드포인트
 - Close

<br>

# 서버 소켓 기본
---

## **[1] 서버 데이터 정의**

```cs
// 서버 IP 주소 정의
IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName()); // 로컬 호스트
IPAddress ipAddr = ipHost.AddressList[0];

// 서버 엔드 포인트 생성
IPEndPoint ep = new IPEndPoint(ipAddr, 1234);
```

## **[2] 서버 소켓 생성**

```cs
// 서버 소켓 생성
Socket serverSocket = new Socket(ep.AddressFamily, SocketType.Dgram, ProtocolType.Udp);
            
// 서버 소켓에 엔드 포인트 바인딩
serverSocket.Bind(ep);
```

## **[3] 리모트 엔드 포인트 생성**

```cs
// 주소와 포트는 상관 없고, AddressFamily만 소켓과 맞추면 됨
// 어차피 Receive로부터 초기화됨
EndPoint remoteEP = new IPEndPoint(IPAddress.IPv6Any, 0000);
```

<br>

## **[4] 데이터 송수신**

```cs
// Send    => Remote End Point
// Receive <= Remote End Point

int index = 0;
while (true)
{
    // Receive
    byte[] recvBuffer = new byte[1024];
    int recvLen = serverSocket.ReceiveFrom(recvBuffer, ref remoteEP);
    string recvString = Encoding.UTF8.GetString(recvBuffer, 0, recvLen);

    Console.WriteLine($"Received From Client [{remoteEP}] : {recvString}");

    // Send
    string replyToClient = $"Server Replied - {index++}";
    serverSocket.SendTo(Encoding.UTF8.GetBytes(replyToClient), remoteEP);

    Console.WriteLine($"Send Data : {replyToClient}\n");
}

serverSocket.Close();
Console.WriteLine("Server Stopped");
```


<br>

# 클라이언트 소켓 기본
---

## **[1] 연결할 서버 데이터 정의**

```cs
// 서버 IP 주소 정의
IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName()); // 로컬 호스트
IPAddress ipAddr = ipHost.AddressList[0];

// 서버 엔드 포인트 생성
IPEndPoint ep = new IPEndPoint(ipAddr, 1234);
```

## **[2] 클라이언트 소켓 생성**

```cs
// 클라이언트 소켓 생성
Socket clientSocket = new Socket(serverEP.AddressFamily, SocketType.Dgram, ProtocolType.Udp);
```

## **[3] 리모트 엔드 포인트 생성**

```cs
// 주소와 포트는 상관 없고, AddressFamily만 소켓과 맞추면 됨
// 어차피 Receive로부터 초기화됨
EndPoint remoteEP = new IPEndPoint(IPAddress.IPv6Any, 0000);
```

## **[4] 데이터 송수신**

```
// Send    => Server End Point
// Receive <= Remote End Point

while (true)
{
    Console.Write("Send To Server : ");
    string consoleInputString = Console.ReadLine();
    if (consoleInputString == "exit")
        break;

    // Send
    byte[] sendBuffer = Encoding.UTF8.GetBytes(consoleInputString);
    clientSocket.SendTo(sendBuffer, sendBuffer.Length, SocketFlags.None, serverEP);

    // Receive
    byte[] recvBuffer = new byte[1024];
    int recvLen = clientSocket.ReceiveFrom(recvBuffer, ref remoteEP);
    string recvString = Encoding.UTF8.GetString(recvBuffer, 0, recvLen);
    Console.WriteLine($"Received From Server [{remoteEP}] : {recvString}\n");
}

clientSocket.Close();
Console.WriteLine("Client Stopped");
```

<br>

# 전체 소스 코드
---

<details>
<summary markdown="span"> 
UdpServerBasic.cs
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

class UdpServerBasic
{
    public static void Run()
    {
        Console.WriteLine("UDP SERVER RUNNING..");

        // ============== [1] 내(서버) 데이터 정의 ========================

        // 서버 IP 주소 정의
        IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName()); // 로컬 호스트
        IPAddress ipAddr = ipHost.AddressList[0];

        // 서버 엔드 포인트 생성
        IPEndPoint ep = new IPEndPoint(ipAddr, 1234);

        // 서버 소켓 생성
        Socket serverSocket = new Socket(ep.AddressFamily, SocketType.Dgram, ProtocolType.Udp);
            
        // 서버 소켓에 엔드 포인트 바인딩
        serverSocket.Bind(ep);

        // ============== [2] 리모트 엔드 포인트 정의 =====================

        // 주소와 포트는 상관 없고, AddressFamily만 소켓과 맞추면 됨
        // 어차피 Receive로부터 초기화됨
        EndPoint remoteEP = new IPEndPoint(IPAddress.IPv6Any, 0000);

        // ============== [3] 통 신 =======================================

        // Send    => Remote End Point
        // Receive <= Remote End Point

        int index = 0;
        while (true)
        {
            // Receive
            byte[] recvBuffer = new byte[1024];
            int recvLen = serverSocket.ReceiveFrom(recvBuffer, ref remoteEP);
            string recvString = Encoding.UTF8.GetString(recvBuffer, 0, recvLen);

            Console.WriteLine($"Received From Client [{remoteEP}] : {recvString}");

            // Send
            string replyToClient = $"Server Replied - {index++}";
            serverSocket.SendTo(Encoding.UTF8.GetBytes(replyToClient), remoteEP);

            Console.WriteLine($"Send Data : {replyToClient}\n");
        }

        serverSocket.Close();
        Console.WriteLine("Server Stopped");
    }
}
```

</details>

<details>
<summary markdown="span"> 
UdpClientBasic.cs
</summary>

```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net;
using System.Net.Sockets;

class UdpClientBasic
{
    public static void Run()
    {
        Console.WriteLine("UDP Client Running....\n");

        // ============== [1] 연결할 서버 데이터 정의 =================

        // 서버 IP 주소 정의
        IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName()); // 로컬 호스트
        IPAddress ipAddr = ipHost.AddressList[0];

        // 서버 엔드 포인트 생성
        IPEndPoint serverEP = new IPEndPoint(ipAddr, 1234);

        // ============== [2] 클라이언트 데이터 정의 =================

        // 클라이언트 소켓 생성
        Socket clientSocket = new Socket(serverEP.AddressFamily, SocketType.Dgram, ProtocolType.Udp);

        // 주소와 포트는 상관 없고, AddressFamily만 소켓과 맞추면 됨
        // 어차피 Receive로부터 초기화됨
        EndPoint remoteEP = new IPEndPoint(IPAddress.IPv6Any, 0000);

        // ============== [3] 통 신 =======================================

        // Send    => Server End Point
        // Receive <= Remote End Point

        while (true)
        {
            Console.Write("Send To Server : ");
            string consoleInputString = Console.ReadLine();
            if (consoleInputString == "exit")
                break;

            // Send
            byte[] sendBuffer = Encoding.UTF8.GetBytes(consoleInputString);
            clientSocket.SendTo(sendBuffer, sendBuffer.Length, SocketFlags.None, serverEP);

            // Receive
            byte[] recvBuffer = new byte[1024];
            int recvLen = clientSocket.ReceiveFrom(recvBuffer, ref remoteEP);
            string recvString = Encoding.UTF8.GetString(recvBuffer, 0, recvLen);
            Console.WriteLine($"Received From Server [{remoteEP}] : {recvString}\n");
        }

        clientSocket.Close();
        Console.WriteLine("Client Stopped");
    }
}
```

</details>


<br>

# References
---
- <https://jinjae.tistory.com/50>
- <https://jcoder1.tistory.com/293>
- <https://it-jerryfamily.tistory.com/entry/Program-CUDP-통신-기본Socket-콘솔-버전>







