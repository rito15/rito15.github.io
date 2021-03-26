---
title: Cloaking(Refraction)
author: Rito15
date: 2021-03-25 20:40:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

- 뒤의 풍경을 왜곡시켜 보여주는 클로킹 쉐이더

- Render Pipeline Asset에서 Opaque Texture에 체크해야 한다.

- Opaque Texture를 사용할 때는 쉐이더그래프의 마스터 노드 Surface를 Transparent로 설정해야 한다.


# Preview
---

![2021_0325_Cloaking_org](https://user-images.githubusercontent.com/42164422/112468986-45362600-8dac-11eb-8b9a-3f3412491a60.gif)

![2021_0325_Cloaking_frn](https://user-images.githubusercontent.com/42164422/112468989-46675300-8dac-11eb-90af-913819a2f1ef.gif)

# Options
---

|프로퍼티|설명
|---|---|
|`Normal Map`|노멀맵 텍스쳐(없을 경우 기본 노멀 벡터 사용)|
|`Refraction`|왜곡 강도|
|`Fresnel Color`|프레넬 색상|
|`Fresnel Power`|프레넬 범위|
|`Fresnel Intensity`|프레넬 색상 강도|
|`Transition Speed`|프레넬 노이즈 이동속도|
|`Noise Frequency`|프레넬 노이즈 조밀도|


# Download
---
- [2021_0325_Cloaking.zip](https://github.com/rito15/Images/files/6204424/2021_0325_Cloaking.zip)


# References
---
- <https://www.youtube.com/watch?v=M7ICBYmZkds&ab_channel=UnityKorea>
