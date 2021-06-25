---
title: Surface Shader Bible [예정]
author: Rito15
date: 2021-02-02 01:00:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader]
math: true
mermaid: true
---

# 목차
---

<br>

# Surface Shader 기본 구성
---
```hlsl
Shader "Custom/SurfaceShader01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        // Custom Lighting Fuction

        ENDCG
    }
    FallBack "Diffuse"
}
```

<br>

# 프로퍼티
---
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

<br>

# 서브쉐이더
---
```hlsl
SubShader
{
    Tags {}
    // Name "" // 선택사항

    CGPROGRAM
    // LOD 000 // 선택사항, 패스별로 지정

    #pragma ...

    Struct

    Variables

    Surface Function

    // Lighting Function // 선택사항
    
    ENDCG

    // 패스 추가할 경우 PROGRAM~END 추가 작성
}
```

<br>

# 태그
---

```hlsl
// 스카이박스(1000)
Tags { "RenderType"="Background" "Queue"="Background" } 

// 불투명(2000)
Tags { "RenderType"="Opaque" }

// 컷아웃(2500)
Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" } 

// 반투명(3000)
Tags { "RenderType"="Transparent" "Queue"="Transparent" } 

// 오버레이(4000)
Tags { "RenderType"="Overlay" "Queue"="Overlay" } 
```

<br>
- ### Render Type

|---|---|
|`Background`|스카이박스|
|`Opaque`|불투명|
|`TransparentCutout`|컷아웃(알파테스트) 쉐이더|
|`Transparent`|반투명|
|`Overlay`|가장 나중에 그리는 경우 - GUI, Halo, Flare|

<br>
- ### Queue

|---|---|---|
|`Background`|1000|가장 먼저 그려져야 하는 경우 - 스카이박스, 배경|
|`Geometry`|2000|대부분의 불투명에 사용, 생략시 자동 지정|
|`AlphaTest`|2500|알파 테스트를 사용하는 경우|
|`Transparent`|3000|반투명|
|`Overlay`|4000|GUI, 렌즈플레어 등 가장 마지막에 그리는 경우|

<br>
- ### 기타 태그

|---|---|---|
|IgnoreProjector|True 또는 False|프로젝터에게 영향 받을지 여부|
|ForceNoShadowCasting|True 또는 False|그림자를 생성하지 않음|
|DisableBatching|True, False, LODFading||
|CanUseSpriteAtlas|True, False||
|PreviewType|Plane, Skybox||

<br>

# 패스
---

- `GrabPass { /*"GrabPassName"*/ }` : 그랩패스 추가
- `UsePass "ShaderName/PassName"` : 다른 쉐이더의 패스 가져와 사용

- 서피스 쉐이더는 멀티패스를 쓰는 경우 Pass{} 대신<br>`CGPROGAM` ~ `ENDCG` 병렬 작성해야 함

- 각각의 패스 CGPROGRAM 상단에 Name, LOD, RenderSetup, Stencil 지정 가능
  - Name "PassName" : 해당 패스의 이름 지정
  - `LOD` : 지정된 LOD 값에 따라 다른 패스 사용<br>(현재 LOD가 패스에 지정한 LOD값 이하인 경우 해당 패스 사용)
  - `RenderSetup` : Cull, ZTest, ZWrite, Blend, ColorMask, Offset

```hlsl
Shader "Custom/SurfaceShader01"
{
    Properties
    {
        // ..
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } // 태그도 패스마다 지정 가능

        GrabPass { /*"GrabPassName"*/ }

        // Name, LOD, RenderSetup, Stencil, (Tag)
        CGPROGRAM // Pass 0
        ...
        ENDCG

        // Name, LOD, RenderSetup
        CGPROGRAM // Pass 1
        ...
        ENDCG

        UsePass "ShaderName/PassName"
    }
    FallBack "Diffuse"
}
```

<br>

# RenderSetup(렌더링 설정)
---

- 각 패스의 CGPROGRAM 상단에 작성

## Culling
- 폴리곤 전면 또는 후면을 렌더링하지 않도록 설정

|---|---|
|`Cull Back`(기본값)|폴리곤 후면(모델 안쪽) 그리지 않기|
|`Cull Front`|폴리곤 전면(모델 바깥쪽) 그리지 않가|
|`Cull Off`|모든 면을 그리기|

<br>

## ZWrite
- 뎁스 버퍼(Z-Buffer)에 그릴지 여부 결정
- 뎁스 버퍼 : 깊이를 나타내는 렌더 텍스쳐

|---|---|
|`ZWrite On`(기본값)|뎁스 버퍼에 그리기|
|`ZWrite Off`|뎁스 버퍼에 그리지 않가<br> - 항상 앞에 보이게 됨|

<br>

## ZTest

https://docs.unity3d.com/kr/530/Manual/SL-Pass.html
https://docs.unity3d.com/kr/530/Manual/SL-CullAndDepth.html
https://m.blog.naver.com/plasticbag0/221299492724


<br>

## Blend




<br>

## ColorMask



<br>

## Offset




<br>

# 스텐실
---

- 각 패스의 CGPROGRAM 상단에 작성

https://docs.unity3d.com/kr/530/Manual/SL-Stencil.html

<br>

# pragma
---

<br>


# 구조체
---

<br>

# surf 함수
---

<br>

# 커스텀 라이팅 함수
---

<br>

# Fallback
---
- 

<br>

# 애트리뷰트
---

https://docs.unity3d.com/ScriptReference/MaterialProperty.PropFlags.html
https://docs.unity3d.com/ScriptReference/MaterialPropertyDrawer.html

<br>

# Shader Feature
---

- Shader Feature, Multi Compile

https://illu.tistory.com/1370#footnote_link_1370_1
https://docs.unity3d.com/kr/2019.4/Manual/SL-MultipleProgramVariants.html

<br>

# GPU Instancing
---

https://docs.unity3d.com/kr/2018.4/Manual/GPUInstancing.html


# 자주 쓰이는 코드 모음
---

<br>

# References
---
- <https://docs.unity3d.com/kr/530/Manual/SL-SurfaceShaders.html>
- <http://rapapa.net/?p=2723> (멀티패스)
- <https://m.blog.naver.com/plasticbag0/221299492724> (알파개념)
- <>
- <>
- <>