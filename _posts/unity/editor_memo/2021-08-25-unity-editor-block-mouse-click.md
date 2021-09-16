---
title: 유니티 - 에디터의 특정 영역 마우스 클릭 방지하기
author: Rito15
date: 2021-08-25 02:59:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

```cs
Rect rect = ....; // 마우스 클릭 방지할 영역

if (rect.Contains(Event.current.mousePosition))
{
    if(Event.current.type == EventType.MouseDown)
        Event.current.Use();
}

// 이후 해당 영역에서의 모든 마우스 클릭은 무시(Button, Value Fields, ...)
```

- 위의 방식을 이용해서, 컨트롤의 색상을 변경시키지 않는 `DisabledGroup`을 구현할 수 있다.

<br>

```cs
// 컨트롤을 그리기 전에 호출
/// <summary> 지정한 조건이 참인 경우에만 해당 영역 마우스 클릭 허용 </summary>
public static void EnabledRectArea(in Rect rect, in bool enabledCondition)
{
    if (!enabledCondition && rect.Contains(Event.current.mousePosition))
    {
        if (Event.current.type == EventType.MouseDown)
            Event.current.Use();
    }
}

/// <summary> 지정한 조건이 참인 경우에만 해당 영역 마우스 클릭 방지 </summary>
public static void DisabledRectArea(in Rect rect, in bool disabledCondition)
{
    if (disabledCondition && rect.Contains(Event.current.mousePosition))
    {
        if (Event.current.type == EventType.MouseDown)
            Event.current.Use();
    }
}
```