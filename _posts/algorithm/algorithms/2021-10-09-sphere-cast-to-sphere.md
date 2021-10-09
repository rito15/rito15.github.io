---
title: Sphere Cast to Sphere
author: Rito15
date: 2021-10-09 18:26:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp, raycast]
math: true
mermaid: true
---

# Sphere Cast
---

- 공간 상의 한 점에서부터 목표 지점까지 구체를 전진시켜, 구체 표면에 닿는 물체 표면을 검출한다.

- 레이캐스트와는 달리 구체의 반지름을 고려해야 한다.

<br>

# Sphere Cast to Sphere
---

- 대상 물체가 구체인 경우에 대해서만 검사한다.

- 충돌 여부와 충돌 지점을 알아내는 것이 목표이다.

<br>

## **[1] 충돌 여부 판정**

충돌 지점을 계산하기 전에, 우선 충돌 여부를 판정할 필요가 있다.

> - A : 캐스트 시작 지점
> - B : 캐스트 종료 지점
> - S : 검사 대상 구체의 중심 위치
> - r1 : 캐스트 구체의 반지름
> - r2 : 구체 S의 반지름
> - d : 점 S에서 직선 AB로 내린 수선의 길이

![image](https://user-images.githubusercontent.com/42164422/136655980-d45ec7ff-9178-47c0-a9a2-4ea35617c491.png)

캡슐과 구체의 충돌을 판정하는 방식과 같다.

점 S에서 직선 AB로 수선의 발을 내렸을 때, 수선의 길이가 두 구체 반지름의 합보다 크거나 같으면 충돌로 판정된다.

수식으로 간단히 표현하면 다음과 같다.

$$
d >= r1 + r2
$$

<br>

## **[2] 충돌하는 순간의 구체 중심 위치 찾기**

구체가 지점 A에서부터 B로 이동하다가 충돌하는 순간의 중심 위치를 C라고 했을 때,

이를 그림으로 그려보면 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/136657560-83b1e849-4b10-4a34-aeea-5443640c8585.png)

위 그림에서의 특징은 다음과 같다.

- 점 C는 직선 AB 위의 한 점이다.
- 선분 CS의 길이는 `r1 + r2`와 같다.

<br>

점 S에서 직선 AB로 내린 수선의 발을 D라고 했을 때, 그림으로 표현하면 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/136657606-992375e0-9403-46aa-892c-3997f85aa995.png)

직선 AB는 이미 알고 있으므로 점 C의 좌표를 구하려면 선분 AC의 길이를 알아야 한다.

$$
|AC| = |AD| - |CD|
$$

위의 식을 이용해 선분 AC의 길이 `|AC|`를 구할 수 있는데,

<br>

직선 `AB`의 방향 벡터를 `nAB`라고 했을 때

삼각형 `ADS`는 직각삼각형이므로 선분 `AS`를 `nAB`와 내적하면 `|AD|`를 구할 수 있다.

$$
nAB = normalize(AB)
$$

$$
|AD| = dot(AS, nAB)
$$

<br>

그리고 피타고라스 정리를 이용하여 `|DS|`의 길이를 구할 수 있다.

$$
|DS| = \sqrt{|AS|^{2} - |AD|^{2}}
$$

<br>

`|CS| = r1 + r2`로 이미 알고 있으므로, 마찬가지로 피타고라스의 정리를 이용하면 `|CD|`를 구할 수 있다.

$$
|CD| = \sqrt{|CS|^{2} - |DS|^{2}}
$$

<br>

이제 `|AC|`를 계산할 수 있으므로, 이를 통해 점 `C`의 좌표를 구할 수 있다.

$$
C = A + nAB * |AC|
$$

<br>

하나의 식으로 정리해보면 다음과 같다.

$$
C = A + nAB * (dot(AS, nAB) - \sqrt{(r1 + r2)^{2} - |AS|^{2} + dot(AS, nAB)^{2}})
$$

<br>

# 구현 예시(Unity)
---

{% include codeHeader.html %}
```cs

```

<details>
<summary markdown="span"> 
Gizmo Example
</summary>

```cs
// MonoBehaviour Script


```

</details>

<br>



<br>
