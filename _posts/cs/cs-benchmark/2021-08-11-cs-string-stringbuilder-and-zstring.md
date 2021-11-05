---
title: C# String, StringBuilder, ZString
author: Rito15
date: 2021-08-11 17:17:00 +09:00
categories: [C#, C# Benchmark]
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

<br>




## **추가 벤치마크 : `StringBuilder.AppendFormat()`**

<details>
<summary markdown="span"> 
..
</summary>

`StringBuilder` 클래스에는 `string.Format()`처럼 스트링을 포맷팅하여 추가하는 `.AppendFormat()` 메소드가 있다.

사용법은 `string.Format()`과 동일하며,

가비지도 `string.Format()`과 동일하게 생성한다.

위와 동일한 조건으로 벤치마크를 진행해보았다.


![image](https://user-images.githubusercontent.com/42164422/129475835-49dcbebe-9647-4d5d-ac12-4ed4aed44124.png)

![image](https://user-images.githubusercontent.com/42164422/129475875-6771cce8-9975-421b-9b28-cee083ae87d3.png)

벤치마크 루프 횟수를 다르게 지정하여 각각 수행했지만,

`string.Format()`과 거의 비슷한 성능이 나오는 것을 확인할 수 있었다.

<br>

너무나 동일하기에 `StringBuilder.AppendFormat()`과 `string.Format()`의 내부 구현을 확인해보니,

```cs
/* String.Format() */

// System.String
/// <summary>문자열에 있는 서식 지정 항목을 지정된 세 개체의 문자열 표현으로 바꿉니다.</summary>
[__DynamicallyInvokable]
public static string Format(string format, object arg0, object arg1, object arg2)
{
    return FormatHelper(null, format, new ParamsArray(arg0, arg1, arg2));
}

// System.String
using System.Text;

private static string FormatHelper(IFormatProvider provider, string format, ParamsArray args)
{
    if (format == null)
    {
        throw new ArgumentNullException("format");
    }
    return StringBuilderCache.GetStringAndRelease(StringBuilderCache.Acquire(format.Length + args.Length * 8).AppendFormatHelper(provider, format, args));
}

// System.Text.StringBuilder
internal StringBuilder AppendFormatHelper(IFormatProvider provider, string format, ParamsArray args)
{
    // ...
}
```

```cs
/* StringBuilder.AppendFormat() */

// System.Text.StringBuilder
/// <summary>서식 항목이 0개 이상 포함된 복합 서식 문자열을 처리하여 반환된 문자열을 이 인스턴스에 추가합니다. 각 서식 항목이 세 인수 중 하나의 문자열 표현으로 바뀝니다.</summary>
[__DynamicallyInvokable]
public StringBuilder AppendFormat(string format, object arg0, object arg1, object arg2)
{
    return AppendFormatHelper(null, format, new ParamsArray(arg0, arg1, arg2));
}

// System.Text.StringBuilder
internal StringBuilder AppendFormatHelper(IFormatProvider provider, string format, ParamsArray args)
{
    // ...
}
```

<br>

애초에 내부적으로 `StringBuilder.AppendFormatHelper()` 메소드를 동일하게 호출하고 있음을 알 수 있었다.

<br>

## **결론**
- `string.Format()`, `StringBuilder.AppendFormat()` 메소드의 내부 구현은 같다.

</details>


<br>

# Benchmark 2
---

- **ZString**에도 스트링 빌더가 존재하는데, 깜빡했다.
- 따라서 이번에는 **StringBuilder**, ZString의 **Utf16ValueStringBuilder**를 이용해 벤치마크를 수행한다.

<br>

## **[1] 벤치마크 소스코드**

<details>
<summary markdown="span">
...
</summary>

```cs
private StringBuilder sb;
private Utf16ValueStringBuilder zb;
private int intValue = 123;
private bool boolValue = true;
private float floatValue = 1234.567f;

[GlobalSetup]
public void Init()
{
    sb = new StringBuilder(500);
    zb = ZString.CreateStringBuilder();
}

[Benchmark(Baseline = true)]
public string StringBuilder_Append()
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
public string ZStringBuilder_Append()
{
    zb.Clear();
    zb.Append("IntValue : ");
    zb.Append(intValue);
    zb.Append(", BoolValue : ");
    zb.Append(boolValue);
    zb.Append(", FloatValue : ");
    zb.Append(floatValue);

    return zb.ToString();
}

[Benchmark]
public string StringBuilder_AppendFormat()
{
    sb.Clear();
    return sb.AppendFormat("IntValue : {0}, BoolValue : {1}, FloatValue : {2}",
        intValue, boolValue, floatValue).ToString();
}

[Benchmark]
public string ZStringFormat()
{
    return ZString.Format("IntValue : {0}, BoolValue : {1}, FloatValue : {2}",
        intValue, boolValue, floatValue);
}
```

</details>

<br>

## **[2] 결과**

![image](https://user-images.githubusercontent.com/42164422/140488192-d8bcbb10-b627-49d6-a8a5-dcdb36f2179f.png)

- `.Append()`는 **StringBuilder**, **Utf16ValueStringBuilder** 모두 힙 할당이 없음을 알 수 있다.

- 성능은 비슷하거나 **StringBuilder**가 조금 더 나은 편이다.

<br>



# Note
---

환경마다 `StringBuilder`의 동작이 조금 다른 듯하다.

예를 들어 다음 코드를 실행했을 때,

```cs
StringBuilder sb = new StringBuilder(1000);

for (int i = 0; i < 100; i++)
{
    sb.Append(i);
}
```

콘솔 앱에서는 위 반복문의 `StringBuilder.Append(int)`에 의한 힙 할당이 없다.

`.NET Framework 2.0, 4.0, 4.7.2`, `.NET Core 3.1` 버전에서 테스트 해보았지만 모두 동일했다.

그런데 유니티 엔진에서는 100번의 힙 할당이 발생하며 그 크기는 대략 `3.3kB` 정도다.

<br>

만약 유니티 엔진을 사용한다면 `ZString`을 꼭 사용하는 것이 좋을 것 같다.

