---
title: 커스텀 애트리뷰트
author: Rito15
date: 2021-02-19 03:55:00 +09:00
categories: [Memo, Csharp Memo]
tags: [csharp, custom, attribute]
math: true
mermaid: true
---

## 필요 네임스페이스

```
using System;
using System.Linq;
```

## 1. 애트리뷰트 클래스 작성

```cs
[System.AttributeUsage(System.AttributeTargets.Method)]
public class CustomAttribute : System.Attribute
{
    public string Title { get; }

    public CustomAttribute(string t) => Title = t;
}
```

## 2. 타겟 메소드에 애트리뷰트 장착

```cs
public class TargetClass
{
    [CustomAttribute("Title String")]
    public void TargetMethod()
    {

    }
}
```

## 3. 대상 클래스에서 MethodInfo[] 가져오기

```cs
var methodInfos = typeof(TargetClass)
     .GetMethods(BindingFlags.Public | BindingFlags.Instance);
```
 
## 4. 해당 애트리뷰트를 가진 MethodInfo[] 걸러내기

```cs
var targetMethods = 
    from method in methodInfos
    where method.GetCustomAttribute(typeof(CustomAttribute)) != null
    select method;
```

## 5. 걸러진 MethodInfo[]에서 해당 애트리뷰트 객체 가져오기

```cs
foreach(var method in targetMethods)
{
    var ca = method.GetCustomAttribute(typeof(CustomAttribute)) as CustomAttribute;
}
```

## 6. 가져온 객체에서 원하는 멤버 직접 참조

```cs
var whatIWanted = ca.Title;
```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/standard/attributes/writing-custom-attributes>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/programming-guide/concepts/attributes/creating-custom-attributes>