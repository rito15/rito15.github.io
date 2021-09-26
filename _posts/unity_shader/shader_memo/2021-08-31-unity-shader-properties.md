---
title: 유니티 쉐이더 - 프로퍼티 메모
author: Rito15
date: 2021-08-31 19:54:00 +09:00
categories: [Unity Shader, Shader Memo]
tags: [unity, shader, memo]
math: true
mermaid: true
---

# Memo
---
- 자꾸만 까먹어서 메모

```hlsl
Properties
{
    _MyColor("MyColor", Color) = (1,1,1,1)

    _MyVector("My Vector", Vector) = (0,0,0,0)

    _MyRange("My Range", Range(0, 1)) = 1

    _MyFloat("My float", Float) = 0.5

    _MyInt("My Int", Int) = 1

    _MyTexture2D("Texture2D", 2D) = "white" {}

    _MyTexture3D("Texture3D", 3D) = "white" {}

    _MyCubemap("Cubemap", CUBE) = "" {}
}
```
