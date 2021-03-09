---
title: 유니티 쉐이더 프로퍼티 애트리뷰트 모음
author: Rito15
date: 2021-03-04 21:58:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, enum, toggle, multicompile]
math: true
mermaid: true
---

# Space
---

```hlsl
[Space(10)]
```

- 단순 공백을 크기로 지정한다.


<br>

# Header
---

```hlsl
[Header(Header Text)]
```

- 헤더 문자열을 지정한다.
- 큰따옴표로 묶지 않아야 한다.


<br>

# Toggle
---

```hlsl
[Toggle] _MyToggle ("My Toggle", Float) = 1.0
```

- 체크할 경우 1.0, 체크 해제할 경우 0.0으로 값을 받을 수 있다.


<br>

# IntRange
---

```hlsl
[IntRange] _Value("Value", Range(0, 100)) = 50
```

- Range를 정수로 지정할 수 있게 한다.


<br>

# PowerSlider
---

```hlsl
[PowerSlider(3.0)] _Pow("Power", Range(0.01, 1)) = 0.01
```

- 지수 슬라이더를 만든다.

<br>

# Enum
---

```hlsl
[Enum(UnityEngine.Rendering.CullMode)] 	_CullMode("Cull Mode", Float) = 2
[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 0
[Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1

[Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("Src Factor", Float) = 5
[Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("Dst Factor", Float) = 10
```

- 이미 정의된 Enum을 타입으로 지정하여 가져올 수 있으며,
- 괄호 내에서 직접 Enum을 넣어줄 수도 있다.
- 이렇게 지정한 Enum은 쉐이더 키워드에서 활용할 수 있다.


<br>

# Shader Feature, Multi Compile
---

## 공통점
 - 전처리기 지시문 if를 통해 분기할 수 있다.

## 차이점
 - Shader Feature는 사용되지 않는 배리언트가 빌드에 포함되지 않아, 마테리얼의 키워드 설정에 적합하다.
 - Multi Compile은 프로젝트 내 전역으로 설정되는 키워드로 사용하기에 적합하다.

## 대상
 - `[Toggle(TOGGLE_NAME)]`, `[KeywordEnum(A, B, C)]`

<br>

## **Toggle**

```hlsl
Properties
{
    [Toggle(BRIGHTER)] _Brighter("Brighter", Float) = 0
}
SubShader
{
    // ..

    CGPROGRAM

    #pragma shader_feature BRIGHTER

    // ..

    void surf (Input IN, inout SurfaceOutputStandard o)
    {
        fixed4 c = _Color;

    #ifdef BRIGHTER
        c.rgb *= 2.0;
    #endif

        o.Albedo = c.rgb;
        o.Alpha = c.a;
    }
    ENDCG
}
```

- Toggle 괄호 내부에 키워드를 지정한다.
- `#pragma shader_feature`로 키워드를 그대로 선언한다.
- 전처리 지시문 `#ifdef` ~ `#else` ~ `#endif`로 활용할 수 있다.

<br>

## **KeywordEnum**

```hlsl
Properties
{
    [KeywordEnum(None, Red, Green, Blue)] _ColorOverwrite("Color Overwrite", Float) = 0
}
SubShader
{
    // ...

    CGPROGRAM

    #pragma shader_feature _COLOROVERWRITE_NONE _COLOROVERWRITE_RED _COLOROVERWRITE_GREEN _COLOROVERWRITE_BLUE

    // ...

    void surf (Input IN, inout SurfaceOutputStandard o)
    {
        fixed4 c = _Color;

    #if _COLOROVERWRITE_RED
        c.rgb = fixed3(1., 0., 0.);
            
    #elif _COLOROVERWRITE_GREEN
        c.rgb = fixed3(0., 1., 0.);
            
    #elif _COLOROVERWRITE_BLUE
        c.rgb = fixed3(0., 0., 1.);

    #endif

        o.Albedo = c.rgb;
        o.Alpha = c.a;
    }
    ENDCG
}
```

- KeywordEnum 괄호 내부에 Enum 값들을 직접 정의한다.
- 정수 값은 0부터 시작한다.

- `#pragma shader_feature` Enum 값마다 `프로퍼티명_값` 꼴로 모두 작성해준다.
- pragma는 enum 하나 당 한줄로 작성해야 하며, 프로퍼티를 소문자로 선언했더라도 모두 대문자로 작성해야 한다.
- 전처리 지시문 `#if` ~ `#elif` ~ `#endif`로 활용할 수 있다.

<br>

# Example Source Code
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/ShaderOptionsExample"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Attributes)]

        [Toggle] _MyToggle ("My Toggle", Float) = 1.0
        [IntRange] _IntRange ("Int Range", Range(0, 100)) = 50
        [PowerSlider(3.0)] _Pow ("Power", Range(0.01, 1)) = 0.01

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Enums)]

        [Enum(UnityEngine.Rendering.CullMode)] 	_CullMode("Cull Mode", Float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("Src Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("Dst Factor", Float) = 10

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Variants)]

        [Toggle(BRIGHTER)] _Brighter("Brighter", Float) = 0
        [KeywordEnum(None, Red, Green, Blue)] _ColorOverwrite("Color Overwrite", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        Cull   [_CullMode]
		ZTest  [_ZTest]
		ZWrite [_ZWrite]
		Blend  [_SrcFactor] [_DstFactor]

        CGPROGRAM

        #pragma shader_feature BRIGHTER
        #pragma shader_feature _COLOROVERWRITE_NONE _COLOROVERWRITE_RED _COLOROVERWRITE_GREEN _COLOROVERWRITE_BLUE

        #pragma surface surf Standard keepalpha //addshadow

        struct Input { fixed color:COLOR; };

        fixed4 _Color;
        float _MyToggle;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = _Color;

        #if _COLOROVERWRITE_RED
            c.rgb = fixed3(1., 0., 0.);
            
        #elif _COLOROVERWRITE_GREEN
            c.rgb = fixed3(0., 1., 0.);
            
        #elif _COLOROVERWRITE_BLUE
            c.rgb = fixed3(0., 0., 1.);

        #endif

        #ifdef BRIGHTER
            c.rgb *= 2.0;
        #else
        #endif

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Transparent"
}
```

</details>

<br>

# References
---
- <https://docs.unity3d.com/kr/2018.4/Manual/SL-MultipleProgramVariants.html>
- <https://chulin28ho.tistory.com/591>
- <https://darkcatgame.tistory.com/77>