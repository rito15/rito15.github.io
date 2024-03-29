---
title: 유니티 - 컴퓨트 쉐이더(Compute Shader)
author: Rito15
date: 2021-09-10 02:01:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Compute Shader
---

## **개념**
 - **GPGPU**(General-Purpose computing on GPU)를 이용해 대규모 병렬처리를 수행하는 쉐이더
 - 동시에 수많은 대상(~ 수십만, 수백만 단위)에 대해 동일한 연산(함수)을 처리해야 할 때 사용한다.
 - 컴퓨트 쉐이더를 연산에 사용하는 예시로 **VFX Graph**가 있다.
 - 확장자는 `.compute`.

<!--

 - **CUDA**, **OpenCL**는 **GPGPU**를 사용하는 독립 API이고, **OpenGL**의 **Compute Shader**, **DirectX**의 **DirectCompute**는 그래픽스API에 종속되어 동작한다.

-->
 
## **커널(Kernal)**
 - GPU에서 동작하는 함수를 의미한다.
 - 함수의 이름이 곧 커널의 이름이며, `#pragma kernel`에도 명시해 주어야 한다.

## **스레드 그룹(Thread Group)**
 - 여러 개의 스레드를 묶어 처리하는 단위
 - 하나의 스레드 그룹 당 `[numthreads(x, y, z)]`로 지정된 개수만큼의 스레드를 실행한다.
 - 스레드 그룹의 개수는 컴퓨트 쉐이더 객체를 `.Dispatch(kernalIndex, X, Y, Z)`로 실행할 때 인자로 지정한다.
 - 개수는 3차원(`X, Y, Z`)으로 구성된다.

## **스레드(Thread)**
 - 커널(함수)을 실행하는 단위.
 - 하나의 스레드가 하나의 커널을 실행한다.
 - 개수는 3차원(`x, y, z`)으로 구성된다.
 - 커널 함수 선언부 상단에 `[numthreads(x, y, z)]`를 붙여 스레드의 개수를 3차원으로 지정한다.
 - `(x * y * z)`는 하나의 스레드 그룹에서 실행될 스레드의 총 개수이다.

## **스레드 개수의 차원 설정**
 - `1024 * 1 * 1`로 1차원으로 지정하는 경우도 있고, `32 * 32 * 1`처럼 2차원으로, 혹은 3차원으로 지정하는 경우도 있다.
 - 이는 계산할 데이터의 차원에 따라 결정한다.
 - 예를 들어 동일한 연산을 단순 병렬처리할 때는 1차원으로 할 수 있다.
 - 렌더 텍스쳐와 같이 2차원 계산이 필요한 경우, 2차원으로 설정한다.
 - 공간과 같이 3차원 계산이 필요하면 3차원으로 설정한다.

## **스레드 개수 한계**
 - 스레드 그룹 수의 한계는 `X`, `Y`, `Z` 각 차원마다 각각 **65535**( $${2}^{16} - 1$$ )이다.
 - 하나의 스레드 그룹이 가질 수 있는 스레드 개수에도 제한이 있다.
   - ShaderModel cs_4_x에서 `x * y * z`의 최댓값은 **768**로 제한되며, 이 중 `z`는 1이어야 한다.
   - ShaderModel cs_5_0에서 `x * y * z`의 최댓값은 **1024**, `z`의 최댓값은 64이다.

## **스레드 개수 계산 예시**
 - 먼저, 필요한 전체 스레드 개수를 계산한다.
 - 예를 들어 `1024 * 768` 크기의 렌더 텍스쳐를 2차원으로 병렬 연산한다고 가정하자.
 - 하나의 스레드 그룹이 가질 스레드의 개수를 `8 * 8 * 1`로 둔다. <br>
   (더 크게 할 수도 있지만, 너무 크게 했다가 낭비되는 스레드가 생길 수 있으므로 적절히 설정한다.)
 - 스레드 그룹의 개수는 `(1024 / 8) * (768 / 8) * (1 / 1)` = `128 * 96 * 1`이 된다.
 
 - 따라서 커널 상단에 `[numthreads(8, 8, 1)]`로 지정하고,
 - 컴퓨트 쉐이더를 실행할 때 `Dispatch(index, 128, 96, 1)` 이렇게 호출한다.
 
## **최적의 스레드 개수**
 - 타겟 디바이스의 GPU 사양에 따라 달라진다.
 - 일반적으로 하나의 스레드 그룹 당 할당되는 총 스레드 개수는 `32`의 배수로 최대 `256`개를 지정하는 것이 성능에 좋다고 한다.
 - 예를 들어 `[numthreads(8, 8, 4)]`, `[numthreads(16, 16, 1)]`, `[numthreads(256, 1, 1)]` 등등
 - 그런데 컴퓨트 쉐이더의 동작은 스레드 그룹 단위로 이루어지므로,<br>
   스레드 그룹 당 256개를 할당해놓고 스레드 100개만 실행시키면 156개는 낭비된다.
 - 따라서 여러 상황을 고려하여 최대 256개로, 낭비를 고려하여 적당히 줄여서 설정해야 한다.

## **참고사항**
 - 타겟 플랫폼의 컴퓨트 쉐이더 지원 여부는 `SystemInfo.supportsComputeShaders`를 통해 확인할 수 있다.
 - 컴퓨트 쉐이더의 연산 결과를 렌더 텍스쳐에 받아 오려면 렌더 텍스쳐의 랜덤 액세스 기능을 활성화해야 한다.
 - `RenderTexture.enableRandomWrite = true`로 설정하면 된다.
 - 또한 렌더 텍스쳐의 생성자에 `RenderTextureReadWrite.Linear` 옵션을 5번째 매개변수로 전달해야 한다.
 - 필요한 연산 수보다 더 많은 스레드를 생성하면 불필요한 성능 낭비가 생기므로, 스레드 개수는 연산에 필요한 만큼 딱 맞춰 설정하는 것이 좋다.

## **쉐이더 참고사항**
 - 컴퓨트 쉐이더 내에서는 `_Time`과 같은 Built-in 변수들을 사용할 수 없으며, CPU 측에서 전달해줘야 한다.

<br>

# ComputeShader 클래스 API
---

## **Dispatch(int kernalIndex, int x, int y, int z) : void**
 - 컴퓨트 쉐이더를 실행시킨다.
 - 연산 결과는 `Dispatch()`로부터 명시적으로 받아오는 것이 아니라, 미리 등록했던 입출력 변수(`RWTexture2D<float4>` 등등)로부터 받아오면 된다.

 - **매개변수**
   - `kernalIndex` : 실행할 커널 함수의 인덱스(기본 0)
   - `x`, `y`, `z` : 각 차원마다 스레드 그룹 개수 지정


## **FindKernal(string name) : int**
 - 커널 함수의 이름을 통해 해당 커널의 인덱스를 찾아 반환한다.
 - 커널 함수를 찾지 못하면 `FindKernel failed` 에러 로그를 출력한다.

 - **매개변수**
   - `name` : 찾을 커널 함수의 이름
 
 
## **GetKernelThreadGroupSize(...) : void**
 - **GetKernelThreadGroupSize(int kernalIndex, out uint x, out uint y, out uint z)**
 
 - 스레드 그룹의 각 차원이 갖고 있는 크기(스레드 개수)를 받아온다.
 - `[numthreads(x, y, z)]`에 입력한 값들을 받아오는 것이다.
 
 - 컴퓨트 쉐이더를 실행하기 전에 이 메소드를 이용해 스레드 개수를 알아내고 <br>
   `Dispatch(index, X / x, Y / y, Z / z)` 처럼 사용할 수 있다.
 
 - **매개변수**
   - `kernalIndex` : 실행할 커널 함수의 인덱스(기본 0)
   - `x`, `y`, `z` : 각각의 차원마다, 스레드 그룹 하나 당 실행할 스레드 개수


## **SetFloat(...) : void**
 - **SetFloat(string name, float value)**
 - **SetFloat(int nameID, float value)**
 
 - 컴퓨트 쉐이더에 선언된 `float` 타입 변수에 값을 전달한다.

 - **매개변수**
   - `name` : 컴퓨트 쉐이더 내의 버퍼 변수 이름
   - `nameID` : 해당 변수에 부여된 정수형 ID. `Shader.PropertyToID()`를 통해 얻을 수 있다.
   - `value` : 전달할 실수 값


## **SetFloats(...) : void**
 - **SetFloat(string name, params float[] values)**
 - **SetFloat(int nameID, params float[] values)**
 
 - 컴퓨트 쉐이더에 선언된 하나의 변수에 여러 개의 값을 전달한다.
 - `float` 벡터, 배열, 벡터 배열 변수에 값을 전달할 수 있다.
 - 예를 들어 `float4 myArr[3]` 벡터 배열 변수에 값 12개를 한 번에 전달할 수 있다.


## **SetVector(...) : void**
 - **SetFloat(string name, Vector4 value)**
 - **SetFloat(int nameID, Vector4 value)**
 
 - 컴퓨트 쉐이더에 선언된 `float4` 타입 변수에 값을 전달한다.


## **SetMatrix(...) : void**
 - **SetMatrix(string name, Matrix4x4 value)**
 - **SetMatrix(int nameID, Matrix4x4 value)**
 
 - 컴퓨트 쉐이더에 선언된 `float4x4` 타입 변수에 값을 전달한다.


## **SetTexture(...) : void**
 - **SetBuffer(int kernalIndex, string name, Texture texture)**
 - **SetBuffer(int kernalIndex, int nameID, Texture texture)**
 - **SetBuffer(int kernalIndex, string name, Texture texture, int mipLevel)**
 - **SetBuffer(int kernalIndex, int nameID, Texture texture, int mipLevel)**
 
 - 컴퓨트 쉐이더에 선언된 입력 전용의 텍스쳐 타입(`Texture2D` 등) 또는 입출력 가능한 텍스쳐 타입(`RWTexture2D<float4>` 등) 변수에 값을 전달한다.
 - 입출력 텍스쳐는 `enableRandomWrite = true` 설정이 된 `RenderTexture`를 사용할 수 있다.

 - **매개변수**
   - `texture` : 입력 혹은 입출력으로 사용할 텍스쳐 객체
   - `mipLevel` : 밉맵 레벨 설정. 입출력 텍스쳐가 아닌 경우에는 무시된다.


## **SetBuffer(...) : void**
 - **SetBuffer(int kernalIndex, string name, ComputeBuffer buffer)**
 - **SetBuffer(int kernalIndex, int nameID, ComputeBuffer buffer)**
 - 입출력으로 사용할 컴퓨트 버퍼 객체를 컴퓨트 쉐이더에 설정한다.

<br>

# ComputeBuffer 클래스 API
---

## **컴퓨트 버퍼?**
 - 컴퓨트 쉐이더를 사용할 때, CPU와 GPU가 데이터를 주고 받기 위해 사용된다.
 - 컴퓨트 쉐이더뿐만 아니라 일반 쉐이더에서도 사용할 수 있다.
 - 쉐이더 내부에서는 `RWStructuredBuffer<T>`, `StructuredBuffer<T>`에 매핑된다.
 - 개별 타입(`float`, 벡터 종류 등) 또는 구조체의 **배열 변수**를 공유 데이터로 사용한다.
   - 구조체를 사용할 경우, CPU와 GPU(쉐이더) 양측에 각각 동일하게 선언해야 한다.

<br>

## **생성자**
 - **ComputeBuffer(int count, int stride)**
 - **ComputeBuffer(int count, int stride, ComputeBufferType type)**

 - **매개변수**
   - `count` : 버퍼 내의 요소 개수(쉽게 말해, 배열의 Length)
   - `stride` : 버퍼 요소 하나의 크기. 쉐이더 내 버퍼 타입의 크기와 일치해야 한다.<br>
     예를 들어 `float3`, `float4`를 필드로 갖고 있는 구조체를 사용할 경우<br>
     `stride`의 값은 `sizeof(float) * 7`
   - `type` : 컴퓨트 쉐이더의 사용과 쉐이더 내의 변수 정의애 따라 달라진다.<br>
     입력하지 않을 경우 기본 값은 `Default`이며,<br>
     `RWStructuredBuffer<T>` 또는 `StructuredBuffer<T>`를 의미한다.

<br>

## **프로퍼티**
 - `int count` : 버퍼 내 요소의 개수(읽기 전용)
 - `int stride` : 버퍼 내 각 요소의 크기(읽기 전용)

<br>

## **SetData() : void**
 - **SetData(Array data)**
 - **SetData(List&lt;T&gt; data)**
 - **SetData(NativeArray&lt;T&gt; data)**
 
 - **SetData(data, int arrayIndex, int bufferIndex, int count)**
 
 - CPU가 갖고 있는 배열을 컴퓨트 버퍼에 등록한다.
 - 매개변수가 4개인 메소드의 경우, 배열의 특정 인덱스(`arrayIndex`)부터 `count` 개수 만큼의 데이터를 
   버퍼의 특정 인덱스(`bufferIndex`)부터 `count` 개수만큼의 범위에 등록한다.

## **GetData() : void**
 - **GetData(Array data)**
 - **GetData(Array data, int arrayIndex, int bufferIndex, int count)**
 
 - 컴퓨트 버퍼의 데이터 값을 배열로 가져온다.
 - 매개변수가 4개인 메소드의 경우, 버퍼의 특정 인덱스(`bufferIndex`)부터 `count` 개수만큼의 데이터를 
   배열의 특정 인덱스(`arrayIndex`)부터 `count` 개수만큼의 범위에 가져온다.

## **IsValid() : bool**
 - 컴퓨트 버퍼가 유효한지 여부를 참조한다.

## **Release() : void**
 - 컴퓨트 버퍼를 해제한다.
 - 컴퓨트 버퍼 객체는 더이상 사용되지 않을 때, 예를 들면 `OnDestroy()`에서 반드시 직접 해제 해줘야 한다.

<br>

# 예제 : Render Texture
---
 - 화면에 스크린 UV 출력하기

![image](https://user-images.githubusercontent.com/42164422/132733632-5ee83e86-c7d1-4483-81b0-db0904e843de.png)

<br>

## DrawScreenUV.compute

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```hlsl
// 커널 함수의 이름을 명시한다.
#pragma kernel CSMain

// 커널 계산을 마치고 결과를 출력할 입출력 텍스쳐
// 렌더 텍스쳐 포맷과 채널을 일치시킨다. (RGBA 4채널 => float4)
RWTexture2D<float4> Result;

// 스레드 그룹 당 쉐이더 개수 = 8 * 8 * 1 = 64
// 2D 텍스쳐에 대한 연산이므로 2차원으로 스레드 할당
[numthreads(8,8,1)]
void CSMain (uint3 id : SV_DispatchThreadID)
{
    // Note : 각 차원마다 총 스레드 개수(그룹 * 그룹당 스레드 수)가 (x, y, z)일 때,
    //        매개변수 id의 값은 (0, 0, 0) ~ (x - 1, y - 1, z - 1)까지 차례로 할당된다.

    // 텍스쳐 변수(렌더 텍스쳐)의 X, Y 성분의 길이, 즉 너비와 높이를 찾아온다.
    uint width, height;
    Result.GetDimensions(width, height);

    // 스크린 픽셀 좌표를 [0, 1] 범위로 변환한다.
    float2 uv = id.xy / float2(width, height);

    // 텍스쳐에 색상을 넣는다.
    Result[id.xy] = float4(uv, 0, 1);
}
```

</details>

<br>

## ScreenUVRenderer.cs
 
<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
using UnityEngine;

public class ScreenUVRenderer : MonoBehaviour
{
    // 컴퓨트 쉐이더 객체를 인스펙터에서 할당한다.
    public ComputeShader computeShader;
    private RenderTexture _renderTarget;

    // 매프레임 화면의 렌더가 끝나면 호출된다.
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Render(destination);
    }

    private void Render(RenderTexture destination)
    {
        // 렌더 텍스쳐의 초기화를 확인한다.
        InitRenderTexture();

        // 렌더 텍스쳐를 컴퓨트 쉐이더의 Result 변수에 입출력 텍스쳐로 할당한다.
        computeShader.SetTexture(0, "Result", _renderTarget);
        
        // 2차원 X, Y 스레드 그룹의 개수를 계산한다.
        // 각 차원마다 실행되는 스레드 수는 해당 차원의 스크린 픽셀 개수(너비, 높이)이며,
        // 따라서 (X Y 스레드 그룹 개수) = (너비 높이 / 그룹당 스레드 개수)이다.
        // 혹시나 계산 안되는 영역이 없도록, 개수는 버림 대신 올림 연산을 사용하여 정수로 변환한다.
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        
        // 커널 ID(기본 0), 스레드 그룹 개수를 지정하여 컴퓨트 쉐이더를 실행한다.
        computeShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        // 결과 텍스쳐를 화면에 출력한다.
        Graphics.Blit(_renderTarget, destination);
    }

    private void InitRenderTexture()
    {
        // 렌더 텍스쳐가 제거되거나, 크기에 변경이 생기면 재할당한다.
        if (_renderTarget == null || _renderTarget.width != Screen.width || _renderTarget.height != Screen.height)
        {
            // 크기가 다른 렌더 텍스쳐가 이미 존재하고 있었다면 메모리에서 해제한다.
            if (_renderTarget != null)
                _renderTarget.Release();

            // 알맞은 설정의 렌더 텍스쳐를 생성한다.
            // 생성자의 세 번째 파라미터는 Z버퍼의 한 픽셀당 크기를 의미하며, 필요 없으므로 0으로 둔다.
            
            // RenderTextureReadWrite는 Linear로 설정하고,
            // RenderTextureFormat은 컴퓨트 쉐이더의 해당 텍스쳐 변수 채널에 알맞게 설정한다.
            // ARGBFLoat는 32비트 float4이다.
            // 지금은 RG 채널에서 계산된 UV만 출력하므로, 최대한 효율적으로 사용하려면 RG16 포맷을 사용해도 된다.
            
            _renderTarget = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            
            // 입출력 텍스쳐로 사용하기 위해 enableRandomWrite는 true로 설정해야 한다.
            _renderTarget.enableRandomWrite = true;
            _renderTarget.Create();
        }
    }
}
```

</details>

<br>

# 예제 : Compute Buffer
---

- 큐브 위치, 색상 시뮬레이션
- 이 예제의 연산은 컴퓨트 쉐이더로 실행할만큼 무겁지 않으니 CPU 연산에 비해 이득이 되지는 않는다.
- 컴퓨트 쉐이더 연산 결과를 CPU로 가져와서 적용하는 `_cubeBuffer.GetData()`도 병목일 수 있으므로, 컴퓨트 버퍼를 완전히 활용하려면 컴퓨트 쉐이더의 연산 결과를 바로 Vert/Frag 쉐이더에서 컴퓨트 버퍼 변수로 참조하여 GPU 내에서 갱신해주는 것이 좋다.

![2021_0926_CubeSimulator](https://user-images.githubusercontent.com/42164422/134808168-206cc357-2a11-4591-9af6-a1c375e1cd6b.gif)

<br>

## SimulateCubes.compute

<details>
<summary markdown="span"> 
...
</summary>

```hlsl
#pragma kernel CSMain

// 컴퓨트 버퍼에 사용될 타입
// CPU측의 구조체와 일치시킨다.
struct Cube
{
    float3 position;
    float4 color;
};

// 컴퓨트 버퍼를 통해 공유될 변수
RWStructuredBuffer<Cube> cubeBuffer;
float time;
float updateSpeed;
float rowSize;
float waveFrequency;

// 1차원으로 스레드 그룹 당 스레드를 할당한다.
[numthreads(16,1,1)]
void CSMain (uint3 id : SV_DispatchThreadID)
{
    float t = time * updateSpeed;
    float t2 = t * 0.5;
    float i = fmod(id.x, rowSize);
    float wave = (i + t) * waveFrequency;

    // 1. 위치
    float3 pos = cubeBuffer[id.x].position;
    pos.y = sin(wave);

    // 2. 색상
    float k = sin(i / rowSize + t2) * 0.5 + 0.5;
    cubeBuffer[id.x].position = pos;
    cubeBuffer[id.x].color = lerp(float4(1, 0, 0, 1), float4(0, 0, 1, 1), k);
}

```

</details>

<br>

## CubeSimulator.cs
 
<details>
<summary markdown="span"> 
...
</summary>

```cs
using UnityEngine;

// 날짜 : 2021-09-26 PM 8:59:19
// 작성자 : Rito

/// <summary> 
/// 큐브 위치, 색상 시뮬레이션
/// </summary>
public class CubeSimulator : MonoBehaviour
{
    private struct Cube
    {
        public Vector3 position;
        public Color color;
    }

    [Tooltip("true : 컴퓨트 쉐이더 사용 / false : CPU 사용")]
    [SerializeField] private bool useComputeShader = true;

    [Space]
    [SerializeField] private ComputeShader computeShader;
    [SerializeField] private Material cubeMaterial;

    [Space]
    [Range(0f, 100f)]
    [SerializeField] private float updateSpeed = 10f;
    [Range(0f, 2f)]
    [SerializeField] private float waveFrequency = 0.5f;

    [Space]
    [SerializeField] private float cubePositionInterval = 1f;
    [SerializeField] private float cubeScale = 1f;
    [SerializeField] private int rowSize = 64; // 행, 열 크기

    private MeshRenderer[] _cubeRenderers;
    private Transform[] _cubeTransforms;
    private Cube[] _cubeDatas;

    private MaterialPropertyBlock _mpb;
    private ComputeBuffer _cubeBuffer;
    private int _cubeCount;

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Start()
    {
        Init();
        CreateCubes();
        InitComputeShaderData();
    }
    private void Update()
    {
        if (useComputeShader)
        {
            DispatchComputeShader();
            GetDataFromComputeShader();
        }
        else
        {
            UpdateCPU();
        }
    }
    private void OnDestroy()
    {
        _cubeBuffer.Release();
    }
    #endregion
    /***********************************************************************
    *                               Init Methods
    ***********************************************************************/
    #region .
    private void Init()
    {
        _mpb = new MaterialPropertyBlock();
    }

    /// <summary> 정방형 분포 큐브들 생성 </summary>
    /// lineCount : 행, 열 개수
    private void CreateCubes()
    {
        _cubeCount = rowSize * rowSize;
        _cubeRenderers = new MeshRenderer[_cubeCount];
        _cubeTransforms = new Transform[_cubeCount];
        _cubeDatas = new Cube[_cubeCount];

        for (int j = 0; j < rowSize; j++)
        {
            for (int i = 0; i < rowSize; i++)
            {
                // 큐브 게임오브젝트 생성
                var goCube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                Transform trCube = goCube.transform;
                trCube.localScale = Vector3.one * cubeScale;
                trCube.localPosition = new Vector3(i * cubePositionInterval, 0f, j * cubePositionInterval);

                // 리스트에 추가
                _cubeTransforms[j * rowSize + i] = trCube;

                MeshRenderer mrCube = goCube.GetComponent<MeshRenderer>();
                if (mrCube != null)
                {
                    mrCube.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    mrCube.material = cubeMaterial;
                    _cubeRenderers[j * rowSize + i] = mrCube;
                }
            }
        }
    }

    private void InitComputeShaderData()
    {
        // Cube[] 배열 데이터 생성
        for (int i = 0; i < _cubeCount; i++)
        {
            _cubeDatas[i] = new Cube() { position = _cubeRenderers[i].transform.position };
        }

        // 컴퓨트 버퍼 객체 생성
        _cubeBuffer = new ComputeBuffer(_cubeCount, sizeof(float) * 7);
        _cubeBuffer.SetData(_cubeDatas);

        // 컴퓨트 쉐이더에 컴퓨트 버퍼 등록
        computeShader.SetBuffer(0, "cubeBuffer", _cubeBuffer);
    }
    #endregion
    /***********************************************************************
    *                               Update Methods
    ***********************************************************************/
    #region .
    private void UpdateCPU()
    {
        float t = Time.time * updateSpeed;
        float t2 = t * 0.5f;

        for (int j = 0; j < rowSize; j++)
        {
            for (int i = 0; i < rowSize; i++)
            {
                int index = j * rowSize + i;
                Transform tran = _cubeTransforms[index];
                Vector3 pos = tran.position;

                // Position
                float wave = (i + t) * waveFrequency;
                pos.y = Mathf.Sin(wave);
                tran.position = pos;

                // Color
                float k = Mathf.Sin((float)i / rowSize + t2) * 0.5f + 0.5f;
                _mpb.SetColor("_Color", Color.Lerp(Color.red, Color.blue, k));
                _cubeRenderers[index].SetPropertyBlock(_mpb);
            }
        }
    }

    private void DispatchComputeShader()
    {
        // 컴퓨트 쉐이더에 변수 값 등록
        computeShader.SetFloat("time", Time.time);
        computeShader.SetFloat("updateSpeed", updateSpeed);
        computeShader.SetFloat("rowSize", rowSize);
        computeShader.SetFloat("waveFrequency", waveFrequency);
        
        // 스레드 그룹 개수 계산
        computeShader.GetKernelThreadGroupSizes(0, out uint numX, out _, out _);
        int numThreadGroups = Mathf.CeilToInt((float)_cubeCount / numX);

        // 컴퓨트 쉐이더 실행
        computeShader.Dispatch(0, numThreadGroups, 1, 1);
    }

    private void GetDataFromComputeShader()
    {
        // 컴퓨트 버퍼로부터 데이터 읽어오기
        _cubeBuffer.GetData(_cubeDatas);

        // 읽어온 데이터(위치, 색상) 적용
        for (int i = 0; i < _cubeCount; i++)
        {
            _cubeTransforms[i].position = _cubeDatas[i].position;

            _mpb.SetColor("_Color", _cubeDatas[i].color);
            _cubeRenderers[i].SetPropertyBlock(_mpb);
        }
    }
    #endregion
}
```

</details>

<br>


# 추가 예제
---
- 컴퓨트 쉐이더를 적절하게 사용하는 예제(GPU Instancing)
  - <https://rito15.github.io/posts/unity-compute-buffer-gpu-instancing/>

<br>


# References
---
- <https://docs.unity3d.com/kr/current/Manual/class-ComputeShader.html>
- <https://docs.unity3d.com/kr/current/ScriptReference/ComputeShader.html>
- <https://docs.unity3d.com/kr/current/ScriptReference/ComputeBuffer.html>
- <https://docs.unity3d.com/ScriptReference/RenderTexture.html>
 
- <https://www.slideshare.net/QooJuice/compute-shader-206256248>
- <https://catlikecoding.com/unity/tutorials/basics/compute-shaders/>

- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221234371788>
- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221292611668>
- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221292620292>
- <https://m.blog.naver.com/jungwan82/221714956151>
