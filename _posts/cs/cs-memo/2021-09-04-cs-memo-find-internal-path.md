---
title: C# 하위 폴더, 파일들의 절대 경로 찾기
author: Rito15
date: 2021-09-04 19:45:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Summary
---
- 재귀를 이용하여 특정 폴더 하위 경로에 있는 파일, 폴더 전체 경로 찾기

<br>

# Source Code
---

## **Usage**

```cs
string folder = FindFolderAbsPath(@"c:\MyFolder", "FolderName");
string file = FindFileAbsPath(@"c:\MyFolder", "FileName.txt");
```

<br>

## **Code**

```cs
/// <summary> 특정 폴더의 모든 하위 경로에서 이름이 일치하는 폴더의 절대 경로 찾기 </summary>
private string FindFolderAbsPath(string rootFolderPath, string folderName)
{
    DirectoryInfo rootDirectory = Directory.CreateDirectory(rootFolderPath);
    string found = null;

    Local_FindDirectoryAbsPath(rootDirectory);
    return found;

    // 내부 재귀 메소드
    void Local_FindDirectoryAbsPath(DirectoryInfo currentDirectory)
    {
        if (found != null) return;

        // 일치하는 폴더명 찾은 경우
        if (currentDirectory.Name == folderName)
        {
            found = currentDirectory.FullName;
            return;
        }

        // 하위 폴더들 재귀 탐색
        DirectoryInfo[] subFolders = currentDirectory.GetDirectories();
        foreach (var folder in subFolders)
        {
            Local_FindDirectoryAbsPath(folder);
        }
    }
}
```

```cs
/// <summary> 특정 폴더의 모든 하위 경로에서 이름이 일치하는 파일의 절대 경로 찾기 </summary>
private string FindFileAbsPath(string rootFolderPath, string fileName)
{
    DirectoryInfo rootDirectory = Directory.CreateDirectory(rootFolderPath);
    string found = null;

    Local_FindDirectoryAbsPath(rootDirectory);
    return found;

    // 내부 재귀 메소드
    void Local_FindDirectoryAbsPath(DirectoryInfo currentDirectory)
    {
        if (found != null) return;

        // 현재 디렉토리 내부 파일들 탐색
        FileInfo[] files = currentDirectory.GetFiles();
        foreach (var file in files)
        {
            if (file.Name == fileName)
            {
                found = file.FullName;
                return;
            }
        }

        // 하위 폴더들 재귀 탐색
        DirectoryInfo[] subFolders = currentDirectory.GetDirectories();
        foreach (var folder in subFolders)
        {
            Local_FindDirectoryAbsPath(folder);
        }
    }
}
```