---
title: (Amplify) Sea Urchin Shader
author: Rito15
date: 2021-07-23 15:15:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 가시 삐쭉삐쭉한 성게 쉐이더

<br>

# 1. 기본
---

## **Preview**

![2021_0723_SeaUrchin_1](https://user-images.githubusercontent.com/42164422/126749491-6301d14a-384d-4e72-9892-977c1ffef025.gif){:.normal width="250" height="220"}
![2021_0723_SeaUrchin_2](https://user-images.githubusercontent.com/42164422/126749497-aa635094-c377-414b-a80e-2cf5e292d78b.gif){:.normal width="250" height="220"}
![2021_0723_SeaUrchin_3](https://user-images.githubusercontent.com/42164422/126749500-31f94efc-daf4-4839-9656-dbb852f58bb4.gif){:.normal width="250" height="220"}

<br>

## **Properties**

![image](https://user-images.githubusercontent.com/42164422/126749825-84cbd2d6-5ebb-4ca6-8c17-0f02f42bafff.png){:.normal}

|프로퍼티|설명|
|---|---|
|`Edge length`|테셀레이션 간격(작을수록 촘촘해진다)|
|`Tiling`|가시 개수 비율|
|`Sharpness`|가시의 뾰족한 정도|
|`Height`|가시의 길이|
|`Body Color`|구체 색상|
|`Thron`|가시 색상|
|`Color Mix Threshold`|두 색상의 경계 구분값|
|`Color Mix Smoothness`|두 색상이 부드럽게 섞이는 정도|

<br>


## **Settings**

- `Tessellation` 체크
- `Edge Length = 6`

<br>


## **Nodes**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126749544-3711fdff-90a1-4807-ac77-0f41edc49183.png)


<br>



# 2. 색상 구분 추가
---

## **Preview**

![image](https://user-images.githubusercontent.com/42164422/126749870-4d7145eb-ab45-4713-9573-26c707af3d61.png)

## **Nodes**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126749682-e7ed7638-b2e5-492d-983e-eaa92a909bae.png)

<br>



# 3. 전환 효과 1
---

## **Preview**

![2021_0723_SeaUrchin_Transition_A](https://user-images.githubusercontent.com/42164422/126783841-8c8b9cc7-1d60-4ef1-bed6-871282b626cd.gif)

## **Nodes**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126783330-be353dcc-3ef4-4b59-b489-6a4620148332.png)

<br>




# 4. 전환 효과 2
---

## **Preview**

![2021_0723_SeaUrchin_Transition_B](https://user-images.githubusercontent.com/42164422/126783844-9effe055-f53e-4aba-abe8-9a4edd8f5c5e.gif)

## **Nodes**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126783402-3e486d9e-095f-462d-847c-229bc29ad308.png)

<br>




# 5. 전환 효과 3
---

## **Preview**

![2021_0723_SeaUrchin_Transition_C](https://user-images.githubusercontent.com/42164422/126783850-b757e6d5-fe62-4599-aabc-919d13054a91.gif)

## **Nodes**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126783523-8c5d42eb-3806-417c-8f28-b4ab44e7df4c.png)

<br>



# Download
---

- [2021_0723_Sea Urchin.zip](https://github.com/rito15/Images/files/6868825/2021_0723_Sea.Urchin.zip)

<br>



