---
title: (Amplify) Spawn Effect Shader
author: Rito15
date: 2021-09-18 00:01:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 월드 좌표의 한 점에서부터 스폰되는 효과

- **월드 공간의 버텍스 이동**, **그리드 패턴의 디졸브 효과**로 이루어져 있다.

<br>



# Preview
---

![2021_0917_Super Hero Landing01](https://user-images.githubusercontent.com/42164422/133798521-26de57b7-afa5-404a-9146-4cd8f37b4052.gif)

![2021_0917_Super Hero Landing02](https://user-images.githubusercontent.com/42164422/133798529-480db209-7b2a-4aed-b529-b4583d72327b.gif)

<br>



# Properties
---

<!--  ===================== 마테리얼 프로퍼티 목록 스샷 or 프로퍼티들 설명 =============  -->

|**프로퍼티명**|**설명**|**기본 값**|**범위**|
|---|---|---|---|
|`Main Texture`|메인 텍스쳐(Albedo)| | |
|`Grid Color`|그리드 패턴 색상(HDR)| | |
|`Grid Tiling X`|그리드 X축 타일링|48|2 ~ 48|
|`Grid Tiling Y`|그리드 Y축 타일링|48|2 ~ 48|
|`Dissolve Smoothness`|디졸브 효과 부드러운 정도|0.5|0 ~ 1|
|`Starting World Position`|스폰 시작 지점 월드 좌표|(0, 32, 0)| |
|`T`|진행도|0|0 ~ 1|


<br>



# Settings
---

- **Shader Type** : Surface
- **Light Model** : Standard
- **Blend Moe** : Opaque

<br>



# Nodes
---
<!--  ============================== 전체 노드 스크린샷 ==============================  -->

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/133798146-41438870-3fd8-4ef0-a5b1-852392937f19.png)

<br>


# Note
---

이 쉐이더의 효과는 버텍스 월드 위치 이동, 그리드 패턴 디졸브 효과로 이루어져 있으며

프로퍼티 `T`의 값이 `0 ~ 0.5`, `0.5 ~ 1` 구간을 진행함에 따라 각각 적용된다.

노드 내에서

![image](https://user-images.githubusercontent.com/42164422/133799448-fc80aa91-0223-45c5-82bb-2027a28b3e56.png)

이렇게 통합 되어 있으며,

분리하려면 `T` 대신 두 개의 프로퍼티를 만들어서

![image](https://user-images.githubusercontent.com/42164422/133799882-846bbd81-de80-4d30-bc5c-a4414de32053.png)

이렇게 사용하면 된다.

<br>

# Download
---

- [2021_0918_Spawn Effect.zip](https://github.com/rito15/Images/files/7186524/2021_0918_Spawn.Effect.zip)

<br>




