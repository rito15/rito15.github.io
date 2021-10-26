---
title: Sphere-AABB Intersection
author: Rito15
date: 2021-10-26 20:22:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp, math]
math: true
mermaid: true
---

# Sphere
---

- 공간의 한 점에서부터 동일한 거리에 있는 점들의 집합

- 구체의 중심 좌표(`Vector3`), 반지름(`float`)을 통해 정의할 수 있다.

<br>

# AABB
---

- **Axis-Aligned Bounding Box**

- 여섯 면이 모두 각각 `X`, `Y`, `Z` 축에 정렬된 형태의 육면체

- 중심 좌표(`Vector3`)와 각 축의 크기(`Vector3`) 또는<br>
  최소 좌표(`Vector3`)와 최대 좌표(`Vector3`)를 통해 정의할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/138880458-b2609c93-18e5-4992-9210-73969d44e9be.png)

<br>


# Closest Point to AABB
---

우선, AABB 바깥의 한 점에서부터

AABB 여섯 면 위의 가장 가까운 점을 찾는다.

2차원 평면의 예시는 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/138879288-4c3bdea1-d554-48c9-ac41-3dd71b3ef656.png)

<br>

위의 그림에서 모든 노란색 점(Closest Point)들의 X 좌표만 살펴보자면,

`Min.x`보다 작은 점은 `Min.x`가 되고

`Min.x`와 `Max.x` 사이에 있는 점은 X 좌표가 유지되고

`Max.x`보다 큰 점은 `Max.x`가 된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/138888752-6d2ba76a-8575-4690-ab0c-f1d1b9e56106.png)

Y 좌표도 마찬가지로 `Min.y`, `Max.y`와의 관계를 따져보면 되고,

공간으로 확장해도 Z 좌표 역시 동일하다.

<br>

`Unity C#`으로 구현해보면 다음과 같다.

{% include codeHeader.html %}
```cs
private Vector3 ClosestPointToAABB(Vector3 P, in AABB aabb)
{
    if      (P.x < aabb.min.x) P.x = aabb.min.x;
    else if (P.x > aabb.max.x) P.x = aabb.max.x;
    if      (P.y < aabb.min.y) P.y = aabb.min.y;
    else if (P.y > aabb.max.y) P.y = aabb.max.y;
    if      (P.z < aabb.min.z) P.z = aabb.min.z;
    else if (P.z > aabb.max.z) P.z = aabb.max.z;
    return P;
}
```

<br>


# Sphere-AABB Intersection
---

![image](https://user-images.githubusercontent.com/42164422/138890348-693edfd2-a53f-434d-987b-dd7193131602.png)

AABB 바깥에서 AABB로의 인접 지점을 찾았으면,

구체와 AABB의 교차 여부는 아주 간단히 확인할 수 있다.

점 `S`에서 `C`까지의 거리가 구체의 반지름인 `r`보다 작거나 같은지 확인하면 된다.

<br>

`Unity C#`으로 구현해보면 다음과 같다.

{% include codeHeader.html %}
```cs
private bool SphereAABBIntersection(in Vector3 S, in float r, in AABB aabb)
{
    Vector3 C = ClosestPointToAABB(S, aabb);
    return (C - S).sqrMagnitude <= r * r;
}
```

거리 계산은 언제나 성분의 제곱으로 계산하는 것이 저렴하다.

<br>


# Source Code
---



<br>

# References
---

