TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>


# 기존 직렬화의 문제점
---

```cs
// PacketSession Class
public void SendPacket(Packet packet)
{
    byte[] size = BitConverter.GetBytes(packet.size); // 중간 배열 생성
    byte[] id = BitConverter.GetBytes(packet.id);     // 중간 배열 생성
    SendBuffer.Factory.Write(size, id);
    Send(SendBuffer.Factory.Read());
}

// SendBuffer Class
public void Write(byte[] data)
{
    int len = data.Length;
    CheckWriteError(len);

    // Write Pos부터 len 길이만큼 버퍼에 쓰기
    Array.Copy(data, 0, _buffer, _writePos, len);

    // Write Pos 이동
    _writePos += len;
}
```

패킷들을 직렬화하여 하나의 `byte[]`로 만들고자 할 때,

패킷 내의 필드마다 `byte[]`를 생성한다.

따라서 필드의 개수만큼 동적으로 배열을 생성하여

가비지를 생성하는 치명적인 문제가 발생한다.

<br>

# 해결책
---

## [1] BitConverter.TryWriteBytes() 사용하기

- `BitConverter.GetBytes()` 대신 `BitConverter.TryWriteBytes()`를 사용하여, 배열을 생성하지 않고 목표 배열의 특정 인덱스부터 직접 값을 넣어줄 수 있다.

- 하지만 `.NET Framework 4.x`에서는 사용할 수 없고, `.NET Core`에서 사용 가능하다.

```cs
// SendBuffer Class
public void Write(ushort data)
{
    const int len = sizeof(ushort);
    CheckWriteError(len);

    BitConverter.TryWriteBytes(new Span<byte>(_buffer, _writePos, len), data);
    _writePos += len;
}
```


<br>

## [2] unsafe를 통해 메모리 직접 참조하기

```cs
unsafe static void WriteToByteArray(byte[] array, int offset, ushort value)
{
    fixed(byte* ptr = &array[offset])
        *(ulong*)ptr = value;
}

// SendBuffer Class
public void Write(ushort data)
{
    const int len = sizeof(ushort);
    CheckWriteError(len);

    WriteToByteArray(_buffer, _writePos, data);

    _writePos += len;
}
```

- 위와 같이 `unsafe` 구문 내에서 배열 내의 메모리를 직접 참조하여, 값을 넣어준다.

<br>


## [3] bit 연산으로 자리를 맞추어 값 넣기

```cs
// SendBuffer Class

// ★Little Endian
private static readonly int[] UshortMaskOffsets =
{
    0, 8
};

public void Write(ushort data)
{
    const int len = sizeof(ushort);
    CheckWriteError(len);

    for (int i = 0; i < len; i++)
    {
        _buffer[_writePos + i] = (byte)(data >> UshortMaskOffsets[i]);
    }
    _writePos += len;
}
```

- `ushort`는 `2바이트`이므로 `1바이트`씩 자리를 나누어 마스크 연산을 통해 두 개의 `byte` 값으로 분할한다.
- 분할한 값들을 배열에 차곡차곡 넣어준다.

- 시스템에 따라, `Big Endian`과 `Little Endian`인지 확인하여 `MaskOffset` 배열의 내용 순서를 결정해야 한다.
- 엔디언은 `BitConverter.IsLittleEndian`으로 확인할 수 있다.

<br>



# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://genesis8.tistory.com/37>







