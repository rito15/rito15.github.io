TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 요약
---

- 패킷의 종류를 `PacketType` 열거형으로 정의하고, `ushort`로 변환하여 각 패킷의 `id` 필드에 할당한다.

- 패킷의 내용을 `SendBuffer`에 작성하는 메소드를 패킷 클래스에서 반드시 작성하도록 한다.

- `ArraySegment<byte>`로부터 패킷으로 변환하는 메소드 역시 패킷 클래스에서 반드시 작성하도록 한다.

- `ArraySegment<byte>`를 `Packet`으로 다시 변환하는 과정에서 세그먼트의 길이가 `Packet`에 필요한 전체 길이와 다르면 예외를 콜해줘야 한다.

<br>



# PacketType 열거형 정의
---

- 패킷의 타입을 명시적으로 지정하기 위해 열거형으로 정의한다.

- 패킷의 자식 클래스들은 각각 열거형 값으로 1:1 대응된다.

```cs
public enum PacketType
{
    Echo,
    Number,
}
```

<br>



# Packet 최상위 클래스 정의
---

추상 클래스인 `Packet` 클래스를 다음과 같이 정의한다.

```cs
public abstract class Packet
{
    public ushort size;
    public ushort id;
    
    protected const ushort BaseSize = sizeof(ushort) * 2;

    public Packet(PacketType packetType)
    {
        this.id = (ushort)packetType;
        this.size = (ushort)(BaseSize + DataSize);
    }
    
    /// <summary> Send Buffer에 Size, Id 직렬화하여 작성하기 </summary>
    protected void WriteSizeAndIdToSendBuffer()
    {
        SendBuffer.Factory.Write(this.size);
        SendBuffer.Factory.Write(this.id);
    }

    /// <summary> size, id를 제외한 패킷의 크기 </summary>
    protected abstract int DataSize { get; }

    /// <summary> Send Buffer에 패킷을 직렬화하여 작성하기 </summary>
    public abstract void WriteToSendBuffer();
}
```

<br>



# 예시 패킷 클래스 작성
---

## **EchoPacket**

- 크기와 `id`를 제외한 다른 데이터는 갖고 있지 않은, 가장 간단한 `EchoPacket`을 작성한다.

```cs
public class EchoPacket : Packet
{
    protected override int DataSize => 0;

    public EchoPacket() : base(PacketType.Echo) { }

    public override void WriteToSendBuffer()
    {
        WriteSizeAndIdToSendBuffer();
    }

    public override string ToString()
    {
        return $"[Echo Packet(ID : {this.id})]";
    }
}
```

<br>

## **NumberPacket**

- 단순히 `int` 타입 숫자를 하나 전송하는 패킷을 작성한다.

```cs
public class NumberPacket : Packet
{
    public int number;
    protected override int DataSize => sizeof(int);

    public NumberPacket(int number) : base(PacketType.Number)
    {
        this.number = number;
    }

    public override void WriteToSendBuffer()
    {
        WriteSizeAndIdToSendBuffer();
        SendBuffer.Factory.Write(this.number);
    }

    public override string ToString()
    {
        return $"[Number Packet(ID : {this.id})] Number : {this.number}";
    }
}
```

<br>

# Packet 클래스 보강하기
---

- `Packet` 클래스에`ArraySegment<byte>`를 해석하여 알맞은 패킷 객체를 생성하고 리턴해주는 정적 메소드를 작성한다.

```cs
/// <summary> ArraySegment를 해석하여 패킷 객체 리턴 </summary>
public static (PacketType, Packet) CreateFromByteSegment(ArraySegment<byte> segment)
{
    // 크기가 잘못된 경우 [1]
    if (segment.Count < BaseSize)
        return (default, null);

    int offset = 0;

    ushort size = MemoryMarshal.Read<ushort>(new ReadOnlySpan<byte>(segment.Array, offset, sizeof(ushort)));
    offset += sizeof(ushort);

    // 크기가 잘못된 경우 [2]
    if (size < BaseSize)
        return (default, null);

    // 크기가 잘못된 경우 [3]
    if (size != segment.Count)
        return (default, null);

    // ID를 통해 패킷 타입 추론
    ushort id = MemoryMarshal.Read<ushort>(new ReadOnlySpan<byte>(segment.Array, offset, sizeof(ushort)));
    offset += sizeof(ushort);

    PacketType type = (PacketType)id;
    Packet packet = null;

    // 패킷 타입에 따라 생성
    switch (type)
    {
        case PacketType.Echo:
            packet = new EchoPacket();
            break;

        case PacketType.Number:
            int number = MemoryMarshal.Read<ushort>(new ReadOnlySpan<byte>(segment.Array, offset, sizeof(int)));
            packet = new NumberPacket(number);
            break;
    }

    return (type, packet);
}
```

<br>

# 테스트
---



<br>



# Future Works
---

- 패킷을 `readonly struct`로 만들어도 될 것 같다.

- 그렇게 되면 패킷의 공통 인터페이스를 `IPacket`으로 정의하는게 나을듯

<br>






# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







