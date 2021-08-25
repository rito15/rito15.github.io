---
title: 유니티 에디터 GUI의 특정 컨트롤 포커스 여부 확인하기
author: Rito15
date: 2021-08-26 03:45:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

```cs
// 다음에 나올 GUI 컨트롤에 이름 부여
GUI.SetNextControlName("Foooooooocus");

// GUI 그리기
EditorGUI.TextArea(rect, value, inputStyle);

// 포커스 여부 확인
if(GUI.GetNameOfFocusedControl() == "Foooooooocus")
{
    // Do Something..
}
```