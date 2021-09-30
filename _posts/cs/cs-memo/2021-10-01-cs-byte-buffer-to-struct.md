---
title: C# 바이트 버퍼를 읽어서 구조체로 변환하기
author: Rito15
date: 2021-10-01 00:01:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# 소스 코드
---

## **메소드**

```cs
/// <summary> 바이트 버퍼를 읽어서 구조체로 변환하기 </summary>
public static T? ByteBufferToStruct<T>(byte[] buffer, int offset) where T : struct
{
    int size = Marshal.SizeOf(typeof(T));

    if (buffer.Length - offset < size)
        return null;

    // Unmanaged Heap에 size만큼 메모리 할당
    IntPtr ptr = Marshal.AllocHGlobal(size);

    // buffer[offset]부터 size만큼 읽어서 ptr이 가리키는 메모리에 복사
    Marshal.Copy(buffer, offset, ptr, size);

    // ptr이 가리키는 위치의 메모리를 T 타입으로 변환하여 새롭게 할당
    T obj = Marshal.PtrToStructure<T>(ptr);

    // ptr 해제
    Marshal.FreeHGlobal(ptr);

    return obj;
}
```

## **예제**

```cs
[StructLayout(LayoutKind.Explicit)]
public struct Data
{
    [FieldOffset(0)] public byte byte0;
    [FieldOffset(1)] public byte byte1;
    [FieldOffset(2)] public int int2;
}

static void Main(string[] args)
{
    byte[] buffer = new byte[1024];
    int curOffset = 0;

    buffer[4] = 3;
    buffer[5] = 2;

                    // Little Endian
    buffer[6] = 1; // 0x00000001
    buffer[7] = 1; // 0x00000100
    buffer[8] = 1; // 0x00010000
    buffer[9] = 1; // 0x01000000

    Data? val = ByteBufferToStruct<Data>(buffer, 4);

    if (val != null)
    {
        Console.WriteLine(val.Value.byte0);
        Console.WriteLine(val.Value.byte1);

        Console.WriteLine(val.Value.int2);
        Console.WriteLine(0x00000001 + 0x00000100 + 0x00010000 + 0x01000000);
        // = 16843009
    }
}
```

<br>

# 설명
---

- `byte*` 포인터를 `T*` 포인터로 변환하여 할당하는 것과 같다.
- `C#`에서는 `fixed` 구문에서도 `T*` 포인터를 만들 수는 없기 때문에, 위의 방법으로만 가능하다.

![image](https://user-images.githubusercontent.com/42164422/135417366-87344509-807c-45fe-b087-7ec9d3170cca.png)
