---
title: C# 매개변수 한정자 ref, in의 성능
author: Rito15
date: 2021-02-16 23:20:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, performance]
math: true
mermaid: true
---

# 목표
---
- 값타입을 매개변수로 전달할 때 매개변수 한정자 사용에 따른 성능 알아보기

(string은 참조타입이지만 매개변수로 전달하면 복제되므로 함께 테스트)

<br>

# 테스트 대상
---

```cs
public struct StructA
{
    public long a,b,c,d,e,f,g;

    public StructA(long value)
    {
        a = b = c = d = e = f = g = value;
    }
}

public readonly struct StructB
{
    public readonly long a,b,c,d,e,f,g;

    public StructB(long value)
    {
        a = b = c = d = e = f = g = value;
    }
}

int iValue = 123456;
float fValue = 123456.f;
double dValue = 123456.0;
string sValue = "qwertyuiopasdfghjkl";
```

<br>

# 테스트 방법
---

- struct, readonly struct, int, float, double, string 타입의 매개변수를 전달받는 메소드를 각각 매개변수 한정자 없이, in 매개변수 한정자 사용, ref 매개변수 한정자를 사용하는 형태로 만들어 반복 호출하며 시간을 측정한다.

<br>

# 테스트 결과
---

- 반복 횟수 : 2천만 번(string은 200만 번)

![image](https://user-images.githubusercontent.com/42164422/108079080-be59a380-70b1-11eb-8322-25ff5e50009d.png){:.normal}

<br>

# 결론
---

# 1. Value Type(int, float, double, ...), String

- 유의미한 차이가 없다. 원래 의도대로 사용하면 된다.

# 2. Struct Type

- 무조건 ref나 in을 붙여주는 것이 이득이다.

