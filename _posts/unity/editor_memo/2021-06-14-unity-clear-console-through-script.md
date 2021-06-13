---
title: 스크립트로 콘솔 내용 지우기
author: Rito15
date: 2021-06-14 02:22:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

```cs
private static MethodInfo clearMethodInfo;
private static void ClearLog()
{
    if (clearMethodInfo == null)
    {
        var assembly = Assembly.GetAssembly(typeof(UnityEditor.Editor));
        var type = assembly.GetType("UnityEditor.LogEntries");
        clearMethodInfo = type.GetMethod("Clear");
    }
    clearMethodInfo.Invoke(new object(), null);
}
```

<br>

# Reference
---
- <https://www.codegrepper.com/code-examples/csharp/how+to+clear+console+through+script+unity>