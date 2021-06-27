---
title: 간단한 앰플리파이 쉐이더 예제 모음
author: Rito15
date: 2021-06-27 04:24:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---


# 1. Vertex
---

## Scale Up and Down

![image](https://user-images.githubusercontent.com/42164422/123306240-00ad5880-d55c-11eb-847a-feeba45ffa89.gif)

<br>

## Heartbeat

![2021_0627_Heartbeat](https://user-images.githubusercontent.com/42164422/123522819-e8c00b00-d6fa-11eb-8c09-c5bf9880efee.gif)

```
( max( sin(T * F), 1-S ) - (1-S) ) * A

T : Time
F : Frequency
S : Sensitivity
A : Amplitude
```

<br>

## World Position Offset

![image](https://user-images.githubusercontent.com/42164422/123471653-150f5500-d631-11eb-98f6-b6480c3d65d2.gif)

<br>

## World Position Offset (Same Scale)

![image](https://user-images.githubusercontent.com/42164422/123471661-16408200-d631-11eb-9092-fb65e96208d9.gif)

<br>

# 2. Color
---

## UV Mask

![image](https://user-images.githubusercontent.com/42164422/123144900-2cb2d600-d497-11eb-9b17-cfa9f1a730fc.gif)

- `Step`의 `A`, `B` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## Smooth UV Mask

![2021_0627_UV_Mask_Smooth](https://user-images.githubusercontent.com/42164422/123523596-8b7a8880-d6ff-11eb-887b-1f57f2fe7463.gif)

- `Smoothstep`의 `Min`, `Max` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## UV Circle

![image](https://user-images.githubusercontent.com/42164422/123522921-89aec600-d6fb-11eb-9eb9-b69ed62ac485.png)

<br>

## Smooth UV Circle

![image](https://user-images.githubusercontent.com/42164422/123523071-620c2d80-d6fc-11eb-90ae-5eb2cf7b3f10.png)

<br>

## UV Mask Dissolve

![2021_0627_UV_Mask_Dissolve](https://user-images.githubusercontent.com/42164422/123523888-ced5f680-d701-11eb-9c29-648de55c8476.gif)

<br>

## Noise Dissolve

![image](https://user-images.githubusercontent.com/42164422/123069599-e2f1cd80-d44d-11eb-950e-2088585127ae.gif)

<br>

## Checkerboard

![2021_0626_CheckerBoard](https://user-images.githubusercontent.com/42164422/123473821-0fffd500-d634-11eb-988c-3ed1c20f4130.gif)

<br>

## Distortion



<br>

## _



<br>

# 3. Lighting
---

## Simple Lambert

![image](https://user-images.githubusercontent.com/42164422/123553686-b32d2780-d7b7-11eb-883f-97094b9fc710.png)

- 마스터 노드 속성 - `General` - `Light Model` - `Custom Lighting` 선택

<br>

## Diffuse Warping

![image](https://user-images.githubusercontent.com/42164422/123554382-a78f3000-d7ba-11eb-8fd4-feb09a3fb9d3.png)

- **Ramp Texture**를 이용한 커스텀 라이팅 기법

- **Ramp Texture**는 반드시 `Wrap Mode : Clamp`, `Filter Mode : Point`로 설정해야 한다.

- 메인 텍스쳐 색상은 `Albedo`나 `Emission`이 아니라 **Custom Lighting** 입력 앞에 있는 `Multiply` 노드에 곱해주어야 한다.

<br>

![2021_0628_DiffuseWarping](https://user-images.githubusercontent.com/42164422/123554613-c80bba00-d7bb-11eb-8e4d-3bcc19cedac4.gif)

- `Scale And Offset` 노드를 통해 각 색상의 영역을 조절해줄 수 있다.


<br>

## Toon(Cel) Shading

https://www.youtube.com/watch?v=dyiLJ1PFhM0
https://www.youtube.com/watch?v=MawzivWLCoo

<br>

## _


<br>

