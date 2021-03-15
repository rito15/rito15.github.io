---
title: Stencil Mask Shader
author: Rito15
date: 2021-03-15 17:10:00 +09:00
categories: [Unity Shader, Shader Scripts]
tags: [unity, csharp, shader, shaderlab]
math: true
mermaid: true
---

# Summary
---

- 스텐실 마스크 & 마스크로 가려야 드러나는 타겟 쉐이더
- Ref 1번 사용


# Preview
---

![2021_0304_Stencil01](https://user-images.githubusercontent.com/42164422/109963895-48e80700-7d30-11eb-8de2-8ec9ff401f36.gif)


# Source Code
---

<details>
<summary markdown="span"> 
StencilTarget01.shader
</summary>

```hlsl
Shader "Custom/StencilTarget01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Stencil
        {
            Ref 1
            Comp Equal // 스텐실 버퍼가 1인 곳에만 렌더링
        }

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

```

</details>

<br>

<details>
<summary markdown="span"> 
StencilMask01.shader
</summary>

```hlsl
Shader "Custom/StencilMask01"
{
    Properties {}
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque"
            "Queue"="Geometry-1" // 반드시 대상보다 먼저 그려져야 하므로
        }

        Stencil
        {
            Ref 1
            Comp Never   // 항상 렌더링 하지 않음
            Fail Replace // 렌더링 실패한 부분의 스텐실 버퍼에 1을 채움
        }

        CGPROGRAM
        #pragma surface surf nolight noforwardadd nolightmap noambient novertexlights noshadow

        struct Input { float4 color:COLOR; };

        void surf (Input IN, inout SurfaceOutput o){}
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, 0);
        }
        ENDCG
    }
    FallBack ""
}
```

</details>

