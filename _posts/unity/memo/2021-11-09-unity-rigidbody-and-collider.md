---
title: 유니티 - 리지드바디와 콜라이더 간단 정리
author: Rito15
date: 2021-11-09 14:50:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 리지드바디(Rigidbody)
---

<details>
<summary markdown="span">
Unity Docs
</summary>

- <https://docs.unity3d.com/kr/2019.4/Manual/class-Rigidbody.html>

</details>

<br>


'강체'로 번역할 수 있다.

유니티 엔진에서 제공하는 기본 컴포넌트이다.

리지드바디가 존재하는 게임 오브젝트는 물리 엔진의 영향을 받는다.

현실감 있는 물리 시뮬레이션이 가능해지며,

**힘(Force)**과 **속도(Velocity)**의 영향을 받는다.

**3D**에서는 `Rigidbody`, **2D**에서는 `Rigidbody2D` 컴포넌트를 사용한다.

프로젝트 종류에 따라 잘 구분해서 사용해야 한다.

<br>



# 콜라이더(Collider)
---

<details>
<summary markdown="span">
Unity Docs
</summary>

- <https://docs.unity3d.com/kr/2019.4/Manual/Physics3DReference.html>

</details>

<br>


'충돌체'로 번역할 수 있다.

유니티 엔진에서 기본적으로 제공하는 콜라이더는

**박스(Box)**, **구(Sphere)**, **캡슐(Capsule)**, **메시(Mesh)** 등이 있다.

콜라이더마다 고유의 모양과 영역이 있으며, 서로의 영역이 겹칠 경우 충돌이 발생한다.

<br>

`Is Trigger` 설정에 체크하지 않을 경우, 충돌 시 접촉에 의한 물리 시뮬레이션이 발생하며

`Is Trigger` 설정에 체크할 경우, 충돌 시 부딪히지 않고 '겹침 상태'만 검사하게 된다.

<br>

**2D**에서는 `BoxCollider2D`처럼 이름 뒤에 `2D`가 붙는 컴포넌트를 사용해야 한다.

<br>



# 정적 콜라이더와 동적 콜라이더
---

리지드바디를 갖고 있지 않는 게임 오브젝트의 콜라이더를 **정적 콜라이더(Static Collider)**,

리지드바디를 갖고 있는 게임 오브젝트의 콜라이더를 **동적 콜라이더(Dynamic Collider)**라고 지칭한다.

<br>

정적 콜라이더는 게임 내에서 위치, 회전을 변경시키면 안된다.

물리 시뮬레이션에 성능, 정확도 면에서 악영향을 줄 수 있다.

동적 콜라이더는 자유롭게 위치, 회전을 변경해도 된다.

대신 트랜스폼을 직접 조작하면 안되고, 리지드바디를 통해 변경해야 한다.

<br>



# 충돌(Collision)
---

<details>
<summary markdown="span">
Unity Docs
</summary>

- [OnCollisionEnter](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionEnter.html)
- [OnCollisionStay](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionStay.html)
- [OnCollisionExit](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionExit.html)

- [OnCollisionEnter2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionEnter2D.html)
- [OnCollisionStay2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionStay2D.html)
- [OnCollisionExit2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnCollisionExit2D.html)

</details>

<br>


콜라이더 컴포넌트를 가진 두 게임오브젝트가 부딪힐 경우 발생한다.

두 게임 오브젝트 중 적어도 하나는 반드시 리지드바디를 갖고 있어야 하고,

두 콜라이더는 모두 `Is Trigger`가 체크되지 않아야 한다.

<br>

동적 콜라이더는 충돌 발생 시 부딪혀 튕겨나가게 된다.

<br>

리지드바디를 가진 게임 오브젝트에 `MonoBehaviour`를 상속받는 클래스를 만들어서 컴포넌트로 넣고,

해당 클래스 내에 `void OnCollisionEnter(Collision)` 메소드를 작성하면

충돌이 발생하는 순간 `OnCollisionEnter(Collision)` 메소드가 호출된다.

마찬가지로 충돌이 유지되는 동안에는 `OnCollisionStay(Collision)`,

충돌이 끝나는 순간에는 `OnCollisionExit(Collision)` 메소드가 호출된다.

<br>

**2D**의 경우, `OnCollisionEnter2D(Collision2D)`처럼

이름 뒤에 `2D`가 붙은 메소드를 작성해야만 한다.

<br>



# 트리거(Trigger) 충돌
---

<details>
<summary markdown="span">
Unity Docs
</summary>

- [OnTriggerEnter](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerEnter.html)
- [OnTriggerStay](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerStay.html)
- [OnTriggerExit](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerExit.html)

- [OnTriggerEnter2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerEnter2D.html)
- [OnTriggerStay2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerStay2D.html)
- [OnTriggerExit2D](https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnTriggerExit2D.html)

</details>

<br>


두 게임 오브젝트가 모두 콜라이더 컴포넌트를 갖고 있고

두 콜라이더 중 하나 이상의 콜라이더에 `Is Trigger`가 체크되어 있으며

두 게임 오브젝트 중 하나 이상의 게임 오브젝트에 리지드바디 컴포넌트가 존재할 경우 발생한다.

<br>

트리거 충돌이 발생해도 게임오브젝트는 튕겨나가지 않고, 그저 관통한다.

<br>

트리거가 아닌 충돌과 마찬가지로,

트리거 충돌 발생 시 리지드바디를 가진 게임오브젝트에 메시지가 전달된다.

충돌 시작 시 `OnTriggerEnter(Collider)`,

충돌이 유지되는 동안 `OnTriggerStay(Collider)`,

충돌 종료 시 `OnTriggerExit(Collider)` 메소드가 호출된다.

<br>

`MonoBehaviour`를 상속받는 클래스에 해당 메소드들을 작성하여

리지드바디를 가진 게임오브젝트에 컴포넌트로 넣어주면

트리거 충돌 발생 시 각각의 충돌 단계에 해당하는 메소드가 호출된다.

<br>

**2D**의 경우, `OnTriggerEnter2D(Collider2D)`처럼

이름 뒤에 `2D`가 붙은 메소드를 작성해야만 한다.

<br>



# 트랜스폼과 리지드바디
---

트랜스폼이 존재하는 기본적인 월드를 **게임 월드(Game World)**라고 할 때,

물리 엔진에 의해 리지드바디가 제어되는 월드를 **물리 월드(Physics World)**라고 할 수 있다.

리지드바디가 존재하지 않는 게임 오브젝트의 트랜스폼은 게임 월드에만 존재하고,

리지드바디가 존재하는 게임 오브젝트의 트랜스폼은 게임 월드, 물리 월드 양측에 존재한다.

<br>

쉽게 말해,

물리 월드의 트랜스폼은 리지드바디의 내부에 감춰진 트랜스폼이라고 이해하면 된다.

`Rigidbody.position`, `Rigidbody.rotation`을 통해 참조할 수 있다.

<br>

리지드바디를 가진 게임 오브젝트의 경우,

게임 월드의 트랜스폼은 물리 월드의 트랜스폼에 영향을 받는다.

반대로 물리 월드의 트랜스폼이 게임 월드의 트랜스폼에 영향을 받기도 하지만,

통제의 우선권은 물리 월드에 있다.

<br>

따라서 리지드바디가 존재하는 게임 오브젝트는 트랜스폼을 직접 조작하면 안되고

반드시 리지드바디를 조작하여 이동, 회전시켜야 한다.

<br>

그리고 물리 엔진의 갱신은 `FixedUpdate()`가 끝날 때마다 이루어진다.

따라서 리지드바디를 가진 게임 오브젝트는 `Update()`가 아니라

`FixedUpdate()`를 통해 조작해야만 한다.

<br>



# 키네마틱(Kinematic) 리지드바디
---

리지드바디에는 `Is Kinematic` 설정이 있다.

키네마틱으로 설정될 경우,

해당 게임오브젝트는 리지드바디가 존재함에도 불구하고 물리 시뮬레이션이 발생하지 않는다.

다시 말해, 다른 리지드바디에 부딪혀도 절대 튕겨나가지 않는다.

그리고 물리 엔진의 영향을 아예 받지 않아서,

리지드바디를 통해 힘을 줘도(`AddForce()`) 움직이지 않는다.

하지만 콜라이더를 갖고 있다면 다른 동적 콜라이더에는 충돌을 발생시킨다.

<br>

## **키네마틱 리지드바디 특징**
- 리지드바디의 힘, 중력, 속도 등의 영향을 받지 않는다.
- 리지드바디의 `position`, `rotation`을 조작하여 이동, 회전할 수 있다.
- 트랜스폼을 통해 직접 `position`, `rotation`을 조작해도 된다.

- 다른 정적 콜라이더와 부딪힐 때 `트리거 충돌` 메시지를 수신한다.
- 다른 동적 콜라이더와 부딪힐 때 `충돌`, `트리거 충돌` 메시지를 수신한다.
- 다른 동적 콜라이더와 부딪힐 때, 해당 동적 콜라이더 입장에서는 정적 콜라이더로 취급된다.

<br>

## **키네마틱 리지드바디의 사용처**

키네마틱 리지드바디는 '움직여도 되는 정적 콜라이더'라고 생각하면 된다.

다른 물체로부터 물리적으로 영향을 받을 필요는 없지만,

반대로 플레이어 캐릭터와 같은 강체에 물리적으로 영향을 줄 수 있는 환경 요소에 사용할 수 있다.

예를 들면 여닫이문, 움직이는 발판 등이 있다.

<br>


# References
---
- <https://docs.unity3d.com/kr/2019.3/Manual/CollidersOverview.html>
- <https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.html>