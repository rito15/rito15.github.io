---
title: 유니티 - 쉐이더에서 파티클 시스템 커스텀 데이터(Custom Data) 사용하기
author: Rito15
date: 2021-11-19 15:00:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 커스텀 데이터(Custom Data)
---
- 파티클 시스템의 `Custom Data` 모듈에서 지정한 값을 쉐이더로 가져와 사용할 수 있다.

<br>



# 1. 파티클 시스템 설정
---

## **[1] Custom Data 모듈**
- **Custom Data** 모듈에 체크한다.

- `Mode`를 `Vector` 또는 `Color`로 설정한다.

- `Vector`로 설정한 경우, 사용할 채널 개수(`Number of Components`), 각 채널의 값을 지정한다.

![image](https://user-images.githubusercontent.com/42164422/142575392-5cded22c-cb54-4239-8672-d9aa76ed7759.png)

<br>

## **[2] Renderer 모듈**
- `Custom Vertex Streams`에 치크한다.

![image](https://user-images.githubusercontent.com/42164422/142575505-691f7f9b-f584-4e3d-9b65-feda48dddad8.png)

<br>

- 우측 하단의 `+` 버튼을 눌러 알맞은 커스텀 데이터를 목록에 추가한다.

- **Custom Data** 모듈에서 지정한 데이터를 정확히 추가해주어야 한다.

- 예시에서는 **Custom Data** 모듈에서 `Custom1`의 `x` 컴포넌트만 지정했으므로 `Custom1.x`를 추가한다.

![image](https://user-images.githubusercontent.com/42164422/142578054-e6ffd4dc-4e79-4c4a-bc56-0e761df8791b.png)

<br>



# 2. 쉐이더
---

## **[1] 쉐이더 코드**

입력 어셈블리에서 들어오는 입력인 `appdata`,

버텍스 쉐이더에서 프래그먼트 쉐이더로 전달해주는 `v2f` 구조체의 내부 변수를

파티클 시스템의 `Custom Vertex Streams`에 맞게 수정해주어야 한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/142578739-b5ab313c-827d-4b01-9ce2-c2f462050732.png)

```hlsl
struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 color : COLOR;
    float3 uv : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float4 color : COLOR;
    float3 uv : TEXCOORD0;
};
```

<br>

원래 `vertex`, `uv`만 있었다면 `normal`, `color`를 각각 `float3`, `float4`로 추가해준다.

`uv`는 원래 `float2`였지만, `Custom1.x`가 `TEXCOORD0.z`로 명시되었으므로

`uv`를 `float3`로 수정하여 `Custom1.x`를 받을 수 있도록 한다.

<br>

```hlsl
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    // ...
    
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    
    // ...
    
    return o;
}
```

버텍스 쉐이더 함수에서 원래 위와 같이 `uv`를 프래그먼트 쉐이더로 전달하고 있었다면,

```hlsl
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    // ...
    
    o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
    o.uv.z = v.uv.z;
    o.color = v.color;
    
    // ...
    
    return o;
}
```

`uv`는 3채널이 되었으므로 기존의 `uv`를 이렇게 `uv.xy`로 바꿔주고,

`uv.z`, `color`는 입력 어셈블리에서 전달받은 그대로 프래그먼트 쉐이더로 넘겨준다.

그리고 프래그먼트 쉐이더에서 알맞게 사용해주면 된다.

<br>

Vert/Frag 말고 서피스 쉐이더인 경우, 구조체가 둘이 아니라 하나라는 점만 다르고 똑같다.

그리고 어차피 서피스 함수는 프래그먼트 함수를 쓰듯 똑같이 해주면 된다.

<br>

## **[2] 앰플리파이 쉐이더**

![image](https://user-images.githubusercontent.com/42164422/142581013-0006a081-ed1a-46a9-983c-c34bc998ad7d.png)

앰플리파이 쉐이더 에디터를 쓰는 경우, 더 쉽다.

`Vertex Texcoord` 노드의 설정에서 알맞게 타입을 변경해주고 가져다 쓰면 된다.

예시에서는 `uv.z`가 커스텀 데이터를 사용하므로 `float3`로 변경한 뒤 `UVW` 중에서 `W`를 사용하면 된다.

<br>

만약 `TEXCOORD0`이 아니라 `TEXCOORD1`로 들어오는 경우,

`Vertex Texcoord` 노드의 설정에서 `UV Channel`을 `2`로 변경해서 받아올 수 있다.

