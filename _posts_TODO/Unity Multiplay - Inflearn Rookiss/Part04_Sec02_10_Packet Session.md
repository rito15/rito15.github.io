TITLE : Packet Session

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# 패킷 설계
---

```cs
public class Packet
{
    public ushort size;
    public ushort id;
}
```

- 패킷의 맨 앞부분에는 크기 정보, 바로 뒤에 패킷의 `id`를 넣어준다.

- 두 데이터의 타입을 `2byte`인 `ushort`로 지정하여 패킷의 크기를 최대한 줄여준다.

<br>

# PacketSession 클래스
---

- 세션 중에서도 패킷을 사용하는 세션을 따로 구분하여 작성한다.

- 완전한 패킷이 도착하지 않은 경우에는 무시한다.

- 완전한 패킷이 도착한 경우에만 패킷을 처리한다.

```cs
using ByteSegment = ArraySegment<byte>;

/// <summary> 패킷을 사용하는 세션 </summary>
public abstract class PacketSession : Session
{
    /// <summary> 패킷 헤더 길이 </summary>
    public static readonly ushort HeaderSize = 2;

    protected sealed override int OnReceived(ByteSegment buffer)
    {
        // 처리한 데이터 길이
        int processedLen = 0;

        while (true)
        {
            // 1. 헤더 파싱조차 불가능하게 작은 데이터가 온 경우, 처리 X
            if (buffer.Count < HeaderSize)
                break;

            // 헤더를 확인하여 패킷이 완전히 도착했는지 여부 확인
            ushort dataLen = BitConverter.ToUInt16(buffer.Array, buffer.Offset);

            // 2. 아직 완전한 패킷이 도착한 것이 아닌 경우, 처리 X
            if (buffer.Count < dataLen)
                break;

            // 3. 완전한 패킷 처리
            OnReceivePacket(new ByteSegment(buffer.Array, buffer.Offset, dataLen));
            processedLen += dataLen;

            // 4. 다음 패킷 확인(Offset 이동)
            buffer = new ByteSegment(buffer.Array, buffer.Offset + dataLen, buffer.Count - dataLen);
        }

        return processedLen;
    }

    protected abstract void OnReceivePacket(ByteSegment buffer);
}
```

<br>

- `Session` 클래스의 `OnReceiveCompleted()` 메소드 내에서 `OnReceived()` 메소드를 호출하는 부분을 간략화하여 살펴보면 다음과 같다.

```cs
// 컨텐츠 쪽에 데이터를 넘겨주고, 처리된 데이터 길이 반환받기
int processedLen = OnReceived(_recvBuffer.ReadableSegment);

// 처리된 데이터 길이만큼 Receive Buffer의 Read 커서 이동
_recvBuffer.OnRead(processedLen);
```

`OnReceived()` 메소드에서 넘겨준 길이만큼 `Receive Buffer`의 `Read Cursor`를 이동하고,

다음 `OnReceiveCompleted()` 호출 시 `Read Cursor`부터 `Write Cursor` 사이의 데이터를

`OnRecived()` 메소드에 세그먼트로 넘겨주는 것을 반복하게 된다.

위와 같은 방식으로 `OnReceiveCompleted()`와 `OnReceived()`가 상호작용하여

패킷이 완성되는 경우에만 정확히 처리되도록 하는 과정을 확인할 수 있다.

<br>

# 임시 메소드 작성
---

- 기본 패킷의 전송과 분석을 위한 메소드를 `PacketSession` 클래스 내에 임시로 작성한다.

```cs
/// <summary> 기본 패킷 정보 읽기(임시) </summary>
protected string GetPacketInfo(ByteSegment buffer)
{
    ushort size = BitConverter.ToUInt16(buffer.Array, buffer.Offset);
    ushort id = BitConverter.ToUInt16(buffer.Array, buffer.Offset + sizeof(ushort));

    return $"Size : {size}, ID : {id}";
}

/// <summary> 기본 패킷 전송하기(임시) </summary>
public void SendPacket(Packet packet)
{
    byte[] size = BitConverter.GetBytes(packet.size);
    byte[] id = BitConverter.GetBytes(packet.id);
    SendBuffer.Factory.Write(size, id);
    Send(SendBuffer.Factory.Read());
}
```

<br>

# 자식 Session 클래스 변경
---

## **[1] GameSession 클래스**

- 서버에서 사용하는 `GameSession` 클래스가 `PacketSession`을 상속받도록 변경한다.

```cs
protected override int OnReceived(ArraySegment<byte> buffer)
{
    string recvData = Encoding.UTF8.GetString(buffer.Array, buffer.Offset, buffer.Count);
    Console.WriteLine($"[From Client] {recvData}");

    // 자동 응답하기
    Send("Server Responded.");

    // 처리한 데이터 길이 반환
    return buffer.Count;
}
```

위와 같이 작성한 `OnReceived()` 메소드를 제거하고,

대신 `OnReceivePacket()` 메소드를 구현한다.

```cs
protected override void OnReceivePacket(ArraySegment<byte> buffer)
{
    string packetInfo = GetPacketInfo(buffer);
    Console.WriteLine($"[From Client] {packetInfo}");

    // 자동 응답하기
    SendPacket(new Packet { size = sizeof(ushort) * 2, id = 1234 });
}
```

<br>

## **[2] ClientSession 클래스**

- 클라이언트에서 사용되는 세션 클래스도 마찬가지로 변경한다.
- 서버의 자동 응답과는 다르게, 일정 주기로 서버에 패킷을 전송하는 테스트 기능을 작성한다.

```cs
protected override void OnConnected(EndPoint endPoint)
{
    Console.WriteLine($"Session Connected : {endPoint}\n");

    EchoTestAsync();
}

protected override void OnReceivePacket(ArraySegment<byte> buffer)
{
    string packetInfo = GetPacketInfo(buffer);
    Console.WriteLine($"[From Server] {packetInfo}");
}

private async void EchoTestAsync(int maxCount = 100)
{
    await Task.Run(async () => 
    {
        for (int i = 0; i < maxCount; i++)
        {
            SendPacket(new Packet { size = sizeof(ushort) * 2, id = (ushort)i });
            await Task.Delay(1000);
        }
    });
}
```


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







