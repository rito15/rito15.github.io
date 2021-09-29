---
title: 유니티 - 진공 청소기, 먼지 시뮬레이션
author: Rito15
date: 2021-09-27 17:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 목표
---
- 수십만 개의 먼지를 렌더링한다.
- 먼지들의 움직임을 시뮬레이션한다.
- 진공 청소기로 먼지들을 예쁘게 빨아들인다.

<br>



<!-- --------------------------------------------------------------------------- -->

# 주요 개념
---

## **Compute Buffer**
- 큰 병렬 데이터를 GPU에 전달하거나 쉐이더끼리 공유하기 위해 사용한다.
- Vert/Frag, Compute Shader에서 `StructuredBuffer<T>` 타입 변수로 사용할 수 있다.

## **Graphics.DrawMeshInstancedIndirect()**
- 컴퓨트 버퍼의 메시 데이터를 GPU Instancing을 적용하여 대규모로 렌더링할 수 있다.

## **Compute Shader**
- GPGPU를 통해 병렬적으로 연산을 적용할 수 있다.

<br>



<!-- --------------------------------------------------------------------------- -->

# 1. 10만개의 먼지 만들기
---

렌더링될 메시의 버텍스 개수에 따라 성능 차이가 커지므로,

일단 메시는 단순한 큐브 메시를 사용한다.

<br>

## **Dustmanager.cs**

- 먼지 생성 및 관리를 담당한다.

<details>
<summary markdown="span"> 
Fields
</summary>

```cs
private const int TRUE = 1;
private const int FALSE = 0;

private struct Dust
{
    public Vector3 position;
    public int isAlive;
}

[Header("Dust Options")]
[SerializeField] private Mesh DustMesh;         // 먼지 메시
[SerializeField] private Material DustMaterial; // 먼지 마테리얼

[Space]
[SerializeField] private int instanceNumber = 100000;    // 생성할 먼지 개수
[SerializeField] private float distributionRange = 100f; // 먼지 분포 범위(정사각형 너비)
[Range(0.01f, 2f)]
[SerializeField] private float DustScale = 1f;           // 먼지 크기

private ComputeBuffer DustBuffer; // 먼지 데이터 버퍼(위치, ...)
private ComputeBuffer argsBuffer; // 먼지 렌더링 데이터 버퍼

private Bounds frustumOverlapBounds;
private Dust[] DustArray;
```

</details>


<details>
<summary markdown="span"> 
Unity Event Methods
</summary>

```cs
private void Start()
{
    InitBuffers();
}
private void Update()
{
    DustMaterial.SetFloat("_Scale", DustScale);
    Graphics.DrawMeshInstancedIndirect(DustMesh, 0, DustMaterial, bounds, argsBuffer);
}
private void OnDestroy()
{
    DustBuffer.Release();
    argsBuffer.Release();
}

private GUIStyle boxStyle;
private void OnGUI()
{
    if (boxStyle == null)
    {
        boxStyle = new GUIStyle(GUI.skin.box);
        boxStyle.fontSize = 48;
    }

    float scWidth = Screen.width;
    float scHeight = Screen.height;
    Rect r = new Rect(scWidth * 0.04f, scHeight * 0.04f, scWidth * 0.25f, scHeight * 0.05f);

    GUI.Box(r, $"{aliveNumber:D6} / {instanceNumber}", boxStyle);
}
```

</details>

<details>
<summary markdown="span"> 
Methods
</summary>

```cs
/// <summary> 컴퓨트 버퍼들 생성 </summary>
private void InitBuffers()
{
    // Args Buffer
    // IndirectArguments로 사용되는 컴퓨트 버퍼의 stride는 20byte 이상이어야 한다.
    // 따라서 파라미터가 앞의 2개만 필요하지만, 뒤에 의미 없는 파라미터 3개를 더 넣어준다.
    uint[] argsData = new uint[] { (uint)DustMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    aliveNumber = instanceNumber;

    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    PopulateDusts();

    // Dust Buffer
    DustBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));
    DustBuffer.SetData(DustArray);
    DustMaterial.SetBuffer("_DustBuffer", DustBuffer);

    // 카메라 프러스텀이 이 영역과 겹치지 않으면 렌더링되지 않는다.
    frustumOverlapBounds = new Bounds(Vector3.zero, new Vector3(distributionRange, 1f, distributionRange));
}

/// <summary> 먼지들을 영역 내의 무작위 위치에 생성한다. </summary>
private void PopulateDusts()
{
    DustArray = new Dust[instanceNumber];

    float min = -0.5f * distributionRange;
    float max = -min;
    for (int i = 0; i < instanceNumber; i++)
    {
        float x = UnityEngine.Random.Range(min, max);
        float z = UnityEngine.Random.Range(min, max);
        DustArray[i].position = new Vector3(x, 0f, z);
        DustArray[i].isAlive = TRUE;
    }
}
```

</details>

<br>

## **DustShader.shader**

- 먼지 렌더링을 담당한다.

- 먼지의 위치를 컴퓨트 버퍼에 저장하면, CPU가 아니라 쉐이더를 통해 GPU로 위치 변경사항을 적용한다.

<details>
<summary markdown="span"> 
...
</summary>

```hlsl
Shader "Rito/Dust"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (0.2, 0.2, 0.2, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TRUE 1
            #define FALSE 0

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                int isAlive : TEXCOORD1;
            };

            struct Dust
            {
                float3 position;
                int isAlive;
            };

            uniform float _Scale;
            StructuredBuffer<Dust> _DustBuffer;

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                // 먼지 생존 여부 받아와서 프래그먼트 쉐이더에 전달
                o.isAlive = _DustBuffer[instanceID].isAlive;

                // 먼지 크기 결정
                v.vertex *= _Scale; 

                // 먼지 위치 결정
                float3 instancePos = _DustBuffer[instanceID].position;
                float3 worldPos = v.vertex + instancePos;

                o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1));
                o.normal = v.normal;
                return o;
            }

            fixed4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                // 죽은 먼지는 렌더링 X
                if(i.isAlive == FALSE)
                {
                    discard;
                }

                return _Color;
            }
            ENDCG
        }
    }
}
```

</details>

<br>

## **실행 결과**

![2021_0927_Dust1](https://user-images.githubusercontent.com/42164422/134875331-f70f4555-7b70-49a6-8049-ae35740165a0.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 2. 먼지 빨아들이기
---

## **진공 청소기 입구**

- 먼지를 빨아들이는 부분

<details>
<summary markdown="span"> 
VacuumCleanerHead.cs
</summary>

```cs
[SerializeField] private bool run = true;
[Range(0f, 50f)]
[SerializeField] private float suctionForce = 1f;
[Range(1f, 20f)]
[SerializeField] private float suctionRange = 5f;
[Range(0.01f, 5f)]
[SerializeField] private float deathRange = 0.2f;

public bool Running => run;
public float SqrSuctionRange => suctionRange * suctionRange;
public float SuctionForce => suctionForce;
public float DeathRange => deathRange;
public Vector3 Position => transform.position;

private void OnDrawGizmosSelected()
{
    Gizmos.color = Color.cyan;
    Gizmos.DrawWireSphere(Position, suctionRange);

    Gizmos.color = Color.red;
    Gizmos.DrawWireSphere(Position, deathRange);
}
```

</details>

<br>

## **[1] CPU 단일 스레드 계산**

- 반복문을 통한 단순 계산을 통해 먼지들의 위치를 업데이트한다.
- 성능이 매우 매우 좋지 않다.

<details>
<summary markdown="span"> 
Dustmanager.cs
</summary>

```cs
private void Update()
{
    UpdateDustPositions();
    DustMaterial.SetFloat("_Scale", DustScale);
    Graphics.DrawMeshInstancedIndirect(DustMesh, 0, DustMaterial, frustumOverlapBounds, argsBuffer);
}

private void UpdateDustPositions()
{
    if (cleanerHead.Running == false) return;

    Vector3 headPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float force = Time.deltaTime * cleanerHead.SuctionForce;

    for (int i = 0; i < instanceNumber; i++)
    {
        if (DustArray[i].isAlive == FALSE) continue;

        // root 연산은 비싸기 때문에 제곱 상태로 거리 비교
        float sqrDist = Vector3.SqrMagnitude(DustArray[i].position - headPos);
        
        // 사망 범위
        if (sqrDist < sqrDeathRange)
        {
            DustArray[i].isAlive = FALSE;
            aliveNumber--;
        }
        // 흡입 범위
        else if (sqrDist < sqrRange)
        {
            DustArray[i].position = Vector3.Lerp(DustArray[i].position, headPos, force);
        }
    }

    DustBuffer.SetData(DustArray);
}
```

</details>

![2021_0927_DustUpdate1](https://user-images.githubusercontent.com/42164422/134880151-4068c99e-a84d-4cdb-8f49-5e88eb31ea89.gif)

<br>

## **[2] CPU 병렬 계산**

- `Parallel`을 통한 멀티스레딩으로 CPU 연산을 적용한다.

- 그리고 먼지가 단순히 `Vector3.Lerp()`를 통해 이동하는 대신, 거리가 가까울수록 빠르게 이동하도록 계산 방식을 변경한다.

<details>
<summary markdown="span"> 
Dustmanager.cs
</summary>

```cs
private void UpdateDustPositions()
{
    if (cleanerHead.Running == false) return;

    Vector3 headPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float sqrForce = Time.deltaTime * cleanerHead.SuctionForce * cleanerHead.SuctionForce;

    // 병렬 처리(동기)
    Parallel.For(0, instanceNumber, i =>
    {
        if (DustArray[i].isAlive == FALSE) return;

        float sqrDist = Vector3.SqrMagnitude(headPos - DustArray[i].position);

        // 사망 범위
        if (sqrDist < sqrDeathRange)
        {
            DustArray[i].isAlive = FALSE;
            Interlocked.Decrement(ref aliveNumber);
        }
        // 흡입 범위
        else if (sqrDist < sqrRange)
        {
            Vector3 dir = (headPos - DustArray[i].position).normalized;
            float weightedForce = sqrForce / sqrDist;
            DustArray[i].position += dir * weightedForce;
        }
    });

    DustBuffer.SetData(DustArray);
}
```

</details>

![2021_0927_DustUpdate2](https://user-images.githubusercontent.com/42164422/134881462-c07f57ba-097c-41fd-87f6-f2639c53f463.gif)

<br>

## **[3] 컴퓨트 쉐이더 병렬 연산**

- 먼지 이동 연산을 컴퓨트 쉐이더로 넘겨서 처리한다.
- 컴퓨트 쉐이더의 연산 결과를 다시 CPU로 가져오는 작업이 없고, 대신 컴퓨트 버퍼를 Vert/Frag 쉐이더에서 바로 참조하여 적용하므로 매우 빠르다.

<details>
<summary markdown="span"> 
DustCompute.compute
</summary>

```hlsl
#pragma kernel CSMain

#define TRUE 1
#define FALSE 0

struct Dust
{
    float3 position;
    int isAlive;
};

RWStructuredBuffer<Dust> DustBuffer;
RWStructuredBuffer<uint> aliveNumberBuffer; // 생존한 먼지 개수

float3 headPos;
float sqrRange;
float sqrDeathRange;
float sqrForce;

[numthreads(64,1,1)]
void CSMain (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;
    if(DustBuffer[i].isAlive == FALSE) return;
    
    // 제곱 상태로 연산
    float3 offs = (headPos - DustBuffer[i].position);
    float sqrDist = (offs.x * offs.x) + (offs.y * offs.y) + (offs.z * offs.z);

    // 사망 범위
    if (sqrDist < sqrDeathRange)
    {
        DustBuffer[i].isAlive = FALSE;
        InterlockedAdd(aliveNumberBuffer[0], -1);
    }
    // 흡입 범위
    else if (sqrDist < sqrRange)
    {
        float3 dir = normalize(headPos - DustBuffer[i].position);
        float weightedForce = sqrForce / sqrDist;
        DustBuffer[i].position += dir * weightedForce;
    }
}
```

</details>

<details>
<summary markdown="span"> 
Dustmanager.cs
</summary>

```cs
/* 기타 필드 생략 */

[SerializeField] private ComputeShader DustCompute;
private ComputeBuffer DustBuffer; // 먼지 데이터 버퍼(위치, ...)
private ComputeBuffer argsBuffer; // 먼지 렌더링 데이터 버퍼
private ComputeBuffer aliveNumberBuffer; // 생존 먼지 개수 RW

private Bounds frustumOverlapBounds;
private Dust[] DustArray;

private uint[] aliveNumberArray;
private int aliveNumber;
int kernelGroupSizeX;

private void Start()
{
    InitBuffers();
    InitComputeShader();
}
private void Update()
{
    UpdateDustPositionsGPU();
    DustMaterial.SetFloat("_Scale", DustScale);
    Graphics.DrawMeshInstancedIndirect(DustMesh, 0, DustMaterial, frustumOverlapBounds, argsBuffer);
}
private void OnDestroy()
{
    DustBuffer.Release();
    argsBuffer.Release();
    aliveNumberBuffer.Release();
}

/// <summary> 컴퓨트 버퍼들 생성 </summary>
private void InitBuffers()
{
    // Args Buffer
    // IndirectArguments로 사용되는 컴퓨트 버퍼의 stride는 20byte 이상이어야 한다.
    // 따라서 파라미터가 앞의 2개만 필요하지만, 뒤에 의미 없는 파라미터 3개를 더 넣어준다.
    uint[] argsData = new uint[] { (uint)DustMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    aliveNumber = instanceNumber;

    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    PopulateDusts();

    // Dust Buffer
    DustBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));
    DustBuffer.SetData(DustArray);
    DustMaterial.SetBuffer("_DustBuffer", DustBuffer);

    // Alive Number Buffer
    // 단순 입력용이 아니라 RW이므로 컴퓨트 버퍼를 사용한다.
    aliveNumberBuffer = new ComputeBuffer(1, sizeof(uint));
    aliveNumberArray = new uint[] { (uint)instanceNumber };
    aliveNumberBuffer.SetData(aliveNumberArray);

    // 카메라 프러스텀이 이 영역과 겹치지 않으면 렌더링되지 않는다.
    frustumOverlapBounds = new Bounds(Vector3.zero, new Vector3(distributionRange, 1f, distributionRange));
}

/// <summary> 컴퓨트 쉐이더 초기화 </summary>
private void InitComputeShader()
{
    DustCompute.SetBuffer(0, "DustBuffer", DustBuffer);
    DustCompute.SetBuffer(0, "aliveNumberBuffer", aliveNumberBuffer);
    DustCompute.GetKernelThreadGroupSizes(0, out uint tx, out _, out _);
    kernelGroupSizeX = Mathf.CeilToInt((float)instanceNumber / tx);
}

private void UpdateDustPositionsGPU()
{
    if (cleanerHead.Running == false) return;

    Vector3 headPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float sqrForce = Time.deltaTime * cleanerHead.SuctionForce * cleanerHead.SuctionForce;

    DustCompute.SetVector("headPos", headPos);
    DustCompute.SetFloat("sqrRange", sqrRange);
    DustCompute.SetFloat("sqrDeathRange", sqrDeathRange);
    DustCompute.SetFloat("sqrForce", sqrForce);

    DustCompute.Dispatch(0, kernelGroupSizeX, 1, 1);

    aliveNumberBuffer.GetData(aliveNumberArray);
    aliveNumber = (int)aliveNumberArray[0];
}
```

</details>


![2021_0927_DustUpdate3](https://user-images.githubusercontent.com/42164422/134906449-5b7787aa-a7f6-44cd-a151-c1b460fc6c7c.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 3. 먼지 생성 최적화
---

난수를 발생시켜 먼지를 무작위 위치에 생성하던 부분을 CPU가 아니라 컴퓨트 쉐이더 내에서 연산하도록 한다.

그리고 평면이 아닌, 공간에서 큐브 형태로 분포할 수 있도록 변경한다.

<br>

## **[1] 컴퓨트 쉐이더**

- 기존 커널의 이름을 `Update`로 변경하고, 새로운 커널 함수 `Populate`를 작성한다.

<details>
<summary markdown="span"> 
DustCompute.compute
</summary>

```hlsl
#pragma kernel Populate
#pragma kernel Update

#define TRUE 1
#define FALSE 0

struct Dust
{
    float3 position;
    int isAlive;
};

/*************************************************
/*                     Methods
/*************************************************/
float Random(float2 seed)
{
    return frac(sin(dot(seed, float2(73.867, 25.241))) * 39482.17593);
}
float RandomRange(float2 seed, float min, float max)
{
    return lerp(min, max, Random(seed)); 
}
float3 RandomRange3(float2 seed, float3 min, float3 max)
{
    float3 vec;
    vec.x = RandomRange(seed, min.x, max.x);
    vec.y = RandomRange(seed + 7.219, min.y, max.y);
    vec.z = RandomRange(seed + 79.714, min.z, max.z);
    return vec;
}

/*************************************************
/*                     Variables
/*************************************************/
RWStructuredBuffer<Dust> DustBuffer;
RWStructuredBuffer<uint> aliveNumberBuffer; // 생존한 먼지 개수

float3 boundsMin; // 먼지 생성 영역 - 최소 지점
float3 boundsMax; // 먼지 생성 영역 - 최대 지점

float3 headPos;
float sqrRange;
float sqrDeathRange;
float sqrForce;

/*************************************************
/*                     Kernels
/*************************************************/

// 0 - 초기 생성
[numthreads(64,1,1)]
void Populate (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;

    float width = boundsMax.x - boundsMin.x;
    float f = float(i);
    float2 uv = float2(f % width, f / width) / width;
    
    DustBuffer[i].position = RandomRange3(uv, boundsMin, boundsMax);
    DustBuffer[i].isAlive = TRUE;
}

// 1 - 실시간 업데이트
[numthreads(64,1,1)]
void Update (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;
    if(DustBuffer[i].isAlive == FALSE) return;
    
    float3 offs = (headPos - DustBuffer[i].position);
    float sqrDist = (offs.x * offs.x) + (offs.y * offs.y) + (offs.z * offs.z);

    if (sqrDist < sqrDeathRange)
    {
        DustBuffer[i].isAlive = FALSE;
        InterlockedAdd(aliveNumberBuffer[0], -1);
    }
    else if (sqrDist < sqrRange)
    {
        float3 dir = normalize(headPos - DustBuffer[i].position);
        float weightedForce = sqrForce / sqrDist;
        DustBuffer[i].position += dir * weightedForce;
    }
}
```

</details>

<br>

## **[2] 먼지 관리 컴포넌트**

- 커널 함수들의 인덱스를 필드로 저장한다.
- 먼지들에 대한 CPU 작업은 더이상 필요하지 않으므로, `DustArray` 필드는 제거하고 모두 `DustBuffer`를 통해 GPU에서 작업한다.

<details>
<summary markdown="span"> 
DustManager.cs
</summary>

```cs
[SerializeField] private float distributionHeight = 5f;  // 먼지 분포 높이

private int kernelPopulateID;
private int kernelUpdateID;
private int kernelUpdateGroupSizeX;

private void Start()
{
    InitBuffers();
    InitComputeShader();
    PopulateDusts();
}

private void Update()
{
    UpdateDustPositionsGPU();

    DustMaterial.SetFloat("_Scale", DustScale);
    Graphics.DrawMeshInstancedIndirect(DustMesh, 0, DustMaterial, frustumOverlapBounds, argsBuffer);
}

/// <summary> 컴퓨트 버퍼들 생성 </summary>
private void InitBuffers()
{
    uint[] argsData = new uint[] { (uint)DustMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    aliveNumber = instanceNumber;

    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    // Dust Buffer => DustArray는 완전히 제거
    DustBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));
    DustMaterial.SetBuffer("_DustBuffer", DustBuffer);

    aliveNumberBuffer = new ComputeBuffer(1, sizeof(uint));
    aliveNumberArray = new uint[] { (uint)instanceNumber };
    aliveNumberBuffer.SetData(aliveNumberArray);

    frustumOverlapBounds = new Bounds(Vector3.zero, new Vector3(distributionRange, 1f, distributionRange));
}

/// <summary> 컴퓨트 쉐이더 초기화 </summary>
private void InitComputeShader()
{
    // 커널 인덱스 찾아 가져오기
    kernelPopulateID = DustCompute.FindKernel("Populate");
    kernelUpdateID   = DustCompute.FindKernel("Update");

    // 버퍼는 커널마다 각각 할당해주어야 한다.
    DustCompute.SetBuffer(kernelPopulateID, "DustBuffer", DustBuffer);
    DustCompute.SetBuffer(kernelUpdateID, "DustBuffer", DustBuffer);
    DustCompute.SetBuffer(kernelUpdateID, "aliveNumberBuffer", aliveNumberBuffer);

    DustCompute.GetKernelThreadGroupSizes(kernelUpdateID, out uint tx, out _, out _);
    kernelUpdateGroupSizeX = Mathf.CeilToInt((float)instanceNumber / tx);
}

/// <summary> 먼지들을 영역 내의 무작위 위치에 생성한다. </summary>
private void PopulateDusts()
{
    Vector3 boundsMin, boundsMax;
    boundsMin.x = boundsMin.z = -0.5f * distributionRange;
    boundsMax.x = boundsMax.z = -boundsMin.x;
    boundsMin.y = 0f;
    boundsMax.y = distributionHeight;

    DustCompute.SetVector("boundsMin", boundsMin);
    DustCompute.SetVector("boundsMax", boundsMax);

    DustCompute.GetKernelThreadGroupSizes(kernelPopulateID, out uint tx, out _, out _);
    int groupSizeX = Mathf.CeilToInt((float)instanceNumber / tx);

    DustCompute.Dispatch(kernelPopulateID, groupSizeX, 1, 1);
}

private void UpdateDustPositionsGPU()
{
    // 생략
    
    // Dispatch(0, ...) => Dispatch(kernelUpdateID, ...) 변경
    DustCompute.Dispatch(kernelUpdateID, kernelUpdateGroupSizeX, 1, 1);
}
```

</details>

<br>

## **[3] 진공 청소기 컴포넌트**

- 임시 이동을 구현한다.

<details>
<summary markdown="span"> 
VacuumCleanerHead.cs
</summary>

```cs
[Range(0.01f, 100f)]
[SerializeField] private float moveSpeed = 50f;

private void Update()
{
    // On/Off
    if (Input.GetKeyDown(KeyCode.Space))
        run ^= true;

    // Move
    float x = Input.GetAxisRaw("Horizontal");
    float z = Input.GetAxisRaw("Vertical");
    float y = 0f;
    if (Input.GetKey(KeyCode.E)) y += 1f;
    else if (Input.GetKey(KeyCode.Q)) y -= 1f;

    Vector3 moveVec = new Vector3(x, y, z).normalized * moveSpeed;

    if (Input.GetKey(KeyCode.LeftShift))
        moveVec *= 2f;

    transform.Translate(moveVec * Time.deltaTime, Space.World);
}
```

</details>

<br>

## **[4] 실행 결과**

![2021_0927_Dust_3D](https://user-images.githubusercontent.com/42164422/135104033-6303ab1b-15fe-412d-9c64-05dc61cb09d3.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 4. 원뿔 흡수 영역 구현
---

구형 범위에서 흡수하는 것은 블랙홀이나 마찬가지이므로,

방향을 지정하여 해당 방향에서 원뿔 범위로 흡수할 수 있게 변경한다.

<br>

1차로 단순히 거리 계산을 통해 구형 범위로 검사하는 것은 동일하다.

> R : 구형 범위<br>
> C : 청소기 입구 위치<br>
> D : 각 먼지의 위치

![image](https://user-images.githubusercontent.com/42164422/135222916-27124d3e-bc37-451b-b7bc-c78f844382e0.png)

<br>

2차로 내적을 이용해 원뿔 범위로 검사할 수 있다.

> C : 청소기 입구 위치<br>
> D : 각 먼지의 위치<br>
> E : 원뿔 밑단 외곽의 한 점<br>
> F : 원뿔 밑단 중심점

![image](https://user-images.githubusercontent.com/42164422/135222977-b6a7511d-34de-4f21-b0db-98e2e37f1951.png)

<br>

## **[1] 컴퓨트 쉐이더**

- 내적을 이용하여 원뿔 범위 흡수를 구현한다.

<details>
<summary markdown="span"> 
DustCompute.compute
</summary>

```hlsl
/* 관련 없는 코드는 생략 */

/*************************************************
/*                     Variables
/*************************************************/
RWStructuredBuffer<Dust> DustBuffer;

float3 headPos;    // 진공 청소기 입구 위치
float sqrRange;      // 먼지 흡입 범위(반지름)
float sqrDeathRange; // 먼지 소멸 범위(반지름)
float sqrForce;

float3 forward;     // 진공 청소기 전방 벡터
float dotThreshold; // 진공 청소기 원뿔 영역 내적 범위

/*************************************************
/*                     Methods
/*************************************************/
float SqrMagnitude(float3 vec)
{
    return (vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z);
}

// 먼지 파괴
void DestroyDust(uint i)
{
    DustBuffer[i].isAlive = FALSE;
    InterlockedAdd(aliveNumberBuffer[0], -1);
}

/*************************************************
/*                     Kernels
/*************************************************/
// 1 - 실시간 업데이트
[numthreads(64,1,1)]
void Update (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;
    if(DustBuffer[i].isAlive == FALSE) return;
    
    float3 pos = DustBuffer[i].position;
    float3 offs = (headPos - pos);
    float sqrDist = SqrMagnitude(offs);

    // 입구 주변 - 먼지 소멸
    if (sqrDist < sqrDeathRange)
    {
        DestroyDust(i);
        return;
    }

    // 먼지 이동
    if (sqrDist < sqrRange)
    {
        float3 dir = normalize(offs); // 먼지 -> 청소기 입구 방향
        float dotValue = dot(forward, -dir);

        // 원뿔 범위 내에 있을 경우 빨아들이기
        if(dotValue > dotThreshold)
        {
            float weightedForce = sqrForce / sqrDist;
            DustBuffer[i].position += dir * weightedForce * dotValue;

            // 청소기 뒤편으로 넘어가면 먼지 소멸
            if(dot(headPos - DustBuffer[i].position, dir) < 0)
                DestroyDust(i);
        }
    }
}
```

</details>

<br>

## **[2] 먼지 관리 컴포넌트**

- 미리 내적 기준값을 계산하여 컴퓨트 쉐이더에 전달한다.

<details>
<summary markdown="span"> 
DustManager.cs
</summary>

```cs
private void UpdateDustPositionsGPU()
{
    // ...
    
    ref var head = ref cleanerHead;
    
    // 청소기 전방 벡터(+Z)
    DustCompute.SetVector("forward", head.Forward);
    
    // Dot(A, B) = |A||B|cos(t) 일 때, A와 B가 정규 벡터이면
    // Dot(A, B) = cos(t) 이므로
    // 원뿔 각도 t를 이용해 미리 계산한 cos(t)를 컴퓨트 쉐이더에 전달한다.
    DustCompute.SetFloat("dotThreshold", Mathf.Cos(head.SuctionAngleRad));

    // ...
}
```

</details>

<br>

## **[3] 진공 청소기 컴포넌트**

- 숄더뷰 이동/회전을 구현한다.
- 이동과 좌우 회전은 부모 오브젝트가 담당하고, 상하 회전은 이 컴포넌트가 있는 게임오브젝트가 담당한다.
- 마우스 우클릭에 따라 마우스를 숨기고 드러낼 수 있도록 구현한다.
- 원뿔 기즈모를 그린다.

<details>
<summary markdown="span"> 
VacuumCleanerHead.cs
</summary>

```cs
[SerializeField] private bool run = true;

[Range(0f, 100f), Tooltip("빨아들이는 힘")]
[SerializeField] private float suctionForce = 1f;

[Range(1f, 50f), Tooltip("빨아들이는 범위(거리)")]
[SerializeField] private float suctionRange = 5f;

[Range(0.01f, 90f), Tooltip("빨아들이는 원뿔 각도")]
[SerializeField] private float suctionAngle = 45f;

[Range(0.01f, 5f), Tooltip("먼지가 사망하는 영역 반지름")]
[SerializeField] private float deathRange = 0.2f;

[Range(0.01f, 100f)]
[SerializeField] private float moveSpeed = 50f;

private Transform parent;
private float deltaTime;
private bool mouseLocked = false;

public bool Running => run;
public float SqrSuctionRange => suctionRange * suctionRange;
public float SuctionForce => suctionForce;
public float DeathRange => deathRange;
public float SuctionAngleRad => suctionAngle * Mathf.Deg2Rad;

public Vector3 Position => transform.position;
public Vector3 Forward => transform.forward;

private void Awake()
{
    parent = transform.parent;
}

private void OnDrawGizmos()
{
    Gizmos.color = Color.blue;
    DrawConeGizmo(Position, suctionRange, suctionAngle);

    //Gizmos.color = Color.red;
    //Gizmos.DrawWireSphere(Position, deathRange);
}

private void Update()
{
    deltaTime = Time.deltaTime;

    MouseControl();

    if (mouseLocked)
    {
        Move();
        Rotate();
    }
}

private void MouseControl()
{
    // On/Off
    run = Input.GetMouseButton(0);

    // 마우스 보이기/숨기기
    if (Input.GetMouseButtonDown(1))
    {
        mouseLocked ^= true;
        Cursor.lockState = mouseLocked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !mouseLocked;
    }
}

private void Move()
{
    float x = Input.GetAxisRaw("Horizontal");
    float z = Input.GetAxisRaw("Vertical");
    float y = 0f;
    
    if (Input.GetKey(KeyCode.Space)) y += .5f;
    else if (Input.GetKey(KeyCode.LeftControl)) y -= .5f;

    Vector3 moveVec = new Vector3(x, y, z).normalized * moveSpeed;

    if (Input.GetKey(KeyCode.LeftShift))
        moveVec *= 2f;

    parent.Translate(moveVec * deltaTime, Space.Self);
}

private void Rotate()
{
    float v = Input.GetAxisRaw("Mouse X") * deltaTime * 100f;
    float h = Input.GetAxisRaw("Mouse Y") * deltaTime * 100f;

    // 부모 : 좌우 회전
    parent.localRotation *= Quaternion.Euler(0, v, 0);

    // 상하 회전
    Vector3 eRot = transform.localEulerAngles;
    float nextX = eRot.x - h;
    if (0f < nextX && nextX < 90f)
    {
        eRot.x = nextX;
    }
    transform.localEulerAngles = eRot;
}

// origin : 원뿔 꼭대기
// height : 원뿔 높이
// angle  : 원뿔 각도
private void DrawConeGizmo(Vector3 origin, float height, float angle, int sample = 24)
{
    float deltaRad = Mathf.PI * 2f / sample;
    float circleRadius = Mathf.Tan(angle * Mathf.Deg2Rad) * height;
    Vector3 forward = Vector3.forward * height;

    Vector3 prevPoint = default;
    for (int i = 0; i <= sample; i++)
    {
        float delta = deltaRad * i;
        Vector3 circlePoint = new Vector3(Mathf.Cos(delta), Mathf.Sin(delta), 0f) * circleRadius;
        circlePoint += forward;
        circlePoint = circlePoint.normalized * height;

        circlePoint = transform.TransformPoint(circlePoint);

        Gizmos.DrawLine(circlePoint, origin);
        if (i > 0)
            Gizmos.DrawLine(circlePoint, prevPoint);
        prevPoint = circlePoint;
    }
}
```

</details>

<br>

## **[4] 실행 결과**

![2021_0927_Dust_3D_Cone](https://user-images.githubusercontent.com/42164422/135104053-80e78eea-bd33-4ea5-8990-29f7d43c1f61.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 5. 물리 계산
---

먼지의 속도를 새로운 컴퓨트 버퍼에 저장한다.

기존의 `Dust` 구조체에 속도를 포함시키지 않고 새로운 버퍼를 만들어 저장하는 이유는

컴퓨트 쉐이더 내에서만 기록하는 용도로 사용되며, 다른 쉐이더(Vert/Frag)에서는 참조할 필요가 없기 때문이다.

기존의 계산을 속도, 가속도, 힘 기반으로 변경하고, 중력과 공기저항력을 계산한다.

그리고 현재 위치와 다음 위치 벡터를 이용해 기본적인 충돌(Plane)을 구현한다.

<br>

## **[1] 컴퓨트 쉐이더**

- `velocityBuffer` 변수 선언
- 물리 계산에 필요한 변수들 선언
- 청소기 흡수 계산을 단순 위치 변동 대신 힘 계산으로 변경
- 힘, 가속도, 속도 계산 적용
- 원뿔 영역 교차, Plane 충돌 구현

<details>
<summary markdown="span"> 
DustCompute.compute
</summary>

```hlsl
RWStructuredBuffer<Dust> dustBuffer;        // 먼지 위치, 생존 여부
RWStructuredBuffer<float3> velocityBuffer;  // 먼지 속도
RWStructuredBuffer<uint> aliveNumberBuffer; // 생존한 먼지 개수

int isRunning;    // 청소기 가동 여부
float deltaTime;

float3 boundsMin; // 먼지 생성 영역 - 최소 지점
float3 boundsMax; // 먼지 생성 영역 - 최대 지점

float3 headPos;      // 진공 청소기 입구 위치
float sqrRange;      // 먼지 흡입 범위(반지름) - 제곱
float sqrDeathRange; // 먼지 소멸 범위(반지름) - 제곱
float sqrForce;      // 빨아들이는 힘 - 제곱

float3 headForwardDir; // 진공 청소기 전방 벡터
float dotThreshold;    // 진공 청소기 원뿔 영역 내적 범위

float mass;          // 질량
float gravityForce;  // -Y 방향 중력 강도
float airResistance; // 공기 저항력

[numthreads(64,1,1)]
void Update (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;
    if(dustBuffer[i].isAlive == FALSE) return;

    bool sucking = false;
    float3 F = 0; // 힘 합 벡터
    float3 A = 0; // 가속도 합 벡터
    
    // ===================================================
    //                  청소기로 먼지 흡수
    // ===================================================
    float3 currPos = dustBuffer[i].position;  // 현재 프레임 먼지 위치
    float3 currToHead = (headPos - currPos);  // 청소기 입구 -> 먼지
    float sqrDist = SqrMagnitude(currToHead); // 청소기 입구 <-> 먼지 사이 거리 제곱

    // 먼지 이동
    if (isRunning == TRUE && sqrDist < sqrRange)
    {
        float3 dustToHeadDir = normalize(currToHead); // 먼지 -> 청소기 입구 방향
        float dotValue = dot(headForwardDir, -dustToHeadDir);

        // 원뿔 범위 내에 있을 경우 빨아들이기
        if(dotValue > dotThreshold)
        {
            float suctionForce = sqrForce / sqrDist;

            // 빨아들이는 힘
            F += dustToHeadDir * suctionForce * dotValue;

            sucking = true;
        }
    }
    
    // F = m * a
    // v = a * t

    // ===================================================
    //                    가속도 계산
    // ===================================================
    // [1] 외력
    A += F / mass;

    // [2] 중력
    A += float3(0, -gravityForce, 0);

    // [3] 공기 저항
    A -= velocityBuffer[i] * airResistance;

    // 속도 적용 : V = A * t
    velocityBuffer[i] += A * deltaTime;
    
    // ===================================================
    //              이동 시뮬레이션, 충돌 검사
    // ===================================================
    // 다음 프레임 위치 계산 : S = S0 + V * t
    float3 nextPos = currPos + velocityBuffer[i] * deltaTime;

    // 교차 지점에서 충돌 검사
    // [1] Plane (Y = 0)
    nextPos.y = max(0, nextPos.y);

    // [2] 입구로 완전히 빨아들인 경우, 먼지 파괴
    if(sucking)
    {
        float3 headToNext = nextPos - headPos;

        float3 headToCurrDir = normalize(-currToHead);
        float3 headToNextDir = normalize(headToNext);

        // 현재 프레임에 먼지가 원뿔 범위 내에 있었다면
        if(dot(headForwardDir, headToCurrDir) > dotThreshold)
        {
            // 다음 프레임에 원뿔 밖으로 나가거나 입구에 근접하면 파괴
            if(dot(headForwardDir, headToNextDir) < dotThreshold ||
               SqrMagnitude(headToNext) < sqrDeathRange)
            {
                DestroyDust(i);
            }
        }
    }
    
    // 다음 위치 적용
    dustBuffer[i].position = nextPos;
}
```

</details>

<br>


## **[2] 먼지 관리 컴포넌트**

- 먼지의 속도를 저장하기 위한 새로운 컴퓨트 버퍼 `dustVelocityBuffer`를 만들고 컴퓨트 쉐이더에 할당한다.
- 물리 시뮬레이션에 필요한 변수들을 추가하고 컴퓨트 쉐이더에 전달한다.
- 메소드 구조를 더 깔끔하게 변경한다.

<details>
<summary markdown="span"> 
DustManager.cs
</summary>

```cs
[Header("Physics Options")]
[Range(0f, 20f)]
[SerializeField] private float mass = 1f;           // 먼지 질량
[Range(0f, 20f)]
[SerializeField] private float gravityForce = 9.8f; // 중력 강도
[Range(0f, 100f)]
[SerializeField] private float airResistance = 1f;  // 공기 저항력

private ComputeBuffer dustVelocityBuffer; // 먼지 현재 속도 버퍼

private void InitBuffers()
{
    // ...
    
    // Dust Velocity Buffer
    dustVelocityBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3);

    // ...
}

/// <summary> 컴퓨트 쉐이더 초기화 </summary>
private void InitComputeShader()
{
    // ...
    
    dustCompute.SetBuffer(kernelUpdateID, "velocityBuffer", dustVelocityBuffer);
    
    // ...
}

private void OnDestroy()
{
    // ...
    
    dustVelocityBuffer.Release();
}

private void UpdateDustPositionsGPU()
{
    ref var head = ref cleanerHead;

    Vector3 headPos = head.Position;
    float sqrRange = head.SqrSuctionRange;
    //float sqrDeathRange = head.DeathRange * head.DeathRange;
    float sqrForce      = head.SuctionForce * head.SuctionForce;

    dustCompute.SetInt("isRunning", head.Running ? TRUE : FALSE);
    dustCompute.SetFloat("deltaTime", deltaTime);

    dustCompute.SetVector("headPos", headPos);
    dustCompute.SetFloat("sqrRange", sqrRange);
    //dustCompute.SetFloat("sqrDeathRange", sqrDeathRange);
    dustCompute.SetFloat("sqrForce", sqrForce);

    // 원뿔
    dustCompute.SetVector("headForwardDir", head.Forward);
    dustCompute.SetFloat("dotThreshold", Mathf.Cos(head.SuctionAngleRad));

    // 물리
    dustCompute.SetFloat("mass", mass);
    dustCompute.SetFloat("gravityForce", gravityForce);
    dustCompute.SetFloat("airResistance", airResistance);

    dustCompute.Dispatch(kernelUpdateID, kernelUpdateGroupSizeX, 1, 1);

    aliveNumberBuffer.GetData(aliveNumberArray);
    aliveNumber = (int)aliveNumberArray[0]; 
}
```

</details>


<details>
<summary markdown="span"> 
DustManager.cs - 메소드 구조 변경
</summary>

```cs
private void Start()
{
    Init();
    InitBuffers();
    SetBuffersToShaders();
    PopulateDusts();
}

private void Init()
{
    aliveNumber = instanceNumber;

    kernelPopulateID = dustCompute.FindKernel("Populate");
    kernelUpdateID = dustCompute.FindKernel("Update");

    dustCompute.GetKernelThreadGroupSizes(kernelUpdateID, out uint tx, out _, out _);
    kernelUpdateGroupSizeX = Mathf.CeilToInt((float)instanceNumber / tx);
}

/// <summary> 컴퓨트 버퍼들 생성 </summary>
private void InitBuffers()
{
    /* [Note]
     * 
     * argsBuffer
     * - IndirectArguments로 사용되는 컴퓨트 버퍼의 stride는 20byte 이상이어야 한다.
     * - 따라서 파라미터가 앞의 2개만 필요하지만, 뒤에 의미 없는 파라미터 3개를 더 넣어준다.
     */

    // Args Buffer
    uint[] argsData = new uint[] { dustMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    // Dust Buffer
    dustBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));

    // Dust Velocity Buffer
    dustVelocityBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3);

    // Alive Number Buffer
    aliveNumberBuffer = new ComputeBuffer(1, sizeof(uint));
    aliveNumberArray = new uint[] { (uint)instanceNumber };
    aliveNumberBuffer.SetData(aliveNumberArray);

    // 카메라 프러스텀이 이 영역과 겹치지 않으면 렌더링되지 않는다.
    frustumOverlapBounds = new Bounds(
        Vector3.zero, 
        new Vector3(distributionRange, distributionHeight, distributionRange));
}

/// <summary> 컴퓨트 버퍼들을 쉐이더에 할당 </summary>
private void SetBuffersToShaders()
{
    dustMaterial.SetBuffer("_DustBuffer", dustBuffer);
    dustCompute.SetBuffer(kernelPopulateID, "dustBuffer", dustBuffer);
    dustCompute.SetBuffer(kernelUpdateID, "dustBuffer", dustBuffer);
    dustCompute.SetBuffer(kernelUpdateID, "aliveNumberBuffer", aliveNumberBuffer);
    dustCompute.SetBuffer(kernelUpdateID, "velocityBuffer", dustVelocityBuffer);
}
```

</details>

<br>

## **[3] 실행 결과**

![2021_0929_Dust_Physics1](https://user-images.githubusercontent.com/42164422/135263865-39b67857-42ec-42e3-b521-e03e8f7fd47f.gif)

![2021_0929_Dust_Physics2](https://user-images.githubusercontent.com/42164422/135263875-3c8238ee-9ed3-49c4-9366-4bab7619118d.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 6. 메시 변경, 쉐이더 수정
---

Cube 메시 대신 Quad 메시를 사용한다.

렌더큐를 Transparent로 바꾸고, 먼지 텍스쳐를 적용한다.

그리고 Billboard 효과를 적용한다.

<br>

<!-- --------------------------------------------------------------------------- -->

# 7. 먼지 반지름 적용
---

먼지의 반지름을 고려하여 물리 연산들을 변경한다.

<br>

<!-- --------------------------------------------------------------------------- -->

# 8. Sphere 충돌 구현
---

기본적인 Sphere 충돌을 구현한다.

충돌 시 탄성력을 구현한다.

<br>

<!-- --------------------------------------------------------------------------- -->

# 9. Cube 충돌 구현
---



<br>

<!-- --------------------------------------------------------------------------- -->

# 0. 애셋 적용
---

- 예쁜 방 꾸미기
- 진공 청소기 모델링 적용하기

<br>




<!-- --------------------------------------------------------------------------- -->

<!-- 

TODO

시뮬레이션이라는 이름에 맞게

- 흩날리는 움직임 구현

- 플레인, 큐브, 스피어 등등 충돌과 미끄러짐, 마찰 등 구현

-->

# Github Link
---
- 

<br>



<!-- --------------------------------------------------------------------------- -->

# References
---
- <https://www.youtube.com/watch?v=PGk0rnyTa1U>
- <https://docs.unity3d.com/ScriptReference/Graphics.DrawMeshInstancedIndirect.html>
- <https://github.com/ColinLeung-NiloCat/UnityURP-MobileDrawMeshInstancedIndirectExample>

<!-- 
https://github.com/SebLague/Super-Chore-Man/blob/main/Assets/Scripts/Particles/DustCompute.compute
-->


<!-- 복붙


## **[1] 컴퓨트 쉐이더**

<details>
<summary markdown="span"> 
DustCompute.compute
</summary>

```hlsl

```

</details>

<br>


## **[2] 먼지 관리 컴포넌트**

<details>
<summary markdown="span"> 
DustManager.cs
</summary>

```cs

```

</details>

<br>


## **[3] 진공 청소기 컴포넌트**

<details>
<summary markdown="span"> 
VacuumCleanerHead.cs
</summary>

```cs

```

</details>

<br>



-->