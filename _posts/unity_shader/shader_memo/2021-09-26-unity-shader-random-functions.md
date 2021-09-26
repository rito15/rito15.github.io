---
title: 유니티 쉐이더 - 랜덤 함수들
author: Rito15
date: 2021-09-26 21:19:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, shader, memo]
math: true
mermaid: true
---

# Memo
---

```hlsl
float Random(float2 seed)
{
    return frac(sin(dot(seed, float2(73.867, 25.241))) * 39482.17593);
}

float RandomRange(float2 seed, float min, float max)
{
    float t = frac(sin(dot(seed, float2(73.867, 25.241))) * 39482.17593);
    return lerp(min, max, t);
}

float3 RandomRGB(float2 seed)
{
    float r = frac(sin(dot(seed, float2(12.586, 25.241))) * 39482.17593);
    float g = frac(cos(dot(seed, float2(43.197, 74.349))) * 17631.64259);
    float b = frac(sin(dot(seed, float2(76.974, 14.846))) * 66569.82467);

    return float3(r, g, b);
}
```

