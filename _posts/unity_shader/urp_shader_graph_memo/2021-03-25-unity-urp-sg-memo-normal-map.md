---
title: 노멀맵에서 노멀 벡터 추출하기
author: Rito15
date: 2021-03-25 17:00:00 +09:00
categories: [Unity Shader, URP Shader Graph Memo]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Memo
---

- Tangent, Bitangent, Normal Vector로 이루어진 3x3 행렬과 샘플링된 노멀맵 벡터를 곱해줌으로써, 노멀맵으로부터 노멀 벡터를 추출하여 사용할 수 있다.

- 행렬을 만들 때 행벡터를 조립하여 만들지, 열벡터를 조립하여 만들지 여부에 주의해야 한다.

- 행렬과 벡터를 곱할 때 벡터가 앞에 나오면 행벡터, 뒤에 나오면 열벡터로 사용됨에 주의해야 한다.

- T, B, N 벡터의 공간을 반드시 일치시켜줘야 한다.

- 각 벡터들의 공간은 노멀맵의 사용 대상에 따라 달라진다.
  - 예 : 월드 라이팅 연산을 할 때는 World Space

<br>


![image](https://user-images.githubusercontent.com/42164422/112439401-671fb080-8d8c-11eb-8cdc-e6c9311ba565.png)


<br>

# References
---
- <https://youtu.be/M7ICBYmZkds?t=1458>