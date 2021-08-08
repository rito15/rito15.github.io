---
title: C# 간단한 힙 메모리 디버거 (콘솔)
author: Rito15
date: 2021-08-08 12:12:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, file, io]
math: true
mermaid: true
---

# 기능
---

- 원하는 지점의 힙 메모리 크기 기록
- 기록된 두 지점의 힙 메모리 크기 차이 출력

<br>

# 주의사항
---

- `Print()` 이후에는 `Record()`하지 않아야 한다.
  > Future Works : Print() 내에서 스트링을 스택에 할당하여 해결

<br>

# 사용 예시
---

```cs
HeapDebugger.Record(0);

int[] array = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

HeapDebugger.Record(1);

new string("ABCDE");

HeapDebugger.Record(2);

HeapDebugger.PrintDiff(0, 1); // 128
HeapDebugger.PrintDiff(1, 2); // 32
HeapDebugger.PrintDiff(0, 2); // 160
```

<br>

# 소스코드
---

```cs
using System;

public static class HeapDebugger
{
    const int RECORDS_LENGTH = 1024;
    private static readonly long[] records = new long[RECORDS_LENGTH];
    private static bool recordAfterPrint = false;

    public static void Record(int index)
    {
        if (recordAfterPrint)
        {
            throw new InvalidOperationException("Print 이후의 Record는 정확하지 않습니다.");
        }

        try
        {
            records[index] = GC.GetTotalAllocatedBytes(true);
        }
        catch (IndexOutOfRangeException)
        {
            Console.WriteLine($"HeapDebugger.Record() : 0 ~ {RECORDS_LENGTH - 1} 인덱스에만 기록할 수 있습니다. (입력값 : {index})");
        }
    }

    public static long GetDiff(int from, int to)
    {
        try
        {
            if (records[from] == 0)
                throw new ArgumentException($"[{from}] 인덱스에는 기록하지 않았습니다.");
        }
        catch (IndexOutOfRangeException)
        {
            Console.WriteLine($"HeapDebugger.GetDiff(from) : 0 ~ {RECORDS_LENGTH - 1} 인덱스에만 기록할 수 있습니다. (입력값 : {from})");
        }
        try
        {
            if (records[to] == 0)
                throw new ArgumentException($"[{to}] 인덱스에는 기록하지 않았습니다.");
        }
        catch (IndexOutOfRangeException)
        {
            Console.WriteLine($"HeapDebugger.GetDiff(to) : 0 ~ {RECORDS_LENGTH - 1} 인덱스에만 기록할 수 있습니다. (입력값 : {to})");
        }
            
        return records[to] - records[from];
    }

    public static void PrintDiff(int from, int to, string msg = null)
    {
        recordAfterPrint = true;

        long diff = GetDiff(from, to);

        string message = msg == null ?
            $"Heap Memory Difference[Index : {from} -> {to}] : {diff}" :
            $"{msg} : {diff}";
        Console.WriteLine(message);
    }
}
```