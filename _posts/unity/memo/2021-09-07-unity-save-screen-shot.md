---
title: 유니티 스크린샷 찍고 저장하기
author: Rito15
date: 2021-09-07 20:20:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 1. Unity Editor
---

## 저장할 경로
 - $"{Application.dataPath}/ScreenShots/"

## 실제 경로
 - "[프로젝트 디렉토리]/Assets/ScreenShots/"

<br>
<!-- ========================================================== -->

# 2. Standalone App
---

## 저장할 경로
 - $"{Application.dataPath}/ScreenShots/"

## 실제 경로
 - "[실행파일명]/[실행파일명_Data]/ScreenShots/"

<br>
<!-- ========================================================== -->

# 3. Android
---

## 저장할 경로
 - $"{Application.persistentDataPath}/ScreenShots/"

## 실제 경로
 - "/mnt/sdcard/Android/data/[패키지명]/files/ScreenShots/"
 
<br>

## 권한 요청하기

- 링크

<br>
<!-- ========================================================== -->

# 4. 스크린샷 찍기
---

## **[1] UI 포함하여 화면 전체 캡쳐**



<br>

## **[2] UI 미포함, 카메라가 렌더링하는 부분만 캡쳐**



<br>
<!-- ========================================================== -->

# References
---
- <https://3dmpengines.tistory.com/1745>
- <https://docs.unity3d.com/kr/530/Manual/PlatformDependentCompilation.html>
- <https://docs.unity3d.com/kr/2020.3/Manual/android-manifest.html>
- <https://docs.unity3d.com/kr/2020.3/Manual/android-RequestingPermissions.html>