---
title: 파티클 시스템 기초 - 05 - 주요 모듈
author: Rito15
date: 2021-02-22 22:00:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [1. Emission](#emission)
- [2. Shape](#shape)
- [3. Velocity over Lifetime](#velocity-over-lifetime)
- [4. Color over Lifetime](#color-over-lifetime)
- [5. Size over Lifetime](#size-over-lifetime)
- [6. Rotation over Lifetime](#rotation-over-lifetime)
- [References](#references)

<br>

# 개요
---

- 메인 모듈 외의 모듈 중에서 주로 사용되는 모듈들에 대해 소개한다.

<br>

# Emission
---

![image](https://user-images.githubusercontent.com/42164422/108713067-0b7ac100-755b-11eb-835f-66a0cd19e073.png)

- 파티클의 생성 타이밍과 개수에 관여한다.

<br>

## Rate over Time

- 초당 생성할 개수를 지정한다.

- 예시 : [1] vs [4]

![2021_0222_Particle_RateOverTime_1_4](https://user-images.githubusercontent.com/42164422/108713361-76c49300-755b-11eb-9fba-3d2ef398f242.gif){:.normal}

<br>

## Rate over Distance

- 게임오브젝트의 이동거리 당 생성할 파티클의 개수를 지정한다. (거리 1 단위)

- 1로 지정할 경우 거리 1을 이동할 때마다 1개, 2로 지정할 경우 거리 0.5를 이동할 때마다 1개를 생성한다.

- 예시 : [1] vs [2]

![2021_0222_Particle_RateOverDist_1_2](https://user-images.githubusercontent.com/42164422/108713862-2568d380-755c-11eb-9319-7500188840fb.gif){:.normal}

<br>

## Bursts

- 버스트의 목록을 만들어, 각 버스트마다 파티클을 생성할 정확한 타이밍과 개수, 반복 횟수 등을 지정한다.

- 각 버스트는 독립적으로 실행되며, 버스트의 반복(Cycle)으로 인해 특정 타이밍에 실행되는 버스트가 여러 개일 경우 생성되는 파티클 개수는 합산된다.

- `+`를 눌러 버스트를 생성하고, `-`를 눌러 버스트를 제거할 수 있다.

- Duration으로 지정한 시간 내에서만 버스트를 등록할 수 있다. (벗어날 경우 무시)

|이름|설명|
|---|---|
|`Time`|버스트가 실행될 타이밍.<br>Duration 내에서만 지정할 수 있다.|
|`Count`|버스트가 실행될 때 생성할 파티클 개수|
|`Cycles`|버스트를 반복할 횟수.|
|`Interval`|하나의 버스트 내에서 각 Cycle 사이의 간격을 의미한다.<br>Cycle이 1인 경우에는 의미가 없다.|
|`Probability`|해당 버스트를 실행할 확률.<br>(0 : 0% ~ 1 : 100%)|

<br>

- 예시 (Duration : 5)

![image](https://user-images.githubusercontent.com/42164422/108718450-c4dc9500-7561-11eb-8b9a-7d5dfb47cff0.png){:.normal}

|타이밍(초)|생성 파티클 개수|
|---|---|
|0.0|1개 [`Burst 0`]|
|0.5|0개|
|1.0|2개 [`Burst 1`]|
|1.5|0개|
|2.0|5개 (2 + 3) [`Burst 1`, `Burst 2`]|
|2.5|3개 [`Burst 2`]|
|3.0|3개 [`Burst 2`]|
|3.5|3개 [`Burst 2`]|
|4.0|3개 [`Burst 2`]|
|4.5|0개|

![2021_0222_Particle_Bursts](https://user-images.githubusercontent.com/42164422/108719502-fb66df80-7562-11eb-8cf4-5aecd6277ac7.gif){:.normal}

<br>

## 추가 설명
  - Rate over Time, Rate over Distance, Bursts는 각각 독립적으로 실행된다.
  - 따라서 서로 영향을 주지 않고 개별적으로 실행되어, 최종적으로 생성되는 개수는 합산된다.

<br>

# Shape
---

![image](https://user-images.githubusercontent.com/42164422/108750808-d5eacd80-7584-11eb-9b2f-5ea0373c253b.png)

- 파티클들이 생성될 영역의 모양과 크기를 결정한다.

- 파티클 시스템을 생성할 경우 초깃값은 Cone이며, 주로 Sphere, Box 등이 사용된다.

<br>

## **Cone**

- 원뿔 모양

<br>

## Angle
 - 원뿔의 벌어진 각도(작을수록 원통에 가깝다)

![image](https://user-images.githubusercontent.com/42164422/108739281-d4ff6f00-7577-11eb-8f2f-3b1abd6ad27a.png)

<center>Angle [0] vs[45]</center>

<br>

## Radius
 - 원뿔의 반지름

![image](https://user-images.githubusercontent.com/42164422/108739461-0415e080-7578-11eb-8f11-759fc9c424aa.png)
<center>Radius [0] vs [1]</center>

<br>

## Radius Thickness
 - 원뿔 내에서 파티클이 실제로 생성될 영역의 두께 (0 ~ 1)

![2021_0222_Particle_Con_RadiusThickness](https://user-images.githubusercontent.com/42164422/108740194-c2d20080-7578-11eb-996e-06862b556ebe.gif)
<center>Radius Thickness [0.1] vs [0.9]</center>

<br>

## Arc
 - 파티클이 생성될 영역의 각도 범위(0 ~ 360)

![2021_0222_Particle_Cone_Arc](https://user-images.githubusercontent.com/42164422/108740449-07f63280-7579-11eb-83cb-6961b5d6552b.gif)
<center>Arc [90] vs [360]</center>

<br>

## Mode
  - 파티클이 생성될 방법 정의
  - Random : 생성 영역 내에서 무작위
  - Loop : 원호를 순서대로 돌며 생성
  - Ping-Pong : Loop와 유사하지만, 한 번의 루프가 끝날 때마다 순회 방향 변경
  - Burst Spread : 넓게 흩뿌리며 생성

![2021_0222_Particle_Cone_Mode](https://user-images.githubusercontent.com/42164422/108741545-2f013400-757a-11eb-8340-324fbe716c1c.gif)
<center>Mode [Random] vs [Loop] vs [Ping-Pong]</center>

<br>

## Spread
  - 파티클의 분포 지정(0 ~ 1)

  - 0을 지정할 경우 모든 지점에서 파티클 생성
  - 0.1을 지정할 경우 10% 구간씩 총 열 군데에서만 파티클 생성
  - 0.5를 지정할 경우 두 군데에서만 파티클 생성

![2021_0222_Particle_Cone_Spread](https://user-images.githubusercontent.com/42164422/108742954-a5526600-757b-11eb-85bc-88a747c8da8d.gif)
<center>Spread [0] vs [0.33] vs [0.5]</center>

<br>

## Speed
 - 원호 순회 속도 지정(0 ~ )

![2021_0222_Particle_Cone_Speed_01_05_10gif](https://user-images.githubusercontent.com/42164422/108742966-a71c2980-757b-11eb-8e51-0092eadac9dd.gif)
<center>Speed [0.1] vs [0.5] vs [1.0]</center>

<br>

## Emit from
  - 파티클 생성 위치 지정

  - Base : 원뿔의 입구(좁은 부분)에서만 생성
  - Volume : 원뿔의 모든 부분에서 생성

![2021_0222_Particle_Cone_EmitFrom](https://user-images.githubusercontent.com/42164422/108744454-4b52a000-757d-11eb-8409-adf86a0f6ac8.gif)
<center>Emit from [Base] vs [Volume]</center>

<br>

## Length 
 - 원뿔의 높이 지정
 - Emit from [Volume]일 때만 지정 가능


<br>

## Texture 
 - 파티클 생성 영역을 텍스쳐의 RGBA 채널 중 하나를 통해 마스킹

<br>

## Position, Rotation, Scale 
 - 원뿔의 위치, 회전, 크기 지정

<br>

## Align To Direction
 - 생성되는 파티클이 이동 방향을 바라보도록 설정

![2021_0222_Particle_Cone_AlignToDirection](https://user-images.githubusercontent.com/42164422/108744426-42fa6500-757d-11eb-9188-1f4996d89633.gif)
<center>Align To Direction [False] vs [True]</center>

<br>

## Randomize Direction
 - 파티클 진행방향 무작위화 정도 설정(0 ~ 1)

![2021_0222_Particle_Cone_RandomizeDirection_0_1](https://user-images.githubusercontent.com/42164422/108744621-7dfc9880-757d-11eb-8631-d019e5c839c0.gif)
<center>Randomize Direction [0] vs [1]</center>

<br>

## Spherize Direction
 - 파티클 진행방향이 구체에 가깝도록 설정(0 ~ 1)

![2021_0222_Particle_Cone_SpherizeDirection_0_05_1](https://user-images.githubusercontent.com/42164422/108745075-05e2a280-757e-11eb-92a7-d15ff08a1836.gif)
<center>Spherize Direction [0] vs [0.5] vs [1]</center>

<br>

## Randomize Position
 -  파티클 생성 위치가 Shape 영역을 벗어나도록 설정 (0 ~ )

![2021_0222_Particle_Cone_RandomizePosition_0_3_8](https://user-images.githubusercontent.com/42164422/108745398-5eb23b00-757e-11eb-9b8f-a1f11ddf634f.gif)
<center>Randomize Position [0] vs [3] vs [8]</center>

<br>

## 기타 Shape 정보
  - <https://docs.unity3d.com/kr/2019.4/Manual/PartSysShapeModule.html>

<br>

# Velocity over Lifetime
---

![image](https://user-images.githubusercontent.com/42164422/108750872-e4d18000-7584-11eb-969e-2026fec6abbe.png)

- 파티클에 지정한 수명(Start Lifetime) 동안의 속도 변화를 지정한다.

- 값을 Constant로 지정할 경우 수명 동안 속도가 일정한 값으로 유지된다.

- 값을 Curve로 지정할 경우 수명 동안 시간의 흐름에 따른 속도를 지정한다.

- 값을 Random ~ 으로 지정할 경우 두 값 또는 두 커브 사이의 범위에서 무작위 속도값을 지정한다.

<br>

## Linear X, Y, Z
 -  X, Y, Z축 방향으로의 이동속도 각각 지정

![2021_0223_Particle_Velocity_Linear_0_Y2](https://user-images.githubusercontent.com/42164422/108748206-adad9f80-7581-11eb-8ec7-8d2c36f9c260.gif)
<center>Linear[0, 0, 0] vs [0, 2, 0]</center>

<br>

## Space
 - 기준이 될 공간 지정

 - Local : 트랜스폼의 회전(Rotation) 영향을 받는다.
 - World : 트랜스폼의 회전을 무시하고 절대적인 월드를 기준으로 한다.

<br>

## Orbital X, Y, Z 
 - X, Y, Z 축 회전속도 각각 지정

![2021_0223_Particle_Velocity_Orbital_0_Z2](https://user-images.githubusercontent.com/42164422/108748221-b0a89000-7581-11eb-9b25-4476fb48477f.gif)
<center>Orbital[0, 0, 0] vs [0, 0, 2]</center>

<br>

## Offset X, Y, Z 
 - 회전 궤도의 중심 좌표 지정
 - Orbital에 값을 지정한 경우에만 기능한다.

![2021_0223_Particle_Velocity_Offset_0_X1](https://user-images.githubusercontent.com/42164422/108748921-7f7c8f80-7582-11eb-8f11-1d1bba43cd56.gif)
<center>Orbital[0, 0, 1]</center>
<center>Offset[0, 0, 0] vs [1, 0, 0]</center>

<br>

## Radial
 - 원심력 지정
 - 값이 양수일 경우 바깥으로 퍼진다.
 - 값이 음수일 경우 안쪽으로 모인다.

![2021_0223_Particle_Velocity_Radial_-1_0_1](https://user-images.githubusercontent.com/42164422/108749336-0af62080-7583-11eb-9fe5-a089f1ac47ee.gif)
<center>Radial [-1] vs [0] vs [1]</center>

<br>

## Speed Modifier
 - 속력 배수 지정

<br>

# Color over Lifetime
---

![image](https://user-images.githubusercontent.com/42164422/108750937-f6b32300-7584-11eb-8fd8-67907c6f4eab.png)

- 파티클의 수명 동안 색상과 알파값의 변화를 그라디언트를 통해 지정한다.

- 가장 많이 사용하는 예시로, 파티클이 생성될 때 알파 값이 0, 수명의 절반 지점에서 255, 마지막 지점에서 0으로 설정하여 자연스럽게 Fade-in ~ Fade-out 형태가 되도록 설정할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108750053-e9496900-7583-11eb-94e8-67dfb3b766a3.png)

![2021_0223_Particle_ColorOverLifetime](https://user-images.githubusercontent.com/42164422/108749727-82c44b00-7583-11eb-93aa-cfa085b314e9.gif)
<center>Color over Lifetime [미지정] vs [지정(알파값 변화)]</center>

<br>

# Size over Lifetime
---

![image](https://user-images.githubusercontent.com/42164422/108751017-0f233d80-7585-11eb-8c0f-82b427e43021.png)

- 파티클의 수명 동안 크기의 변화를 지정한다.

<br>

## Separate Axes
 - 체크할 경우 X, Y, Z 크기를 각각 따로 지정할 수 있다.

<br>

## Size - Curve
 - 크기변화를 커브를 통해 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108751414-835de100-7585-11eb-83d1-526a995af832.png)

![2021_0223_Particle_SizeOverLifetime_1](https://user-images.githubusercontent.com/42164422/108751847-126af900-7586-11eb-85c4-c37375f255bf.gif)

<br>

## Size - Random Between Two Constants
 - 수명 주기 동안 변하지 않는 고정 크기 값을 두 값 사이의 무작위 값으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108751445-907ad000-7585-11eb-8e82-264bd4226dd1.png)

![2021_0223_Particle_SizeOverLifetime_2](https://user-images.githubusercontent.com/42164422/108751850-1434bc80-7586-11eb-8bfb-aba2cc370515.gif)

<br>

## Size - Random Between Two Curves
 - 크기 변화를 두 커브 사이의 무작위 값으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108751466-9b356500-7585-11eb-857f-4df90ca1f33a.png)

![2021_0223_Particle_SizeOverLifetime_3](https://user-images.githubusercontent.com/42164422/108751854-1565e980-7586-11eb-857f-e794333866d1.gif)

<br>

# Rotation over Lifetime
---

![image](https://user-images.githubusercontent.com/42164422/108751961-3a5a5c80-7586-11eb-9d34-5fef1a4897c5.png)

- 수명 동안 파티클의 회전값 변화를 지정한다.

<br>

## Separate Axes
 - 체크할 경우 X, Y, Z 회전값을 각각 지정할 수 있다.

<br>

## Angular Velocity - Constant
 - 수명 주기 동안 변하지 않는 고정 회전값을 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108752654-14818780-7587-11eb-9fdf-5dee6023341b.png)

![2021_0223_Particle_RotationOverLifetime_1](https://user-images.githubusercontent.com/42164422/108753043-95d91a00-7587-11eb-9d87-498e5a6d623e.gif)

<br>

## Angular Velocity - Curve
 - 수명에 따라 변화하는 회전값을 커브를 통해 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108752673-1a776880-7587-11eb-94be-086fccba1e08.png)

![2021_0223_Particle_RotationOverLifetime_2](https://user-images.githubusercontent.com/42164422/108753050-97a2dd80-7587-11eb-8a3d-0dabf0b68e5d.gif)

<br>

## Angular Velocity - Random Between Two Constants
 - 수명 주기 동안 변하지 않는 고정 회전값을 두 상수값의 사이에서 랜덤으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108752697-22cfa380-7587-11eb-8baf-c53eae2c7bb6.png)

![2021_0223_Particle_RotationOverLifetime_3](https://user-images.githubusercontent.com/42164422/108753056-98d40a80-7587-11eb-88e4-2ee468fff78b.gif)

<br>

## Angular Velocity - Random Between Two Curves
 - 수명에 따라 변화하는 회전값을 두 커브의 사이 범위값으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108752718-295e1b00-7587-11eb-8298-4ae57f2ecc5b.png)

![2021_0223_Particle_RotationOverLifetime_4](https://user-images.githubusercontent.com/42164422/108753058-9a053780-7587-11eb-97e7-9d98c464ada6.gif)

<br>

# References
---
- <https://docs.unity3d.com/kr/2019.4/Manual/ParticleSystemModules.html>