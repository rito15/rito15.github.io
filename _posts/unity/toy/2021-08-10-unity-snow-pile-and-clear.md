---
title: Snow Pile &amp; Clear (Plane에 눈 쌓기, 지우기)
author: Rito15
date: 2021-08-10 23:23:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp]
math: true
mermaid: true
---

# Summary
---
- 파티클이 닿는 지점에 눈 쌓기

- 쌓인 눈 지우기

<br>



# Preview
---

## **[1] 쌓기**

![2021_0810_SnowPile_01](https://user-images.githubusercontent.com/42164422/128891274-52c3c543-1d62-4263-a26a-70c085b6929e.gif)
![2021_0810_SnowPile_03](https://user-images.githubusercontent.com/42164422/128891281-519d714f-d95c-48e3-8481-e8f81f879db2.gif)

<br>

## **[2] 지우기**

![2021_0810_SnowPile_05](https://user-images.githubusercontent.com/42164422/128891294-78414cd0-a2e6-40e2-86ab-2361e654e14f.gif)
![2021_0810_SnowPile_06](https://user-images.githubusercontent.com/42164422/128891299-752ab00c-bc36-4f3b-a877-621205046f3c.gif)

<br>



# Details
---

## **[1] Ground 쉐이더**

- 메인 텍스쳐의 색상을 그대로 최종 색상으로 출력한다.

- 메인 텍스쳐의 `rgb` 값 중 하나를 `Height Map`으로 사용하여, 버텍스 `Y` 위치값에 더해준다.

- 마테리얼을 생성하여 `Plane`에 적용한다.

<br>



## **[2] 렌더 텍스쳐**

- 게임 시작 시 렌더 텍스쳐를 하나 생성한다.

- `Ground` 마테리얼의 메인 텍스쳐에 렌더 텍스쳐를 넣어준다.

<br>



## **[3] 브러시 텍스쳐**

- 마치 `Default Particle System`과 같은 흑백의 동그란 모양 텍스쳐를 준비하거나, 수식을 통해 생성한다.

- 이 텍스쳐의 알파값은 렌더 텍스쳐에 색칠할 때 `Opacity`로 사용된다.

- 동일한 모양의 텍스쳐를 각각 하얀색, 검정색으로 하나씩 준비한다.

- 하얀색 텍스쳐는 눈을 쌓을 때, 검정색 텍스쳐는 눈을 지울 때 사용된다.

<br>



## **[4] 눈 쌓기**

- 파티클 시스템을 이용해 `Plane`에 충돌을 발생시킨다.

- 충돌 지점으로부터 `Plane`의 `UV` 좌표를 계산한다.

- 렌더 텍스쳐의 해당 `UV` 좌표에 하얀색 브러시 텍스쳐로 픽셀을 칠해준다.

<br>



## **[5] 눈 지우기**

- 매 프레임마다 눈을 지울 게임오브젝트의 위치를 기반으로 `Plane`의 `UV` 좌표를 계산한다.

- 렌더 텍스쳐의 해당 `UV` 좌표에 검정색 브러시 텍스쳐로 픽셀을 칠해준다.

<br>



# Download
---
- [2021_0810_Snow Pile and Clear.zip](https://github.com/rito15/Images/files/6962736/2021_0810_Snow.Pile.and.Clear.zip)


