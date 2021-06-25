---
title: 유니티 쉐이더 모음 [예정]
author: Rito15
date: 2021-02-06 01:25:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, transparent, stencil]
math: true
mermaid: true
---

# Render Depth 
---

- 단순히 뎁스만 색상으로 보여주는 쉐이더

![image](https://user-images.githubusercontent.com/42164422/107067589-d49a7080-6822-11eb-95d0-f8b4a103bece.png){:.normal}

```hlsl
Shader "Render Depth"
{
    Properties
    {
        _Multiplier("Multiplier", Float) = 50
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass 
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float depth : TEXCOORD0;
            };

            float _Multiplier;

            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.depth = length(mul(UNITY_MATRIX_MV, v.vertex)) * _ProjectionParams.w;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return fixed4(i.depth, i.depth, i.depth, 1) * _Multiplier;
            }
            ENDCG
        }
    }
}
```
