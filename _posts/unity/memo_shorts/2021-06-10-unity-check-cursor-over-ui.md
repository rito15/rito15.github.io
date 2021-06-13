---
title: 마우스 커서가 UI 위에 있는지 검사하는 간단한 코드
author: Rito15
date: 2021-06-10 02:22:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

```cs
private static bool IsPointerOverUI()
    => UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject();
```