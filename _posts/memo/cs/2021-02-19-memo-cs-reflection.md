---
title: 리플렉션
author: Rito15
date: 2021-02-19 03:50:00 +09:00
categories: [Memo, Csharp Memo]
tags: [csharp, reflection]
math: true
mermaid: true
---

## 필요 네임스페이스
```cs
using System;
using System.Reflection;
```

<br>
## 특정 클래스 타입 가져오기
```cs
Type targetType = Type.GetType("클래스명");
```

<br>
## 네임스페이스 내에 있는 클래스 타입 가져오기
```cs
Type targetType = Type.GetType("네임스페이스명.클래스명");
```

<br>
## 다른 어셈블리(예: DLL) 내에 있는 클래스 타입 가져오기
```cs
Type targetType = Type.GetType("네임스페이스명.클래스명, 어셈블리명);
```

<br>
## 타입으로 객체 생성하기
```cs
object instance = Activator.CreateInstance(targetType);
```

<br>
## 특정 클래스의 메소드 가져오기
```cs
MethodInfo targetMethod = targetType.GetMethod (
    "메소드명",
    new Type[] { typeof(파라미터1타입), typeof(파라미터2타입) }
);
```

<br>
## 가져온 메소드 호출하기
```cs
targetMethod.Invoke(instance, new object[]{ 파라미터1, 파라미터2 });
```

<br>
# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.assembly.gettype>
- <https://www.csharpstudy.com/Mistake/Article/11>