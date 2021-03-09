---
title: 파티클 시스템 예제 - 03 - Firefly
author: Rito15
date: 2021-03-01 22:57:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# Preview
---

![2021_0301_Firefly_Completed](https://user-images.githubusercontent.com/42164422/109513377-5f038680-7ae8-11eb-9ccd-047b13ba6f16.gif)

<br>

# 목표
---

- Light 모듈, Collision 모듈 간단히 사용해보고 이해하기

- 반딧불이 이펙트 만들기

<br>

# Firefly Effect
---

## 마테리얼 준비

- Addtive

- 작은 Glow 모양의 텍스쳐

![image](https://user-images.githubusercontent.com/42164422/109507715-5c059780-7ae2-11eb-817c-01c438f6ce0d.png)

<br>

## 씬 준비

- 새로운 씬 생성 (Project 우클릭 - Create - Scene)

<br>

## 메인 카메라(Main Camera) 설정

- Clear Flags : `Solid Color`

![image](https://user-images.githubusercontent.com/42164422/109507329-f74a3d00-7ae1-11eb-8ae8-1c6619f1cb07.png)

- Background : 검정(RGBA 0, 0, 0, 0)으로 설정

![image](https://user-images.githubusercontent.com/42164422/109507460-1ea10a00-7ae2-11eb-813f-d455aecc4582.png)

<br>

## 파티클 시스템 생성

- 하이라키 우클릭 - Effects - Particle System

- 인스펙터 Transform 우측 상단 `...` - `Reset`
  - Position이 (0, 0, 0)으로 설정되어야 한다.

- 미리 준비한 마테리얼을 파티클 시스템에 적용한다.

- 현재 상태 :

![2021_0301_Firefly_Prepare01](https://user-images.githubusercontent.com/42164422/109508072-c7e80000-7ae2-11eb-966c-facfb6883b75.gif)

<br>

## 메인 모듈

- `Start Speed` - [Random Between Two Constants] : (0.1, 0.5)

- `Start Size` - [Random Between Two Constants] : (0.5, 3)

- `Start Color` : 원하는 색상을 설정한다.

- 예제에서는 [Random Color] 사용

![image](https://user-images.githubusercontent.com/42164422/109508322-17c6c700-7ae3-11eb-9493-0d37bf51ca47.png)

<br>

## Shape 모듈

- `Shape` : Box
- `Scale` : (15, 5, 5)
- `Randomize Direction` : 1

<br>

## Color over Lifetime 모듈

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Size over Lifetime 모듈

![2021_0301_Firefly_Prepare02_SizeOverLifetime](https://user-images.githubusercontent.com/42164422/109509302-177afb80-7ae4-11eb-8f6e-37ee31ff545b.gif)

<br>

- 현재 상태 :

![2021_0301_Firefly_Prepare03](https://user-images.githubusercontent.com/42164422/109509306-18ac2880-7ae4-11eb-9c54-94eaa490b6ba.gif)

<br>

## Plane 준비

- Project 우클릭 - Create - Material 
  - 이름은 "Black"이라고 지정한다.

- 생성한 마테리얼을 클릭하고, 인스펙터에서 Albedo 색상을 검정색으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/109510081-eea73600-7ae4-11eb-85d2-ca5ce3dbad13.png)

<br>

- 하이라키 우클릭 - 3D Object - Plane을 2개 생성한다.

- 첫 번째 Plane을 클릭하고 인스펙터의 Transform에서 Position (0, -2, 0), Scale (2, 1, 1)로 설정한다.

- 두 번째 Plane은 Position (0, 2, 3), Rotation (-90, 0, 0), Scale (2, 1, 1)로 설정한다.

- Black 마테리얼을 드래그하여 두 Plane에 모두 적용한다.

<br>

- 추가 : 하이라키의 Directional Light를 클릭하고 인스펙터 상단에서 체크 해제하거나, 아예 제거한다.

<br>

## Light 준비

- 하이라키의 파티클 시스템을 우클릭하고 [Light] - [Point Light]를 생성한다.

- 생성된 Point Light를 좌클릭하고 인스펙터 상단에서 체크 해제한다.

- 파티클 시스템의 하단부 Lights 모듈을 체크한다.

- `Light`에 방금 생성한 Point Light를 드래그한다.

- `Ratio`를 1로 지정한다.

- `Range Multiplier`를 5로 지정한다.

- `Intensity Multiplier`를 0.5로 지정한다.

![2021_0301_Firefly_Prepare05_Light](https://user-images.githubusercontent.com/42164422/109511829-cddfe000-7ae6-11eb-89ee-61f46b57b16b.gif)

- 이제 생성되는 파티클들에 무작위로 포인트 라이트가 적용되어, 주변의 오브젝트를 비추게 된다.

<br>

## Collision 모듈

- Collision 모듈에 체크하고, Planes에 하이라키에 존재하는 두 Plane을 모두 등록한다.

![2021_0301_Firefly_Prepare06_Collision](https://user-images.githubusercontent.com/42164422/109512446-72fab880-7ae7-11eb-87d4-e7e4f55e147c.gif)

- 이제 파티클들은 Plane에 닿을 때 더이상 관통하지 않고, 튕겨 나가게 된다.

<br>

## 결과

![2021_0301_Firefly_Completed](https://user-images.githubusercontent.com/42164422/109513377-5f038680-7ae8-11eb-9ccd-047b13ba6f16.gif)