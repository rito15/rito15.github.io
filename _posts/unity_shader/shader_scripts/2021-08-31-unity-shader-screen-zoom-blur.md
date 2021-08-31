---
title: Screen Effect - Zoom Blur
author: Rito15
date: 2021-08-31 21:33:00 +09:00
categories: [Unity Shader, Shader Scripts]
tags: [unity, csharp, shader, shaderlab]
math: true
mermaid: true
---

# Summary
---

- 화면 중심에서부터 바깥 방향으로 번져나가는 블러 이펙트

- 스크린 이펙트 적용 애셋 : [Link](https://rito15.github.io/posts/unity-screen-effect-controller/)

<br>

# Properties
---

- `Center Pos`
  - 블러 중심 위치(벡터2)
  - 기본값 : (0.5, 0.5)

- `Sample Count`
  - 블러 계산(샘플링) 횟수
  - 값이 커질수록 성능 저하

- `Blur Size`
  - 블러 강도
  - 범위 : 0 ~ 100

- `Area Range`
  - 블러가 적용될 범위 크기
  - 바깥에서부터 화면 중심부로 범위가 증가한다.
  - 범위 : 0 ~ 1

- `Area Smoothness`
  - 블러가 적용되는 영역과 미적용 영역 사이의 부드러운 정도
  - 범위 : 0 ~ 1

<br>

# Preview
---

![2021_0831_ScreenEffect_ZoomBlur](https://user-images.githubusercontent.com/42164422/131504136-8c5a541c-d525-4d15-9d61-44d6516db319.gif)

<br>

# Download
---

- [2021_0831_Screen Effect_Zoom Blur.zip](https://github.com/rito15/Images/files/7083980/2021_0831_Screen.Effect_Zoom.Blur.zip)

<br>

# Source Code
---

<details>
<summary markdown="span"> 
...
</summary>

```hlsl
// 출처 : https://blog.naver.com/mnpshino/221478999495

Shader "Rito/Screen Zoom Blur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _CenterPos("Center Pos", Vector) = (0.5, 0.5, 0., 0.)
        _SampleCount("Sample Count", Float) = 8
        _BlurSize("Blur Size", Range(0, 100)) = 20
        _AreaRange("Area Range", Range(0, 1)) = 0.5
        _AreaSmoothness("Area Smoothness", Range(0, 1)) = 0.5
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
            half4 _MainTex_TexelSize;

            half2 _CenterPos;
            half _SampleCount;
            half _BlurSize;
            half _AreaRange;
            half _AreaSmoothness;

            half4 frag (v2f i) : SV_Target
            {
                half4 mainCol = tex2D(_MainTex, i.uv);

                half2 uv2 = i.uv - _CenterPos;
                half4 col = half4(0., 0., 0., 1.);

                _AreaSmoothness += 0.001;

                half range = (1. - (_AreaRange + _AreaSmoothness)) * (1. + _AreaSmoothness);
                half circleRange = smoothstep(range, range + _AreaSmoothness, length(uv2));

                for(int a = 0; a < _SampleCount; a++)
                {
                    half scale = 1. - _BlurSize * _MainTex_TexelSize * a;
                    col.rgb += tex2D(_MainTex, uv2 * scale + _CenterPos).rgb;
                }

                col.rgb /= _SampleCount;

                return lerp(mainCol, col, circleRange);
            }
            ENDCG
        }
    }
}
```

</details>


# References
---
- <https://blog.naver.com/mnpshino/221478999495>