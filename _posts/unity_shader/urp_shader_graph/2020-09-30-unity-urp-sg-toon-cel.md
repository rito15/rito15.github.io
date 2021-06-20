---
title: Toon(Cel)
author: Rito15
date: 2020-09-30 00:00:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

- 셀 셰이딩을 통한 카툰 라이팅 표현


# Preview
---

![image](https://user-images.githubusercontent.com/42164422/111077154-c979e500-8532-11eb-8e80-8b3041c31115.png)

# Options
---

|프로퍼티|설명
|---|---|
|`Main Texture`|메인 텍스쳐|
|`Apply Main Light Color`|메인 라이트의 색상 적용 여부 설정|
|`Cel Count`|셀 셰이딩 분할 개수|
|`Threshold`|셀 셰이딩 기준점 설정|
|`Shadow Color`|그림자 색상|
|`Shadow Size`|그림자 영역 크기|
|`Shadow Blend`|부드러운 그림자 적용 정도|
|`Rim Color`|림라이트 색상|
|`Rim Range`|림라이트 영역 크기|
|`Rim Blend`|부드러운 림라이트 적용 정도|


# Graph
---

![image](https://user-images.githubusercontent.com/42164422/122684757-6048f280-d242-11eb-9a55-723fa0b6f583.png)

![image](https://user-images.githubusercontent.com/42164422/122684743-3bed1600-d242-11eb-8740-00416c544bd6.png)

```hlsl
// Custom Function : MainLight.hlsl

void GetLightingInformation_float(out float3 Direction, out float3 Color,out float Attenuation)
{
    #ifdef SHADERGRAPH_PREVIEW
        Direction = float3(-0.5,0.5,-0.5);
        Color = float3(1,1,1);
        Attenuation = 0.4;
    #else
        Light light = GetMainLight();
        Direction = light.direction;
        Attenuation = light.distanceAttenuation;
        Color = light.color;
    #endif
}
```


# Download
---
- [2020_0930_Toon(Cel).zip](https://github.com/rito15/Images/files/6137165/2020_0930_Toon.Cel.zip)

