---
title: 유니티 - UI 위에 게임오브젝트 띄우기
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
방법
</summary>

<br>

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
- Plane Distance : `0.3001` (메인 카메라의 Near Plane + 0.0001)

<br>

## [4] 대상에 레이어 설정
- UI 위에 띄울 게임오브젝트들에 [Over UI] 레이어를 설정한다.

</details>

<br>


<details>
<summary markdown="span">
스크린샷
</summary>

<br>

## 레이어 설정
![image](https://user-images.githubusercontent.com/42164422/145761749-31d23fcd-80bc-489e-9f53-d5ef55ff4b51.png){:.normal}

## 하이라키 구성
![image](https://user-images.githubusercontent.com/42164422/145761393-863f5f38-1197-463d-98e2-a7a103c45869.png){:.normal}

## 메인 카메라
![image](https://user-images.githubusercontent.com/42164422/145763213-f46577e3-0073-4449-aa5b-a7452e7d3315.png){:.normal}

## Over UI 카메라
![image](https://user-images.githubusercontent.com/42164422/145763237-4aabd560-454b-4e33-b214-bc9e2bdf80c2.png){:.normal}

## 캔버스
![image](https://user-images.githubusercontent.com/42164422/145763266-8550be44-f4be-488d-85bd-dab809249be3.png){:.normal}

## Over UI 오브젝트
![image](https://user-images.githubusercontent.com/42164422/145763274-350f0c09-e6d3-4b16-bb80-b7cc5db9db95.png){:.normal}

</details>

<br>

# 2. Universal Render Pipeline(URP)
---

<details>
<summary markdown="span"> 
방법
</summary>

<br>

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
- Plane Distance : `0.3001` (메인 카메라의 Near Plane + 0.0001)

<br>

## [4] 대상에 레이어 설정
- UI 위에 띄울 게임오브젝트들에 [Over UI] 레이어를 설정한다.

<br>

## [5] 파티클 버그 해결

- 위처럼 설정할 경우, 파티클이 정상적으로 UI에 가려지지 않는 버그가 발생한다.

- Sorting Layer - [UI] 생성

- Canvas - Sorting Layer - [UI] 설정

</details>

<br>


<details>
<summary markdown="span">
스크린샷
</summary>

<br>

## 레이어 설정
![image](https://user-images.githubusercontent.com/42164422/145761749-31d23fcd-80bc-489e-9f53-d5ef55ff4b51.png){:.normal}

## 하이라키 구성
![image](https://user-images.githubusercontent.com/42164422/145761393-863f5f38-1197-463d-98e2-a7a103c45869.png){:.normal}

## 메인 카메라
![image](https://user-images.githubusercontent.com/42164422/145765141-00981265-9dc8-4fdc-a418-1934db6428e6.png){:.normal}

## Over UI 카메라
![image](https://user-images.githubusercontent.com/42164422/145765149-4c3319f3-9448-43fa-913c-ca968fca2d7a.png){:.normal}

## 캔버스
![image](https://user-images.githubusercontent.com/42164422/145763266-8550be44-f4be-488d-85bd-dab809249be3.png){:.normal}

## Over UI 오브젝트
![image](https://user-images.githubusercontent.com/42164422/145763274-350f0c09-e6d3-4b16-bb80-b7cc5db9db95.png){:.normal}

</details>

<br>