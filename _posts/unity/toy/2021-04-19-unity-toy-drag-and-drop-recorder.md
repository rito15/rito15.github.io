---
title: Drag and Drop Recorder
author: Rito15
date: 2021-04-19 21:00:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Summary
---
- 드래그 앤 드롭으로 게임오브젝트를 커서를 따라 이동시킨다.
- 이동 경로를 기록하고, 반복재생할 수 있다.


# How To Use
---
- 빈 게임오브젝트에 `DDRecorder` 컴포넌트를 추가한다.
- 드래그 앤 드롭으로 이동시킬 게임오브젝트에 콜라이더와 `DDTarget` 컴포넌트를 추가한다.
- `DDRecorder` 컴포넌트의 `Replay Target` 필드에 반복 재생시킬 게임오브젝트를 등록한다.
- 스페이스바를 누를 때마다 등록된 경로대로 타겟 게임오브젝트가 이동한다.


# Preview
---

![2021_0419_RecordDragAndDrop](https://user-images.githubusercontent.com/42164422/115235609-5711ab80-a155-11eb-8941-bb9e9ad91282.gif)


# Download
---
- [Drag and Drop Recorder.zip](https://github.com/rito15/Images/files/6336003/2021_0419_Drag.and.Drop.Recorder.zip)


# Source Code
---
- <https://github.com/rito15/Unity_Toys>

