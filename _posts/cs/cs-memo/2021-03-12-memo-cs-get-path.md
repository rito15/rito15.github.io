---
title: 스크립트(.cs), 어셈블리(.dll, .exe) 경로 참조
author: Rito15
date: 2021-03-12 18:10:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, path]
math: true
mermaid: true
---

## 스크립트 경로

```cs
public static void GetScriptPath([System.Runtime.CompilerServices.CallerFilePath] string filePath = "")
{
    // 1. Script(.cs) Path
    _ = filePath;

    // 2. Folder Path
    string folderPath = System.IO.Path.GetDirectoryName(filePath);

    // 3. Specific Root Folder Path
    string rootFolderName = @"Assets\";
    int rootIndex = folderPath.IndexOf(rootFolderName);
    if (rootIndex > -1)
    {
        string rootFolderPath = folderPath.Substring(rootIndex, folderPath.Length - rootIndex);
    }
}
```

<br>

## 어셈블리 경로

```cs
string filePath =
    System.Reflection.Assembly.GetExecutingAssembly().Location;

string folderPath = 
    System.IO.Path.GetDirectoryName(filePath);
```
