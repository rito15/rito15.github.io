---
title: 파티클 시스템 예제 - 11 - Sword Effect
author: Rito15
date: 2021-03-30 23:23:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. 하이라키 구성](#1-하이라키-구성)
- [2. Glow 이펙트](#2-glow-이펙트)
- [3. Sparkle 이펙트](#3-sparkle-이펙트)
- [4. Aura 이펙트](#4-aura-이펙트)
- [5. 결과](#5-결과)

<br>

# Preview
---

![2021_0330_SwordEffect](https://user-images.githubusercontent.com/42164422/113001565-e1489e80-91ab-11eb-8051-83e7256c89ad.gif)

<br>

# 목표
---

- 검 모델링에 부착하여 사용할 수 있는 이펙트(무기 강화 이펙트) 만들기

<br>

# 준비물
---

- 검 모델링
  - <https://assetstore.unity.com/packages/3d/props/weapons/free-low-poly-swords-189978>

<br>

- Sparkle, PointGlow 텍스쳐를 사용하는 Additive 마테리얼
  - [Sparkle_PointGlow.zip](https://github.com/rito15/Images/files/6229470/Sparkle_PointGlow.zip)

<br>

# 1. 하이라키 구성
---

위의 검 모델링 무료 애셋을 사용하는 경우를 예시로 한다.

1. 우선 [PP_Sword_1039] 프리팹을 하이라키로 드래그하여 가져온다.

2. 해당 게임오브젝트를 우클릭하고 [Unpack Prefab]을 클릭한다.

3. 다시 게임오브젝트를 우클릭하고 [Effects] - [Particle System]을 클릭한다.

4. 추가된 파티클 시스템 게임오브젝트의 이름을 [Enhancement Effect]로 변경한다.

5. [Enhancement Effect] 게임오브젝트의 `Particle System` 컴포넌트에서 `Emission`, `Shape`, `Renderer` 모듈을 모두 체크 해제한다.

![image](https://user-images.githubusercontent.com/42164422/113035317-14038e80-91ce-11eb-8aaf-bddccf371345.png)

<br>

# 2. Glow 이펙트
---

[Enhancement Effect] 게임오브젝트를 우클릭하고, [Effects] - [Particle System]을 클릭하여 새로운 파티클 시스템 게임오브젝트를 자식으로 추가한다.

그리고 해당 게임오브젝트의 이름을 [Glow]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/113035614-5cbb4780-91ce-11eb-801e-111a8e5c513f.png)

파티클 시스템에 `Additive_PointGlow` 마테리얼을 적용한다.

<br>

## **메인 모듈**

- `Start Lifetime` - [Random Between Two Constants] : (2, 3)

- `Start Speed` : 0

- `Start Size` : 0.5

- `Start Color` : 원하는 색상 설정

- 색상 예시(Random Color)

![image](https://user-images.githubusercontent.com/42164422/113044564-c3456300-91d8-11eb-961c-a6982831c216.png)

<br>

## **Emission 모듈**

- `Rate over Lifetime` : 48

<br>

## **Shape 모듈**

- `Shape` : Mesh

- `Type` : Triangle

- `Mesh` : 우측의 ◎를 눌러 검 모델링의 메시 선택

<br>

## **Color over Lifetime 모듈**

- `Color` : 알파값이 0 ~ 255 ~ 0으로 변하도록 지정

![image](https://user-images.githubusercontent.com/42164422/113037593-81182380-91d0-11eb-82eb-481e30b81ebe.png)

<br>

## **Size over Lifetime 모듈**

- `Size` : 0.0 ~ 1.0으로 증가하는 그래프(기본값)

![image](https://user-images.githubusercontent.com/42164422/113037781-b4f34900-91d0-11eb-8f18-db61bf107d19.png)

<br>

## **현재 상태**

![2021_0331_SwordEffect_1](https://user-images.githubusercontent.com/42164422/113037352-40200f00-91d0-11eb-893e-669556cd5529.gif)

<br>

# 3. Sparkle 이펙트
---

[Enhancement Effect] 게임오브젝트를 우클릭하고, [Effects] - [Particle System]을 클릭하여 새로운 파티클 시스템 게임오브젝트를 자식으로 추가한다.

그리고 해당 게임오브젝트의 이름을 [Sparkle]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/113037975-e66c1480-91d0-11eb-88bb-3b63c95b6668.png)

파티클 시스템에 `Additive_Sparkle` 마테리얼을 적용한다.

<br>

## **메인 모듈**

- `Start Lifetime` - [Random Between Two Constants] : (1, 2)

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (0.1, 0.5)

- `Start Color` : 원하는 색상 지정

- `Gravity Modifier` - [Random Between Two Constants] : (0, -0.05)

<br>

## **Emission 모듈**

- `Rate over Lifetime` : 48

<br>

## **Shape 모듈**

- `Shape` : Sphere

- `Radius` : 0.3

- `Radius Thickness` : 0.3

- `Position` : (0, 0.5, 0)

- `Scale` : (1, 3, 1)

<br>

만약 다른 검 모델을 사용하는 경우, 아래처럼 Shape가 검을 완전히 감싸도록 `Radius`, `Position`, `Scale`을 적절히 조절한다.

![image](https://user-images.githubusercontent.com/42164422/113038921-09e38f00-91d2-11eb-9ffd-cf27fd56dab7.png)

<br>

## **Color over Lifetime 모듈**

- `Color` : 알파값이 0 ~ 255 ~ 0으로 변하도록 지정

![image](https://user-images.githubusercontent.com/42164422/113037593-81182380-91d0-11eb-82eb-481e30b81ebe.png)

<br>

## **Size over Lifetime 모듈**

- `Size` : 1.0 ~ 0.0으로 감소하는 그래프

![image](https://user-images.githubusercontent.com/42164422/113039266-7068ad00-91d2-11eb-8ed4-be9106b92082.png)

<br>

## **현재 상태**

![2021_0331_SwordEffect_2](https://user-images.githubusercontent.com/42164422/113040146-6eebb480-91d3-11eb-8778-00d17f46305e.gif)

<br>

# 4. Aura 이펙트
---

[Enhancement Effect] 게임오브젝트를 우클릭하고, [Effects] - [Particle System]을 클릭하여 새로운 파티클 시스템 게임오브젝트를 자식으로 추가한다.

그리고 해당 게임오브젝트의 이름을 [Aura]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/113040280-96428180-91d3-11eb-9df4-f3f404203473.png)

파티클 시스템에 `Additive_Sparkle` 마테리얼을 적용한다.

<br>

## **메인 모듈**

- `Start Lifetime` - [Random Between Two Constants] : (3, 5)

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (0.1, 0.3)

- `Start Color` : A 값을 0으로 지정하여 파티클이 아예 보이지 않도록 한다.

<br>

## **Emission 모듈**

- `Rate over Lifetime` : 48

<br>

## **Shape 모듈**

- `Radius` : 0.3

- `Position` : (0, -0.1, 0)

- `Rotaion` : (90, 0, 0)

<br>

다른 검 모델링을 사용할 경우, Circle 형태의 Shape가 손잡이 중간 ~ 위쪽을 감싸도록 `Shape` 내의 프로퍼티를 적절히 설정한다.

![image](https://user-images.githubusercontent.com/42164422/113041098-837c7c80-91d4-11eb-8ba2-674415feef5a.png)

<br>

## **Velocity over Lifetime 모듈**

- `Linear` - [Random Between Two Constants] : (0, 0.5, 0) ~ (0, 1, 0)

- `Orbital` - [Random Between Two Constants] : (0, 1, 0) ~ (0, 3, 0)

- `Radial` - [Random Between Two Constants] : 0 ~ -0.5

![image](https://user-images.githubusercontent.com/42164422/113041348-d22a1680-91d4-11eb-95cd-f986527450d5.png)

<br>

## **Trails 모듈**

- `Inherit Particle Color` : 체크 해제

- `Color over Lifetime` - [Gradient] - 알파값이 0 ~ 255 ~ 0으로 변화하도록 지정

![image](https://user-images.githubusercontent.com/42164422/113041658-2a611880-91d5-11eb-9498-811deaa64dfb.png)

- `Color over Trail` - [Gradient] - 원하는 색상 지정

<br>

# 5. 결과
---

![2021_0331_SwordEffect_3](https://user-images.githubusercontent.com/42164422/113042543-4b763900-91d6-11eb-89d0-b22a97fa383a.gif)

