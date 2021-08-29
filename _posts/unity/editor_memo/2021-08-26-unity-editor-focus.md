---
title: 유니티 에디터 GUI - 포커스 확인, 처리
author: Rito15
date: 2021-08-26 03:45:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# 1. 컨트롤 포커스 여부 확인
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

<br>

# 2. 특정 컨트롤에 포커스
---

```cs
// 다음에 나올 GUI 컨트롤에 이름 부여
GUI.SetNextControlName("Foooooooocus");

// GUI 그리기
EditorGUI.TextArea(rect, value, inputStyle);

// 이름 부여된 컨트롤에 포커싱
EditorGUI.FocusTextInControl("Foooooooocus);
```

<br>

# 3. 포커스 제거
---

```cs
// 컨트롤이 없는 부분에 마우스 클릭할 경우
// 강제로 포커스 제거
if(Event.current.type == EventType.MouseDown)
    EditorGUI.FocusTextInControl("");
```

