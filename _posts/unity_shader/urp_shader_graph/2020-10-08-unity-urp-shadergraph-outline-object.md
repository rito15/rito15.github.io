---
title: Outline Object
author: Rito15
date: 2020-10-08 00:00:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

- CameraDepthNormal 텍스쳐를 이용하여 개별 오브젝트마다 아웃라인을 적용한다.

- URP Asset의 Depth Texture에 체크해야 한다.

- MSAA 2x 이상 사용해야 한다.


# Preview
---

![image](https://user-images.githubusercontent.com/42164422/111079728-989fad00-853e-11eb-81f3-605b867bcd4e.png)

# Options
---

|프로퍼티|설명
|---|---|
|`Main Texture`|메인 텍스쳐|
|`Outline Color`|아웃라인 색상|
|`Outline Thickness`|아웃라인 두께|
|`Depth Sensitivity`|아웃라인 생성 기준 깊이값|
|`Normals Sensitivity`|별다른 영향을 주지 않음|


# Download
---
- [2020_1008_OutlineObject.zip](https://github.com/rito15/Images/files/6137335/2020_1008_OutlineObject.zip)


# References
---
- <https://alexanderameye.github.io/outlineshader.html>