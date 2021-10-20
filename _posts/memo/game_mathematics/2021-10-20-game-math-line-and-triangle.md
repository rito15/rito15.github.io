---
title: 게임 수학 - 선과 삼각형, 정점의 보간
author: Rito15
date: 2021-10-20 21:00:00 +09:00
categories: [Memo, Game Mathematics]
tags: [game, math]
math: true
mermaid: true
---

# 3D 게임 공간의 확장
---
- 벡터 공간 : 이동 벡터를 표현(w가 항상 0)
- 아핀 공간 : 위치 벡터를 표현(w가 항상 1)

<br>

## **특징**
- 벡터와 벡터는 더할 수 있다.
- 벡터와 점을 더하면 `w = 1`이므로 점이 된다.
- 점과 점을 더하면 `w = 2`가 되어 아핀 공간을 벗어나므로, 더할 수 없다.

<br>

# 아핀 조합(Affine Combination)
---

$$
a + b = 1
$$

$$
P = aP_{1} + bP_{2}
$$

$$
P = aP_{1} + (1 - a)P_{2}
$$

- 점 `P`는 `(x, y, z, 1)`인 아핀 공간의 위치 벡터
- 아핀 조합 : 아핀 공간의 두 점을 더했을 때의 결과가 아핀 공간의 점(w = 1)이 됨을 보장하는 공식

<br>

# 두 개의 점을 이용해 선 표현하기
---
$$
P = aP_{1} + (1 - a)P_{2}
$$

- `a` : 계수

- `(a = 1)`이면 P는 P1
- `(a = 0)`이면 P는 P2

<br>

![image](https://user-images.githubusercontent.com/42164422/138098295-e97e1296-ec56-4379-90ac-ac2f6235d2d5.png)

- `a`가 실수이면 P는 직선(Line)

<br>

![image](https://user-images.githubusercontent.com/42164422/138098460-d10f7fe3-038b-4b2d-8672-8667b86dacf9.png)

- `(a > 0)`이면 P2에서 P1을 향한 반직선(Ray)

<br>

![image](https://user-images.githubusercontent.com/42164422/138098505-ff804e9b-7c67-4c6b-94fe-acf9323b1490.png)

- `(0 < a < 1)` 이면 P1과 P2 사이의 선분(Line Segment)

<br>



# 세 개의 점을 이용해 평면 표현하기
---
$$
P = aP_{1} + bP_{2} + (1 - a - b)_{3}
$$

- `a`, `b` : 계수

<br>

![image](https://user-images.githubusercontent.com/42164422/138098652-fad3be8c-07f1-4e14-a13d-f152a9c54978.png)

- (`a = 1`, `b = 0`, `(1 - a - b) = 0`)이면 P는 P1
- (`a = 0`, `b = 1`, `(1 - a - b) = 0`)이면 P는 P2
- (`a = 0`, `b = 0`, `(1 - a - b) = 1`)이면 P는 P3

<br>

![image](https://user-images.githubusercontent.com/42164422/138098864-e568f3fc-78fd-44eb-b69e-73650887f172.png)

- `a`, `b`가 실수이면 P는 점 P1, P2, P3를 모두 지나는 평면

<br>

![image](https://user-images.githubusercontent.com/42164422/138098789-c82e4be8-7ad2-40b0-8fda-6f1df4097b67.png)

![image](https://user-images.githubusercontent.com/42164422/138099237-5c7ff313-6f0c-403b-8051-88e46bb78375.png)

- (`0 < a < 1`, `0 < b < 1`, `0 < a + b < 1`)이면 P는 점 P1, P2, P3가 이루는 삼각형

<br>

![image](https://user-images.githubusercontent.com/42164422/138098925-ee1d7989-c154-4783-8b98-c0fdcfee5982.png)

- 모든 계수(`a`, `b`, `(1 - a - b)`)가 `1/3`일 때 P는 무게중심좌표(Barycentric Coordinate)

<br>

# 정점 데이터의 보간
---

## **픽셀화(Rasterization)**

![image](https://user-images.githubusercontent.com/42164422/138104722-17337645-3a8c-4bd7-a89c-db31a692db28.png)

- 세 개의 정점 데이터를 이용해 각 정점 사이의 픽셀 데이터를 계산하는 것
- 각 정점이 갖고 있던 데이터가 위의 평면 방정식을 통해 계수 `(0 ~ 1)` 사이에서 보간되어 삼각형 내의 픽셀들에 적용된다.


<br>

## **색상 보간 예시**

![image](https://user-images.githubusercontent.com/42164422/138101376-726fe88a-5bf7-452f-88ee-b876a2b0e4e1.png)

- 세 개의 정점이 각각 `R`, `G`, `B` 색상을 가지고 있었을 경우, 평면의 보간을 통해 삼각형의 내부를 위와 같이 채울 수 있다.


<br>

# References
---
- <https://www.inflearn.com/course/게임-수학-이해/lecture/75047>