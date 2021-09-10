---
title: C# Tuple, ValueTuple
author: Rito15
date: 2021-09-11 03:45:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Note
---

**Tuple**, **ValueTuple**은 `C# 7.0`에 처음 도입되었다.

두 개 이상의 타입을 함께 묶어 사용할 때,

클래스나 구조체를 따로 정의하지 않고 곧바로 사용할 수 있게 해준다.

<br>



# Tuple
---

클래스 튜플 타입.

클래스 타입이므로 전달할 때 복사가 발생하지 않고, 참조를 전달한다.

`Tuple<T1, T2>` 같이 명시적으로 타입명을 작성해야 한다.

<br>

```cs
Tuple<int, float> tuple = (10, 20f); // 불가능
```

아쉽게도 위와 같은 편리한 생성은 안되고,

```cs
Tuple<int, float> tuple = new Tuple<int, float>(10, 20f);
```

이렇게 명시적으로 생성자를 호출하여 생성해야 한다.

<br>

제네릭 인자는 `Tuple<T>`, `Tuple<T1, T2>`, ... , `Tuple<T1, ... , T8>`

이렇게 1개부터 8개까지 지정하여 사용할 수 있다.

내부 값들은 필드가 아니라 프로퍼티로 존재한다.

<br>



# ValueTuple
---

구조체 튜플 타입.

구조체 타입이므로 전달할 때마다 복사가 발생한다.

`ValueTuple<T1, T2>` 같이 타입명을 명시적으로 작성하지 않아도

`(T1, T2)`와 같은 문법으로 간편하게 사용할 수 있다.

<br>

이 때 적용되는 타입은 `ValueTuple` 타입 자체가 아니고

`ValueTuple<T>`, `ValueTuple<T1, T2>`과 같은 제네릭 타입이다.

`Tuple<>`처럼 제네릭 인자는 1개부터 8개까지 사용할 수 있다.

그리고 내부 값들은 필드 형태로 저장된다.

<br>

제네릭 인자가 없는 `ValueTuple` 구조체 타입은 실제 사용을 위한 타입이 아니며,

대신 `Create<T1>(T1 item1)`, `Create<T1, T2>(T1 item1, T2 item2)`와 같은 정적 메소드를 제공한다.

<br>


# 타입 추론
---

`<int, float, string>` 타입의 `ValueTuple`을 사용하려면

```cs
ValueTuple<int, float, string> tuple = (1, 0.5f, "abc");
```

혹은

```cs
(int, float, string) tuple = (1, 0.5f, "abc");
```

처럼 작성하면 된다.

하지만 타입 부분이 너무 길게 늘어진다는 단점이 있다.

<br>

```cs
var tuple = (1, 0.5f, "abc");
```

![image](https://user-images.githubusercontent.com/42164422/132912445-18b4b356-5121-45e4-972f-4a8ad606bfcc.png)

`var` 키워드는 타입을 명시적으로 작성하지 않고,

초기화되는 값의 타입에 따라 추론하여 컴파일 타임에 변수의 타입을 지정해준다.

이를 이용하면 특히 튜플 타입의 변수에 대해

일일이 필드의 타입을 명시하지 않고 편리하게 선언할 수 있다.

<br>


# 튜플을 지역변수로 분해하기
---

## **선언과 동시에 초기화하기**

```cs
(int, float, string) tuple = (1, 0.5f, "abc");
```

이런 튜플이 있을 때,


```cs
(int i, float f, string s) = tuple;
```

이렇게 각각의 지역 변수 선언과 동시에

튜플을 분해하여 값을 초기화할 수 있다.

<br>

```cs
var (i, f, s) = tuple;
```

`var`를 통한 타입 추론을 활용하여

위와 같이 선언과 동시에 초기화할 수도 있다.

<br>

## **무시 항목 사용하기**

```cs
(int i, _, string s) = tuple;
```

이렇게 무시 항목(`_`)을 사용하여, 튜플의 일부 필드를 무시하고

원하는 필드들만 지역변수로 선언과 동시에 초기화할 수 있다.

<br>

```cs
var (i, _, s) = tuple;
```

이런 방식도 가능하다.

<br>

## **유사한 문법**

튜플을 사용하지는 않지만 위와 유사한 문법이 있다.

```cs
(int i, float f) = (123, 45f);
```

```cs
var (i, f) = (123, 45f);
```

이렇게 서로 다른 타입의 지역 변수들에 대해, 

한 줄로 묶어서 선언과 동시에 초기화할 수 있다.

<br>


## **이미 선언된 변수들에 튜플 분해하여 전달하기**

```cs
// 튜플
(int, float, string) tuple = (1, 0.5f, "abc");

// 지역 변수들
int i;
float f;
string s;
```

위와 같이 튜플과 지역변수들이 선언되어 있다.

```cs
(i, f, s) = tuple;
```

튜플의 값을 이렇게 필드 순서대로 지역 변수들에 전달할 수 있으며,

```cs
(i, _, s) = tuple;
```

전달을 원치 않는 부분은 무시 항목(`_`)을 사용하여 건너뛰고,

다른 필드들만 전달할 수도 있다.

<br>

## **불가능한 문법 형태**


```cs
string s; // 미리 선언된 지역 변수

(int i, float f, s) = tuple; // 튜플의 분해와 동시에 선언 및 초기화
```

분해와 동시에 선언 및 초기화, 그리고 미리 선언된 지역 변수에 대한 초기화는

'분해의 혼합 선언 및 식'이라고 하며, 동시에 이루어질 수 없다.

<br>

```cs
tuple = (1, _, _); // 불가능
```

튜플의 필드를 동시에 초기화할 때 위와 같이 일부만 초기화하는 것은 안된다.

<br>



# 필드 이름 직접 지정하기
---

```cs
(int, float, string) tuple = (1, 0.5f, "abc");
```

위에서 작성한 변수 `tuple`에 대한 각각의 필드는

`.item1`, `.item2`, `.item3`을 통해 참조할 수 있다.

그런데 필드 이름들이 아무런 의미를 담고 있지 않는, 그저 **item**일 뿐이니

이대로 반복적으로 사용하면 가독성이 영 좋지 않을 것 같다.

따라서 이 필드들에 직접 이름을 지정해줄 수 있다.

<br>

```cs
(int index, float ratio, string name) tuple = (1, 0.5f, "abc");
```

각 필드에 순서대로 `index`, `ratio`, `name`이라는 이름을 붙여주었다.

이제 `item~` 대신, 지정된 이름을 통해 참조할 수 있다.

<br>

```cs
(int, float ratio, string) tuple = (1, 0.5f, "abc");
```

이렇게 원하는 필드에만 명시적으로 이름을 붙여줄 수 있다.

이름이 지정되지 않은 필드들은 순서대로 `item~` 이름을 갖는다.

<br>


# 튜플 타입 매개변수
---

```cs
public void Method(int id, string name)
{
    // Do Something
}
```

이 메소드는 `int`, `string` 타입 매개변수를 각각 전달 받는다.

```cs
public void Method((int id, string name) tuple)
{
    // Do Something
}
```

이 메소드는 `(int, string)` 타입의 튜플 매개변수 하나를 전달 받는다.

물론 이런 방식이 필요하다면 사용해야 하겠지만

튜플 타입의 매개변수는 가독성이 썩 좋지 않고 혼동을 유발할 수 있으므로, 

굳이 필요하지 않다면 사용하지 않는 것이 좋을 것 같다.

<br>



# 튜플을 반환하는 메소드
---

튜플의 진정한 편의성은 **메소드 반환 타입**으로서의 사용에 있다.

<br>

```cs
private float[] GetData()
{
    float[] retArr = { 1f, 2f, 3f, 4f }; // 임의의 반환 데이터

    return retArr;
}
```

위와 같이 `float[]` 타입을 리턴하는 메소드가 있다.

만약 이 배열 데이터의 유효성을 검증하고 사용하려면

```cs
float[] arr = GetData();

if (arr != null && arr.Length > 0)
{
    // Do Something
}
```

이렇게 일단 메소드를 통해 데이터를 전달 받은 다음,

데이터를 사용하는 부분에서 검증해야 한다.

<br>

그런데 튜플을 활용하면 이런 검사를 미리 완료하여 전달할 수 있다.

```cs
/// <summary> 완성된 배열 데이터, 데이터 유효성을 함께 리턴 </summary>
private (bool, float[]) GetData()
{
    float[] retArr = { 1f, 2f, 3f, 4f }; // 임의의 반환 데이터

    // 미리 유효성 검증 완료하여 반환
    return (retArr != null && retArr.Length > 0, retArr);
}
```

데이터를 받아 사용하는 부분에서는

```cs
(bool isValid, float[] arr) data = GetData();

if (data.isValid)
{
    // Do Something
}
```

이렇게 완성된 데이터들을 전달받아 곧바로 사용할 수 있다.

<br>

## **반환되는 튜플의 필드 이름 지정하기**

```cs
private (bool isValid, float[] arr) GetData()
{
    return ...;
}
```

이렇게 메소드의 반환부에 각 튜플 필드의 이름을 명시적으로 지정하고,

```cs
var data = GetData();

if (data.isValid)
{
    // Do Something
}
```

`var`로 타입 추론을 하면 그 이름 그대로 사용하도록 할 수도 있다.

<br>

## **필요하지 않은 반환 값 무시하기**

위의 경우를 예시로,

데이터의 유효성만 필요하거나 혹은 데이터 자체만 필요한 경우

```cs
(bool isValid, _) = GetData();
(_, var arrData) = GetData();
```

이런 식으로 무시 항목을 사용하여 필터링할 수 있다.

```cs
(_, _) = GetData();
_ = GetData();
```

심지어 위와 같은 방식도 가능한데,

이렇게 한다고 해서 반환 값의 메모리 할당을 방지하여 최적화를 한다거나 그렇지는 않다.

<br>



# 튜플 형변환 연산자
---

```cs
class Student
{
    public int id;
    public string name;
}
```

클래스가 있다.

이 클래스 타입의 객체가 `(int, string)` 타입의 튜플로 형변환 되도록 하려면

```cs
class Student
{
    public int id;
    public string name;

    public static implicit operator (int id, string name)(Student student)
    {
        return (student.id, student.name);
    }
}
```

이렇게 작성하면 되고,

```cs
Student student = new Student();
(int, string) tuple = student;
```

위와 같이 사용할 수 있다.

<br>


## **참고**

```cs
Student student = new Student();
(int, string) = student; // Deconstruct() 호출
```

이런 형태는 튜플 형변환이 아니라 `Deconstruct()` 메소드 호출이며,

전혀 다른 문법이다.

<br>


# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.valuetuple?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/builtin-types/value-tuples>
