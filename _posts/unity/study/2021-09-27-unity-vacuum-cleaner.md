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
- 진공 청소기로 빨아들인다.

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

## **DirtsManager.cs**

- 먼지 생성 및 관리를 담당한다.

<details>
<summary markdown="span"> 
Fields
</summary>

```cs
private const int TRUE = 1;
private const int FALSE = 0;

private struct Dirt
{
    public Vector3 position;
    public int isAlive;
}

[Header("Dirt Options")]
[SerializeField] private Mesh dirtMesh;         // 먼지 메시
[SerializeField] private Material dirtMaterial; // 먼지 마테리얼

[Space]
[SerializeField] private int instanceNumber = 100000;    // 생성할 먼지 개수
[SerializeField] private float distributionRange = 100f; // 먼지 분포 범위(정사각형 너비)
[Range(0.01f, 2f)]
[SerializeField] private float dirtScale = 1f;           // 먼지 크기

private ComputeBuffer dirtBuffer; // 먼지 데이터 버퍼(위치, ...)
private ComputeBuffer argsBuffer; // 먼지 렌더링 데이터 버퍼

private Bounds frustumOverlapBounds;
private Dirt[] dirtArray;
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
    dirtMaterial.SetFloat("_Scale", dirtScale);
    Graphics.DrawMeshInstancedIndirect(dirtMesh, 0, dirtMaterial, bounds, argsBuffer);
}
private void OnDestroy()
{
    dirtBuffer.Release();
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
    uint[] argsData = new uint[] { (uint)dirtMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    aliveNumber = instanceNumber;

    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    PopulateDirts();

    // Dirt Buffer
    dirtBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));
    dirtBuffer.SetData(dirtArray);
    dirtMaterial.SetBuffer("_DirtBuffer", dirtBuffer);

    // 카메라 프러스텀이 이 영역과 겹치지 않으면 렌더링되지 않는다.
    frustumOverlapBounds = new Bounds(Vector3.zero, new Vector3(distributionRange, 1f, distributionRange));
}

/// <summary> 먼지들을 영역 내의 무작위 위치에 생성한다. </summary>
private void PopulateDirts()
{
    dirtArray = new Dirt[instanceNumber];

    float min = -0.5f * distributionRange;
    float max = -min;
    for (int i = 0; i < instanceNumber; i++)
    {
        float x = UnityEngine.Random.Range(min, max);
        float z = UnityEngine.Random.Range(min, max);
        dirtArray[i].position = new Vector3(x, 0f, z);
        dirtArray[i].isAlive = TRUE;
    }
}
```

</details>

<br>

## **DirtShader.shader**

- 먼지 렌더링을 담당한다.

- 먼지의 위치를 컴퓨트 버퍼에 저장하면, CPU가 아니라 쉐이더를 통해 GPU로 위치 변경사항을 적용한다.

<details>
<summary markdown="span"> 
...
</summary>

```hlsl
Shader "Rito/Dirt"
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

            struct Dirt
            {
                float3 position;
                int isAlive;
            };

            uniform float _Scale;
            StructuredBuffer<Dirt> _DirtBuffer;

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                // 먼지 생존 여부 받아와서 프래그먼트 쉐이더에 전달
                o.isAlive = _DirtBuffer[instanceID].isAlive;

                // 먼지 크기 결정
                v.vertex *= _Scale; 

                // 먼지 위치 결정
                float3 instancePos = _DirtBuffer[instanceID].position;
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

![2021_0927_Dirt1](https://user-images.githubusercontent.com/42164422/134875331-f70f4555-7b70-49a6-8049-ae35740165a0.gif)

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
DirtsManager.cs
</summary>

```cs
private void Update()
{
    UpdateDirtPositions();
    dirtMaterial.SetFloat("_Scale", dirtScale);
    Graphics.DrawMeshInstancedIndirect(dirtMesh, 0, dirtMaterial, frustumOverlapBounds, argsBuffer);
}

private void UpdateDirtPositions()
{
    if (cleanerHead.Running == false) return;

    Vector3 centerPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float force = Time.deltaTime * cleanerHead.SuctionForce;

    for (int i = 0; i < instanceNumber; i++)
    {
        if (dirtArray[i].isAlive == FALSE) continue;

        // root 연산은 비싸기 때문에 제곱 상태로 거리 비교
        float sqrDist = Vector3.SqrMagnitude(dirtArray[i].position - centerPos);
        
        // 사망 범위
        if (sqrDist < sqrDeathRange)
        {
            dirtArray[i].isAlive = FALSE;
            aliveNumber--;
        }
        // 흡입 범위
        else if (sqrDist < sqrRange)
        {
            dirtArray[i].position = Vector3.Lerp(dirtArray[i].position, centerPos, force);
        }
    }

    dirtBuffer.SetData(dirtArray);
}
```

</details>

![2021_0927_DirtUpdate1](https://user-images.githubusercontent.com/42164422/134880151-4068c99e-a84d-4cdb-8f49-5e88eb31ea89.gif)

<br>

## **[2] CPU 병렬 계산**

- `Parallel`을 통한 멀티스레딩으로 CPU 연산을 적용한다.

- 그리고 먼지가 단순히 `Vector3.Lerp()`를 통해 이동하는 대신, 거리가 가까울수록 빠르게 이동하도록 계산 방식을 변경한다.

<details>
<summary markdown="span"> 
DirtsManager.cs
</summary>

```cs
private void UpdateDirtPositions()
{
    if (cleanerHead.Running == false) return;

    Vector3 centerPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float sqrForce = Time.deltaTime * cleanerHead.SuctionForce * cleanerHead.SuctionForce;

    // 병렬 처리(동기)
    Parallel.For(0, instanceNumber, i =>
    {
        if (dirtArray[i].isAlive == FALSE) return;

        float sqrDist = Vector3.SqrMagnitude(centerPos - dirtArray[i].position);

        // 사망 범위
        if (sqrDist < sqrDeathRange)
        {
            dirtArray[i].isAlive = FALSE;
            Interlocked.Decrement(ref aliveNumber);
        }
        // 흡입 범위
        else if (sqrDist < sqrRange)
        {
            Vector3 dir = (centerPos - dirtArray[i].position).normalized;
            float weightedForce = sqrForce / sqrDist;
            dirtArray[i].position += dir * weightedForce;
        }
    });

    dirtBuffer.SetData(dirtArray);
}
```

</details>

![2021_0927_DirtUpdate2](https://user-images.githubusercontent.com/42164422/134881462-c07f57ba-097c-41fd-87f6-f2639c53f463.gif)

<br>

## **[3] 컴퓨트 쉐이더 병렬 연산**

- 먼지 이동 연산을 컴퓨트 쉐이더로 넘겨서 처리한다.
- 컴퓨트 쉐이더의 연산 결과를 다시 CPU로 가져오는 작업이 없고, 대신 컴퓨트 버퍼를 Vert/Frag 쉐이더에서 바로 참조하여 적용하므로 매우 빠르다.

<details>
<summary markdown="span"> 
DirtUpdater.compute
</summary>

```hlsl
#pragma kernel CSMain

#define TRUE 1
#define FALSE 0

struct Dirt
{
    float3 position;
    int isAlive;
};

RWStructuredBuffer<Dirt> dirtBuffer;
RWStructuredBuffer<uint> aliveNumberBuffer; // 생존한 먼지 개수

float3 centerPos;
float sqrRange;
float sqrDeathRange;
float sqrForce;

[numthreads(64,1,1)]
void CSMain (uint3 id : SV_DispatchThreadID)
{
    uint i = id.x;
    if(dirtBuffer[i].isAlive == FALSE) return;
    
    // 제곱 상태로 연산
    float3 offs = (centerPos - dirtBuffer[i].position);
    float sqrDist = (offs.x * offs.x) + (offs.y * offs.y) + (offs.z * offs.z);

    // 사망 범위
    if (sqrDist < sqrDeathRange)
    {
        dirtBuffer[i].isAlive = FALSE;
        InterlockedAdd(aliveNumberBuffer[0], -1);
    }
    // 흡입 범위
    else if (sqrDist < sqrRange)
    {
        float3 dir = normalize(centerPos - dirtBuffer[i].position);
        float weightedForce = sqrForce / sqrDist;
        dirtBuffer[i].position += dir * weightedForce;
    }
}
```

</details>

<details>
<summary markdown="span"> 
DirtsManager.cs
</summary>

```cs
/* 기타 필드 생략 */

[SerializeField] private ComputeShader dirtCompute;
private ComputeBuffer dirtBuffer; // 먼지 데이터 버퍼(위치, ...)
private ComputeBuffer argsBuffer; // 먼지 렌더링 데이터 버퍼
private ComputeBuffer aliveNumberBuffer; // 생존 먼지 개수 RW

private Bounds frustumOverlapBounds;
private Dirt[] dirtArray;

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
    UpdateDirtPositionsGPU();
    dirtMaterial.SetFloat("_Scale", dirtScale);
    Graphics.DrawMeshInstancedIndirect(dirtMesh, 0, dirtMaterial, frustumOverlapBounds, argsBuffer);
}
private void OnDestroy()
{
    dirtBuffer.Release();
    argsBuffer.Release();
    aliveNumberBuffer.Release();
}

/// <summary> 컴퓨트 버퍼들 생성 </summary>
private void InitBuffers()
{
    // Args Buffer
    // IndirectArguments로 사용되는 컴퓨트 버퍼의 stride는 20byte 이상이어야 한다.
    // 따라서 파라미터가 앞의 2개만 필요하지만, 뒤에 의미 없는 파라미터 3개를 더 넣어준다.
    uint[] argsData = new uint[] { (uint)dirtMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };
    aliveNumber = instanceNumber;

    argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
    argsBuffer.SetData(argsData);

    PopulateDirts();

    // Dirt Buffer
    dirtBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3 + sizeof(int));
    dirtBuffer.SetData(dirtArray);
    dirtMaterial.SetBuffer("_DirtBuffer", dirtBuffer);

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
    dirtCompute.SetBuffer(0, "dirtBuffer", dirtBuffer);
    dirtCompute.SetBuffer(0, "aliveNumberBuffer", aliveNumberBuffer);
    dirtCompute.GetKernelThreadGroupSizes(0, out uint tx, out _, out _);
    kernelGroupSizeX = Mathf.CeilToInt((float)instanceNumber / tx);
}

private void UpdateDirtPositionsGPU()
{
    if (cleanerHead.Running == false) return;

    Vector3 centerPos = cleanerHead.Position;
    float sqrRange = cleanerHead.SqrSuctionRange;
    float sqrDeathRange = cleanerHead.DeathRange * cleanerHead.DeathRange;
    float sqrForce = Time.deltaTime * cleanerHead.SuctionForce * cleanerHead.SuctionForce;

    dirtCompute.SetVector("centerPos", centerPos);
    dirtCompute.SetFloat("sqrRange", sqrRange);
    dirtCompute.SetFloat("sqrDeathRange", sqrDeathRange);
    dirtCompute.SetFloat("sqrForce", sqrForce);

    dirtCompute.Dispatch(0, kernelGroupSizeX, 1, 1);

    aliveNumberBuffer.GetData(aliveNumberArray);
    aliveNumber = (int)aliveNumberArray[0];
}
```

</details>


![2021_0927_DirtUpdate3](https://user-images.githubusercontent.com/42164422/134906449-5b7787aa-a7f6-44cd-a151-c1b460fc6c7c.gif)

<br>


<!-- --------------------------------------------------------------------------- -->

# 3. 먼지 생성 최적화
---

난수를 발생시켜 먼지를 무작위 위치에 생성하던 부분을 CPU가 아니라 컴퓨트 쉐이더 내에서 연산하도록 한다.

<br>


<!-- --------------------------------------------------------------------------- -->

# 4. 메시 변경, 텍스쳐 적용
---

Cube 메시 대신 +Y를 바라보는 Quad 메시를 사용한다.

렌더큐를 Transparent로 바꾸고, 먼지 텍스쳐를 적용한다.

<br>



<!-- --------------------------------------------------------------------------- -->

# 5. 애셋 적용
---

- 예쁜 방 꾸미기
- 진공 청소기 모델링 적용하기

<br>



<!-- --------------------------------------------------------------------------- -->

# 6. 이동 구현
---

- 진공 청소기 이동, 카메라 이동 및 회전

<br>



<!-- --------------------------------------------------------------------------- -->

# Download
---
- 

<br>



<!-- --------------------------------------------------------------------------- -->

# References
---
- <https://www.youtube.com/watch?v=PGk0rnyTa1U>
- <https://docs.unity3d.com/ScriptReference/Graphics.DrawMeshInstancedIndirect.html>
- <https://github.com/ColinLeung-NiloCat/UnityURP-MobileDrawMeshInstancedIndirectExample>
