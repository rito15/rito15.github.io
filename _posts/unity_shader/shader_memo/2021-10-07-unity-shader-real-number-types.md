---
title: 유니티 쉐이더 - 실수 타입들
author: Rito15
date: 2021-10-07 00:48:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, shader, memo]
math: true
mermaid: true
---

# Memo
---

## **[1] float**
- 32비트
- 유효 숫자 : 6자리

- 실수 중 정확도가 가장 높다.
- 실수 중 연산이 가장 느리다.
- 정확해야 하는 경우, 대개 사용된다.

- 예시 : 정점 위치, UV, 복합 스칼라 연산

<br>

## **[2] half**
- 16비트
- 유효 숫자 : 3자리
- 표현 범위 : `-60,000.0` ~ `+60,000.0`

- 예시 : 방향 벡터, HDR 색상

<br>

## **[3] fixed**
- 11비트
- 정밀도 : `1/256`
- 표현 범위 : `-2.0` ~ `+2.0`

- 연산이 가장 빠르다.
- 작은 범위에서 한정된 LDR 색상 등에 사용된다.

- 예시 : `Albedo`, `Emission`, `Normal`

<br>

# References
---
- <https://docs.unity3d.com/kr/2019.4/Manual/SL-DataTypesAndPrecision.html>

