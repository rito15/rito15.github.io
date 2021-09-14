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
 - GPU를 CPU의 영역인 응용 프로그램 계산에 사용하는 **GPGPU**(General-Purpose computing on GPU)와는 개념이 유사하지만 다르다고 한다.
 - **GPGPU**를 사용하는 **CUDA**, **OpenCL**은 독립 API이고 **OpenGL**의 **Compute Shader**, **DirectX**의 **DirectCompute**는 그래픽스API에 종속되어 동작한다.
 - 동시에 수많은 대상(수십만, 수백만 단위 가능)에 대해 동일한 연산(함수)을 처리해야 할 때 사용한다.
 - **VFX Graph**도 컴퓨트 쉐이더를 연산에 사용한다고 한다.
 - 확장자는 `.compute`이다.
 
## **커널(Kernal)**
 - GPU에서 동작하는 함수를 의미한다.
 - 함수의 이름이 곧 커널의 이름이며, `#pragma kernel`에도 명시해 주어야 한다.

## **스레드 그룹(Thread Group)**
 - 하나의 스레드 그룹 당 `[numthread(x, y, z)]`로 지정된 개수만큼의 스레드를 실행한다.
 - 스레드 그룹의 개수는 컴퓨트 쉐이더 객체를 `.Dispatch(kernalIndex, X, Y, Z)`로 실행할 때 지정한다.
 - 개수는 3차원(`X, Y, Z`)으로 구성된다.

## **스레드(Thread)**
 - 커널(함수)을 실행하는 단위.
 - 하나의 스레드가 하나의 커널을 실행한다.
 - 개수는 3차원(`x, y, z`)으로 구성된다.
 - 커널 함수 선언부 상단에 `[numthreads(x, y, z)]`를 붙여 스레드의 개수를 3차원으로 지정한다.
 - `(x * y * z)`는 하나의 스레드 그룹에서 실행될 스레드의 총 개수이다.

## **스레드 개수의 차원 설정**
 - `1024 * 1 * 1`로 1차원으로 지정하는 경우도 있고, `32 * 32 * 1`처럼 2차원으로, 혹은 3차원으로 지정하는 경우도 있다.
 - 이는 계산할 데이터의 차원에 따라 결정된다.
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
 
 - 따라서 커널 상단에 `[numthread(8, 8, 1)]`로 지정하고,
 - 컴퓨트 쉐이더를 실행할 때 `Dispatch(index, 128, 96, 1)` 이렇게 호출한다.

## **참고사항**
 - 컴퓨트 쉐이더의 연산 결과를 렌더 텍스쳐에 받아 오려면 렌더 텍스쳐의 랜덤 액세스 기능을 활성화해야 한다.
 - `RenderTexture.enableRandomWrite = true`로 설정하면 된다.
 - 또한 렌더 텍스쳐의 생성자에 `RenderTextureReadWrite.Linear` 옵션을 5번째 매개변수로 전달해야 한다.
 - 필요한 연산 수보다 더 많은 스레드를 생성하면 불필요한 성능 낭비가 생기므로, 스레드 개수는 연산에 필요한 만큼 딱 맞춰 설정하는 것이 좋다.

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

# 예제
---
 - 화면에 스크린 UV 출력하기

<br>

## DrawScreenUV.compute

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

<br>

## ScreenUVRenderer.cs
 
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

<br>

## **실행 결과**

![image](https://user-images.githubusercontent.com/42164422/132733632-5ee83e86-c7d1-4483-81b0-db0904e843de.png)

<br>

# References
---
- <https://docs.unity3d.com/kr/current/Manual/class-ComputeShader.html>
- <https://docs.unity3d.com/kr/current/ScriptReference/ComputeShader.html>
- <https://docs.unity3d.com/kr/current/ScriptReference/ComputeBuffer.html>
- <https://docs.unity3d.com/ScriptReference/RenderTexture.html>
 
 - <https://www.slideshare.net/QooJuice/compute-shader-206256248>

- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221234371788>
- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221292611668>
- <https://blog.naver.com/PostView.naver?blogId=kimsung4752&logNo=221292620292>

- <https://catlikecoding.com/unity/tutorials/basics/compute-shaders/>
