---
title: (Amplify) Screen Effect - Ice (Frozen)
author: Rito15
date: 2021-09-12 01:01:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---
- 화면이 가장자리부터 얼어붙는 효과

- 스크린 이펙트 적용 애셋 : [Link](https://rito15.github.io/posts/unity-screen-effect-controller/)

<br>



# Preview
---

![image](https://user-images.githubusercontent.com/42164422/132953627-284901f4-8daa-4a60-a150-7f64127d573c.png)

![2021_0912_Screen Ice](https://user-images.githubusercontent.com/42164422/132953631-43ea5fda-faeb-4337-bf8c-6dd85f9a29d5.gif)

<br>



# Properties
---

- **Ice Texture**
  - 얼음 효과로 사용할 텍스쳐
  - 원하는 텍스쳐를 사용하면 된다.

- **Range**
  - 효과 적용 범위 (0 ~ 1)

- **Noise Scale**
  - 기본 값 : 4
  - 노이즈 적용 스케일

- **Power A**
  - 기본 값 : 3
  - 영역의 모양
  - 작을수록 원형, 클수록 사각형에 가까워진다.

- **Power B**
  - 기본 값 : 2
  - 영역 경계 부분의 선명도

- **Opacity**
  - 기본 값 : 1
  - 얼음 텍스쳐의 불투명도
  - 범위 : 0 ~ 2

- **Smoothness**
  - 기본 값 : 5
  - 범위 : 1 ~ 10
  - 얼음 영역의 부드러운 정도

- **Distortion**
  - 기본 값 : 1
  - 범위 : 0 ~ 1
  - 얼음이 닿는 부분의 왜곡 강도

<br>



# Nodes
---

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/132954197-c6e9d839-63ff-49be-a520-1af6eeee6a42.png)

<br>



# Download
---
- [2021_0912_Screen_Ice.zip](https://github.com/rito15/Images/files/7148132/2021_0912_Screen_Ice.zip)

<br>


# References
---
- <https://www.youtube.com/watch?v=Oi4kPjirHf8>


