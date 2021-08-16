---
title: (Amplify) Time Easing Functions
author: Rito15
date: 2021-08-16 22:22:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Note
---

- `Time` 노드 기반의, 시간 진행에 따른 변화 함수 예제 모음

<br>



# [1]
---

![image](https://user-images.githubusercontent.com/42164422/129604803-8c640e8a-5747-464a-b78b-70d37ef06912.png)

![2021_0817_Easing_01](https://user-images.githubusercontent.com/42164422/129605391-32215bee-1769-422b-83d1-00f6521064ec.gif)

- `0` ~ `1` 값을 단순 선형으로 왕복할 수 있다.

<br>



# [2]
---

![2021_0816_Easing_02](https://user-images.githubusercontent.com/42164422/129570286-784c21a8-85bf-4476-982a-3464e278621e.gif)

![image](https://user-images.githubusercontent.com/42164422/129569862-3fe232ce-f49e-4ab9-b2cf-b929f2756c1c.png)

- `Power` 값은 `[2, 8]` 범위에서 2의 배수로 넣어 주는 것이 안전하다.

- 사용 예시 : 심장 박동 표현

<br>





<br>

# References
---
- <https://easings.net/ko>