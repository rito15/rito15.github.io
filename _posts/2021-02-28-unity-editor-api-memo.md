---
title: 유니티 에디터 관련 유용한 스크립트, 팁 모음
author: Rito15
date: 2021-02-28 01:50:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

<details>
<summary markdown="span"> 
다이얼로그 창 띄우기
</summary>

```cs
bool res1 = EditorUtility.DisplayDialog("Title", "Message", "OK");
bool res2 = EditorUtility.DisplayDialog("Title", "Message", "OK", "Cancel");
```

</details>

<br>

<details>
<summary markdown="span"> 
Undo 모음
</summary>

```cs
// 이름 변경, 기타 등등 수행하기 직전에 호출
// 주의 : 게임오브젝트의 변경사항은 트랜스폼이 아니라 게임오브젝트를 넣어야 함
Undo.RecordObject(target, "Action");

// 오브젝트 생성 이후에 호출
Undo.RegisterCreatedObjectUndo(target, "Create New");

// 오브젝트 파괴 및 Undo 등록
Undo.DestroyObjectImmediate(selected.gameObject);

// 부모 변경 및 Undo 등록
Undo.SetTransformParent(transform, parent, "Change Parent");
```

</details>

<br>

<details>
<summary markdown="span"> 
우클릭 MenuItem 메소드 중복 호출 방지하기
</summary>

- 게임오브젝트를 다중 선택하고 우클릭 메뉴를 통해 실행했을 때 생기는 중복 호출 버그 방지

- 다이얼로그를 띄우면 방지 안되니 주의

```cs
private static string _prevMethodCallInfo = "";

/// <summary> 같은 메소드가 이미 실행됐었는지 검사 (중복 메소드 호출 제한용) </summary>
private static bool IsDuplicatedMethodCall([System.Runtime.CompilerServices.CallerMemberName] string memberName = "")
{
    string info = memberName + DateTime.Now.ToString();

    if (_prevMethodCallInfo.Equals(info))
    {
        return true;
    }
    else
    {
        _prevMethodCallInfo = info;
        return false;
    }
}

[MenuItem("GameObject/Rito/Test", priority = -999)]
private static void TestUsage()
{
    if(IsDuplicatedMethodCall()) return;

    // ...
}
```

</details>

<br>

<details>
<summary markdown="span"> 
현재 선택된 트랜스폼들을 필터링에 따라 가져오기
</summary>

```cs
// 선택된 트랜스폼들 중에 루트들만, 프리팹 제외하고 가져오기
Selection.transforms;

/// <summary> 현재 선택된 트랜스폼들 중 계층 관계에 있는 것들은 최상위 부모만 필터링하여 가져오기 </summary>
private static Transform[] SelectedTopLevelTransforms => Selection.GetTransforms(SelectionMode.TopLevel);

/// <summary> 현재 선택된 모든 트랜스폼들을 필터링 없이 그대로 가져오기 </summary>
private static Transform[] SelectedAllTransforms
    => Selection.GetTransforms(SelectionMode.Unfiltered);
```

</details>

<br>

<details>
<summary markdown="span"> 
Enum - EditorWindowType
</summary>

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

</details>

<br>

<details>
<summary markdown="span"> 
특정 윈도우에 포커스하기
</summary>

```cs
private static void FocusOnWindow(EditorWindowType windowType)
{
    EditorApplication.ExecuteMenuItem("Window/General/" + windowType.ToString());
}
```

</details>

<br>

<details>
<summary markdown="span"> 
현재 선택된 윈도우에 특정 키 이벤트 발생시키기
</summary>

```cs
/// <summary> 현재 선택된 윈도우에 특정 키 이벤트 발생시키기 </summary>
private static void InvokeKeyEventOnFocusedWindow(KeyCode key, EventType eventType)
{
    var keyEvent = new Event { keyCode = key, type = eventType };
    EditorWindow.focusedWindow.SendEvent(keyEvent);
}
```

</details>

<br>

<details>
<summary markdown="span"> 
현재 선택된 윈도우 타입 검사하기
</summary>

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

</details>

<br>



