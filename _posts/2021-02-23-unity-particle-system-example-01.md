---
title: 파티클 시스템 예제 - 01
author: Rito15
date: 2021-02-23 21:15:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# Preview
---

## 1. Twinkles

![2021_0223_Particle_Ex_Twinkle_Completed](https://user-images.githubusercontent.com/42164422/108846034-7abae880-7621-11eb-9ca0-f0831153ae0e.gif)

## 2. Falling Snowflakes

![2021_0223_Particle_Ex_Snow_Completed](https://user-images.githubusercontent.com/42164422/108849793-ec953100-7625-11eb-9a33-3b4c595cc628.gif)

## 3. Rising Hearts

![2021_0223_Particle_Ex_Hearts](https://user-images.githubusercontent.com/42164422/108842884-49d8b480-761d-11eb-86b4-d6ad7590c42a.gif)

<br>

# 목차
---

- [1. Twinkles](#twinkles)
- [2. Falling Snowflakes](#falling-snowflakes)
- [3. Rising Hearts](#rising-hearts)

<br>

# Twinkles
---

- 우선 반짝이는 모양의 텍스쳐와 Additive 마테리얼을 준비한다.

  (텍스쳐 및 마테리얼 준비는 설명을 생략하며, 파티클 시스템 게임오브젝트를 생성한 상태라고 가정한다.)

<br>

## Transform

- 파티클 시스템 게임오브젝트를 최초로 생성하면 Rotation X 값이 -90으로 설정되어 있다.

- 의도와 다르게 동작할 수 있으므로, 0으로 지정해주고 시작하는 것이 좋다.

![image](https://user-images.githubusercontent.com/42164422/108844434-7988bc00-761f-11eb-8f87-52cde111a46a.png)

<br>

## Shape

- 파티클이 넓게 퍼진 영역에서 생성될 것이므로, Shape를 Box로 지정한다.

- 영역의 크기(Scale)는 적당히 넓게 10 ~ 20 정도로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108844090-f7989300-761e-11eb-8f81-10496469f102.png)

<br>

## Main - Start Speed
 - 파티클이 움직이지 않고 제자리에서 생성되고 사라지는 형태이므로, Start Speed를 0으로 설정한다.

<br>

## Main - Start Color
 - 다양한 색상을 무작위로 사용하기 위해, [Random Color]를 지정하고 다음과 같이 설정한다.

![image](https://user-images.githubusercontent.com/42164422/108844904-0d5a8800-7620-11eb-92df-31b5a56690c3.png)

<br>

## Main - Start Size
 - 다양한 크기를 무작위로 사용하기 위해, [Random Between Two Constants]를 지정한다.
 - 카메라와의 거리에 따라 크기를 적절하게 지정한다. (예 : 1 ~ 4)

<br>

## Size over Lifetime
 - 점점 커졌다가 작아지는 것을 표현하기 위해 커브를 다음처럼 지정한다.

![2021_0223_Particle_Ex_Twinkle_SizeCurve](https://user-images.githubusercontent.com/42164422/108845697-1435ca80-7621-11eb-8c8c-7aadd486549b.gif)

<br>

## Main - Start Lifetime
 - 더 빠르게 깜빡일 수 있도록, Lifetime 값을 1 정도로 설정한다.

<br>

## Emission
 - 파티클을 더 많이 생성하도록 Rate over Time 값을 64 정도로 높여준다.

<br>

## 결과

![2021_0223_Particle_Ex_Twinkle_Completed](https://user-images.githubusercontent.com/42164422/108846034-7abae880-7621-11eb-9ca0-f0831153ae0e.gif)

<br>

# Falling Snowflakes
---

## 사전 준비
 - 텍스쳐
 - 마테리얼
 - 파티클 시스템 게임오브젝트 생성
 - Transform - Rotation (0, 0, 0)

<br>

## Shape
 - Box
 - 옆으로 길쭉한 형태가 필요하므로, Scale을 (20, 1, 1) 정도로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/108846733-3ed45300-7622-11eb-8153-b2b4daabc13b.png)

<br>

## Main - Start Speed
 - 0으로 설정한다.

<br>

## Main - Gravity Modifier
 - 파티클이 적당히 천천히 떨어질 수 있도록 0.2로 지정한다.

![2021_0223_Particle_Ex_Snow_Gravity](https://user-images.githubusercontent.com/42164422/108847091-9d013600-7622-11eb-9e93-d8e9a9ee4160.gif)

<br>

## Main - Start Color
 - 하얀색 ~ 하늘색 사이에서 무작위 색상을 사용할 수 있도록 [Random Color]로 다음과 같이 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108847409-008b6380-7623-11eb-961e-ea42bd7f17fc.png)

<br>

## Main - Start Size
 - 파티클이 다양한 크기를 가질 수 있도록 [Random Between Two Constants]로 설정하고, 값을 [1, 2]로 지정한다.

<br>

## Rotation over Lifetime
 - 파티클이 수명 내에서 계속 회전할 수 있도록 Angular Velocity 값을 180으로 지정한다.

![2021_0223_Particle_Ex_Snow_RotationOverTime](https://user-images.githubusercontent.com/42164422/108848287-28c79200-7624-11eb-85ba-3badc6e99d17.gif)

<br>

## Main - Flip Rotation
 - 파티클이 반대 방향의 회전도 가질 수 있도록 Flip Rotation 값을 0.5로 지정한다.

![2021_0223_Particle_Ex_Snow_FlipRotation](https://user-images.githubusercontent.com/42164422/108848473-5e6c7b00-7624-11eb-9665-2ec02a0474fd.gif)

<br>

## Color over Lifetime
 - 파티클이 자연스럽게 나타나고 사라지는 것처럼 보일 수 있게 다음처럼 그라디언트를 지정한다.

![2021_0223_Particle_Ex_Snow_ColorOverLifetime](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

<br>

## 기타 속성
 - 메인 모듈의 Start Lifetime으로 파티클의 수명을 적절하게 조정해준다. (예제 : 4)
 - Emission 모듈의 Rate over Time으로 파티클의 개수를 원하는대로 조정한다. (예제 : 20)

<br>

## 결과

![2021_0223_Particle_Ex_Snow_Completed](https://user-images.githubusercontent.com/42164422/108849793-ec953100-7625-11eb-9a33-3b4c595cc628.gif)

<br>

# Rising Hearts
---

- 위의 Snowflake와 비슷하므로 중복되는 내용은 간략히 설명한다.

## 사전 준비
 - 텍스쳐
 - 마테리얼
 - 파티클 시스템 게임오브젝트 생성
 - Transform - Rotation (0, 0, 0)

<br>

## Shape
 - Box
 - Scale (20, 1, 1)

<br>

## Main 모듈

- Start Lifetime : 2 ~ 4 [Random Between Two Constants]

- Start Speed : 0

- Start Size : 1 ~ 3 [Random Between Two Constants]

- Start Color : Random Color

![image](https://user-images.githubusercontent.com/42164422/108851491-d38d7f80-7627-11eb-861a-ffa2b718a802.png)

<br>

## Color over Lifetime

- 위의 Snowflake와 동일하게 지정한다. (알파값 0 ~ 255 ~ 0)

![image](https://user-images.githubusercontent.com/42164422/108851647-046db480-7628-11eb-81c0-8dafe903c51f.png)

<br>

## Velocity over Lifetime

- 파티클들이 다양한 속도로 이동할 수 있도록, Linear를 [Random Between Two Constants]로 지정한다.

- 값은 다음과 같이 설정한다.

![image](https://user-images.githubusercontent.com/42164422/108851972-5f9fa700-7628-11eb-8037-126434148bfc.png)

<br>

## Size over Lifetime

- Size 값을 [Random Between Two Curves]로 지정한다.

- 커브를 수정하지 않고 이대로 사용한다.

![image](https://user-images.githubusercontent.com/42164422/108852128-8a89fb00-7628-11eb-8ddd-6ff80b611e47.png)

<br>

## 기타 속성

- Emission - Rate over Time (예제에서는 20으로 설정)

<br>

## 결과

![2021_0223_Particle_Ex_Hearts_Completed](https://user-images.githubusercontent.com/42164422/108852403-e9e80b00-7628-11eb-9b15-a274baef8401.gif)