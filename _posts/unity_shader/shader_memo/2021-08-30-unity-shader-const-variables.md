---
title: 유니티 쉐이더 - 상수, 상수 배열 선언하기
author: Rito15
date: 2021-08-30 21:00:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, shader, memo]
math: true
mermaid: true
---

# Memo
---

- Pass 내부에 작성

```hlsl
// 매크로 상수
#define RANDOM_SEED 426.791

// 그냥 상수
static const float RandomSeed = 5417.24;

// 상수 배열
static const float2 dir[8] = 
{
    float2(1, 0), float2(0, 1),   float2(-1, 0), float2(0, -1),
    float2(1, 1), float2(-1, -1), float2(-1, 1), float2(1, -1)
};
```
