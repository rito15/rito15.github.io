---
title: C# 패킷을 byte[]로 직렬화하는 다양한 방법
author: Rito15
date: 2021-08-08 02:34:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, benchmark, serialization]
math: true
mermaid: true
---

# Note
---

- 비교적 단순한 형태의 패킷들을 정의한다.

- 패킷을 다양한 방법으로 직렬화하여 `byte[]` 타입 버퍼에 순서대로 넣으며, 성능을 검사한다.

- 직렬화된 결과의 크기는 패킷 내 모든 필드의 크기의 합이어야 한다.

- 문자열 패킷은 어차피 공통적으로 인코딩을 거쳐야 하므로, 제외한다.

- `BenchmarkDotNet`을 통해 벤치마크를 진행한다.

<br>

# 패킷 정의
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public class Packet
{
    public ushort size;
    public ushort id;

    public Packet(ushort id)
    {
        this.id = id;
        this.size = sizeof(ushort) * 2;
    }
}

public class Int3Packet : Packet
{
    public int x, y, z;

    public Int3Packet(ushort id, int x, int y, int z) : base(id)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.size = sizeof(ushort) * 2 + sizeof(int) * 3;
    }
}

public class TransformPacket : Packet
{
    public float posX, posY, posZ;
    public float rotX, rotY, rotZ;
    public float scaleX, scaleY, scaleZ;

    public TransformPacket(ushort id) : base(id)
    {
        this.size = sizeof(ushort) * 2 + sizeof(float) * 9;
    }
}
```

</details>

<br>

# 필드 정의
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
const int USHORT_SIZE = sizeof(ushort);
const int INT_SIZE    = sizeof(int);
const int FLOAT_SIZE  = sizeof(float);

byte[] buffer = new byte[1024];
int offset = 100;

Packet            packet  = new Packet(1234);
Int3Packet    int3Packet  = new Int3Packet(2345, 10, 102030, 99999999);
TransformPacket trPacket  = new TransformPacket(3456)
{
    posX = 1.1f, posY = 2.2f, posZ = 3.3f,
    rotX = 123.456f, rotY = 234.567f, rotZ = 345.678f,
    scaleX = 10000f, scaleY = 20000f, scaleZ = 30000f
};
```

</details>

<br>

# 직렬화 방법들
---

<details>
<summary markdown="span"> 
...
</summary>

## **[0] BinaryFormatter.Serialize()**

<details>
<summary markdown="span"> 
.
</summary>

```cs
BinaryFormatter bf = new BinaryFormatter(); // Field

using (MemoryStream ms = new MemoryStream(1024))
{
    bf.Serialize(ms, packet);

    byte[] arr = ms.ToArray();
    Array.Copy(arr, 0, buffer, offset, arr.Length);
}
```

- 단순히 `ushort` 필드 2개만 갖고 있는 클래스를 직렬화했을 때 결과 `byte[]` 배열의 길이가 `183`이 나온다.

- 필드 외에, 클래스 관련된 수많은 정보들을 담고 있다는 뜻이므로 네트워크 통신을 위한 패킷 직렬화 방식으로는 부적절하다.

- 따라서 **테스트에 사용하지 않는다.**

</details>

<br>

## **[1] BitConverter.GetBytes()**

<details>
<summary markdown="span"> 
.
</summary>

```cs
private void Serialize_GetBytes(byte[] buffer, int offset, ushort data)
{
    byte[] result = BitConverter.GetBytes(data);
    Array.Copy(result, 0, buffer, offset, sizeof(ushort));
}
```

- 가장 단순하고도 직관적인 방법이다.
- 각각의 필드를 `byte[]`로 변환하여 순서대로 버퍼에 담는다.
- 필드마다 `byte[]`를 생성하므로, 항상 `GC`를 호출한다는 단점이 있다.

</details>

<br>

## **[2] BitConverter.TryWriteBytes()**

<details>
<summary markdown="span"> 
.
</summary>

```cs
private void Serialize_TryWriteBytes(byte[] buffer, int offset, ushort data)
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(ushort)), data);
}
```

- `.NET 5.0` 또는 `.NET Core 2.1` 이상에서 사용할 수 있다.
- 배열을 따로 생성하지 않고, 직렬화된 결과를 대상 `byte[]` 배열의 특정 위치에 바로 복사한다.

</details>

<br>

## **[3] Span, MemoryMarshal**

<details>
<summary markdown="span"> 
.
</summary>

```cs
private void Serialize_Span(byte[] buffer, int offset, ushort data)
{
    Span<byte> bSpan = MemoryMarshal.AsBytes(stackalloc ushort[1] { data });
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(ushort)));
}

// 추가 : 성능 20~30% 향상된 방식
private void Serialize_Span(byte[] buffer, int offset, ushort data)
{
    ReadOnlySpan<ushort> span = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
    ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<ushort, byte>(span);
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(ushort)));
}
```

- `.NET 5.0` 또는 `.NET Core 2.1` 이상에서 사용할 수 있다.
- 힙 할당 없이 스택 할당으로 배열을 생성하고, 목표 `byte[]` 배열의 특정 위치에 바로 복사한다.

</details>

<br>

## **[4] Unsafe 포인터 캐스팅**

<details>
<summary markdown="span"> 
.
</summary>

```cs
private void Serialize_Unsafe(byte[] buffer, int offset, ushort data)
{
    unsafe
    {
        fixed (byte* bPtr = &buffer[offset])
        {
            *(ushort*)bPtr = data;
        }
    }
}
```

- 컴파일 옵션으로 `/unsafe`를 허용해야 한다.
- 포인터를 통해 메모리에 직접 접근하여 값을 변경한다.

</details>

<br>

## **[5] Bit 연산을 통한 분리**

<details>
<summary markdown="span"> 
.
</summary>

```cs
private static readonly int[] UshortOffsetLookup = { 0, 8 };

private void Serialize_BitCalculation(byte[] buffer, int offset, ushort data)
{
    for (int i = 0; i < sizeof(ushort); i++)
    {
        buffer[offset + i] = (byte)(data >> UshortOffsetLookup[i]);
    }
}
```

- 정수 타입의 값에 대해서만 가능하다.
- 리틀 엔디안을 기준으로 작성하였다.
- 빅 엔디안 시스템의 경우, `UshortOffsetLookup` 배열의 요소를 반대로 `8, 0`으로 넣어야 한다.
- 엔디언은 `BitConverter.IsLittleEndian`으로 확인할 수 있다.

</details>

<br>

## **[6] 구조체를 union처럼 사용하기**

<details>
<summary markdown="span"> 
.
</summary>

```cs
[StructLayout(LayoutKind.Explicit)]
public struct UnionUshortByte2
{
    [FieldOffset(0)] public ushort value;

    [FieldOffset(0)] public byte byte0;
    [FieldOffset(1)] public byte byte1;

    public byte this[int index]
    {
        get
        {
            switch (index)
            {
                case 0: return byte0;
                case 1: return byte1;
                default:
                    throw new IndexOutOfRangeException();
            }
        }
    }

    public static UnionUshortByte2 New(ushort value)
    {
        return new UnionUshortByte2() { value = value };
    }
}

private void Serialize_UnionStruct(byte[] buffer, int offset, ushort data)
{
    UnionUshortByte2 bytes = UnionUshortByte2.New(data);
    for (int i = 0; i < sizeof(ushort); i++)
    {
        buffer[offset + i] = bytes[i];
    }
}
```

- 동일한 메모리 주소를 서로 다른 필드가 공유하도록 한다.
- 2바이트 크기에 `ushort` 타입으로 값을 넣은 뒤, 1바이트씩 `byte` 타입으로 값을 읽어들인다.

</details>

</details>

<br>

# 직렬화를 위한 API 작성
---

<details>
<summary markdown="span"> 
...
</summary>

- 위의 6가지 방법을 편리하게 사용할 수 있도록 메소드로 작성한다.
- `ushort`, `int`, `float` 타입에 대해 오버로딩한다.

<br>

<details>
<summary markdown="span"> 
Definitions
</summary>

```cs
private static readonly int[] UshortOffsetLookup = { 0, 8 };
private static readonly int[] IntOffsetLookup = { 0, 8, 16, 24 };

[StructLayout(LayoutKind.Explicit)]
public struct UnionUshortByte2
{
    [FieldOffset(0)] public ushort value;

    [FieldOffset(0)] public byte byte0;
    [FieldOffset(1)] public byte byte1;

    public byte this[int index]
    {
        get
        {
            switch (index)
            {
                case 0: return byte0;
                case 1: return byte1;
                default:
                    throw new IndexOutOfRangeException();
            }
        }
    }

    public static UnionUshortByte2 New(ushort value)
    {
        return new UnionUshortByte2() { value = value };
    }
}

[StructLayout(LayoutKind.Explicit)]
public struct UnionIntByte4
{
    [FieldOffset(0)] public int value;

    [FieldOffset(0)] public byte byte0;
    [FieldOffset(1)] public byte byte1;
    [FieldOffset(2)] public byte byte2;
    [FieldOffset(3)] public byte byte3;

    public byte this[int index]
    {
        get
        {
            switch (index)
            {
                case 0: return byte0;
                case 1: return byte1;
                case 2: return byte2;
                case 3: return byte3;
                default:
                    throw new IndexOutOfRangeException();
            }
        }
    }

    public static UnionIntByte4 New(int value)
    {
        return new UnionIntByte4() { value = value };
    }
}

[StructLayout(LayoutKind.Explicit)]
public struct UnionFloatByte4
{
    [FieldOffset(0)] public float floatValue;

    [FieldOffset(0)] public byte byte0;
    [FieldOffset(1)] public byte byte1;
    [FieldOffset(2)] public byte byte2;
    [FieldOffset(3)] public byte byte3;

    public byte this[int index]
    {
        get
        {
            switch (index)
            {
                case 0: return byte0;
                case 1: return byte1;
                case 2: return byte2;
                case 3: return byte3;
                default:
                    throw new IndexOutOfRangeException();
            }
        }
    }

    public static UnionFloatByte4 New(float value)
    {
        return new UnionFloatByte4() { floatValue = value };
    }
}
```

</details>

<details>
<summary markdown="span"> 
APIs
</summary>

```cs
// [1]
private void Serialize_GetBytes(byte[] buffer, int offset, ushort data)
{
    byte[] result = BitConverter.GetBytes(data);
    Array.Copy(result, 0, buffer, offset, sizeof(ushort));
}
private void Serialize_GetBytes(byte[] buffer, int offset, float data)
{
    byte[] result = BitConverter.GetBytes(data);
    Array.Copy(result, 0, buffer, offset, sizeof(float));
}
private void Serialize_GetBytes(byte[] buffer, int offset, int data)
{
    byte[] result = BitConverter.GetBytes(data);
    Array.Copy(result, 0, buffer, offset, sizeof(int));
}

// [2]
private void Serialize_TryWriteBytes(byte[] buffer, int offset, ushort data)
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(ushort)), data);
}
private void Serialize_TryWriteBytes(byte[] buffer, int offset, int data)
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(int)), data);
}
private void Serialize_TryWriteBytes(byte[] buffer, int offset, float data)
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(float)), data);
}

// [3]
private void Serialize_Span(byte[] buffer, int offset, ushort data)
{
    Span<byte> bSpan = MemoryMarshal.AsBytes(stackalloc ushort[1] { data });
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(ushort)));
}
private void Serialize_Span(byte[] buffer, int offset, int data)
{
    Span<byte> bSpan = MemoryMarshal.AsBytes(stackalloc int[1] { data });
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(int)));
}
private void Serialize_Span(byte[] buffer, int offset, float data)
{
    Span<byte> bSpan = MemoryMarshal.AsBytes(stackalloc float[1] { data });
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(float)));
}

// [4]
private void Serialize_Unsafe(byte[] buffer, int offset, ushort data)
{
    unsafe
    {
        fixed (byte* bPtr = &buffer[offset])
        {
            *(ushort*)bPtr = data;
        }
    }
}
private void Serialize_Unsafe(byte[] buffer, int offset, int data)
{
    unsafe
    {
        fixed (byte* bPtr = &buffer[offset])
        {
            *(int*)bPtr = data;
        }
    }
}
private void Serialize_Unsafe(byte[] buffer, int offset, float data)
{
    unsafe
    {
        fixed (byte* bPtr = &buffer[offset])
        {
            *(float*)bPtr = data;
        }
    }
}

// [5]
private void Serialize_BitCalculation(byte[] buffer, int offset, ushort data)
{
    for (int i = 0; i < sizeof(ushort); i++)
    {
        buffer[offset + i] = (byte)(data >> UshortOffsetLookup[i]);
    }
}
private void Serialize_BitCalculation(byte[] buffer, int offset, int data)
{
    for (int i = 0; i < sizeof(int); i++)
    {
        buffer[offset + i] = (byte)(data >> IntOffsetLookup[i]);
    }
}

// [6]
private void Serialize_UnionStruct(byte[] buffer, int offset, ushort data)
{
    UnionUshortByte2 bytes = UnionUshortByte2.New(data);
    for (int i = 0; i < sizeof(ushort); i++)
    {
        buffer[offset + i] = bytes[i];
    }
}
private void Serialize_UnionStruct(byte[] buffer, int offset, int data)
{
    UnionIntByte4 bytes = UnionIntByte4.New(data);
    for (int i = 0; i < sizeof(int); i++)
    {
        buffer[offset + i] = bytes[i];
    }
}
private void Serialize_UnionStruct(byte[] buffer, int offset, float data)
{
    UnionFloatByte4 bytes = UnionFloatByte4.New(data);
    for (int i = 0; i < sizeof(float); i++)
    {
        buffer[offset + i] = bytes[i];
    }
}
```

</details>

</details>

<br>

# 벤치마크 공통 조건
---

<details>
<summary markdown="span"> 
...
</summary>

```
BenchmarkDotNet=v0.13.0, OS=Windows 10.0.18362.720 (1903/May2019Update/19H1)
Intel Core i7-9750H CPU 2.60GHz, 1 CPU, 12 logical and 6 physical cores
.NET SDK=5.0.301
  [Host]     : .NET Core 3.1.16 (CoreCLR 4.700.21.26205, CoreFX 4.700.21.26205), X64 RyuJIT
  Job-FTADDV : .NET Core 3.1.16 (CoreCLR 4.700.21.26205, CoreFX 4.700.21.26205), X64 RyuJIT
  
Invocation Count : 50,000,000
Launch Count : 5
Warmup Count : 3
```

</details>

<br>

# 벤치마크 1
---

<details>
<summary markdown="span"> 
...
</summary>

- `ushort` 필드 2개를 직렬화한다.

<br>

## **소스 코드**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
[BenchmarkCategory("Simple Packet"), Benchmark(Baseline = true)]
public void BitConverter_GetBytes_1()
{
    Serialize_GetBytes(buffer, offset, packet.size);
    Serialize_GetBytes(buffer, offset + USHORT_SIZE, packet.id);
}

[BenchmarkCategory("Simple Packet"), Benchmark]
public void BitConverter_TryWriteBytes_1()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size);
    Serialize_TryWriteBytes(buffer, offset + USHORT_SIZE, packet.id);
}

[BenchmarkCategory("Simple Packet"), Benchmark]
public void Span_1()
{
    Serialize_Span(buffer, offset, packet.size);
    Serialize_Span(buffer, offset + USHORT_SIZE, packet.id);
}

[BenchmarkCategory("Simple Packet"), Benchmark]
public void Unsafe_1()
{
    Serialize_Unsafe(buffer, offset, packet.size);
    Serialize_Unsafe(buffer, offset + USHORT_SIZE, packet.id);
}

[BenchmarkCategory("Simple Packet"), Benchmark]
public void BitCalculation_1()
{
    Serialize_BitCalculation(buffer, offset, packet.size);
    Serialize_BitCalculation(buffer, offset + USHORT_SIZE, packet.id);
}

[BenchmarkCategory("Simple Packet"), Benchmark]
public void UnionStruct_1()
{
    Serialize_UnionStruct(buffer, offset, packet.size);
    Serialize_UnionStruct(buffer, offset + USHORT_SIZE, packet.id);
}
```

</details>

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/128601792-9a871b99-93f5-4b99-8d9f-f90cfdfb3a0e.png)

</details>

<br>

# 벤치마크 2
---

<details>
<summary markdown="span"> 
...
</summary>

- `ushort` 필드 2개와 `int` 필드 3개를 직렬화한다.

<br>

## **소스 코드**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
[BenchmarkCategory("Int3 Packet"), Benchmark(Baseline = true)]
public void BitConverter_GetBytes_2()
{
    int cur = 0;

    Serialize_GetBytes(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, int3Packet.z);
}

[BenchmarkCategory("Int3 Packet"), Benchmark]
public void BitConverter_TryWriteBytes_2()
{
    int cur = 0;

    Serialize_TryWriteBytes(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.z);
}

[BenchmarkCategory("Int3 Packet"), Benchmark]
public void Span_2()
{
    int cur = 0;

    Serialize_Span(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_Span(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_Span(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_Span(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_Span(buffer, offset + cur, int3Packet.z);
}

[BenchmarkCategory("Int3 Packet"), Benchmark]
public void Unsafe_2()
{
    int cur = 0;

    Serialize_Unsafe(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, int3Packet.z);
}

[BenchmarkCategory("Int3 Packet"), Benchmark]
public void BitCalculation_2()
{
    int cur = 0;

    Serialize_BitCalculation(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_BitCalculation(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_BitCalculation(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_BitCalculation(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_BitCalculation(buffer, offset + cur, int3Packet.z);
}

[BenchmarkCategory("Int3 Packet"), Benchmark]
public void UnionStruct_2()
{
    int cur = 0;

    Serialize_UnionStruct(buffer, offset,       int3Packet.size); cur += USHORT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, int3Packet.id);   cur += USHORT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, int3Packet.x);    cur += INT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, int3Packet.y);    cur += INT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, int3Packet.z);
}
```

</details>

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/128601790-d5ff439a-c990-41c0-ab56-b48323836ab4.png)

</details>

<br>

# 벤치마크 3
---

<details>
<summary markdown="span"> 
...
</summary>

- `ushort` 필드 2개와 `float` 필드 9개를 직렬화한다.
- bit 연산 방식은 `float`에 적용할 수 없으므로 제외한다.

<br>

## **소스 코드**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
[BenchmarkCategory("Transform Packet"), Benchmark(Baseline = true)]
public void BitConverter_GetBytes_3()
{
    int cur = 0;

    Serialize_GetBytes(buffer, offset,       trPacket.size);   cur += USHORT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.id);     cur += USHORT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.posX);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.posY);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.posZ);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.rotX);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.rotY);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.rotZ);   cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
    Serialize_GetBytes(buffer, offset + cur, trPacket.scaleZ);
}

[BenchmarkCategory("Transform Packet"), Benchmark]
public void BitConverter_TryWriteBytes_3()
{
    int cur = 0;

    Serialize_TryWriteBytes(buffer, offset,       trPacket.size);   cur += USHORT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.id);     cur += USHORT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posX);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posY);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posZ);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotX);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotY);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotZ);   cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
    Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleZ);
}

[BenchmarkCategory("Transform Packet"), Benchmark]
public void Span_3()
{
    int cur = 0;

    Serialize_Span(buffer, offset,       trPacket.size);   cur += USHORT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.id);     cur += USHORT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.posX);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.posY);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.posZ);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.rotX);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.rotY);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.rotZ);   cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
    Serialize_Span(buffer, offset + cur, trPacket.scaleZ);
}

[BenchmarkCategory("Transform Packet"), Benchmark]
public void Unsafe_3()
{
    int cur = 0;

    Serialize_Unsafe(buffer, offset,       trPacket.size);   cur += USHORT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.id);     cur += USHORT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.posX);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.posY);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.posZ);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.rotX);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.rotY);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.rotZ);   cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
    Serialize_Unsafe(buffer, offset + cur, trPacket.scaleZ);
}

// float는 Bit 연산 불가 //

[BenchmarkCategory("Transform Packet"), Benchmark]
public void UnionStruct_3()
{
    int cur = 0;

    Serialize_UnionStruct(buffer, offset,       trPacket.size);   cur += USHORT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.id);     cur += USHORT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.posX);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.posY);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.posZ);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.rotX);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.rotY);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.rotZ);   cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
    Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleZ);
}
```

</details>

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/128602631-f4e37e8d-454a-4f70-b7ca-f249976050f7.png)

</details>

<br>


# 결론
---

<details>
<summary markdown="span"> 
...
</summary>

## **성능 순서**

1. `unsafe`를 통한 메모리 직접 접근, `BitConverter.TryWriteBytes()`
  - 데이터가 적을 때는 확실히 `unsafe`가 빠르지만, 많아질수록 격차가 줄어든다.

2. `Span<T>`, 비트 연산
  - 비트 연산이 조금 더 빠르지만 큰 차이는 없다.
  - 비트 연산은 정수에만 사용 가능하다는 치명적인 단점이 있다.

3. `union` 구조체
  - `unsafe`를 사용할 수 없고, `.NET` 버전도 낮다면 고려할만하다.

4. `BitConverter.GetBytes()`
  - 압도적으로 느리다.

</details>

<br>


# 추가 벤치마크 1 : 직렬화 API에 따른 성능 차이
---

<details>
<summary markdown="span"> 
...
</summary>

## 테스트 대상

1. 인라인 방식 : `BitConverter.TryWriteBytes()` 직접 호출
2. 메소드 반복 호출 : `Serialize_TryWriteBytes()` 반복 호출
3. `params` 메소드 호출 : `params` 인자로 한 번에 전달

<br>

## 직렬화 API

```cs
// [1] 인라인 방식으로 직접 사용

// [2] 메소드 하나에 데이터 1개 직렬화
private void Serialize_TryWriteBytes(byte[] buffer, int offset, ushort data)
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(ushort)), data);
}

// [3] params를 이용해 데이터 한번에 직렬화
private void Serialize_TryWriteBytes(byte[] buffer, int offset, params ushort[] data)
{
    const int Len = sizeof(ushort);
    for (int i = 0; i < data.Length; i++)
    {
        BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + i * Len, Len), data[i]);
    }
}
```

<br>

## [1] ushort 변수 2개 직렬화

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
[Benchmark]
public void BitConverter_TryWriteBytes_A()
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, 2), packet.size);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 2, 2), packet.id);
}
[Benchmark]
public void BitConverter_TryWriteBytes_B()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size);
    Serialize_TryWriteBytes(buffer, offset + 2, packet.id);
}
[Benchmark]
public void BitConverter_TryWriteBytes_C()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size, packet.id);
}
```

</details>

![image](https://user-images.githubusercontent.com/42164422/128597526-8e0d95de-a492-4bb6-91ba-313814ba3e10.png)

<br>

## [2] ushort 변수 5개 직렬화

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public ushort ushort_1 = 1;
public ushort ushort_2 = 2;
public ushort ushort_3 = 3;

[Benchmark]
public void BitConverter_TryWriteBytes_A()
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, 2), packet.size);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 2, 2), packet.id);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 4, 2),  ushort_1);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 6, 2),  ushort_2);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 8, 2),  ushort_3);
}
[Benchmark]
public void BitConverter_TryWriteBytes_B()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size);
    Serialize_TryWriteBytes(buffer, offset + 2,  packet.id);
    Serialize_TryWriteBytes(buffer, offset + 4,  ushort_1);
    Serialize_TryWriteBytes(buffer, offset + 6,  ushort_2);
    Serialize_TryWriteBytes(buffer, offset + 8,  ushort_3);
}
[Benchmark]
public void BitConverter_TryWriteBytes_C()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size, packet.id,
        ushort_1, ushort_2, ushort_3
    );
}
```

</details>

![image](https://user-images.githubusercontent.com/42164422/128597833-cfe5497a-5286-43a9-b32b-ba6763a0fab8.png)

<br>

## [3] ushort 변수 10개 직렬화

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public ushort ushort_1 = 1;
public ushort ushort_2 = 2;
public ushort ushort_3 = 3;
public ushort ushort_4 = 4;
public ushort ushort_5 = 5;
public ushort ushort_6 = 6;
public ushort ushort_7 = 7;
public ushort ushort_8 = 8;

[Benchmark]
public void BitConverter_TryWriteBytes_A()
{
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, 2), packet.size);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 2, 2), packet.id);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 4, 2),  ushort_1);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 6, 2),  ushort_2);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 8, 2),  ushort_3);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 10, 2), ushort_4);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 12, 2), ushort_5);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 14, 2), ushort_6);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 16, 2), ushort_7);
    BitConverter.TryWriteBytes(new Span<byte>(buffer, offset + 18, 2), ushort_8);
}
[Benchmark]
public void BitConverter_TryWriteBytes_B()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size);
    Serialize_TryWriteBytes(buffer, offset + 2,  packet.id);
    Serialize_TryWriteBytes(buffer, offset + 4,  ushort_1);
    Serialize_TryWriteBytes(buffer, offset + 6,  ushort_2);
    Serialize_TryWriteBytes(buffer, offset + 8,  ushort_3);
    Serialize_TryWriteBytes(buffer, offset + 10, ushort_4);
    Serialize_TryWriteBytes(buffer, offset + 12, ushort_5);
    Serialize_TryWriteBytes(buffer, offset + 14, ushort_6);
    Serialize_TryWriteBytes(buffer, offset + 16, ushort_7);
    Serialize_TryWriteBytes(buffer, offset + 18, ushort_8);
}
[Benchmark]
public void BitConverter_TryWriteBytes_C()
{
    Serialize_TryWriteBytes(buffer, offset, packet.size, packet.id,
        ushort_1, ushort_2, ushort_3, ushort_4,
        ushort_5, ushort_6, ushort_7, ushort_8
    );
}
```

</details>

![image](https://user-images.githubusercontent.com/42164422/128598226-b7b0dc98-f440-4204-b65f-df25a6e188be.png)

<br>

## **결론**

1. 인라인 방식과 인자 1개를 넣는 메소드의 성능은 유의미한 차이가 없다.
2. 변수의 개수가 많을수록 `params`를 이용하는 메소드가 더 유리하지만, 역시 큰 차이는 없다.

</details>

<br>


# 추가 벤치마크 2 : Span 방식 개선
---

<details>
<summary markdown="span"> 
...
</summary>

## **소스 코드**

```cs
// 공통 필드
public byte[] buffer = new byte[1024];
public int offset = 123;
public float data = 123.456f;

// 기존
public void Span1()
{
    Span<byte> bSpan = MemoryMarshal.AsBytes(stackalloc float[1] { data });
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(float)));
}

// 개선
public void Span2()
{
    ReadOnlySpan<float> fSpan = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
    ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<float, byte>(fSpan);
    bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(float)));
}
```

<br>

## **결과**

### **[1]**

```
Launch Count: 10
Warmup Count: 3
InvocationCount: 5,000,000
```

![image](https://user-images.githubusercontent.com/42164422/128606991-74aad060-89d4-4103-8e67-2e5a489a52fc.png)

<br>

### **[2]**

```
Launch Count: 10
Warmup Count: 3
InvocationCount: 50,000,000
```

![image](https://user-images.githubusercontent.com/42164422/128607126-33746971-6058-4b9d-9637-241e4925d367.png)

<br>

### **[3]**

```
Launch Count: 20
Warmup Count: 10
InvocationCount: 50,000,000
```

![image](https://user-images.githubusercontent.com/42164422/128607403-fce07fee-db76-4f30-8092-a5edd0baf564.png)

<br>

## **결론**

- 개선된 방식의 성능이 `20%` ~ `30%` 가량 더 좋다.

<br>

## **개선된 방식으로 직렬화 벤치마크 전체 다시 진행**

```
Launch Count: 5
Warmup Count: 3
InvocationCount: 50,000,000
```

![image](https://user-images.githubusercontent.com/42164422/128609134-24bd5fef-8635-4047-a9cf-c8a0e3bcd18d.png)

- 이전 방식에 비해 딱 `30%`정도 성능이 향상된 것을 확인할 수 있다.

</details>


<br>

# 전체 소스코드
---

<details>
<summary markdown="span"> 
SerializationBenchmarks.cs
</summary>

```cs
using System;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Configs;
using System.Runtime.InteropServices;

[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]
[SimpleJob(launchCount: 5, warmupCount: 3, invocationCount: 50_000_000)]
//[CategoriesColumn]
public class SerializationBenchmarks
{
    /***********************************************************************
    *                               Packet Definitions
    ***********************************************************************/
    #region .
    public class Packet
    {
        public ushort size;
        public ushort id;

        public Packet(ushort id)
        {
            this.id = id;
            this.size = sizeof(ushort) * 2;
        }
    }

    public class Int3Packet : Packet
    {
        public int x, y, z;

        public Int3Packet(ushort id, int x, int y, int z) : base(id)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.size = sizeof(ushort) * 2 + sizeof(int) * 3;
        }
    }

    public class TransformPacket : Packet
    {
        public float posX, posY, posZ;
        public float rotX, rotY, rotZ;
        public float scaleX, scaleY, scaleZ;

        public TransformPacket(ushort id) : base(id)
        {
            this.size = sizeof(ushort) * 2 + sizeof(float) * 9;
        }
    }

    #endregion
    /***********************************************************************
    *                               Fields, Setups
    ***********************************************************************/
    #region .

    public byte[] buffer;
    public int offset;

    public Packet packet;
    public Int3Packet int3Packet;
    public TransformPacket trPacket;

    [GlobalSetup]
    public void Setup()
    {
        buffer = new byte[1024];
        offset = 100;

        packet = new Packet(1234);
        int3Packet = new Int3Packet(2345, 10, 102030, 99999999);
        trPacket = new TransformPacket(3456)
        {
            posX = 1.1f,
            posY = 2.2f,
            posZ = 3.3f,
            rotX = 123.456f,
            rotY = 234.567f,
            rotZ = 345.678f,
            scaleX = 10000f,
            scaleY = 20000f,
            scaleZ = 30000f
        };
    }

    [IterationSetup]
    public void IterationSetup()
    {
        buffer = new byte[1024];
    }

    public void PrintBuffer(int len)
    {
        Console.WriteLine("\n============ Buffer ===============");
        for (int i = 0; i < len; i++)
        {
            Console.WriteLine($"[{offset + i,2}] {buffer[offset + i]}");
        }
    }

    #endregion
    /***********************************************************************
    *                               Lookups
    ***********************************************************************/
    #region .

    const int USHORT_SIZE = sizeof(ushort);
    const int INT_SIZE = sizeof(int);
    const int FLOAT_SIZE = sizeof(float);

    private static readonly int[] UshortOffsetLookup = { 0, 8 };
    private static readonly int[] IntOffsetLookup = { 0, 8, 16, 24 };

    [StructLayout(LayoutKind.Explicit)]
    public struct UnionUshortByte2
    {
        [FieldOffset(0)] public ushort value;

        [FieldOffset(0)] public byte byte0;
        [FieldOffset(1)] public byte byte1;

        public byte this[int index]
        {
            get
            {
                switch (index)
                {
                    case 0: return byte0;
                    case 1: return byte1;
                    default:
                        throw new IndexOutOfRangeException();
                }
            }
        }

        public static UnionUshortByte2 New(ushort value)
        {
            return new UnionUshortByte2() { value = value };
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct UnionIntByte4
    {
        [FieldOffset(0)] public int value;

        [FieldOffset(0)] public byte byte0;
        [FieldOffset(1)] public byte byte1;
        [FieldOffset(2)] public byte byte2;
        [FieldOffset(3)] public byte byte3;

        public byte this[int index]
        {
            get
            {
                switch (index)
                {
                    case 0: return byte0;
                    case 1: return byte1;
                    case 2: return byte2;
                    case 3: return byte3;
                    default:
                        throw new IndexOutOfRangeException();
                }
            }
        }

        public static UnionIntByte4 New(int value)
        {
            return new UnionIntByte4() { value = value };
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct UnionFloatByte4
    {
        [FieldOffset(0)] public float floatValue;

        [FieldOffset(0)] public byte byte0;
        [FieldOffset(1)] public byte byte1;
        [FieldOffset(2)] public byte byte2;
        [FieldOffset(3)] public byte byte3;

        public byte this[int index]
        {
            get
            {
                switch (index)
                {
                    case 0: return byte0;
                    case 1: return byte1;
                    case 2: return byte2;
                    case 3: return byte3;
                    default:
                        throw new IndexOutOfRangeException();
                }
            }
        }

        public static UnionFloatByte4 New(float value)
        {
            return new UnionFloatByte4() { floatValue = value };
        }
    }

    #endregion
    /***********************************************************************
    *                               Tool Methods
    ***********************************************************************/
    #region .
    private void Serialize_GetBytes(byte[] buffer, int offset, ushort data)
    {
        byte[] result = BitConverter.GetBytes(data);
        Array.Copy(result, 0, buffer, offset, sizeof(ushort));
    }
    private void Serialize_GetBytes(byte[] buffer, int offset, float data)
    {
        byte[] result = BitConverter.GetBytes(data);
        Array.Copy(result, 0, buffer, offset, sizeof(float));
    }
    private void Serialize_GetBytes(byte[] buffer, int offset, int data)
    {
        byte[] result = BitConverter.GetBytes(data);
        Array.Copy(result, 0, buffer, offset, sizeof(int));
    }

    private void Serialize_TryWriteBytes(byte[] buffer, int offset, ushort data)
    {
        BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(ushort)), data);
    }
    private void Serialize_TryWriteBytes(byte[] buffer, int offset, int data)
    {
        BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(int)), data);
    }
    private void Serialize_TryWriteBytes(byte[] buffer, int offset, float data)
    {
        BitConverter.TryWriteBytes(new Span<byte>(buffer, offset, sizeof(float)), data);
    }

    private void Serialize_Span(byte[] buffer, int offset, ushort data)
    {
        ReadOnlySpan<ushort> span = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
        ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<ushort, byte>(span);
        bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(ushort)));
    }
    private void Serialize_Span(byte[] buffer, int offset, int data)
    {
        ReadOnlySpan<int> span = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
        ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<int, byte>(span);
        bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(int)));
    }
    private void Serialize_Span(byte[] buffer, int offset, float data)
    {
        ReadOnlySpan<float> span = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
        ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<float, byte>(span);
        bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(float)));
    }

    private void Serialize_Unsafe(byte[] buffer, int offset, ushort data)
    {
        unsafe
        {
            fixed (byte* bPtr = &buffer[offset])
            {
                *(ushort*)bPtr = data;
            }
        }
    }
    private void Serialize_Unsafe(byte[] buffer, int offset, int data)
    {
        unsafe
        {
            fixed (byte* bPtr = &buffer[offset])
            {
                *(int*)bPtr = data;
            }
        }
    }
    private void Serialize_Unsafe(byte[] buffer, int offset, float data)
    {
        unsafe
        {
            fixed (byte* bPtr = &buffer[offset])
            {
                *(float*)bPtr = data;
            }
        }
    }

    private void Serialize_BitCalculation(byte[] buffer, int offset, ushort data)
    {
        for (int i = 0; i < sizeof(ushort); i++)
        {
            buffer[offset + i] = (byte)(data >> UshortOffsetLookup[i]);
        }
    }
    private void Serialize_BitCalculation(byte[] buffer, int offset, int data)
    {
        for (int i = 0; i < sizeof(int); i++)
        {
            buffer[offset + i] = (byte)(data >> IntOffsetLookup[i]);
        }
    }

    private void Serialize_UnionStruct(byte[] buffer, int offset, ushort data)
    {
        UnionUshortByte2 bytes = UnionUshortByte2.New(data);
        for (int i = 0; i < sizeof(ushort); i++)
        {
            buffer[offset + i] = bytes[i];
        }
    }
    private void Serialize_UnionStruct(byte[] buffer, int offset, int data)
    {
        UnionIntByte4 bytes = UnionIntByte4.New(data);
        for (int i = 0; i < sizeof(int); i++)
        {
            buffer[offset + i] = bytes[i];
        }
    }
    private void Serialize_UnionStruct(byte[] buffer, int offset, float data)
    {
        UnionFloatByte4 bytes = UnionFloatByte4.New(data);
        for (int i = 0; i < sizeof(float); i++)
        {
            buffer[offset + i] = bytes[i];
        }
    }

    #endregion
    /***********************************************************************
    *                               BenchMark1 - Simple Packet
    ***********************************************************************/
    #region .

    [BenchmarkCategory("Simple Packet"), Benchmark(Baseline = true)]
    public void BitConverter_GetBytes_1()
    {
        Serialize_GetBytes(buffer, offset, packet.size);
        Serialize_GetBytes(buffer, offset + USHORT_SIZE, packet.id);
    }

    [BenchmarkCategory("Simple Packet"), Benchmark]
    public void BitConverter_TryWriteBytes_1()
    {
        Serialize_TryWriteBytes(buffer, offset, packet.size);
        Serialize_TryWriteBytes(buffer, offset + USHORT_SIZE, packet.id);
    }

    [BenchmarkCategory("Simple Packet"), Benchmark]
    public void Span_1()
    {
        Serialize_Span(buffer, offset, packet.size);
        Serialize_Span(buffer, offset + USHORT_SIZE, packet.id);
    }

    [BenchmarkCategory("Simple Packet"), Benchmark]
    public void Unsafe_1()
    {
        Serialize_Unsafe(buffer, offset, packet.size);
        Serialize_Unsafe(buffer, offset + USHORT_SIZE, packet.id);
    }

    [BenchmarkCategory("Simple Packet"), Benchmark]
    public void BitCalculation_1()
    {
        Serialize_BitCalculation(buffer, offset, packet.size);
        Serialize_BitCalculation(buffer, offset + USHORT_SIZE, packet.id);
    }

    [BenchmarkCategory("Simple Packet"), Benchmark]
    public void UnionStruct_1()
    {
        Serialize_UnionStruct(buffer, offset, packet.size);
        Serialize_UnionStruct(buffer, offset + USHORT_SIZE, packet.id);
    }

    #endregion
    /***********************************************************************
    *                               BenchMark2 - Int3 Packet
    ***********************************************************************/
    #region .

    [BenchmarkCategory("Int3 Packet"), Benchmark(Baseline = true)]
    public void BitConverter_GetBytes_2()
    {
        int cur = 0;

        Serialize_GetBytes(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, int3Packet.z);
    }

    [BenchmarkCategory("Int3 Packet"), Benchmark]
    public void BitConverter_TryWriteBytes_2()
    {
        int cur = 0;

        Serialize_TryWriteBytes(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, int3Packet.z);
    }

    [BenchmarkCategory("Int3 Packet"), Benchmark]
    public void Span_2()
    {
        int cur = 0;

        Serialize_Span(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_Span(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_Span(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_Span(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_Span(buffer, offset + cur, int3Packet.z);
    }

    [BenchmarkCategory("Int3 Packet"), Benchmark]
    public void Unsafe_2()
    {
        int cur = 0;

        Serialize_Unsafe(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, int3Packet.z);
    }

    [BenchmarkCategory("Int3 Packet"), Benchmark]
    public void BitCalculation_2()
    {
        int cur = 0;

        Serialize_BitCalculation(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_BitCalculation(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_BitCalculation(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_BitCalculation(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_BitCalculation(buffer, offset + cur, int3Packet.z);
    }

    [BenchmarkCategory("Int3 Packet"), Benchmark]
    public void UnionStruct_2()
    {
        int cur = 0;

        Serialize_UnionStruct(buffer, offset, int3Packet.size); cur += USHORT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, int3Packet.id); cur += USHORT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, int3Packet.x); cur += INT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, int3Packet.y); cur += INT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, int3Packet.z);
    }

    #endregion
    /***********************************************************************
    *                               BenchMark3 - Transform Packet
    ***********************************************************************/
    #region .

    [BenchmarkCategory("Transform Packet"), Benchmark(Baseline = true)]
    public void BitConverter_GetBytes_3()
    {
        int cur = 0;

        Serialize_GetBytes(buffer, offset, trPacket.size); cur += USHORT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.id); cur += USHORT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.posX); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.posY); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.posZ); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.rotX); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.rotY); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.rotZ); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
        Serialize_GetBytes(buffer, offset + cur, trPacket.scaleZ);
    }

    [BenchmarkCategory("Transform Packet"), Benchmark]
    public void BitConverter_TryWriteBytes_3()
    {
        int cur = 0;

        Serialize_TryWriteBytes(buffer, offset, trPacket.size); cur += USHORT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.id); cur += USHORT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posX); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posY); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.posZ); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotX); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotY); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.rotZ); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
        Serialize_TryWriteBytes(buffer, offset + cur, trPacket.scaleZ);
    }

    [BenchmarkCategory("Transform Packet"), Benchmark]
    public void Span_3()
    {
        int cur = 0;

        Serialize_Span(buffer, offset, trPacket.size); cur += USHORT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.id); cur += USHORT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.posX); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.posY); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.posZ); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.rotX); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.rotY); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.rotZ); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
        Serialize_Span(buffer, offset + cur, trPacket.scaleZ);
    }

    [BenchmarkCategory("Transform Packet"), Benchmark]
    public void Unsafe_3()
    {
        int cur = 0;

        Serialize_Unsafe(buffer, offset, trPacket.size); cur += USHORT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.id); cur += USHORT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.posX); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.posY); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.posZ); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.rotX); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.rotY); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.rotZ); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
        Serialize_Unsafe(buffer, offset + cur, trPacket.scaleZ);
    }

    // float는 Bit 연산 불가 //

    [BenchmarkCategory("Transform Packet"), Benchmark]
    public void UnionStruct_3()
    {
        int cur = 0;

        Serialize_UnionStruct(buffer, offset, trPacket.size); cur += USHORT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.id); cur += USHORT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.posX); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.posY); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.posZ); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.rotX); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.rotY); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.rotZ); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleX); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleY); cur += FLOAT_SIZE;
        Serialize_UnionStruct(buffer, offset + cur, trPacket.scaleZ);
    }

    #endregion
}
```

</details>


<details>
<summary markdown="span"> 
MainClass.cs
</summary>

```cs
using System;
using BenchmarkDotNet.Running;

class MainClass
{
    static void Main(string[] args)
    {
        BenchmarkRunner.Run<SerializationBenchmarks>();
    }
}
```

</details>




