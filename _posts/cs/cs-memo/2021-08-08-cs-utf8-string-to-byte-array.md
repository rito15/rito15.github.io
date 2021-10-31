---
title: C# - UTF8 문자열을 힙 할당 없이 byte 배열로 직렬화하기
author: Rito15
date: 2021-08-08 19:31:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, file, io]
math: true
mermaid: true
---

# 1. 힙 할당 있는 방식
---

```cs
string str = "가나다 ABC 123";

byte[] byteStr = Encoding.UTF8.GetBytes(str);
```

<br>

# 2. 힙 할당 없는 방식
---

- 요지 : 미리 생성된 `byte[]`의 특정 `offset`에 문자열을 직렬화하여 복제하기

<br>

## **버퍼를 이용한 직렬화 예시**

```cs
using System;
using System.Text;

class UTF8StringBuffer
{
    private byte[] buffer = new byte[1024 * 100];
    private int readPos = 0;
    private int writePos = 0;

    private void WriteCompleted(int pos) => writePos += pos;
    private void ReadCompleted() => readPos = writePos;

    private int WritableSize => buffer.Length - writePos;
    private int ReadableSize => writePos - readPos;

    private ReadOnlySpan<byte> ReadSpan => 
        new ReadOnlySpan<byte>(buffer, readPos, ReadableSize);

    /// <summary> 커서를 맨 앞으로 당기기 </summary>
    private void Refresh()
    {
        int readableSize = ReadableSize;

        // 1. 버퍼에 안읽은 내용이 없는 경우
        if (readableSize == 0)
        {
            readPos = writePos = 0;

            Console.WriteLine($"REFRESH - ReadPos : Zero, WritePos : Zero");
        }
        // 2. 버퍼에 안읽은 내용이 있는 경우 : 맨 앞으로 복제
        else
        {
            ReadSpan.CopyTo(new Span<byte>(buffer, 0, readableSize));
            readPos = 0;
            writePos = readableSize;

            Console.WriteLine($"REFRESH - ReadPos : {readPos}, WritePos : {writePos}");
        }
    }

    /// <summary> 버퍼에 새로운 스트링 작성하기 </summary>
    public void WriteString(string str)
    {
        // 하나의 문자는 최대 4바이트 크기를 가질 수 있으므로, 넉넉히 준비
        // Encoding.UTF8.GetByteCount()를 안하는 이유
        // - GetBytes()를 호출하는 것의 50% ~ 80% 정도의 성능을 추가적으로 소모하기 때문
        int enoughLen = str.Length * 4;
        int len;
        try
        {
            // Write 시도하고 버퍼 크기 부족으로 예외 호출되는 경우, 커서 이동 후 다시 Write
            LocalWrite();
        }
        catch (ArgumentOutOfRangeException)
        {
            Refresh();
            LocalWrite();
        }

        WriteCompleted(len);

        void LocalWrite()
        {
            len = Encoding.UTF8.GetBytes(str.AsSpan(), new Span<byte>(buffer, writePos, enoughLen));
        }
    }

    /// <summary> 버퍼의 내용을 모두 읽어오기 </summary>
    public ReadOnlySpan<byte> ReadBytes()
    {
        if (ReadableSize == 0) return null;

        ReadOnlySpan<byte> ret = ReadSpan;
        ReadCompleted();

        return ret;
    }

    /// <summary> 버퍼의 내용을 모두 읽어서 스트링으로 변환하기 </summary>
    public string ReadString()
    {
        if (ReadableSize == 0) return null;

        string ret = Encoding.UTF8.GetString(ReadSpan);
        ReadCompleted();

        return ret;
    }
}
```