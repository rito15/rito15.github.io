---
title: C#에서 union 구현하기
author: Rito15
date: 2021-07-30 18:00:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# C언어의 union
---

```c
union MyUnion
{
    int intValue;     // 4바이트
    short shortValue; // 2바이트
}
```

- 위처럼 C언어에는 서로 다른 타입의 변수가 동일 메모리를 사용하도록 하는 `union`(공용체)이 존재한다.

<br>

# C#에서의 union
---

- `C#`에는 `union` 키워드가 존재하지 않지만, 편법을 통해 `union` 기능을 구현할 수 있다.

```cs
[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Explicit)]
class UnionExample
{
    [System.Runtime.InteropServices.FieldOffset(0)]
    public int intValue;

    [System.Runtime.InteropServices.FieldOffset(0)]
    public short shortValue1;

    [System.Runtime.InteropServices.FieldOffset(2)]
    public short shortValue2;
}
```

위의 클래스에서는 `0` ~ `2`바이트 부분을 `intValue`의 4바이트 중 앞의 `2`바이트와 `shortValue1`이 공유하며

`2` ~ `4`바이트 부분을 `intValue`의 4바이트 중 뒤의 `2`바이트와 `shortValue2`가 공유하게 된다.

이렇게 원하는 변수가 특정 메모리 영역을 바이트 단위로 구분하여 사용하도록 할 수 있다.

<br>

# 참고 : 객체의 크기 참조
---

- `StructLayout` 애트리뷰트로 `LayoutKind`를 `Explicit` 또는 `Sequential`로 지정한 경우에만 `Marshal`을 이용해 크기를 참조할 수 있다.

- 필드에 스트링, 배열, 컬렉션 등의 객체가 존재하는 경우에는 불가능하다.

```cs
UnionExample a = new UnionExample();

// 객체의 크기 참조
int size = System.Runtime.InteropServices.Marshal.SizeOf(a);
```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.runtime.interopservices.layoutkind?view=net-5.0>


