TITLE : 패킷 처리 기능 분리

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 주요 내용
---

- 서버, 클라이언트 세션에서 패킷을 전달받아 처리하는 기능을 다른 클래스로 분리한다.

<br>

# 패킷 수신부
---

서버, 클라이언트 세션 클래스를 각각 살펴보면

```cs
protected override bool OnReceivePacket(ArraySegment<byte> buffer)
{
    // 0 : Size, 2 : ID
    ushort id = ByteSerializer.Read_ushort(buffer, sizeof(ushort));
    PacketType packetType = (PacketType)id;

    bool receiveSucceeded = true;

    switch (packetType)
    {
        // 잘못된 패킷 도착 시 : 패킷, 수신 버퍼 폐기
        case PacketType.Default:
            Logger.Log($"[From Client] Wrong Packet\n");
            return false;

        case PacketType.Echo:
            {
                EchoPacket packet = new EchoPacket();
                receiveSucceeded = packet.ReadFromSegment(buffer);
                Logger.Log($"[From Client] {packet}\n");
            }
            break;
        
        // ...
    }

    return receiveSucceeded;
}
```

이런 식으로 패킷을 전달받아 처리하는 부분이 있다.

'수신'과 '처리'가 한 곳에 모여 있는 셈인데,

확장성을 고려하면 이를 분리할 필요가 있다.


<br>

# 패킷 처리반
---

## **인터페이스, 추상 클래스 작성**

굳이 이렇게 할 필요는 없지만, 서버와 클라이언트 측의 공통 API를 정의하기 위해

```cs
public interface IPacketHandler
{
    public void Handle(ArraySegment<byte> buffer);
}

public abstract class PacketHandler
{
    protected PacketSession session;
    public PacketHandler(PacketSession session)
    {
        this.session = session;
    }
    
    public abstract void Handle(ArraySegment<byte> buffer);
}
```

**ServerCore**에 위와 같이 작성한다.

<br>

## **서버, 클라이언트 측 클래스 작성**

그리고 서버와 클라이언트 측에서는 이를 구현하는 클래스를 작성한다.

```cs
internal class ServerPacketHandler : PacketHandler
{
    public ServerPacketHandler(PacketSession session) : base(session){}

    public override void Handle(ArraySegment<byte> buffer)
    {
        ushort id = ByteSerializer.Read_ushort(buffer, sizeof(ushort));
        PacketType packetType = (PacketType)id;

        switch (packetType)
        {
            case PacketType.Echo:
                {
                    EchoPacket packet = new EchoPacket();
                    packet.ReadFromSegment(buffer);
                    ProcessPacket(packet);
                }
                break;
                    
            case PacketType.Number:
                {
                    NumberPacket packet = new NumberPacket();
                    packet.ReadFromSegment(buffer);
                    ProcessPacket(packet);
                }
                break;

            case PacketType.String:
                {
                    StringPacket packet = new StringPacket();
                    packet.ReadFromSegment(buffer);
                    ProcessPacket(packet);
                }
                break;

            case PacketType.Vector3:
                {
                    Vector3Packet packet = new Vector3Packet();
                    packet.ReadFromSegment(buffer);
                    ProcessPacket(packet);
                }
                break;

            case PacketType.Vector3List:
                {
                    Vector3ListPacket packet = new Vector3ListPacket();
                    packet.ReadFromSegment(buffer);
                    ProcessPacket(packet);
                }
                break;

            default:
                Logger.Log($"Unhandled Packet - Type : {packetType}");
                break;
        }
    }

    public void ProcessPacket(EchoPacket packet)
    {

    }

    public void ProcessPacket(NumberPacket packet)
    {

    }

    public void ProcessPacket(StringPacket packet)
    {

    }

    public void ProcessPacket(Vector3Packet packet)
    {

    }

    public void ProcessPacket(Vector3ListPacket packet)
    {

    }
}
```

생성자를 통해 세션 객체를 저장한다.

그리고 `Handle(ArraySegment<byte> buffer)` 메소드에서 패킷 타입별로 알맞는 패킷 객체들을 생성하고

패킷 타입별로 오버로딩된 각각의 메소드로 전달하여 처리한다.

<br>

## **제네릭을 이용한 리팩토링**

추후 변경을 고려해봤을 때, 처리할 패킷 하나가 늘어날 때마다

```cs
// [1]
case PacketType.Vector3List:
    {
        Vector3ListPacket packet = new Vector3ListPacket();
        packet.ReadFromSegment(buffer);
        ProcessPacket(packet);
    }
    break;
    
// [2]
public void ProcessPacket(Vector3ListPacket packet)
{

}
```

이렇게 두 가지를 추가해줘야 하는 번거로움이 있다.

사실 어쩔 수 없는 부분이기는 하지만, 제네릭을 활용하여 조금 더 다이어트 시켜줄 수 있다.

```cs
public T GeneratePacket<T>(ArraySegment<byte> buffer) where T : Packet, new()
{
    T packet = new T();
    packet.ReadFromSegment(buffer);
    return packet;
}
```

위와 같은 메소드를 만들어 놓으면

```cs
switch (packetType)
{
    case PacketType.Echo:
        ProcessPacket(GeneratePacket<EchoPacket>(buffer));
        break;
                    
    case PacketType.Number:
        ProcessPacket(GeneratePacket<NumberPacket>(buffer));
        break;

    case PacketType.String:
        ProcessPacket(GeneratePacket<StringPacket>(buffer));
        break;

    case PacketType.Vector3:
        ProcessPacket(GeneratePacket<Vector3Packet>(buffer));
        break;

    case PacketType.Vector3List:
        ProcessPacket(GeneratePacket<Vector3ListPacket>(buffer));
        break;

    default:
        Logger.Log($"Unhandled Packet - Type : {packetType}");
        break;
}
```

이렇게 각 케이스마다 한 줄씩만 작성하도록 줄여줄 수 있다.

<br>

강좌처럼 딕셔너리를 사용하여 더 줄여줄 수도 있지만,

`switch-case`와 딕셔너리는 애초에 성능 차이가 발생하므로

극한의 다이어트보다는 이정도의 타협을 하는 것으로 마무리한다.

<br>

# 서버, 클라이언트 세션 변경
---

```cs
class ClientSession : PacketSession
{
    private PacketHandler packetHandler;

    protected override void OnConnected(EndPoint endPoint)
    {
        Logger.Log($"Session Connected : {endPoint}\n");
        packetHandler = new ServerPacketHandler(this);
    }

    protected override void OnDisconnected(EndPoint endPoint)
    {
        Logger.Log($"Session Disconnected : {endPoint}\n");
    }

    // Note : 최종적으로 OnReceivePacket()에서 패킷 검증이 필요 없어지는 경우,
    //        bool 대신 void 리턴하도록 시그니처 변경
    protected override bool OnReceivePacket(ArraySegment<byte> buffer)
    {
        packetHandler.Handle(buffer);

        // 자동 응답하기(에코)
        SendPacket(new EchoPacket());

        return true;
    }

    protected override void OnSent(int numOfBytes)
    {
        Logger.Log($"[To Client] Transferred Bytes : {numOfBytes}");
    }
}
```

서버와 클라이언트의 세션에 위와 같이 `PacketHandler packetHandler` 필드를 만들고,

`OnReceived()` 메소드에서 이 필드에 패킷을 전달하여 처리하도록 위임한다.

<br>







# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







