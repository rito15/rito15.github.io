---
title: Unlit으로 만드는 Custom Lit Shadergraph
author: Rito15
date: 2020-11-16 17:14:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics]
math: true
mermaid: true
---

# 목표
---
- URP 쉐이더그래프 중 Unlit 그래프를 이용해 직접 Lit 쉐이더 만들기

<br>

# 1. Diffuse 구현
---
- 커스텀 함수를 이용하여 메인라이트의 방향, 색상, 감쇠를 얻어낸다.

![](https://user-images.githubusercontent.com/42164422/105636772-2ea74780-5ead-11eb-9533-e4094fba622c.png)

### Custom_Mainlight.hlsl

```hlsl
void MainLight_half(float3 WorldPos, out half3 Direction, out half3 Color, out half DistanceAtten, out half ShadowAtten)
{
    #if SHADERGRAPH_PREVIEW
        Direction = half3(0.5, 0.5, 0);
        Color = 1;
        DistanceAtten = 1;
        ShadowAtten = 1;
    #else
        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
        Light mainLight = GetMainLight(shadowCoord);
        Direction = mainLight.direction;
        Color = mainLight.color;
        DistanceAtten = mainLight.distanceAttenuation;

        #if !defined(_MAIN_LIGHT_SHADOWS) || defined(_RECEIVE_SHADOWS_OFF)
            ShadowAtten = 1.0h;
        #endif
            ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
            half shadowStrength = GetMainLightShadowStrength();
            ShadowAtten = SampleShadowmap(shadowCoord,
                TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture),
                shadowSamplingData, shadowStrength, false
            );
    #endif
}
```

<br>

- 주변광을 얻어와야 하므로, 주변광을 얻기 위한 커스텀 함수와 서브 노드를 이용한다.

- Sub_AdditionalLights
![](https://user-images.githubusercontent.com/42164422/105636788-467ecb80-5ead-11eb-839e-edfdcb41ba3d.png)

- 여기에 들어가는 커스텀 함수 :

### Custom_AdditionalLights.hlsl

```hlsl
void AdditionalLights_half(half3 WorldPos, half3 WorldNormal, half3 WorldView, out half3 Diffuse)
{
    half3 diffuseColor = 0;
    
#ifndef SHADERGRAPH_PREVIEW
    WorldNormal = normalize(WorldNormal);
    WorldView = SafeNormalize(WorldView);
    int pixelLightCount = GetAdditionalLightsCount();

    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
    }
#endif

    Diffuse = diffuseColor;
}
```

<br>
![](https://user-images.githubusercontent.com/42164422/105636784-4383db00-5ead-11eb-87cb-e85a9ca16604.png)

- PBR 라이팅 공식을 이용해 조립한다.

![](https://user-images.githubusercontent.com/42164422/105636782-3ff05400-5ead-11eb-9ba9-52cd27ff747b.png)

<br>

# 2. Soft Shadow 적용
---
- 이대로는 하드 쉐도우만 적용되므로, 키워드를 이용해 소프트 쉐도우를 적용한다.
- Keyword - Boolean : Shader Feature, Global
  - _MAIN_LIGHT_SHADOWS_CASCADE
  - _SHADOWS_SOFT

![](https://user-images.githubusercontent.com/42164422/105636797-4979bc00-5ead-11eb-87fe-5988de4e3364.png)

<br>

# 3. Fog 적용
---

![](https://user-images.githubusercontent.com/42164422/105636800-4bdc1600-5ead-11eb-87b9-6b11d8b767e6.png)

![](https://user-images.githubusercontent.com/42164422/105636824-6adaa800-5ead-11eb-99f0-d7113ec00d11.png)

![](https://user-images.githubusercontent.com/42164422/105637321-459b6900-5eb0-11eb-8f37-c9ed352cae5d.png)

- 여기에 필요한 커스텀 함수 2가지

### Custom_ComputeFogFactor.hlsl

```hlsl
void ComputeFogFactor_float(in float z, out float fogFactor)
{
    float clipZ_01 = UNITY_Z_0_FAR_FROM_CLIPSPACE(z);

#if defined(FOG_LINEAR)
    fogFactor = saturate(clipZ_01 * unity_FogParams.z + unity_FogParams.w);

#elif defined(FOG_EXP) || defined(FOG_EXP2)
    fogFactor = (unity_FogParams.x * clipZ_01);

#else
    fogFactor = 0.0h;

#endif
}
```

### Custom_ComputeFogIntensity.hlsl

```hlsl
void ComputeFogIntensity_float(in float fogFactor, out float fogIntensity)
{
    fogIntensity = 1;

#if defined(FOG_EXP)
    fogIntensity = saturate(exp2(-fogFactor));

#elif defined(FOG_EXP2)
    fogIntensity = saturate(exp2(-fogFactor * fogFactor));

#elif defined(FOG_LINEAR)
    fogIntensity = fogFactor;

#endif
}
```

# 4. Specular, Rim Light 추가
---
- 쉐이더그래프의 월드 Normal, View 벡터들은 크기가 1이 아니므로

  반드시 정규화시켜서 사용해야 한다.

- 블린 퐁 스페큘러와 림라이트까지 적용한 커스텀 릿 쉐이더를 완성하였다.

![](https://user-images.githubusercontent.com/42164422/105636833-729a4c80-5ead-11eb-8196-87b5c6ce6ca7.png)

<br>

# Reference
---
- <https://www.youtube.com/watch?v=j0uInkqU3Pk>

<br>

# 5. Download
---
- [Unlit_Custom_Lit_ShaderGraph](https://github.com/rito15/Images/files/5862666/2021_0117_Unlit_Custom_Lit.zip)