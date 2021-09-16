---
title: 유니티 - 오클루전 컬링
author: Rito15
date: 2021-03-01 01:40:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization, performance]
math: true
mermaid: true
---

# 프러스텀 컬링 (Frustum Culling)
---
- 카메라의 뷰 프러스텀(View Frustum) 영역 밖의 오브젝트들은 렌더링하지 않는 것

- 따로 설정하지 않아도 유니티 내에서 기본적으로 적용된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/109426375-cd850d80-7a30-11eb-82f8-6e175b6ce416.png){:.normal}

그냥 이렇게 두어도

![image](https://user-images.githubusercontent.com/42164422/109426398-ee4d6300-7a30-11eb-9b4a-d3011505ed3b.png){:.normal}

실제로 이렇게 컬링된다.

<br>

## GIF

![2021_0301_FrustumCulling](https://user-images.githubusercontent.com/42164422/109426546-98c58600-7a31-11eb-9b64-752e0d63a804.gif)

<br>

# 오클루전 컬링 (Occlusion Culling)
---
- 다른 오브젝트에 가려진 오브젝트들은 렌더링하지 않는 것

- [Window] - [Rendering] - [Occlusion Culling]

- Occlusion Culling 윈도우를 통해 설정할 수 있다.

<br>

## 사전 준비
- 오클루전 컬링의 대상이 될 오브젝트들은 게임 내에서 움직이지 않아야 한다.

- 대상 게임오브젝트들을 `Occluder Static` 또는 `Occludee Static`으로 설정한다.
  - Occluder : 다른 오브젝트를 가리거나 가려질 오브젝트
  - Occludee : Occluder에 의해 가려질 오브젝트

![image](https://user-images.githubusercontent.com/42164422/109426669-2bfebb80-7a32-11eb-826e-972bd2bcf2b2.png)

<br>

## 오클루전 컬링 윈도우

- Bake 탭에서 아래의 프로퍼티들을 설정할 수 있다.

|프로퍼티|기능|
|---|---|
|`Smallest Occluder`|오브젝트를 Occluder로 인식할 최소 크기.<br>이 값보다 작은 크기를 갖는 오브젝트는 다른 오브젝트를 가리지 않는다고 판단한다.|
|`Smallest Hole`|카메라가 지오메트리 사이의 빈 공간으로 인식할 최소 거리.<br>오브젝트들이 촘촘하게 배치되어 있을수록 이 값은 더 작게 설정해야 한다.|
|`Backface Threshold`|백페이스를 제거할 임계값. 값이 작을수록 더 많은 백페이스를 제거한다.| 

![image](https://user-images.githubusercontent.com/42164422/109427878-b7c71680-7a37-11eb-8c74-df0a9a0acac0.png)

<br>

- [Bake] 버튼을 누르면 오클루전 컬링 데이터가 베이크 된다.

- [Visualization] 탭에서 실제로 컬링되는 모습을 확인할 수 있다.

<br>

## GIF

![2021_0301_OcclusionCulling](https://user-images.githubusercontent.com/42164422/109426547-9a8f4980-7a31-11eb-9ff2-11bf3d95ba40.gif)

<br>

# References
---
- <https://docs.unity3d.com/kr/530/Manual/OcclusionCulling.html>