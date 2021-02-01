---
title: 멀티패스 쉐이더 코드 깔끔하게 작성하기
author: Rito15
date: 2021-02-02 00:00:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader]
math: true
mermaid: true
---

```hlsl
Shader "A/B"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"

        struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};
	struct v2f
	{
		float4 vertex:SV_POSITION;
		float2 uv:TEXCOORD0;
	};

	sampler2D _MainTex;

	v2f vert1 (appdata_img v)
	{
		v2f o;
                // ...
		return o;
	}

	fixed4 frag1 (v2f i) : SV_Target
	{
		// ...
		return col;
	} 	

	v2f vert2 (appdata_img v)
	{
		v2f o;
                // ...
		return o;
	}

	fixed4 frag2 (v2f i) : SV_Target
	{
		// ...
		return col;
	} 
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Opaque" }
		//Cull Off ZWrite Off ZTest Always
		Pass // Pass 0
		{
			CGPROGRAM
			#pragma vertex vert1	
			#pragma fragment frag1
			ENDCG
		}
		Pass // Pass 1
		{
			CGPROGRAM
			#pragma vertex vert2
			#pragma fragment frag2
			ENDCG
		}
	}
}
```