---
title: 유니티 - Vert/Frag 쉐이더에서 Receive Shadow, Cast Shadow 구현하기
author: Rito15
date: 2021-10-07 00:01:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, shader]
math: true
mermaid: true
---

# Surface Shader
---
- 쉐이더를 빠르게 작성할 수 있도록 다양한 편의를 제공한다.
- Surface 쉐이더 함수는 `#pragma surface Surface쉐이더함수명`으로 등록한다.
- 미리 만들어진 라이팅을 간편히 적용할 수 있다.
- 커스텀 라이트를 작성하는 것도 어렵지 않다.
- Receive Shadow, Cast Shadow는 자동으로 적용된다.
- Surface 쉐이더 함수는 기본적으로 Fragment 쉐이더 함수에 대응되며, 필요하다면 Vertex 쉐이더 함수를 따로 추가할 수 있다.

<br>


<details>
<summary markdown="span"> 
Surface Shader Example
</summary>

```hlsl
Shader "Custom/BasicSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
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
        ENDCG
    }
    FallBack "Diffuse"
}
```

</details>

<br>




# Vertex/Fragment Shader
---
- 대부분의 구현을 직접 해야 한다.
- Vertex, Fragment 쉐이더 함수는 각각 `#pragma vert Vertex쉐이더함수명` `#pragma frag Fragment쉐이더함수명`으로 등록한다.
- 라이팅 계산은 Vertex 또는 Fragment 쉐이더 함수 내에서 직접 해야 한다.
- Receive Shadow, Cast Shadow 역시 직접 해야 하며, 특히 Cast Shadow는 패스를 추가하여 작성해야 한다.

<details>
<summary markdown="span"> 
Vertex/Fragment Shader Example
</summary>

```hlsl
Shader "Custom/BasicVertFragShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
```

</details>

<br>

# 1. Receive Shadow 구현하기
---
- 위의 기본 Vertex/Fragment 쉐이더에 추가하여 작성한다.
- 그림자는 스크린 스페이스를 기반으로 생성된다.

<br>

## **[1] LightMode : ForwardBase 추가**

`"LightMode"="ForwardBase"` 태그를 선언하면 포워드 렌더링에서 동작하도록 하며, Ambient, Directional Light, Vertex Light, SH(Spherical Harmonic) Light를 받을 수 있으며 라이트맵이 적용된다.

추후 **Cast Shadow**를 다른 패스에 구현해야 하므로, 메인 패스에만 영향을 받도록 `Tags{}`를 `Pass` 내부에 집어넣는다.

```hlsl
Pass
{
    Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
    
    //...
}
```

<br>

포워드 렌더링 모드에서 작동하기 위한 Shader Variant를 추가하기 위해, `#pragma multi_compile_fwdbase`를 선언해준다.

불필요한 라이트맵, 버텍스 라이트 등에 영향 받지 않도록 `nolightmap nodirlightmap nodynlightmap novertexlight`를 함께 선언한다.

```hlsl
#pragma multi_complie_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
```

<br>

## **[2] Include cginc Files**

유니티에서 미리 만들어진 라이팅 기능들을 사용하기 위해, `.cginc` 파일들을 가져온다.

```hlsl
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
```

<br>

## **[3] v2f 구조체 정의**

반드시 정점 위치 변수의 이름은 `pos`로 해야만 한다.

`TRANSFER_SHADOW()` 매크로 내에서 정점 위치를 `pos` 이름으로 사용하기 때문이다.

그리고 `SHADOW_COORDS(uv채널)` 매크로를 통해 쉐도우맵을 받아올 변수를 선언한다.

```hlsl
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    SHADOW_COORDS(1)
};
```

`SHADOW_COORDS(1)` 매크로는 실제로 `unityShadowCoord4 _ShadowCoord : TEXCOORD1`로 확장된다.

<br>

## **[4] 버텍스 쉐이더**

`TRANSFOR_SHADOW(o)` 매크로를 통해 프래그먼트 쉐이더에 쉐도우 맵을 전달할 수 있다.

```hlsl
v2f vert (appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    
    TRANSFER_SHADOW(o)
    return o;
}
```

<br>

## **[5] 프래그먼트 쉐이더**

출력할 RGB 색상에 `SHADOW_ATTENUATION(i)`를 곱해주면 그림자가 적용된다.

```hlsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    col.rgb *= SHADOW_ATTENUATION(i);
    
    return col;
}
```

<br>

## **[6] 결과**

![image](https://user-images.githubusercontent.com/42164422/136208841-ef37ea0b-dfef-4ed7-ae18-c637200e1ec6.png)

상단, 하단의 오브젝트에는 기본 PBR 쉐이더가 적용되었고, 중앙 오브젝트에 위의 쉐이더가 적용되었다.

그런데 그림자가 제대로 적용되지 않고, 희한하게 나타나 있는 것을 볼 수 있다.

**Receive Shadow**를 구현하는 것만으로는 위와 같이 그림자가 제대로 적용되지 않는다.

제대로 적용되게 하려면, **Cast Shadow** 패스가 필요하다.

따라서 `Pass{ }` 블록 이후에 다음과 같이 추가해준다.

```hlsl
Pass
{
    // ...
}
UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
```

![image](https://user-images.githubusercontent.com/42164422/136209303-3c20364c-6d16-4fde-b102-8dd8bee765d2.png)

이제 제대로 적용되는 것을 확인할 수 있다.

<br>

# 2. Cast Shadow 구현하기
---

위에서 했던 것처럼

```hlsl
UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
```

이걸 추가해서 빠르게 구현할 수도 있고,

커스터마이징이 필요하다면 패스를 직접 작성하면 된다.

<br>

```hlsl
Pass
{
    Tags { "LightMode"="ShadowCaster" }

    CGPROGRAM

    #pragma vertex vertShadowCaster
    #pragma fragment fragShadowCaster
    #pragma multi_compile_shadowcaster
    //#pragma multi_compile_instancing
    #pragma fragmentoption ARB_precision_hint_fastest
    //#pragma fragmentoption ARB_precision_hint_nicest

    #include "UnityCG.cginc"
    #include "UnityStandardShadow.cginc"

    struct v2f
    {
        V2F_SHADOW_CASTER;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
        return o;
    }

    fixed4 frag(v2f i) : SV_TARGET
    {
        SHADOW_CASTER_FRAGMENT(i);
    }
    ENDCG
}
```

GPU Instancing을 적용하고 싶다면 `#pragma multi_compile_instancing`을 작성하면 되고,

그림자 계산의 정밀도를 더 높이고 싶다면 `ARB_precision_hint_fastest` 대신 `ARB_precision_hint_nicest`를 적용하면 된다.

<br>

# 3. 기본 라이팅 구현하기
---

- 기본 램버트와 앰비언트(환경광)를 적용한다.

<br>

## **[1] v2f 구조체**

`COLOR0`, `COLOR1` 채널에 `diffuse`, `ambient` 변수를 선언한다.

```hlsl
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    SHADOW_COORDS(1)
    fixed3 diffuse : COLOR0;
    fixed3 ambient : COLOR1;
};
```

<br>

## **[2] 버텍스 쉐이더**

아래와 같이 라이팅을 계산하고 출력한다.

프래그먼트 쉐이더가 아니라 버텍스 쉐이더에서 라이팅을 계산하는 이유는,

버텍스 쉐이더가 훨씬 적게 호출되므로 저렴하기 때문이다.

```hlsl
v2f vert (appdata v)
{
    v2f o;
    
    // Lambert
    half3 N = UnityObjectToWorldNormal(v.normal);
    half3 L = _WorldSpaceLightPos0;
    half NdL = saturate(dot(N, L));

    // Outputs
    o.pos     = UnityObjectToClipPos(v.vertex);
    o.uv      = v.uv;
    o.diffuse = NdL * _LightColor0;
    o.ambient = ShadeSH9(half4(N, 1));
    TRANSFER_SHADOW(o)

    return o;
}
```

<br>

## **[3] 프래그먼트 쉐이더**

버텍스 쉐이더에서 전달해준 램버트, 앰비언트를 그대로 출력 색상에 계산해준다.

```hlsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);

    col.rgb *= i.diffuse;
    col.rgb *= SHADOW_ATTENUATION(i);
    col.rgb += i.ambient;

    return col;
}
```

<br>

## **[4] 실행 결과**

![image](https://user-images.githubusercontent.com/42164422/136215769-10d58d06-c965-4dd7-83b6-97894c373296.png)

중앙의 오브젝트에 위의 쉐이더가 적용되었다.

위화감 없이 다른 오브젝트들처럼 잘 구현된 것을 확인할 수 있다.

<br>

# 참고 : 유니티 내장 cginc 파일들
---

```
유니티 에디터 설치 경로\Editor\Data\CGIncludes
```

위 경로에서 `.cginc` 파일들을 확인할 수 있다.

<br>

# References
---
- <https://docs.unity3d.com/kr/current/Manual/SL-SurfaceShaders.html>
- <https://docs.unity3d.com/kr/current/Manual/SL-ShaderPrograms.html>
- <https://docs.unity3d.com/kr/current/Manual/SL-PassTags.html>
- <https://docs.unity3d.com/560/Documentation/Manual/SL-VertexFragmentShaderExamples.html>
- <https://walll4542.wixsite.com/watchthis/post/unityshader-05-cast-receive-shadow>