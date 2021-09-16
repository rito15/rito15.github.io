---
title: 유니티 에디터 - 하이라키 윈도우 관련 코드 모음
author: Rito15
date: 2021-08-27 18:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---
```cs
// 1. 하이라키 윈도우 타입
public static Type HierarchyWindowType
{
    get
    {
        if (_hierarchyWindowType == null)
            _hierarchyWindowType = 
                typeof(EditorWindow).Assembly.GetTypes()
                .Where(t => t.Name == "SceneHierarchyWindow")
                .First();

        return _hierarchyWindowType;
    }
}
private static Type _hierarchyWindowType;


// 2. 하이라키 윈도우 객체
public static SearchableEditorWindow HierarchyWindow
{
    get
    {
        if (_hierarchyWindow == null)
            _hierarchyWindow = EditorWindow.GetWindow(HierarchyWindowType) as SearchableEditorWindow;

        return _hierarchyWindow;
    }
}
private static SearchableEditorWindow _hierarchyWindow;


// 3. 하이라키 윈도우에 포커스 되어 있는지 여부
public static bool IsFocusedOnHierarchyWindow
{
    get
    {
        var focused = EditorWindow.focusedWindow;
        if (focused == null)
            return false;

        return focused.titleContent.text == "Hierarchy";
    }
}

// 하이라키 윈도우가 2개 이상이면 첫 번째 하이라키 윈도우에만 제대로 인식되는 문제가 있음
public static bool IsFocusedOnHierarchyWindow2
    => EditorWindow.focusedWindow == HierarchyWindow;


// 4. 하이라키의 게임오브젝트가 선택된 상태에서 키 입력 이벤트 감지하기
[InitializeOnLoadMethod]
private static void StaticInitMethod()
{
    EditorApplication.hierarchyWindowItemOnGUI -= OnHierarchyWindow;
    EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyWindow;
}

private static void OnHierarchyWindow(int instanceID, Rect selectionRect)
{
    Event cur = Event.current;

    if (cur == null) return;
    if (Selection.activeGameObject == null) return;

    if (cur.type == EventType.KeyDown)
    {
        Debug.Log(cur.keyCode);
    }
}
```