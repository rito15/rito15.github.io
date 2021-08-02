---
title: TCP 비동기 소켓으로 간단한 콘솔 채팅 구현하기
author: Rito15
date: 2021-08-03 03:33:00 +09:00
categories: [C#, C# Socket]
tags: [csharp, thread]
math: true
mermaid: true
---

* [이전 포스팅](../06-cs-tcp-async-socket-with-packet.md/)에서 이어집니다.

<br>


# 1. 채팅을 위한 패킷 설계
---

## **[1] ChattingCommand 열거형**

- 전달하는 패킷의 명령어를 미리 열거형으로 정의한다.
- 명령어의 종류는 크게 공통, 클라이언트의 요청, 서버의 통지 3가지로 나뉜다.

<br>

<details>
<summary markdown="span"> 
ChattingCommand.cs
</summary>

```cs
/// <summary> 채팅 명령어 </summary>
public enum ChattingCommand
{
    /* [1] 공통 */
    /// <summary> 일반 채팅 </summary>
    Chat,

    /* [2] 클라이언트 -> 서버 */
    /// <summary> 닉네임 변경 요청 </summary>
    RequestRename,
    /// <summary> 입장 + 닉네임 지정 </summary>
    RequestEnterAndName,
    /// <summary> 퇴장 </summary>
    RequestExit,

    /* [3] 서버 -> 클라이언트 */
    /// <summary> 닉네임 변경사항 통지 </summary>
    NotifyRenamed,
    /// <summary> 입장 통지 </summary>
    NotifyEntered,
    /// <summary> 퇴장 통지 </summary>
    NotifyExit,
}
```

</details>

<br>

## **[2] ChattingPacket 클래스**

- 채팅을 위한 패킷을 정의한다.
- 패킷의 주요 부분은 크게 `명령어`와 `내용`으로 나뉜다.
- `ID`는 현재로서는 필요하지 않으므로 무시한다.
- 소켓을 통한 전송 시 필요한 데이터는 `ByteSegment` 타입이므로, 패킷을 `ByteSegment`로 변환하는 메소드를 작성한다.

<br>

<details>
<summary markdown="span"> 
ChattingPacket.cs
</summary>

```cs
using ByteSegment = ArraySegment<byte>;

public class ChattingPacket : Packet
{
    public readonly ushort command; // 명령어
    public readonly string content; // 채팅 내용

    public ChattingPacket(string content, ChattingCommand command = ChattingCommand.Chat)
    {
        this.command = (ushort)command;
        this.content = content;

        this.size = 0;
    }

    public ByteSegment ToByteSegment()
    {
        // * ID는 일단 필요 없으니 사용하지 않음

        // 1. Command & Content 
        byte[] command = BitConverter.GetBytes(this.command);
        byte[] content = Encoding.UTF8.GetBytes(this.content);

        this.size += sizeof(ushort) * 2;
        this.size += (ushort)content.Length;

        // 2. Size
        byte[] size = BitConverter.GetBytes(this.size);

        // 3. Send Buffer에 작성
        SendBuffer.Factory.Write(size);
        SendBuffer.Factory.Write(command);
        SendBuffer.Factory.Write(content);

        return SendBuffer.Factory.Read();
    }
}
```

</details>

<br>

## **[3] ChattingPacketData 구조체**

- 전달받은 패킷을 처리할 때, `ByteSegment`로부터 `ChattingPacket` 객체를 그대로 복원하는 것은 낭비라고 할 수 있다.

- 그렇다고 해서 패킷을 전달받아 처리하는 부분에서 일일이 명령어, 내용을 분리하는 것은 굉장히 비효율적이다.

- 따라서, 전달받은 `ByteSegment`로부터 필요한 부분만 추출하고 구조체로 전달할 수 있도록 미리 정의한다.

<br>

<details>
<summary markdown="span"> 
ChattingPacketData.cs
</summary>

```cs
/// <summary> 간소화된 채팅 패킷 데이터 </summary>
public readonly struct ChattingPacketData
{
    public readonly ChattingCommand command;
    public readonly string content;

    private ChattingPacketData(ChattingCommand command, string content)
    {
        this.command = command;
        this.content = content;
    }

    /// <summary> ByteSegment로부터 패킷 데이터 조립 </summary>
    public static ChattingPacketData FromByteSegment(ByteSegment seg)
    {
        ushort usSize = BitConverter.ToUInt16(seg.Array, 0);
        ushort usCommand = BitConverter.ToUInt16(seg.Array, 2);

        int contentLen = usSize - 4;
        ChattingCommand command = (ChattingCommand)usCommand;
        string content = Encoding.UTF8.GetString(seg.Array, 4, contentLen);

        return new ChattingPacketData(command, content);
    }
}
```

</details>

<br>




# 2. 채팅 서버 설계
---

## **[1] ChattingManager 클래스**

### **특징**
- 프로그램 내에 유일하게 존재해야 하므로, 싱글톤으로 작성한다.
- 연결된 클라이언트들에 대한 세션을 컬렉션으로 저장하여 관리한다.
- 클라이언트들은 중복되면 안되므로 컬렉션은 `HashSet<Session>` 타입을 사용한다.
- 세션들은 서로 다른 스레드에서 동작하므로, 컬렉션에 접근할 때는 `lock`을 사용하여 동기화한다.

<br>

### **브로드캐스트와 멀티캐스트**
- 각 클라이언트에게 패킷을 전송할 때, 브로드캐스트와 멀티캐스트로 나누어 처리한다.
- 브로드캐스트 : 목록 내의 모든 클라이언트들에게 패킷을 전송한다.
- 멀티캐스트 : 특정 클라이언트를 제외한 모든 클라이언트들에게 패킷을 전송한다.

<br>

### **새 클라이언트 추가**
- 새로운 클라이언트가 연결되었을 때 수행된다.
- 세션 목록에 해당 클라이언트에 대한 세션을 추가한다.
- 브로드캐스트로 새 클라이언트의 접속을 알린다.

<br>

### **클라이언트 제거**
- 연결된 클라이언트가 접속을 종료했을 때 수행된다.
- 세션 목록에서 해당 클라이언트에 대한 세션을 제거한다.
- 다른 클라이언트들이 존재할 경우, 멀티캐스트로 해당 클라이언트의 접속 종료를 알린다.

<br>

### **채팅 메시지 전달**
- 클라이언트가 채팅 메시지를 전송한 경우 수행된다.
- 다른 클라이언트들이 존재할 경우, 멀티캐스트로 이름과 채팅 내용을 전송한다.

<br>

### **클라이언트 이름 변경**
- 클라이언트가 이름 변경을 요청한 경우 수행된다.
- 브로드캐스트로 모든 클라이언트들에게 해당 클라이언트의 이름 변경을 알린다.

<br>

<details>
<summary markdown="span"> 
ChattingManager.cs
</summary>

```cs
using System;
using System.Collections.Generic;

using ByteSegment = System.ArraySegment<byte>;

/// <summary> 채팅 기능 관리 </summary>
class ChattingManager
{
    // Singleton
    public static ChattingManager Instance => _instance;
    private static readonly ChattingManager _instance = new ChattingManager();
    private ChattingManager() { } // 생성자 봉인

    public HashSet<ChattingServerSession> ClientSessionList { get; } = new HashSet<ChattingServerSession>(4);
    private readonly object _lock = new object();

    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 클라이언트로부터 전달받은 패킷 데이터 처리 </summary>
    public void HandleDataFromClient(ChattingServerSession clientSession, in ChattingPacketData data)
    {
        switch (data.command)
        {
            // 채팅 메시지 전달
            case ChattingCommand.Chat:
                string chatContent = $"[{clientSession.ClientName}] : {data.content}";
                Console.WriteLine($"Handle - Chat : {chatContent}");
                RelayChattingMessage(clientSession, chatContent);
                break;

            // 이름 변경 요청
            case ChattingCommand.RequestRename:
                Console.WriteLine($"Handle - Request Rename : {clientSession.ClientName} -> {data.content}");
                RenameClient(clientSession, data.content);
                break;

            // 접속 및 이름 지정 요청
            case ChattingCommand.RequestEnterAndName:
                Console.WriteLine($"Handle - Enter and Name : {data.content}");
                AddClient(clientSession, data.content);
                break;

            default:
                break;
        }
    }
    #endregion
    /***********************************************************************
    *                               Processing Methods
    ***********************************************************************/
    #region .
    /// <summary> 새로운 클라이언트를 목록에 추가 </summary>
    private void AddClient(ChattingServerSession clientSession, string name)
    {
        bool addSucceeded;

        // 1. 목록에 추가
        lock (_lock)
        {
            addSucceeded = ClientSessionList.Add(clientSession);
        }

        // 2. 이름 지정
        clientSession.ClientName = name;

        if (!addSucceeded)
            return;

        // 3. 다른 클라이언트들에 입장 통지
        ChattingPacket packet = new ChattingPacket(name, ChattingCommand.NotifyEntered);
        BroadcastToAll(packet);
    }

    /// <summary> 목록에서 클라이언트 제거 </summary>
    public void RemoveClient(ChattingServerSession clientSession)
    {
        // 1. 목록에서 제거
        lock (_lock)
        {
            ClientSessionList.Remove(clientSession);
        }

        // 2. 이름 지정 여부 확인
        if (string.IsNullOrWhiteSpace(clientSession.ClientName))
            return;

        // 3. 다른 클라이언트들에 퇴장 통지
        if (ClientSessionList.Count > 0)
        {
            ChattingPacket packet = new ChattingPacket(clientSession.ClientName, ChattingCommand.NotifyExit);
            MulticastToAll(clientSession, packet);
        }
    }

    /// <summary> 지정한 클라이언트의 이름 변경 </summary>
    private void RenameClient(ChattingServerSession clientSession, string newName)
    {
        // 1. "기존이름|새로운이름" 꼴로 내용 구성
        string renameContent = $"{clientSession.ClientName}|{newName}";

        // 2. 이름 변경
        clientSession.ClientName = newName;

        // 3. 모든 클라이언트들에 이름 변경 통지
        ChattingPacket packet = new ChattingPacket(renameContent, ChattingCommand.NotifyRenamed);
        BroadcastToAll(packet);
    }

    /// <summary> 해당 클라이언트를 제외한 모두에게 채팅 메시지 전달 </summary>
    private void RelayChattingMessage(ChattingServerSession clientSession, string message)
    {
        if (ClientSessionList.Count > 1)
        {
            ChattingPacket packet = new ChattingPacket(message, ChattingCommand.Chat);
            MulticastToAll(clientSession, packet);
        }
    }

    #endregion
    /***********************************************************************
    *                               Cast Methods
    ***********************************************************************/
    #region .
    /// <summary> 모든 클라이언트들에 패킷 전달 </summary>
    private void BroadcastToAll(ChattingPacket packet)
    {
        ByteSegment bPacket = packet.ToByteSegment();

        lock (_lock)
        {
            foreach (var client in ClientSessionList)
            {
                client.Send(bPacket);
            }
        }
    }

    /// <summary> 패킷을 특정 클라이언트 제외, 다른 클라이언트 세션들에 모두 전달 </summary>
    private void MulticastToAll(Session except, ChattingPacket packet)
    {
        ByteSegment bPacket = packet.ToByteSegment();

        lock (_lock)
        {
            foreach (var client in ClientSessionList)
            {
                if (client == except) continue;

                client.Send(bPacket);
            }
        }
    }
    #endregion
}
```

</details>

<br>



## **[2] ChattingServerSession 클래스**

- 클라이언트 연결 시 서버 측에 생성되는 세션
- 연결된 클라이언트의 이름을 저장한다.
- 클라이언트로부터 패킷을 수신할 경우 패킷을 분리하여 `ChattingManager` 싱글톤에 넘겨 처리한다.

<br>

<details>
<summary markdown="span"> 
ChattingServerSession.cs
</summary>

```cs
using System;
using System.Net;

using ByteSegment = System.ArraySegment<byte>;

class ChattingServerSession : Session
{
    private ChattingManager _chatManager;
    public string ClientName { get; set; }

    protected override void OnConnected(EndPoint endPoint)
    {
        Console.WriteLine($"Conntected To {endPoint}");

        _chatManager = ChattingManager.Instance;
    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        Console.WriteLine($"Disconntected From {endPoint}");

        _chatManager.RemoveClient(this);
    }

    protected override int OnReceived(ByteSegment buffer)
    {
        Console.WriteLine($"Received : {buffer.Count}");

        // 1. 패킷 데이터 분리
        ChattingPacketData data = ChattingPacketData.FromByteSegment(buffer);

        // 2. 처리
        _chatManager.HandleDataFromClient(this, data);

        return buffer.Count;
    }

    protected override void OnSent(ByteSegment buffer)
    {
        Console.WriteLine($"Sent : {buffer.Count}\n");
    }
}
```

</details>

<br>

## **[3] ServerProgram**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
using System;
using System.Net;

class ServerProgram
{
    static void Main(string[] args)
    {
        Utility.PrintServerTitle();

        IPInformation ipInfo = new IPInformation(Dns.GetHostName(), 12345);
        Listener listener = new Listener();

        listener.Init(ipInfo.EndPoint, () => new ChattingServerSession());

        while (true);
    }
}
```

</details>


<br>

# 3. 채팅 클라이언트 설계
---

## **[1] ChattingClient 클래스**

### **역할**
- 필드에 클라이언트 세션 객체를 갖는다.
- 콘솔 입력, 출력을 담당한다.
- 콘솔에 입력한 내용을 패킷으로 가공하여 세션을 통해 서버에 전달한다.
- 세션으로부터 전달받은 서버 패킷을 해석하여 명령대로 처리한다.

<br>

### **콘솔 입력 처리**
- 실행되는 동안, 반복문을 통해 콘솔로부터 한 줄씩 스트링을 입력받는다.
- 입력받은 스트링이 `/`로 시작할 경우 정규 표현식을 통해 스트링을 `명령어`와 `내용`으로 분리하여 명령 처리를 수행한다.
- 보통의 경우 스트링을 채팅 내용으로 인식한다.

<br>

### **패킷 가공 및 전달**
- 콘솔 입력 내용에 따라 알맞은 타입의 패킷으로 가공한다.
- 가공된 패킷을 세션 객체를 통해 서버에 전달한다.

<br>

### **수신한 패킷 데이터 처리**
- 서버로부터 패킷을 전달받은 경우, 클라이언트 세션은 이를 데이터로 분석하여 채팅 클라이언트에 전달한다.
- 이렇게 전달받은 데이터에 따라 알맞은 처리를 수행한다.
- 일반 채팅 패킷을 전달받은 경우, 타임스탬프와 함께 콘솔에 그대로 출력한다.
- 입장, 퇴장, 이름 변경 등의 패킷을 전달받은 경우에도 약간 가공하여 타임스탬프와 함께 콘솔에 출력한다.


<br>

<details>
<summary markdown="span"> 
ChattingClient.cs
</summary>

```cs
using System;
using System.Text.RegularExpressions;

class ChattingClient
{
    public string Name { get; set; }

    private ChattingClientSession _session;
    private bool _isRunning;

    /// <summary> "잘못된 명령어를 입력하셨습니다." </summary>
    private static readonly string WRONG_COMMAND = "잘못된 명령어를 입력하셨습니다.";

    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 채팅 클라이언트 동작 시작 </summary>
    public void Run(ChattingClientSession session)
    {
        _session = session;
        _isRunning = true;
        _session.IsPaused = true;

        // 1. 이름 등록
        Console.Write("닉네임을 입력하세요 > ");
        InitMyName(Console.ReadLine());

        // 2. 채팅 시작
        while (_isRunning)
        {
            Console.Write("\n> ");
            string chatting = Console.ReadLine();
            ProcessInput(chatting);
        }
    }

    /// <summary> 종료 </summary>
    public void Quit()
    {
        _isRunning = false;
        Console.WriteLine("채팅이 종료되었습니다.");
    }

    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .

    /// <summary> 접속 시 초기 이름 지정 </summary>
    private void InitMyName(string name)
    {
        _session.IsPaused = false;
        ChangeMyName(name);
        ChattingPacket packet = new ChattingPacket(name, ChattingCommand.RequestEnterAndName);
        _session.Send(packet.ToByteSegment());
    }

    private void ChangeMyName(string newName)
    {
        Name = newName;
        Console.Title = $"Chatting Client : {newName}";
    }

    /// <summary> 타임스탬프와 함께 콘솔에 출력 </summary>
    private void PrintWithTimeStamp(string msg)
    {
        Console.WriteLine($"{Utility.GetTimeStamp()} {msg}");
    }

    private void PrintCursor()
    {
        Console.Write("\n> ");
    }
    #endregion
    /***********************************************************************
    *                           Processing Client Chattings
    ***********************************************************************/
    #region .
    /// <summary> 닉네임 허용 정규식 </summary>
    private static readonly Regex NickNameRegex = 
        new Regex(@"\/([a-zA-Z]+)\s([a-zA-Z0-9가-힣_]+)$");

    /// <summary> 콘솔로 입력받은 채팅 처리 </summary>
    private void ProcessInput(string chatting)
    {
        if (chatting.Length <= 0) return;

        // 1. 명령인지 검사
        // "/command content123"  꼴
        if (chatting[0] == '/')
        {
            GroupCollection groups = CommandRegex.Match(chatting).Groups;

            if (groups.Count < 3)
            {
                Console.WriteLine(WRONG_COMMAND);
            }
            else
            {
                ProcessCommand(groups[1].Value, groups[2].Value);
            }
        }
        // 2. 채팅 처리
        else
        {
            ProcessChatting(chatting);
        }
    }

    /// <summary> 명령 처리 </summary>
    private void ProcessCommand(string command, string content)
    {
        switch (command)
        {
            // 이름 변경 요청
            case "rename":
            case "Rename":
                ChattingPacket packet = new ChattingPacket(content, ChattingCommand.RequestRename);
                _session.Send(packet.ToByteSegment());
                ChangeMyName(content);
                break;

            default:
                Console.WriteLine(WRONG_COMMAND);
                break;
        }
    }

    /// <summary> 일반 채팅 처리 </summary>
    private void ProcessChatting(string content)
    {
        ChattingPacket packet = new ChattingPacket(content, ChattingCommand.Chat);
        _session.Send(packet.ToByteSegment());
    }
    #endregion
    /***********************************************************************
    *                           Handling Server Packets
    ***********************************************************************/
    #region .
    /// <summary> 서버로부터 전달받은 패킷 데이터 처리 </summary>
    public void HandleDataFromServer(in ChattingPacketData data)
    {
        switch (data.command)
        {
            // 일반 채팅
            case ChattingCommand.Chat:
                PrintWithTimeStamp(data.content);
                break;

            // 클라이언트 이름 변경 통지
            case ChattingCommand.NotifyRenamed:
                string[] names = data.content.Split('|');
                PrintWithTimeStamp($"닉네임 변경 : {names[0]} -> {names[1]}");
                break;

            // 클라이언트 입장 통지
            case ChattingCommand.NotifyEntered:
                PrintWithTimeStamp($"({data.content})님이 입장하셨습니다.");
                break;

            // 클라이언트 퇴장 통지
            case ChattingCommand.NotifyExit:
                PrintWithTimeStamp($"({data.content})님이 퇴장하셨습니다.");
                break;

            default:
                throw new Exception("Unknown Command");
        }

        PrintCursor();
    }
    #endregion
}
```

</details>

<br>



## **[2] ChattingClientSession 클래스**

- 서버와 연결 시 클라이언트 측에 생성되는 세션
- 서버와 연결 성공 시 `ChattingClient` 객체를 생성하여 실행시킨다.
- 서버로부터 패킷을 수신할 경우 패킷을 분리하여 `ChattingClient` 객체에 넘겨 처리한다.

<br>

<details>
<summary markdown="span"> 
ChattingClientSession.cs
</summary>

```cs
using System;
using System.Net;

using ByteSegment = System.ArraySegment<byte>;

class ChattingClientSession : Session
{
    private ChattingClient _chatClient;

    protected override void OnConnected(EndPoint endPoint)
    {
        Console.WriteLine($"Conntected To {endPoint}");

        // 채팅 클라이언트 생성 및 시작
        _chatClient = new ChattingClient();
        _chatClient.Run(this);
    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        _chatClient.Quit();
    }

    protected override int OnReceived(ByteSegment buffer)
    {
        // 1. 아직 이름이 지정되지 않은 경우 무시
        if (string.IsNullOrWhiteSpace(_chatClient.Name))
            return buffer.Count;

        // 2. 패킷 데이터 분석
        ChattingPacketData data = ChattingPacketData.FromByteSegment(buffer);

        // 3. 채팅 클라이언트에 전달
        _chatClient.HandleDataFromServer(data);

        return buffer.Count;
    }

    protected override void OnSent(ByteSegment buffer)
    {
        //Console.WriteLine($"Sent : {buffer.Count}\n");
    }
}
```

</details>


<br>

## **[3] ClientProgram**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
using System;
using System.Net;

class ClientProgram
{
    static void Main(string[] args)
    {
        Utility.PrintClientTitle();

        IPInformation ipInfo = new IPInformation(Dns.GetHostName(), 12345);
        Connector connector = new Connector();

        connector.Connect(ipInfo.EndPoint, () => new ChattingClientSession());

        while (true);
    }
}
```

</details>


<br>

# 4. 기타
---

<details>
<summary markdown="span"> 
Utility.cs
</summary>

```cs
using System;

public static class Utility
{
    /// <summary> [HH:mm:ss]꼴 시간 스트링 </summary>
    public static string GetTimeStamp()
    {
        return DateTime.Now.ToString("[HH:mm:ss]");
    }
    
    public static void PrintServerTitle()
    {
        string str =
            "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■\n" +
            "■　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　■\n" +
            "■　　■■■　■■■　■■■■　■　　　■　■■■　■■■■　■\n" +
            "■　■　　　　■　　　■　　■　■　　　■　■　　　■　　■　■\n" +
            "■　　■■　　■■■　■■■　　■　　　■　■■■　■■■　　■\n" +
            "■　　　　■　■　　　■　　■　　■　■　　■　　　■　　■　■\n" +
            "■　■■■　　■■■　■　　■　　　■　　　■■■　■　　■　■\n" +
            "■　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　■\n" +
            "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■\n";
        Console.WriteLine(str);
    }
    public static void PrintClientTitle()
    {
        string str =
            "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■\n" +
            "■　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　■\n" +
            "■　　■■■　■　　　■■■　■■■　■　　　■　■■■■■　■\n" +
            "■　■　　　　■　　　　■　　■　　　■■　　■　　　■　　　■\n" +
            "■　■　　　　■　　　　■　　■■■　■　■　■　　　■　　　■\n" +
            "■　■　　　　■　　　　■　　■　　　■　　■■　　　■　　　■\n" +
            "■　　■■■　■■■　■■■　■■■　■　　　■　　　■　　　■\n" +
            "■　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　■\n" +
            "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■\n";
        Console.WriteLine(str);
    }
}
```

</details>

<br>

# 5. 실행 예시
---

<details>
<summary markdown="span"> 
.
</summary>

## **Client 1**

![image](https://user-images.githubusercontent.com/42164422/127906453-8b992398-c17a-4692-a462-3f4f9bd4a807.png)


## **Client 2**

![image](https://user-images.githubusercontent.com/42164422/127906471-8bfb15a0-9ea3-4fca-a1c3-266a9fbbe51f.png)


## **Server**

![image](https://user-images.githubusercontent.com/42164422/127906483-e2aa6fb1-b209-4e6c-8cda-def5633b87ec.png)

</details>

<br>


# Github Repo
---

- <https://github.com/rito15/Csharp-Tcp-Socket-Console-Chatting>


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







