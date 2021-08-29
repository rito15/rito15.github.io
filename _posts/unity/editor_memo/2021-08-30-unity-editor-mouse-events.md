---
title: 유니티 에디터 - 마우스 이벤트 메모
author: Rito15
date: 2021-08-30 03:03:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

- `OnInspectorGUI()` 내에서 호출

```cs
private static bool IsLeftMouseDown => 
    Event.current.type == EventType.MouseDown && Event.current.button == 0;

private static bool IsLeftMouseDrag => 
    Event.current.type == EventType.MouseDrag && Event.current.button == 0;

private static bool IsLeftMouseUp => 
    Event.current.type == EventType.MouseUp && Event.current.button == 0;

private static bool IsRightMouseDown => 
    Event.current.type == EventType.MouseDown && Event.current.button == 1;

private static bool IsRightMouseDrag => 
    Event.current.type == EventType.MouseDrag && Event.current.button == 1;

private static bool IsRightMouseUp => 
    Event.current.type == EventType.MouseUp && Event.current.button == 1;

private static bool IsMouseExitEditor =>
    Event.current.type == EventType.MouseLeaveWindow;

private static Vector2 MousePosition => Event.current.mousePosition;
```

<br>

## 마우스 커서 변경

```cs
// rect 영역 내에서 손꾸락 모양으로 변경
EditorGUIUtility.AddCursorRect(rect, MouseCursor.Link);
```

