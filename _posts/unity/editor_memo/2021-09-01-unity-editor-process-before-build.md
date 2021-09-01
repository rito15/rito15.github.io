---
title: 유니티 에디터 - 빌드 직전에 동작하는 기능 작성하기
author: Rito15
date: 2021-09-01 17:51:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

- 아래의 형태로 스크립트를 작성해놓으면 빌드 직전에 동작한다.

```cs
#if UNITY_EDITOR

class BuildPreProcessor : UnityEditor.Build.IPreprocessBuildWithReport
{
    public int callbackOrder => 0;

    public void OnPreprocessBuild(UnityEditor.Build.Reporting.BuildReport report)
    {
        // Do Something Here
    }
}

#endif
```

<br>

# References
---
- <https://docs.unity3d.com/ScriptReference/Build.IPreprocessBuildWithReport.OnPreprocessBuild.html>