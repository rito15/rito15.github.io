---
title: UI 위에 게임오브젝트 띄우기
author: Rito15
date: 2021-02-28 22:30:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, ui]
math: true
mermaid: true
---

# Preview
---

![image](https://user-images.githubusercontent.com/42164422/109421383-7116f380-7a1a-11eb-95c2-fea9f22aa3ba.png)

- Green : Default
- Red : Over UI

<br>

# 1. Built-in Render Pipeline
---

<details>
<summary markdown="span"> 
.
</summary>

## [1] 레이어 준비
- [Over UI] 레이어를 만든다.

<br>

## [2] Over UI 카메라 준비
- 카메라를 하나 더 만들고, Audio Listener를 제거한다.

- 메인 카메라와 함께 움직이려면 메인 카메라의 자식으로 둔다.

- Over UI 카메라의 Camera 컴포넌트 설정
  - Clear Flags : `Depth Only`
  - Culling Mask : `Over UI`
  - Depth : `0`

- 메인 카메라의 Camera 컴포넌트 설정
  - Culling Mask에서 `Over UI`만 제외
  - Depth : `-1` (기본값)

<br>

## [3] 캔버스 설정
- Render Mode : `Screen Space - Camera`
- Render Camera : 메인 카메라
- Plane Distance : `0.30001` (메인 카메라의 Near Plane + 0.0001)

<br>

## [4] 대상에 레이어 설정
- UI 위에 띄울 게임오브젝트들에 [Over UI] 레이어를 설정한다.


</details>


<br>

# 2. Universal Render Pipeline
---

<details>
<summary markdown="span"> 
.
</summary>

## [1] 레이어 준비
- [Over UI] 레이어를 만든다.

<br>

## [2] Over UI 카메라 준비
- 카메라를 하나 더 만들고, Audio Listener를 제거한다.

- 메인 카메라와 함께 움직이려면 메인 카메라의 자식으로 둔다.

- Over UI 카메라의 Camera 컴포넌트 설정
  - Render Type : `Overlay`
  - Culling Mask : `Over UI`

- 메인 카메라의 Camera 컴포넌트 설정
  - Culling Mask에서 `Over UI`만 제외
  - Stack - Over UI 카메라 추가

<br>

## [3] 캔버스 설정
- Render Mode : `Screen Space - Camera`
- Render Camera : 메인 카메라
- Plane Distance : `0.30001` (메인 카메라의 Near Plane + 0.0001)

<br>

## [4] 대상에 레이어 설정
- UI 위에 띄울 게임오브젝트들에 [Over UI] 레이어를 설정한다.

<br>

## [5] 파티클 버그 해결

- 위처럼 설정할 경우, 파티클이 정상적으로 UI에 가려지지 않는 버그가 발생한다.

- Sorting Layer - [UI] 생성

- Canvas - Sorting Layer - [UI] 설정

</details>