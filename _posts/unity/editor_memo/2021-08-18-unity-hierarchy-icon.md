---
title: Unity - 하이라키 아이콘 적용 예제
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

        UnityEditor.EditorApplication.hierarchyWindowItemOnGUI += HierarchyIconHandler;
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

    static void HierarchyIconHandler(int instanceID, Rect selectionRect)
    {
        const float Pos = 0f;

        // 1. Icon Rect
        Rect iconRect = new Rect(selectionRect);
        iconRect.x = iconRect.width + Pos;
        iconRect.width = 16f;

        // 2. Label Rect
        Rect labelRect = new Rect(iconRect);
        labelRect.x += 20f;
        labelRect.width = 80f;

        GameObject go = UnityEditor.EditorUtility.InstanceIDToObject(instanceID) as GameObject;

        if (go != null && go.GetComponent<Test_HierarchyIcon>() != null)
        {
            GUI.DrawTexture(iconRect, iconTexture);

            Color c = GUI.color;
            GUI.color = Color.yellow;
            {
                GUI.Label(labelRect, "Nyang");
            }
            GUI.color = c;
        }
    }
#endif
}
```