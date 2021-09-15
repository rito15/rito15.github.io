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

- 하지만 `.NET Framework 4.x`에서는 사용할 수 없고, `.NET Core 2.1` 이상 또는 `.NET 5.0` 이상에서 사용 가능하다.

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



# ByteSerializer 클래스 작성
---

- 대상 `byte[]`의 특정 위치에 원하는 타입으로 데이터를 작성하는 정적 래퍼 클래스를 따로 작성한다.

- `Unmanaged Type` -> `byte[]` 직렬화를 모두 담당하도록 하여, `Send Buffer`로부터 직렬화 기능을 분리하는 역할을 한다.

- 역직렬화 기능도 작성한다.

```cs
/// <summary> value &lt;-&gt; byte[] </summary>
public static class ByteSerializer
{
    /***********************************************************************
    *                               Write to byte[]
    ***********************************************************************/
    #region .
    public static void WriteShort(byte[] array, int offset, short data)
    {
        const int Len = sizeof(short);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }
    public static void WriteUshort(byte[] array, int offset, ushort data)
    {
        const int Len = sizeof(ushort);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }
    public static void WriteInt(byte[] array, int offset, int data)
    {
        const int Len = sizeof(int);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }
    public static void WriteUint(byte[] array, int offset, uint data)
    {
        const int Len = sizeof(uint);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }
    public static void WriteFloat(byte[] array, int offset, float data)
    {
        const int Len = sizeof(float);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }
    public static void WriteLong(byte[] array, int offset, long data)
    {
        const int Len = sizeof(long);
        BitConverter.TryWriteBytes(array.AsSpan(offset, Len), data);
    }

    /// <summary> byte 배열에 스트링을 UTF8로 작성하고, 길이 리턴 </summary>
    public static int WriteUTF8String(byte[] array, int offset, string data)
    {
        int len = data.Length * 4;
        return Encoding.UTF8.GetBytes(data.AsSpan(), array.AsSpan(offset, len));
    }
    #endregion
    /***********************************************************************
    *                           Read from byte[]
    ***********************************************************************/
    #region .
    public static short ReadShort(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(short));
        return MemoryMarshal.Read<short>(span);
    }
    public static ushort ReadUshort(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(ushort));
        return MemoryMarshal.Read<ushort>(span);
    }
    public static int ReadInt(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(int));
        return MemoryMarshal.Read<int>(span);
    }
    public static uint ReadUint(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(uint));
        return MemoryMarshal.Read<uint>(span);
    }
    public static float ReadFloat(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(float));
        return MemoryMarshal.Read<float>(span);
    }
    public static float ReadLong(byte[] array, int offset)
    {
        var span = new ReadOnlySpan<byte>(array, offset, sizeof(long));
        return MemoryMarshal.Read<long>(span);
    }
    #endregion
    /***********************************************************************
    *                       Read from ArraySegment<byte>
    ***********************************************************************/
    #region .
    public static short ReadShort(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(short));
        return MemoryMarshal.Read<short>(span);
    }
    public static ushort ReadUshort(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(ushort));
        return MemoryMarshal.Read<ushort>(span);
    }
    public static int ReadInt(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(int));
        return MemoryMarshal.Read<int>(span);
    }
    public static uint ReadUint(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(uint));
        return MemoryMarshal.Read<uint>(span);
    }
    public static float ReadFloat(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(float));
        return MemoryMarshal.Read<float>(span);
    }
    public static float ReadLong(ArraySegment<byte> segment, int offset)
    {
        var span = new ReadOnlySpan<byte>(segment.Array, segment.Offset + offset, sizeof(long));
        return MemoryMarshal.Read<long>(span);
    }
    #endregion
}
```

<br>



# SendBuffer 클래스 보강
---

- 위의 API를 이용하여 `SendBuffer` 클래스에 새로운 메소드들을 작성한다.

```cs
public class SendBuffer
{
    public void Write(ushort data)
    {
        const int len = sizeof(ushort);
        CheckWriteError(len);

        ByteSerializer.WriteUshort(_buffer, _writePos, data);
        _writePos += len;
    }

    public void Write(int data)
    {
        const int len = sizeof(int);
        CheckWriteError(len);

        ByteSerializer.WriteInt(_buffer, _writePos, data);
        _writePos += len;
    }

    public void Write(float data)
    {
        const int len = sizeof(float);
        CheckWriteError(len);

        ByteSerializer.WriteFloat(_buffer, _writePos, data);
        _writePos += len;
    }
    
    public static class Factory
    {
        /// <summary> 버퍼 생성 여부, 여유 공간 검사 </summary>
        private static void CheckBuffer(int dataLength)
        {
            // 초기 접근 시 버퍼 새로 생성
            if (CurrentBuffer.Value == null)
                CurrentBuffer.Value = new SendBuffer(ChunkSize);

            // 여유 공간이 없는 경우 앞으로 당기기
            else if (CurrentBuffer.Value.CheckWritableSize(dataLength) == false)
                CurrentBuffer.Value.Refresh();
        }

        public static void Write(ushort data)
        {
            CheckBuffer(sizeof(ushort));
            CurrentBuffer.Value.Write(data);
        }

        public static void Write(int data)
        {
            CheckBuffer(sizeof(int));
            CurrentBuffer.Value.Write(data);
        }

        public static void Write(float data)
        {
            CheckBuffer(sizeof(float));
            CurrentBuffer.Value.Write(data);
        }
    }
}
```


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://genesis8.tistory.com/37>







