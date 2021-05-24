---
title: 에디터 GUI 이벤트 모음
author: Rito15
date: 2021-05-25 02:22:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

# Mouse Over Control
---

- 특정 컨트롤에 마우스가 위치해 있는지 확인

## [1] Layout 요소가 아닌 경우

```cs
Rect rect = /* Set Rect */;

EditorGUI.LabelField(rect, "Label"); // Draw Field Control

bool mouseOver = rect.Contains(Event.current.mousePosition);
```

## [2] Layout 요소인 경우

```cs
EditorGUILayout.TextField("Text");

bool mouseOver = GUILayoutUtility.GetLastRect()
                .Contains(Event.current.mousePosition);
```

<br>

# Mouse Down, Up, Drag
---

- 컨트롤에 포커싱된 상태에서는 검사 불가

```cs
bool mouseDown = Event.current.type == EventType.MouseDown;
bool mouseUp   = Event.current.type == EventType.MouseUp;
bool mouseDrag = Event.current.type == EventType.MouseDrag;
```

<br>

# Focused On Control
---

- 특정 컨트롤에 포커싱되어 있는지 확인

```cs
GUI.SetNextControlName("Control"); // 이어지는 컨트롤에 이름 부여

// <- Draw Field (Layout 요소 상관 없음)

bool focused = (GUI.GetNameOfFocusedControl() == "Control");
```

<br>

# KeyDown, KeyUp
---

## [1] 컨트롤에 포커싱되지 않은 경우

```cs
bool keyDown = 
    Event.current.keyCode == KeyCode.A && 
    Event.current.type == EventType.KeyDown;

bool keyUp = 
    Event.current.keyCode == KeyCode.A && 
    Event.current.type == EventType.KeyUp;
```

## [2] 컨트롤에 포커싱된 상태에서 검사

```cs
bool keyDown = 
    Event.current.keyCode == KeyCode.A && 
    Event.current.type == EventType.Used;  // KeyDown 대신 Used

bool keyUp = 
    Event.current.keyCode == KeyCode.A && 
    Event.current.type == EventType.KeyUp; // KeyUp은 동일
```

<br>

# Force to Focus on Control
---

- 특정 컨트롤에 포커싱하기

```cs
GUI.SetNextControlName("TextField"); // 컨트롤에 이름 부여
EditorGUILayout.TextField("Text");

// 이름 부여된 컨트롤에 포커싱
EditorGUI.FocusTextInControl("TextField");
```

- 응용 : 현재 포커스 제거하기

```cs
// 컨트롤이 없는 부분에 마우스 클릭할 경우
// 강제로 포커스 제거
if(Event.current.type == EventType.MouseDown)
    EditorGUI.FocusTextInControl("");
```