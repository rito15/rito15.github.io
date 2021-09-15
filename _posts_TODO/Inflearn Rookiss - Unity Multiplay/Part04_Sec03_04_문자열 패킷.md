TITLE : 문자열 패킷

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 주요 내용
---

- 가변 길이의 문자열 패킷을 정의하고 전송한다.

<br>



# 문자열 패킷 클래스 정의
---

- `UTF-8`로 인코딩되는 문자열 패킷 클래스를 정의한다.

<br>

```cs
public class UTF8StringPacket : Packet
{
    public readonly ushort strLen;
    public readonly string strData;
    protected override int DataSize => sizeof(ushort) + strLen;

    // 생성자 : 스트링의 길이를 이미 알고 있는 경우
    public UTF8StringPacket(string strData, ushort strLen) : base(PacketType.Utf8String)
    {
        this.strData = strData;
        this.strLen = strLen;

        base.size = TotalSize; // size 다시 계산
    }

    // 생성자 : 스트링만으로 바로 생성하려는 경우
    public UTF8StringPacket(string strData) : this(strData, (ushort)Encoding.UTF8.GetByteCount(strData)) { }

    protected override void WriteDataToSendBuffer()
    {
        SendBuffer.Factory.Write(this.strLen);
        SendBuffer.Factory.WriteUtf8String(this.strData);
    }

    public override string ToString()
    {
        return $"[UTF-8 String Packet(ID : {this.id})] String : {this.strData}, Length : {this.strLen}";
    }
}
```

<br>

# 기타 변경사항
---

## **Packet 클래스**

- 자식 클래스에서 `WriteSizeAndIdToSendBuffer()` 메소드를 불필요하게 매번 호출할 필요가 없도록, 다음과 같이 변경

```cs
/// <summary> Send Buffer에 패킷을 직렬화하여 작성 </summary>
public void WriteToSendBuffer()
{
    SendBuffer.Factory.Write(this.size);
    SendBuffer.Factory.Write(this.id);
    WriteDataToSendBuffer();
}

/// <summary> Send Buffer에 Size, Id를 제외한 부분을 직렬화하여 작성 </summary>
protected abstract void WriteDataToSendBuffer();
```

<br>



## **SendBuffer 클래스**

- 버퍼에 데이터 작성 시, 여유 길이를 검사하여 확장하는 작업은 `Factory`가 아니라 클래스 내에서 직접 수행하도록 변경

```cs
// Factory
public static void Write(ushort data)
{
    CheckBufferCreated();
    CurrentBuffer.Value.Write(data);
}

// SendBuffer
/// <summary> 버퍼의 여유 길이를 검사 </summary>
private bool IsWritable(int len)
{
    return len < WritableSize;
}

/// <summary> 버퍼의 여유 길이를 검사하고, 부족하면 커서 당겨오기 </summary>
private void CheckWritableOrRefresh(int len)
{
    if (!IsWritable(len)) Refresh();
}

public void Write(ushort data)
{
    const int len = sizeof(ushort);
    CheckWritableOrRefresh(len);

    bool success = ByteSerializer.WriteUshort(_buffer, _writePos, data);
    if (!success)
    {
        HandleWriteFailure(data);
        return;
    }
    _writePos += len;
}
```

<br>



## **PacketSession 클래스**

- 패킷을 SendBuffer에 작성하고, 읽어오는 과정에서 데이터의 길이를 검사하여 직렬화 성공 여부를 검증한다.

```cs
/// <summary> 패킷 전송하기 </summary>
public void SendPacket(Packet packet)
{
    // 2021. 08. 11. 추가 : 연결 끊긴 경우 확인
    if (_isConnected == FALSE)
        return;

    // 1. 패킷을 Send Buffer에 작성
    packet.WriteToSendBuffer();

    // 2. Send Buffer로부터 직렬화된 패킷 데이터 가져와서 전송
    ByteSegment readSegment = SendBuffer.Factory.Read();

    // 패킷 직렬화 과정이 모두 성공했는지, 크기를 이용해 검증
    if (readSegment.Count == packet.size)
    {
        Send(readSegment);

        Logger.Log($"Sending Packet Succeeded - {packet}");
    }
    else
    {
        Logger.Log($"Sending Packet Failed - {packet}");
    }
}
```

<Br>



# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







