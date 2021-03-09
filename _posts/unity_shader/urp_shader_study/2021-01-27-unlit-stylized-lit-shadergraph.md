---
title: Unlit 쉐이더그래프로 만드는 Stylized Lit 쉐이더
author: Rito15
date: 2021-01-27 22:00:00 +09:00
categories: [Unity Shader, URP Shader Study]
tags: [unity, csharp, shader, shadergraph]
math: true
mermaid: true
---

# 동기
---

![](https://user-images.githubusercontent.com/42164422/105963070-e44be380-60c3-11eb-9a27-19eded174b98.png)

- 유나이트 서울 2020의 위 세션을 보고, 쉐이더그래프만을 이용해 비슷하게 만들어 봐야겠다고 생각했다.

# 목표
---
- URP 쉐이더그래프 중 Unlit 그래프를 이용해 직접 Stylized Lit 쉐이더 만들기

<br>

# 1. 서브그래프 준비
---
- 영상에서 보면, SmoothStep과 비슷한 연산을 더 저렴하게 할 수 있게 해주는 LinearStep을 다룬다.

![](https://user-images.githubusercontent.com/42164422/105963609-8b307f80-60c4-11eb-9900-c27dd78495c7.png)

- LinearStep을 함수화하여 자주 사용하는 코드가 나오기에, 서브그래프로 만들어주었다.

![](https://user-images.githubusercontent.com/42164422/105963981-f5e1bb00-60c4-11eb-917a-b607a35aec71.png)

- 그런데 실제로 이 세션의 코드를 보면 LinearStep 내에 threshold, smooth 값들을 동일한 형태로 사용하는 코드가 반복된다.

![](https://user-images.githubusercontent.com/42164422/105964242-3fcaa100-60c5-11eb-88c2-10322d9d2165.png)

- 따라서 이것을 Smoother라고 명명하고 통째로 서브그래프로 만들어주었다.
- 그런데 smooth 값이 만약 0이 된다면 LinearStep의 (in-min)/(max-min)에서 (max-min)이 0이 되므로 zero division 문제가 발생할 수 있기 때문에 이를 방지하기 위해 smooth에 아주 작은 값을 더해주었다.

![](https://user-images.githubusercontent.com/42164422/105982414-94c4e200-60da-11eb-97c5-5fe396f34779.png)

<br>

# 2. Diffuse
---
- <https://rito15.github.io/posts/unlit-custom-lit-shadergraph/>
- 위 링크에서 만들었던 디퓨즈를 이용하되, Half Lambert를 적용한다.
- Attenuation은 이후에 쓰임새가 더 있으므로 지금 적용하지 않고, 따로 분리해둔다.

![](https://user-images.githubusercontent.com/42164422/105982930-4f54e480-60db-11eb-8fb2-d70daae7d9d8.png)

<br>

# 3. Color
---
- 쉐이더 프로퍼티에 3가지 색상과 그림자 색상을 만든다.
- 3가지 색상에 적용할 Threshold, Smooth도 각각 만든다.
- 위에서 만든 서브그래프 Smoother, 그리고 Lerp를 이용해 총 네 가지 색상을 아래처럼 섞어준다.
- 각 Smoother 노드의 In 파라미터는 Diffuse의 결괏값을 넣어준다.

![](https://user-images.githubusercontent.com/42164422/105983224-c0949780-60db-11eb-81a9-14e0a092fbcf.png)

- 이제 메인 텍스쳐의 색상에 곱해주고, 추가로 Color Intensity 프로퍼티를 만들고 곱하여 간단히 전체 색상의 강도를 조절할 수 있도록 한다.

![](https://user-images.githubusercontent.com/42164422/105984407-6ac0ef00-60dd-11eb-95af-e46e20c1841a.png)

<br>

# 4. Specular
---
- 우선 블린 퐁 스페큘러를 Smoother에 적용한 서브그래프를 준비한다.
- offset 프로퍼티는 Vector3 타입으로, 스페큘러의 위치를 조정하기 위한 용도이다.

![](https://user-images.githubusercontent.com/42164422/105984978-37329480-60de-11eb-9c13-0d436439af26.png)

- 스페큘러 역시 Threshold와 Smooth 프로퍼티를 만들어 적용하며, 색상을 지정할 수 있도록 Color 프로퍼티도 추가하여 곱해준다.

![](https://user-images.githubusercontent.com/42164422/105985479-d9527c80-60de-11eb-8ec8-f564d6cbcc4e.png)

<br>

# 5. Rim Light
---
- 림라이트 서브그래프는 간단히 Fresnel 노드에 Smoother를 적용시키는 정도로 만들어주고 림라이트는 색상을 지정해서 사용하는 경우가 많았기 때문에 서브그래프 내에 색상 파라미터도 추가해주었다.

![](https://user-images.githubusercontent.com/42164422/105985881-77dedd80-60df-11eb-88ce-2fc29659ce62.png)

- 마찬가지로 Threshold, Smooth, Color 프로퍼티를 추가하여 적용해준다.

![](https://user-images.githubusercontent.com/42164422/105985990-9e9d1400-60df-11eb-8790-ebb68e7a49e0.png)

<br>

# 6. Specular, Rim Light 적용
---
- 색상의 결괏값에 더해준다.

![](https://user-images.githubusercontent.com/42164422/105988056-76fb7b00-60e2-11eb-8f26-a6e9f4845361.png)

<br>

# 7. Reflection
---
- 반사율을 조정하기 위한 Reflection(Vector1) 프로퍼티를 만들고, 반사 영역을 지정하기 위한 Reflection Map 텍스쳐 프로퍼티도 추가한다.
- Reflection Probe 노드를 이용해 간단히 반사를 추가할 수 있다.
- 6번의 결과에 Lerp를 이용하여 반사를 적용시켜준다.

![](https://user-images.githubusercontent.com/42164422/105988402-e70a0100-60e2-11eb-8cea-dba29a91d4db.png)

<br>

# 8. Shadow
---
- Shadow Cascade, Soft Shadow를 적용하기 위해 키워드를 추가한다.

![](https://user-images.githubusercontent.com/42164422/105988493-0acd4700-60e3-11eb-99b3-97dac2bba555.png)

- 그림자 적용 여부를 위한 Receive Shadow(Boolean) 프로퍼티를 추가한다.
- 기존에는 없는 기능이지만, 그림자 반응 민감도를 조정하기 위해 Shadow sensitivity(Vector1) 프로퍼티도 추가했다.

- 그림자가 생겼을 때는 스페큘러가 맺히지 않도록 하기 위해 스페큘러를 아래와 같이 수정한다.

![](https://user-images.githubusercontent.com/42164422/105988995-d4dc9280-60e3-11eb-9533-c56dd1f0d399.png)

- Reflection까지 적용한 결과에 그림자 조정 옵션을 적용하기 위해 아래처럼 추가하고 그래프를 완성한다.

![](https://user-images.githubusercontent.com/42164422/105989189-1a00c480-60e4-11eb-84a7-97f645b3ef50.png)

<br>

# 9. 완성된 그래프
---

![](https://user-images.githubusercontent.com/42164422/105994469-ff7e1980-60ea-11eb-974d-982cbbe5a303.png)

<br>

# Captures - Sphere
---
## [1] PBR과의 비교

- 색상을 그라데이션으로 자유롭게 적용하고, 스페큘러와 림라이트의 커스텀도 가능하기 때문에 당연히 더 예쁘다.

![](https://user-images.githubusercontent.com/42164422/105982128-3dbf0d00-60da-11eb-952b-d98579e7c0c9.png)

<br>

## [2] 다양한 그라데이션, NPR 효과

- 앞은 여러 색상을 혼합하였으며, 뒤는 각각의 Smooth값을 0으로 낮추어 셀 쉐이딩 같은 효과를 내주었다.

![](https://user-images.githubusercontent.com/42164422/105982196-50d1dd00-60da-11eb-97ab-85aa21650f31.png)

<br>

# Captures - Model(Robot Kyle)
---
## [1] PBR

![](https://user-images.githubusercontent.com/42164422/105961740-4277c700-60c2-11eb-902d-7faa9cc3d899.png)

## [2] Stylized Lit

- 네 번째 로봇은 모든 smooth 값을 0으로 낮추어 NPR 효과를 주었다.

![](https://user-images.githubusercontent.com/42164422/105962365-10b33000-60c3-11eb-811d-e5e835062d67.png)

## [3] Stylized Lit - 응용

- 다른 톤의 색상을 혼합하여 변화를 주었다.

![](https://user-images.githubusercontent.com/42164422/105962351-0db83f80-60c3-11eb-866e-bda95cd8e2ae.png)

<br>

# Captures - Shadow
---
- Shadow Sensitivity가 0.2일 때 그림자가 드리우는 모습

![](https://user-images.githubusercontent.com/42164422/105990613-1bcb8780-60e6-11eb-9a1e-8bdee1421a87.gif)

- 빛이 가려져 있을 때 Shadow Sensitivity를 0.0 ~ 1.0으로 조정하는 모습

![](https://user-images.githubusercontent.com/42164422/105990620-1e2de180-60e6-11eb-9daa-ab40ccdad056.gif)

<br>

# Future Works
---
- 각종 맵 텍스쳐 적용
  - 참고 세션처럼 PBR 쉐이더를 수정한 것이 아니라 Unlit 쉐이더에서 직접 만든 것인 만큼 노멀, 메탈릭, 오클루전 등 각종 텍스쳐들은 필요한 경우 추가해야 한다.

- 브러시 텍스쳐
  - 세션에서는 브러시 텍스쳐를 추가했지만, 여기서는 일단 공통적인 효과들만 적용하기 위해 브러시 텍스쳐는 추가하지 않았다.

<br>

# Reference
---
- <https://www.youtube.com/watch?v=cykinrW0pwQ>
- <https://github.com/madumpa/URP_StylizedLitShader>

<br>

# Download
---
- [2021_0126_Stylized Lit.zip](https://github.com/rito15/Images/files/5880324/2021_0126_Stylized.Lit.zip)