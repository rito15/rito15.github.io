---
title: 유니티 - FixedUpdate()에서 이동, 회전 구현 시 버벅임 현상 해결하기
author: Rito15
date: 2021-11-22 00:23:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp]
math: true
mermaid: true
---

# Update()와 FixedUpdate()
---

## **Update()**

`Update()` 메소드는 프레임 당 한 번씩 호출된다.

그리고 이동, 회전 등을 구현할 경우 프레임 간의 호출 간격을 고려하고

단위 시간 당 일정한 수치로 기능을 구현하기 위해 `Time.deltaTime`을 사용한다.

<br>

## **FixedUpdate()**

리지드바디를 사용할 때, 즉 물리 엔진의 기능을 이용할 때 사용하는 메소드.

`FixedUpdate()` 메소드는 **Fixed Time Step** 주기(**기본 0.02초**)마다 한 번씩 호출되도록 보정된다.

그냥 '호출된다'가 아니고, '호출되도록 보정된다'.

왜냐하면, `FixedUpdate()`의 호출은 `Update()`를 호출하는 게임 루프와 별도의 루프, 혹은 멀티스레드에 의해 발생하지 않기 때문이다.

`Update()`를 호출하는 게임 루프에서 또다른 내부 물리 루프를 통해 `FixedUpdate()`를 호출한다.

다시 말해, `FixedUpdate()`의 호출 역시 각각의 프레임 내에서 이루어진다.

<br>

예를 들어 **Frame Rate = 50**일 경우, 즉 매 프레임이 **0.02초**마다 실행될 경우

매 프레임마다 `Update()`, `FixedUpdate()`는 한 번씩 호출될 것이다.

<br>

**Frame Rate = 25**일 경우, 즉 매 프레임이 **0.04초**마다 실행될 경우

`Update()`는 역시 매 프레임마다 호출되겠지만,

`FixedUpdate()`는 고정된 **Fixed Time Step** 주기에 맞출 수 있도록

매 프레임마다 두 번씩 호출될 것이다.

<br>

반면에 성능이 아주 좋아서 **Frame Rate = 250**쯤 된다면,

프레임은 **0.004초** 간격으로 실행된다.

그리고 `FixedUpdate()`는 **5프레임**마다 한 번씩 호출될 것이다.

즉, **5프레임**마다 **4프레임**은 `FixedUpdate()`가 호출되지 않는다.

<br>



# FixedUpdate()로 이동, 회전 시 버벅임 현상
---

위에서 서술했듯,

`FixedUpdate()`는 기본적으로 **0.02초**마다 실행된다.

**Frame Rate**로 따지자면 **50**에 해당한다.

따라서 현재 **Frame Rate**가 **50**보다 클 경우,

`FixedUpdate()`가 호출되지 않는 프레임들이 존재하기 때문에

분명 사용자 입력이 이루어지는데도 움직임이 업데이트되지 않는 프레임들이 존재하여

`FixedUpdate()`를 이용한 이동, 회전이 버벅이는 듯이 보일 수 있다.

![2021_1121_Fixed Update 01](https://user-images.githubusercontent.com/42164422/142766415-d77b57b8-3bc4-4934-9f44-96663103f325.gif)

<br>



# 버벅임 현상 해결 방법
---

`FixedUpdate()`의 이동, 회전에 의한 버벅임 현상은 어떻게 해결할 수 있을까?

**Frame Rate**와 **Fixed Time Step**을 고려하여,

`FixedUpdate()`가 프레임당 최소 한 번은 호출되도록 해주어야 한다.

다시 말해, `FixedUpdate()`가 호출되지 않는 프레임이 없어야 한다.

이를 위해 두 가지를 설정할 수 있다.

<br>

## **[1] Target Frame Rate를 지정한다**

스크립트에서 `Application.targetFrameRate` 값을 설정하여 최대 **Frame Rate** 제한을 지정할 수 있다.

**Fixed Time Step**이 기본 값(**0.02**)일 때, 초당 물리 업데이트 횟수는 **50**이다.

만약 **Fixed Time Step**을 그대로 유지하고 버벅임 현상을 없애려면,

`targetFrameRate` 값을 **50** 이하로 설정하여

프레임 당 `FixedUpdate()`가 최소 1번 이상 호출되도록 해주면 된다.

<br>

## **[2] Fixed Time Step을 조정한다**

**Frame Rate**에 맞추어 물리 업데이트 주기를 변경할 수도 있다.

`[Edit] - [Project Settings] - [Time]` 창을 연다.

**Fixed Time Step**은 기본적으로 **0.02**로 지정되어 있는데,

이 값을 **(1 / Frame Rate)**로 계산하여 넣어주면 된다.

예를 들어 **Frame Rate**가 **60**이면 **(1 / 60) = 0.016667**로 설정하면 된다.

<br>

보통 이렇게 `targetFrameRate` 값을 먼저 결정하고,

이에 맞추어 **Fixed Time Step** 값을 조정하는 것이 일반적이다.

<br>



# 결론
---

## **[1] Target Frame Rate 설정**

게임의 특징, 실행할 기기 환경 등에 따라 **Target Frame Rate**를 설정한다.

스크립트에서 `Application.targetFrameRate`를 통해 설정할 수 있으며

캐주얼, 아케이드 등 가벼운 게임은 **30**,

FPS, 액션 게임처럼 부드러운 화면 업데이트가 필요하면 **60**으로 설정하는 경우가 많다.

모바일 대상인 경우, 액션 게임이라도 최적화를 위해 **30**으로 설정할 수도 있다.

<br>

## **[2] 계산을 통해 Fixed Time Step 설정**

물리 엔진 기반으로 움직임들을 구현할 경우,

**Target Frame Rate**에 따라 알맞은 **Fixed Time Step** 값을 설정해준다.

프레임당 최소 한 번의 물리 업데이트가 발생하도록 하는 것이 목적이다.

<br>

### **계산 방법**
> Fixed Time Step = (1 / Target Frame Rate)

<br>

예를 들어,

**Target Frame Rate = 60**이면 **(1 / 60) = 0.016667**,

**Target Frame Rate = 30**이면 **(1 / 30) = 0.033333**으로 설정한다.

<br>


# 예시
---

## **공통**
- **Target Frame Rate = 120** <br>
  (**Delta Time = (1 / 120) = 0.008333**)

<br>

## **[1] Fixed Time Step = 0.02**
![2021_1121_Fixed Update 01](https://user-images.githubusercontent.com/42164422/142766415-d77b57b8-3bc4-4934-9f44-96663103f325.gif)

## **[2] Fixed Time Step = 0.008333**
![2021_1121_Fixed Update 02](https://user-images.githubusercontent.com/42164422/142766417-942e1984-6b78-455c-a015-539810da4c24.gif)

<br>

