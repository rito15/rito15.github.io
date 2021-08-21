---
title: (Shorts) C# Foreach가 실제로 생성하는 소스코드
author: Rito15
date: 2021-08-21 17:22:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Memo
---

## Source Code

```cs
private List<int> list = new List<int>(10);

foreach (var item in list)
{
    Console.WriteLine(item);
}
```

<br>

## Generated Code

```cs
private List<int> list = new List<int>(10);

List<int>.Enumerator enumerator = list.GetEnumerator();

while (enumerator.MoveNext())
{
    int item = enumerator.Current;
    Console.WriteLine(item);
}
```

<br>

## 정리

1. `.GetEnumerator()`를 통해, 구현된 Enumerator를 가져온다. 타입은 구현에 따라 달라진다.
2. `while(enumerator.MoveNext())`를 통해 진행 가능 여부를 가져온다.
3. `enumerator.Current` 프로퍼티를 통해 현재 값을 참조한다.



