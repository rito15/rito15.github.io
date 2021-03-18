---
title: 파티클 시스템 예제 - 07 - Fireworks
author: Rito15
date: 2021-03-16 17:10:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. Fireworks 이펙트](#1-fireworks-이펙트)
- [2. SubEmitter - Birth](#2-subemitter---birth)
- [3. SubEmitter - Death](#3-subemitter---death)
- [4. SubEmitter - Death Flash](#4-subemitter---death-flash)
- [5. 완성](#5-완성)

# Preview
---

![2021_0316_Fireworks3](https://user-images.githubusercontent.com/42164422/111277476-d6562000-867b-11eb-9c79-88ba5903b34c.gif)

<br>

# 목표
---

- 서브 이미터 모듈 이해하기

- 불꽃놀이 이펙트 완성하기

<br>

# 준비물
---

- 동그란 텍스쳐와 Additive 마테리얼

![image](https://user-images.githubusercontent.com/42164422/111299999-f72a6f80-8693-11eb-93b5-7feea986b03c.png)

<br>

# 1. Fireworks 이펙트
---

불꽃을 하늘로 쏘아올리는, 간단한 형태의 이펙트를 우선 제작한다.

<br>

## 준비

- 하이라키 - 우클릭 - [Effects] - [Particle System]을 통해 파티클 시스템 게임오브젝트를 생성한다.

- 생성된 게임오브젝트를 클릭하고 이름을 "Fireworks"로 변경한다.

- 인스펙터의 트랜스폼 우측 상단에 있는 `...`을 클릭하고 [Reset]을 누른다.

- 트랜스폼의 Position Y 값을 -4정도로 낮춘다.

- 준비한 마테리얼을 파티클 시스템에 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` - [Random Between Two Constants] : (1.5, 2)

- `Start Color` - [Gradient] 또는 [Random Color] : 원하는 색상 지정

![image](https://user-images.githubusercontent.com/42164422/111301164-37d6b880-8695-11eb-953c-80ec39fd8cab.png)

- `Gravity Modifier` : 0.1

- `Simulation Space` : World

<br>

## Emission 모듈

- `Rate over Time` : 4

<br>

## Shape 모듈

- `Shape` : Cone

- `Angle` : 45

- `Rotation` : (-90, 0, 0)

<br>

## Sub Emitters 모듈

![2021_0316_Fireworks_SubEmitter1](https://user-images.githubusercontent.com/42164422/111300667-aebf8180-8694-11eb-8e57-14670ea0930b.gif)

- 첫 번째 요소의 우측에 있는 `+`를 눌러, 파티클 시스템 하나를 추가한다.

- `Inherit`를 Color로 설정한다.

<br>

추가된 서브 이미터 파티클 시스템은 [Fireworks] 파티클 시스템의 각 파티클이 생성될 때마다 생성되며, 

색상을 계승하여 자동으로 적용한다.

<br>

# 2. SubEmitter - Birth
---

![image](https://user-images.githubusercontent.com/42164422/111300745-c4cd4200-8694-11eb-99ad-5c63a52020d2.png)

하이라키의 [Fireworks] 게임오브젝트의 좌측 화살표를 클릭해보면 [SubEmitter0] 게임오브젝트가 추가된 것을 확인할 수 있다.

이 게임오브젝트의 이름을 [SubEmitter - Birth]로 수정한다.

<br>

## 마테리얼 지정

- [Fireworks] 파티클 시스템에 사용한 마티리얼을 똑같이 [SubEmitter - Birth] 파티클 시스템에도 적용해준다.

<br>

## 메인 모듈

- `Looping` : 체크 해제

- `Start Speed` : 0.2

- `Simulation Space` : World

<br>

## Emission 모듈

- `Rate over Time` : 48

<br>

## Color over Lifetime 모듈

- 알파값이 255 ~ 0으로 감소하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/111301767-f09cf780-8695-11eb-9694-fe2d85f981b7.png)

<br>

## Size over Lifetime 모듈

- 크기가 100%에서 0%로 감소하도록 커브를 설정한다.

![image](https://user-images.githubusercontent.com/42164422/111301997-322da280-8696-11eb-96d9-e6a38a47a0b9.png)

<br>

## 현재 상태

![2021_0316_Fireworks_SubEmitter1_Prev](https://user-images.githubusercontent.com/42164422/111302348-a2d4bf00-8696-11eb-8bed-4734782dcd82.gif)

<br>

# 3. SubEmitter - Death
---

[Fireworks] 파티클 시스템의 Sub Emitters 모듈에 새로운 서브이미터를 하나 더 추가하고, `Birth`를 `Death`로 변경한다.

![2021_0317_Fireworks_SubEmitter2](https://user-images.githubusercontent.com/42164422/111459833-9156ea00-875e-11eb-893a-64a7715fafae.gif)

그리고 추가된 [SubEmitter1] 게임오브젝트의 이름을 [SubEmitter - Death]로 변경하고,

[Fireworks]와 동일한 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Looping` : 체크 해제

- `Start Lifetime` : 2

- `Start Speed` : 1

- `Simulation Space` : World

<br>

## Emission 모듈

- `Bursts` : 자동으로 등록되어 있는 버스트의 `Count`를 30에서 96으로 변경한다.

<br>

## Color over Lifetime 모듈

- 알파값이 255 ~ 0으로 감소하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/111301767-f09cf780-8695-11eb-9694-fe2d85f981b7.png)

<br>

## Size over Lifetime 모듈

- 크기가 100%에서 0%로 감소하도록 커브를 설정한다.

![image](https://user-images.githubusercontent.com/42164422/111301997-322da280-8696-11eb-96d9-e6a38a47a0b9.png)

<br>

## 현재 상태

![2021_0317_Fireworks_SubEmitter2_Prev](https://user-images.githubusercontent.com/42164422/111460715-a3855800-875f-11eb-8980-1ae8d68f62b6.gif)

<br>

# 4. SubEmitter - Death Flash
---

[Fireworks] 파티클 시스템의 Sub Emitters 모듈에 새로운 서브이미터를 하나 더 추가하고, `Birth`를 `Death`로 변경한다.

그리고 추가된 [SubEmitter2] 게임오브젝트의 이름을 [SubEmitter - Death Flash]로 변경한다.

마테리얼은 바꾸지 않고 [Default-ParticleSystem]을 그대로 사용한다.

유니티의 기본 파티클 텍스쳐는 너무 흐릿해서 쓸 일이 별로 없지만, 빛이 순간적으로 번쩍이는 효과를 표현할 때 유용하게 사용할 수 있다.

<br>

## 메인 모듈

- `Looping` : 체크 해제

- `Start Lifetime` : 0.5

- `Start Speed` : 0

- `Start Size` : 4

- `Simulation Space` : World

- `Start Color` : 색상을 클릭하여, A(알파) 값만 0.4로 수정한다.

<br>

## Emission 모듈

- `Bursts` : 자동으로 등록되어 있는 버스트의 `Count`를 30에서 1로 변경한다.

<br>

## Color over Lifetime 모듈

- 알파값이 255 ~ 0으로 감소하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/111301767-f09cf780-8695-11eb-9694-fe2d85f981b7.png)

<br>

# 5. 완성
---

![2021_0316_Fireworks3](https://user-images.githubusercontent.com/42164422/111277476-d6562000-867b-11eb-9c79-88ba5903b34c.gif)

