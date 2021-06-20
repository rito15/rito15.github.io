---
title: Directional Dissolve (2 Color)
author: Rito15
date: 2021-03-25 00:00:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

- 디졸브 방향을 직접 지정할 수 있는 디졸브 쉐이더

- 디졸브 효과 색상 2가지를 지정할 수 있다.

- 포스트 프로세싱 Bloom 효과가 반드시 필요하다.


# Preview
---

![2021_0325_2ColDissolve](https://user-images.githubusercontent.com/42164422/112436162-02af2200-8d89-11eb-84d5-48ce1cc8c5de.gif)

# Options
---

|프로퍼티|설명
|---|---|
|`Main Texture`|메인 텍스쳐|
|`Tint Color`|메인 텍스쳐에 곱할 색상|
|`Color A`|디졸브 첫 번째 영역의 색상|
|`Color B`|디졸브 두 번째 영역의 색상|
|`Edge Thickness A`|디졸브 첫 번째 영역의 두께|
|`Edge Thickness B`|디졸브 두 번째 영역의 두께|
|`Noise Scale`|디졸브 영역 노이즈 스케일|
|`Dissolve Direction`|디졸브 월드 방향|
|`Dissolve Begin Offset`|디졸브 시작지점의 오프셋|
|`Dissolve End Offset`|디졸브 끝지점의 오프셋|
|`Dissolve`|디졸브 진행도(0 ~ 1)|


# Graph
---

![image](https://user-images.githubusercontent.com/42164422/122684927-6ab7bc00-d243-11eb-9f4b-c7ee98f0d598.png)


# Download
---
- [2021_0325_Dissolve_Directional_2Color.zip](https://github.com/rito15/Images/files/6202820/2021_0325_Dissolve_Directional_2Color.zip)


# References
---
- <https://www.youtube.com/watch?v=taMp1g1pBeE&ab_channel=Brackeys>