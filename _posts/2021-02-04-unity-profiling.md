---
title: Unity Profiling
author: Rito15
date: 2021-02-04 19:30:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, profiling, optimization]
math: true
mermaid: true
---

# Note
---
- [x] 프로파일링은 1차적으로 에디터에서 수행하지만, 타겟 디바이스에서 실제로 실행하며 진행하는 프로파일링이 가장 중요하다.
- [x] [Edit - Project Settings - Quliaty - Other]에서 `VSync`가 설정되어 있는지 확인한다.
- [x] `Application.targetFrameRate`가 설정되어 있는지 확인한다(미설정 시 -1)
- [x] 병목을 확인할 때 CPU 바운드인지 GPU 바운드인지 꼭 짚고 시작한다.
- [x] 모바일 기기라면 프로파일링 순간이 쓰로틀링 상황인지 확인해야 한다.

<br>
# Tools
---

## 1. Unity Editor
- Unity Profiler
  - [Window - Analysis - Profiler (Ctrl+7)]
  - <https://docs.unity3d.com/kr/2018.4/Manual/ProfilerWindow.html>

- Profile Analyzer
  - Package Manager - Prifile Analyzer
  - <https://unity.com/kr/how-to/optimize-your-game-profile-analyzer>

- Memory Profiler
  - Package Manager - Memory Profiler [Preview]
  - <https://bitbucket.org/Unity-Technologies/memoryprofiler/src/default/>

## 2. Intel CPU/GPU 사용
- VTune
  - <https://software.intel.com/content/www/us/en/develop/tools/vtune-profiler.html>

- GPA
  - <https://software.intel.com/content/www/us/en/develop/tools/graphics-performance-analyzers.html>

## 3. Android
- Snapdragon Profiler
  - <https://developer.qualcomm.com/software/snapdragon-profiler>

## 4. iOS
- XCode Frame Debugger
  - <https://developer.apple.com/documentation/metal/frame_capture_debugging_tools>

<br>

# Unity Profiler
---

# **Custom Profiler Tags**

```cs
// using UnityEngine.Profiling;

private void SomeMethod()
{
    Profiler.BeginSample("Sample Name");

    // Codes ...

    Profiler.EndSample();
}
```

- 이렇게 래핑하면 저 사이에 있는 부분을 프로파일러에서 묶어 보여준다.
- 지정한 이름으로 확인할 수 있으므로 프로파일링 하기에 매우 편해진다.

<br>

# **CPU & GPU Boundary**

![image](https://user-images.githubusercontent.com/42164422/106927047-1957d600-6755-11eb-8035-14de7be3294a.png){: .normal}

- 프로파일러의 이 부분을 확인하면 CPU, GPU 수행에 걸린 시간을 통해 CPU와 GPU 중 어느 부분이 더 병목인지 파악할 수 있다.

<br>

# **CPU Boundary**

## GC.Alloc, GC.Collect
- 대표적인 CPU 바운드로, 힙의 할당과 가비지 수거를 의미한다.
- Alloc 자체는 직접적인 성능 저하를 유발하지 않지만, 결국 Collect의 대상이 되므로 줄이는 것이 좋다.

## Draw Call, Set Pass Call
- GPU 바운드로 착각할 수 있지만, CPU가 GPU에게 전달하는 CPU 바운드이다.
- Batch : DP Call 상태 변경을 합친 넓은 의미의 드로우 콜
- SetPass Call : 쉐이더로 인한 렌더링 패스의 횟수를 의미하며 쉐이더 및 쉐이더 파라미터들의 변경이 일어날 때마다 발생한다.

## Method Calls
- Marker들을 통해 병목지점을 확인할 수 있으며, 구체적으로 파악하고 싶은 경우 Deep Profile 또는 Custom Profiler Tag를 이용하면 된다.

<br>
## **Script update markers**

|---|---|
|`Update.ScriptRunBehaviourUpdate`|MonoBehaviour 내부의 Update() 호출 및 코루틴 yield|
|`BehaviourUpdate`|Update() 호출|
|`CoroutinesDelayedCalls`|코루틴 yield|
|`ScriptRunBehaviourLateUpdate`|LateUpdate() 호출|
|`FixedBehaviourUpdate`|FixedUpdate() 호출|

<br>

# **GPU Boundary**

## Graphics.Blit, Device.Present, Gfx.WaitForPresent
- 프로파일러에서 확인할 수 있는 대표적인 GPU 병목.
- CPU가 GPU에게 일을 시키고 CPU는 한가한데 GPU가 열심히 일하는 상태이다.

![image](https://user-images.githubusercontent.com/42164422/106918827-e873a300-674c-11eb-9c70-41b58cb1a213.png){: .normal}

- 이를 해결하려면 GPU 관련 요소들을 확인해야 한다.
  - 필레이트(쉐이더 최적화)
  - 메모리 대역폭(텍스쳐 최적화)
  - 포스트 프로세싱
  - 버텍스(LOD Model 활용)

<br>

## 필레이트(Fill rate)
- `화면의 픽셀 수` X `프래그먼트 쉐이더 복잡도` X `오버드로우`
- 오버드로우(Overdraw) : 투명 오브젝트의 픽셀을 여러 번 그리는 현상
- 필레이트가 문제인지 알기 위해서는 간단히 해상도 또는 렌더 스케일(Render Scale)을 줄였을 때 성능이 많이 향상되는지 확인하면 된다.
- URP에서는 파이프라인 애셋에서 간단히 [Quality - Render Scale]을 조절하면 된다.
- 이를 해결하려면 쉐이더를 최적화 해야 한다.

## 메모리 대역폭(Memory Bandwidth)
- 메모리 대역폭 : GPU가 전용 메모리에서 읽고 쓸 수 있는 속도
- 메모리 대역폭이 문제인지 알아보려면, 텍스쳐 품질을 줄였을 때 성능이 많이 향상되는지 확인하면 된다.
- 이를 해결하려면 텍스쳐를 압축하거나 밉맵을 사용하여 멀리 떨어진 경우 작은 밉맵을 적용해야 한다.

<br>
## **Rendering and VSync markers**

- CPU가 GPU를 기다리는 시간과 GPU의 소요시간을 포함하는 경우로, 모두 GPU 바운드에 해당한다.
  - `WaitForTargetFPS`
  - `Gfx.ProcessCommands`
  - `Gfx.WaitForCommands`
  - `Gfx.PresentFrame`
  - `Gfx.WaitForPresentOnGfxThread`
  - `Gfx.WaitForRenderThread`

<br>

# Memory Profiler
---
- 유니티 패키지 매니저에서 Preview 버전을 받을 수 있다.
- 시각적으로 메모리 사용률을 파악할 수 있으며, 각각의 사각형을 클릭할 경우 더 구체적인 내용을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106920799-c549f300-674e-11eb-8009-f2c6b71a598b.png)

<br>

# References
---
- <https://www.youtube.com/watch?v=4kVffWfmJ60&ab_channel=UnityKorea>
- <https://blogs.unity3d.com/kr/2019/11/14/tales-from-the-optimization-trenches/>
- <https://coderzero.tistory.com/entry/유니티-최적화-유니티-최적화에-대한-이해>
- <https://docs.unity3d.com/Manual/profiler-markers.html>
- <https://learn.unity.com/tutorial/fixing-performance-problems>
