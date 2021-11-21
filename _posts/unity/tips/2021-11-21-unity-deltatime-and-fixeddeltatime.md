---
title: 유니티 - Time.deltaTime과 Time.fixedDeltaTime의 올바른 이해
author: Rito15
date: 2021-11-21 23:45:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp]
math: true
mermaid: true
---

# deltaTime과 fixedDeltaTime
---

## **deltaTime**

`Time.deltaTime`을 통해 참조할 수 있다.

이전 프레임의 발생 시각과 현재 프레임의 발생 시각 사이의 시간 간격,

즉 이전 프레임의 수행에 걸린 시간을 의미한다.

`Update()` 내에서 시간의 진행에 따른 일정한 기능을 구현하기 위해 `Time.deltaTime`을 이용해 보정한다.

<br>

## **fixedDeltaTime**

`Time.fixedDeltaTime`을 통해 참조할 수 있다.

기본적으로 물리 업데이트 발생 주기, 즉 **Fixed Time Step** 값을 의미한다.

마찬가지로 `FixedUpdate()` 내에서 `Time.fixedDeltaTime`을 이용해 보정한다.

<br>



# Frame Rate
---

'프레임률'이라고도 부르며, 초당 프레임 진행 횟수를 의미한다.

흔히 **FPS(Frame Per Second)**라고도 한다.

`Application.targetFrameRate`를 통해 최대 프레임률을 제한할 수 있으며,

예를 들어 **60**으로 설정할 경우 **Frame Rate**는 **60**을 넘지 못하게 된다.

캐주얼 게임은 **30**, 액션 게임은 **60**으로 설정하는 경우가 많다.

<br>



# 참고 : FixedUpdate()와 물리 루프에 대한 이해
---

- [Post Link](../unity-fixed-update-and-physics-loop/)

<br>



# 잘못된 deltaTime의 사용
---

`FixedUpdate()`에서 `Time.fixedDeltaTime`이 아닌 `Time.deltaTime`을 사용하는 예제를 본 적이 있다.

본 적이 있는 정도가 아니고, 많이 봤다.

`FixedUpdate()`에서 `Time.deltaTime`을 사용하면 왜 문제가 될까?

<br>

실제 **FrameRate**에 관계 없이 단위 시간당 `FixedUpdate()`의 호출 횟수는 동일하다.

**Fixed Time Step = 0.02**일 경우, `FixedUpdate()`는 항상 평균적으로 1초에 **50번씩** 호출되도록 물리 루프에 의해 보정된다.

단적으로, **FrameRate**가 각각 **50**, **2**인 환경을 생각해보자.

<br>

**FrameRate = 50**인 환경에서는 `deltaTime`의 값이 평균적으로 **0.02**가 된다.

마찬가지로 `FixedUpdate()` 호출마다 `deltaTime`만큼 이동한다면

1초 동안 `0.02 * 50 = 1`, 총 **1**만큼 이동한다.

`fixedDeltaTime`만큼 이동한다면

마찬가지로 1초 동안 `0.02 * 50 = 1`, 총 **1**만큼 이동한다.

`deltaTime`과 `fixedDeltaTime`이 이렇게 일치하는 경우에는 문제가 없어 보인다.

<br>

**FrameRate = 2**인 환경에서는 `deltaTime`의 값이 평균적으로 **0.5**가 된다.

그리고 1초에 `FixedUpdate()`가 50번 실행되어야 하므로

프레임당 25번씩의 `FixedUpdate()`호출이 발생한다.

만약 `FixedUpdate()` 호출마다 `deltaTime`만큼 이동한다면

1초 동안 `0.5 * 50 = 25`, 총 **25**만큼 이동한다.

반면 `fixedDeltaTime`만큼 이동한다면

1초 동안 `0.02 * 50 = 1`, 총 **1**만큼 이동한다.

<br>

`FixedUpdate()` 내에서 `fixedDeltaTime`이 아니라 `deltaTime`을 사용해 보정하려 할 경우, 이렇게 환경에 따른 차이가 발생한다.

단위 시간당 `FixedUpdate()`의 호출 횟수는 일정하도록 보정되는데,

`deltaTime`의 값은 **Frame Rate**에 따라 천차만별로 달라질 수 있으므로

`FixedUpdate()`에서 `deltaTime`을 통해 보정하면 '보정'의 의미가 퇴색된다.

<br>

`deltaTime`과 `fixedDeltaTime`이 괜히 따로 존재하는 것이 아니다.

따라서 `FixedUpdate()` 내에서 `deltaTime`을 사용하는 예제는 모조리 틀린 예제다.

<br>



# 결론
---

`Update()`에서는 `Time.deltaTime`을 통해 시간에 따른 일정한 동작을 할 수 있도록 보정한다.

마찬가지로 `FixedUpdate()`에서는 `Time.fixedDeltaTime`을 통해 보정하면 된다.

만약 완전히 이해하지 못했더라도, 법칙처럼 외우면 된다.


