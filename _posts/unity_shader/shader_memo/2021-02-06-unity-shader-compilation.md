---
title: 유니티 쉐이더 & 함수 모음
author: Rito15
date: 2021-02-06 01:25:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, csharp, shader, graphics, transparent, stencil]
math: true
mermaid: true
---

# Functions
---

## 트랜스폼에서 회전 행렬만 추출하기

```hlsl
// 트랜스폼의 회전 행렬 추출
float4x4 GetModelRotationMatrix()
{
    float4x4 rotationMatrix;

    vector sx = vector(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20, 0);
    vector sy = vector(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21, 0);
    vector sz = vector(unity_ObjectToWorld._m02, unity_ObjectToWorld._m12, unity_ObjectToWorld._m22, 0);

    float scaleX = length(sx);
    float scaleY = length(sy);
    float scaleZ = length(sz);

    rotationMatrix[0] = float4(unity_ObjectToWorld._m00 / scaleX, unity_ObjectToWorld._m01 / scaleY, unity_ObjectToWorld._m02 / scaleZ, 0);
    rotationMatrix[1] = float4(unity_ObjectToWorld._m10 / scaleX, unity_ObjectToWorld._m11 / scaleY, unity_ObjectToWorld._m12 / scaleZ, 0);
    rotationMatrix[2] = float4(unity_ObjectToWorld._m20 / scaleX, unity_ObjectToWorld._m21 / scaleY, unity_ObjectToWorld._m22 / scaleZ, 0);
    rotationMatrix[3] = float4(0, 0, 0, 1);

    return rotationMatrix;
}

// 위치 벡터 회전
float3 RotatePosObjectToWorld(float4x4 rotationMatrix, float3 pos)
{
    return mul(rotationMatrix, pos).xyz;
}

float3 RotatePosWorldToObject(float4x4 rotationMatrix, float3 pos)
{
    return mul(pos, rotationMatrix).xyz;
}
            
// 방향 벡터 회전
float3 RotateDirObjectToWorld(float4x4 rotationMatrix, float3 dir)
{
    return mul((float3x3)rotationMatrix, dir);
}

float3 RotateDirWorldToObject(float4x4 rotationMatrix, float3 dir)
{
    return mul(dir, (float3x3)rotationMatrix);
}

// 활용 예시
fixed4 frag (v2f i) : SV_Target
{
    float4x4 rotMatrix = GetModelRotationMatrix();

    // Object Light Direction
    float3 L = normalize(_WorldSpaceLightPos0.xyz);
    L = RotateDirWorldToObject(rotMatrix, L);
}
```

<br>

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


<br>

# References
---
- <https://www.sysnet.pe.kr/2/0/11640>
- <https://www.sysnet.pe.kr/2/0/11637>