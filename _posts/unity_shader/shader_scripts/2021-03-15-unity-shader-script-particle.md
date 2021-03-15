---
title: Particle Shader
author: Rito15
date: 2021-03-15 16:00:00 +09:00
categories: [Unity Shader, Shader Scripts]
tags: [unity, csharp, shader, shaderlab]
math: true
mermaid: true
---

# Summary
---

- 블렌딩 옵션 선택 가능한 파티클 쉐이더(기본 : Additive)


# Source Code
---

```hlsl
Shader "Custom/Particle"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 2)) = 1
        _MainTex("Albedo (RGB)", 2D) = "white"{}
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode", Float) = 5 // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend Mode", Float) = 1 // One
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        Blend [_SrcBlend] [_DstBlend]
        Zwrite off
        Cull off

        CGPROGRAM
        #pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow

        sampler2D _MainTex;
        float4 _TintColor;
        float _Intensity;

        struct Input
        {
            float2 uv_MainTex;
            float4 color:COLOR; // Vertex Color
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            c = c * _TintColor * IN.color;
            o.Emission = c.rgb * _Intensity;
            o.Alpha = c.a;
        }

        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
}
```


# Alpha Blending Combinations
---

### Alpha Blending
 - `Blend SrcAlpha OneMinusSrcAlpha`

### Additive
 - `Blend SrcAlpha One`

### Additive 2 (Additive No Alpha Black is Transparent)
 - `Blend One One`

### Multiplicative
 - `Blend DstColor Zero`

### 2x Multiplicative
 - `Blend DstColor SrcColor`