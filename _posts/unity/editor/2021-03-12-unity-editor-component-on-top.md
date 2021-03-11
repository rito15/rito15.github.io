---
title: 컴포넌트의 인스펙터 내 순서를 맨 위로 올리기
author: Rito15
date: 2021-03-12 04:04:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

```cs
bool flag = true;
while (flag)
{
    flag = UnityEditorInternal.ComponentUtility.MoveComponentUp(this);
    // 맨 위로 올라갔을 경우 false 리턴
}
```