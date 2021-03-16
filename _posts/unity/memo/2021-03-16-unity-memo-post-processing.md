---
title: 포스트 프로세싱 적용하기
author: Rito15
date: 2021-03-16 17:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, postprocessing]
math: true
mermaid: true
---

# 1. Built-in Pipeline
---

- `Package Manager` - [Post Processing] 설치

- 레이어 - [Post Processing] 추가

<br>
- 메인 카메라
  - 컴포넌트 추가 : `Post-process Layer`
  - `Volume blending` - `Layer` : [Post Processing] 설정

<br>
- 빈 게임오브젝트 추가 : "Volume"
  - 레이어 설정 : [Post Processing]
  - 컴포넌트 추가 : `Post-process Volume`
    - `Is Global` 체크
    - `Profile` - [New]
    - [Add effect...]

<br>

# 2. URP
---

- 레이어 - [Post Processing] 추가

<br>
- 메인 카메라
  - `Rendering` - `Post Processing` 체크
  - `Environment` - `Volume Mask` - [Post Processing] 설정

<br>
- 빈 게임오브젝트 추가 : "Volume"
  - 레이어 설정 : [Post Processing]
  - 컴포넌트 추가 : `Volume`
    - `Mode` : [Global]
    - `Profile` - [New]
    - [Add effect...]