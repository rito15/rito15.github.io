---
title: 컴파일, 게임 시작 시 실행되는 애트리뷰트 정리
author: Rito15
date: 2021-03-08 03:03:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp]
math: true
mermaid: true
---

# 공통 특징
---

- 클래스 또는 메소드 상단에 애트리뷰트를 명시한다.

- 컴포넌트로 넣지 않고, 스크립트로만 존재해도 실행된다.

- 정적 클래스나 상속에 관계 없이 동작한다.

- 메소드 애트리뷰트는 정적 메소드에만 동작한다.

<br>


# 컴파일, 플레이모드 진입 시 실행
---

## Note
 - `EditorApplication.isPlaying`으로 현재 에디터 모드를 구분하여 활용할 수 있다.

<br>

## **[InitializeOnLoad]**

- `using UnityEditor;`

- 클래스 애트리뷰트

- **정적 생성자가 호출되므로, 정적 생성자에 원하는 코드를 작성한다.**

- 실행 타이밍 : 컴파일, 플레이모드 진입(Awake() 호출 이전)

- 활용 : `EditorApplication.update`에 이벤트 핸들러를 추가하고 싶을 때

<br>

## **[InitializeOnLoadMethod]**

- `using UnityEditor;`

- 메소드 애트리뷰트

- 실행 타이밍 : 컴파일, 플레이모드 진입(Awake() 호출 이전)

<br>

# 플레이 모드 진입 시 실행
---

## **[InitializeOnEnterPlayMode]**

- `using UnityEditor;`

- 메소드 애트리뷰트

- 실행 타이밍 : 플레이 모드 진입(Awake() 호출 이전)

<br>

## **[RuntimeInitializeOnLoadMethod]**

- `using UnityEngine`

- 메소드 애트리뷰트

- 실행 타이밍 : 플레이 모드 진입(Awake(), OnEnable() 호출 이후)

<br>

# 실행 순서(플레이 모드 기준)
---

- `[InitializeOnLoad]` : 정적 생성자

- `[InitializeOnEnterPlayMode]` : 정적 메소드

- `[InitializeOnLoadMethod]` : 정적 메소드

- `Awake()`, `OnEnable()` : 동일 클래스 내에서는 `Awake()` 우선

- `[RuntimeInitializeOnLoadMethod]` : 정적 메소드

- `Start()`

<br>

# References
---
- <https://docs.unity3d.com/2019.3/Documentation/ScriptReference/InitializeOnEnterPlayModeAttribute.html>
- <https://docs.unity3d.com/kr/530/Manual/RunningEditorCodeOnLaunch.html>