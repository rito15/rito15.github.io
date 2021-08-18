---
title: Unity - Path
author: Rito15
date: 2021-08-18 20:40:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

```cs
public static string ScriptFolderFullPath { get; private set; }      // "......\이 스크립트가 위치한 폴더 경로"
public static string ScriptFolderInProjectPath { get; private set; } // "Assets\...\이 스크립트가 위치한 폴더 경로"
public static string AssetFolderPath { get; private set; }           // "....../Assets"

private static Texture2D texture;
private static string textureFileName = "TextureName.png";

[UnityEditor.InitializeOnLoadMethod]
private static void Init()
{
    InitFolderPath();
    AssetFolderPath = Application.dataPath;


    /* 현재 스크립트가 위치한 폴더로부터 텍스쳐 로드하는 예제 */

    if (texture == null)
    {
        // "Assets\...\TextureName.png"
        string texturePath = System.IO.Path.Combine(ScriptFolderInProjectPath, textureFileName);

        // AssetDatabase.LoadAssetAtPath() : "......\프로젝트폴더\" 에서부터 경로 시작
        texture = UnityEditor.AssetDatabase.LoadAssetAtPath(texturePath, typeof(Texture2D)) as Texture2D;
    }
}

private static void InitFolderPath([System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "")
{
    ScriptFolderFullPath = System.IO.Path.GetDirectoryName(sourceFilePath);
    int rootIndex = ScriptFolderFullPath.IndexOf(@"Assets\");
    if (rootIndex > -1)
    {
        ScriptFolderInProjectPath = ScriptFolderFullPath.Substring(rootIndex, ScriptFolderFullPath.Length - rootIndex);
    }
}
```