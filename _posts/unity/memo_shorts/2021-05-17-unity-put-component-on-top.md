---
title: 유니티 - 컴포넌트를 인스펙터 최상단에 올리기
author: Rito15
date: 2021-05-17 21:12:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Memo
---

```cs
/// <summary> 컴포넌트를 최상단에 올리기 </summary>
[System.Diagnostics.Conditional("UNITY_EDITOR")]
private static void PutComponentOnTop(Component component)
{
    for (int i = 0; i < 100 && UnityEditorInternal.ComponentUtility.MoveComponentUp(component); i++);
}
```