---
title: 유니티 - 에디터 프로파일러
author: Rito15
date: 2021-02-04 17:50:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, profiling]
math: true
mermaid: true
---

# 목차
---

- [1. Unity Profiler](#unity-profiler)
- [2. CPU Usage](#cpu-usage)
  - [Timeline View](#timeline-view)
  - [Hierarchy View](#hierarchy-view)
  - [Show Related Objects](#show-related-objects)
  - [Call Stack](#call-stack)
  - [Show Calls](#show-calls)
  - [Deep Profile](#deep-profile)
- [3. GPU Usage](#gpu-usage)
- [4. Rendering](#rendering)
- [5. Memory](#memory)


<br>

# Unity Profiler
---
[Window] - [Analysis] - [Profiler]를 통해 프로파일러 윈도우를 열 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106927000-0a712380-6755-11eb-87bd-ba4d22bf0bbc.png)

CPU, GPU(Rendering), Memory 등등 다양한 지표들을 통해 현재 유니티 프로젝트에서 측정되는 성능을 확인할 수 있다.

선택된 탭의 구체적인 내용들은 윈도우 하단에 나타난다.

프로젝트 실행 후 그래프의 한 부분을 클릭할 경우, 유니티 프로젝트의 실행이 일시정지되며 해당 프레임의 정보를 확인할 수 있다.

## **Note**
- 좌측 상단의 [Profiler Modules]를 통해 측정할 지표들을 선택할 수 있으며, 필요하지 않은 지표들은 불필요하게 성능을 소모하므로 체크 해제하는 것이 좋다.

<br>

# CPU Usage
---
프로파일러에서 주로 확인하게 되는 부분으로, 해당 프레임에서 각각의 코드 수행에 걸린 시간과 비율 등을 확인할 수 있다.

그래프 중앙 하단에서 해당 프레임 동안 CPU, GPU 수행에 걸린 시간을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106927047-1957d600-6755-11eb-8035-14de7be3294a.png){: .normal}

- 만약 GPU가 표시되지 않는 경우, 좌측 상단의 [Profiler Modules]에서 GPU Usage를 체크하면 된다.

<br>
## Timeline View

![image](https://user-images.githubusercontent.com/42164422/106882158-c7498d00-6721-11eb-95e5-11b029ed4989.png)

스레드별로 각 메소드의 실행 시간을 타임라인 순서대로 확인할 수 있다.

<br>
## Hierarchy View

![image](https://user-images.githubusercontent.com/42164422/106927972-0d204880-6756-11eb-8f32-bd2812f68a0f.png){: .normal}

실행된 메소드들의 호출 스택을 하이라키 형태로 나타낸다.

|---|---|
|`Total`|해당 메소드와 하위 메소드들의 호출에 소요된 시간 비율의 총합|
|`Self`|해당 메소드의 호출에만 소요된 시간 비율|
|`Calls`|한 프레임 내에서 해당 메소드가 실행된 횟수|
|`GC Alloc`|해당 메소드 및 하위 메소드에서 생성된 메모리의 크기|
|`Time ms`|해당 메소드 및 하위 메소드를 실행하는 데 소요된 시간|
|`Self ms`|해당 메소드의 호출에만 소요된 시간|
|`Warning`|한 프레임 내에서 경고가 호출된 횟수|

<br>
## Show Related Objects

![image](https://user-images.githubusercontent.com/42164422/106928125-34771580-6756-11eb-9b05-876b0d8278cd.png)
{: .normal}

우측 하단에서 [Show Related Object]를 선택하고 하이라키의 메소드 중 하나를 선택할 경우, 연관된 오브젝트의 이름과 구체적인 정보를 확인할 수 있다.

연관된 오브젝트가 없는 경우 "N/A"로 표시된다.


<br>
## Call Stack

![image](https://user-images.githubusercontent.com/42164422/106928446-8881fa00-6756-11eb-9d67-984138170f56.png){: .normal}

상단에서 [Call Stacks]를 활성화하고 하이라키에서 GC.Alloc 항목을 선택, Show Related Object에서 하나의 항목을 선택할 경우 메모리 호출 스택을 확인할 수 있다.

<br>
## Show Calls

![image](https://user-images.githubusercontent.com/42164422/106928534-9fc0e780-6756-11eb-9ab9-0d4a7066244e.png){: .normal}

우측 하단에서 [Show Calls]를 선택하고 하이라키에서 하나의 항목을 선택할 경우 해당 메소드를 호출한 부분들을 모두 확인할 수 있다.

<br>
## Deep Profile

![image](https://user-images.githubusercontent.com/42164422/106928722-d1d24980-6756-11eb-85b3-a485b76a74d4.png){: .normal}

윈도우 상단의 [Deep Profile]을 활성화할 경우, 더 구체적인 메소드 호출 스택을 확인할 수 있다.

하지만 프로파일링에 성능을 더 많이 소모하므로 유의해야 한다.

<br>

# GPU Usage
---

![image](https://user-images.githubusercontent.com/42164422/106928934-18c03f00-6757-11eb-8869-4cae095f30a3.png){: .normal}

- CPU와 유사하게 메소드 호출 스택에 따른 성능을 파악할 수 있으며, 드로우콜 횟수를 확인할 수 있다.

<br>

# Rendering
---

![image](https://user-images.githubusercontent.com/42164422/106878840-c878bb00-671d-11eb-9a57-b1f0b2c43b44.png){: .normal}

- 드로우 콜, 패스 콜 등 렌더링 관련 정보를 확인할 수 있다.

<br>

# Memory
---

![image](https://user-images.githubusercontent.com/42164422/106881595-15aa5c00-6721-11eb-9cc0-20aba09631ea.png){: .normal}

- 항목별 메모리 사용량을 확인할 수 있다.

<br>

# References
---
- <https://docs.unity3d.com/kr/2018.4/Manual/ProfilerWindow.html>
