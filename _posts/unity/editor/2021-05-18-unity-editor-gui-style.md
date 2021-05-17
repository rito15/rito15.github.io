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

// GUIs

GUI.backgroundColor = oldBgColor;
```

<br>

# GUIStyle 객체 이용하기
---

- `GUIStyle` 객체를 만들 때 매개변수로 `GUI.skin`을 알맞게 지정해야 한다.

- `GUI.skin`은 **OnGUI** 종류의 메소드에서만 호출할 수 있으므로<br>
  가비지를 감수하고 `OnInspectorGUI()` 내에서 항상 초기화한다.

<br>

- 스트링 리터럴로 지정할 수도 있다.
 - <https://gist.github.com/MadLittleMods/ea3e7076f0f59a702ecb>

<br>

```
// OnInspectorGUI

GUIStyleState buttonStyleState = new GUIStyleState()
{
    textColor = Color.yellow,
};
GUIStyle buttonStyle = new GUIStyle(GUI.skin.button)
{
    fontStyle = FontStyle.Bold,
    normal = buttonStyleState,
};

GUILayout.Button("Button", buttonStyle /*, Layouts */)
```

<br>

# 레이아웃 스타일 지정하기
---

```
GUILayout.Button("Button", GUILayout.Width(100f), GUILayout.Height(20f));
```

<br>

# References
---
- <https://docs.unity3d.com/kr/530/ScriptReference/GUIStyle.html>