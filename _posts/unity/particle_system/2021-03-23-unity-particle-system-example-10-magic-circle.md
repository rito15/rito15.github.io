---
title: 파티클 시스템 예제 - 10 - Magic Circle
author: Rito15
date: 2021-03-23 17:12:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. Magic Circle 이펙트](#1-magic-circle-이펙트)
- [2. Circle Loop 이펙트](#2-circle-loop-이펙트)
- [3. Dust 이펙트](#3-dust-이펙트)
- [4. Burn 이펙트](#4-burn-이펙트)
- [5. 다양한 연출 효과](#5-다양한-연출-효과)

<br>

# Preview
---

![2021_0322_Magic Circle_Short2](https://user-images.githubusercontent.com/42164422/112114689-b1255c80-8bfb-11eb-8067-c9ce6e589418.gif)

![2021_0322_Magic Circle_Short](https://user-images.githubusercontent.com/42164422/112008554-ef257080-8b68-11eb-994e-d16639868103.gif)

<br>

# 목표
---

- 예쁜 마법진 이펙트 만들기
- Trail 활용하기
- Duration, Delay 활용하여 다양한 연출 효과 만들기

<br>

# 준비물
---
[MagicCircle_Resources.zip](https://github.com/rito15/Images/files/6197395/MagicCircle_Resources.zip)

- 텍스쳐 : 마법진, Point, Trail

- Trail 텍스쳐는 다양한 텍스쳐들을 사용하여 서로 다른 효과를 낼 수 있다.
  - Default-Particle System도 가능하다.

<br>

# 1. Magic Circle 이펙트
---

## 빈 파티클 시스템 오브젝트 생성

- 파티클 시스템 오브젝트를 하나 생성한다.

- 트랜스폼의 우측 상단 `...`을 누르고 [Reset]을 클릭한다.

- Emission, Shape, Renderer 모듈을 모두 체크 해제한다.

- 이렇게 비어있는 형태의 파티클 시스템 게임오브젝트는 다른 파티클 시스템들의 부모로서 묶어주는 역할을 한다.

- 게임오브젝트의 이름을 [Magic Circle Effect]로 변경한다.

<br>

## 생성

- 위에서 생성한 [Magic Circle Effect] 게임오브젝트를 우클릭하고, [Effects] - [Particle System]을 통해 첫 번째 자식 파티클 시스템을 생성한다.

- 게임오브젝트의 이름을 [Magic Circle]로 변경한다.

- 마법진 텍스쳐가 적용된 Additive 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` : 10

- `Start Speed` : 0

- `Start Size` : 10

- `Start Color` : 원하는 색상 설정(단색)

<br>

## Emission 모듈

- `Rate over Time` : 0

- `Bursts`
  - 우측 하단의 `+`를 눌러 버스트 하나를 추가한다.
  - Count를 2로 설정한다.

<br>

## Shape 모듈

- Shape 모듈을 체크 해제한다.

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 255 ~ 0으로 변화하도록 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Renderer 모듈

- `Render Mode` : Horizontal Billboard

- `Max Particle Size` : 2
  - 기본 값은 0.5로, 파티클은 화면의 크기에 비례하여 50%가 넘도록 커지지 못하게 제한되어 있다.
  - 넉넉히 2로 설정하여, 카메라가 가까이 가도 파티클이 정상적으로 확대되도록 한다.

<br>

## 현재 상태

![2021_0324_MagicCircle_01](https://user-images.githubusercontent.com/42164422/112316109-25402d00-8cee-11eb-99a6-2a979c435e6f.gif)

<br>

# 2. Circle Loop 이펙트
---

## 생성

- [Magic Circle Effect] 게임오브젝트를 우클릭하고 파티클 시스템 오브젝트를 생성한다.

- 이름을 [Circle Loop]로 변경한다.

- Point(동그란 형태) 텍스쳐를 사용하는 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` : 1

- `Start Speed` : 0

- `Start Size` ; 0.5

- `Start Color` : 단색 적용(마법진 색상과 유사하게)

<br>

## Emission 모듈

- `Rate over Time` : 64

<br>

## Shape 모듈

- `Shape` : Circle

- `Radius` : 3.2

- `Radius Thickness` : 0

- `Arc`
  - `Mode` : Loop
  - `Spread` : 0
  - `Speed` : -0.5

- `Rotation` : (90, 0, 0)

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 255 ~ 0으로 변화하도록 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Size over Lifetime 모듈

- 모듈에 체크하고, 따로 수정하지 않는다. (점차 커지도록)

<br>

## 게임오브젝트 복제

- 하이라키에서 [Circle Loop] 오브젝트를 선택하고, [Ctrl + D] 키를 눌러 복제한다.

- 복제된 게임오브젝트를 선택하고, `Shape` 모듈의 `Rotation Y` 값을 180으로 수정한다.

<br>

## 현재 상태

![2021_0324_MagicCircle_02](https://user-images.githubusercontent.com/42164422/112324587-50c71580-8cf6-11eb-8ba3-0a27a1f6f100.gif)

<br>

# 3. Dust 이펙트
---

## 생성

- 위와 동일한 방식으로 파티클 시스템 게임오브젝트를 생성하고 이름을 [Dust]로 변경한다.

- Point 마테리얼을 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` - [Random Between Two Constants] : (3, 4)

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (0.2, 0.5)

- `Start Color` : 원하는 색상 지정

- `Gravity Modifier` - [Random Between Two Constants] : (-0.1, -0.2)

<br>

## Emission 모듈

- `Rate over Time` : 24

<br>

## Shape 모듈

- `Shape` : Circle

- `Radius` : 2.4

- `Rotation` : (90, 0, 0)

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 255 ~ 0으로 변화하도록 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Size over Lifetime 모듈

- `Size`
  - 좌상단에서 우하단으로 하강하는 그래프를 선택한다.

![image](https://user-images.githubusercontent.com/42164422/112325484-114cf900-8cf7-11eb-9a68-fd0c4731deaa.png)

<br>

## 현재 상태

![2021_0324_MagicCircle_03](https://user-images.githubusercontent.com/42164422/112325974-79034400-8cf7-11eb-86e8-88bc88c0de57.gif)

<br>

# 4. Burn 이펙트
---

## 생성

- 위와 동일한 방식으로 파티클 시스템 게임오브젝트를 생성하고 이름을 [Burn]으로 변경한다.

- Trail 마테리얼을 적용한다. (다양한 텍스쳐를 넣어서 활용해볼 수 있다.)

<br>

## 메인 모듈

- `Start Lifetime` : 2

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (0.1, 1)

- `Start Color` : A 값을 0으로 지정한다.
  (파티클의 색상이 아예 보이지 않도록)

- `Gravity Modifier` - [Random Between Two Constants` : (-0.1, -0.7)

<br>

## Emission 모듈

- `Rate over Time` : 192

<br>

## Shape 모듈

- `Shape` : Circle

- `Radius` : 3.6

- `Radius Thickness` : 0

- `Rotation` : (90, 0, 0)

<br>

## Velocity over Lifetime 모듈

- `Orbital` : (0, 1, 0)

- `Radial` : -1

<br>

## Trails 모듈

- `Inherite Particle Color` : 체크 해제
  - 트레일이 파티클의 색상에 영향받지 않도록 한다.
  - 따라서 파티클은 알파 값이 0이므로 아예 보이지 않고, 트레일만 보이게 된다.

- `Color over Lifetime`
  - [Gradient]
  - 알파 값이 0 ~ 255 ~ 0 으로 변화하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/112327186-8e2ca280-8cf8-11eb-8d27-163d3a897ba7.png)

- `Color over Trail` 
  - 원하는 색상을 지정한다.
  - 이펙트가 너무 밝을 경우 알파 값을 낮춘다. (예제에서는 0.5)

<br>

## 현재 상태

![2021_0324_MagicCircle_04](https://user-images.githubusercontent.com/42164422/112328340-96391200-8cf9-11eb-9b90-559371aa9673.gif)

<br>

# 5. 다양한 연출 효과
---

## [1] 딜레이를 이용한 연출

각 파티클 시스템마다 서로 다른 딜레이를 적용하여, 다양한 연출 효과를 줄 수 있다.

- [Ctrl] 키를 누른 채로 [Magic Circle], [Dust], [Burn] 게임오브젝트를 선택한다.

- 선택된 오브젝트들의 `Start Delay`를 1로 지정한다.

![2021_0322_Magic Circle_Short2](https://user-images.githubusercontent.com/42164422/112114689-b1255c80-8bfb-11eb-8067-c9ce6e589418.gif)

<br>

## [2] Duration을 이용한 연출

마법진이 영원히 지속되지 않고, 일정 시간이 지나면 순차적으로 사라지도록 한다.

- [Magic Circle], [Circle Loop] 2개, [Dust], [Burn]을 모두 선택하고 `Looping`을 체크 해제한다.

- [Circle Loop] 2개 이펙트를 모두 선택하고 `Duration`을 9로 지정한다.

- [Dust] 이펙트의 `Duration`을 6으로 지정한다.

- [Burn] 이펙트의 `Duration`을 7로 지정한다.

![2021_0322_Magic Circle_Short](https://user-images.githubusercontent.com/42164422/112008554-ef257080-8b68-11eb-994e-d16639868103.gif)

<br>

이처럼, 생성되는 타이밍(Delay), 지속시간(Duration)을 조절하여 다양한 연출을 꾸며볼 수 있다.




