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

## **Scale Up and Down**

![image](https://user-images.githubusercontent.com/42164422/123306240-00ad5880-d55c-11eb-847a-feeba45ffa89.gif)

<br>

## **Heartbeat**

![2021_0627_Heartbeat](https://user-images.githubusercontent.com/42164422/123522819-e8c00b00-d6fa-11eb-8c09-c5bf9880efee.gif)

```
( max( sin(T * F), 1-S ) - (1-S) ) * A

T : Time
F : Frequency
S : Sensitivity
A : Amplitude
```

<br>

## **World Position Offset**

![image](https://user-images.githubusercontent.com/42164422/123471653-150f5500-d631-11eb-98f6-b6480c3d65d2.gif)

![image](https://user-images.githubusercontent.com/42164422/124704646-6112a180-df2f-11eb-900c-4b0ec3db65af.png)

- 두 가지 방식 모두 동일한 결과를 내므로, 상황에 따라 선택하여 사용하면 된다.

<br>

## **World Position Offset (Keep Scale)**

![image](https://user-images.githubusercontent.com/42164422/123471661-16408200-d631-11eb-9092-fb65e96208d9.gif)

![image](https://user-images.githubusercontent.com/42164422/124704685-6cfe6380-df2f-11eb-8c77-a8e28db7b39b.png)

- 두 가지 방식 모두 동일한 결과를 내므로, 상황에 따라 선택하여 사용하면 된다.

<br>

## **Vertex Displacement**

![image](https://user-images.githubusercontent.com/42164422/123921004-864c6080-d9c1-11eb-97b0-4b08b1ac58c7.png)

![2021_0630_VertexDisplacement](https://user-images.githubusercontent.com/42164422/123919002-6c118300-d9bf-11eb-94d2-e5ced763c5c7.gif)

- `Noise Generator` 노드에 `UV` 입력이 있다고 해서 진짜로 `UV`를 넣으면 안되고, 대신 `Vertex Position`을 넣어야 한다.

<br>

# 2. Color
---

## **UV Mask**

![image](https://user-images.githubusercontent.com/42164422/123144900-2cb2d600-d497-11eb-9b17-cfa9f1a730fc.gif)

- `Step`의 `A`, `B` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## **Smooth UV Mask**

![2021_0627_UV_Mask_Smooth](https://user-images.githubusercontent.com/42164422/123523596-8b7a8880-d6ff-11eb-887b-1f57f2fe7463.gif)

- `Smoothstep`의 `Min`, `Max` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## **UV Circle**

![image](https://user-images.githubusercontent.com/42164422/123522921-89aec600-d6fb-11eb-9eb9-b69ed62ac485.png)

<br>

## Smooth UV Circle

![image](https://user-images.githubusercontent.com/42164422/123523071-620c2d80-d6fc-11eb-90ae-5eb2cf7b3f10.png)

<br>

## **UV Mask Dissolve**

![2021_0627_UV_Mask_Dissolve](https://user-images.githubusercontent.com/42164422/123523888-ced5f680-d701-11eb-9c29-648de55c8476.gif)

<br>

## **Noise Dissolve**

![image](https://user-images.githubusercontent.com/42164422/123069599-e2f1cd80-d44d-11eb-950e-2088585127ae.gif)

<br>

## **Checkerboard**

![2021_0626_CheckerBoard](https://user-images.githubusercontent.com/42164422/123473821-0fffd500-d634-11eb-988c-3ed1c20f4130.gif)

<br>

## **Distortion**

![image](https://user-images.githubusercontent.com/42164422/123935349-1a70f480-d9cf-11eb-8e17-026c610e2009.png)

![2021_0630_Distortion](https://user-images.githubusercontent.com/42164422/123935354-1c3ab800-d9cf-11eb-8caa-dfdde3e4ee88.gif)

- 마스터 노드의 속성에서 `Blend Mode`를 `Transparent`로 지정한다.

- 마찬가지로 `General - Light Model`을 `Unlit`으로 변경한다.

<br>

## **World Position-Based Color Variation**

![image](https://user-images.githubusercontent.com/42164422/123928240-b1867e00-d9c8-11eb-8c35-fff6ee009084.png)

![image](https://user-images.githubusercontent.com/42164422/123928341-c9f69880-d9c8-11eb-936f-bddbe1abf096.png)

- 게임 오브젝트의 현재 월드 위치를 기반으로 색상을 지정한다.

- `Distribution`, `Seed` 프로퍼티를 이용해 다양한 연출이 가능하다.

<br>

## **World Position-Based Color Variation (From-To)**

![image](https://user-images.githubusercontent.com/42164422/123930182-75541d00-d9ca-11eb-9610-8830222c9000.png)

![image](https://user-images.githubusercontent.com/42164422/123930087-5fdef300-d9ca-11eb-9805-c92d664ebe57.png)

- 지정한 두 색상 사이에서만 월드 위치 기반으로 색상이 분포하도록 한다.

<br>

## **Contact Point**

![2021_0705_ContactPoint](https://user-images.githubusercontent.com/42164422/124423754-c84e1b80-dda0-11eb-9fba-d38ddb500bf7.gif)

- 다른 불투명 물체와 접촉한 지점을 강조하여 표현한다.

- 대표적으로 쉴드 이펙트, 물 쉐이더 등에 사용된다.

- `Screen Position` 노드의 `Type`은 `Screen`으로 지정해야 한다.

- 반드시 `Blend Mode`를 `Transparent`로 설정해야 한다.

<br>

## **Texture Sheet Animation**

- 예제 텍스쳐 :

![TextureSheet_Debug_3x2](https://user-images.githubusercontent.com/42164422/126528144-0b6fcfcb-5394-443d-8b8f-4575140cb9b2.png)

<br>

### **[1] 좌측 하단부터 시작**

![2021_0722_TextureSheetAnimation1](https://user-images.githubusercontent.com/42164422/126528271-e978a29b-cc87-43e7-899e-f3621c8d2553.gif)

![2021_0722_TextureSheetAnimation2](https://user-images.githubusercontent.com/42164422/126528281-6d2a7f6b-a6a9-4b41-a2d5-b8106f5f79f7.gif)

- 좌측 하단 영역을 `(0, 0)`, 우측 상단 영역을 `(2, 1)` 좌표로 하여 인덱스의 진행에 따라 `(0, 0)`, `(1, 0)`, `(2, 0)`, `(0, 1)`, `(1, 1)`, `(2, 1)` 순서대로 재생한다.

- 첫 번째 사진처럼 인덱스를 직접 지정해줄 수도 있고, 두 번째 사진처럼 시간의 흐름에 따라 자동 재생되게 해줄 수도 있다.

<br>

### **[2] 좌측 상단부터 시작**

![2021_0722_TextureSheetAnimation_LT_1](https://user-images.githubusercontent.com/42164422/126530606-e7153b8b-b620-4903-a49b-c8583e7f22dd.gif)

![2021_0722_TextureSheetAnimation_LT_2](https://user-images.githubusercontent.com/42164422/126530610-f83d849e-c429-4531-b20b-5e56f354a87a.gif)

- 파티클 시스템의 `Texture Sheet Animation`과 같은 방식

- 텍스쳐 시트 형태로 만들어지는 파티클 텍스쳐의 경우 이와 같이 좌상단부터 우하단 방향으로 재생된다.

<br>

- 그런데 `Amplify`, `Shadergraph`에 모두 간편하게 하나의 노드로 이미 구현되어 있으므로, 추가적인 응용이 필요한 것이 아니라면 `Flipbook` 노드를 사용하면 된다.

![2021_0722_TextureSheetAnimation_Flipbook](https://user-images.githubusercontent.com/42164422/126530621-a328afee-26b6-4a76-97a8-1ba12d61e081.gif)

<br>

# 3. Lighting
---

## **Lambert**

![image](https://user-images.githubusercontent.com/42164422/123553686-b32d2780-d7b7-11eb-883f-97094b9fc710.png)

- 마스터 노드 속성 - `General` - `Light Model` - `Custom Lighting` 선택

<br>

<!--

## **Half Lambert**

## **Blinn-Phong Specular**

<br>

-->

## **Diffuse Warping**

![image](https://user-images.githubusercontent.com/42164422/123554382-a78f3000-d7ba-11eb-8fd4-feb09a3fb9d3.png)

- [Ramp Texture](https://user-images.githubusercontent.com/42164422/123857489-50759080-d95d-11eb-8d1d-24215df18856.png)를 이용한 커스텀 라이팅 기법

- **Ramp Texture**는 반드시 `Wrap Mode : Clamp`, `Filter Mode : Point`로 설정해야 한다.

- 메인 텍스쳐 색상은 `Albedo`나 `Emission`이 아니라 **Custom Lighting** 입력 앞에 있는 `Multiply` 노드에 곱해주어야 한다.

<br>

![2021_0628_DiffuseWarping](https://user-images.githubusercontent.com/42164422/123554613-c80bba00-d7bb-11eb-8e4d-3bcc19cedac4.gif)

- `Scale And Offset` 노드를 통해 각 색상의 영역을 조절해줄 수 있다.

<br>

- 사용된 **Ramp Texture** :

![](https://user-images.githubusercontent.com/42164422/123857489-50759080-d95d-11eb-8d1d-24215df18856.png)

<br>



<!--

## **Toon(Cel) Shading**

<details>
<summary markdown="span"> 
TODO
</summary>

https://www.youtube.com/watch?v=dyiLJ1PFhM0
https://www.youtube.com/watch?v=MawzivWLCoo

</details>


<br>

-->


