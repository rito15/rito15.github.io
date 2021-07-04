---
title: (Amplify) World Position Offset(Black Hole) Shaders
author: Rito15
date: 2021-07-04 17:00:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 특정 월드 좌표로 빨려 들어가는 효과

<br>

# 1. Simple Move
---

- 현재 좌표로부터 타겟 위치까지 `T(0 ~ 1)` 값에 따라 선형 보간하여 단순 이동

![2021_0704_WPO_01](https://user-images.githubusercontent.com/42164422/124375780-e2bfc080-dcde-11eb-8790-0bec114e39fb.gif)

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124375783-e6534780-dcde-11eb-9caf-255c9351121c.png)

<br>

# 2. Procedural Move
---

- 현재 좌표로부터 타겟 위치까지 `T(0 ~ 1)` 값에 따라 선형 보간하여 빨려 들어가는 효과

- (버텍스 -> 타겟 위치) 방향 벡터와 노멀 벡터의 내적 결과값을 마스크로 사용한다.

![2021_0704_WPO_02](https://user-images.githubusercontent.com/42164422/124376456-105a3900-dce2-11eb-84c7-018ac2fec79e.gif)

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124376461-14865680-dce2-11eb-88e5-e24aea7bb592.png)

<br>

# 3. Dramatic Move
---

- 현재 좌표로부터 타겟 위치까지 `T(0 ~ 1)` 값에 따라 선형 보간하여 빨려 들어가는 효과

- (버텍스 -> 타겟 위치) 방향 벡터와 노멀 벡터의 내적 결과값을 마스크로 사용한다.

- `Lerp`에 들어갈 `0 ~ 1` 범위 값을 `Step` 노드를 통해 `0`, `1` 값으로 이분하여 극적인 효과를 준다.

![2021_0704_WPO_03](https://user-images.githubusercontent.com/42164422/124376459-118b6600-dce2-11eb-8cbf-c41133067ecb.gif)

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124376550-7777ed80-dce2-11eb-8ca0-4d03b6e93070.png)

<br>

# 4. Range
---

- `T(0 ~ 1)` 값 대신, 효과가 미칠 범위 값(`Range`)을 기준값으로 사용한다.

- `Smoothness` 값을 조정하여 다양한 효과를 연출할 수 있다.

![2021_0704_WPO_04](https://user-images.githubusercontent.com/42164422/124377970-dee56b80-dce9-11eb-8eba-b63912e95a09.gif)

![2021_0704_WPO_04_02](https://user-images.githubusercontent.com/42164422/124377971-df7e0200-dce9-11eb-87b7-5323225e8d30.gif)

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124379252-d3e20980-dcf0-11eb-8f85-970cc9c4a253.png)

<br>

![image](https://user-images.githubusercontent.com/42164422/124379186-7948ad80-dcf0-11eb-9ea5-965ac575b582.png)

계산을 시각화하면 위와 같다.

<br>

## [1] 정점이 움직이지 않는 경우

![image](https://user-images.githubusercontent.com/42164422/124379194-81a0e880-dcf0-11eb-9372-405e3fa50ce9.png)

- `Distance`가 `Range`보다 큰(멀리 있는) 정점들은 `LerpValue` 값이 `0`이 되어 모두 원래 위치에 존재한다.

<br>

## [2] 정점이 이동 중인 경우

![image](https://user-images.githubusercontent.com/42164422/124379280-055ad500-dcf1-11eb-985c-b933a4efc345.png)

- `Distance`가 `(Range - Smoothness)` ~ `Range` 내에 있는 정점들은 `LerpValue` 값이 `0 ~ 1` 값을 가지며, 그 값에 따라 이동 거리가 결정된다.

<br>

## [3] 정점이 타겟 위치로 완전히 이동한 경우

![image](https://user-images.githubusercontent.com/42164422/124379283-0ab81f80-dcf1-11eb-9cdf-3f80de74ac6b.png)

- `Distance`가 `(Range - Smoothness)`보다 작은 범위에 있는 정점들은 `LerpValue` 값이 `1`이 되어 모두 타겟 위치에 존재한다.


<br>

# 5. Twirl
---

- `Vertex -> Target` 방향 벡터와 `Object View Dir` 벡터를 외적하여 진행 방향에 수직인 벡터를 계산한다.

- `Target Position`과 위의 벡터를 서로 더한 위치를 계산한다.

- 현재 정점 위치로부터 위에서 얻은 위치 벡터를 `Lerp`를 통해 보간하여 중간 위치를 얻고, 그 결과를 다시 `Target Position`과 보간하여, 결과적으로 진행방향이 둥글게 왜곡된다.

![2021_0704_WPO_05](https://user-images.githubusercontent.com/42164422/124385422-7e1d5980-dd10-11eb-860c-8c8a38a73cb5.gif)

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124385330-00f1e480-dd10-11eb-9391-1dd26b1755b2.png)

<br>

# Download
---

- [2021_0704_World Position Offsets.zip](https://github.com/rito15/Images/files/6759885/2021_0704_World.Position.Offsets.zip)








