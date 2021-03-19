---
title: 트랜스폼과 방향벡터의 회전
author: Rito15
date: 2021-03-19 17:08:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, rotation]
math: true
mermaid: true
---

# Memo
---

## **유니티엔진에서의 회전**

- 각 축에 회전이 적용되는 순서는 Z축 -> X축 -> Y축

<br>

## **트랜스폼을 자신의 축으로 회전시킬 때**

Local Rotation(Euler) X, Y, Z 값 중 회전시키려는 축을 제외하고 모두 0이라면

(예 : X축으로 회전시키려는데 (34f, 0f, 0f)인 상태)

해당 축의 오일러 값만 변경시키면 다른 축에 영향을 받지 않고 정상적으로 회전할 수 있다.

<br>

정확히는, 유니티엔진의 회전 순서에 따라

Z축 회전일 경우 X, Y 오일러 값에 상관 없이 회전이 가능하고

X축 회전일 경우 Z 값이 0이 아니면 영향을 받고,

Y축 회전일 경우 Z, X값이 0이 아니면 영향을 받는다.

<br>

회전시키려는 축 외의 다른 값이 0이 아닌 상태라면

(예 : X축으로 회전시키려는데 (1f, 2f, 3f)인 상태)

아래의 1번 방법을 사용하여 회전시켜야 한다.

<br>

# 1. 트랜스폼을 자신의 축으로 회전
---

- 트랜스폼의 자신의 축으로 회전시키기
- rotVector가 (1, 0, 0)인 경우 : 자신의 X축으로 회전

- 트랜스폼의 rotation 값 자체는 x, y, z 모두 변화하지만, 회전 자체는 자신의 축을 기반으로 수행

```cs
transform.Rotate(rotVector, Space.Self);

// Space.Self일 때의 Rotate() 내부 구현
transform.localRotation *= Quaternion.Euler(rotVector);
```

<br>

# 2. 트랜스폼을 월드 축으로 회전
---

- 트랜스폼을 월드 축으로 회전시키기

```cs
transform.Rotate(rotVector, Space.World);

// 내부 구현
transform.rotation *= 
    rot * Quaternion.Inverse(rot) * Quaternion.Euler(rotVector) * rot;
```

<br>

# 3. 방향 벡터를 월드 축으로 회전
---

```cs
Vector3 dirVec = new Vector3(1f, 0f, 0f);  // 회전시킬 방향 벡터
Vector3 rotVec = new Vector3(0f, 45f, 0f); // Y축 45도 회전

Vector3 rotatedDirVec = Quaternion.Euler(rotVec) * dirVec;
```

<br>

# 4. 방향 벡터를 특정 축으로 회전
---

```cs
Vector3 dirVec = new Vector3(1f, 0f, 0f);              // 회전시킬 방향 벡터
Vector3 axisVec = new Vector3(-1f, 1f, 0f).normalized; // 회전 기준축 벡터

// axisVec을 축으로 하여 dirVec을 45도 회전
Vector3 rotatedDirVec = Quaternion.AngleAxis(45f, axisVec) * dirVec;
```



