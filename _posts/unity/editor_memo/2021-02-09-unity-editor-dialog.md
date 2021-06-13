---
title: 유니티 에디터 다이얼로그 창 띄우기
author: Rito15
date: 2021-02-09 13:50:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, dialog, csharp]
math: true
mermaid: true
---

```cs
bool res1 = EditorUtility.DisplayDialog("Title", "Message", "OK");
bool res2 = EditorUtility.DisplayDialog("Title", "Message", "OK", "Cancel");
```