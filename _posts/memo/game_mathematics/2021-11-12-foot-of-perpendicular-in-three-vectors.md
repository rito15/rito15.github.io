---
title: 게임 수학 - 세 점이 주어질 때 수선의 발 구하기
author: Rito15
date: 2021-11-12 18:12:00 +09:00
categories: [Memo, Game Mathematics]
tags: [game, math]
math: true
mermaid: true
---

# 수선의 발 구하기
---

![image](https://user-images.githubusercontent.com/42164422/141440387-44f3cd8c-2294-4c1f-93eb-61f85d3dd25a.png)

공간 상의 세 점 `A`, `B`, `C`가 주어져 있다.

`D`는 `C`에서 직선 `AB`에 내린 수선의 발이다.

`D`는 간단히 다음과 같이 구할 수 있다.

$$
D = A + AB * \frac{AB \cdot AC}{AB \cdot AB}
$$

<br>

## **설명**

`AD` 벡터를 구하고, `A`에서 `AD`를 더해 `D`를 계산하는 방식이다.

벡터 `AB`와 `AC`를 내적하면 `AB`의 크기와 `AC`를 `AB`에 사영한 벡터 `AD`의 크기를 곱한 값, 즉 `|AB| * |AD|`를 얻을 수 있고,

벡터 `AB`를 자기 자신에 대해 내적하면 `|AB| * |AB|`를 얻을 수 있다.

전자를 후자로 나누면 `|AD| / |AB|`를 얻을 수 있고,

여기에 벡터 `AB`를 곱하면 `AB`의 방향을 유지한채 크기는 `|AD|`인 벡터, 즉 `AD`를 얻을 수 있다.

그리고 `A`에 더해주면 `D`가 된다.


