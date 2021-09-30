---
title: 유니티 쉐이더 - 빌보드(Vert/Frag)
author: Rito15
date: 2021-09-30 21:00:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, shader, memo]
math: true
mermaid: true
---

# 1. 일반
---

```hlsl
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};

float4 Billboard(float4 vertex)
{
    float3 camUpVec      =  normalize( UNITY_MATRIX_V._m10_m11_m12 );
    float3 camForwardVec = -normalize( UNITY_MATRIX_V._m20_m21_m22 );
    float3 camRightVec   =  normalize( UNITY_MATRIX_V._m00_m01_m02 );
    float4x4 camRotMat   = float4x4( camRightVec, 0, camUpVec, 0, camForwardVec, 0, 0, 0, 0, 1 );
                
    vertex = mul( vertex , unity_ObjectToWorld );
    vertex = mul( vertex , camRotMat );
    vertex = mul( vertex , unity_WorldToObject );

    return UnityObjectToClipPos(vertex);
}

v2f vert (appdata v)
{
    v2f o;

    o.vertex = Billboard(v.vertex);
    o.uv = v.uv;

    return o;
}
```

<br>

# 2. GPU 인스턴싱으로 그리는 경우
---
- `Graphics.DrawMeshInstancedIndirect()`를 통해 그릴 때, 매개변수 마테리얼의 쉐이더
- Quad 메시

- 컴퓨트 버퍼(`_PositionBuffer`)를 통해 각 인스턴스의 위치 지정
- `_Scale` 변수 또는 컴퓨트 버퍼를 통해 각 인스턴스의 크기 지정

```hlsl
StructuredBuffer<float3> _PositionBuffer;
float _Scale;

float4 CalculateVertex(float4 vertex, float3 worldPos)
{
    float3 camUpVec      =  normalize( UNITY_MATRIX_V._m10_m11_m12 );
    float3 camForwardVec = -normalize( UNITY_MATRIX_V._m20_m21_m22 );
    float3 camRightVec   =  normalize( UNITY_MATRIX_V._m00_m01_m02 );
    float4x4 camRotMat   = float4x4( camRightVec, 0, camUpVec, 0, camForwardVec, 0, 0, 0, 0, 1 );

    vertex = mul(vertex, camRotMat); // Billboard
    vertex.xyz *= _Scale;   // Scale
    vertex.xyz += worldPos; // Instance Position

    // World => VP => Clip
    return mul(UNITY_MATRIX_VP, vertex);
}

v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
{
    v2f o;

    o.vertex = CalculateVertex(v.vertex, _PositionBuffer[instanceID]);
    o.uv = v.texcoord;

    return o;
}
```