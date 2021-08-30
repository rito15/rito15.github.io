---
title: Screen Effect - Blur
author: Rito15
date: 2021-08-30 22:11:00 +09:00
categories: [Unity Shader, Shader Scripts]
tags: [unity, csharp, shader, shaderlab]
math: true
mermaid: true
---

# Summary
---

- 블러 이펙트

- 스크린 이펙트 적용 애셋 : [Link](https://rito15.github.io/posts/unity-screen-effect-controller/)

<br>

# Properties
---

- `Resolution` : 블러 적용 해상도(기본 0.5)

- `Intensity` : 블러 적용 강도

- `Blur Area Mask` : 블러 적용 영역을 제한할 수 있는 마스크

<br>

# Preview
---

## **[1] 블러 미적용**

![image](https://user-images.githubusercontent.com/42164422/131344640-d4ac64a0-51df-43a8-a334-6dcdbe3e62ea.png)

<br>

## **[2] 블러 적용**

- **Resolution : 0.5**
- **Intensity : 0.4**

![image](https://user-images.githubusercontent.com/42164422/131344711-b8feaed7-b170-437a-ac6e-356a9ccdad5e.png)

<br>

## **[3] 마스크 사용**

- 사용된 마스크

![image](https://user-images.githubusercontent.com/42164422/131345966-1cf7c046-7197-4b9b-9a5b-9eb838fbbb1f.png)

- 결과

![2021_0830_ScreenEffect_Blur](https://user-images.githubusercontent.com/42164422/131345689-c342d0bd-4167-447b-b104-47f2520325c3.gif)

<br>

# Download
---

- [2021_0830_Screen Effect_Blur.zip](https://github.com/rito15/Images/files/7076981/2021_0830_Screen.Effect_Blur.zip)

<br>

# Source Code
---

<details>
<summary markdown="span"> 
...
</summary>

```hlsl
Shader "Rito/Screen Blur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Blur Area Mask", 2D) = "white" {}
        _Resolution("Resolution", Range(0, 1)) = 0.5
        _Intensity("Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _MaskTex; // 블러 영역 마스크
            float _Resolution;
            float _Intensity;

            #define RANDOM_SEED 426.791

            static const half2 dir[8] = 
            {
                half2(1., 0.),
                half2(-1., 0.),
                half2(0., 1.),
                half2(0., -1.),
                half2(1., 1.),
                half2(-1., 1.),
                half2(1., 1.),
                half2(1., -1.),
            };

            float2 GetRandomDir(float2 uv, uint i)
            {
                float r1 = (uv.x * uv.y);
                float r2 = ((1. - uv.x) * uv.y);
                float r3 = (uv.x * (1. - uv.y));
                float r4 = ((1. - uv.x) * (1. - uv.y));

                float r = frac((r1 + r2 + r3 + r4) * RANDOM_SEED * i);
                float2 d = dir[i % 8] * r;
                // i % 2 : 좌우
                // i % 4 : 상하좌우
                // i % 8 : 8방향

                return d;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                uint sampleCount = (uint)(_Resolution * 64.);

                fixed4 mainColor = tex2D(_MainTex, i.uv);

                if(_Intensity <= 0.0 || _Resolution <= 0.0)
                    return mainColor;

                float4 col = 0.;
                for(uint index = 0; index < sampleCount; index++)
                {
                    float2 uv = i.uv - GetRandomDir(i.uv, index) * _Intensity * 0.05;
                    col += tex2D(_MainTex, uv);
                }
                
                fixed4 mask = tex2D(_MaskTex, i.uv);

                return lerp(mainColor, (col / sampleCount), mask);
            }
            ENDCG
        }
    }
}
```

</details>

