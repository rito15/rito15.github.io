---
title: 유니티 에디터 - 미리 정의된 GUIStyle 목록
author: Rito15
date: 2021-08-27 21:59:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# 목록
---

```cs
"box"
"button"
"toggle"
"label"
"window"
"textfield"
"textarea"
"horizontalslider"
"horizontalsliderthumb"
"verticalslider"
"verticalsliderthumb"
"horizontalscrollbar"
"horizontalscrollbarthumb"
"horizontalscrollbarleftbutton"
"horizontalscrollbarrightbutton"
"verticalscrollbar"
"verticalscrollbarthumb"
"verticalscrollbarupbutton"
"verticalscrollbardownbutton"
"scrollview"
```

- NOTE : `EditorStyles.~`를 통해서도 참조할 수 있다.

<br>

# 참조 방법
---

- NOTE : 반드시 `OnGUI()`, `OnInspectorGUI()` 등의 메소드 내에서 사용해야 한다.

<br>

## [1] 해당 스타일 객체 직접 참조

```cs
/* Custom Editor - OnInspectorGUI() */

// 버튼에 대한 스타일 객체를 참조한다.
GUIStyle buttonStyle = "button";

// 모든 버튼의 텍스트 색상이 노란색으로 변경된다.
buttonStyle.normal.textColor = Color.yellow;

if (GUILayout.Button("BUTTON"))
{
    // ..
}
```

<br>

## [2] 스타일 복사본 생성 및 적용

```cs
/* Custom Editor - OnInspectorGUI() */

// 버튼 스타일의 객체를 복제한다.
GUIStyle buttonStyle = new GUIStyle("button");

// 해당 복사본 스타일의 텍스트 색상을 설정한다.
buttonStyle.normal.textColor = Color.yellow;

// 복사본 스타일을 버튼에 적용한다.
if (GUILayout.Button("BUTTON", buttonStyle))
{
    // ..
}
```

