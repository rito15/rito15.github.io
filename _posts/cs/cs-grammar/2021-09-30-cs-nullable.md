---
title: C# Nullable
author: Rito15
date: 2021-09-30 00:11:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# null 허용 값 타입
---

- `.Net Framework 2.0` 버전부터 사용할 수 있다.

- `Nullable<T>` 또는 `T?` 꼴로 사용할 수 있다.

- `null` 값의 초기화를 허용한다.

- `null`을 허용한다고 해서 참조형이 되는 것은 아니고, 값 타입은 그대로 값 타입이다.

- 힙에 할당되지 않고, 스택에 할당되는 것은 동일하다.

<br>

# Nullable 클래스
---
- 정적 클래스이다.

- 변수를 선언할 수 없다.

- `Nullable<T>`와는 엄연히 다른 타입이며, 관련 API를 제공하기 위해 존재한다.

<br>

# Nullable&lt;T&gt; 구조체
---
- `T?` 꼴로 축약될 수 있다.

- 변수를 선언할 수 있다.

<br>

# 특징
---
- `T` 타입과 `T?` 타입의 값을 연산한 결과는 `T?` 타입이다.

- `null` 값을 갖고 있다는 것은 내부적으로 `HasValue` 프로퍼티가 `false`라는 의미이다.

- `.Value`를 통해 `T?` 타입 변수로부터 `T` 타입의 값을 참조할 수 있다.<br>
  하지만 `T?` 타입 변수의 값이 `null`일 때 `.Value`를 참조하면 `InvalidOperationException`이 발생한다.

- `T?` 타입 변수에 대해 박싱, 언박싱을 할 경우 `null` 값을 갖고 있었으면 그대로 `null`로 변환된다.

<br>

# 예제
---

## **[1] 변수 선언**

```cs
Nullable<int> a = 2; // null 허용 정수 타입
int? b = null;       // 축약형
```

## **[2] 연산**

```cs
var c = (5 + a); // int와 int? 연산의 결과는 int? 타입

int d = (5 + a).Value; // 저장되는 값 : 7
int e = (5 + b).Value; // 한쪽이 null이므로 InvalidOperationException 발생

// 안전하게 int 타입 값 초기화하기
int f = (a + b) ?? default;
```

## **[3] T -&gt; T? 캐스팅**

```cs
int g = (int)a;       // 값 2 그대로 초기화
int h = (int)b;       // 원래 값이 null이므로 InvalidOperationException 발생
int i = b ?? default; // 안전한 캐스팅
```

## **[4] 박싱, 언박싱**

```cs
object oa = a;     // Boxing : T? -> object : 값 2
object ob = b;     // Boxing : T? -> object : 값 null

int? j = (int?)oa; // Unboxing : object -> T? : 값 2
int? k = (int?)ob; // Unboxing : object -> T? : 값 null

int l = (int)oa;   // Unboxing : object -> T : 값 2
int m = (int)ob;   // Unboxing : object -> T : NullReferenceException
```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.nullable-1?view=netframework-2.0>
- <https://www.csharpstudy.com/CSharp/CSharp-nullable.aspx>
- <https://stackoverflow.com/questions/7131910/c-sharp-nullable-value-type-generates-garbage>
- <https://stackoverflow.com/questions/2865604/where-in-memory-are-nullable-types-stored>