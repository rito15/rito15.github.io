---
title: 유니티 투명 쉐이더와 스텐실 개념 익히기 [작성 중]
author: Rito15
date: 2021-02-06 01:29:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, transparent, alpha, stencil]
math: true
mermaid: true
---

# 불투명과 투명
---

**불투명(Opaque)**과 **투명(Transparent)** 오브젝트는 그려지는 타이밍도, 그리기 위한 고려사항도 다르다.

유니티에서는 오브젝트를 렌더링하는 순서를 **렌더 큐(Render Queue)**를 통해 정수 값으로 지정하는데, 
지정한 값이 작은 순서대로 그리게 되며 기본적으로 Opaque는 **2000**, Transparent는 **3000**의 값을 가진다.

따라서 불투명 오브젝트가 전부 그려진 후에 투명 오브젝트가 그려진다.

<br>

## **Z-buffer**

카메라로부터 픽셀마다 가장 가까운 오브젝트까지의 거리를 (0.0 ~ 1.0) 값으로 기록해놓는 버퍼.

**깊이 버퍼(Depth Buffer)**라고도 한다.

![image](https://user-images.githubusercontent.com/42164422/107067589-d49a7080-6822-11eb-95d0-f8b4a103bece.png){:.normal}

<br>

## **불투명(Opaque)**

![image](https://user-images.githubusercontent.com/42164422/107073497-cfd9ba80-682a-11eb-922e-9766ea42556f.png){:.normal}

불투명 오브젝트를 그리기 위해서 우선 Z버퍼를 참조한다.
각각의 픽셀마다 얻어낸 Z버퍼의 값을 통해 겹쳐 있는 픽셀들 중 가장 가까운 오브젝트의 픽셀만 화면에 그리게 되는데, 이를 **Z Test**(Z Read)라고 한다.

따라서 불투명을 그릴 때는 해당 픽셀에서 가장 앞에 있는 오브젝트의 픽셀만 그리고 뒤에 있는 픽셀은 그리지 않음으로써 자원을 절약하게 된다.

### **+ 만약 동일한 Z 값을 가진다면?**

![image](https://user-images.githubusercontent.com/42164422/107071993-e2eb8b00-6828-11eb-8f76-6ea2fdef82e0.png){:.normal}

어떤 것을 먼저 그릴지 알 수 없으므로 위처럼 보이게 되며, 이를 **Z fighting**이라고 한다.

<br>

## **투명(Transparent)**

![image](https://user-images.githubusercontent.com/42164422/107073835-34951500-682b-11eb-843c-c78fb555b9c6.png){:.normal}

투명 오브젝트는 모든 불투명 오브젝트가 그려진 뒤에 그려진다.

앞에서 불투명 오브젝트가 가리지 않는 이상 투명 오브젝트는 겹쳐 있는 부분을 전부 그려야 하기 때문에, 불투명 오브젝트의 계산을 모두 끝내고 투명 오브젝트를 계산하게 되는 것이다.

따라서 같은 픽셀에 존재하는 모든 투명 오브젝트의 픽셀들은 전부 화면에 그려지며, 이를 **오버드로우(Overdraw)**라고 한다.

<br>

# 알파 블렌딩, 알파 소팅
---

겹쳐 있는 투명 오브젝트의 픽셀들은 서로 섞여 최종적으로 화면에 그려지는데, 이를 **알파 블렌딩(Alpha Blending)**이라고 한다.

투명 쉐이더는 기본적으로 알파 블렌딩 쉐이더라고 부른다.

그리고 투명 오브젝트는 불투명 오브젝트와 다르게 멀리 있는 것부터 그려지는데, 이를 **알파 소팅(Alpha Sorting)**이라고 한다.

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

기본적으로 알파 블렌딩 쉐이더를 만들려면,

- Tags의 RenderType과 Queue를 `"Transparent"`로 작성한다.
- pragma에 `alpha:fade` 또는 `alpha:blend`라고 작성한다.
- 투명 오브젝트는 그림자가 없는 것이 당연하므로, Fallback은 `"Transparent"`로 작성한다.<br>
  (Fallback에 지정한 쉐이더가 그림자의 생성에 영향을 준다.)

![2021_0206_Grass](https://user-images.githubusercontent.com/42164422/107119845-7aa2b500-68cd-11eb-89d6-75ff0a3e6ccd.gif){:.normal}

알파 소팅은 카메라에서 각 오브젝트의 피벗까지의 거리값을 기반으로 하기 때문에, 카메라 시점이 회전함에 따라 뒤에 있던 오브젝트가 불쑥 튀어나오는 현상이 발생한다.

이는 고질적인 문제로, 순수한 알파 블렌딩 쉐이더에서는 해결할 수 없다.

<br>

![2021_0206_Grass_Zwriteon](https://user-images.githubusercontent.com/42164422/107127187-c0747300-68f7-11eb-9ad8-bc5815e6ec44.gif){:.normal}

그리고 위와 같은 문제가 발생할 수 있는데, `ZWrite off`를 적어주면 해결할 수 있다.

따라서 알파 블렌딩 쉐이더에서는 기본적으로 Tags 밑에 ZWrite off를 적어준다.

<br>

# 알파 테스팅
---

DirectX에서는 **알파 테스팅(Alpha Testing)**, OpenGL에서는 **컷아웃(Cutout)**이라고 부르며, 유니티에서도 컷아웃이라고 부른다.

(그런데 키워드로는 AlphaTest를 쓰고, 기본 프로퍼티명은 _Cutoff라고 쓴다...)

알파 테스팅 쉐이더는 지정한 Cutoff 값보다 큰 알파값을 가지는 부분만 그려주고, 작은 값을 가지는 부분은 잘라낸다.

알파 테스팅 쉐이더에서는 알파 소팅에서 발생하는 문제(시점을 돌리면 뒤에 있던 오브젝트가 불쑥 튀어나오는 문제)가 발생하지 않는다.

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

- Tags의 RenderType은 딱히 상관 없지만 Queue는 꼭 `"AlphaTest"`로 해준다.
- 프로퍼티에 컷아웃 변수를 하나 만들어주고(이름은 꼭 _Cutoff), pragma에서 `alphatest:_Cutoff`로 연결해준다.
- pragma에 `addshadow`를 추가해주지 않으면 쿼드의 그림자가 네모네모하게 나온다.
- Fallback도 그림자 생성에 관여하므로, 위처럼 작성해야 한다.

<br>

- addshadow 대신, `_Color` 프로퍼티를 추가해주는 방법이 있다.
- _Color 프로퍼티를 그저 넣어주기만 하면 그림자 생성에 영향을 준다.

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

![2021_0206_Grass_Alphatest](https://user-images.githubusercontent.com/42164422/107126350-af753300-68f2-11eb-8a9a-cf0b84053af5.gif){:.normal}

알파 테스팅 쉐이더는 알파 소팅의 불쑥 튀어나오는 문제가 발생하지 않고, 알파 블렌딩에 비해 가볍다는 장점이 있다.

하지만 알파 블렌딩에 비해 외곽선이 자글자글하고 거칠게 잘려 보인다는 단점이 있다.

<br>

## 번외 : 알파 블렌딩 쉐이더에서 그림자 생성하기

- 알파 테스팅 쉐이더에서 그림자를 생성하는 방식을 이용하면 알파 블렌딩 쉐이더에서도 그림자를 생성할 수 있다.

  (하지만 그림자를 받지는 않는다. 다시 말해, Cast Shadow는 동작하지만 Receive Shadow는 동작하지 않는다.)

- 알파 소팅 문제가 발생하지만, 외곽선이 알파 테스팅 쉐이더보다 훨씬 부드럽다는 장점이 있다.

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

![image](https://user-images.githubusercontent.com/42164422/107126764-1693e700-68f5-11eb-8b6e-cf3033f53247.png){:.normal}

<br>

# 커스텀 알파 블렌딩
---

알파 블렌딩 쉐이더에서는 `Blend` 키워드를 통해 블렌딩 연산 방식을 지정할 수 있다.

그리고 ZWrite는 off로 설정해주고, pragma에 alpha:fade나 alpha:blend 대신 `keepalpha`를 작성한다.

(유니티 5.0부터 서피스 쉐이더에서는 기본적으로 모든 불투명 쉐이더 알파값이 1.0으로 강제되는데, keepalpha를 쓰면 이것을 막아준다.)

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

``` hlsl
Shader "Custom/Particle"
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

- 폴리곤의 양면을 모두 그린다(2 sided mode)

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

**[1] 위에서 작성한 쉐이더 사용**

![2021_0208_CustomParticle](https://user-images.githubusercontent.com/42164422/107153835-ee6abd80-69b2-11eb-806f-7bbdc7673b42.gif){:.normal}

<br>
**[2] 유니티 기본 파티클 쉐이더 사용**

![2021_0208_DefaultParticle](https://user-images.githubusercontent.com/42164422/107153836-f0cd1780-69b2-11eb-8144-80e7d40f4e72.gif){:.normal}

<br>

# 깨끗한 알파 블렌딩 쉐이더 만들기
---

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

- 알파 소팅 문제가 발생하지 않아 깔끔하다.

<br>

# 스텐실
---
- 

<br>

# References
---
- 정종필, 테크니컬 아티스트를 위한 유니티 쉐이더 스타트업, 비엘북스, 2017
- <https://m.blog.naver.com/plasticbag0/221299492724>