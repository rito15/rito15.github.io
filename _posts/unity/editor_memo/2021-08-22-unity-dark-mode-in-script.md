---
title: 유니티 에디터 다크모드 여부 스크립트로 확인하기
author: Rito15
date: 2021-08-22 22:48:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

## 확인된 버전

- `2019.4.9f1`

<br>

## [1] 다크모드 여부 확인

```cs
EditorGUIUtility.isProSkin;

// true : 다크모드
// false : 일반모드(Light)
```

<br>

## [2] 모드 변경하기

```cs
UnityEditorInternal.InternalEditorUtility.SwitchSkinAndRepaintAllViews();
```