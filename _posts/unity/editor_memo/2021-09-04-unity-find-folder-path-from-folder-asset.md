---
title: 유니티 - 폴더 애셋으로부터 폴더 절대 경로 구하기
author: Rito15
date: 2021-09-04 19:59:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# 1. 삽질
---

<details>
<summary markdown="span"> 
...
</summary>

아무 생각 없이 재귀로 폴더도 찾고, 메타 파일도 찾고, Regex로 guid도 찾고...

정신 차려보니 아래와 같은 소스 코드를 짜고 있었다.

```cs
/// <summary> 지정한 폴더 애셋의 절대 경로 찾기 </summary>
private string FindFolderAssetAbsPath(DefaultAsset folderAsset)
{
    // Note: Assets 디렉토리로부터 하위 폴더 전부 순회하며 폴더 이름 일치하는 경로 탐색

    DirectoryInfo rootDirectory = Directory.CreateDirectory(Application.dataPath);
    string found = null;

    bool guidFound = AssetDatabase.TryGetGUIDAndLocalFileIdentifier(folderAsset, out string guid, out long _);
    if (guidFound == false) return null;

    Local_FindDirectoryAbsPath(rootDirectory, folderAsset.name, guid);
    return found;

    // 내부 재귀 메소드
    void Local_FindDirectoryAbsPath(DirectoryInfo currentDirectory, string folderName, string folderGuid)
    {
        if (found != null) return;

        // 일치하는 경로명 찾은 경우 Meta 파일의 GUID 일치 여부 확인
        if (currentDirectory.Name == folderName)
        {
            FileInfo metaFile = new FileInfo(currentDirectory.FullName + ".meta");
            string metaGUID = GetGuidFromMetaFile(metaFile);

            // GUID까지 일치
            if (metaGUID == folderGuid)
            {
                found = currentDirectory.FullName;
                return;
            }
        }

        // 하위 폴더들 재귀 탐색
        DirectoryInfo[] subFolders = currentDirectory.GetDirectories();
        foreach (var folder in subFolders)
        {
            Local_FindDirectoryAbsPath(folder, folderName, folderGuid);
        }
    }
}

private string GetGuidFromMetaFile(FileInfo metaFileInfo)
{
    if (metaFileInfo == null || metaFileInfo.Exists == false) return null;

    string contents = File.ReadAllText(metaFileInfo.FullName);

    Debug.Log(contents);

    Match match = Regex.Match(contents, @"guid: (.+)[\r\n]");
    if (match.Groups.Count > 1)
    {
        return match.Groups[1].Value;
    }

    return null;
}
```

<br>

## **Usage**

```cs
// EditorWindow 상속 클래스 내부

public DefaultAsset folderAsset;
private GUIContent folderLabel;

private void OnGUI()
{
    if(folderLabel == null)
        folderLabel = new GUIContent("Folder");

    folderAsset = EditorGUILayout.ObjectField(folderLabel, folderAsset, typeof(DefaultAsset), false) as DefaultAsset;

    if (GUILayout.Button("Find"))
    {
        if (folderAsset != null)
        {
            string path = FindFolderAssetAbsPath(folderAsset);
            Debug.Log(path);
        }
    }
}
```

이정도 기능은 있지 않을까.. 하고 찾아보니

역시나 `AssetDatabase` 클래스가 모두 갖고 있는 기능이었다.

교훈 : 친절하게 구현된 API를 먼저 찾자.

</details>

<br>

# 2. Unity API 사용
---

- NOTE : `DefaultAsset` 클래스는 `UnityEngine.Object`의 자식으로, 폴더 애셋을 가리킨다.

<details>
<summary markdown="span"> 
...
</summary>

```cs
// EditorWindow 상속 클래스 내부

public DefaultAsset folderAsset;
private GUIContent folderLabel;

private void OnGUI()
{
    if(folderLabel == null)
        folderLabel = new GUIContent("Folder");

    folderAsset = EditorGUILayout.ObjectField(folderLabel, folderAsset, typeof(DefaultAsset), false) as DefaultAsset;

    if (GUILayout.Button("Call") && folderAsset != null)
    {
        // 폴더 애셋 -> GUID 찾기
        AssetDatabase.TryGetGUIDAndLocalFileIdentifier(folderAsset, out string guid, out long _);

        if (guid != null)
        {
            // GUID -> Assets/ 로 시작하는 상대 경로 찾기
            string path = AssetDatabase.GUIDToAssetPath(guid);
            path = path.Substring(path.IndexOf('/') + 1);

            // 드라이브 경로로부터 시작하는 절대 경로 조립
            string fullPath = Path.Combine(Application.dataPath, path);
            Debug.Log(fullPath);
        }
    }
}
```

</details>

<br>

# 3. 사용하기 편리한 확장 메소드
---

- 반드시 `UNITY_EDITOR` 조건 내에서 사용해야 한다.

```cs
public static class UnityEditorAssetExtensions
{
    /// <summary> 폴더 애셋으로부터 Assets로 시작하는 로컬 경로 얻기 </summary>
    public static string GetLocalPath(this UnityEditor.DefaultAsset @this)
    {
        bool success = 
            UnityEditor.AssetDatabase.TryGetGUIDAndLocalFileIdentifier(@this, out string guid, out long _);

        if (success)
            return UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
        else
            return null;
    }

    /// <summary> 폴더 애셋으로부터 절대 경로 얻기 </summary>
    public static string GetAbsolutePath(this UnityEditor.DefaultAsset @this)
    {
        string path = GetLocalPath(@this);
        if (path == null) 
            return null;

        path = path.Substring(path.IndexOf('/') + 1);
        return Application.dataPath + "/" + path;
    }

    /// <summary> 폴더 애셋으로부터 DirectoryInfo 객체 얻기 </summary>
    public static System.IO.DirectoryInfo GetDirectoryInfo(this DefaultAsset @this)
    {
        string absPath = GetAbsolutePath(@this);
        return (absPath != null) ? new System.IO.DirectoryInfo(absPath) : null;
    }
}
```
