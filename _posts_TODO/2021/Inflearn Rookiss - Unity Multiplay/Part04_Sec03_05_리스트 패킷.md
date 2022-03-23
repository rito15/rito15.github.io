TITLE : 리스트 패킷

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# 요약
---

- 가변 길이의 리스트를 저장하는 패킷을 작성한다.

<br>


# 주요 내용
---

## PacketType 열거형 값 추가

```cs
public enum PacketType
{
    Default,
    Echo,
    Number,
    Utf8String,
    Vector3List, // 추가

    SIZE,
}
```

<br>

## Vector3 구조체

```cs
public struct Vector3
{
    public float x, y, z;

    public Vector3(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}
```

<br>

## Vector3ListPacket 클래스

```cs
public class Vector3ListPacket : Packet
{
    protected override int DataSize => sizeof(ushort) + (sizeof(float) * 3 * dataCount);

    public ushort dataCount;
    public List<Vector3> dataList;

    public Vector3ListPacket(IEnumerable<Vector3> dataSet) : base(PacketType.Vector3List)
    {
        this.dataList = new List<Vector3>(dataSet);
        this.dataCount = (ushort)this.dataList.Count;

        InitalizeSize();
    }

    protected override void WriteDataToSendBuffer()
    {
        SendBuffer.Factory.Write(this.dataCount);

        for (int i = 0; i < this.dataCount; i++)
        {
            SendBuffer.Factory.Write(this.dataList[i].x);
            SendBuffer.Factory.Write(this.dataList[i].y);
            SendBuffer.Factory.Write(this.dataList[i].z);
        }
    }

    public override string ToString()
    {
        STR str = STR.Begin();
        str.Add($"[Vector3 List Packet(ID : {this.ID})]\n");

        for (int i = 0; i < this.dataCount; i++)
        {
            str.Add("[").Add(i).Add("] X : ")
                .Add(this.dataList[i].x).Add(", Y : ")
                .Add(this.dataList[i].y).Add(", Z : ")
                .Add(this.dataList[i].z).Add("\n");
        }

        return str.End();
    }
}
```

<br>

## Packet.CreateFromByteSegment() 메소드 일부

```cs
case PacketType.Vector3List:
    ushort dataListCount = ByteSerializer.ReadUshort(segment, ref offset);

    // 리스트 길이 검증
    ushort desiredDataListCount = (ushort)((packetSize - HeaderSize - sizeof(ushort)) / (sizeof(float) * 3));
    if (dataListCount != desiredDataListCount)
    {
        throw new Exception($"데이터 리스트의 크기({dataListCount})가 예상된 크기({desiredDataListCount})와 일치하지 않습니다.");
    }

    List<Vector3> dataList = new List<Vector3>(dataListCount);
    for (int i = 0; i < dataListCount; i++)
    {
        Vector3 vec = new Vector3();
        vec.x = ByteSerializer.ReadFloat(segment, ref offset);
        vec.y = ByteSerializer.ReadFloat(segment, ref offset);
        vec.z = ByteSerializer.ReadFloat(segment, ref offset);
        dataList.Add(vec);
    }

    packet = new Vector3ListPacket(dataList);

    break;
```








# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







