---
title: 유니티 투명 쉐이더와 스텐실 개념
author: Rito15
date: 2021-02-06 01:29:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, transparent, stencil]
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

알파 블렌딩 쉐이더에서는 `blend` 키워드를 통해 블렌딩 연산 방식을 지정할 수 있다.

그리고 ZWrite는 off로 설정해주고, pragma에 alpha:fade나 alpha:blend 대신 `keepalpha`를 작성한다.

(유니티 5.0부터 서피스 쉐이더에서는 기본적으로 모든 불투명 쉐이더 알파값이 1.0으로 강제되는데, keepalpha를 쓰면 이것을 막아준다.)

<br>

## 블렌딩 구문

```
blend SrcAlpha OneMinusSrcAlpha
```

- blend A B 라고 했을 때, `A * Source + B * Destination` 으로 계산한다.
- `A`, `B` : 블렌딩 팩터
- `Source` : 오브젝트 자신의 픽셀
- `Destination` : 배경의 픽셀


<br>

## 블렌딩 팩터

|---|---|
|`One`|숫자 1|
|`Zero`|숫자 0|
|`SrcColor`|소스 색상|
|`SrcAlpha`|소스 알파|
|`DstColor`|배경 색상|
|`DstAlpha`|배경 알파|
|`OneMinusSrcColor`|1 - 소스 색상|
|`OneMinusSrcAlpha`|1 - 소스 알파|
|`OneMinusDstColor`|1 - 배경 색상|
|`OneMinusDstAlpha`|1 - 배경 알파|


<br>

## 블렌딩 구문 예시



<br>

# 깨끗한 알파 블렌딩 쉐이더 만들기
---



<br>

# 스텐실
---
- 

<br>

# References
---
- 정종필, 테크니컬 아티스트를 위한 유니티 쉐이더 스타트업, 비엘북스, 2017
- <https://m.blog.naver.com/plasticbag0/221299492724>