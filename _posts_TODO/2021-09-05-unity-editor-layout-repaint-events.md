---
title: 유니티 IMGUI Layout, Repaint 이벤트, 그리고 예외 처리
author: Rito15
date: 2021-09-05 03:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

## **Layout과 Repaint 이벤트**

유니티 IMGUI에서 `OnGUI()` 메소드가 호출되는 이벤트 타이밍은

기본적으로 `Layout`과 `Repaint`가 있다.

`Layout`은 GUI 레이아웃 컨트롤을 생성하는 단계이고,

`Repaint`는 이를 화면에 적용하여 새로 고침하는 단계이다.

(+ 사용자 상호작용에 따라 MouseDown, KeyDown ... 등의 이벤트가 더 있다.)

`Event.current`를 통해 현재 IMGUI 환경에서의 이벤트 객체를 참조할 수 있고,

`Event.current.type`을 통해 현재 처리되는 이벤트의 종류를 알 수 있다.

<br>

## **레이아웃 엔트리와 커서**

`EditorGUILayout`, `GUILayout`을 통해 그려지는 GUI 요소를 레이아웃 요소라고 하는데,

각 레이아웃 요소들은 하나의 엔트리(리스트) 내에 저장된다.

그리고 이 레이아웃 요소를 순회할 수 있는 정수형 커서가 존재한다.

(`UnityEngine.GUILayoutGroup.entries`, `UnityEngine.GUILayoutGroup.m_Cursor`)

`Layout` 이벤트에서는 이 레이아웃 요소들을 리스트에 차례로 저장하고,

`Repaint` 이벤트에서는 커서를 이동시켜서 저장된 레이아웃 요소들을 순회하면서 화면에 그려낸다.

<br>

## **예외가 발생하는 경우**

간혹, 

```
Getting control [cursor]'s position in a group with only [entry count] controls
when doing [Repaint] Aborting
```

위와 같은 예외가 발생하는 경우가 있다.

발생 원인은 보통 두 가지 경우이다.

1. `OnGUI()` 메소드 내에서 그려야 할 레이아웃 요소의 개수가 변한 경우

2. 다른 스레드가 레이아웃 요소 개수를 간접적으로 변경시킨 경우





ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?
ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ?





다시 `Repaint` 이벤트가 발생하여 레이아웃 요소들을 그려내게 되는데,

커서 값이 엔트리의 범위를 벗어난 영역을 참조하게 되어

이런 에러 메시지를 띄우게 된다.

<br>

# 해결 방법
---



<br>

# 부록 : 커서와 엔트리 개수 확인하기
---

```cs
// OnGUI() 내에서 호출
private static void CheckCursorAndLayoutEntry(int index)
{
    Type GetTypeFromDomain(string typeName)
    {
        return AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(ass => ass.GetTypes())
                .Where(t => t.Name == typeName)
                .FirstOrDefault();
    }

    Type tLayoutCache = GetTypeFromDomain("LayoutCache");
    Type tGUILayoutGroup = GetTypeFromDomain("GUILayoutGroup");

    FieldInfo fiCurrent = typeof(GUILayoutUtility).GetField("current", BindingFlags.NonPublic | BindingFlags.Static);
    object current = fiCurrent.GetValue(null);

    FieldInfo fiTopLevel = tLayoutCache.GetField("topLevel", BindingFlags.NonPublic | BindingFlags.Instance);
    object topLevel = fiTopLevel.GetValue(current);

    FieldInfo fiM_Cursor = tGUILayoutGroup.GetField("m_Cursor", BindingFlags.NonPublic | BindingFlags.Instance);
    object m_Cursor = fiM_Cursor.GetValue(topLevel);

    FieldInfo fiEntries = tGUILayoutGroup.GetField("entries", BindingFlags.Public | BindingFlags.Instance);
    object entries = fiEntries.GetValue(topLevel);

    Type tGUILayoutEntryList = entries.GetType();
    PropertyInfo piCount = tGUILayoutEntryList.GetProperty("Count", BindingFlags.Public | BindingFlags.Instance);
    object entriesCount = piCount.GetValue(entries);

    Debug.Log($"[{index}][{Event.current.type}] m_Cursor : {m_Cursor}, entries.Count : {entriesCount}");
}
```