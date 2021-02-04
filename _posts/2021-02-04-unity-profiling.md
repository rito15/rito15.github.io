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
- [x] [Edit - Project Settings - Quliaty - Other]에서 VSync가 설정되어 있는지 확인한다.
- [x] `Application.targetFrameRate`가 설정되어 있는지 확인한다(미설정 시 -1)
- [x] 병목을 확인할 때 CPU 바운드인지 GPU 바운드인지 꼭 짚고 시작한다.

<br>
# Tools
---

## 1. Unity Editor
- Unity Profiler
  - <https://docs.unity3d.com/kr/2018.4/Manual/ProfilerWindow.html>

- Profile Analyzer
  - Package Manager - Prifile Analyzer
  - <https://unity.com/kr/how-to/optimize-your-game-profile-analyzer>

- Memory Profiler
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

<br>
# References
---
- <https://www.youtube.com/watch?v=4kVffWfmJ60&ab_channel=UnityKorea>
- <https://blogs.unity3d.com/kr/2019/11/14/tales-from-the-optimization-trenches/>
- <https://coderzero.tistory.com/entry/유니티-최적화-유니티-최적화에-대한-이해>
