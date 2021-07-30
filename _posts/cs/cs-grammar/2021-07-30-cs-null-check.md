---
title: 클래스 타입 객체가 null인지 검사하는 4가지 방법
author: Rito15
date: 2021-07-30 17:30:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# 4가지 방법
---

## [1]

```cs
instance == null;
```

```
// 1-1. == 연산자를 오버로딩 하지 않은 경우
ldloc.0
ldnull
ceq

// 1-2. == 연산자를 오버로딩한 경우
ldnull
call        bool ClassName::op_Equality(class ClassName, class ClassName)
```


<br>

## [2]

```cs
instance.Equals(null);
```

```
ldnull
callvirt   instance bool [mscorlib]System.Object::Equals(object)
```


<br>

## [3]

```cs
ReferenceEquals(instance, null);
```

```
ldloc.0
ldnull
ceq
```

<br>

## [4]

```cs
// C# 7.0부터 사용 가능
instance is null;
```

```
ldloc.0
ldnull
ceq
```

<br>



# 정리
---
- 객체 참조가 `null`인지 검사하려면 **[3]**, **[4]**의 방법이 가장 간결한 어셈블리 코드를 생성하며, 정확하다.

- **[1]**는 `==` 연산자를 오버로딩했다면 해당 연산자 메소드를, 오버로딩 하지 않았다면 `ceq`를 호출하여 검사한다.

- **[2]**은 `Equals(object)` 메소드를 오버라이딩했다면 해당 메소드를, 오버라이딩 하지 않았다면 `object.Equals(object)` 메소드를 항상 호출하여 검사한다.

