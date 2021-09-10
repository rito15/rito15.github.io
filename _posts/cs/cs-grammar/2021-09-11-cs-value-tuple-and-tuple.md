---
title: C# ValueTuple, Tuple
author: Rito15
date: 2021-09-11 00:45:00 +09:00
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

# ValueTuple
---

구조체 튜플 타입.

구조체 타입이므로 전달할 때마다 복사가 발생한다.

`ValueTuple` 이라는 타입명을 명시적으로 작성하지 않아도

`(T1, T2)`와 같은 문법으로 간편하게 사용할 수 있다.

내부 타입의 값은 필드 형태로 저장된다.



<br>

# Tuple
---

클래스 튜플 타입.

클래스 타입이므로 전달할 때 복사가 발생하지 않고, 참조를 전달한다.

`Tuple<T1, T2>` 같이 명시적으로 타입명을 작성해야 한다.

내부 타입의 값은 프로퍼티 형태로 저장된다.



<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.valuetuple?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/builtin-types/value-tuples>
