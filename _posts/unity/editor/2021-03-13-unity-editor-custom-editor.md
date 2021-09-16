---
title: 유니티 - Custom Editor (커스텀 에디터)
author: Rito15
date: 2021-03-13 17:40:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp, customeditor]
math: true
mermaid: true
---

# Begin
---

<details>
<summary markdown="span"> 
Custom Editor Example
</summary>

```cs
#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SomeScript))]
public class SomeScriptEditor : UnityEditor.Editor
{
    private SomeScript ss;

    private void OnEnable()
    {
        ss = target as SomeScript;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
    }
}

#endif
```

</details>

<br>

# Note
---

- UnityEngine.Editor 타입은 ScriptableObject를 상속받는다.

<br>

# Memo
---

<details>
<summary markdown="span"> 
GUI와 GUILayout
</summary>

<br>

- GUI, EditorGUI
  - Rect(x, y, w, h)를 직접 지정하여 윈도우에 그린다.
  - 수동으로 그리는 만큼, 번거롭지만 그만큼 자유도가 높다.
  - EditorGUIUtility를 이용해 현재 환경의 영역 크기 등을 가져와 사용해야 한다.
  - Rect로 그려낸 높이만큼 GUILayout의 Space를 직접 호출하여 윈도우 영역을 넓혀줘야 한다.

<br>

- GUILayout, EditorGUILayout
  - 영역을 직접 지정할 수 없고, 컨트롤마다 정해진 만큼의 영역이 자동으로 할당된다.
  - 자동으로 영역이 그려지는 만큼, 편리하지만 그만큼 자유도가 낮다.

</details>

<br>

<details>
<summary markdown="span"> 
값의 수정과 SerializedObject
</summary>

<br>

- SerializedObject를 수정하는 경우
  - `OnInspectorGUI()` 상단에서 `.Update()` 메소드를 호출하여 연결된 오브젝트의 값을 항상 받아온 상태에서 GUI 필드를 그려야 한다.
  - GUI가 변경된 경우, `OnInspectorGUI()` 하단에서 `.ApplyModifiedProperties()` 메소드를 호출하여 변경사항을 연결된 오브젝트에 적용해야 한다.
  - Undo는 자동으로 적용된다.

<br>

- SerializedObject가 아니라 대상 컴포넌트의 필드 값을 직접 수정하는 경우
  - `Undo.RecordObject(대상 컴포넌트, "")`를 호출한 뒤, 값을 수정해야 한다.

</details>

<br>

<details>
<summary markdown="span"> 
필드 값의 보존
</summary>

<br>

- 모든 필드(동적, 정적)가 값을 잃어버리는 경우
  - 플레이모드 진입 시
  - 컴파일 시

<br>

- 동적 필드만 값을 잃어버리는 경우
  - 플레이모드 종료 시

<br>

- 정적 필드의 값을 유지하고 싶은 경우
  - EditorPrefs 이용
  - 정적 생성자에서 EditorPrefs의 값을 정적 필드에 적용
  - ChangeCheck를 통해, GUI에서 값이 변경될 때마다 정적 필드의 값을 EditorPrefs에 적용

<br>

- 동적 필드의 값을 유지하고 싶은 경우
  - `Play Mode Saver`의 방식 사용
  - SerializedObject에 값을 캐싱해놨다가, 값을 잃어버리는 타이밍(예 : 정적 생성자)에 SO로부터 값을 복원

</details>

<br>

# API
---

<details>
<summary markdown="span"> 
GUI
</summary>

```cs
// 버튼 그리기
// 주의 : 레이아웃 요소가 아니므로 Space 직접 추가해야 함
GUI.Button(new Rect(0f, 0f, 100f, 20f), "Button");

```

</details>

<br>



<details>
<summary markdown="span"> 
GUILayout
</summary>

```cs
/***********************************************************
/*                          NOTE
/***********************************************************
/* 공통 2번째 파라미터 : GUIStyle
/* EditorStyles.~ 를 통해 다양한 스타일을 곧바로 지정 가능
/*
/* 공통 3번째 파라미터 : params GUILayoutOption[]
/* GUILayout.~ 를 통해 너비, 높이 지정 가능(width, height)
************************************************************/

// 기본 버튼
GUILayout.Button("Button"); // Width: 자동으로 최대치, Height : 19f
GUILayout.Button("Button", GUILayout.Width(200f)); // Width 직접 지정

// 마우스 클릭 유지하는 동안 true 값을 리턴하는 버튼
// 실제로는 누르는 순간, 떼는 순간, 누른 채로 마우스가 스치는 동안에만 true
GUILayout.RepeatButton("Repeat Button");

// 레이블
GUILayout.Label("Label");

// 단순 박스 그리기
// 너비, 높이를 따로 지정하지 않을 경우 : 텍스트에 맞춰서 자동으로 크기 설정됨
GUILayout.Box("Box", GUILayout.Width(EditorGUIUtility.currentViewWidth));

// 기본 체크박스 스타일의 토글
boolField = GUILayout.Toggle(boolField, "Bool Field");

// 버튼 스타일의 토글
boolField = GUILayout.Toggle(boolField, boolField ? "on" : "off", "button");

// 가로로 나열된 토글버튼들 표시(동시에 1개만 선택 가능)
intField = GUILayout.Toolbar(intField, new[] { "A", "B", "C" });

// EditorStyles.toolbar~ 를 통해 다양한 모습의 툴바 지정 가능
intField = GUILayout.Toolbar(intField, new[] { "A", "B", "C" }, EditorStyles.toolbarButton);

// 한 줄을 입력할 수 있는 텍스트 필드(주의사항 : stringFIeld 기본 값이 null이면 안됨)
stringField = GUILayout.TextField(stringField);
stringField = GUILayout.TextField(stringField, 10); // Max Length : 10

// 한 줄 비밀번호 필드
stringField = GUILayout.PasswordField(stringField, '*');
stringField = GUILayout.PasswordField(stringField, '*', 10); // Max Length : 10


// 가로 영역
using (new GUILayout.HorizontalScope())
{
    // ..
}
// 세로 영역
using (new GUILayout.VerticalScope())
{
    // ..
}
// 스크롤뷰 영역
using (new GUILayout.ScrollViewScope(vector2Field))
{

}
```

</details>

<br>



<details>
<summary markdown="span"> 
GUILayoutUtility
</summary>

```cs
// 가장 최근에 그린 컨트롤의 Rect 정보 얻어오기
GUILayoutUtility.GetLastRect();

```

</details>

<br>



<details>
<summary markdown="span"> 
EditorGUI
</summary>

```cs
// GUI 변화 여부 관찰
using (var check = new EditorGUI.ChangeCheckScope())
{
    // Draw Somthing..

    if (check.changed)
    { } // ..
}

// 비활성화 영역 지정
// 매개변수 true : 비활성화, false : 활성화
using (new EditorGUI.DisabledGroupScope(true))
{
    // Draw Something..
}

```

</details>

<br>



<details>
<summary markdown="span"> 
EditorGUILayout
</summary>

```cs

```

</details>

<br>



<details>
<summary markdown="span"> 
EditorGUIUtility
</summary>

```cs
// 현재 에디터 GUI의 너비값
EditorGUIUtility.currentViewWidth;
```

</details>

<br>



# Useful Source Codes
---

<details>
<summary markdown="span"> 
Color Scope
</summary>

```cs
/// <summary> 영역 내에서 컨텐츠 색상, 배경 색상을 지정한다.
/// <para/> null로 지정한 색상은 영향을 주지 않는다.
/// </summary>
public class ColorScope : GUI.Scope
{
    private readonly Color? originalContentColor;
    private readonly Color? originalBackgroundColor;

    public ColorScope(Color? contentColor, Color? backgroundColor)
    {
        if (contentColor != null)
        {
            originalContentColor = GUI.contentColor;
            GUI.contentColor = contentColor.Value;
        }
        else
            originalContentColor = null;

        if (backgroundColor != null)
        {
            originalBackgroundColor = GUI.backgroundColor;
            GUI.backgroundColor = backgroundColor.Value;
        }
        else
            originalBackgroundColor = null;
    }

    protected override void CloseScope()
    {
        if(originalContentColor != null)
            GUI.contentColor = originalContentColor.Value;

        if (originalBackgroundColor != null)
            GUI.backgroundColor = originalBackgroundColor.Value;
    }
}
```

</details>

<br>



<details>
<summary markdown="span"> 
편리하게 사용할 수 있는 Editor Pref 전용 구조체
</summary>

```cs
/***********************************************************************
*                               Editor Prefs
***********************************************************************/
#region .
private struct BoolPref
{
    private readonly bool defaultValue;
    public bool value;
    public string name; // Pref 이름

    public BoolPref(string name, bool defaultValue)
    {
        this.name = name;
        this.value = this.defaultValue = defaultValue;
    }

    public static implicit operator bool(BoolPref other) => other.value;

    public void SaveToEditorPref()
        => EditorPrefs.SetBool(name, value);

    public void LoadFromEditorPref()
        => value = EditorPrefs.GetBool(name, defaultValue);

    public void Set(bool newValue)
        => value = newValue;
}

private static BoolPref foldout = new BoolPref("Example_Foldout_", true);

// 플레이모드 진입 시, 컴파일 시 값 다시 읽어와 복원
[InitializeOnLoadMethod]
private static void LoadPrefValues()
{
    foldoutA.LoadFromEditorPref();
}

// GUI 내에서 bool 값이 변화하는 경우에 Set(value)로 값 초기화,
// ChangeCheck로 감지 후 SaveToEditorPref()로 EditorPref에 변경사항 저장

#endregion
```

</details>

<br>



<details>
<summary markdown="span"> 
수동(GUI) 요소와 자동(GUILayout) 요소 함께 다루기
</summary>

```cs
/***********************************************************************
*                               Manual Editor Control
***********************************************************************/
#region .
/// <summary> [수동] 현재 그려질 컨트롤의 Y 위치 </summary>
private float currentY = 0f; // 반드시 OnInspectorGUI() 상단에서 0으로 초기화

/// <summary> [수동, 자동(Layout)] 모두 Y 공백 삽입 </summary>
private void NextSpace(float value)
{
    GUILayout.Space(value);
    currentY += value;
}

/// <summary> [수동] Y 공백 삽입</summary>
private void NextY(float value)
{
    currentY += value;
}

// GUI 요소를 그리고 난 후의 Space는 NextSpace() 호출
// GUILayout 요소를 그리고 난 후에는 NextY() 호출

#endregion
```

</details>

<br>



<details>
<summary markdown="span"> 
열고 닫을 수 있는 적당히 무난하게 생긴 박스
</summary>

```cs
// boxY : 그려질 Y 위치
// boxH : 헤더를 제외한, 순수한 박스의 높이(펼쳐졌을 때 표시될 박스 높이)
// foldout : Foldout 상태를 나타낼 bool 필드
// 리턴값 : 현재 Foldout 여부 bool 값
/// <summary> 헤더(Foldout) + 박스 그리기 </summary>
private bool DrawFoldoutHeaderBox(float boxY, float boxH, bool foldout, string titleText,
    in Color boxColor, in Color headerColor, in Color titleColor)
{
    const float boxX = 14f;
    const float padding = 4f;
    const float headerX = boxX + padding;
    const float headerH = 18f;

    // 헤더 높이 + 패딩 * 2
    float headerAreaH = headerH + padding * 2f;
    float headerY = boxY + padding;

    float viewWidth = EditorGUIUtility.currentViewWidth;
    float headerW = viewWidth - headerX * 2f + 12f;
    float boxW = viewWidth - boxX * 2f + 12f;

    // 펼쳤을 때만 박스 보여주기
    boxH = foldout ? (boxH + headerAreaH) : (headerAreaH);

    using (new ColorScope(null, boxColor))
    {
        // Outside Box
        GUI.Box(new Rect(boxX, boxY, boxW, boxH), "");
    }

    using (new ColorScope(titleColor, headerColor))
    {
        // Header Box
        GUI.Box(new Rect(headerX, headerY, headerW, headerH), "");

        // Foldout
        foldout = EditorGUI.Foldout(new Rect(headerX + 16f, headerY, headerW, headerH),
            foldout, titleText, true, EditorStyles.boldLabel);
    }

    // 수동 컨트롤을 그려낸 만큼 공백 삽입
    NextSpace(headerH + padding);

    return foldout;
}

// 예시
public override void OnInspectorGUI()
{
    currentY = 0f;

    NextSpace(8f);
    foldOut = DrawFoldoutHeaderBox(currentY, 42f, foldOut, "Title",
        Color.black, Color.white * 4f, Color.black);

    if (foldOut)
    {
        GUILayout.Button("Button 1");
        GUILayout.Button("Button 2");
        NextY(GUILayoutUtility.GetLastRect().height * 2f); // 버튼 높이 * 2만큼 수동 Y 이동
    }

    NextSpace(8f);

    GUILayout.Button("Button");
}
```

</details>

<br>



<details>
<summary markdown="span"> 
.
</summary>

```cs

```

</details>

<br>



# References
---
- <https://m.blog.naver.com/PostList.nhn?blogId=hammerimpact&categoryNo=19>
- <https://m.blog.naver.com/hammerimpact/220775012493>