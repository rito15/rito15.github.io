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
    (PacketType packetType, Packet packet) = Packet.CreateFromByteSegment(buffer);

    switch (packetType)
    {
        // 잘못된 패킷 도착 시 : 패킷, 수신 버퍼 폐기
        case PacketType.Default:
            Logger.Log($"[From Client] Wrong Packet\n");
            return false;

        // 임시 : 패킷 정보를 로그로 출력
        default:
            Logger.Log($"[From Client] {packet}\n");

            // 자동 응답하기(에코)
            SendPacket(new EchoPacket());
            break;
    }

    return true;
}
```

이런 식으로 패킷을 전달받아 처리하는 부분이 있다.

'수신'과 '처리'가 한 곳에 모여 있는 셈인데,

확장성을 고려하면 이를 분리할 필요가 있다.











# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







