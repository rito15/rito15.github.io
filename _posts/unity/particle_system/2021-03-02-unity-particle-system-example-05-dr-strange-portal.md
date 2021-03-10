---
title: 파티클 시스템 예제 - 05 - Dr. Strange Portal
author: Rito15
date: 2021-03-03 03:33:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. 계층형 파티클 시스템](#1-계층형-파티클-시스템)
- [2. Portal 이펙트 만들기](#2-portal-이펙트-만들기)
- [3. Spiral A 이펙트 만들기](#3-spiral-a-이펙트-만들기)
- [4. Spiral B 이펙트 만들기](#4-spiral-b-이펙트-만들기)
- [5. Burst 이펙트 만들기](#5-burst-이펙트-만들기)
- [6. 완성](#6-완성)

<br>

# Preview
---

![2021_0309_drStrange_10](https://user-images.githubusercontent.com/42164422/110457627-2ed26e00-810e-11eb-9770-c5c5c9d7576c.gif)

<br>

# 목표
---

- 계층형 파티클 시스템 만들기

- 닥터 스트레인지 포탈 이펙트 완성하기

<br>

# 준비물
---

- 글로우 모양의 동그란 텍스쳐와 Additive 마테리얼

![image](https://user-images.githubusercontent.com/42164422/110457764-53c6e100-810e-11eb-87f9-6e260bc0b85c.png)

<br>

# 1. 계층형 파티클 시스템
---

지금까지는 이펙트 하나 당 파티클 시스템을 하나씩만 사용해서 제작했다.

하지만 대부분의 이펙트는 실제로 하나의 파티클 시스템으로 표현하기 어려운 경우가 많고,

여러 개의 파티클 시스템 게임오브젝트를 하나의 부모 게임오브젝트로 묶어서 계층형으로 제작한다.

<br>

## **계층 구조 만들기**

- 하이라키에서 우클릭 - [Create Empty]를 눌러 게임오브젝트 하나를 만든다.

- 트랜스폼의 우측 상단 `...`을 누르고, `Reset`을 클릭한다.

- 생성한 게임오브젝트를 우클릭하고 [Effects] - [Particle System]을 누른다.

- 다시 부모 게임오브젝트를 우클릭하고 [Effects] - [Particle System]을 눌러 자식으로 파티클 시스템을 하나 더 생성한다.

![image](https://user-images.githubusercontent.com/42164422/110439266-9a124500-80fa-11eb-8701-7a6ab97764b1.png)

- 하지만 이렇게 하면 두 자식 오브젝트의 파티클 시스템이 함께 재생되지 않는 것을 볼 수 있다.

<br>

## **파티클 시스템을 위한 계층구조 만들기**

- 따라서 파티클 시스템을 하나로 묶어서 함께 재생하려면, 부모 게임오브젝트 역시 파티클 시스템이어야 한다.

- 일단 위에서 생성한 3개의 게임오브젝트를 모두 지운다(Delete).

- 이 상태에서 하이라키 우클릭으로 파티클 시스템을 만든다.
  - 만들고 항상 트랜스폼을 리셋해준다.(필수)

- 생성한 파티클 시스템을 우클릭하여, 자식 파티클 시스템을 마찬가지로 두 개 만들어본다.

![image](https://user-images.githubusercontent.com/42164422/110439641-0bea8e80-80fb-11eb-87bd-0f9adf132b64.png)

- 이제는 파티클 시스템이 모두 연결되어 함께 재생되는 것을 확인할 수 있다.

<br>

## **부모 파티클 시스템 수정**

- 하지만 원래 원했던 것은, 빈 부모 오브젝트 아래에 여러 개의 파티클 시스템을 묶어 하나로 관리하는 것이다.

- 따라서 부모 게임오브젝트는 아무런 파티클도 생성하고 싶지 않지만, 부모 파티클 시스템도 자식들처럼 계속 파티클을 생성하고 있다.

- 이를 수정하기 위해, 부모 게임오브젝트를 선택한다.

- 인스펙터의 파티클 시스템 컴포넌트에서 `Emission`, `Shape`, `Renderer` 모듈을 모두 체크 해제한다.

![image](https://user-images.githubusercontent.com/42164422/110439955-76033380-80fb-11eb-8456-fcd375d6ad5b.png)

- 이제 더이상 부모 게임오브젝트는 파티클을 생성하지 않고, 자식 파티클 시스템들을 묶어주는 역할만 하게 된다.

<br>

# 2. Portal 이펙트 만들기
---

- 총 네 개로 이루어진 닥터 스트레인지 포탈의 파티클 시스템 중, 첫 번째를 만든다.

- 우선 부모 게임오브젝트의 이름을 [Doctor Strange Portal]로 바꿔준다.

- 그리고 첫 번째 자식의 이름을 [Portal]로 변경한다.

- 두 번째 자식 게임오브젝트는 Delete 키를 눌러 제거한다.

![image](https://user-images.githubusercontent.com/42164422/110445315-5111bf00-8101-11eb-8e9a-cea91a87029d.png)

<br>

## 메인 모듈 설정

- `Start Lifetime` - [Random Between Two Constants] : (0.2, 2)

- `Start Speed` : 0

- `Start Size` - [Random Between Two Constants] : (0.5, 1)

- `Start Color` - [Random Color]

![image](https://user-images.githubusercontent.com/42164422/110441004-a13a5280-80fc-11eb-9de7-d911c14feffc.png)

<br>

## Shape 모듈

- `Shape` : Circle

- `Radius` : 2

- `Radius Thickness` : 0

- `Arc` - `Mode` : Loop

<br>

![2021_0309_drStrange_01](https://user-images.githubusercontent.com/42164422/110442782-8537b080-80fe-11eb-8020-9262d3e4f627.gif)

Shape를 Circle로 설정하면 3차원 공간에서도 2차원의 원형 범위에서 파티클이 생성된다.


Radius Thickness는 원 내에서 파티클이 생성될 영역의 두께를 설정하는데, 기본 설정인 1로 두면 원 범위 전체에서 파티클을 생성하고

점차 감소시키면 도넛 형태의 범위에서 파티클을 생성하며, 0으로 두면 원의 테두리 부분에서만 파티클을 생성하게 된다.

<br>

Arc Mode를 Random으로 두면 생성 범위 내에서 무작위로 파티클이 생성되며, Loop로 설정하면 원의 테두리를 차근차근 순회하며 생성된다.

그리고 Loop을 때 파티클이 생성되는 지점들은 `Spread`, `Speed` 속성, Emission 모듈의 `Rate over Time` 속성의 영향을 받는다.

따라서 Emission 모듈의 `Rate over Time`을 임시로 64 정도로 높여두면 다음과 같은 모습을 확인할 수 있다.

![2021_0309_drStrange_02](https://user-images.githubusercontent.com/42164422/110443439-435b3a00-80ff-11eb-949b-f0e0e7af21a6.gif)

<br>

## Color over Lifetime 모듈

- 알파값이 0 ~ 1 ~ 0으로 변화하도록 다음처럼 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## Size over Lifetime 모듈

- 생성되는 파티클이 점차 작아지며 사라지도록, 다음처럼 설정한다.

![image](https://user-images.githubusercontent.com/42164422/110443732-97feb500-80ff-11eb-80a2-f594af73de9a.png)

<br>

## Velocity over Lifetime 모듈

- 일단 `Radial`에 2를 입력한다.

- `Radial`의 우측에 있는 화살표를 눌러 [Curve]로 바꾸고, 다음처럼 설정한다.
  - 하단의 프리셋 우측 두번째를 클릭하면 빠르게 설정할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/110444375-46a2f580-8100-11eb-8b17-1aa573394c52.png)

- `Orbital`의 Z 값을 -2로 설정한다.

<br>

Radial 속성은 생성된 파티클이 중심으로부터 멀어지는 속도를 지정한다.

커브를 통해 0부터 2까지 증가하도록 설정하였으므로, 파티클이 생성되는 순간에는 가만히 있다가 점차 중심으로부터 빠르게 멀어지게 된다.

Orbital 속성은 각 축(X, Y, Z)에 대한 회전 속도를 지정한다.

Z축 회전 속도를 지정하였으므로, 아래 그림에서 보이는 파란색 축(Z축) 을 기준축으로 하여 파티클이 회전하게 된다.

![image](https://user-images.githubusercontent.com/42164422/110444661-a4374200-8100-11eb-9120-78658850c12e.png)

<br>

- 현재 상태 :

![2021_0309_drStrange_03](https://user-images.githubusercontent.com/42164422/110444919-ec566480-8100-11eb-9d9d-580cb64cb24b.gif)

<br>

## Emission 모듈

- `Rate over Time` : 512

- 결과 :

![2021_0309_drStrange_04](https://user-images.githubusercontent.com/42164422/110445048-14de5e80-8101-11eb-8b99-10ffe37e2475.gif)

<br>

# 3. Spiral A 이펙트 만들기
---

- [Portal] 게임오브젝트를 클릭하고 [Ctrl + D]를 눌러 복제한 뒤, 이름을 [Spiral A]로 변경한다.

- [Portal] 게임오브젝트를 다시 클릭하고 인스펙터 좌측 상단의 체크박스를 클릭하거나, [Alt + Shift + A]를 눌러 잠시 게임오브젝트를 비활성화 해둔다.

![image](https://user-images.githubusercontent.com/42164422/110446190-40157d80-8102-11eb-9b04-a2d4d741eac0.png)

<br>

## 메인 모듈 수정

- `Start Delay` : 0.5

- `Start Lifetime` - [Random Between Two Constants] : (0.5, 1)

- `Start Size` - [Random Between Two Constants] : (0.2, 1)

- `Start Color` - [Random Color] : 노란색 ~ 좀 더 진한 주황색 정도로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/110445949-05abe080-8102-11eb-9cd3-8263769784e6.png)

<br>

Start Delay 0.5로 설정했으므로, 파티클 시스템이 재생될 때 0.5초가 지나고 시작하게 된다.

<br>

## Shape 모듈 수정

- `Arc` - `Speed` : 6

![2021_0309_drStrange_05](https://user-images.githubusercontent.com/42164422/110446767-e19ccf00-8102-11eb-9f09-f55dd8926616.gif)

<br>

## Trails 모듈

- 트레일 모듈을 그냥 체크만 해준다.

- 트레일 모듈이 활성화된 경우, 생성되는 모든 파티클은 잔상을 남기게 된다.

![2021_0309_drStrange_06](https://user-images.githubusercontent.com/42164422/110447045-2cb6e200-8103-11eb-81e0-994bddb9ce2a.gif)

- 위처럼 보이지 않고 이상하게 보이는 경우, Renderer 모듈을 열어서 `Trail Material`에 `Material`과 동일한 마테리얼이 등록되어 있는지 확인한다.

- 만약 등록되어 있지 않거나 다르다면, 동일한 마테리얼을 지정해준다.

![image](https://user-images.githubusercontent.com/42164422/110447387-84ede400-8103-11eb-989f-9f87f79f4160.png)

<br>

## Velocity over Lifetime 모듈

- `Orbital`의 Z 값을 -2에서 -4로 변경한다.

- `Radial`의 커브를 클릭하고, 하단의 커브 에디터를 클릭하여 연다.

- Radial의 Y축 값을 2에서 6으로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/110449829-f038b580-8105-11eb-96e2-1f43ada1d076.png)

<br>

## 결과

![2021_0309_drStrange_07](https://user-images.githubusercontent.com/42164422/110449949-0e9eb100-8106-11eb-9b15-7bcfc94cade7.gif)

<br>

# 4. Spiral B 이펙트 만들기
---

- [Spiral A] 게임오브젝트를 선택하고, [Ctrl + D]를 눌러 복제한다.

- 복제한 게임오브젝트의 이름을 [Spiral B]로 변경한다.

- [Spiral A] 게임오브젝트를 선택하고, 인스펙터 좌측 상단의 체크박스를 클릭하거나 [Alt + Shift + A]를 눌러 잠시 비활성화 해둔다.

![image](https://user-images.githubusercontent.com/42164422/110450428-88369f00-8106-11eb-8175-908f5037c678.png)

<br>

## 메인 모듈 수정

- `Start Delay` : 0.75

- `Start Lifetime` - [Random Between Two Constants] : (1, 1.2)

- `Start Color` - [Random Color] : Spiral A보다 약간 더 진하게, 주황색 ~ 갈색 정도로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/110450912-0004c980-8107-11eb-8c92-8b0428ae8b64.png)

<br>

## Emission 모듈 수정

- `Rate over Time` : 256

<br>

## Velocity over Lifetime 모듈 수정

- `Orbital` : Z값을 -8로 수정한다.

- `Radial`의 커브를 클릭하고, 하단의 커브 에디터를 클릭하여 연다.

- Radial의 Y축 값을 6에서 4로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/110451442-8caf8780-8107-11eb-87c8-51e3446ff997.png)

<br>

## 결과

![2021_0309_drStrange_08](https://user-images.githubusercontent.com/42164422/110451633-b9639f00-8107-11eb-9140-104e90337cf3.gif)

<br>

# 5. Burst 이펙트 만들기
---

- [Spiral B] 게임오브젝트를 선택하고, [Ctrl + D]를 눌러 복제한다.

- 복제한 게임오브젝트의 이름을 [Burst]로 변경한다.

- [Spiral B] 게임오브젝트를 선택하고, 인스펙터 좌측 상단의 체크박스를 클릭하거나 [Alt + Shift + A]를 눌러 잠시 비활성화 해둔다.

<br>

## 메인 모듈 수정

- `Looping` : 체크 해제한다.

- `Start Delay` : 1

- `Start Lifetime` - [Random Between Two Constants] : (0.5, 0.8)

- `Max Particles` : 4096

- `Stop Action` : Disable

<br>

Burst 이펙트는 다른 이펙트들과 달리, 파티클 시스템 재생 시 반복되는 것이 아니라 한 번만 반짝 뿜어내고 사라지는 이펙트이다.

따라서 Looping을 해제하여 반복되지 않게 하며, Stop Action을 Disable로 설정하고 재생이 끝나면 파티클 시스템 게임오브젝트가 비활성화 되도록 해준다.

그리고 한 번에 많은 파티클을 생성해야 하는데 Max Particle 이하의 파티클만 동시에 존재할 수 있으므로, Max Particle 한도를 늘려준다.

<br>

## Emission 모듈 수정

- `Rate over Time` : 0

- `Bursts`의 우측 하단 `+` 버튼을 눌러, 버스트 하나를 추가한다.

- 생성한 버스트의 `Count`를 128, `Cycles`를 48로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/110452875-ef555300-8108-11eb-9a99-ac70c958b3fc.png)

<br>

Emission 모듈의 버스트 설정이 [Burst] 이펙트의 핵심이다.

Rate over Time은 지속적으로 생성할 파티클의 개수를 초당 개수로 지정하는데 반해,

Bursts는 지정된 타이밍(Time)에 지정한 개수(Count)의 파티클을 지정한 횟수(Cycles)만큼 지정한 시간 간격(Inteval)로 반복하여 생성하도록 한다.

따라서 파티클을 재생하면 0초에 0.01초 간격으로 48번, 0.48초까지 매 번 128개의 파티클을 생성하게 된다.

(메인 모듈에서 Start Delay를 지정하였으므로 실제로는 1초부터 시작된다.)

<br>

## Shape 모듈 수정

- `Arc` - `Mode` : Burst Spread

Burst Spread는 Emission의 Burst로 생성하는 파티클들이 생성 영역 내에서 골고루 생성되도록 해준다.

<br>

## Velocity over Lifetime 모듈

- `Orbital` : Z 값을 -4로 수정한다.

- `Radial` 커브를 클릭하여 커브 에디터를 열고, Y축의 값을 -10으로 수정한다.

<br>

## Trails 모듈 수정

- `Color over Lifetime` - [Gradient] : 알파값이 0 ~ 1 ~ 0으로 변화하도록 다음처럼 설정한다.

![image](https://user-images.githubusercontent.com/42164422/110458348-01d28b00-810f-11eb-8726-f9090d863d54.png)


<br>

## 결과

![2021_0309_drStrange_09](https://user-images.githubusercontent.com/42164422/110457241-c5525f80-810d-11eb-82c2-768a89614618.gif)

<br>

# 6. 완성
---

- 4개의 게임오브젝트를 모두 활성화하고, 파티클 시스템을 재생해본다.

![2021_0309_drStrange_10](https://user-images.githubusercontent.com/42164422/110457627-2ed26e00-810e-11eb-9770-c5c5c9d7576c.gif)


