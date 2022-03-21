---
title: 유니티 - 포스트 프로세싱 적용하기
author: Rito15
date: 2021-03-16 17:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, postprocessing]
math: true
mermaid: true
---

# 1. Built-in Pipeline
---

## **[1] 패키지 설치**

- **Package Manager** - `Post Processing` 설치

<br>

## **[2] 레이어 추가**

- 레이어 - `Post Processing` 추가

<br>

## **[3] 메인 카메라 게임오브젝트**

- 컴포넌트 추가 : `Post-process Layer`

- **Post-process Layer** 컴포넌트
  - **Volume blending** - **Layer** : `Post Processing` 설정

<br>

## **[4] 포스트 프로세싱 볼륨 게임오브젝트**

- 빈 게임오브젝트 추가

- 레이어 설정 : `Post Processing`

- 컴포넌트 추가 : `Post-process Volume`
  - `Is Global` 체크
  - **Profile** - `New`
  - `Add effect`를 통해 원하는 효과 추가

<br>

# 2. URP
---

## **[1] URP 애셋 정상 적용 확인**

- **Edit - Project Settings**
  - **Graphics** - `Scriptable Render Pipeline Settings`
  - URP 애셋 장착(드래그 앤 드롭 또는 우측 동그라미를 통해 목록에서 선택)

<br>

- URP 애셋이 없을 경우
  - **Project 윈도우** - 빈 공간 우클릭
  - Create
  - Rendering
  - Universal Render Pipeline
  - `Pipeline Asset (Forward Renderer)`

<br>

## **[2] URP Asset Forward Renderer 설정**

- **Post-processing**
  - `Enabled` 체크

<br>

## **[3] 레이어 추가**

- 레이어 - `Post Processing` 추가

<br>

## **[4] 메인 카메라 - Camera 컴포넌트**

- **Rendering**
  - `Post Processing` 체크

- **Environment**
  - **Volume Mask** - `Post Processing` 설정

<br>

## **[5] 포스트 프로세싱 볼륨 게임오브젝트**

- 빈 게임오브젝트 추가

- 레이어 설정 : `Post Processing`

- 컴포넌트 추가 : `Volume`
  - **Mode** : `Global`
  - **Profile** - `New`
  - `Add Override`를 통해 원하는 효과 추가

<br>

