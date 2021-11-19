---
title: 멀티패스 쉐이더 코드 깔끔하게 작성하기
author: Rito15
date: 2021-02-02 00:00:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, csharp, shader]
math: true
mermaid: true
---

```hlsl
Shader "A/B"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    /* Structs */
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };
    struct v2f
    {
        float4 pos:SV_POSITION;
        float2 uv:TEXCOORD0;
    };

    sampler2D _MainTex;

    /* Pass 1 Shader Functions */
    v2f vert1 (appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        // ...
        return o;
    }

    fixed4 frag1 (v2f i) : SV_Target
    {
        fixed4 col = fixed4(0,0,0,0);
        // ...
        return col;
    }     

    /* Pass 2 Shader Functions */
    v2f vert2 (appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        // ...
        return o;
    }

    fixed4 frag2 (v2f i) : SV_Target
    {
        fixed4 col = fixed4(0,0,0,0);
        // ...
        return col;
    } 
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //Cull Off ZWrite Off ZTest Always

        Pass // 1
        {
            CGPROGRAM
            #pragma vertex vert1    
            #pragma fragment frag1
            ENDCG
        }
        Pass // 2
        {
            CGPROGRAM
            #pragma vertex vert2
            #pragma fragment frag2
            ENDCG
        }
    }
}
```