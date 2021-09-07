---
title: 유니티 - 플랫폼별 경로들
author: Rito15
date: 2021-09-07 19:39:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 경로 파라미터
---

- `<projectroot>` : **유니티 에디터 프로젝트 폴더 루트 경로**
- `<executablefolder>` : **빌드된 실행 파일의 폴더 경로**
- `<companyname>` : **Project Settings - Player**에서 지정한 `Company Name`
- `<productname>` : **Project Settings - Player**에서 지정한 `Product Name`
- `<packagename>` : `com.<companyname>.<productname>`

<br>

# 읽기, 쓰기 모두 가능한 경로
---

## **Windows Editor**

```cs
Application.dataPath
"<projectroot>/Assets"
```

```cs
Application.persistentDataPath
"%userprofile%/AppData/LocalLow/<companyname>/<productname>"
```

```cs
Application.streamingAssetsPath
"<projectroot>/Assets/StreamingAssets"
```

<br>

## **Windows Standalone**

```cs
Application.dataPath
"<executablefolder>/<productname>_Data"
```

```cs
Application.persistentDataPath
"%userprofile%/AppData/LocalLow/<companyname>/<productname>"
```

```cs
Application.streamingAssetsPath
"<executablefolder>/<productname>_Data/StreamingAssets"
```


<br>

## **Android**

```cs
Application.persistentDataPath

/* 외부 저장소 */
"/storage/emulated/0/Android/data/<packagename>/files"

/* 내부 저장소 */
"/data/data/<packagename>/files/"
```

<br>

## **IOS**

```cs
Application.persistentDataPath
"/var/mobile/Applications/programID/Documents"
```

<br>

# 읽기 전용 경로
---

## **Android**

```cs
Application.dataPath

/* 외부 저장소, 내부 저장소 */
"/data/app/<packagename>-NUMBER.apk"
```

```cs
Application.streamingAssetsPath

/* 외부 저장소, 내부 저장소 */
"jar:file:///data/app/<packagename>.apk!/assets"
```

<br>

## **IOS**

```cs
Application.persistentDataPath
"/var/mobile/Applications/programID/Documents"
```

<br>

## **WebGL**

- 모두 애셋 번들 사용

<br>

# References
---
- <https://docs.unity3d.com/ScriptReference/Application-dataPath.html>
- <https://docs.unity3d.com/ScriptReference/Application-persistentDataPath.html>
- <https://docs.unity3d.com/ScriptReference/Application-streamingAssetsPath.html>
- <http://memocube.blogspot.com/2014/04/blog-post.html>
- <https://3dmpengines.tistory.com/1745>