---
title: C# 타입별 GetHashCode() 성능
author: Rito15
date: 2021-09-11 00:30:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Curiosity
---

타입별로 `GetHashCode()`의 성능 비용이 얼마나 달라지는지 간단히 확인해본다.

사용자 정의 타입은 `GetHashCode()` 메소드를 임의로 오버라이드 하지 않고 확인한다.

<br>

## **사용자 정의 타입**

```cs
public struct Struct1 { }
public struct Struct2
{
    public int a, b, c, d, e, f, g;
    public long A, B, C, D, E, F, G, H;
}
public struct Struct3
{
    public int i1, i2, i3, i4, i5, i6, i7, i8;
    public long l1, l2, l3, l4, l5, l6, l7, l8;
    public double d1, d2, d3, d4, d5, d6, d7, d8;
}

public class Class1 { }
public class Class2
{
    public int a, b, c, d, e, f, g;
    public long A, B, C, D, E, F, G, H;
}
public class Class3
{
    public int i1, i2, i3, i4, i5, i6, i7, i8;
    public long l1, l2, l3, l4, l5, l6, l7, l8;
    public double d1, d2, d3, d4, d5, d6, d7, d8;
}
```

<br>

## **벤치마크 대상 타입**

- 구조체
  - 정수 : `int`(값의 크기에 따라 2가지), `long`
  - 실수 : `float`, `double`
  - 임의의 구조체 : `Struct1`, `Struct2`, `Struct3`

- 클래스
  - 문자열 : `string`(길이가 다른 문자열 2가지)
  - 임의의 클래스 : `Class1`, `Class2`, `Class3`

<br>

# Benchmark
---

![image](https://user-images.githubusercontent.com/42164422/132879130-92ff3281-6510-4216-b7e0-43acaa7dd8af.png)


## **결론**

- 정해진 크기의 객체에 대해, 저장된 값이 계산 비용에 영향을 주지는 않는다.

- 기본 타입이 아닌 구조체 타입은 기본 타입에 비해 계산 비용이 매우 크다.

- 구조체 타입은 객체의 크기에 비례하여 비용이 증가한다.

- 클래스 타입은 타입이 달라도 비용이 같거나 비슷하다.

- `string` 타입은 문자열이 길어질수록 비용이 증가한다.

