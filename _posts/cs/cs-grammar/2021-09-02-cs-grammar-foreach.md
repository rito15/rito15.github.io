---
title: C# Foreach
author: Rito15
date: 2021-09-02 16:00:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Foreach 구문
---

- 컬렉션의 요소를 간편히 순차 탐색할 수 있는 구문

```cs
int[] arr = { 0, 1, 2, 3, 4 };

foreach (int i in arr)
{
    Console.WriteLine(i);
}
```

<br>

# Foreach 구문이 실제로 생성하는 코드
---

- 위의 소스 코드는 실제로 다음과 같은 코드를 생성한다.

```cs
int[] arr = { 0, 1, 2, 3, 4 };

var enumerator = arr.GetEnumerator();

while (enumerator.MoveNext())
{
    Console.WriteLine(enumerator.Current);
}
```

<br>

# Foreach 구문을 사용하기 위한 조건
---

`GetEnumerator()`, `MoveNext()`, `Current` 이렇게 세 가지만 구현하면

`foreach` 구문을 사용하기 위한 최소 조건을 만족한다.

`GetEnumerator()`

<br>

## **간단한 범위 출력 예제**

### **[1] 자기 자신을 enumerator로 사용하는 경우**

```cs
class IntRange
{
    private int from, to;
    public int Current { get; private set; }

    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public bool MoveNext()
    {
        return Current++ < to;
    }

    public IntRange GetEnumerator()
    {
        Current = from - 1;
        return this;
    }
}
```

### **[2] 별개의 enumerator를 사용하는 경우**

```cs

```

<br>

### **[3] Test**

```cs
IntRange range = new IntRange(2, 8);

foreach (var i in range)
{
    Console.WriteLine(i); // 2 ~ 8까지 한 줄씩 출력
}
```

<br>



<br>

# References
---
- 