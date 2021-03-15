---
title: Stencil Silhouette Shader
author: Rito15
date: 2021-03-15 17:20:00 +09:00
categories: [Unity Shader, Shader Scripts]
tags: [unity, csharp, shader, shaderlab]
math: true
mermaid: true
---

# Summary
---

- 가려질 경우 단색이 드러나는 실루엣 쉐이더
- Ref 2번 사용


# Preview
---

![2021_0304_Stencil02](https://user-images.githubusercontent.com/42164422/109963897-49809d80-7d30-11eb-8fbc-d2e6e32b21e8.gif)


# Source Code
---

<details>
<summary markdown="span"> 
Silhouette.shader
</summary>

```cs
Shader "Custom/Silhouette"
{
    Properties
    {
        _SilhouetteColor ("Silhouette Color", Color) = (1, 0, 0, 0.5)

        [Space]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        /****************************************************************
        *                            Pass 1
        *****************************************************************
        * - 메인 패스
        * - 스텐실 버퍼에 Ref 2 기록
        *****************************************************************/
        ZWrite On

        Stencil
        {
            Ref 2
            Pass Replace // Stencil, Z Test 모두 성공한 부분에 2 기록
        }

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0
        
        fixed4 _Color;
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG

        /****************************************************************
        *                            Pass 2
        *****************************************************************
        * - Zwrite off
        * - ZTest Greater : 다른 물체에 가려진 부분에 단색 실루엣 렌더링
        * - Stencil NotEqual : 다른 실루엣이 그려진 부분에 덮어쓰지 않기
        *****************************************************************/
        ZWrite Off
        ZTest Greater // 가려진 부분에 항상 그린다

        Stencil
        {
            Ref 2
            Comp NotEqual // 패스 1에서 렌더링 성공한 부분에는 그리지 않도록 한다
        }

        CGPROGRAM
        #pragma surface surf nolight alpha:fade noforwardadd nolightmap noambient novertexlights noshadow
        
        struct Input { float4 color:COLOR; };
        float4 _SilhouetteColor;
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = _SilhouetteColor.rgb;
            o.Alpha = _SilhouetteColor.a;
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(s.Emission, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

</details>

