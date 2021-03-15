---
title: 유니티 반투명, 스텐실 개념 익히기
author: Rito15
date: 2021-02-06 01:29:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, transparent, alpha, stencil]
math: true
mermaid: true
---

# 목차
---

- [1. 불투명과 반투명](#불투명과-반투명)
- [2. 알파 블렌딩, 알파 소팅](#알파-블렌딩-알파-소팅)
- [3. 알파 테스트](#알파-테스트)
- [4. 커스텀 알파 블렌딩](#커스텀-알파-블렌딩)
- [5. 파티클 쉐이더 만들어보기](#파티클-쉐이더-만들어보기)
- [6. 깨끗한 알파 블렌딩 쉐이더 만들기](#깨끗한-알파-블렌딩-쉐이더-만들기)
- [7. ZTest와 ZWrite](#ztest와-zwrite)
- [8. 알파 블렌딩 쉐이더에서 발생하는 문제점들](#알파-블렌딩-쉐이더에서-발생하는-문제점들)
- [9. 스텐실](#스텐실)
- [10. References](#references)


<br>

# 불투명과 반투명
---

**불투명(Opaque)**과 **반투명(Transparent)** 오브젝트는 그려지는 타이밍도, 그리기 위한 고려사항도 다르다.

유니티에서는 오브젝트를 렌더링하는 순서를 쉐이더와 마테리얼의 **렌더 큐(Render Queue)**를 통해 정수 값으로 지정하는데, 
지정한 값이 작은 순서대로 그리게 되며 기본적으로 Opaque는 **2000**, Transparent는 **3000**의 값을 가진다.

따라서 불투명 오브젝트가 전부 그려진 후에 반투명 오브젝트가 그려진다.

<br>

## **Z-buffer**

카메라로부터 픽셀마다 가장 가까운 오브젝트까지의 거리를 (0.0 ~ 1.0) 값으로 기록해놓는 버퍼.

**깊이 버퍼(Depth Buffer)**라고도 한다.

![image](https://user-images.githubusercontent.com/42164422/109923539-42db3180-7d02-11eb-8b1e-c6152cfcf71d.png){:.normal}

<br>

## **불투명(Opaque)**

![image](https://user-images.githubusercontent.com/42164422/107073497-cfd9ba80-682a-11eb-922e-9766ea42556f.png){:.normal}

불투명 오브젝트를 그리기 위해서 우선 Z버퍼를 참조한다.
각각의 픽셀마다 얻어낸 Z버퍼의 깊이 값과 자신의 깊이를 비교하여 픽셀들을 그릴지 안그릴지 여부를 결정하게 되는데, 이를 **Z Test**(Z Read)라고 한다.

따라서 불투명을 그릴 때는 해당 픽셀에서 겹쳐 있는 픽셀들 중에 가장 앞에 있는 오브젝트의 픽셀만 그리고, 뒤에 있는 픽셀은 그리지 않음으로써 자원을 절약하게 된다.

### **+ 만약 동일한 깊이 값을 가진다면?**

![image](https://user-images.githubusercontent.com/42164422/107071993-e2eb8b00-6828-11eb-8f76-6ea2fdef82e0.png){:.normal}

어떤 것을 먼저 그릴지 알 수 없으므로 위처럼 깨져 보이게 되며, 이를 **Z fighting**이라고 한다.

<br>

## **반투명(Transparent)**

![image](https://user-images.githubusercontent.com/42164422/107073835-34951500-682b-11eb-843c-c78fb555b9c6.png){:.normal}

반투명 오브젝트는 모든 불투명 오브젝트가 그려진 뒤에 그려진다.

만약 불투명 오브젝트 앞에 반투명 오브젝트가 존재하는데 반투명 오브젝트를 먼저 그리게 되면 

![image](https://user-images.githubusercontent.com/42164422/109839300-52b72f00-7c8a-11eb-82d2-37b927bda1fc.png)

반투명 오브젝트가 Z버퍼에 자신의 깊이를 기록해놓았고, 그 뒤에 그려지는 불투명 오브젝트는 이를 비교하여 겹친 부분에는 자신의 픽셀을 그리지 않도록 하여 위처럼 보이게 된다.

따라서 이런 문제 때문에 불투명 오브젝트를 모두 그리고 반투명 오브젝트를 그리게 된다.

그리고 불투명 오브젝트와 달리 같은 픽셀에 존재하는 모든 반투명 오브젝트의 픽셀들은 앞에서 불투명으로 가려지지 않은 이상 전부 화면에 그려지며, 이를 **오버드로우(Overdraw)**라고 한다.

오버드로우는 GPU 성능을 잡아먹는 주범 중 하나이기도 하다.

<br>

# 알파 블렌딩, 알파 소팅
---

겹쳐 있는 반투명 오브젝트의 픽셀들은 서로 섞여 최종적으로 화면에 그려지는데, 이를 **알파 블렌딩(Alpha Blending)**이라고 한다.

반투명 쉐이더는 기본적으로 알파 블렌딩 쉐이더라고 부른다.


그리고 반투명 오브젝트는 불투명 오브젝트와 다르게 멀리 있는 것부터 그려지는데, 이를 **알파 소팅(Alpha Sorting)**이라고 한다.

이 때 거리값을 판별하는 기준은 "카메라에서 오브젝트 피벗까지의 거리"를 이용한다.

<br>

## 알파 소팅을 하는 이유?

바로 이런 문제를 해결하기 위함이다.

![image](https://user-images.githubusercontent.com/42164422/109841098-0ec52980-7c8c-11eb-86bf-934787ca542c.png)

불투명을 그릴 때는 "앞에 오브젝트가 존재하면 뒤의 오브젝트는 그리지 않는 것"이 당연한데,

반투명 오브젝트를 그릴 때도 그렇게 해버리면 안되므로

"불투명보다 반투명을 무조건 나중에 그리기"로 합의해서 불투명-반투명 오브젝트간의 문제는 해결했다.

그런데 이번에는 똑같은 문제가 반투명 오브젝트 사이에서도 발생한다.

따라서 이를 해결하기 위해 반투명 오브젝트를 그릴 때 카메라로부터 피벗까지의 거리를 기준으로 멀리 있는 오브젝트부터 그리도록 하여,

앞의 오브젝트를 먼저 그려서 뒤의 오브젝트가 가려지는 일이 발생하지 않게 하는 것이다.

<br>

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/AlphaBlend"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM

        #pragma surface surf Lambert alpha:fade // alpha:fade 또는 alpha:blend
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Transparent" // 그림자 없애기
}
```

</details>

<br>

기본적으로 알파 블렌딩 쉐이더를 만들려면,

- Tags의 RenderType과 Queue를 `"Transparent"`로 작성한다.
- pragma에 `alpha:fade`, `alpha:blend` 중 하나를 작성한다.<br>
  (`keepalpha` 옵션도 있지만, 커스텀 알파 블렌딩 항목에서 설명한다.)

- 반투명 오브젝트는 그림자가 없는 것이 당연하므로, Fallback은 `"Transparent"`로 작성한다.<br>
  (Fallback에 지정한 쉐이더가 그림자의 생성에 영향을 준다.)

![2021_0206_Grass](https://user-images.githubusercontent.com/42164422/107119845-7aa2b500-68cd-11eb-89d6-75ff0a3e6ccd.gif){:.normal}

알파 소팅은 카메라에서 각 오브젝트의 피벗까지의 거리값을 기반으로 하기 때문에, 카메라 시점이 회전함에 따라 뒤에 있던 오브젝트가 불쑥 튀어나오는 현상이 발생한다.

이는 고질적인 문제로, 순수한 알파 블렌딩 쉐이더에서는 해결할 수 없다.

<br>

# 알파 테스트
---

DirectX에서는 **알파 테스트(Alpha Test)**, OpenGL에서는 **컷아웃(Cutout)**이라고 부르며, 유니티에서도 컷아웃이라고 부른다.

(그런데 키워드로는 AlphaTest를 쓰고, 기본 프로퍼티명은 _Cutoff라고 쓴다...)

알파 테스팅 쉐이더는 지정한 Cutoff 값보다 큰 알파값을 가지는 부분만 그려주고, 작은 값을 가지는 부분은 잘라낸다.

알파 테스팅 쉐이더에서는 알파 소팅에서 발생하는 문제(시점을 돌리면 뒤에 있던 오브젝트가 불쑥 튀어나오는 문제)가 발생하지 않는다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/AlphaTest"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

        CGPROGRAM

        // 컷아웃 프로퍼티 연결, 그림자 정보 갱신
        #pragma surface surf Lambert alphatest:_Cutoff addshadow
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Legacy Shaders/Transparent/Cutout/Diffuse" // 그림자 생성 관여
}
```

</details>

<br>

- Tags의 RenderType은 딱히 상관 없지만 Queue는 꼭 `"AlphaTest"`로 해준다.
- 프로퍼티에 컷아웃 변수를 하나 만들어주고(이름은 꼭 _Cutoff), pragma에서 `alphatest:_Cutoff`로 연결해준다.
- pragma에 `addshadow`를 추가해주지 않으면 쿼드의 그림자가 네모네모하게 나온다.
- Fallback도 그림자 생성에 관여하므로, 위처럼 작성해야 한다.

<br>

- addshadow 대신, `_Color` 프로퍼티를 추가해주는 방법이 있다.
- _Color 프로퍼티를 그저 넣어주기만 하면 그림자 생성에 영향을 준다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/AlphaTest"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
        _Color("Color", Color) = (1,1,1,1) // 그림자 생성 관여
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

        CGPROGRAM

        // 컷아웃 프로퍼티 연결
        #pragma surface surf Lambert alphatest:_Cutoff // addshadow 안씀
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Legacy Shaders/Transparent/Cutout/Diffuse" // 그림자 생성 관여
}
```

</details>

<br>

![2021_0206_Grass_Alphatest](https://user-images.githubusercontent.com/42164422/107126350-af753300-68f2-11eb-8a9a-cf0b84053af5.gif){:.normal}

알파 테스팅 쉐이더는 알파 소팅의 불쑥 튀어나오는 문제가 발생하지 않고, 알파 블렌딩에 비해 가볍다는 장점이 있다.

하지만 알파 블렌딩에 비해 외곽선이 자글자글하고 거칠게 잘려 보인다는 단점이 있다.

<br>

## 번외 : 알파 블렌딩 쉐이더에서 그림자 생성하기

- 알파 테스팅 쉐이더에서 그림자를 생성하는 방식을 이용하면 알파 블렌딩 쉐이더에서도 그림자를 생성할 수 있다.

  (하지만 그림자를 받지는 않는다. 다시 말해, Cast Shadow는 동작하지만 Receive Shadow는 동작하지 않는다.)

- 알파 소팅 문제가 발생하지만, 외곽선이 알파 테스팅 쉐이더보다 훨씬 부드럽다는 장점이 있다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/AlphaBlendShadow"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cutout", Range(0, 1)) = 0.5 // 그림자 생성 관여
        _Color("Color", Color) = (1,1,1,1)         // 그림자 생성 관여
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        ZWrite Off

        CGPROGRAM

        #pragma surface surf Lambert alpha:fade // alpha
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Legacy Shaders/Transparent/Cutout/Diffuse" // 그림자 생성
}
```

</details>

<br>

![image](https://user-images.githubusercontent.com/42164422/107126764-1693e700-68f5-11eb-8b6e-cf3033f53247.png){:.normal}

<br>

# 커스텀 알파 블렌딩
---

알파 블렌딩 쉐이더에서는 `Blend` 키워드를 통해 블렌딩 연산 방식을 지정할 수 있다.

그리고 ZWrite는 off로 설정해주고, pragma에 alpha, alpha:fade나 alpha:blend 대신 `keepalpha`를 작성한다.

(유니티 5.0부터 서피스 쉐이더에서는 기본적으로 모든 불투명 쉐이더 알파값이 1.0으로 강제되는데, keepalpha를 쓰면 이것을 막아준다.)

`Blend` 키워드를 통해 커스텀 알파 블렌딩을 지정해도 `keepalpha` 대신 다른 키워드를 pragma에 넣으면 적용되지 않으니 주의한다.

<br>

## 블렌딩 구문

```
Blend SrcAlpha OneMinusSrcAlpha
```

- Blend A B 라고 했을 때, `A * Source + B * Destination` 으로 계산한다.
- `A`, `B` : 블렌딩 팩터
- `Source` : 오브젝트 자신의 픽셀 색상(RGB)
- `Destination` : 배경의 픽셀 색상(RGB)


<br>

## 블렌딩 팩터

|---|---|
|`One`|숫자 1|
|`Zero`|숫자 0|
|`SrcColor`|소스 색상(RGB)|
|`SrcAlpha`|소스 알파|
|`DstColor`|배경 색상|
|`DstAlpha`|배경 알파|
|`OneMinusSrcColor`|1 - 소스 색상|
|`OneMinusSrcAlpha`|1 - 소스 알파|
|`OneMinusDstColor`|1 - 배경 색상|
|`OneMinusDstAlpha`|1 - 배경 알파|

<br>

## 주로 사용되는 블렌딩 구문들

### Alpha Blending
 - `Blend SrcAlpha OneMinusSrcAlpha`

### Additive
 - `Blend SrcAlpha One`

### Additive 2 (Additive No Alpha Black is Transparent)
 - `Blend One One`

### Multiplicative
 - `Blend DstColor Zero`

### 2x Multiplicative
 - `Blend DstColor SrcColor`

<br>
![image](https://user-images.githubusercontent.com/42164422/107146122-7e940d00-6989-11eb-9476-e8df784d9ea0.png){:.normal}

- 모든 쉐이더의 알파값은 0.7로 지정하였다.
- Multiplicative 쉐이더들은 알파 값의 영향을 받지 않는다.

- Alpha Blending, Additive, Additive 2 쉐이더는 Albedo에 텍스쳐 색상을 넣어주었다.
  - `o.Albedo = c.rgb;`

- Multiplicative 쉐이더는 RGB의 까만 영역을 모두 하얗게 바꿔주었다.
  - `o.Emission = lerp(float3(1,1,1), c.rgb, c.a);`

- 2x Multiplicative 쉐이더는 이렇게 작성하여 RGB의 까만 영역을 모두 회색으로 바꿔주었다.
  - `o.Emission = lerp(float3(.5, .5, .5), c.rgb, c.a);`

<br>
### 메인 라이트의 강도를 0 ~ 1사이에서 조정했을 때

![2021_0207_AlphaShaders_LightIntensityChange](https://user-images.githubusercontent.com/42164422/107146211-ff530900-6989-11eb-9bee-ea124986debc.gif){:.normal}

- 모든 쉐이더의 라이팅 함수 : Lambert

- Alpha Blending 쉐이더는 빛이 없으면 색상이 까맣게 변한다.
- Additive, Additive 2 쉐이더는 빛이 없으면 투명해진다.
- Multiplicative, 2x Multiplicative 쉐이더는 Albedo 대신 Emission을 지정하였으므로, 빛의 영향을 받지 않는다.

<br>

# 파티클 쉐이더 만들어보기
---

## 조건
- 빛을 받지 않으므로 빛의 연산이 필요하지 않다.
- 그림자를 받지도, 만들지도 않는다.
- 파티클 색상을 조절할 수 있어야 한다.
- 알파 블렌딩 옵션을 조절할 수 있어야 한다.

<br>
## 소스코드

<details>
<summary markdown="span"> 
Source Code
</summary>

``` hlsl
Shader "Custom/Particle"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 2)) = 1
        _MainTex("Albedo (RGB)", 2D) = "white"{}
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode", Float) = 5 // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend Mode", Float) = 1 // One
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        Blend [_SrcBlend] [_DstBlend]
        Zwrite off
        Cull off

        CGPROGRAM
        #pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow

        sampler2D _MainTex;
        float4 _TintColor;
        float _Intensity;

        struct Input
        {
            float2 uv_MainTex;
            float4 color:COLOR; // Vertex Color
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            c = c * _TintColor * IN.color;
            o.Emission = c.rgb * _Intensity;
            o.Alpha = c.a;
        }

        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
}
```

</details>

<br>

## 설명

```hlsl
_TintColor ("Tint Color", Color) = (1, 1, 1, 1)
_Intensity("Intensity", Range(0, 2)) = 1
```

- _TintColor 값으로 색상을 지정할 수 있게 한다.
- _Intensity 값으로 색상의 강도를 조절할 수 있게 한다.

<br>

```hlsl
[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode", Float) = 5 // SrcAlpha
[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend Mode", Float) = 1 // One

Blend [_SrcBlend] [_DstBlend]
```

- Src, Dst 블렌드 팩터를 마테리얼에서 직접 지정할 수 있게 한다.
- 기본 값은 `Blend SrcAlpha One`

<br>

```hlsl
Cull off
```

- 폴리곤의 양면을 모두 그린다(2-sided mode)

<br>

```hlsl
"IgnoreProjector"="True"
```

- 유니티의 Projector의 영향을 받지 않도록 한다.
- 프로젝터를 안써봐서 솔직히 잘 모르겠다.

<br>

```hlsl
#pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow
```

-> 쉐이더가 만들어지며 자동 생성되는 추가 쉐이더(Variant)들을 최소화하여 쉐이더를 가볍게 해주는 구문들이다.

(**Variant** : 라이트맵, 그림자, 정점조명 등이 있는 경우, 없는 경우를 모두 계산하여 경우에 따라 미리 다르게 만들어 놓는 쉐이더들)<br>

- `nolight` : Lightingnolight 커스텀 라이팅 함수를 지정하여 빛의 연산을 최소화한다.
- `noforawrdadd` : Forward 렌더링 추가 패스를 비활성화하여, 쉐이더의 크기를 줄인다.
- `nolightmap` : 쉐이더에서 모든 라이트맵 지원을 비활성화한다.
- `noambient` : 주변광과 라이트 프로브를 적용하지 않도록 한다.
- `novertexlights` : 정점 라이팅을 비활성화한다.
- `noshadow` : 그림자를 받지 않도록 한다.

이렇게 적용하면 Variants를 엄청 줄여줄 수 있다.

![image](https://user-images.githubusercontent.com/42164422/107154451-5b338700-69b6-11eb-90e9-747a09e69bc6.png){:.normal}

<br>

```hlsl
float4 color:COLOR; // Vertex Color
```

- 버텍스 컬러를 받아온다. 파티클에서 색상을 조정할 수 있게 하려면 꼭 필요하다.

<br>

```hlsl
void surf(Input IN, inout SurfaceOutput o)
{
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
    c = c * _TintColor * IN.color;
    o.Emission = c.rgb * _Intensity;
    o.Alpha = c.a;
}
```

- 텍스쳐 샘플링을 통해 얻은 색상에 _TintColor를 곱해줌으로써 마테리얼에서 지정한 색상을 적용시켜주고, IN.color를 곱해줌으로써 파티클 시스템에서 지정한 색상도 적용시켜준다.
- o.Albedo가 아니라 o.Emission에 rgb값을 지정하여, 라이팅의 영향을 받지 않도록 한다.
- o.Emissiom에 색상을 지정할 때 _Intensity를 곱해줌으로써 마테리얼에서 지정한 색상의 강도를 적용시켜준다.

<br>

```hlsl
float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
{
    return float4(0, 0, 0, s.Alpha);
}
```

- 아무 것도 하지 않는, 그저 껍데기만 있는 아주 가벼운 라이팅 함수
- 이렇게 라이팅 함수가 존재하기는 해야 하기 때문에 넣어준다.

<br>

## 파티클 예시

![2021_0306_ParticleEx](https://user-images.githubusercontent.com/42164422/110201189-2b887980-7ea5-11eb-8a51-d88d8727023e.gif)

- 좌 : 기본 파티클 쉐이더(Standard Unlit) / 우 : 위에서 작성한 쉐이더

<br>

# 깨끗한 알파 블렌딩 쉐이더 만들기
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```hlsl
Shader "Custom/Alpha2Pass"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        /****************************************************************
        *                            Pass 1
        *****************************************************************
        * - Zwrite on
        * - Rendering off (ColorMask 0)
        * - 패스 1의 역할 : 알파 소팅 문제가 발생하지 않도록
        *                   Z버퍼에 기록해주기
        *****************************************************************/
        ZWrite On
        ColorMask 0

        CGPROGRAM
        #pragma surface surf nolight noambient noforwardadd nolightmap novertexlights noshadow

        struct Input
        {
            float4 color:COLOR; // Input을 비워두지 않기 위해 작성
        };

        // 서피스 함수 : 아무 것도 하지 않음
        void surf(Input IN, inout SurfaceOutput o){}

        // 라이팅 함수 : 아무 것도 하지 않음
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,0);
        }
        ENDCG

        /****************************************************************
        *                            Pass 2
        *****************************************************************
        * - Zwrite off
        * - 패스 2 : 메인 패스. 여기서 모든걸 계산. 빛의 영향도 받음
        *****************************************************************/
        ZWrite Off

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        
        sampler2D _MainTex;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        float _Alpha;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    Fallback "Transparent" // 그림자 생성 X
}
```

</details>

<br>

- 패스를 두 개로 나누어 작성한다.
- 첫 번째 패스는 알파 소팅 문제가 발생하지 않도록 Z버퍼에 기록만 해주는 용도로 작성한다.
- 두 번째 패스에서 필요한 모든 것을 계산한다.

<br>

![2021_0208_CustomAlphaRobot](https://user-images.githubusercontent.com/42164422/107155537-51ad1d80-69bc-11eb-863e-3d59c0c5381c.gif){:.normal}

- _Alpha 프로퍼티를 통해 투명도를 조절할 수 있다.
- 두 번째 패스에서 Lambert 라이팅을 적용했기 때문에 빛의 영향도 받는다.

<br>

## 기본 알파 블렌딩 쉐이더와 비교

![image](https://user-images.githubusercontent.com/42164422/107155608-b4061e00-69bc-11eb-8c5c-6c3752e5c321.png){:.normal}

- 좌 : 2 Pass / 우 : 기본

- 내부가 드러나지 않고 깔끔하게 그려지는 것을 볼 수 있다.

<br>

# ZTest와 ZWrite
---

앞서 설명했듯, 오브젝트를 그리는 순서는 렌더 큐에 적힌 값에 따라 결정된다.

예를 들면 불투명은 2000, 스카이박스는 2500, 반투명은 3000이다.

그리고 대부분의 경우에는 렌더 큐의 값이 같으면 무작위 순서로 그리는데, 반투명 오브젝트 만큼은 알파 소팅 과정을 통해 멀리서부터 그린다. (그래서 더 비싸다)

<br>

- 불투명 오브젝트 그리기(무작위)

![image](https://user-images.githubusercontent.com/42164422/109772010-d5b39780-7c40-11eb-83fd-de729c801870.png)

- 반투명 오브젝트 그리기(멀리서부터)

![image](https://user-images.githubusercontent.com/42164422/109771587-545c0500-7c40-11eb-825d-4685c4fe84b3.png)

<br>

그런데 먼저 그린 오브젝트가 나중에 그린 오브젝트에 가려질까? 아니면 반대로 나중에 그린 오브젝트가 먼저 그린 오브젝트에 가려질까?

둘 중 하나가 맞긴 할텐데, 정확히는 둘 다 아니다.

그려진 순서만으로는 어떻게 가릴지 판단하지 못한다.

이걸 판단하기 위해 존재하는 것이 바로 ZBuffer와 ZTest, ZWrite의 개념이다.

<br>

## **ZBuffer**

![image](https://user-images.githubusercontent.com/42164422/109923539-42db3180-7d02-11eb-8b1e-c6152cfcf71d.png)

ZBuffer는 화면의 각 픽셀마다 카메라와 가장 가까운 오브젝트의 표면을 0.0 ~ 1.0 값으로 기록해놓은 텍스쳐이다.

카메라의 Near Plane(뷰 프러스텀 내에서 카메라와 가장 가까운 위치)에 있으면 0.0 값을 갖고,

Far Plane(뷰 프러스텀 내에서 카메라와 가장 먼 위치)에 있으면 1.0 값을 갖는다.


그래서 카메라에 가까운 부분은 새까맣게 보이고, 멀어질수록 점차 하얗게 보인다.

<br>

## **ZWrite**

ZWrite는 오브젝트가 그려질 때 해당 픽셀에 이미 적힌 깊이 값과 자신의 깊이 값을 비교하여, 더 작은 값을 ZBuffer의 해당 픽셀에 기록하는 것을 의미한다.

그렇게 되면 결국 모든 오브젝트의 깊이 값을 기록했을 때 ZBuffer는 픽셀마다 카메라에서 가장 가까운 오브젝트의 깊이 값만을 갖게 된다.

유니티에서는 쉐이더에 `ZWrite On`, `ZWrite Off`를 작성하여 해당 오브젝트의 ZWrite를 수행할지 여부를 결정할 수 있다.

<br>

## **ZTest**

ZTest는 ZRead라고도 한다. 오브젝트가 그려질 때 ZBuffer의 해당 픽셀에 이미 기록된 깊이 값과 자신의 깊이 값을 비교하여, 자신의 픽셀을 화면에 그릴지 결정하게 된다.

유니티에서는 ZTest `Less`, `Greater`, `LEqual`, `GEqual`, `Equal`, `NotEqual`, `Always` 옵션으로 쉐이더에서 해당 오브젝트의 ZTest를 어떻게 수행할지 결정 할 수 있다.

다시 말해, "ZBuffer에 이미 기록된 값에 자신의 깊이 값을 비교하여 자신의 픽셀을 렌더링할지 여부"를 결정하는 연산을 나타낸다.

예를 들어 `Less`일 경우, 해당 픽셀에 존재하는 자신의 깊이 값이 ZBuffer에 기록된 깊이 값보다 작으면(Less) 자신의 픽셀을 화면에 그린다.

그리고 `Always`는 그냥, 그린다. 비교 안하고 아무튼 그냥 자기를 그린다.

<br>

## **Note**

알아둬야 할 점은, 오브젝트를 그릴 때 ZTest를 먼저 수행한 다음에 ZWrite를 한다는 것이다.

<br>

예를 들어 Equal로 비교한다고 해서

"일단 내 깊이 값을 버퍼에 써놓고(ZWrite), ZBuffer 값 읽어와서 내 깊이 값이랑 비교(ZTest) 해야지~"

하고 어라 같네? 하면서 자신을 그려버리는게 아니고,

"일단 쓰여있는 ZBuffer 값을 내 깊이 값이랑 비교해서 그릴지 안그릴지 결정하고(ZTest), 그 이후에 ZBuffer에 내 깊이 값 적어놔야지!(ZWrite)" 

이게 맞다는 것이다.

<br>

그러니까 ZTest에는 자기 자신의 ZWrite가 영향을 미치지 않는다. (중요)

대신, ZWrite에는 ZTest의 결과가 영향을 미친다.

ZTest의 비교 연산이 참의 값을 가져서 자신의 픽셀을 그리는데 성공했을 때, 이를 "ZTest를 통과했다"라고 한다.

반대로, ZTest의 결과가 거짓이라 픽셀을 그리지 못했다면 "ZTest에 실패했다"고 하며

**ZTest를 통과해야 ZWrite를 수행한다.**

<br>

그리고 아무 오브젝트도 ZWrite를 안한 순수한 상태라면 ZBuffer의 모든 값은 1.0이다. (이것도 중요)

<br>

## **ZTest : 하나의 오브젝트를 그릴 때**

ZBuffer에 아무도 쓰지 않았으므로, ZBuffer의 모든 값은 1.0인 상태,

오브젝트의 ZBuffer 값은 0.1 정도라고 가정

- 그려지는 경우 : `Less`, `LEqual`, `NotEqual`, `Always`

![image](https://user-images.githubusercontent.com/42164422/109782310-16fd7480-7c4c-11eb-8e2a-f01b94696946.png)

- 그려지지 않는 경우 : `Equal`, `Greater`, `GEqual`

![image](https://user-images.githubusercontent.com/42164422/109782339-211f7300-7c4c-11eb-8926-9522cd0934fb.png)

<br>

## **ZTest : 여러 개의 오브젝트를 그릴 때**

- ZWrite는 모두 On
- 깊이 값 : 빨강(0.1), 초록(0.2), 파랑(0.3) 이라고 가정
- 빨강, 파랑은 기본 값인 LEqual, 렌더 큐 2000

- **초록색만 ZTest, 렌더 큐(그려지는 순서) 값을 변동시켜 비교한다.**

<br>

### **[1] Less, LEqual**

![image](https://user-images.githubusercontent.com/42164422/109785330-5e393480-7c4f-11eb-8478-954bc3856aa8.png)

그려지는 순서에 관계 없이, 가장 가까운 오브젝트가 먼저 그려진다.

<details>
<summary markdown="span"> 
그래도 자세히 살펴보자면..
</summary>

### (1) 빨 -> 초 -> 파

빨강이 그려질 때 ZBuffer에는 모두 1.0이므로 ZTest를 (0.1 <= 1.0)로 모두 성공하고, ZBuffer에서 빨간색 오브젝트가 존재하는 픽셀들에 0.1을 기록한다.

초록이 그려질 때 ZBuffer에서 빨간색 오브젝트와 겹치는 부분은 0.1이 기록되어 있으므로 ZTest를 (0.2 <= 0.1)로 실패하여 그리지 못하고, 다른 부분은 (0.2 <= 1.0)으로 성공하여, 해당 부분의 ZBuffer에 0.2를 기록한다.

파랑이 그려질 때 ZBuffer의 값은 크게 3가지로 나눌 수 있다.<br>
빨강이 기록해놓은 0.1, 초록이 기록해놓은 0.2, 그 외의 부분은 1.0이다.<br>
따라서 ZTest (0.3 <= 0.1), (0.3 <= 0.2)는 실패하고, (0.3 <= 1.0)은 성공하여 빨강, 초록이 위치하지 않은 픽셀에만 파란색의 픽셀을 그리고 해당 부분의 ZBuffer에 0.3을 기록한다.

<br>

### (2) 파 -> 초 -> 빨

파랑이 그려질 때 ZBuffer에는 모두 1.0이므로 ZTest를 (0.3 <= 1.0)로 모두 성공하고, ZBuffer에서 파란색 오브젝트가 존재하는 픽셀들의 ZBuffer에 0.3을 기록한다.

초록이 그려질 때 ZBuffer의 값은 파랑이 위치한 픽셀의 0.3, 그 외의 부분에는 1.0만 존재하므로 ZTest는 (0.2 <= 0.3), (0.2 <= 1.0)으로 모두 성공하며, 초록이 존재하는 부분의 ZBuffer에 0.2를 기록한다.

빨강이 그려질 때 ZBuffer의 값은 초록(0.2), 파랑(0.3), 나머지(1.0)이므로 ZTest는 (0.1 <= 0.2), (0.1 <= 0.3), (0.1 <= 1.0)으로 모두 성공하며, 빨강이 존재하는 부분의 ZBuffer에 0.1을 기록한다.

<br>

### 기타

초 -> 파 -> 빨, 빨 -> 파 -> 초, ... 등등 모두 결과는 같다.

</details>

<br>

### **[2] Equal**

![image](https://user-images.githubusercontent.com/42164422/109785443-7b6e0300-7c4f-11eb-969e-b9a735fa69b9.png)

그려지는 순서에 관계 없이, 안그려진다.

<br>

### **[3] Greater, GEqual**

![image](https://user-images.githubusercontent.com/42164422/109785694-b8d29080-7c4f-11eb-9e5e-b27c4fde27d7.png)

렌더 큐를 1999로 설정하여 다른 오브젝트보다 먼저 그리는 경우, 그리는 순간에는 아무 것도 없기 때문에

초록색(0.2) < 기본(1.0) 이므로 초록색 오브젝트는 그려지지 않는다. (모든 픽셀에서 ZTest 실패)

ZTest를 모두 실패했으므로, ZWrite를 해도 ZBuffer에 아무것도 쓰지 못한 것이다.

그래서 빨간색과 파란색을 그리는 순간에도 ZBuffer에는 아무 것도 없으므로 빨간색과 파란색은 `LEqual`에 따라, 겹치는 부분에서는 빨간색이 앞에 그려진다.

<br>

![image](https://user-images.githubusercontent.com/42164422/109801607-0a841680-7c62-11eb-9301-e69084c5d9b9.png)

렌더 큐를 2001로 설정하여 다른 오브젝트보다 나중에 그리는 경우,

ZTest를 수행했을 때

빨간색과 겹치는 부분에는 빨간색(0.1) < 초록색(0.2) 이므로 초록색을 그린다.

파란색과 겹치는 부분에는 파란색(0.3) > 초록색(0.2) 이므로 그려지지 않는다.

다른 오브젝트와 겹치지 않는 부분에는 기본(1.0) > 초록색(0.2)이므로 그려지지 않는다.

<br>

### **[4] Not Equal, Always**

![image](https://user-images.githubusercontent.com/42164422/109801758-428b5980-7c62-11eb-97ca-162327f8db65.png)

렌더 큐를 1999로 설정하여 다른 오브젝트보다 먼저 그리는 경우,

Not Equal에서는 0.2 != 1.0이므로 그려지고, Always에서는 판단하지 않고 무조건 그린다.

그리고 뒤늦게 그려지는 오브젝트들의 판단에 따라 가려지거나 앞에 보이게 된다.

그러니까 일단 무조건 그려지지만, 가려질지 여부는 더 늦게 그려지는 오브젝트의 판단에 따른다.

<br>

![image](https://user-images.githubusercontent.com/42164422/109802098-b75e9380-7c62-11eb-9bc0-a04a24e2c0ab.png)

렌더 큐를 2001로 설정하여 다른 오브젝트보다 나중에 그리는 경우,

Not Equal에서는 ZBuffer에 완전히 같은 깊이 값이 존재하지 않으면 그려지므로, 이 경우에는 무조건 그려지고

Always에서는 그냥 무조건 앞에 그려진다.

결국 렌더 큐의 값이 같을 때 운좋게 나중에 그려지거나, 렌더 큐의 값이 커서 나중에 그려지게 되는 경우, '무조건' 맨 앞에 그려진다.

심지어 Transparent+1 (3001)로 설정하면 반투명도 무시하고 그냥 무대뽀로 맨 앞에 그릴 수 있다.

![image](https://user-images.githubusercontent.com/42164422/109803529-7ff0e680-7c64-11eb-983e-cbc7211241ad.png)

위 그림이 바로 ZTest `Always`/`Not Equal`, 렌더 큐 3001로 설정한 상태.

<br>

그리고 Not Equal을 이용하여 독특한 연출을 할 수 있는데,

초록색은 Geometry+1(2001), ZTest `Not Equal`로 놓은 상태에서

하얀색 오브젝트를 만들어 Geometry(2000), 동일한 크기, 동일한 위치로 놓고, ZTest `LEqual`로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/109803805-d6f6bb80-7c64-11eb-9792-7c4792e5868b.png)

ZBuffer에 자신과 같은 깊이 값이 이미 존재하면 자신은 그려지지 않는다는 점을 이용해서

앞의 빨간색으로 가려진 부분은 빨간색(0.1) != 초록색(0.2) 이므로 초록색이 그려지고,

가려지지 않은 부분은 하얀색이 먼저 ZBuffer에 기록해 놓았으므로 하얀색(0.2) == 초록색(0.2) 이므로

초록색이 그려지지 않게 되어 먼저 그려졌던 하얀색이 그대로 화면에 보이게 된다.

<br>

## **ZWrite Off**

기본적으로 불투명 쉐이더는 ZWrite On, ZTest LEqual로 설정된다.

여기에서 초록색 오브젝트의 ZWrite만 off하고, 렌더링 순서를 바꿨을 때를 살펴본다.

<br>

렌더 큐 2000인 경우(다른 오브젝트들과 동일)

![2021_0303_ZWriteOff](https://user-images.githubusercontent.com/42164422/109813375-9d2bb200-7c70-11eb-826e-484e28047c6e.gif)

같은 렌더 큐 값을 갖는 불투명 오브젝트는 무작위로 그려지므로, 앞에 그려질지 뒤에 그려질지 확신할 수 없다.

<br>

렌더 큐 1999인 경우(먼저 그려지는 경우)

![image](https://user-images.githubusercontent.com/42164422/109814107-6f933880-7c71-11eb-82a8-89508b5fff8e.png)

초록색이 먼저 ZTest를 수행하여 화면에 그려지고, ZWrite Off이므로 ZBuffer에는 모두 1.0으로 깨끗한 상태이다.

이 상태에서 빨간색과 파란색은 ZTest를 LEqual로 판단하여 무조건 초록색보다는 앞에 그려지게 된다.

<br>

렌더 큐 2001인 경우(나중에 그려지는 경우)

![image](https://user-images.githubusercontent.com/42164422/109924893-54253d80-7d04-11eb-8f11-013b5fb2cc1b.png)

초록색을 그리는 상황에는 이미 빨간색, 파란색이 자신들의 깊이 값을 ZBuffer에 기록해놓은 상태이다.

이 상태에서 초록색은 ZTest를 LEqual로 판단하여 정상적으로 빨강과 파랑 사이에 그려지고,

초록 이후에 그려지는 것이 없으므로 ZWrite 여부는 딱히 의미 없게 된다.


<br>

# 알파 블렌딩 쉐이더에서 발생하는 문제점들
---

위에서 간간히 언급한, 순수한 알파 블렌딩 쉐이더에서 알파 소팅으로 인해 발생하는 문제점들을 한군데 모아서 정리해본다.

<br>

## **[1] 오브젝트 내부가 드러나는 문제**

![image](https://user-images.githubusercontent.com/42164422/109829364-c9e7c580-7c80-11eb-9d50-4469635ef080.png)

- 해결책 : 2Pass (ZWrite Pass + Main Pass) 쉐이더를 사용하면 된다!

![image](https://user-images.githubusercontent.com/42164422/109829542-f8fe3700-7c80-11eb-9716-69c8954ecb92.png)

<br>

## **[2] 다른 반투명 오브젝트를 완전히 가리는 문제**

![2021_0304_AlphaOverwrite](https://user-images.githubusercontent.com/42164422/109831526-dd942b80-7c82-11eb-8e83-f5894c46bc0f.gif)

알파소팅을 하는 근본적인 이유가 바로 이 현상을 해결하기 위함인데, 카메라의 회전에 따라 아직도 발생하는 문제이다.


`keepalpha`로 지정하고, 커스텀 알파 블렌딩을 했을 경우 발생한다.

알파 소팅 방식에 따라 피벗 지점이 카메라로부터 멀리 있는 오브젝트부터 그려내는데,

픽셀 상으로 가까이 있는 것(초록색 풀)이 피벗 거리는 더 멀리 있다고 판정될 때 위처럼 된다.


알파 소팅에 의해 초록색 풀을 먼저 그리고 ZWrite로 초록색 풀의 모든 픽셀(완전히 투명한 부분 포함)을 ZBuffer에 기록한 상태에서

빨간색 풀의 ZTest를 할 때, 초록색 풀과 겹치는 부분에서는 당연히 초록색 풀의 픽셀이 더 가까이 있으니까

ZTest `LEqual`로 비교했을 때 초록색 풀 < 빨간색 풀이므로 ZTest를 실패하여 빨간색 풀은 그려지지 않는다.

결국 "피벗은 더 멀리 있는데 픽셀은 더 가까이 있는" 어이없는 현상에 의해 발생하는 문제.

<br>

해결책은 여러 가지가 있는데,

### (1) 알파값이 필요 없다면, 알파 테스팅을 사용한다.
  - 투명도가 필요하다면 사용할 수 없는 방법이다.
  - 외곽선이 거칠어보이는 단점이 있다.

### (2) 오브젝트를 잘게 쪼갠다.
  - 당연히 성능에 더 큰 부하가 생기므로, 여유가 있을 때 사용한다.

### (3) 렌더링 레이어를 나눈다.
  - 오브젝트의 종류에 따라서 지형지물, 물, 이펙트, ... 등으로 나누어, 같은 반투명 오브젝트라도 그려질 순서를 크게 나눈다.
  - 쉽게 말해, 렌더 큐의 숫자를 바꾸는 것처럼 그려질 순서를 아예 다르게 지정하여 알파 소팅 문제를 근본적으로 회피하는 방법이다.

  - 장점 : 서로 다른 레이어간의 문제점은 완벽하게 해결할 수 있다.
  - 단점 : 같은 레이어 내에서는 전혀 해결할 수 없다.

### (4) ZWrite를 Off로 지정한다.
  - 반투명 오브젝트가 모두 ZWrite를 하지 않게 함으로써, ZTest를 할 때 뒤늦게 그려지는 오브젝트가 무조건 앞에 보이게 한다.
  - 완전히 가리는 문제는 해결할 수 있지만, 또다른 문제가 발생한다. ([3]에서 계속)

### (5) ZTest를 Always로 지정한다.
  - 반투명 쉐이더'만' 그린다면, 혹은 반투명 앞에 불투명 오브젝트가 존재하지 않는다면 (4)와 같은 결과를 낼 수 있는 해결 방법.
  - 하지만 자신의 렌더큐보다 작은 값을 갖는 오브젝트와 겹치면 무조건 자신이 앞에 그려지는 대참사가 일어날 수 있다.
  - 사실상 해결책이라고 하긴 힘들다.

<br>

## **[3] 뒤에 있는 오브젝트가 앞에 그려지는 문제**

알파 블렌딩 쉐이더(keepalpha)에서 위의 [2]-(4), [2]-(5)를 통해 완전히 가리는 문제를 해결했을 때,

그리고 쉐이더에 alpha:fade, alpha:blend라고 작성했을 때 여전히 발생하는 문제이다.

알파 블렌딩과 알파 소팅을 사용하는 이상 해결할 수 없는 문제이기도 하다.

![2021_0304_AlphaSortingBug](https://user-images.githubusercontent.com/42164422/109831535-dec55880-7c82-11eb-991b-7dcf6fd6361f.gif)

카메라의 회전에 따라 뒤에 있는 오브젝트가 앞의 오브젝트를 가리는 문제.

원인은 [2]와 같이 "피벗은 더 멀리 있는데 픽셀은 더 가까이 있는 경우"이다.

초록색 오브젝트의 피벗이 더 멀리 있어서 알파 소팅에 의해 먼저 그리게 되어 빨간색 오브젝트가 초록색 오브젝트를 가리는데, 실제로는 초록색 오브젝트가 더 가까이 있으므로 발생하는 문제이다.

이를 완전히 해결하려면 [2]-(3)처럼 렌더링 레이어를 나누거나 알파 테스팅을 사용해야 하는데

모두 제약조건이 있으므로, 해당하지 않는 경우에는 아예 해결이 불가능하다.

<br>

## **[4] 겹친 부분의 색상이 시점에 따라 다르게 보이는 문제**

역시 알파 소팅 문제를 근본적으로 해결할 수 없는 한 언제나 발생하는 문제 중 하나.

![2021_0304_AlphaBlendingColorChange](https://user-images.githubusercontent.com/42164422/109846999-17206300-7c92-11eb-83d4-a1475c3e345d.gif)

블렌딩 구문은 `Blend SrcAlpha OneMinusSrcAlpha`로 설정된 상태.

겹친 부분의 색상이 파란색의 피벗이 더 가까이 있을 때는 '파란 보라색'으로, 빨간색의 피벗이 더 가까이 있을 때는 '빨간 보라색'으로 보인다.

이 문제는 그래도 Additive 또는 Multiplicative 종류의 구문을 사용하면 해결할 수 있다.

<br>

- Additive (`Blend SrcAlpha One`) :

![2021_0304_AlphaBlending_Additive](https://user-images.githubusercontent.com/42164422/109849530-d413bf00-7c94-11eb-8af2-275235b7e115.gif)

- Multiplicative (`Blend DstColor SrcColor`) :

![2021_0304_AlphaBlending_Multiplicative](https://user-images.githubusercontent.com/42164422/109849541-d544ec00-7c94-11eb-8f33-ed3b6299235d.gif)

<br>

# 스텐실
---

스텐실 버퍼는 오브젝트의 픽셀을 화면에 그리거나 그리지 않도록 판단하기 위한 마스크 용도로 사용된다.

스텐실 버퍼의 모든 값은 8비트(0 ~ 255)의 값을 가지며, 기본적으로 0으로 초기화되어 있다.

<br>

ZBuffer에 깊이 값을 ZTest로 읽고 ZWrite로 쓰는 것처럼,

쉐이더가 가진 스텐실 레퍼런스 값을 스텐실 버퍼에 읽고 쓰며, 스텐실 테스트를 할 때 해당 픽셀에서 스텐실 버퍼가 가진 값과 쉐이더가 가진 값을 비교하여 해당 픽셀을 그릴지 여부를 결정할 수 있다.

<br>

## **스텐실 테스트 과정**

스텐실 테스트는 ZTest와 마찬가지로, 렌더링 순서에 따라 먼저 그려진 오브젝트에 먼저 수행된다.

그리고 테스트 과정은 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/110202240-a43e0480-7eaa-11eb-9426-0fd1fd952786.png)

- [1] 스텐실 테스트(`Comp`) : 스텐실 버퍼의 값을 읽어, 자신의 Ref 값과 비교

- [2-1] 스텐실 테스트 실패 시 `Fail` 동작 수행 => 종료

- [2-2] 스텐실 테스트 성공 시 깊이 테스트(ZTest)

- [3-1] 스텐실 테스트, ZTest 모두 성공 시 `Pass` 동작 수행 => 종료

- [3-2] 스텐실 테스트 성공, ZTest 실패 시 `ZFail` 동작 수행 => 종료

<br>

스텐실 테스트를 실패하면 ZTest를 안하는 것일까?

그렇다.

<br>

## **스텐실 구문**

스텐실 구문은 `Stencil {}`로 감싸며, `Ref`, `ReadMask`, `WriteMask`, `Comp`, `Pass`, `Fail`, `ZFail`로 이루어져 있다.

명시적으로 작성하지 않은 구문은 디폴트 값이 사용된다.

|구문|설명|값의 범위|기본 값|
|---|---|---|---|
|`Ref`|쉐이더가 가질 레퍼런스 값|0 ~ 255|0|
|`ReadMask`|버퍼에서 읽을 값의 최대치.<br>지정된 값보다 큰 값이 버퍼에 적혀있으면 읽지 않고 무시한다.|0 ~ 255|255|
|`WriteMask`|버퍼에 쓸 값의 최대치.<br>지정된 값보다 큰 값은 버퍼에 쓰지 않는다.|0 ~ 255|255|
|`Comp`|버퍼에 이미 적힌 값과 쉐이더의 Ref 값을 비교할 때<br>사용할 연산의 종류를 지정한다.|후술|Always|
|`Pass`|스텐실, Z 테스트를 모두 통과한다면<br>버퍼의 값을 어떻게 할지 지정한다.|후술|Keep|
|`Fail`|스텐실 테스트가 실패하면<br>버퍼의 값을 어떻게 할지 지정한다.|후술|Keep|
|`Zfail`|스텐실 테스트를 통과했으나 Z 테스트를 실패하면<br>버퍼의 값을 어떻게 할지 지정한다.|후술|Keep|

## **비교 함수(`Comp`)**

|종류|설명|
|---|---|
|`Never`|스텐실 테스트를 항상 실패하도록 만든다.|
|`Always`|스텐실 테스트를 항상 성공하도록 만든다.|
|`Greater`|(쉐이더 Ref 값 > 버퍼 값)인 픽셀만 화면에 그린다.|
|`GEqual`|(쉐이더 Ref 값 >= 버퍼 값)인 픽셀만 화면에 그린다.|
|`Less`|(쉐이더 Ref 값 < 버퍼 값)인 픽셀만 화면에 그린다.|
|`LEqual`|(쉐이더 Ref 값 <= 버퍼 값)인 픽셀만 화면에 그린다.|
|`Equal`|(쉐이더 Ref 값 == 버퍼 값)인 픽셀만 화면에 그린다.|
|`NotEqual`|(쉐이더 Ref 값 != 버퍼 값)인 픽셀만 화면에 그린다.|

## **스텐실 동작(`Pass`, `Fail`, `ZFail`)**

|종류|설명|
|---|---|
|`Keep`|버퍼의 현재 값을 유지한다.|
|`Zero`|버퍼에 0을 작성한다.|
|`Replace`|버퍼에 쉐이더 Ref 값을 작성한다.|
|`IncrSat`|버퍼의 값을 1 증가시킨다. (최대 255)|
|`DecrSat`|버퍼의 값을 1 감소시킨다. (최소 0)|
|`Invert`|버퍼의 모든 비트(8비트)를 반전시킨다.|
|`IncrWrap`|버퍼의 값을 1 증가시키며,<br>이미 255이면 0으로 바꾼다.|
|`DecrWrap`|버퍼의 값을 1 감소시키며,<br>이미 0이면 255로 바꾼다.|

<br>

## **스텐실의 대표적인 활용**

## **[1] 마스킹**

- 특정 오브젝트(마스크)에게 가려진 경우에만 보이게 한다.

![2021_0304_Stencil01](https://user-images.githubusercontent.com/42164422/109963895-48e80700-7d30-11eb-8de2-8ec9ff401f36.gif)

<br>

### **타겟 오브젝트**
 - 마스크에게 가려져야 보이는 오브젝트
 - 마스크가 카메라와 이 오브젝트 사이에 있어야 보인다.

```hlsl
Stencil
{
    Ref 1      // 1번으로 설정
    Comp Equal // 버퍼 값이 1인 픽셀에만 그린다
}
```

<details>
<summary markdown="span"> 
StencilTarget01.shader
</summary>

```hlsl
Shader "Custom/StencilTarget01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Stencil
        {
            Ref 1
            Comp Equal // 스텐실 버퍼가 1인 곳에만 렌더링
        }

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

```

</details>

<br>

### **마스크 (1)**
 - 마스크 뒤에 대상 오브젝트가 있으면 보이게 한다.
 - 마스크 오브젝트를 화면에 렌더링하지 않는다.
 - 항상 대상보다 먼저 그려져야 하므로 렌더큐 1999번(Geometry-1)에 렌더링한다.

```hlsl
Stencil
{
    Ref 1        // 1번으로 설정
    Comp Never   // 이녀석은 절대 안그린다
    Fail Replace // 못그린 픽셀에는 버퍼에 1을 기록한다
}
```

<details>
<summary markdown="span"> 
StencilMask01.shader
</summary>

```hlsl
Shader "Custom/StencilMask01"
{
    Properties {}
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque"
            "Queue"="Geometry-1" // 반드시 대상보다 먼저 그려져야 하므로
        }

        Stencil
        {
            Ref 1
            Comp Never   // 항상 렌더링 하지 않음
            Fail Replace // 렌더링 실패한 부분의 스텐실 버퍼에 1을 채움
        }

        CGPROGRAM
        #pragma surface surf nolight noforwardadd nolightmap noambient novertexlights noshadow

        struct Input { float4 color:COLOR; };

        void surf (Input IN, inout SurfaceOutput o){}
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, 0);
        }
        ENDCG
    }
    FallBack ""
}
```

</details>

<br>

### **마스크 (2)**

 - 위의 마스킹 기능을 하면서, 동시에 마스크 오브젝트도 반투명으로 렌더링하려 했지만
 - 유니티 쉐이더는 하나의 쉐이더에 렌더 큐를 여러 개 지정할 수 없다.
 - 따라서 마스크 오브젝트에 마테리얼을 2개 사용해서 첫 번째는 위의 마스크, 두 번째에는 반투명 마테리얼을 사용하였다.

![2021_0304_Stencil01_MultiMat](https://user-images.githubusercontent.com/42164422/109963857-3c63ae80-7d30-11eb-8893-5e1767fd1349.gif)

<br>

## **[2] 실루엣**

 - 가려지지 않은 경우에는 정상적으로 렌더링한다.
 - (다른 모든 오브젝트에게) 가려진 경우에는 단색의 실루엣을 보여준다.

![2021_0304_Stencil02](https://user-images.githubusercontent.com/42164422/109963897-49809d80-7d30-11eb-8fbc-d2e6e32b21e8.gif)

<br>

### **패스 1**
 - 일반적인 Opaque로 렌더링한다.
 - 스텐실 버퍼에 값을 기록한다.

## **패스 2**
 - ZWrite는 필요 없으므로 하지 않는다.
 - 가려진 경우에만 렌더링한다. (ZTest Greater)
 - 패스 1에서 이미 렌더링된 부분(Ref 2)에는 실루엣을 그리지 않도록 스텐실을 설정한다. (Comp NotEqual)

<br>

<details>
<summary markdown="span"> 
Silhouette.shader
</summary>

```cs
Shader "Custom/Silhouette"
{
    Properties
    {
        _SilhouetteColor ("Silhouette Color", Color) = (1, 0, 0, 0.5)

        [Space]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        /****************************************************************
        *                            Pass 1
        *****************************************************************
        * - 메인 패스
        * - 스텐실 버퍼에 Ref 2 기록
        *****************************************************************/
        ZWrite On

        Stencil
        {
            Ref 2
            Pass Replace // Stencil, Z Test 모두 성공한 부분에 2 기록
        }

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0
        
        fixed4 _Color;
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG

        /****************************************************************
        *                            Pass 2
        *****************************************************************
        * - Zwrite off
        * - ZTest Greater : 다른 물체에 가려진 부분에 단색 실루엣 렌더링
        * - Stencil NotEqual : 다른 실루엣이 그려진 부분에 덮어쓰지 않기
        *****************************************************************/
        ZWrite Off
        ZTest Greater // 가려진 부분에 항상 그린다

        Stencil
        {
            Ref 2
            Comp NotEqual // 패스 1에서 렌더링 성공한 부분에는 그리지 않도록 한다
        }

        CGPROGRAM
        #pragma surface surf nolight alpha:fade noforwardadd nolightmap noambient novertexlights noshadow
        
        struct Input { float4 color:COLOR; };
        float4 _SilhouetteColor;
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = _SilhouetteColor.rgb;
            o.Alpha = _SilhouetteColor.a;
        }
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(s.Emission, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

</details>

<br>

# References
---
- 정종필, 테크니컬 아티스트를 위한 유니티 쉐이더 스타트업, 비엘북스, 2017
- <https://m.blog.naver.com/plasticbag0/221299492724>
- <https://docs.unity3d.com/kr/2019.4/Manual/SL-Stencil.html>