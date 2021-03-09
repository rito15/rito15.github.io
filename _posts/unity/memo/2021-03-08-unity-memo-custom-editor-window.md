---
title: 커스텀 에디터 윈도우
author: Rito15
date: 2021-03-08 00:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, editorwindow]
math: true
mermaid: true
---

# Note
---
- 에디터 윈도우를 직접 만들어 사용할 수 있다.


# Preview
---

![image](https://user-images.githubusercontent.com/42164422/110249599-384ac180-7fba-11eb-8a62-0cb72931209a.png)

<br>

# Source Code Example
---

```cs
#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;

public class ExampleWindow : EditorWindow
{
    private bool boolValue;
    private float floatValue;
    private Vector3 vector3Value;

    [MenuItem("Window/Rito/Example Window")] // 메뉴 등록
    private static void Init()
    {
        // 현재 활성화된 윈도우 가져오며, 없으면 새로 생성
        ExampleWindow window = (ExampleWindow)GetWindow(typeof(ExampleWindow));
        window.Show();

        // 윈도우 타이틀 지정
        window.titleContent.text = "W I N D O W";

        // 최소, 최대 크기 지정
        window.minSize = new Vector2(340f, 150f);
        window.maxSize = new Vector2(340f, 200f);
    }

    void OnGUI()
    {
        // 굵은 글씨 
        Color originColor = EditorStyles.boldLabel.normal.textColor;
        EditorStyles.boldLabel.normal.textColor = Color.yellow;

        // Header =====================================================================
        GUILayout.Space(10f);
        GUILayout.Label("Header Label", EditorStyles.boldLabel);

        vector3Value = EditorGUILayout.Vector3Field("Vector3", vector3Value);

        // ============================================================================
        GUILayout.Space(10f);
        GUILayout.Label("Horizontal", EditorStyles.boldLabel);

        // Horizontal =================================================================
        GUILayout.BeginVertical();

        boolValue = EditorGUILayout.Toggle("Bool", boolValue);
        floatValue = EditorGUILayout.FloatField("Float", floatValue);

        GUILayout.EndVertical();

        // Horizontal =================================================================
        GUILayout.BeginHorizontal();

        GUILayout.Label("Label Left");
        GUILayout.Label("Label Right");

        GUILayout.EndHorizontal();
        // ============================================================================

        EditorStyles.boldLabel.normal.textColor = originColor;
    }
}

#endif
```


