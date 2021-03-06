---
title: Reflection(리플렉션)
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
Type targetType = Type.GetType("네임스페이스명.클래스명, 어셈블리명");

// 어셈블리명 예시
string shortName = "UnityEngine";
string fullName  = "UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";
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
## 특정 네임스페이스의 모든 클래스 타입 가져오기(모든 어셈블리 확인)
```cs
string assName = "UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";
string nsName = "UnityEngine";

var classTypes =
    AppDomain.CurrentDomain.GetAssemblies()    // 모든 어셈블리 대상
        .Where(ass => ass.FullName == assName) // 특정 어셈블리(exe, dll)로 필터링
        .SelectMany(ass => ass.GetTypes())
        .Where(t => t.IsClass && t.Namespace == nsName); // 특정 네임스페이스로 필터링
```

<br>
## 현재 어셈블리의 모든 클래스 타입 가져오기
```cs
var classTypes = 
    Assembly.GetExecutingAssembly().GetTypes()
        .Where(t => t.IsClass /*&& t.Namespace == nsName*/);
```

<br>
# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.assembly.gettype>
- <https://www.csharpstudy.com/Mistake/Article/11>