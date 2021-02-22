---
title: 파티클 시스템 기초 - 02 - 파티클 속성 기초
author: Rito15
date: 2021-02-22 15:55:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [1. 개요](#개요)

- [2. 메인 모듈](#메인-모듈)
  - [Start Lifetime](#start-lifetime)
  - [Start Speed](#start-speed)
  - [Start Size](#start-size)
  - [Start Color](#start-color)
  - [Gravity Modifier](#gravity-modifier)

- [3. Emission](#emission)

- [4. Shape](#shape)

- [5. Renderer](#renderer)


<br>

# 개요
---

- 파티클 시스템에는 수많은 모듈과 그 속성들이 존재한다.

- Duration ~ Ring Buffer Mode 부분은 메인 모듈이라고 부르며 반드시 사용되는 속성들이 존재한다.

- Emision, Shape 등 추가적인 모듈들이 존재하며, 체크 및 체크 해제하여 사용 여부를 결정할 수 있다.

- 많은 속성들 중에서도 파티클 시스템을 만들기 위해 최소한으로 필요한 속성들에 대해 소개한다.

<br>

# 메인 모듈
---

![image](https://user-images.githubusercontent.com/42164422/108676183-2fbea980-752b-11eb-9924-4165131923ea.png){:.normal}

<br>

## Start Lifetime

- 파티클 시스템에서 생성되는 각 파티클의 수명을 결정한다. (단위 : 초)

- 예를 들어 5를 설정했을 경우, 각각의 파티클은 생성되는 순간부터 5초가 지나면 사라진다.

- 예시 : Start Lifetime [5] vs [1]

![2021_0222_Particle_Lifetime](https://user-images.githubusercontent.com/42164422/108677492-1dde0600-752d-11eb-85b0-6145f0d58850.gif){:.normal}

<br>

## Start Speed

- 각 파티클에 적용될 속력을 지정한다.

- 이 때, 방향은 파티클 시스템에 적용된 Shape 속성에 따라 결정된다.

- 예시 : Start Speed [1] vs [3]

![2021_0222_Particle_Speed](https://user-images.githubusercontent.com/42164422/108677497-21718d00-752d-11eb-8549-05a52f66ed04.gif){:.normal}

<br>

## Start Size

- 각 파티클의 크기를 결정한다.

- 예시 : Start Size [1] vs [3]

![2021_0222_Particle_Size](https://user-images.githubusercontent.com/42164422/108677505-23d3e700-752d-11eb-89b0-2e9d3769428a.gif){:.normal}

<br>

## Start Color

- 각 파티클의 색상 및 투명도를 결정한다.

- 예시 : Start Color [White] vs [Yellow]

![2021_0222_Particle_Color](https://user-images.githubusercontent.com/42164422/108677512-25051400-752d-11eb-8325-e9b386683277.gif){:.normal}

<br>

## Gravity Modifier

- 각 파티클에 적용될 중력의 강도를 결정한다.

- 기본적으로 중력은 -Y축 방향으로 설정되어 있으므로, Gravity Modifer를 설정하면 파티클은 아래쪽으로 향하게 된다.

- Start Speed와 Gravity Modifier가 모두 설정되어 있을 경우, 합산하여 적용된다.

- 예시 : Gravity Modifier [0] vs [1]

![2021_0222_Particle_Gravity](https://user-images.githubusercontent.com/42164422/108677519-26364100-752d-11eb-9707-f356cb25b57a.gif){:.normal}

<br>

# Emission
---

![image](https://user-images.githubusercontent.com/42164422/108676859-3863af80-752c-11eb-9b03-4bd3479deaf9.png){:.normal}

## Rate over Time

- 초당 생성되는 파티클의 개수를 지정한다.

- 예시 : Rate over Time [1] vs [10]

![2021_0222_Particle_Emission](https://user-images.githubusercontent.com/42164422/108677525-28000480-752d-11eb-9902-265637250d61.gif){:.normal}

<br>

# Shape
---

![image](https://user-images.githubusercontent.com/42164422/108678485-7cf04a80-752e-11eb-96da-e9ec61a13cbe.png){:.normal}

- 파티클이 생성될 영역의 모양과 크기를 결정한다.

- 파티클 시스템을 처음 생성할 때 기본적으로 Cone으로 지정된다.

- Cone, Sphere, Box 등을 주로 사용한다.

- `Particle System` 컴포넌트의 [Shape] 탭을 펼칠 경우, 씬뷰에서 기즈모를 통해 모양을 가시적으로 확인할 수 있다.

- 예시 : [Cone] vs [Sphere]

![2021_0222_Particle_Shape](https://user-images.githubusercontent.com/42164422/108678281-3d296300-752e-11eb-9a42-ec6bbbb04f28.gif){:.normal}

<br>

# Renderer
---

![image](https://user-images.githubusercontent.com/42164422/108679844-74990f00-7530-11eb-93a1-0a8ab8ac565f.png){:.normal}

- 파티클의 렌더링 관련 속성들을 결정한다.

<br>

## Material

- 파티클에 사용될 마테리얼을 지정한다.

