---
title: Raycast to AABB
author: Rito15
date: 2021-10-19 03:00:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# 레이캐스트(Raycast)
---

- 공간 상의 한 점에서부터 목표 지점까지 가상의 광선을 발사하여, 광선에 닿는 물체의 표면을 검출한다.

<br>


# AABB
---

- **Axis-Aligned Bounding Box**

- 여섯 면이 모두 각각 `X`, `Y`, `Z` 축에 정렬된 형태의 육면체

- 중심 좌표(`Vector3`)와 각 축의 크기(`Vector3`) 또는<br>
  최소 좌표(`Vector3`)와 최대 좌표(`Vector3`)를 통해 정의할 수 있다.

<br>


# Raycast to AABB
---



<br>


# 구현 예시(Unity)
---

{% include codeHeader.html %}
```cs
private Vector3? RaycastToAABB(Vector3 origin, Vector3 end, in MinMax bounds)
{
    ref Vector3 A = ref origin;
    ref Vector3 B = ref end;
    Vector3 min = bounds.min;
    Vector3 max = bounds.max;

    Vector3 AB = B - A;
    Vector3 signAB = Sign(AB);
    Vector3 contact;

    // [1] YZ 평면 검사
    if (signAB.x > 0) contact = RaycastToPlaneYZ(A, B, min.x);
    else              contact = RaycastToPlaneYZ(A, B, max.x);

    if (InRange(contact.y, min.y, max.y) && InRange(contact.z, min.z, max.z))
        return contact;
        
    // [2] XZ 평면 검사
    if (signAB.y > 0) contact = RaycastToPlaneXZ(A, B, min.y);
    else              contact = RaycastToPlaneXZ(A, B, max.y);

    if (InRange(contact.x, min.x, max.x) && InRange(contact.z, min.z, max.z))
        return contact;

    // [3] XY 평면 검사
    if (signAB.z > 0) contact = RaycastToPlaneXY(A, B, min.z);
    else              contact = RaycastToPlaneXY(A, B, max.z);

    if (InRange(contact.x, min.x, max.x) && InRange(contact.y, min.y, max.y))
        return contact;

    // [4] No Contact Point
    return null;
}
```

<details>
<summary markdown="span"> 
Math Functions
</summary>

```cs
/// <summary> XY 평면에 정렬된 평면을 향해 레이캐스트 </summary>
private Vector3 RaycastToPlaneXY(in Vector3 A, in Vector3 B, float planeZ)
{
    float ratio = (B.z - planeZ) / (B.z - A.z);
    Vector3 C;
    C.x = (A.x - B.x) * ratio + (B.x);
    C.y = (A.y - B.y) * ratio + (B.y);
    C.z = planeZ;
    return C;
}
/// <summary> XZ 평면에 정렬된 평면을 향해 레이캐스트 </summary>
private Vector3 RaycastToPlaneXZ(in Vector3 A, in Vector3 B, float planeY)
{
    float ratio = (B.y - planeY) / (B.y - A.y);
    Vector3 C;
    C.x = (A.x - B.x) * ratio + (B.x);
    C.z = (A.z - B.z) * ratio + (B.z);
    C.y = planeY;
    return C;
}
/// <summary> YZ 평면에 정렬된 평면을 향해 레이캐스트 </summary>
private Vector3 RaycastToPlaneYZ(in Vector3 A, in Vector3 B, float planeX)
{
    float ratio = (B.x - planeX) / (B.x - A.x);
    Vector3 C;
    C.y = (A.y - B.y) * ratio + (B.y);
    C.z = (A.z - B.z) * ratio + (B.z);
    C.x = planeX;
    return C;
}

/// <summary> 벡터의 각 요소마다 부호값 계산 </summary>
private Vector3 Sign(in Vector3 vec)
{
    return new Vector3(
        vec.x >= 0f ? 1f : -1f,
        vec.y >= 0f ? 1f : -1f,
        vec.z >= 0f ? 1f : -1f
    );
}

/// <summary> 값이 닫힌 범위 내에 있는지 검사 </summary>
private bool InRange(float value, float min, float max)
{
    return min <= value && value <= max;
}
```

</details>

<details>
<summary markdown="span"> 
Gizmo Example
</summary>

```cs
// MonoBehaviour Script


```

</details>

<br>

![2021_1019_Raycast to AABB 1](https://user-images.githubusercontent.com/42164422/137787643-ae6112a8-cda8-441e-b911-145f19be2d26.gif)

![2021_1019_Raycast to AABB 2](https://user-images.githubusercontent.com/42164422/137787645-e0d14cd9-7116-4f76-bb0a-7c5bacc76c83.gif)

<br>
