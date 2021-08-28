---
title: 유니티 에디터 - Built-in Icons
author: Rito15
date: 2021-08-29 05:02:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

- 유니티 에디터에 내장된 아이콘들이 존재한다.

- `UnityEditor.EditorGUIUtility.IconContent("이름")`을 통해 `GUIContent` 타입으로 로드할 수 있다.

- `UnityEditor.EditorGUIUtility.FindTexture("이름")`을 통해 `Texture2D` 타입으로 로드할 수 있다.

<br>



# 아이콘 목록 확인
---

- <https://github.com/halak/unity-editor-icons>

- <https://blog.csdn.net/Game_jqd/article/details/103497366>

<br>



# 사용 예시
---

## **[1] IconContent**

![2021_0829_EditorButton1](https://user-images.githubusercontent.com/42164422/131229659-6e24263e-d062-49fa-8b67-f00be6ff128b.gif)

```cs
[CustomEditor(typeof(TestTest))]
private class CE : UnityEditor.Editor
{
    private static GUIContent playIconContent;

    private void OnEnable()
    {
        if (playIconContent == null)
            playIconContent = EditorGUIUtility.IconContent("PlayButton@2x");
    }

    public override void OnInspectorGUI()
    {
        GUILayout.Button(playIconContent, GUILayout.Width(40f), GUILayout.Height(40f));
    }
}
```

<br>

## **[2] FindTexture**

![2021_0829_EditorButton2](https://user-images.githubusercontent.com/42164422/131229660-e0efef93-b53b-4c18-8953-aec29d8b8542.gif)

```cs
[CustomEditor(typeof(TestTest))]
private class CE : UnityEditor.Editor
{
    private static Texture2D playIconTex;
    private static Texture2D playOnIconTex;
    private static GUIStyle buttonStyle;

    private void OnEnable()
    {
        if (playIconTex == null)
            playIconTex = EditorGUIUtility.FindTexture("PlayButton@2x");
        if (playOnIconTex == null)
            playOnIconTex = EditorGUIUtility.FindTexture("PlayButton On@2x");
    }

    public override void OnInspectorGUI()
    {
        if (buttonStyle == null) // 스타일은 반드시 OnInspectorGUI()에서 참조
            buttonStyle = "button";

        var oldNormalTex = buttonStyle.normal.background;
        var oldActiveTex = buttonStyle.active.background;

        if(playIconTex != null)   buttonStyle.normal.background = playIconTex;
        if(playOnIconTex != null) buttonStyle.active.background = playOnIconTex;

        GUILayout.Button(" ", GUILayout.Width(40f), GUILayout.Height(40f));

        buttonStyle.normal.background = oldNormalTex;
        buttonStyle.active.background = oldActiveTex;
    }
}
```

