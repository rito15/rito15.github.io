---
title: 유니티 - Quaternion
author: Rito15
date: 2021-10-24 16:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Quaternion
---

- 4개의 float로 이루어져 있다.

- 쿼터니언은 3차원 공간에서의 회전 정보를 가진다.
  - 예를 들어, `[X축 15도, Y축 30도, Z축 0도 회전]` 또는 `[벡터 (1, 2, 3)을 축으로 25도 회전]`과 같은 정보를 갖고 있다.

- 쿼터니언의 회전은 해당 쿼터니언 연산(곱셈)을 적용하는 순간의 로컬 공간을 기준으로 적용된다.

<br>


# 오일러 회전 적용 순서
---

- <https://docs.unity3d.com/Packages/com.unity.mathematics@0.0/api/Unity.Mathematics.math.RotationOrder.html>

위와 같은 유니티 문서들을 찾아봐도, 

```cs
internal class TransformRotationGUI
{
    // ...

    private RotationOrder m_OldRotationOrder = RotationOrder.OrderZXY;
```

이렇게 유니티 구현 코드를 열어봐도

회전 순서는 언제나 `ZXY`라고 나온다.

<br>

근데 쿼터니언 곱셈 연산을 통해 실제로 테스트 해보면

```cs
Quaternion qX30 = Quaternion.Euler(30f, 0f, 0f);
Quaternion qY45 = Quaternion.Euler(0f, 45f, 0f);
Quaternion qZ15 = Quaternion.Euler(0f, 0f, 15f);
Quaternion qX30Y45Z15 = Quaternion.Euler(30f, 45f, 15f);

// [1] Mul Order : ZXY
transform.rotation = qZ15 * qX30 * qY45;

// [2] Mul Order : YXZ
transform.rotation = qY45 * qX30 * qZ15;

// [3] Answer
transform.rotation = qX30Y45Z15;
```

`[3]`과 동일하게 적용되는 것은 `[1] ZXY`가 아니라 `[2] YXZ`이다.

곱셈을 한번에 하지 않고,

```cs
// [1] ZXY
transform.rotation = qZ15;
transform.rotation *= qX30;
transform.rotation *= qY45;

// [2] YXZ
transform.rotation = qY45;
transform.rotation *= qX30;
transform.rotation *= qZ15;
```

이렇게 차례로 적용해봐도

`ZXY`가 아니라 `YXZ` 순서가 맞다.

<br>

그러니까 유니티에서 `Rotation Order = ZXY`라고 하는 것은

아마도 회전행렬 곱셈 시 행렬 배치 순서가 아닌가 싶다.

회전행렬을 조립할 때

```
Matrix4x4 rotMatrix = mEulerZ * mEulerX * mEulerY;
```

이렇게 하면 회전이 `Y-X-Z` 순서로 적용되는데,

이 때의 행렬 배치 순서를 의미하는 것 같다.

<br>

결국, 유니티 엔진에서 오일러 회전이 적용되는 순서는 `Y-X-Z`이다.


<br>

# 생성
---

## **[1] 오일러 회전**

- x, y, z 축마다 회전 각도 설정

```cs
Quaternion.Euler(Vector3 eulerAngle);
```

<br>

## **[2] 로드리게스(축-각) 회전**

- 회전 기준 축, 회전 각도 설정

```cs
Quaternion.AngleAxis(float angle, Vector3 axis);
```

<br>

## **[3] 

<br>


# 연산
---

> q : 쿼터니언
> v : 벡터

<br>

## **[1] 쿼터니언 = q1 `*` q2**

- `lhs` 회전 우선 적용 후, 결과 공간의 표준 기저를 기준으로 `rhs`의 회전을 적용하는 회전 데이터

> 위와 같이 복잡하게 설명하는 이유는, 쿼터니언끼리의 곱셈은 교환 법칙이 성립하지 않으며
> 곱셈 연산 시 월드 또는 특정 공간을 기준으로 회전하는 것이 아니라
> 곱셈을 통해 회전할 때마다 회전의 기준이 되는 표준 기저가 변하기 때문이다.

<br>

## **[2] 벡터 = q `*` v**

- `rhs` 벡터에 월드 공간의 표준 기저를 기준으로 `lhs` 회전을 적용한다.

<br>

## **[3] q = q1 `*` q **

- 현재 

<br>


# Quaternion API
---




 메소드들 작성하고 동작 설명

LookRotation, Slerp 등등, ...


## **Quaternion.LookRotation()**
> param 0 : Vector3 forward <br>
> param 1 : Vector3 up

- 기존 공간의 +Z 기저가 `forward`를, +Y 기저가 `up`을 향하도록 회전시키는 쿼터니언을 정의한다.


<br>

# 트랜스폼의 rotation이 갖는 의미
---

## **Transform.rotation**

- 월드 공간의 표준 기저를 기준으로 해당 쿼터니언 값만큼 회전한 상태

<br>

## **Transform.localRotation**

- 로컬 공간의 표준 기저를 기준으로 해당 쿼터니언 값만큼 회전한 상태

<br>


# 활용(트랜스폼)
---

## **[1] 트랜스폼 로컬 회전**

```cs
Quaternion q = ...;
transform.rotation *= q;
```

<br>

## **[2] 트랜스폼 월드 회전**

```cs
Quaternion q = ...;
transform.rotation = q * transform.rotation;
```

<br>

## **[3] 대상 바라보기**

- 트랜스폼의 Forward 벡터가 대상을 바라보게 한다.

```cs
Vector3 targetPosition = ...;
Vector3 direction = targetPosition - transform.position;

transform.rotation = Quaternion.LookRotation(direction, Vector3.up);
```

<br>



# References
---
- <https://docs.unity3d.com/kr/2018.4/Manual/QuaternionAndEulerRotationsInUnity.html>


