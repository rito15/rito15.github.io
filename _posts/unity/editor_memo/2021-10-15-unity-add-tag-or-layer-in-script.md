---
title: 유니티 - 에디터에서 스크립트로 태그, 레이어 추가하기
author: Rito15
date: 2021-10-15 17:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

프로젝트의 일부를 다른 프로젝트로 옮기는 경우,

특정 씬에서만 사용하는 태그 또는 레이어가 존재할 수 있다.

그런데 옮긴 프로젝트에서 해당 태그 또는 레이어가 존재하지 않으면

직접 추가해줘야 하므로 번거롭다.

따라서 아래 소스 코드를 통해 이를 자동화할 수 있다.

<br>

# Source Code
---

```cs
using UnityEngine;
using UnityEditor;

public static class EditorTagLayerHelper
{
    /// <summary> 태그 중복 확인 및 추가 </summary>
    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void AddNewTag(string tagName)
    {
#if UNITY_EDITOR
        SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
        SerializedProperty tagsProp = tagManager.FindProperty("tags");

        int tagCount = tagsProp.arraySize;

        // [1] 해당 태그가 존재하는지 확인
        bool found = false;
        for (int i = 0; i < tagCount; i++)
        {
            SerializedProperty t = tagsProp.GetArrayElementAtIndex(i);

            if (t.stringValue.Equals(tagName))
            {
                found = true;
                break;
            }
        }

        // [2] 배열 마지막에 태그 추가
        if (!found)
        {
            tagsProp.InsertArrayElementAtIndex(tagCount);
            SerializedProperty n = tagsProp.GetArrayElementAtIndex(tagCount);
            n.stringValue = tagName;
            tagManager.ApplyModifiedProperties();
        }
#endif
    }

    /// <summary> 레이어 중복 확인 및 추가 </summary>
    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void AddNewLayer(string layerName)
    {
#if UNITY_EDITOR
        SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
        SerializedProperty layersProp = tagManager.FindProperty("layers");

        int layerCount = layersProp.arraySize;
        int targetIndex = -1;

        // [1] 해당 레이어가 존재하는지 확인
        // NOTE : 0 ~ 7까지는 Buit-in Layer 공간이므로 무시
        for (int i = 8; i < layerCount; i++)
        {
            SerializedProperty t = layersProp.GetArrayElementAtIndex(i);
            string strValue = t.stringValue;

            // 빈 레이어 공간을 찾은 경우
            if (targetIndex == -1 && string.IsNullOrWhiteSpace(strValue))
            {
                targetIndex = i;
            }

            // 이미 해당 레이어 이름이 존재할 경우
            else if (strValue.Equals(layerName))
            {
                targetIndex = -1;
                break;
            }
        }

        // [2] 빈 공간에 레이어 추가
        if (targetIndex != -1)
        {
            SerializedProperty n = layersProp.GetArrayElementAtIndex(targetIndex);
            n.stringValue = layerName;
            tagManager.ApplyModifiedProperties();
        }
#endif
    }
}
```

<br>

## **예제**

- 컴파일 완료 시 태그 및 레이어 추가

```cs
#if UNITY_EDITOR
public static class ExampleClass
{
    private static bool isPlaymode = false;

    [InitializeOnEnterPlayMode]
    private static void OnEnterPlayMode()
    {
        isPlaymode = true;
    }

    [InitializeOnLoadMethod]
    private static void OnLoadMethod()
    {
        if (isPlaymode) return;

        AddNewLayer("Layer01");
        AddNewLayer("PostProcess");
    }
}
#endif
```

<br>

# References
---
- <https://answers.unity.com/questions/33597/is-it-possible-to-create-a-tag-programmatically.html>