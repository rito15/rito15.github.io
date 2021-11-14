---
title: 파티클 시스템 기초 - 04 - 메인 모듈
author: Rito15
date: 2021-02-22 18:04:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [1. Duration, Looping, Prewarm](#duration-looping-prewarm)
- [2. Start Delay](#start-delay)
- [3. Start Lifetime](#start-lifetime)
- [4. Start Speed](#start-speed)
- [5. Start Size](#start-size)

- [6. Start Rotation](#start-rotation)
- [7. Flip Rotation](#flip-rotation)
- [8. Start Color](#start-color)
- [9. Gravity Modifier](#gravity-modifier)
- [10. Simulation Space](#simulation-space)

- [11. Simulation Speed](#simulation-speed)
- [12. Delta Time](#delta-time)
- [13. Scaling Mode](#scaling-mode)
- [14. Play On Awake](#play-on-awake)
- [15. Emitter Velocity](#emitter-velocity)

- [16. Max Particles](#max-particles)
- [17. Random Seed](#random-seed)
- [18. Stop Action](#stop-action)
- [19. Culling Mode](#culling-mode)
- [20. Ring Buffer Mode](#ring-buffer-mode)


<br>

# 파티클 기본 속성 (메인 모듈)
---

![image](https://user-images.githubusercontent.com/42164422/108674761-1f0d3400-7529-11eb-9b6a-6eca8ffdca04.png)

<br>

# Duration, Looping, Prewarm
---

## **Duration**
 - 파티클 시스템의 지속 시간을 초 단위로 지정한다.

 - Looping이 체크되지 않은 경우, 파티클 시스템이 시작된 순간부터 Duration에 지정된 시간이 지나면 자동으로 정지한다.

## **Looping**
 - Looping에 체크할 경우 파티클 시스템이 파괴되거나 수동으로 정지하기 전까지 Duration이 무한히 반복되며 파티클을 생성한다.

## **Prewarm**
 - Looping에 체크한 경우에만 Prewarm 속성을 사용할 수 있다.

 - Prewarm에 체크하면 파티클 시스템은 시작될 때 빈 공간에서부터 파티클을 하나씩 생성하는 것이 아니라 한 번의 루프(Duration 시간만큼)가 지났을 때를 가정하고, 그 지점에서부터 시작하게 된다.

 - 즉, Prewarm을 체크하면 시작부터 이미 생성된 많은 파티클을 가진 채로 시작하게 된다.

<br>
- 예시 1 : **Looping** [설정] vs [해제]

![2021_0222_Particle_Looping](https://user-images.githubusercontent.com/42164422/108683623-33572e00-7535-11eb-87fe-d91c346df823.gif){:.normal}

- 예시 2 : **Prewarm** [설정] vs [해제]

![2021_0222_Particle_Prewarm](https://user-images.githubusercontent.com/42164422/108683889-8cbf5d00-7535-11eb-9675-4b070fe5391c.gif){:.normal}

<br>

# Start Delay
---

- 파티클 시스템의 지연시간을 지정한다.

- 파티클 시스템이 재생될 때 **Start Delay**에 지정된 시간(초)만큼 기다렸다가 재생하게 된다.

- 예시 : **Start Delay** [0] vs [2]

![2021_0222_Particle_Delay_0_2](https://user-images.githubusercontent.com/42164422/108685223-3c48ff00-7537-11eb-9292-121ae87f49ea.gif){:.normal}

<br>

# Start Lifetime
---

- 각 파티클의 수명을 결정한다.

- 각 파티클은 생성된 이후부터 **Start Lifetime**에 지정된 시간(초)이 지나면 사라진다.

- 예시 : **Start Lifetime** [1] vs [5]

![2021_0222_Particle_Lifetime_1_5](https://user-images.githubusercontent.com/42164422/108685251-4539d080-7537-11eb-8421-628602e0d466.gif){:.normal}

<br>

# Start Speed
---

- 각 파티클의 속력을 결정한다.

- 이 때, 각 파티클이 향하는 방향은 **Shape** 속성에 지정한 모양에 따라 달라진다.

- 예시 : **Start Speed** [1] vs [3]

![2021_0222_Particle_Speed_1_3](https://user-images.githubusercontent.com/42164422/108685271-4b2fb180-7537-11eb-9a82-ddcd4be43c2e.gif){:.normal}

<br>

# Start Size
---

- 각 파티클의 크기를 결정한다.

- `3D Start Size`를 체크할 경우 X, Y, Z 크기를 개별적으로 지정할 수 있다.

- 예시 : **Start Size** [1] vs [2]

![2021_0222_Particle_Size_1_2](https://user-images.githubusercontent.com/42164422/108685285-51259280-7537-11eb-968e-0104e1f7e72e.gif){:.normal}

<br>

# Start Rotation
---

- 각 파티클의 시작 회전값을 결정한다.

- `3D Start Rotation`을 체크할 경우 X, Y, Z축 회전을 개별적으로 지정할 수 있다.

- `3D Start Rotation`을 체크하지 않을 경우 Z축 회전값으로 지정된다.

- 예시 : **Start Rotation** [0] vs [90]

![2021_0222_Particle_Rotation_0_90](https://user-images.githubusercontent.com/42164422/108685313-584ca080-7537-11eb-87fb-c94cb31b234c.gif){:.normal}

<br>

# Flip Rotation
---

- 파티클을 회전시키는 경우에만 해당된다.

  (**Start Rotation**이 아니라 **Rotation over Lifetime**, **Rotation by Speed**에 해당)

- 0 ~ 1 범위의 값으로 지정한다.

- 0일 경우, 모든 파티클이 기본 회전방향을 유지한다.

- 1일 경우, 모든 파티클이 기본 회전방향과 반대로 회전한다.

- 0 ~ 1 사잇값을 가질 경우, 지정한 비율만큼의 파티클들이 반대로 회전한다.

(0.5일 경우 절반은 기본 회전방향, 절반은 반대방향 회전)

<br>

- 예시 : **Flip Rotation** [0] vs [0.5]

![2021_0222_Particle_FlipRotation_0_05](https://user-images.githubusercontent.com/42164422/108685368-68fd1680-7537-11eb-88d9-8a8785db55b9.gif){:.normal}

<br>

# Start Color
---

- 각 파티클들의 색상 및 투명도를 지정한다.

- 예시 : **Start Color** [White] vs [Red]

![2021_0222_Particle_Color_White_Red](https://user-images.githubusercontent.com/42164422/108685403-731f1500-7537-11eb-901a-943eb86afbf7.gif){:.normal}

<br>

# Gravity Modifier
---

- 각 파티클에 적용될 중력의 강도를 지정한다.

- 중력의 기본 설정 방향은 -Y축 방향이므로, 중력을 지정하면 파티클들이 하단으로 낙하한다.

- 파티클의 속도와 중력은 모두 최종적으로 합산되어 결정된다.

- 예시 : **Gravity Modifier** [0] vs [1]

![2021_0222_Particle_Gravity_0_1](https://user-images.githubusercontent.com/42164422/108685438-7b775000-7537-11eb-9877-a6dfbdf57a23.gif){:.normal}

<br>

# Simulation Space
---

- 생성된 파티클의 기준 스페이스를 지정한다.

- `Local` : 파티클 시스템 게임오브젝트가 이동하면 파티클은 모두 게임오브젝트를 따라간다.

- `World` : 파티클 시스템 게임오브젝트가 이동해도 파티클은 영향받지 않고 개별적으로 이동한다.

- `Custom` : 기준이 될 대상을 직접 지정한다.

- 예시 : **Simulation Space** [Local] vs [World]

![2021_0222_Particle_ScalingMode](https://user-images.githubusercontent.com/42164422/108683128-8a103800-7534-11eb-8f98-ba234bbb958d.gif){:.normal}

<br>

# Simulation Speed
---

- 파티클 시스템의 재생 속도를 지정한다.

- 속도, 초당 생성 개수, ~over lifetime 등 모든 속도에 영향을 준다.

- 예시 : `Simulation Speed` [1] vs [4]

![2021_0222_Particle_SimulationSpeed_1_4](https://user-images.githubusercontent.com/42164422/108685757-e2950480-7537-11eb-91c0-feff56e15e4c.gif){:.normal}

<br>

# Delta Time
---

- 게임 내 시간에 영향 받을지 여부를 결정한다. (Time.timeScale)

- `Scaled` : 게임 내 시간의 영향을 받는다.

- `Unscaled` : 게임 내 시간의 영향을 받지 않아, 타임스케일 값을 변경해도 파티클 시스템은 동일한 속도로 재생된다.

<br>

# Scaling Mode
---

- 파티클의 크기가 트랜스폼(Transform) 스케일의 영향을 받을지 여부를 결정한다.

- `Local` : 해당 파티클 시스템이 위치한 게임오브젝트의 트랜스폼 스케일에만 영향을 받는다.

- `Hierarchy` : 해당 파티클 시스템이 위치한 게임오브젝트, 부모, 부모, .... 계층 관계를 통해 곱해진 최종 스케일의 영향을 받는다.

- `Shape` : [Shape] 탭에서 설정한 스케일에만 영향을 받는다.

<br>

# Play On Awake
---

- 게임 시작 시 또는 파티클 시스템 게임오브젝트 비활성화 -> 활성화 시 자동으로 파티클 시스템을 재생할지 여부를 결정한다.

- 체크 해제할 경우, 스크립트를 통해 직접 시작시키는 경우에만 재생된다.

<br>

# Emitter Velocity
---

- 파티클 시스템이 이동할 경우 속도 계산을 트랜스폼 기반으로 할지, 리지드바디(물리) 기반으로 할지 결정한다.

<br>

# Max Particles
---

- 파티클 시스템 내에서 동시에 존재할 수 있는 파티클의 개수를 지정한다.

- 현재 파티클 개수가 **Max Particles**에 지정한 값에 도달할 경우, 더이상 생성되지 않는다.

- 예시 : **Max Particles** [4] vs [1000]

![2021_0222_Particle_MaxParticles_4_1000](https://user-images.githubusercontent.com/42164422/108687073-9ba80e80-7539-11eb-8a21-95a4f2354d5a.gif){:.normal}

<br>

# Random Seed
---

- 파티클 시스템이 진행되는 형태를 지정한다.

- `Auto Random Seed`를 체크할 경우, 파티클 시스템을 재생할 때마다 서로 다른 형태로 진행된다.

- `Auto Random Seed`를 체크 해제하고 Random Seed 값을 직접 지정할 경우, 같은 시드값을 가지는 파티클 시스템은 서로 같은 형태를 띠며 진행된다.

<br>

- 예시 1 : **Auto Random Seed** 체크

![2021_0222_Particle_AutoRandomSeed](https://user-images.githubusercontent.com/42164422/108687567-37397f00-753a-11eb-8d48-5f1cf1922a8e.gif){:.normal}

- 예시 2 : **Auto Random Seed** 체크 해제, 동일한 **Random Seed** 값 설정

![2021_0222_Particle_RandomSeed_0](https://user-images.githubusercontent.com/42164422/108687577-399bd900-753a-11eb-96fe-8664b9b514f7.gif){:.normal}

<br>

# Stop Action
---

- 파티클 시스템이 중단되는 순간의 동작을 결정한다.

- `Disable` : 게임 오브젝트가 비활성화된다.

- `Destroy` : 게임 오브젝트가 파괴된다.

- `Callback` : 해당 게임오브젝트에 존재하는 MonoBehaviour의 OnParticleSystemStopped() 메소드를 호출한다.

<br>

# Culling Mode
---

- 파티클 시스템이 화면에서 벗어날 때 동작을 결정한다.

- `Pause and Catch-up` : 화면을 벗어나는 순간에는 일시정지하며, 다시 복귀할 경우 무정지 상태의 진행도를 예측하여 해당 진행도로 이어 재생한다.

- `Pause` : 화면에서 벗어나면 재생이 정지되며, 다시 복귀할 경우 정지된 곳에서부터 이어 재생한다.

- `Always Simulate` : 화면에서 벗어나도 정지되지 않고 그대로 재생한다. 성능을 가장 많이 소모하며, 단발성 파티클 시스템에 권장된다.

- `Automatic` (권장) : Looping일 때는 Pause, Looping이 아닐 떄는 Always Simulate를 사용한다.

<br>

# Ring Buffer Mode
---

- 파티클의 개수가 Max Particles에 도달했을 때 재활용하는 방식을 결정한다.

- `Disabled` : Ring Buffer Mode를 비활성화하여, 수명을 다한 파티클을 제거한다. 메모리를 가장 아낄 수 있다.

- `Pause Until Replaced` : 수명을 다한 파티클을 일시정지 상태로 보존하다가 Max Particles에 도달 시 재활용한다.

- `Loop Until Replaced` : 수명을 다한 파티클을 바로 새로 생성되는 파티클에 재활용시킨다.

<br>


# References
---
- <https://docs.unity3d.com/kr/2019.3/Manual/PartSysMainModule.html>