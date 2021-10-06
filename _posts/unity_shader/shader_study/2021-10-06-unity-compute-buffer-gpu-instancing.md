---
title: 유니티 - 컴퓨트 버퍼를 통한 GPU 인스턴싱
author: Rito15
date: 2021-10-06 15:15:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, shader, compute shader]
math: true
mermaid: true
---

# GPU Instancing
---

## **[1] 컴퓨트 버퍼 - 메시 데이터**
- 그려낼 메시의 정보를 컴퓨트 버퍼에 저장한다.
- 컴퓨트 버퍼의 `stride`는 `4 byte`(`sizeof(uint)`)이다.
- 컴퓨트 버퍼의 크기는 `20 byte`(`uint` 5개)이며, 각각의 데이터는 메시에 대한 정보를 담고 있다.

```cs
Mesh mesh;                     // 그려낼 메시
int subMeshIndex = 0;          // 기본 : 0
int instanceCount = 100_000;   // 생성할 인스턴스의 개수
uint[] argsData = new uint[5]; // 메시 데이터

argsData[0] = (uint)mesh.GetIndexCount(subMeshIndex);
argsData[1] = (uint)instanceCount;
argsData[2] = (uint)mesh.GetIndexStart(subMeshIndex);
argsData[3] = (uint)mesh.GetBaseVertex(subMeshIndex);
argsData[4] = 0

ComputeBuffer argsBuffer = 
    new ComputeBuffer(
        1,                                  // Count
        sizeof(uint) * 5,                   // Stride
        ComputeBufferType.IndirectArguments // Buffer Type
    );

argsBuffer.SetData(argsData);
```

<br>

## **[2] 컴퓨트 버퍼 - 위치 데이터**
- 위치 데이터를 CPU 혹은 컴퓨트 쉐이더에서 결정하며, 버텍스 쉐이더에서 받아 사용한다.
- 위치뿐만 아니라, 필요하다면 회전과 스케일도 컴퓨트 버퍼에 담아 버텍스 쉐이더에 전달할 수 있다.

```cs
Material material; // 그려낼 마테리얼

// XYZ : 위치, W : 스케일
for (int i = 0; i < instanceCount; i++)
{
    ref Vector4 pos = ref positions[i];
    pos.x = UnityEngine.Random.Range(boundsMin.x, boundsMax.x);
    pos.y = UnityEngine.Random.Range(boundsMin.y, boundsMax.y);
    pos.z = UnityEngine.Random.Range(boundsMin.z, boundsMax.z);
    pos.w = UnityEngine.Random.Range(0.25f, 1f); // Scale
}

positionBuffer = new ComputeBuffer(instanceCount, sizeof(float) * 4);
positionBuffer.SetData(positions);

material.SetBuffer("positionBuffer", positionBuffer);
```

<br>

## **[3] 그리기**
- `Graphics.DrawMeshInstancedIndirect()` 메소드를 통해 그려낸다.

```cs
// 이 범위에 카메라 프러스텀이 겹치지 않는 경우, 컬링된다.
Bounds renderBounds = new Bounds(Vector3.zero, Vector3.one * 50f);

Graphics.DrawMeshInstancedIndirect(
    mesh,         // 그려낼 메시
    subMeshIndex, // 서브메시 인덱스
    material,     // 그려낼 마테리얼
    renderBounds, // 렌더링 영역
    argsBuffer    // 메시 데이터 버퍼
);
```

<br>

## **[4] 컴퓨트 버퍼 해제**
- 컴퓨트 버퍼는 가비지 콜렉터에 의해 자동적으로 해제되지 않는다.
- 따라서 `OnDisable()`, `OnDestroy()` 등에서 적절히 해제 해줘야 한다.

```cs
if (argsBuffer != null)
    argsBuffer.Release();

if (positionBuffer != null)
    positionBuffer.Release();
```

<br>

## **[5] 버텍스 쉐이더**
- `StructuredBuffer<float4>` 타입으로 버퍼 변수를 선언한다.
- `<>`의 타입은 CPU측의 컴퓨트 버퍼 타입과 일치시킨다.
- 버텍스 함수에서 `uint instanceID : SV_InstanceID`를 통해 인스턴스 인덱스를 받아올 수 있다.
- 전달받은 위치, 스케일 데이터를 버텍스에 적용한다.

```hlsl
#pragma vertex vert
// ...
#pragma target 4.5

#if SHADER_TARGET >= 45
StructuredBuffer<float4> positionBuffer;
#endif

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
{
#if SHADER_TARGET >= 45
    float4 data = positionBuffer[instanceID];
#else
    float4 data = 0;
#endif

    float3 localPosition = v.vertex.xyz * data.w;    // 스케일 적용
    float3 worldPosition = data.xyz + localPosition; // 위치 적용

    v2f o;
    // World Pos -> Clip Pos
    o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
    o.uv  = v.texcoord;

    return o;
}
```

<br>

# 예제 1
---

## **[1] 스크립트**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
[Range(1, 1_000_000)]
public int instanceCount = 100_000;
public Mesh mesh;
public Material material;
public int subMeshIndex = 0;
public Bounds renderBounds = new Bounds(Vector3.zero, Vector3.one * 50f);

private ComputeBuffer argsBuffer;     // 메시 데이터 버퍼
private ComputeBuffer positionBuffer; // 위치&스케일 버퍼
private uint[] argsData = new uint[5];

// 변경사항 감지
private int cachedInstanceCount;
private int cachedSubMeshIndex;

private void Update()
{
    if (mesh == null || material == null)
        return;

    // 변경사항 생길 경우 버퍼 재생성
    if (cachedInstanceCount != instanceCount || cachedSubMeshIndex != subMeshIndex)
    {
        InitArgsBuffer();
        InitPositionBuffer();

        cachedInstanceCount = instanceCount;
        cachedSubMeshIndex = subMeshIndex;
    }

    DrawInstances();
}

private void OnDestroy()
{
    if (argsBuffer != null)
        argsBuffer.Release();

    if (positionBuffer != null)
        positionBuffer.Release();
}

/// <summary> 메시 데이터 버퍼 생성 </summary>
private void InitArgsBuffer()
{
    if (argsBuffer == null)
        argsBuffer = new ComputeBuffer(1, sizeof(uint) * 5, ComputeBufferType.IndirectArguments);

    argsData[0] = (uint)mesh.GetIndexCount(subMeshIndex);
    argsData[1] = (uint)instanceCount;
    argsData[2] = (uint)mesh.GetIndexStart(subMeshIndex);
    argsData[3] = (uint)mesh.GetBaseVertex(subMeshIndex);
    argsData[4] = 0;

    argsBuffer.SetData(argsData);
}

/// <summary> 위치, 스케일 데이터 버퍼 생성 </summary>
private void InitPositionBuffer()
{
    if (positionBuffer != null)
        positionBuffer.Release();

    Vector4[] positions = new Vector4[instanceCount];
    Vector3 boundsMin = renderBounds.min;
    Vector3 boundsMax = renderBounds.max;

    // XYZ : 위치, W : 스케일
    for (int i = 0; i < instanceCount; i++)
    {
        ref Vector4 pos = ref positions[i];
        pos.x = UnityEngine.Random.Range(boundsMin.x, boundsMax.x);
        pos.y = UnityEngine.Random.Range(boundsMin.y, boundsMax.y);
        pos.z = UnityEngine.Random.Range(boundsMin.z, boundsMax.z);
        pos.w = UnityEngine.Random.Range(0.25f, 1f); // Scale
    }

    positionBuffer = new ComputeBuffer(instanceCount, sizeof(float) * 4);
    positionBuffer.SetData(positions);

    material.SetBuffer("positionBuffer", positionBuffer);
}

private void DrawInstances()
{
    Graphics.DrawMeshInstancedIndirect(
        mesh,         // 그려낼 메시
        subMeshIndex, // 서브메시 인덱스
        material,     // 그려낼 마테리얼
        renderBounds, // 렌더링 영역
        argsBuffer    // 메시 데이터 버퍼
    );
}
```

</details>

<br>


## **[2] 쉐이더**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```hlsl
Shader "Rito/Test_GPUInstancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;

        #if SHADER_TARGET >= 45
            StructuredBuffer<float4> positionBuffer;
        #endif

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 diffuse : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
            #if SHADER_TARGET >= 45
                float4 data = positionBuffer[instanceID];
            #else
                float4 data = 0;
            #endif

                float3 localPosition = v.vertex.xyz * data.w;    // 스케일 적용
                float3 worldPosition = data.xyz + localPosition; // 위치 적용
                float3 worldNormal   = v.normal;

                float3 NdL = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                float3 diffuse = (NdL * _LightColor0.rgb);

                v2f o;
                o.pos     = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
                o.uv      = v.texcoord;
                o.diffuse = diffuse;

                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed  shadow   = SHADOW_ATTENUATION(i);
                fixed4 albedo   = tex2D(_MainTex, i.uv);
                float3 lighting = i.diffuse * shadow;
                fixed4 output   = fixed4(albedo.rgb * lighting, albedo.a);

                UNITY_APPLY_FOG(i.fogCoord, output);
                return output;
            }

            ENDCG
        }
    }
}

```

</details>

<br>


## **[3] 실행 결과**

![image](https://user-images.githubusercontent.com/42164422/136166210-0551faf8-6515-4f91-ba1e-258c57f96e16.png)

<br>

# 예제 2 : 유니티 공식 문서
---

- <https://docs.unity3d.com/kr/current/ScriptReference/Graphics.DrawMeshInstancedIndirect.html>

## **[1] 스크립트**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
//using Random = UnityEngine.Random;

public int instanceCount = 100000;
public Mesh instanceMesh;
public Material instanceMaterial;
public int subMeshIndex = 0;

private int cachedInstanceCount = -1;
private int cachedSubMeshIndex = -1;
private ComputeBuffer positionBuffer;
private ComputeBuffer argsBuffer;
private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

void Start()
{
    argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
    UpdateBuffers();
}

void Update()
{
    // 인스턴스 개수 또는 서브메시 인덱스가 변경될 경우 버퍼 재생성
    if (cachedInstanceCount != instanceCount || cachedSubMeshIndex != subMeshIndex)
        UpdateBuffers();

    // Pad input
    if (Input.GetAxisRaw("Horizontal") != 0.0f)
        instanceCount = (int)Mathf.Clamp(instanceCount + Input.GetAxis("Horizontal") * 40000, 1.0f, 5000000.0f);

    // 렌더링 영역 설정 : 카메라의 프러스텀이 Bounds와 겹치지 않으면 컬링된다.
    Bounds renderBounds = new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f));

    // Render
    Graphics.DrawMeshInstancedIndirect(
        instanceMesh,     // 그려낼 메시
        subMeshIndex,     // 서브메시 인덱스
        instanceMaterial, // 그려낼 마테리얼
        renderBounds,     // 렌더링 영역
        argsBuffer        // 메시 데이터 버퍼
    );
}

void OnGUI()
{
    GUI.Label(new Rect(265, 25, 200, 30), "Instance Count: " + instanceCount.ToString());
    instanceCount = (int)GUI.HorizontalSlider(new Rect(25, 20, 200, 30), (float)instanceCount, 1.0f, 5000000.0f);
}

/// <summary> 인스턴스 개수 또는 서브메시 인덱스가 변경될 경우 버퍼 재생성 </summary>
void UpdateBuffers()
{
    // 서브메시 인덱스 범위 제한
    if (instanceMesh != null)
        subMeshIndex = Mathf.Clamp(subMeshIndex, 0, instanceMesh.subMeshCount - 1);

    // 위치 버퍼
    // xyz : 3D 위치
    // w   : 크기
    if (positionBuffer != null)
        positionBuffer.Release();
    positionBuffer = new ComputeBuffer(instanceCount, 16);
    Vector4[] positions = new Vector4[instanceCount];

    for (int i = 0; i < instanceCount; i++)
    {
        float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
        float distance = Random.Range(20.0f, 100.0f);
        float height = Random.Range(-2.0f, 2.0f);
        float size = Random.Range(0.05f, 0.25f);
        positions[i] = new Vector4(
            Mathf.Sin(angle) * distance, // Pos X
            height,                      // Pos Y
            Mathf.Cos(angle) * distance, // Pos Z
            size                         // Scale
        );
    }
    positionBuffer.SetData(positions);
    instanceMaterial.SetBuffer("positionBuffer", positionBuffer);

    // Indirect Args Buffer : 메시 데이터 초기화
    if (instanceMesh != null)
    {
        args[0] = (uint)instanceMesh.GetIndexCount(subMeshIndex);
        args[1] = (uint)instanceCount;
        args[2] = (uint)instanceMesh.GetIndexStart(subMeshIndex);
        args[3] = (uint)instanceMesh.GetBaseVertex(subMeshIndex);
    }
    else
    {
        args[0] = args[1] = args[2] = args[3] = 0;
    }
    argsBuffer.SetData(args);

    // 변화 감지를 위해 필드에 데이터 저장
    cachedInstanceCount = instanceCount;
    cachedSubMeshIndex = subMeshIndex;
}

void OnDisable()
{
    if (positionBuffer != null)
        positionBuffer.Release();
    positionBuffer = null;

    if (argsBuffer != null)
        argsBuffer.Release();
    argsBuffer = null;
}
```

</details>

<br>


## **[2-1] Surface 쉐이더**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```hlsl
Shader "Instanced/InstancedSurf" 
{
    Properties 
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model
        #pragma surface surf Standard addshadow fullforwardshadows
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
        StructuredBuffer<float4> positionBuffer;
    #endif

        void rotate2D(inout float2 v, float r)
        {
            float s, c;
            sincos(r, s, c);
            v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
        }

        void setup()
        {
        #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            float4 data = positionBuffer[unity_InstanceID];

            float rotation = data.w * data.w * _Time.y * 0.5f;
            rotate2D(data.xz, rotation);

            unity_ObjectToWorld._11_21_31_41 = float4(data.w, 0, 0, 0);
            unity_ObjectToWorld._12_22_32_42 = float4(0, data.w, 0, 0);
            unity_ObjectToWorld._13_23_33_43 = float4(0, 0, data.w, 0);
            unity_ObjectToWorld._14_24_34_44 = float4(data.xyz, 1);
            unity_WorldToObject = unity_ObjectToWorld;
            unity_WorldToObject._14_24_34 *= -1;
            unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
        #endif
        }

        half _Glossiness;
        half _Metallic;

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

</details>

<br>


## **[2-2] Vert/Frag 쉐이더**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```hlsl
Shader "Instanced/InstancedVertFrag"
{
    Properties 
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader 
    {
        Pass 
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;

        #if SHADER_TARGET >= 45
            StructuredBuffer<float4> positionBuffer;
        #endif

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float3 ambient : TEXCOORD1;
                float3 diffuse : TEXCOORD2;
                float3 color : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            void rotate2D(inout float2 v, float r)
            {
                float s, c;
                sincos(r, s, c);
                v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
            }

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
            #if SHADER_TARGET >= 45
                float4 data = positionBuffer[instanceID];
            #else
                float4 data = 0;
            #endif

                float rotation = data.w * data.w * _Time.x * 0.5f;
                rotate2D(data.xz, rotation);

                float3 localPosition = v.vertex.xyz * data.w;
                float3 worldPosition = data.xyz + localPosition;
                float3 worldNormal = v.normal;

                float3 ndotl = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                float3 ambient = ShadeSH9(float4(worldNormal, 1.0f));
                float3 diffuse = (ndotl * _LightColor0.rgb);
                float3 color = v.color;

                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
                o.uv_MainTex = v.texcoord;
                o.ambient = ambient;
                o.diffuse = diffuse;
                o.color = color;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed4 albedo = tex2D(_MainTex, i.uv_MainTex);
                float3 lighting = i.diffuse * shadow + i.ambient;
                fixed4 output = fixed4(albedo.rgb * i.color * lighting, albedo.w);
                UNITY_APPLY_FOG(i.fogCoord, output);
                return output;
            }

            ENDCG
        }
    }
}

```

</details>

<br>


## **[3] 실행 결과**

![image](https://user-images.githubusercontent.com/42164422/136167287-a8a487a1-49c3-4a4a-af1a-598c3693399e.png)

![image](https://user-images.githubusercontent.com/42164422/136167366-5d33c62d-04de-4964-a140-e455cef22fa4.png)

<br>