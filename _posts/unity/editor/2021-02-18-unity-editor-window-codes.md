---
title: 유니티 - 에디터 윈도우 관련 유용한 코드 모음
author: Rito15
date: 2021-06-14 01:50:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, editor]
math: true
mermaid: true
---


# Enum - EditorWindowType
---

```cs
[Flags]
private enum EditorWindowType
{
    Scene = 1,
    Game  = 2,
    Inspector = 4,
    Hierarchy = 8,
    Project   = 16,
    Console   = 32
}
```

<br>

# 특정 윈도우에 포커스하기
---

```cs
private static void FocusOnWindow(EditorWindowType windowType)
{
    EditorApplication.ExecuteMenuItem("Window/General/" + windowType.ToString());
}
```

<br>

# 현재 선택된 윈도우에 키 이벤트 발생시키기
---

```cs
/// <summary> 현재 선택된 윈도우에 특정 키 이벤트 발생시키기 </summary>
private static void InvokeKeyEventOnFocusedWindow(KeyCode key, EventType eventType)
{
    var keyEvent = new Event { keyCode = key, type = eventType };
    EditorWindow.focusedWindow.SendEvent(keyEvent);
}
```

<br>

# 현재 선택된 윈도우 타입 검사하기
---

```cs
// using System.Linq;

/// <summary> 현재 활성화된 윈도우 타입 검사 (OR 연산으로 다중 검사 가능) </summary>
private static bool CheckFocusedWindow(EditorWindowType type)
{
    string currentWindowTitle = EditorWindow.focusedWindow.titleContent.text;
    var enumElements = Enum.GetValues(typeof(EditorWindowType)).Cast<EditorWindowType>();

    foreach (var item in enumElements)
    {
        if((type & item) != 0 && item.ToString() == currentWindowTitle)
            return true;
    }

    return false;
}
```

<br>



