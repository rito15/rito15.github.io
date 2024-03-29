---
title: (Amplify) Electricity Shader
author: Rito15
date: 2021-08-14 09:09:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 표면에 전기가 맴도는 효과

<br>



# Note
---

- 포스트프로세싱 Bloom을 넣어 주는 것이 좋다.

- 최적화를 위해서는 `Noise Generator` 노드 대신 노이즈 텍스쳐를 사용해야 한다.

<br>



# Preview
---

![2021_0814_Electricity3](https://user-images.githubusercontent.com/42164422/129456094-ae6ae78d-9c6d-479d-9ea4-56cdf5359767.gif)

![2021_0814_Electricity4](https://user-images.githubusercontent.com/42164422/129456096-2042eb4e-2756-4b39-9fe7-3c0cb1697467.gif)

<br>



# Properties
---

![image](https://user-images.githubusercontent.com/42164422/129428504-948e5453-fa33-4234-8de7-7fbd96d05b5d.png)

<br>



# Settings
---

## General
 - Light Model : `Unlit`
 - `Cast Shadows`, `Receive Shadows` 체크 해제

## Blend Mode
 - `Masked`

<br>



# Nodes
---

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/129428364-f0a3b24f-1a73-4f3e-876c-5d54fdc1655f.png)

<br>



# Download
---

- [2021_0814_Electricity.zip](https://github.com/rito15/Images/files/6985643/2021_0814_Electricity.zip)




