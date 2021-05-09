---
title: 델리게이트가 특정 메소드를 갖고 있는지 확인하기
author: Rito15
date: 2021-03-12 21:52:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, delegate]
math: true
mermaid: true
---

```cs
//using System;
//using System.Linq;

/// <summary> 델리게이트가 메소드를 갖고 있는지 검사 </summary>
private static bool CheckDelegateHasMethod<DType>(DType @delegate, DType method) where DType : Delegate
{
    return @delegate?.GetInvocationList()
            .Where(d => d.Method == method.Method)
            .Count() > 0;
}

private Action<int> del;
private void MethodA(int i) { }
private void Example()
{
    _ = CheckDelegateHasMethod(del, MethodA); // false

    del += MethodA;

    _ = CheckDelegateHasMethod(del, MethodA); // true
}
```