---
title: 유니티 - FixedUpdate()와 Physics Loop에 대한 이해
author: Rito15
date: 2021-10-23 03:45:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp]
math: true
mermaid: true
---

# Update()와 Game Loop
---

유니티 엔진의 `Update()`는 매 프레임 호출되며,

이동, 회전, 입력, 실시간 계산 등 수많은 기능을 여기에 작성한다.

그렇다면 `Update()`의 정체는 무엇일까?

<br>

그래픽스 라이브러리를 통해 구현되는 게임은 기본적으로 **Game Loop(게임 루프)** 를 통해 프레임 기반 동작이 수행된다.

**DirectX**, **OpenGL**, **Vulkan**, ... 등 어떤 그래픽스 라이브러리를 사용하더라도

```cpp
/* Main Function */

// Game Loop
while(...)
{
    // User Inputs..
    // Game Logics..
    // Draw Calls..
    // ...
}
```

이렇게 메인 스레드에 무한 반복문을 통해 게임 루프를 작성하며,

이 게임 루프의 반복이 프레임의 진행을 의미한다.

즉, 게임 루프 내부를 한 번 실행하면 한 프레임이 지난 것이다.

<br>

그리고 `Update()`의 호출은 게임 루프의 1회 반복에 대응된다.

정확히는 게임 루프 내에서 매 반복마다 모든 `Update()`가 한 번씩 호출되는 것이다.

```cs
// Game Loop
while(...)
{
    // ...
    
    game->Update();
    
    // ...
}
```

<br>

그런데 유니티 엔진에서

>`MonoBehaviour.Update()`는 스크립트에 작성하기만 하면 알아서 동작하지 않나? <br>
>어디서 따로 호출해주지도 않는데?

이렇게 생각할 수 있지만,

<br>

유니티 같은 상용 엔진도 저 게임 루프가 엔진 코어 내에 숨겨져 있을 뿐이지,

근본적인 구조는 다르지 않다.

<br>

`Update()` 메소드가 존재하는 모든 `MonoBehaviour`를 찾아서

스크립팅 런타임이 내부적으로 저장해놓았다가

게임 루프에서 일괄적으로 순회하며 호출해주는 방식이다.

유니티 엔진은 프로그래머의 편의를 위해서 이런 방식을 채택했다고 한다.

```cs
// Unity Game Loop
while(...)
{
    // ...
    
    foreach(var m in monoBehavioursWhoHaveUpdateMethod)
    {
        m.Update();
    }
    
    // ...
}
```

<br>

그리고 `Update()` 내에서 단골로 호출되는 `Time.deltaTime`은

게임 루프의 이전 수행과 현재 수행 간의 시간 간격을 저장한 값이다.

이를 통해 비주기적으로 실행되는 게임 루프 반복 간의 시간 보정을 해줄 수 있게 된다.

<br>


# FixedUpdate()
---

매 프레임 동작하는 게임 로직은 `Update()`를 기반으로 작성되며, 게임 루프 내부에서 실행된다.

반면, **Unity Physics**에 의한 물리 연산은 게임 루프와는 다른 별개의 루프에서 실행되며

성능에 따라 들쑥날쑥 실행되는 `Update()`와 달리 `FixedUpdate()`는 완전히 일정한 주기로 실행되고,

이 주기는 기본적으로 `0.02`초이다.

<br>

...라고 오해하기 쉽다.

`FixedUpdate()`는 게임 루프와 완전히 별개로 여겨질 수 있다는 것이다.

엔진의 내부 핵심 코드를 덮어놓고, `MonoBehaviour`만 바라보고 있자면

사실 이렇게 생각하고 구현해도 결과적으로 별로 문제될 것은 없다.

<br>

하지만 언제나 근본적인 이해가 실력 향상에 도움이 되는 법이다.

<br>

`MonoBehaviour` 스크립트를 하나 만들고, 컴포넌트로 넣는다.

그리고 다음과 같이 작성해본다.

```cs
private void Update()
{
    Debug.Log($"Update [{Time.frameCount}] : {Time.realtimeSinceStartup}");
}
private void FixedUpdate()
{
    Debug.Log($"FixedUpdate [{Time.frameCount}] : {Time.realtimeSinceStartup}");
}
```

<br>

![image](https://user-images.githubusercontent.com/42164422/140308729-a347afda-e5dd-46dd-8801-df21fa5fc14b.png)

이렇게 `FixedUpdate()`가 호출되지 않고 `Update()`만 연달아 호출되는 경우가 있는가 하면,


![image](https://user-images.githubusercontent.com/42164422/140309024-d902ca99-206d-405a-b07d-c42185f48017.png)

`Update()`와 다음 `Update()` 사이에 `FixedUpdate()`가 여러 번 호출되는 경우도 있다.

<br>

두 메소드 호출의 주기가 다른 것을 감안하면 여기까지는 자연스러울 수 있으나,

자세히 보면 뭔가 좀 이상하다는 것을 느낄 수 있다.

`364`번째 프레임의 `Update()`와 `365`번째 프레임의 `Update()` 사이에,

`365`번째 프레임에서 `FixedUpdate()`가 **4번**이나 호출된 것이다.

심지어 `FixedUpdate()` 호출 시간 간격은

`Fixed Time Step`의 기본 값인 `0.02`초여야 할텐데, 그렇지도 않다.

<br>


<https://docs.unity3d.com/Manual/ExecutionOrder.html>

위 문서는 유니티의 내부 동작 구조를 보여준다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138499595-94035082-66ec-47a9-833c-3bbe5f06d29f.png)

빨간색으로 표시된 것이 매 프레임 실행되는 로직들, 즉 `Game Loop`의 매 순회를 의미한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138499788-344c6a22-a66e-4cbf-84d7-b2dcd5e2d44f.png)

그런데 위와 같이 노란색으로 표시된 루프가 하나 더 존재한다.

<br>

이는 `Physics Loop`라고 하며,

좌측 상단을 잘 살펴보면

```
The physics cycle may happen more than once per frame
if the fixed time step is less than the actual frame update time.
```

이라고 적혀 있는 것을 확인할 수 있다.

<br>

간단히 말해,

`Fixed Time Step` 값이 `deltaTime`보다 작으면

그만큼 `Physics Loop`가 여러 번 반복하여 실행된다는 것이다.

<br>

예를 들어 `Fixed Time Step`은 `0.02`이고,

이번 프레임의 `deltaTime`이 `0.1`이었다면

`0.1 / 0.02 = 5`회 만큼 `Physics Loop`가 실행될 것으로 예측할 수 있다.

반대로, `deltaTime`이 `0.005`처럼 너무 작았다면

이번 프레임에는 `Physics Loop`가 한 번도 실행되지 않을 수 있다.

<br>

`FixedUpdate()`는 `Physics Loop`의 초입에 실행되며,

결국 게임 루프와는 별개로 일정한 주기마다 호출되는 것이 아니라

게임 루프 내에서 중첩 루프를 통해 호출된다는 것을 알 수 있다.


<br>

# Physics Loop의 존재 이유
---

그렇다면 왜 물리 업데이트는 기본적으로 `0.02`초의 주기를 갖고,

이 주기에 따라 계산된 횟수로 **Physics Loop**가 실행되는 것일까?

물리 업데이트가 단순히 프레임 기반으로 실행되는, 반대의 상황을 가정해보면 쉽게 이해할 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138504990-85231aac-74ff-4e3b-a649-0fcf70f39abe.png)

`Sphere Collider`를 갖고 있는 강체가 `Box Collider`에 부딪힌다.

물리 업데이트는 `Update()`와 동일한 주기로 호출된다고 가정한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138505123-b79fb9d5-708d-4f63-ac8d-d32964a521d8.png)

이렇게 비주기적인 물리 시뮬레이션을 통해, 

`Box Collider`에 부딪혀 튕겨 나갈 것으로 예상해볼 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138505329-323abb43-00e5-434d-a214-c0dc5e778d74.png)

그런데 성능 저하로 인해 업데이트 주기가 너무 길어진다면?

위와 같이 `Box Collider`와의 충돌을 감지하지 못하고 관통해버릴 수 있다.

<br>

주기가 길어서 충돌 감지를 못하고 관통하는 것은 어쨌든 납득할 수 있다.

하지만 **Frame Rate** 차이로 인해 언제는 충돌하고, 언제는 관통하게 되는,

심지어 타겟 기기마다의 성능 격차로 인해 전혀 다른 결과를 얻을 수도 있는

예측 불가능한 물리 시뮬레이션은 사실상 신뢰성에 있어서 문제가 되는 것이다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138505920-db0732c4-6f64-4a0a-bfa8-99bb38122908.png)

따라서 `Fixed Time Step` 주기를 정의하고,

지난 프레임의 수행 시간(`deltaTime`)이 너무 오래 걸렸으면

`deltaTime`과 `Fixed Time Step`의 관계에 따라

그만큼 `Physics Loop`를 반복함으로써

일정한 주기로 물리 업데이트가 진행되는 것처럼 보정하는 방식을 채택하여,

물리 시뮬레이션에 있어서 신뢰성을 얻을 수 있게 된다.

<br>


# Physics Loop가 Game Loop에 포함되는 이유?
---

`Physics Loop`는 일정한 주기로 실행되어야 한다.

그렇다면 별도의 스레드를 통해 일정한 주기로 수행되는 루프를 만들어

여기서 물리 업데이트를 실행하면 될텐데

그러면 심지어 멀티스레딩을 통해 성능 향상도 있을텐데,

왜 굳이 메인 스레드의 게임 루프 내에서 실행하는 것일까?

<br>

무엇보다도 스레드 간의 데이터 동기화 문제가 가장 클 것이다.

<br>

애초에 메인 스레드에서는 물리 관련 데이터에 접근하지 못하게 하고,

`FixedUpdate()` 및 내부 물리 연산에서는 물리 처리에 관련 없는 데이터에 접근하지 못하도록

접근 영역을 완전히 분리할 수 있다면 이것이 최고의 방법일 수 있다.

<br>

하지만 이는 프로그래밍 난이도를 기하급수적으로 끌어올리는 결과가 될 수 있으므로

상용 엔진 입장에서 선택하기 힘든 방안인데다,

결국 물리 업데이트의 결과는 트랜스폼에 적용되어야 하므로

동기화 문제에서 결코 자유롭지 못하다.

<br>

그래서 메인 스레드와 물리 스레드의 공유 데이터를 모두 동기화(e.g., `lock`) 하자니,

게임 루프를 기반으로 동작하는 메인 스레드 특성 상

물리 스레드는 게임 루프의 동작에 종속되고,

반대로 게임 루프도 물리 스레드의 동작에 종속되는 최악의 경우가 발생할 수 있다.

<br>

이렇게 되느니 `Physics Loop`를 게임 루프 내에서 실행하고,

`deltaTime`과 `fixedDeltaTime`의 관계에 따라

실행 횟수를 보정해주는 방식이 결국 최선의 선택이었던 것으로 생각된다.

