TITLE : 패킷 생성 자동화를 위한 리팩토링

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# 패킷 자동화 구현 이전 변경사항
---

강의의 내용과는 좀 다르게, 나는 `Packet` 클래스에서 정적 메소드 `CreateFromByteSegment()` 메소드를 통해

`ArraySegment<byte> buffer` 매개변수를 받아 이를 분석하고, 해당하는 패킷을 만들어 리턴하도록 구현했다.

이를 변경하여 자동화에 적합하도록

`ArraySegment<byte>`를 해석하여 패킷을 생성하는 부분은 각자의 클래스에

`bool Read(ArraySegment<byte> buffer)`처럼 작성하도록 변경해야 할 것 같다.

기존 방식처럼 정적 메소드를 통해 생성하는 방식은 언제나 가비지를 생성하기 때문에

강의의 방식인 "객체 생성 후 버퍼 읽어들여 필드 초기화"가 나을 것 같다.

이렇게 하면 이미 만들어진 객체를 이용해 재사용할 수 있다는 이점도 있다.

그리고 `Size` 같은 프로퍼티 또한 없애는 것이 좋을 것 같다.

`Size`는 패킷과 버퍼의 변환 간에 필요할 뿐, 패킷 클래스가 이를 보관할 필요도 없다.

지금 `Size` 프로퍼티는 생성자로부터 초기화되며 `Write()` 메소드에서 사용되는데,

없애버리고 그냥 매번 `Write()`에서 계산하도록 하는 것이 좋을 듯하다.

마지막으로 리스트를 필드로 갖는 패킷은 내부 구조체를 선언하고

재귀적으로 `Read/Write`를 수행하도록 변경해야 한다.

마지막으로 생성자에 대한 고민이 있는데,

굳이 패킷별로 거창한 옵션을 주는 것보다

기본 생성자 하나, 모든 필드에 대한 매개변수를 받아 전부 초기화하는 생성자 하나씩 작성하면 될 것 같다.

<br>

## **정리 : 자동화를 위한 변경**
- 각 패킷 클래스마다 생성자는 기본 생성자와 전부 초기화 생성자 두 개만 작성
- `Size` 프로퍼티 제거
- `Packet` 클래스의 `CreateFromByteSegment()` 메소드 제거 및 각 패킷 클래스에 `Read()` 메소드 작성
- 리스트 필드가 존재하는 경우, 내부 구조체 선언 및 재귀 구조로 변경

<br>

# 자동화를 위한 리팩토링
---

## **Packet 클래스**

- `Size`, `DataSize` 프로퍼티 제거

- `CreateFromByteSegment()` 메소드 제거

- 하위 패킷들에서 사용할 `ValidateSegment(ArraySegment<byte>, out int)` 메소드 작성

- `WriteToSendBuffer()`, `ReadFromSegment(ArraySegment<byte>)` 메소드 작성

```cs
public abstract class Packet
{
    public ushort ID { get; private set; }

    /// <summary> 패킷 헤더(Size + ID)의 길이 </summary>
    protected const ushort HeaderSize = sizeof(ushort) * 2;

    // 생성자
    public Packet(PacketType packetType)
    {
        this.ID = (ushort)packetType;
    }

    /// <summary> 세그먼트 유효성 검증 및 시작 오프셋 지정 </summary>
    protected bool ValidateSegment(ArraySegment<byte> segment, out int offsetBegin)
    {
        offsetBegin = 0;

        // 전달받은 패킷의 크기
        int packetSize = segment.Count;

        // 세그먼트의 크기가 패킷의 기본 크기보다 작은 경우
        if (packetSize < HeaderSize)
        {
            Logger.Log($"Packet Segment Validation : 패킷의 크기가 너무 작습니다 ({packetSize})");
            return false;
        }

        // Size, ID 부분을 건너뛰고 offset 시작
        offsetBegin = sizeof(ushort) * 2;

        // ID 불일치 확인 - ID를 확인한 상태에서 오기 때문에 검증 필요 X
        //ushort id = ByteSerializer.Read_ushort(segment, ref offset);
        //if (this.ID != id) return false;

        return true;
    }

    /// <summary> 모두 직렬화하여 Send Buffer에 작성 </summary>
    public abstract void WriteToSendBuffer();

    /// <summary> 세그먼트로부터 역직렬화하여 필드 초기화 </summary>
    public abstract void ReadFromSegment(ArraySegment<byte> segment);
}
```

<br>

## **예시 : StringPacket**

```cs
public class StringPacket : Packet
{
    public string str;

    public StringPacket() : base(PacketType.String) { }
    public StringPacket(string str) : this()
    {
        this.str = str;
    }

    public override void WriteToSendBuffer()
    {
        // 패킷 전체 크기 계산
        ushort size = HeaderSize; // Size + ID

        ushort strLen = (ushort)ByteSerializer.DefaultStringEncoding.GetByteCount(this.str);
        size += sizeof(ushort);   // strLen
        size += strLen;           // this.str

        // 버퍼에 차례대로 작성
        SendBuffer.Factory.Write(size);
        SendBuffer.Factory.Write(this.ID);

        SendBuffer.Factory.Write(strLen);
        SendBuffer.Factory.Write(this.str);
    }

    public override void ReadFromSegment(ArraySegment<byte> segment)
    {
        int offset = HeaderSize;

        ushort strLen = ByteSerializer.Read_ushort(segment, ref offset);
        this.str = ByteSerializer.Read_string(segment, ref offset, strLen);
    }

    public override string ToString()
    {
        return $"[String Packet(ID : {ID})] String : {str}";
    }
}
```

<br>

## **예시 : Vector3Packet**

```cs
public class Vector3Packet : Packet
{
    public float x;
    public float y;
    public float z;

    public Vector3Packet() : base(PacketType.Vector3) { }
    public Vector3Packet(float x, float y, float z) : this()
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public override void WriteToSendBuffer()
    {
        // 패킷 전체 크기 계산
        ushort size = HeaderSize; // Size + ID

        size += sizeof(float); // this.x
        size += sizeof(float); // this.y
        size += sizeof(float); // this.z

        // 버퍼에 차례대로 작성
        SendBuffer.Factory.Write(size);
        SendBuffer.Factory.Write(this.ID);

        SendBuffer.Factory.Write(this.x);
        SendBuffer.Factory.Write(this.y);
        SendBuffer.Factory.Write(this.z);
    }

    public override void ReadFromSegment(ArraySegment<byte> segment)
    {
        int offset = HeaderSize;

        this.x = ByteSerializer.Read_float(segment, ref offset);
        this.y = ByteSerializer.Read_float(segment, ref offset);
        this.z = ByteSerializer.Read_float(segment, ref offset);
    }

    public override string ToString()
    {
        return $"[Vector3 Packet(ID : {ID})] x : {x}, y : {y}, z : {z}";
    }
}
```

<br>

## **예시 : Vector3ListPacket**

```cs
public class Vector3ListPacket : Packet
{
    public class Vector3
    {
        public float x;
        public float y;
        public float z;

        public static ushort GetPacketSize()
        {
            ushort size = 0;
            size += sizeof(float);
            size += sizeof(float);
            size += sizeof(float);
            return size;
        }

        public void WriteToSendBuffer()
        {
            SendBuffer.Factory.Write(this.x);
            SendBuffer.Factory.Write(this.y);
            SendBuffer.Factory.Write(this.z);
        }

        public void ReadFromSegment(ArraySegment<byte> segment, ref int offset)
        {
            this.x = ByteSerializer.Read_float(segment, ref offset);
            this.y = ByteSerializer.Read_float(segment, ref offset);
            this.z = ByteSerializer.Read_float(segment, ref offset);
        }
    }

    public List<Vector3> vector3List;

    public Vector3ListPacket() : base(PacketType.Vector3List) { }
    public Vector3ListPacket(IEnumerable<Vector3> dataSet) : this()
    {
        this.vector3List = new List<Vector3>(dataSet);
    }

    public override void WriteToSendBuffer()
    {
        // 패킷 전체 크기 계산
        ushort size = HeaderSize; // Size + ID

        ushort vector3ListCount = (ushort)this.vector3List.Count;
        ushort vector3ListSize = (ushort)(Vector3.GetPacketSize() * vector3ListCount);
        size += sizeof(ushort);   // vector3ListCount
        size += vector3ListSize;  // this.vector3List

        // 버퍼에 차례대로 작성
        SendBuffer.Factory.Write(size);
        SendBuffer.Factory.Write(this.ID);

        SendBuffer.Factory.Write(vector3ListCount);
        for (int i = 0; i < vector3ListCount; i++)
        {
            this.vector3List[i].WriteToSendBuffer();
        }
    }

    public override void ReadFromSegment(ArraySegment<byte> segment)
    {
        int offset = HeaderSize;

        ushort vector3ListCount = ByteSerializer.Read_ushort(segment, ref offset);
        this.vector3List = new List<Vector3>(vector3ListCount);

        for (int i = 0; i < vector3ListCount; i++)
        {
            Vector3 vector3 = new Vector3();
            vector3.ReadFromSegment(segment, ref offset);
            this.vector3List.Add(vector3);
        }
    }

    public override string ToString()
    {
        STR str = STR.Begin()
            .Add("[Vector3List Packet(ID : ").Add(ID).Add(")]\n");

        for (int i = 0; i < this.vector3List.Count; i++)
        {
            Vector3 vec = this.vector3List[i];
            str.Add("[").Add(i).Add("]")
                .Add(" x : ").Add(vec.x)
                .Add(" y : ").Add(vec.y)
                .Add(" z : ").Add(vec.z)
                .Add("\n");
        }

        return str.End();
    }
}
```

<br>



# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







