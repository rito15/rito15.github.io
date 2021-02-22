---
title: 파티클 시스템 기초 - 03 - 값의 지정 방법
author: Rito15
date: 2021-02-22 17:04:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [1. 값(Value)](#1-값value)
  - [Constant](#1-constant)
  - [Curve](#2-curve)
  - [Random Between Two Constants](#3-random-between-two-constants)
  - [Random Between Two Curves](#4-random-between-two-curves)

- [2. 색상(Color)](#2-색상color)
  - [Color](#1-color)
  - [Gradient](#2-gradient)
  - [Random Between Two Colors](#3-random-between-two-colors)
  - [Random Between Two Gradients](#4-random-between-two-gradients)
  - [Random Color](#5-random-color)


<br>

# 1. 값(Value)
---

![image](https://user-images.githubusercontent.com/42164422/108690004-29d1c400-753d-11eb-8fcb-f0f384efd368.png)

<br>

## [1] Constant

- 기본 설정

- 고정된 상수 값을 지정한다.

<br>

## [2] Curve

- 커브(그래프)를 통해 값을 결정한다.

- Curve로 설정 후, 파티클 시스템 인스펙터 하단에 위치한 [Particle System Curves]를 클릭하여 커브 설정 창을 열고 커브를 수정할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108705782-16305880-7551-11eb-8658-2a3c961fb3a7.png)

<br>

- 해당 커브 범위의 값들을 시간의 흐름에 따라 X축 순서로 탐색하여 Y축의 값을 사용하게 된다.

- 예시 : Start Size [0 ~ 1 직선 커브]

![image](https://user-images.githubusercontent.com/42164422/108705820-234d4780-7551-11eb-9be6-ae0b00f27ca2.png)

![2021_0222_Particle_Curve](https://user-images.githubusercontent.com/42164422/108705834-26483800-7551-11eb-94d3-81711d7953b9.gif)

<br>

## [3] Random Between Two Constants

- 지정한 두 값 사이의 범위에서 무작위 값을 항상 뽑아 사용하게 된다.

- 예시 : Start Size [0.1, 2]

![image](https://user-images.githubusercontent.com/42164422/108706045-660f1f80-7551-11eb-9620-15798c85055f.png)

![2021_0222_Particle_RandomTwoConst](https://user-images.githubusercontent.com/42164422/108706290-bbe3c780-7551-11eb-81d4-e0927a368113.gif)

<br>

## [4] Random Between Two Curves

- 기본적으로 Curve와 같이 시간의 흐름에 따라 X축을 탐색하여, 두 커브 사이에 있는 Y축의 값을 무작위로 사용한다.

- 예시 : Start Size [0 ~ 0, 0 ~ 2]

![image](https://user-images.githubusercontent.com/42164422/108706618-34e31f00-7552-11eb-9a0a-15788cb06cfb.png)

![2021_0222_Particle_RandomTwoCurve](https://user-images.githubusercontent.com/42164422/108706702-53491a80-7552-11eb-9da2-6d1bcffd09d5.gif)

<br>

# 2. 색상(Color)
---

![image](https://user-images.githubusercontent.com/42164422/108690026-30603b80-753d-11eb-920a-45fe58e25e3c.png)

<br>

## [1] Color

- 단일 색상을 지정한다.

<br>

## [2] Gradient

- 그라디언트를 지정한다.

- 시간의 흐름에 따라 그라디언트의 색상들을 순차적으로 사용하게 된다.

- 예시 : Start Color

![image](https://user-images.githubusercontent.com/42164422/108707191-03b71e80-7553-11eb-8e6a-74f2d2cf4f33.png)

![2021_0222_Particle_Gradient](https://user-images.githubusercontent.com/42164422/108707265-1b8ea280-7553-11eb-98b1-fcd811f4ad9a.gif)

<br>

## [3] Random Between Two Colors

- 두 개의 색상을 지정한다.

- 두 색상 값 사이에 있는 무작위 색상을 뽑아 사용하게 된다.

- 예시 : Start Color

![image](https://user-images.githubusercontent.com/42164422/108707428-542e7c00-7553-11eb-8792-29889235ef00.png)

![2021_0222_Particle_TwoColor](https://user-images.githubusercontent.com/42164422/108707557-8c35bf00-7553-11eb-8105-0748a0b0f771.gif)

<br>

## [4] Random Between Two Gradients

- 두 개의 그라디언트를 지정한다.

- 시간의 흐름에 따라 각각의 그라디언트에 지정된 색상값 사이에서 무작위 색상을 뽑아 사용한다.

- 예시 : Start Color

![image](https://user-images.githubusercontent.com/42164422/108708297-9ad0a600-7554-11eb-9f8c-c116654215e1.png)

![2021_0222_Particle_TwoGradient](https://user-images.githubusercontent.com/42164422/108708605-ff8c0080-7554-11eb-90ae-4a1c9ffc7a90.gif)

<br>

## [5] Random Color

- 그라디언트를 지정한다.

- 시간의 흐름에 관계 없이, 그라디언트 내의 무작위 색상을 뽑아 사용한다.

- 예시 : Start Color

![image](https://user-images.githubusercontent.com/42164422/108708788-3c57f780-7555-11eb-87d5-bc2e6999305d.png)

![2021_0222_Particle_RandomColor](https://user-images.githubusercontent.com/42164422/108708795-3eba5180-7555-11eb-8838-5096e7039dd7.gif)
