---
title: GUI 스타일 지정하기
author: Rito15
date: 2021-05-18 02:02:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

# 인라인 방식으로 스타일 설정하기
---

- `GUI.___` 프로퍼티 값들을 수정하고 돌려놓기

```cs
// OnInspectorGUI

var oldBgColor = GUI.backgroundColor;
GUI.backgroundColor = Color.red;

// <- Draw GUIs

GUI.backgroundColor = oldBgColor;
```

<br>

# GUIStyle 객체 이용하기
---

- GUI 컨트롤을 생성하는 메소드의 매개변수로 `GUIStyle` 객체를 넣어서 스타일을 지정할 수 있다.

- 미리 만들어진 스타일들을 그대로 사용하거나,<br>
  `GUIStyle` 생성자의 매개변수로 스타일을 집어넣어서 복제할 수 있다.

- 미리 만들어진 스타일들
  - `GUI.skin.~`
  - `EditorStyles.~`

<br>

- `GUI.skin`은 **OnGUI** 종류의 메소드에서만 호출할 수 있으므로<br>
  `OnInspectorGUI()` 내에서 초기화해야 한다.

<br>

- 스트링 리터럴로 지정할 수도 있다.
 - `EditorStyles.~`와 동일
 - <https://gist.github.com/MadLittleMods/ea3e7076f0f59a702ecb>

<br>

## 예제 1 : 버튼 스타일 지정

```cs
private GUIStyleState buttonStyleState;
private GUIStyle buttonStyle;

public override void OnInspectorGUI()
{
    if(buttonStyleState == null)
        buttonStyleState = new GUIStyleState()
        {
            textColor = Color.yellow,
        };

    if(buttonStyle == null)
        buttonStyle = new GUIStyle(GUI.skin.button)
        {
            fontStyle = FontStyle.Bold,
            normal = buttonStyleState,
        };

    GUILayout.Button("Button", buttonStyle /*, Layouts */)
}
```

<br>

## 예제 2 : 토글 버튼

```cs
private bool toggle;
private GUIStyle toggleButtonStyle;

public override void OnInspectorGUI()
{
    if(toggleButtonStyle == null)
        toggleButtonStyle = new GUIStyle(GUI.skin.button);

    toggle = GUILayout.Toggle(toggle, "Toggle Button", toggleButtonStyle);
}
```

<br>

# 레이아웃 지정하기
---

- `EditorGUILayout` 클래스로 GUI 요소를 생성할 때 매개변수로 넣어서<br>
  레이아웃을 지정할 수 있다.

- `GUILayout.~()`

```
GUILayout.Button("Button", GUILayout.Width(100f), GUILayout.Height(20f));
```

<br>

# References
---
- <https://docs.unity3d.com/kr/530/ScriptReference/GUIStyle.html>