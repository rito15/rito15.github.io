---
title: C# String, StringBuilder, ZString
author: Rito15
date: 2021-08-11 17:17:00 +09:00
categories: [C#, C# Study]
tags: [csharp]
math: true
mermaid: true
---

# String 포맷팅의 문제점
---

```cs
$"IntValue : {123}, BoolValue : {true}";
```

또는

```cs
string.Format("IntValue {0}, BoolValue : {1}", 123, true);
```

이런 방식의 스트링 포맷팅을 쓰는 경우가 정말 많다.

<br>

정말 편리하긴 하지만,

`StringBuilder`와 비교하면 성능도 좋지 않고

심지어 가비지도 더 많이 발생시킨다.

그렇다고 `StringBuilder`를 쓰려니 가독성이 좋지 않고 불편하다는 단점이 있다.

<br>



# ZString
---

- <https://github.com/Cysharp/ZString>

<br>

```cs
ZString.Format("IntValue {0}, BoolValue : {1}", 123, true);
```

`string.Format()`과 같은 형식으로 사용할 수 있는

`ZString.Format()` 메소드를 제공한다.

그래도 여전히 `StringBuilder`보다는 느리고 가비지도 많이 생성한다.

그렇지만 `string.Format()`보다는 더 낫다.

<br>


# StringBuilder Wrapper
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public class STR
{
    private static readonly STR singleton = new STR();
    private readonly StringBuilder sb = new StringBuilder(100);

    private STR() { }

    public static STR Begin()
    {
        singleton.sb.Clear();
        return singleton;
    }

    public STR _(string value) { sb.Append(value); return this; }
    public STR _(bool value)   { sb.Append(value); return this; }
    public STR _(byte value)   { sb.Append(value); return this; }
    public STR _(short value)  { sb.Append(value); return this; }
    public STR _(ushort value) { sb.Append(value); return this; }
    public STR _(int value)    { sb.Append(value); return this; }
    public STR _(uint value)   { sb.Append(value); return this; }
    public STR _(float value)  { sb.Append(value); return this; }
    public STR _(double value) { sb.Append(value); return this; }

    public string End()
    {
        return sb.ToString();
    }
}
```

</details>

<br>

`StringBuilder`를 아주 조금이라도 편하게 사용하기 위해 시험삼아 작성해본 클래스.

매번 번거롭게 `StringBuilder` 객체를 만들어 쓰는 대신

싱글톤 객체를 만든 다음 정적 호출에 숨겨버리고,

```cs
sb.Append("Int : ")
  .Append(a)
  .Append(", Bool : ")
  .Append(b);
```

이런식으로 작성할 코드를 좀더 타이트하게 줄여서

```cs
STR.Begin()._("Int : ")._(a)._(", Bool : ")._(b).End();
```

이렇게 그나마 한 줄로 나열될 수 있게 했다는 의의가 있지만

가독성은 여전히 썩 좋지 않다.

이럴 때는 `C/C++`의 전처리 매크로를 `C#`에서도 쓰고 싶다는 생각이 강하게 든다.

<br>


# Benchmark
---

<!-- ============================= 벤치마크 소스코드 BEGIN ============================ -->

## **벤치마크 소스 코드**

<details>
<summary markdown="span"> 
...
</summary>

```cs
private StringBuilder sb = new StringBuilder(200);
private int intValue = 123;
private bool boolValue = true;
private float floatValue = 1234.567f;

[Benchmark(Baseline = true)]
public string StringFormat_1()
{
    return $"IntValue : {intValue}, BoolValue : {boolValue}, FloatValue : {floatValue}";
}

[Benchmark]
public string StringFormat_2()
{
    return string.Format("IntValue : {0}, BoolValue : {1}, FloatValue : {2}", intValue, boolValue, floatValue);
}

[Benchmark]
public string StringBuilder_()
{
    sb.Clear();
    return sb
        .Append("IntValue : ")
        .Append(intValue)
        .Append(", BoolValue : ")
        .Append(boolValue)
        .Append(", FloatValue : ")
        .Append(floatValue)
        .ToString();
}

[Benchmark]
public string ZString_()
{
    return ZString.Format("IntValue : {0}, BoolValue : {1}, FloatValue : {2}", intValue, boolValue, floatValue);
}

[Benchmark]
public string StringBuilderWrapper()
{
    return STR.Begin()
        ._("IntValue : ")._(intValue)
        ._(", BoolValue : ")._(boolValue)
        ._(", FloatValue : ")._(floatValue)
        .End();
}
```

</details>

<br>

<!-- ============================= 벤치마크 소스코드 END ============================== -->


## **결과**

![image](https://user-images.githubusercontent.com/42164422/129000693-675586b0-537d-4dd5-aad2-dd40f11795fd.png)

<br>

## **추가 : 가비지 생성량(`byte`)**

- `string.Format()` : 208
- `ZString.Format()` : 160
- `StringBuilder` : 136

<br>


## **결론**

- 성능, 가비지 면에서 언제나 `StringBuilder`가 가장 좋다.

- `ZString.Format()`이 `string.Format()`보다 더 좋다.

- 가독성을 포기하고 성능을 선택하는 경우, `StringBuilder`를 쓰면 된다.

- 반드시 스트링 포맷팅이 필요한 경우, `ZString.Format()`를 쓰면 된다.

- `string.Format()`은 안쓰면 된다.








