---
title: 레이캐스트 - 평면(Plane)
author: Rito15
date: 2021-10-03 22:22:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# 레이캐스트(Raycast)
---

- 공간 상의 한 점에서부터 목표 지점까지 가상의 광선을 발사하여, 광선에 닿는 물체의 표면을 검출한다.


<br>

# 평면(Plane)
---

![image](https://user-images.githubusercontent.com/42164422/135755066-0a3bd70a-5f31-4f02-8f06-2dcfbac95dfe.png)

평면 위의 점 `P`와 평면의 법선 벡터 `N`을 알고 있으면 평면을 정의할 수 있으며,

평면 위의 임의의 점 `X`를 가정하여 `dot(N, P - X) = 0`을 통해 평면의 방정식을 정의할 수 있다.

<br>

# 직선과 평면의 교차점 찾기
---

점 `A`에서 점 `B`를 향해 광선을 발사하여, 광선과 평면이 만나는 지점을 찾는다.

![image](https://user-images.githubusercontent.com/42164422/135755364-130b5305-7275-462f-a63c-39ee42ca036d.png)

위와 같이 `A`, `B`, `P`, `N`이 주어졌을 때, 

길이 `d`를 알아내고 이를 통해 직선과 평면의 교차점 `C`를 알아내야 한다.

<br>

평면의 정의에 의해 다음과 같은 식을 얻을 수 있다.

$$
dot(N, P - C) = 0
$$

<br>

그리고 내적의 분배 법칙에 의해

$$
dot(N, P - C) = dot(N, P) - dot(N, C) = 0
$$

이며,

<br>

따라서

$$
dot(N, P) = dot(N, C)
$$

이다.

<br>

점 `A`에서 `B`를 향하는 직선의 방향 벡터를 `nAB`라고 할 때, 다음과 같이 구할 수 있다.

$$
nAB = normalize(B - A)
$$

<br>

따라서 점 `C`는 다음과 같이 정의할 수 있다.

$$
C = A + nAB * d
$$

<br>

위에서 구한 식의 `C`에 대입하면

$$
dot(N, P) = dot(N, A + nAB * d)
$$

이며,

<br>

내적의 분배법칙에 의해

$$
dot(N, P) = dot(N, A) + dot(N, nAB) * d
$$

이다.

<br>

위의 식을 내적의 결합법칙을 통해 정리하면 다음과 같다.

$$
dot(N, P) - dot(N, A) = dot(N, nAB) * d
$$

<br>

$$
dot(N, P - A) = dot(N, nAB) * d
$$

<br>

$$
d = \frac{dot(N, P - A)}{dot(N, nAB)}
$$

<br>

따라서 점 `C`의 좌표는 다음과 같이 구할 수 있다.

$$
C = A + nAB \cdot \frac{dot(N, P - A)}{dot(N, nAB)}
$$

<br>

# 구현 예시(Unity)
---

{% include codeHeader.html %}
```cs
private Vector3? RaycastToPlane(Vector3 origin, Vector3 end, Vector3 planePoint, Vector3 planeNormal)
{
    ref Vector3 A = ref origin;
    ref Vector3 B = ref end;
    ref Vector3 P = ref planePoint;
    ref Vector3 N = ref planeNormal;
    Vector3 AB = (B - A);
    Vector3 nAB = AB.normalized;

    float d = Vector3.Dot(N, P - A) / Vector3.Dot(N, nAB);

    // 레이 방향이 평면을 향하지 않는 경우
    if (d < 0) return null;

    Vector3 C = A + nAB * d;

    float sqrAB = AB.sqrMagnitude;
    float sqrAC = (C - A).sqrMagnitude;

    // 레이가 짧아서 평면에 도달하지 못한 경우
    if (sqrAB < sqrAC) return null;

    return C;
}
```

<details>
<summary markdown="span"> 
Gizmo Example
</summary>

```cs
// MonoBehaviour Script

public Transform rayOrigin;
public Transform rayEnd;
public Transform plane;

public bool intersected;

private void OnDrawGizmos()
{
    if (!rayOrigin || !rayEnd || !plane) return;

    Vector3 ro = rayOrigin.position; // 레이 시작 지점
    Vector3 re = rayEnd.position;    // 레이 종료 지점
    Vector3 pp = plane.position;     // 평면 위치
    Vector3 pn = plane.up;           // 평면 노멀 벡터

    Gizmos.color = Color.blue;
    Gizmos.DrawSphere(ro, 0.3f);
    Gizmos.DrawLine(ro, re);

    Gizmos.color = Color.green;
    Gizmos.DrawSphere(re, 0.3f);

    Vector3? intersection = RaycastToPlane(ro, re, pp, pn);
    intersected = (intersection != null);
    if (intersected)
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(intersection.Value, 0.3f);
    }
}
```

</details>

<br>

![2021_1003_LinePlane_Inter](https://user-images.githubusercontent.com/42164422/135756141-c18a6815-0f40-4339-99cc-2e37e5c48ac5.gif)

![2021_1003_LinePlane_Inter2](https://user-images.githubusercontent.com/42164422/135756142-b9029e4e-db7c-4f8e-83ad-4197afb3fe1c.gif)


