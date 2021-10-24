---
title: 유니티 - 하이라키 아이콘 적용 예제
author: Rito15
date: 2021-08-18 21:20:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

- NOTE : 아이콘 뿐만 아니라 가능한 GUI를 모두 그릴 수 있다.

![image](https://user-images.githubusercontent.com/42164422/129899146-49fe71d1-82df-4f4a-8393-01a3effac442.png)

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
[DisallowMultipleComponent]
public class Test_HierarchyIcon : MonoBehaviour
{
#if UNITY_EDITOR
    public static string CurrentFolderPath { get; private set; } // "Assets\......\이 스크립트가 있는 폴더 경로"

    private static Texture2D iconTexture;
    private static string iconTextureFileName = "Icon.png";

    [UnityEditor.InitializeOnLoadMethod]
    private static void ApplyHierarchyIcon()
    {
        InitFolderPath();

        if (iconTexture == null)
        {
            // "Assets\...\Icon.png"
            string texturePath = System.IO.Path.Combine(CurrentFolderPath, iconTextureFileName);
            iconTexture = UnityEditor.AssetDatabase.LoadAssetAtPath(texturePath, typeof(Texture2D)) as Texture2D;
        }

        UnityEditor.EditorApplication.hierarchyWindowItemOnGUI += DrawHierarchyIcon;
    }

    private static void InitFolderPath([System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "")
    {
        CurrentFolderPath = System.IO.Path.GetDirectoryName(sourceFilePath);
        int rootIndex = CurrentFolderPath.IndexOf(@"Assets\");
        if (rootIndex > -1)
        {
            CurrentFolderPath = CurrentFolderPath.Substring(rootIndex, CurrentFolderPath.Length - rootIndex);
        }
    }

    // 구버전에서는 GUI.color를 통한 색상 지정이 안되므로, 범용성을 위해 style을 사용한다.
    private static GUIStyle labelStyle;
    static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
    {
        const float Pos = 0f;

        // 1. Icon Rect
        Rect iconRect = new Rect(selectionRect);
        iconRect.x = iconRect.width + Pos;
        iconRect.width = 16f;

        // 2. Label Rect
        Rect labelRect = new Rect(iconRect);
        labelRect.x += 20f; 
        labelRect.width = 60f;

        if (labelStyle == null)
        {
            labelStyle = new GUIStyle(UnityEditor.EditorStyles.label);
            labelStyle.normal.textColor = Color.yellow;
        }

        GameObject go = UnityEditor.EditorUtility.InstanceIDToObject(instanceID) as GameObject;

        if (go != null && go.activeSelf && go.GetComponent<Test_HierarchyIcon>() != null)
        {
            GUI.DrawTexture(iconRect, iconTexture);
            GUI.Label(labelRect, "Nyang", labelStyle);
        }
    }
#endif
}
```

</details>

<br>

# 좌측 끝에 아이콘 하나 띄우기
---

![image](https://user-images.githubusercontent.com/42164422/130314363-bfcc95fc-46ed-4ba0-b3f5-535cc1ff841b.png)

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
using UnityEngine;

[DisallowMultipleComponent]
public class Test_HierarchyLeftIcon : MonoBehaviour
{
#if UNITY_EDITOR
    public static string CurrentFolderPath { get; private set; } // "Assets\......\이 스크립트가 있는 폴더 경로"

    private static Texture2D iconTexture;
    private static readonly string iconTextureFileName = "Icon.png";

    [UnityEditor.InitializeOnLoadMethod]
    private static void ApplyHierarchyIcon()
    {
        InitFolderPath();

        if (iconTexture == null)
        {
            string texturePath = System.IO.Path.Combine(CurrentFolderPath, iconTextureFileName);
            iconTexture = UnityEditor.AssetDatabase.LoadAssetAtPath(texturePath, typeof(Texture2D)) as Texture2D;
        }

        if (iconTexture != null)
        {
            UnityEditor.EditorApplication.hierarchyWindowItemOnGUI += DrawHierarchyIcon;
        }
    }

    private static void InitFolderPath([System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "")
    {
        CurrentFolderPath = System.IO.Path.GetDirectoryName(sourceFilePath);
        int rootIndex = CurrentFolderPath.IndexOf(@"Assets\");
        if (rootIndex > -1)
        {
            CurrentFolderPath = CurrentFolderPath.Substring(rootIndex, CurrentFolderPath.Length - rootIndex);
        }
    }

    static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
    {
        const float Pos =
#if UNITY_2019_3_OR_NEWER      
            32f;
#else
            0f
#endif

        Rect iconRect = new Rect(selectionRect);
        iconRect.x = Pos;
        iconRect.width = 16f;

        GameObject go = UnityEditor.EditorUtility.InstanceIDToObject(instanceID) as GameObject;

        if (go != null && go.GetComponent<Test_HierarchyLeftIcon>() != null)
        {
            GUI.DrawTexture(iconRect, iconTexture);
        }
    }
#endif
}
```

</details>

<br>

# 타입별로 Built-in 아이콘 그려주기
---

![image](https://user-images.githubusercontent.com/42164422/138607984-26d138e8-55a3-4a30-8c7e-c3528dbae65c.png)

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public static class EditorHierarchyIconHelper
{
    [UnityEditor.InitializeOnLoadMethod]
    private static void ApplyHierarchyIcon()
    {
        if (iconData == null || iconData.Length == 0)
            InitIconData();

        UnityEditor.EditorApplication.hierarchyWindowItemOnGUI += DrawHierarchyIcon;
    }

    private static (Type type, Texture icon, Color color)[] iconData;

    private static void InitIconData()
    {
        Texture boxCollider    = EditorGUIUtility.IconContent("d_BoxCollider Icon").image;
        Texture sphereCollider = EditorGUIUtility.IconContent("d_SphereCollider Icon").image;

        iconData = new (Type, Texture, Color)[]
        {
            (typeof(DustManager), EditorGUIUtility.FindTexture("GameManager Icon"), Color.magenta),
            (typeof(Cone),   EditorGUIUtility.FindTexture("d_Favorite On Icon"), Color.yellow),
            (typeof(Camera), EditorGUIUtility.FindTexture("Camera Gizmo"),       Color.cyan),
            (typeof(DustBoxCollider),    boxCollider,    Color.white),
            (typeof(DustSphereCollider), sphereCollider, Color.white),
        };
    }

    private static void DrawHierarchyIcon(int instanceID, Rect selectionRect)
    {
        Rect iconRect  = new Rect(selectionRect);
        iconRect.x     = 32f; // 하이라키 좌측 끝
        iconRect.width = 16f;

        GameObject go = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
        if (go == null)
            return;

        Color c = GUI.color;

        for (int i = 0; i < iconData.Length; i++)
        {
            ref var current = ref iconData[i];
            if (current.icon != null && go.GetComponent(current.type) != null)
            {
                GUI.color = go.activeInHierarchy ? current.color : Color.white * 0.5f;
                GUI.DrawTexture(iconRect, current.icon);
                break;
            }
        }

        GUI.color = c;
    }
}

#endif
```

</details>


<br>

# 참고 : Built-in 아이콘 목록
---
- <https://rito15.github.io/posts/unity-editor-built-in-icons/>
- <https://github.com/halak/unity-editor-icons>