---
title: 유니티 - Transform의 공간 변환 메소드 간단 메모
author: Rito15
date: 2021-11-13 00:02:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# 1. 로컬-월드 변환
---

## **[1] TransformPoint()**

- `위치`, `회전`, `크기` 변환을 적용한다.

- 방향 벡터가 아니라, 위치 벡터를 월드 위치로 변환할 때 사용한다.

- 메시의 로컬 정점 좌표로부터 월드 정점 좌표를 구할 때처럼, <br>
  오브젝트에 완전히 종속적인 위치 벡터를 변환할 때 사용된다.

- C# 스크립트에서는 딱히 자주 쓰이지 않는다.

<br>


## **[2] TransformVector()**

- `회전`, `크기` 변환을 적용한다.

- 메시의 노멀 벡터처럼 오브젝트에 종속적인 방향 벡터를 월드로 변환할 때 사용된다.

- 이것도 C# 스크립트에서 딱히 쓸 일은 없어 보인다.

- 혹시나 방향 벡터를 변환할 때 `TransformDirection()`과 이 메소드를 혼동하여 쓰게 될 경우, 의도치 않은 값을 얻을 수 있으니 주의해야 한다.

<br>


## **[3] TransformDirection()**

- `회전` 변환만 적용한다.

- 로컬 공간의 방향 벡터를 트랜스폼의 월드 공간 방향 벡터로 바꿀 때 사용된다.

- `Transform`의 변환 메소드 중에서는 가장 자주 쓰이는 편이다.

- `transform.TransformDirection(vector)`는 <br> `transform.rotation * vector`와 같다.

<br>

- 예시 : 키보드 입력에 따른 이동 방향 벡터를 로컬 공간에서 조립하여, <br>
  캐릭터의 현재 회전에 맞게 월드 벡터로 변환한다.

```cs
float h = Input.GetAxisRaw("Horizontal");
float v = Input.GetAxisRaw("Vertical");
Vector3 moveDir = new Vector3(h, 0f, v).normalized;
Vector3 worldMoveDir = transform.TransformDirection(moveDir);
```

<br>



# 2. 월드-로컬 변환
---

## **[1] InverseTransformPoint()**

- `위치`, `회전`, `크기` 변환을 적용한다.

- 방향 벡터가 아니라, 위치 벡터를 변환할 때 사용한다.

- 메시의 월드 정점 좌표로부터 로컬 정점 좌표를 구할 때 사용된다.

- 쉐이더가 아닌 C# 스크립트에서는 정말로 쓸 일이 드문 메소드

<br>

## **[2] InverseTransformVector()**

- `회전`, `크기` 변환을 적용한다.

- 마찬가지로 C# 스크립트에서 굳이 사용할 일이 별로 없으며, 괜히 `InverseTransformDirection()`과 혼동하지 않도록 주의한다.

<br>


## **[3] InverseTransformDirection()**

- `회전` 변환만 적용한다.

- 월드 공간의 방향 벡터를 트랜스폼의 로컬 공간 방향 벡터로 바꿀 때 사용된다.

- 예시 : 내적을 통해 적이 캐릭터의 왼쪽 또는 오른쪽에 있는지 파악하기

```cs
Vector3 enemyPos  = ...;                // 적의 현재 월드 위치
Vector3 playerPos = transform.position; // 플레이어 캐릭터의 현재 월드 위치

Vector3 playerToEnemyDir = enemyPos - playerPos;
Vector3 localEnemyDir = transform.InverseTransformDirection(playerToEnemyDir);

float d = Vector3.Dot(localEnemyDir, Vector3.right);

// d >= 0 : 적은 플레이어 캐릭터의 우측에 존재
// d <  0 : 적은 플레이어 캐릭터의 좌측에 존재
```

<br>


# References
---
- <https://irfanbaysal.medium.com/differences-between-transformvector-transformpoint-and-transformdirection-2df6f3ebbe11>
- <https://docs.unity3d.com/ScriptReference/Transform.html>


