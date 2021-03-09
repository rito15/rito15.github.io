---
title: 물 쉐이더 만들기
author: Rito15
date: 2021-02-13 19:24:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, water]
math: true
mermaid: true
---

# 목표
---
- 서피스 쉐이더로 물 쉐이더 만들기

<br>

# 목차
---
- [1. 물 쉐이더 기초](#물-쉐이더-기초)
- [2. 프레넬 공식 적용](#프레넬-공식-적용)
- [3. 물 흐르게 하기](#물-흐르게-하기)
- [4. 스페큘러 적용](#스페큘러-적용)
- [5. 파도 만들기](#파도-만들기)
- [6. 투과율 제어하기](#투과율-제어하기)
- [7. 최종 결과](#최종-결과)

<br>

# 준비물
---
- 큐브맵 텍스쳐 기반 스카이박스
- 물 노멀맵 텍스쳐
- 물에 빠질 로봇

<br>

# 물 쉐이더 기초
---

메시는 유니티의 기본적인 Plane을 이용한다.

노멀은 노멀맵을 넣어 적용하고, 간단히 float로 타일링이 가능하도록 _Tiling 프로퍼티를 추가한다.

그리고 _Strength 프로퍼티를 통해 노멀의 강도를 조절할 수 있게 한다.

![image](https://user-images.githubusercontent.com/42164422/107851210-a8e34000-6e4b-11eb-8da1-d918d73f54cf.png){:.normal}

```hlsl
Shader "Rito/Water"
{
    Properties
    {
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Cube("Cube", Cube) = ""{}

        [Space]
        _Alpha("Alpha", Range(0, 1)) = 0.8
        _Tiling("Normal Tiling", Range(1, 10)) = 1
        _Strength("Normal Strength", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        #pragma target 3.0

        sampler2D _BumpMap;
        samplerCUBE _Cube;

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldRefl;
            INTERNAL_DATA
        };

        float _Alpha;
        float _Tiling;
        float _Strength;

        void surf (Input IN, inout SurfaceOutput o)
        {
            float3 reflColor = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling)) * _Strength;
            o.Emission = reflColor;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit"
}
```

<br>

# 프레넬 공식 적용
---

프레넬 공식은 시야 방향 벡터와 대상의 노멀 방향 벡터의 관계를 이용한 공식이다.

두 벡터가 이루는 각이 수직에 가까울수록 투과율이 감소하고, 반사율이 증가한다는 것을 의미한다.

간단히 `1 - saturate(dot(N, V))`로 표현하며, 이를 다양하게 응용할 수 있다.

![2021_0213_Fresnel1](https://user-images.githubusercontent.com/42164422/107852230-f8793a00-6e52-11eb-8822-3a245ae2a624.gif){:.normal}

```hlsl

// Properties
_FresnelPower("Fresnel Power", Range(0, 10)) = 3
_FresnelIntensity("Fresnel Intensity", Range(0, 5)) = 1

// ...

void surf (Input IN, inout SurfaceOutput o)
{
    float3 reflColor = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
    o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling)) * _Strength;
    
    // Fresnel
    float ndv = saturate(dot(normalize(o.Normal), IN.viewDir));
    float fresnel = 1. - pow(ndv, _FresnelPower) * _FresnelIntensity;
    
    o.Emission = reflColor * _CubeIntensity * fresnel + _CubeBrightness;
    o.Alpha = _Alpha * (fresnel + _AlphaAdd);
}
```

<br>

# 물 흐르게 하기
---

물을 흐르게 하는 것은 정말 간단하다.

노멀 텍스쳐를 샘플링할 때 uv에 시간을 더해주면 된다.

![2021_0214_WaterFlows](https://user-images.githubusercontent.com/42164422/107855372-2ebfb500-6e65-11eb-9abe-2e365fa439b7.gif){:.normal}

그런데 이렇게 하면 흐른다는 느낌보다 '지나간다'는 느낌이 강하다.

그래서 텍스쳐를 두 번 샘플링하여, 서로 반대 방향으로 흐르게 해주고 두 결과의 평균 값을 사용한다.

![2021_0214_WaterFlows2](https://user-images.githubusercontent.com/42164422/107855374-32ebd280-6e65-11eb-9584-0b798957cce4.gif){:.normal}

이제 정말로 물이 흐르는 듯한 느낌이 든다.

```hlsl
// Properties
_FlowDirX("Flow Direction X", Range(-1, 1)) = 1
_FlowDirY("Flow Direction Y", Range(-1, 1)) = 0
_FlowSpeed("Flow Speed", Range(0, 10)) = 1

// ...

void surf (Input IN, inout SurfaceOutput o)
{
    // Flow
    float2 flowDir = normalize(float2(_FlowDirX, _FlowDirY));
    float2 flow = flowDir * _Time.x * _FlowSpeed;
    
    float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling + flow)) * _Strength;
    float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling - flow * 0.3)) * _Strength * 0.5;
    
    float3 reflColor = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
    o.Normal = (normal1 + normal2) * 0.5;
    
    // Fresnel
    float ndv = saturate(dot(normalize(o.Normal), IN.viewDir));
    float fresnel = 1. - pow(ndv, _FresnelPower) * _FresnelIntensity;
    
    o.Emission = reflColor * _CubeIntensity * fresnel + _CubeBrightness;
    o.Alpha = _Alpha * (fresnel + _AlphaAdd);
}
```

<br>

# 스페큘러 적용
---

스페큘러를 이용해 물 표면에 빛이 예쁘게 산란되도록 만들 수 있다.

기존에 사용하던 Lambert 대신, 커스텀 라이트 함수를 만들어 적용한다.

스페큘러는 저렴한 블린 퐁 공식을 사용하였다.

![2021_0214_WaterSpecular](https://user-images.githubusercontent.com/42164422/107856162-bad3db80-6e69-11eb-9847-473c933d5c6d.gif){:.normal}

```hlsl
// Properties
_SpColor("Specular Color", Color) = (1, 1, 1, 1)
_SpPower("Specular Power", Range(10, 500)) = 150
_SpIntensity("Specular Intensity", Range(0, 10)) = 3

// ...

#pragma surface surf WaterSpecular alpha:fade

// ...

float4 LightingWaterSpecular(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
{
    float3 H = normalize(lightDir + viewDir); // Binn Phong
    float spec = saturate(dot(H, s.Normal));
    spec = pow(spec, _SpPower);
    
    float4 col;
    col.rgb = spec * _SpColor.rgb * _SpIntensity * _LightColor0;
    col.a = s.Alpha + spec;
    
    return col;
}

```

<br>

# 파도 만들기
---

거창한 파도는 아니고, 물이 더 역동적으로 일렁이게끔 하려고 한다.

우선 하나만 사용하던 Plane을 복제하여 4개로 만든다.

![image](https://user-images.githubusercontent.com/42164422/107856318-a8a66d00-6e6a-11eb-8001-183f3732fe57.png){:.normal}

그리고 버텍스 함수를 추가하고, 정점 Y 위치를 uv.x만큼 더해준다.

```hlsl
#pragma surface surf WaterSpecular alpha:fade vertex:vert

void vert(inout appdata_full v)
{
    v.vertex.y += v.texcoord.x;
}
```

![image](https://user-images.githubusercontent.com/42164422/107856405-4ef27280-6e6b-11eb-9091-9beeadfee5c8.png){:.normal}

그럼 요렇게 경사가 생긴다.

이번에는 Plane끼리 연결시킬 목적으로 이렇게 수정한다.

```hlsl
v.vertex.y += abs(v.texcoord.x * 2. - 1.);
```

![image](https://user-images.githubusercontent.com/42164422/107856458-a7c20b00-6e6b-11eb-8870-ba487a6f25dc.png){:.normal}

근데 곰곰이 생각해보니, 메시가 더 조밀한 Plane을 만들어 쓰거나 테셀레이션을 넣으면 굳이 번거롭게 Plane을 여러 장 붙여 쓸 필요가 없을 것 같다.

그래서 바로 만들어 왔다.

- [Custom Plane Mesh Generator(Link)](../custom-plane-mesh-generator/)

![image](https://user-images.githubusercontent.com/42164422/107857915-93364080-6e74-11eb-8578-d5855f9247ae.png){:.normal}

그리고 이번엔 프로퍼티를 넣어 각종 옵션들을 제어할 수 있게 해주고,

uv의 x와 y를 이용해 모든 방향으로 파도를 설정할 수 있게 해준다.

그리고 부드럽게 연결되도록 sin() 함수에 넣어준다.

![](https://user-images.githubusercontent.com/42164422/107857293-f920c900-6e70-11eb-90dc-7e7a6e6c9ab3.png){:.normal}

```hlsl
// Properties
_WaveCount("Wave Count", Int) = 0
_WaveHeight("WaveHeight", Range(0, 10)) = 1
_WaveDirX("Wave Direction X", Range(-1, 1)) = 0.5
_WaveDirY("Wave Direction Y", Range(-1, 1)) = 1
_WaveSpeed("Wave Speed", Range(0, 10)) = 1

// ...

#pragma surface surf WaterSpecular alpha:fade vertex:vert

// ...

float _WaveHeight, _WaveDirX, _WaveDirY, _WaveSpeed;
int _WaveCount;

void vert(inout appdata_full v)
{
    float t = _Time.y * _WaveSpeed;
    float2 waveDir = normalize(float2(_WaveDirX, _WaveDirY));

    float wave;
    wave  = sin(abs(v.texcoord.x * waveDir.x) * _WaveCount + t) * _WaveHeight;
    wave += sin(abs(v.texcoord.y * waveDir.y) * _WaveCount + t) * _WaveHeight;

    v.vertex.y = wave / 2.;
}

// ...
```

<br>

![2021_0214_WaterFinal](https://user-images.githubusercontent.com/42164422/107858268-c679cf00-6e76-11eb-939a-8da5f56cf8bd.gif){:.normal}

![2021_0214_WaterFinal2](https://user-images.githubusercontent.com/42164422/107858345-00e36c00-6e77-11eb-91af-1d4f278f31d5.gif){:.normal}

<br>

# 투과율 제어하기
---

![](https://user-images.githubusercontent.com/42164422/107852304-632a7580-6e53-11eb-830c-0a3b69710598.png){:.normal}

지금까지 노멀맵에 의해 분산된 노멀 값을 기반으로 투과율을 설정했더니, 의도와 전혀 다른 결과가 나왔다.

마치 물 표면에 오클루전이 자글자글하게 낀 것 같은 느낌이었다.

따라서 노멀맵 적용 이전의 노멀값과 뷰 벡터를 이용해 투과율을 제어하도록 변경하였다.

![2021_0214_Penet](https://user-images.githubusercontent.com/42164422/107860874-43ac4080-6e85-11eb-8cb6-f5ce42bbdc3a.gif){:.normal}

```hlsl
[Space, Header(Penetration Options)]
_Penetration("Penetration", Range(0, 1)) = 0.2 // 투과율
_PenetrationThreshold("Penetration Threshold", Range(0, 50)) = 5

/* surf 함수 */
// originNormal : 노멀맵 적용하지 않은 초기 노멀벡터
float penet = pow(saturate(dot(originNormal, IN.viewDir)), _PenetrationThreshold) * _Penetration;
o.Alpha = _Alpha - penet;
```

<br>

# 최종 결과
---

![2021_0214_WaterFinal3](https://user-images.githubusercontent.com/42164422/107861076-a4884880-6e86-11eb-9480-9f7d383d96b1.gif)

```hlsl
Shader "Rito/Water"
{
    Properties
    {
        [Header(Textures)]
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Cube("Cube", Cube) = ""{}

        [Space, Header(Basic Options)]
        _Tint("Tint Color", Color) = (0, 0, 0.01, 1)
        _Alpha("Alpha", Range(0, 1)) = 1
        _CubeIntensity("CubeMap Intensity", Range(0, 2)) = 1
        _CubeBrightness("CubeMap Brightness", Range(-2, 2)) = 0
        
        [Space, Header(Penetration Options)]
        _Penetration("Penetration", Range(0, 1)) = 0.2 // 투과율
        _PenetrationThreshold("Penetration Threshold", Range(0, 50)) = 5

        [Space, Header(Normal Map Options)]
        _Tiling("Normal Tiling", Range(1, 10)) = 2
        _Strength("Normal Strength", Range(0, 2)) = 1

        [Space, Header(Fresnel Options)]
        _FresnelPower("Fresnel Power", Range(0, 10)) = 3
        _FresnelIntensity("Fresnel Intensity", Range(0, 5)) = 1

        [Space, Header(Lighting Options)]
        _SpColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpPower("Specular Power", Range(10, 500)) = 300
        _SpIntensity("Specular Intensity", Range(0, 10)) = 2

        [Space, Header(Flow Options)]
        _FlowDirX("Flow Direction X", Range(-1, 1)) = -1
        _FlowDirY("Flow Direction Y", Range(-1, 1)) = 1
        _FlowSpeed("Flow Speed", Range(0, 10)) = 1

        [Space, Header(Wave Options)]
        _WaveCount("Wave Count", Int) = 8
        _WaveHeight("WaveHeight", Range(0, 10)) = 0.1
        _WaveDirX("Wave Direction X", Range(-1, 1)) = -1
        _WaveDirY("Wave Direction Y", Range(-1, 1)) = 1
        _WaveSpeed("Wave Speed", Range(0, 10)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM
        #pragma surface surf WaterSpecular alpha:fade vertex:vert
        #pragma target 3.0

        sampler2D _BumpMap;
        samplerCUBE _Cube;

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldRefl;
            float3 viewDir;
            float3 Normal;
            INTERNAL_DATA
        };

        float _Alpha, _Penetration, _PenetrationThreshold;
        float _CubeIntensity, _CubeBrightness;
        float _Tiling, _Strength;
        float _FresnelPower, _FresnelIntensity;
        float _FlowDirX, _FlowDirY, _FlowSpeed;
        float4 _Tint, _SpColor;
        float _SpPower, _SpIntensity, _DiffIntensity;
        float _WaveHeight, _WaveDirX, _WaveDirY, _WaveSpeed;
        int _WaveCount;

        // Wave
        void vert(inout appdata_full v)
        {
            float t = _Time.y * _WaveSpeed;
            float2 waveDir = normalize(float2(_WaveDirX, _WaveDirY));

            float wave;
            wave  = sin(abs(v.texcoord.x * waveDir.x) * _WaveCount + t) * _WaveHeight;
            wave += sin(abs(v.texcoord.y * waveDir.y) * _WaveCount + t) * _WaveHeight;

            v.vertex.y = wave / 2.;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float3 originNormal = o.Normal;
            float3 reflColor = texCUBE(_Cube, WorldReflectionVector(IN, originNormal));

            // Flow
            float2 flowDir = normalize(float2(_FlowDirX, _FlowDirY));
            float2 flow = flowDir * _Time.x * _FlowSpeed;
            
            float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling + flow));
            float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling * 0.5 - flow * 0.3)) * 0.5;
            
            o.Normal = (normal1 + normal2) * 0.5;

            // Fresnel
            float ndv = saturate(dot(o.Normal * _Strength, IN.viewDir));
            float fresnel = 1. - pow(ndv, _FresnelPower) * _FresnelIntensity;
            
            // Penetration
            float penet = pow(saturate(dot(originNormal, IN.viewDir)), _PenetrationThreshold) * _Penetration;

            // FInal
            o.Emission = (_Tint * 0.5) + (reflColor * _CubeIntensity * fresnel) + _CubeBrightness;
            o.Alpha = _Alpha - penet;
        }

        float4 LightingWaterSpecular(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float3 H = normalize(lightDir + viewDir); // Binn Phong
            float spec = saturate(dot(H, s.Normal));
            spec = pow(spec, _SpPower);

            float4 col;
            col.rgb = spec * _SpColor.rgb * _SpIntensity * _LightColor0;
            col.a = s.Alpha + spec;

            return col;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit"
}
```

<br>

# References
---
- 정종필, 테크니컬 아티스트를 위한 유니티 쉐이더 스타트업, 비엘북스, 2017