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


# Graph
---

![image](https://user-images.githubusercontent.com/42164422/122684678-c41eeb80-d241-11eb-9120-1caba8a2319b.png)


<details>
<summary markdown="span"> 
OutlineObject.hlsl
</summary>

```hlsl
// https://alexanderameye.github.io/outlineshader.html
//
// 함수명 : OutlineObject
// 
// [파라미터]
// float2 UV : Screen Position Node의 출력을 넣어줌
// float OutlineThickness : 0~10 정도의 값 사용, 2 단위로 굵기 증가
// float DepthSensitivity : 0~1 범위. 이상적인 값은 0.2
// float NormalsSensitivity : 0~1 범위. 딱히 영향 안주는듯
//
// [준비]
// URP Asset의 Depth Texture 체크, MSAA 2x 이상 사용
//
// [적용법]
// Lerp의 A에는 메인 텍스쳐
// B에는 Outline 색상
// T에는 이 함수를 사용한 Custom Function의 Output을 넣어줌
// Lerp의 Out을 Albedo에 적용하면 됨


TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);
float4 _CameraDepthTexture_TexelSize;

TEXTURE2D(_CameraDepthNormalsTexture);
SAMPLER(sampler_CameraDepthNormalsTexture);
 
float3 DecodeNormal(float4 enc)
{
    float kScale = 1.7777;
    float3 nn = enc.xyz*float3(2*kScale,2*kScale,0) + float3(-kScale,-kScale,1);
    float g = 2.0 / dot(nn.xyz,nn.xyz);
    float3 n;
    n.xy = g*nn.xy;
    n.z = g-1;
    return n;
}

void OutlineObject_float(float2 UV, float OutlineThickness, float DepthSensitivity, float NormalsSensitivity, out float Out)
{
    float halfScaleFloor = floor(OutlineThickness * 0.5);
    float halfScaleCeil = ceil(OutlineThickness * 0.5);
    
    float2 uvSamples[4];
    float depthSamples[4];
    float3 normalSamples[4];

    uvSamples[0] = UV - float2(_CameraDepthTexture_TexelSize.x, _CameraDepthTexture_TexelSize.y) * halfScaleFloor;
    uvSamples[1] = UV + float2(_CameraDepthTexture_TexelSize.x, _CameraDepthTexture_TexelSize.y) * halfScaleCeil;
    uvSamples[2] = UV + float2(_CameraDepthTexture_TexelSize.x * halfScaleCeil, -_CameraDepthTexture_TexelSize.y * halfScaleFloor);
    uvSamples[3] = UV + float2(-_CameraDepthTexture_TexelSize.x * halfScaleFloor, _CameraDepthTexture_TexelSize.y * halfScaleCeil);

    for(int i = 0; i < 4 ; i++)
    {
        depthSamples[i] = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uvSamples[i]).r;
        normalSamples[i] = DecodeNormal(SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uvSamples[i]));
    }

    // Depth
    float depthFiniteDifference0 = depthSamples[1] - depthSamples[0];
    float depthFiniteDifference1 = depthSamples[3] - depthSamples[2];
    float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100;
    float depthThreshold = (1/DepthSensitivity) * depthSamples[0];
    edgeDepth = edgeDepth > depthThreshold ? 1 : 0;

    // Normals
    float3 normalFiniteDifference0 = normalSamples[1] - normalSamples[0];
    float3 normalFiniteDifference1 = normalSamples[3] - normalSamples[2];
    float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));
    edgeNormal = edgeNormal > (1/NormalsSensitivity) ? 1 : 0;

    float edge = max(edgeDepth, edgeNormal);
    Out = edge;
}
```

</details>


# Download
---
- [2020_1008_OutlineObject.zip](https://github.com/rito15/Images/files/6137335/2020_1008_OutlineObject.zip)


# References
---
- <https://alexanderameye.github.io/outlineshader.html>