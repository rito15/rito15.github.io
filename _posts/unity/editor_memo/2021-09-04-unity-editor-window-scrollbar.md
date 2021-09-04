---
title: 유니티 에디터 윈도우 - 스크롤 바 생성하기
author: Rito15
date: 2021-09-04 23:11:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

- 에디터 윈도우 내의 내용들이 세로 범위를 넘어설 경우, 윈도우 우측에 스크롤 바를 생성한다.

- `BeginScrollView` ~ `EndScrollView` 사이 영역에만 스크롤바를 생성하고,<br>
  위아래 영역은 기존처럼 고정된다.

```cs
[SerializeField]
private Vector2 scrollPos = Vector2.zero;

private void OnGUI()
{
    scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

    // Codes....

    EditorGUILayout.EndScrollView();
}
```

