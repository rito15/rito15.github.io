---
title: 파티클 시스템 예제 - 09 - Rainfall
author: Rito15
date: 2021-03-23 17:10:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [씬 준비](#씬-준비)
- [1. Rainfall 이펙트](#1-rainfall-이펙트)
- [2. Splash 이펙트](#2-splash-이펙트)
- [3. Ripple 이펙트](#3-ripple-이펙트)
- [4. 결과](#4-결과)

<br>

# Preview
---

## [1]

![2021_0322_Rainfall](https://user-images.githubusercontent.com/42164422/112285843-15185580-8cce-11eb-9227-1e635e43a01c.gif)

## [2]

![](https://user-images.githubusercontent.com/42164422/112008564-f0ef3400-8b68-11eb-9bb9-8239bb7a9fa6.gif)

<br>

# 목표
---

- 비내리는 이펙트 만들기

- 빗줄기가 바닥에 충돌했을 때 물 튀기는 이펙트, 파문이 번져나가는 이펙트 만들기

<br>

# 준비물
---

[Rainfall_Resources.zip](https://github.com/rito15/Images/files/6195731/Rainfall_Resources.zip)

<br>

- 빗줄기에 사용할 Droplet 텍스쳐
  - 좌우 크기를 많이 줄여서 길쭉하게 사용하기 때문에 무엇이든 상관 없다.
  - 기본값인 Default-Particle System도 가능 

<br>

- 퍼져나가는 잔물결(파문)을 표현할 Ripple 또는 원형의 텍스쳐
  - 마찬가지로 기본값인 Default-Particle System도 가능 

<br>

- 빗줄기가 충돌할 Plane 게임오브젝트

<br>

# 씬 준비
---

이펙트를 뚜렷하게 확인할 수 있도록, 씬을 최대한 어둡게 세팅한다.

<br>

- Main Camera
  - 트랜스폼 : Position(0, 1, -10), Rotation(0, 0, 0)
  - Camera 컴포넌트
    - `Clear Flags` : Solid Color
    - `Backgorund` : 검정색 

<br>

- Plane
  - 하이라키 우클릭 - 3D Object - Plane
  - 트랜스폼 : Position(0, -3, 0), Rotation(0, 0, 0), Scale(4, 1, 2) 

<br>

- Plane에 적용할 마테리얼
  - [Project] 창에서 우클릭 - Create - Material
  - Albedo의 색상을 검정색으로 변경
  - 마테리얼을 하이라키에 있는 Plane에 드래그 앤 드롭하여 적용 

<br>

- 라이팅 변경사항 적용
  - 화면 좌측 상단의 [Window] - [Rendering] - [Lighting Settings] 클릭하여 [Lighting] 창 열기
  - [Lighting] 창의 우측 하단 [Generate Lighting] 클릭

<br>

# 1. Rainfall 이펙트
---

생성되는 파티클의 X축 스케일을 최대한 줄이고 Y축 스케일을 길게 늘여 빗줄기처럼 보이게 하며,

콜라이더와 충돌할 경우 파괴시키고 서브이미터를 생성하는 것이 핵심이다.

<br>

파티클 시스템 게임오브젝트를 생성했으면, 트랜스폼의 우측 상단 `...`을 누르고 [Reset]을 클릭한다.

그리고 Position의 Y 값을 10으로 지정한다.

<br>

## 메인 모듈

- `Start Lifetime` : 빗줄기가 목표에 닿을 만큼 넉넉히 지정한다. (예 : 2)

- `Start Speed` : 0

- `3D Start Size` : 체크, [Random Between Two Constants] 설정
  - X : 0.05 ~ 0.1
  - Y : 1 ~ 5
  - Z : 1

![image](https://user-images.githubusercontent.com/42164422/112277548-388ad280-8cc5-11eb-8098-d2e1bca0a53e.png)

- `Gravity Modifier` - [Random Between Two Constants] : (3, 5)

- `Simulation Space` : World

<br>

## Emission 모듈

- `Rate over Time` : 표현하고 싶은 강우량에 따라 다르게 설정한다. (예시 - 폭우 : 512)

<br>

## Shape 모듈

- `Shape` : Box

- `Scale` : X, Z축으로 충분히 넓은 범위
  - 예 : (20, 1, 10)
  - 주의사항 : 트랜스폼의 Rotation이 (0, 0, 0)이어야 한다.

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 255 ~ 0으로 변화하도록 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Collision 모듈

- `Type` : Plane으로 설정하여 부딪힐 대상을 직접 등록하거나, World로 설정한다.

- `Lifetime Loss` : 1
  - 충돌체와 부딪힌 파티클은 즉시 모든 수명을 잃고 파괴된다.

- `Radius Scale` : 0.1

- `Visualize Bounds`
  - 각각의 파티클에 존재하는 충돌체를 씬뷰에서 기즈모로 보여준다.
  - 에디터에서의 성능을 많이 소모하므로, 디버깅을 원하는 것이 아니라면 평소에는 체크 해제한다.

<br>

## Renderer 모듈

- `Render Mode` : Stretched Billboard
  - 파티클이 길쭉하게 늘어진 형태로 보이게 한다.

<br>

## 현재 상태

- 씬 뷰

![image](https://user-images.githubusercontent.com/42164422/112280511-6de4ef80-8cc8-11eb-97c9-84141ea5f90e.png)

- 게임 뷰

![image](https://user-images.githubusercontent.com/42164422/112280541-750bfd80-8cc8-11eb-99da-d0c1021df2cd.png)

<br>

# 2. Splash 이펙트
---

## 서브 이미터 설정
 - Rainfall 파티클 시스템의 `Sub Emitters` 모듈을 체크한다.
 - `Birth`를 `Collision`으로 변경하고, 우측의 작은 `+`를 눌러 서브이미터를 생성한다.
 - 생성된 [SubEmitter0] 게임오브젝트의 이름을 [Splash]로 변경한다.
 - Rainfall 파티클 시스템과 동일한 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` - [Random Between Two Constants] : (0.1, 0.3)

- `Start Speed` - [Random Between Two Constants] : (0.1, 3)

- `Start Size` - [Random Between Two Constants] : (0.01, 0.03)

- `Start Color` : A 값을 0으로 설정하여, 아예 보이지 않게 한다.

- `Gravity Modifier` - [Random Between Two Constants] : (0, 1)

- `Simulation Space` : World

- `Max Particles` : 3000

<br>

## Emission 모듈

- `Rate over Time` : 0

- `Bursts` :

![image](https://user-images.githubusercontent.com/42164422/112282712-b0a7c700-8cca-11eb-8e96-b4c3610dcc00.png)

<br>

## Shape 모듈

- `Shape` : Hemisphere

<br>

## Trails 모듈

- `Inherit Particle Color` : 체크 해제
  - 메인 모듈에서 Start Color의 투명도를 0으로 하여 파티클의 입자를 보이지 않게 하고,<br>
    Trail에서는 파티클 메인 모듈의 색상의 영향을 받지 않도록 하여<br>
    결국 파티클에서 Trail만 보이도록 설정하게 된다.

<br>

## 현재 상태

![2021_0322_Heavy Rain_Splash](https://user-images.githubusercontent.com/42164422/112283805-ded9d680-8ccb-11eb-806a-10c6255aedc8.gif)

- 주의사항 : 플레이모드에 진입해야 Splash 이펙트를 제대로 확인할 수 있다.

<br>

# 3. Ripple 이펙트
---

## 서브 이미터 설정
 - Rainfall 파티클 시스템의 `Sub Emitters` 모듈
 - 우측 하단의 `+ -`에서 `+`를 눌러 서브이미터 슬롯을 하나 더 생성한다.
 - `Collision`으로 설정된 것을 확인하고, 우측의 작은 `+`를 눌러 서브이미터를 생성한다.
 - 생성된 [SubEmitter1] 게임오브젝트의 이름을 [Ripple]로 변경한다.
 - 잔물결로 설정할 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` - [Random Between Two Constants] : (0.5, 1)

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (1, 10)

- `Start Color` : A 값을 0.015로 변경

- `Simulation Space` : World

<br>

## Emisison 모듈

- `Rate over Time` : 0

- `Bursts` : Count를 30에서 1로 변경한다.

<br>

## Shape 모듈

- Shape 모듈을 체크 해제한다.

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 255 ~ 0으로 변화하도록 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Size over Lifetime 모듈

- 체크하고, Size가 0부터 1까지 증가하는 그래프 그대로 놔둔다.

<br>

## Renderer 모듈

- `Render Mode` : Horizontal Billboard

<br>

## 4. 결과
---

## [1] Emission : 32

![2021_0322_Rainfall](https://user-images.githubusercontent.com/42164422/112285843-15185580-8cce-11eb-9227-1e635e43a01c.gif)

## [2] Emission : 512

![](https://user-images.githubusercontent.com/42164422/112008564-f0ef3400-8b68-11eb-9bb9-8239bb7a9fa6.gif)


