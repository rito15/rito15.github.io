---
title: 레이 마칭(Ray Marching)
author: Rito15
date: 2021-01-19 23:15:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 레이 마칭이란?
---

- 메시 데이터를 이용하는 기존의 3D 렌더링 방식과는 달리, 거리 함수(**SDF**)를 통해 오브젝트의 표면을 정의한다.

- 카메라로부터 스크린 픽셀들을 향해 레이를 전진시키고(**Ray Marching**), 해당 픽셀의 레이가 오브젝트 표면에 닿으면 그 픽셀에 오브젝트 표면을 렌더링하는 방식을 사용한다.

<center><img src="https://user-images.githubusercontent.com/42164422/104993172-ce0bab00-5a65-11eb-9eda-705de2034f17.png" width="500"></center>

<br>

## **SDF**
- **Signed Distance Function**
- 공간 상의 임의의 한 점으로부터 오브젝트 표면까지의 최단 거리를 계산하는 함수
- SDF를 통해 3D 오브젝트 표면의 공간상 위치를 정의할 수 있다.

<br>

- 가장 간단한 **SDF** : 구체(Sphere)

![image](https://user-images.githubusercontent.com/42164422/139840667-430e5a81-3f5b-4c26-9d68-5c033532abf7.png)


```glsl
// point  : 거리를 계산할 기준 좌표
// center : Sphere의 중심 좌표
// radius : Sphere의 반지름
float sdSphere(vec3 point, vec3 center, float radius)
{
    return length(point - center) - radius;
}
```

<br>

# 레이 마칭 과정
---

## **[1] Ray Origin 정의**

![image](https://user-images.githubusercontent.com/42164422/139842639-663e9600-b516-46be-bb94-010caa8fd7fb.png)

레이의 출발 지점(Ray Origin, **RO**), 즉 카메라의 3D 공간 상 위치를 정의한다.

<br>

## **[2] Screen UV 정의**

![UV_225](https://user-images.githubusercontent.com/42164422/139843156-502d0b30-9708-4aa7-8d7f-f55fc954eda0.png)

XY 평면에 Screen UV(화면 좌표)를 정의한다.

<br>

## **[3] Ray Direction 정의**

![image](https://user-images.githubusercontent.com/42164422/139843952-739a740b-d8ef-4b44-ac33-683da9614090.png)

Screen UV 좌표에 깊이(Z축 좌표)를 추가하여 3D 공간 상의 화면 좌표를 생성한다.

그리고 카메라(**RO**)에서 모든 화면 좌표를 향하는 방향 벡터(Ray Direction, **RD**)를 정의한다.

**RD**는 정규화된 벡터여야 한다.

<br>

## **Note**

레이 마칭은 대개 **Pixel Shader** 또는 **Fragment Shader**에서 계산한다.

물체의 표면을 이루는 모든 픽셀마다 한 번씩 병렬적으로 실행된다는 뜻이다.

다시 말해, **RD**는 각 픽셀 쉐이더마다 한 개씩 계산된다.

따라서 물체의 표면을 이루는 픽셀이 `200 x 100 = 20000`개라면 `20000` 개의 **RD**가 존재하고, 

렌더 타겟, 즉 스크린 전체에서 레이 마칭을 계산하게 될 경우 해상도 만큼의 **RD**가 존재한다.

<br>

## **[4] SDF 정의**

![image](https://user-images.githubusercontent.com/42164422/139844891-5446eed6-84fe-482b-bce9-b4e2ea6fa3a9.png)

![image](https://user-images.githubusercontent.com/42164422/139845841-6e8f40f5-14e9-49d5-a555-1a5f64701e3d.png)

공간 상의 물체 표면 정보를 SDF 함수를 통해 정의한다.

<br>

## **[5] 레이 전진 알고리즘**

하나의 픽셀 쉐이더, 즉 하나의 **RD**에 대해 예시로 설명한다.

**RO**, **RD**, **SDF**가 모두 정의된 상태.

![image](https://user-images.githubusercontent.com/42164422/139847236-5f6a7f82-93f2-462c-9d47-99bbcd3bdfcb.png)

<br>

**RO**에서 각각의 물체마다 **SDF(거리 함수)**를 계산하여, **RO**로부터 각 물체 표면까지의 최단거리를 계산한다.

예시의 오브젝트는 2개이므로, 총 2개의 **SDF** 계산을 거쳐 두 개의 거리 값이 계산된다.

![image](https://user-images.githubusercontent.com/42164422/139847954-89581066-d543-45ab-860a-ed2a6ecc46fb.png)

<br>

계산된 모든 **SDF** 값(`d1`, `d2`)들 중 가장 작은 값(`d1`)만큼의 거리를 **RD** 방향으로 전진한다.

그러면 한 번의 스텝(Step)이 완료된 것이다.

![image](https://user-images.githubusercontent.com/42164422/139849098-bd7a9678-e2f8-47a5-bcfb-ffa75d25a8fd.png)

<br>

첫 번째 스텝에서 전진한 위치(`P1`)에서 다시 모든 물체의 **SDF**를 계산하여 각 물체 표면까지의 최단거리를 계산한다.

![image](https://user-images.githubusercontent.com/42164422/139849650-0687557c-2b28-4e18-9e8e-4975af579308.png)

<br>

그리고 마찬가지로 각 최단거리 중 가장 작은 값만큼 **RD** 방향으로 전진한다.

![image](https://user-images.githubusercontent.com/42164422/139849976-35d56ae4-9b48-492a-a592-aae6ab65388e.png)

<br>

위와 같이 스텝을 반복하여 레이를 전진시키고, 이동한 거리 값을 누적한다.

<br>

물체 표면에 닿거나(최단거리가 임계 값보다 작다고 판단)

![image](https://user-images.githubusercontent.com/42164422/139850580-093b4657-2a6e-498b-ac9d-7a68c20b4309.png)

<br>

물체 표면을 찾지 못한 상태에서 제한 스텝 수 또는 제한 전진 거리에 도달한 경우

![image](https://user-images.githubusercontent.com/42164422/139850983-928ee2ac-9871-46ab-909a-f722744d7610.png)

스텝을 종료한다.

<br>

레이마칭의 결과로는 `RO에서부터 물체 표면까지의 거리`(**d**)를 리턴하게 되는데,

`RO + RD * d` 계산식을 통해 물체 표면의 공간 상 위치를 계산할 수 있다.

<br>

# 레이 마칭 함수
---

## **레이 마칭 함수의 구성**

<center> <img src="https://user-images.githubusercontent.com/42164422/104993811-c1d41d80-5a66-11eb-9ad3-a861471cce8e.png" width="500"> </center>

```glsl
#define MAX_STEPS 100   // 최대 스텝 수
#define MAX_DIST  100   // 최대 전진 거리
#define SURF_DIST 0.01  // 표면 인식 거리

float RayMarch(vec3 ro, vec3 rd)
{
    // RO에서 현재까지 전진한 누적 거리 저장
    float dO = 0.;
    
    for(int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd * dO;
        
        // GetDist() : 지정한 위치로부터 최단 SDF 거리값 계산
        float dS = GetDist(p); // 이번 스텝에 전진할 거리
        dO += dS;              // 레이 전진
        
        // 레이 제한 거리까지 도달하거나
        // 레이가 물체의 정점 또는 땅에 닿은 경우 레이 마칭 종료
        if(dO > MAX_DIST || dS < SURF_DIST)
            break;
    }
    
    return dO;
}
```

> - i : 누적 스텝 수
> - ro : 카메라의 위치
> - rd : 레이의 전진 방향(카메라 -> 스크린의 모든 픽셀)

> - dO : 현재 스텝까지 레이의 누적 전진 거리
> - dS : 이번 스텝에서 전진할 거리(즉, 모든 SDF를 계산했을 때 가장 작은 값)
> - p : 레이의 현재 위치

> - MAX_STEPS : 최대 반복(스텝) 횟수
> - SURFACE_DIST : 레이가 표면에 닿았다고 판단할 임계값
> - MAX_DIST : 레이가 전진할 수 있는 최대 거리

<br>

# 전체 계산 과정
---
 
### **[1] 거리 계산**

- 스크린의 모든 픽셀에 대해 위의 레이마칭 과정을 통해 최단 거리 값을 계산한다.

<center><img src="https://user-images.githubusercontent.com/42164422/104995624-f0072c80-5a69-11eb-9888-15b0f89edd41.png" width="500"></center>

<details>
<summary markdown="span">
RayMarch Function
</summary>

```glsl
float RayMarch(vec3 ro, vec3 rd)
{
    // RO에서 현재까지 전진한 누적 거리 저장
    float dO = 0.;
    
    for(int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd * dO;
        
        // GetDist() : 지정한 위치로부터 최단 SDF 거리값 계산
        float dS = GetDist(p); // 이번 스텝에 전진할 거리
        dO += dS;              // 레이 전진
        
        // 레이 제한 거리까지 도달하거나
        // 레이가 물체의 정점 또는 땅에 닿은 경우 레이 마칭 종료
        if(dO > MAX_DIST || dS < SURF_DIST)
            break;
    }
    
    return dO;
}
```

</details>

<br>

### **[2] 노멀 계산**

- `[1]`에서 얻어낸 거리값(`d`)을 이용해, 각 표면의 정확한 3D 공간 상 위치(`P = RO + RD * d`)를 계산한다.

- 계산된 위치(`P`)로부터 x, y, z축 방향으로 각각 미세하게 떨어진 위치에서 `GetDist()` 함수를 통해 가장 가까운 물체 표면까지의 거리를 계산한다.

- 이렇게 얻어낸 3개의 값을 각각 해당 표면에서의 x, y, z 노멀 벡터 성분으로 사용한다.

<center><img src="https://user-images.githubusercontent.com/42164422/104995731-1927bd00-5a6a-11eb-8f0b-c63f60abe394.png" width="500"> </center>

<details>
<summary markdown="span">
GetNormal Function
</summary>

```glsl
// 각 물체 표면 위치에서 노멀 벡터 계산
vec3 GetNormal(vec3 p)
{
    float d = GetDist(p);
    vec2  e = vec2(0.001, 0.0);
    
    // x, y, z 좌표를 0.01씩 움직인 3개의 방향벡터를 이용하여
    // 각각 GetDist()를 통해 해당 방향에 있는 물체의 표면까지의 최단거리를 찾고,
    // 이를 x, y, z 성분으로 사용한 노멀 벡터 생성
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx)
    );
    
    return normalize(n);
}
```

</details>

<br>

### [3] 라이트(Directional Light) 계산

- 픽셀 쉐이더에서의 디퓨즈 계산 방식과 동일하게, 가상 라이트 벡터(L)와 각 표면의 노멀 벡터(N)를 내적하여 라이팅을 계산한다.

<center><img src="https://user-images.githubusercontent.com/42164422/104995793-2e045080-5a6a-11eb-86db-8c7601d12846.png" width="500"> </center>

<details>
<summary markdown="span">
GetLight Function
</summary>

```glsl
// 각 물체 표면에서 라이팅 계산
float GetLight(vec3 p)
{
    vec3 L = normalize(g_lightPos - p);
    vec3 N = GetNormal(p);
    
    // Shade(Diffuse)
    float diff = saturate( dot(N, L) );
    
    // Shadow
    // 정점(3D 물체 표면이 위치하는 모든 지점)에서 광원을 향해 레이마칭하여 얻은 거리가
    // 정점에서 광원까지의 거리보다 작다면,
    // 그 사이에 또다른 정점이 가로막고 있다는 뜻이므로 이 정점은 그림자가 생긴다.
    
    // SURF_DIST만큼의 거리를 더해주는 이유 : 레이가 정점을 찾아내는 최소 거리(Threshold)이므로
    // SURF_DIST에 1.0 초과 숫자를 곱해주는 이유 : 의도치 않은 음영이 생길 수 있으므로
    
    float d = RayMarch(p + N * SURF_DIST * 2.0, L);
    if( d < length(g_lightPos - p) )
        diff *= 0.1;
    
    return diff;
}
```

</details>

<br>

# ShaderToy에서의 구현 예시
---

- [https://www.shadertoy.com/view/wstBW4](https://www.shadertoy.com/view/wstBW4)

![2021_0314_Raymarching](https://user-images.githubusercontent.com/42164422/111060423-17b1c880-84e0-11eb-8367-c221f3576e91.gif)

<br>

<details>
<summary markdown="span"> 
Source Code
</summary>

```glsl
#define MAX_STEPS 100
#define MAX_DIST  100.0
#define SURF_DIST 0.01

// 광원
vec3 g_lightPos = vec3(0., 5., 1.);

/**************************************************************************************************
 * 3D Objects
 * https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
 * https://www.youtube.com/watch?v=Ff0jJyyiVyw
 **************************************************************************************************/
struct Plane
{
    vec3  normal; // 평면 법선 벡터의 방향
    float height; // 높이 : 원점에서 normal벡터 방향으로 더한 값
};
    
struct Sphere
{
    vec3  pos;
    float radius;
};
    
struct Box
{
    vec3 pos;
    vec3 size;
};
    
// 속이 빈 박스
struct BoundingBox
{
    vec3  pos;
    vec3  size;
    float e;    // edge Thickness
};

// 도넛형
struct Torus
{
    vec3 pos;
    vec2 radius; // (out radius, in radius)
};

/**************************************************************************************************
 * 3D Object Distance Functions
 **************************************************************************************************/
// GetMinDist : 지점 p로부터 오브젝트 o위의 정점으로의 거리 중 가장 가까운 거리 찾아 리턴
float SD(vec3 p, Sphere o)
{
    return length(p - o.pos) - o.radius;
}
float SD(vec3 p, Plane o)
{
    return dot(p, normalize(o.normal)) - o.height;
}
float SD(vec3 p, Box o)
{
    vec3 q = abs(p - o.pos) - o.size;
    return length(max(q, 0.0)) + min( max(q.x, max(q.y,q.z) ), 0.0);
}
float SD(vec3 p, BoundingBox o)
{
    vec3  b = o.size;
    float e = o.e;
    
    p = abs(p - o.pos )-b;
    vec3 q = abs(p+e)-e;
    
    return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float SD(vec3 p, Torus o)
{
    p = p - o.pos;
    vec2 r = o.radius;
        
    vec2 q = vec2(length(p.xz)-r.x,p.y);
    return length(q)-r.y;
}

/**************************************************************************************************
 * Ray Marching Functions
 **************************************************************************************************/
// 현재 진행중인 레이 위의 점에서 다음 지점(특정 오브젝트 표면 또는 플레인) 발견하여 리턴
// 현재 위치 p에서 구형범위로 탐색하여, 어떤 물체든 찾아 가장 작은 구체의 반지름을 리턴하는 것과 같음
float GetDist(vec3 p)
{
    Plane pl;
    pl.normal = vec3(0.0, 1.0, 0.0);
    pl.height = 0.0;
    
    Sphere s;
    s.pos    = vec3(-6.0, 1.0, 6.0);
    s.radius = 1.0;
    
    Box b;
    b.pos   = vec3(-2.0, 1.0, 6.0);
    b.size  = vec3(1.0, 1.0, 1.0);
    
    BoundingBox bb;
    bb.pos  = vec3(1.0, 1.0, 6.0);
    bb.size = vec3(1.0, 1.0, 1.0);
    bb.e    = 0.1;
    
    Torus t;
    t.pos   = vec3(5.0, 1.0, 6.0);
    t.radius = vec2(1.0, 0.4);
    
    float dPlane  = SD(p, pl); //p.y;
    float dSphere = SD(p, s);
    float dBox    = SD(p, b);
    float dBBox   = SD(p, bb);
    float dTorus  = SD(p, t);
    
    // 발견한 다음 지점들 중 가장 가까운 지점 리턴
    float d = min(dPlane, dSphere);
          d = min(d, dBox);
          d = min(d, dBBox);
          d = min(d, dTorus);
    
    return d;
}

// ro(카메라)로부터 rd 방향(모든 uv 픽셀)으로 레이 발사
// 리턴값 : 카메라로부터 레이 방향에서 찾은 가장 가까운 정점
float RayMarch(vec3 ro, vec3 rd)
{
    // RayMarch Distance From Origin : Ray Origin(카메라)에서부터의 거리
    float dO = 0.;
    
    for(int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd * dO;
        float dS = GetDist(p);   // Distance to the Scene : 레이 내에서 다음 스텝으로 전진시킬 거리
        dO += dS;                // 레이 한 스텝 전진
        
        // 레이 제한 거리까지 도달하거나
        // 레이가 물체의 정점 또는 땅에 닿은 경우 레이 마칭 종료
        if(dO > MAX_DIST || dS < SURF_DIST)
            break;
    }
    
    return dO;
}

// 각 정점에서 노멀 벡터 계산
vec3 GetNormal(vec3 p)
{
    float d = GetDist(p);
    vec2  e = vec2(0.001, 0.0);
    
    // x, y, z 좌표를 0.01씩 움직인 3개의 방향벡터로 각각 GetDist를 통해 해당 방향에 있는 물체의 정점까지 거리를 찾고,
    // 이를 x, y, z 성분으로 사용한 노멀 벡터 생성
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx)
    );
    
    return normalize(n);
}

// 각 정점에서 라이팅 계산
float GetLight(vec3 p)
{
    vec3 L = normalize(g_lightPos - p);
    vec3 N = GetNormal(p);
    
    // Shade(Diffuse)
    float dif = saturate( dot(N, L) );
    
    // Shadow
    // 정점(3D 물체 표면이 위치하는 모든 지점)에서 광원을 향해 레이마칭하여 얻은 거리가
    // 정점에서 광원까지의 거리보다 작다면,
    // 그 사이에 또다른 정점이 가로막고 있다는 뜻이므로 이 정점은 그림자가 생김
    
    // SURF_DIST만큼의 거리를 더해주는 이유 : 레이가 정점을 찾아내는 최소 거리(Threshold)이므로
    // SURF_DIST에 1.0 초과 숫자를 곱해주는 이유 : 의도치 않은 음영이 생길 수 있으므로
    
    float d = RayMarch(p + N * SURF_DIST * 2.0, L);
    if(d < length(g_lightPos - p) )
        dif *= 0.1;
    
    return dif;
}

float DistLine(vec3 ro, vec3 rd, vec3 p)
{
    return length(cross(p - ro, rd)) / length(rd);
}

/**************************************************************************************************
 * Main
 **************************************************************************************************/
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // UV ================================================================================================
    vec2 uv = fragCoord/iResolution.xy;                
           uv = (uv - 0.5) * vec2(iResolution.x/iResolution.y, 1.0) *2.0; // Square Area  -1.0 ~ 1.0
    
    float zoom = 1.3;
    uv /= zoom;
    
    vec2 mPos = iMouse.xy/iResolution.xy;
           mPos = (mPos - 0.5) * vec2(iResolution.x/iResolution.y, 1.0) *2.0;
    mPos /= zoom;
    
    // Final Variables ===================================================================================
    vec3 shp = vec3(0.0); // Shapes
    vec3 col = vec3(0.0); // Colors of Shapes
    
    // Ray Origin
    vec3 ro = vec3(0.0, 1.1, 0.0);// + vec3(sin(mPos.x), 0., cos(mPos.x));
    
    // Ray Direction : ro -> uv screen
    vec3 rd = normalize(vec3(uv, 1.0));
    
    float t = iTime;
    
    float d;  // Distance from point
    vec3  p;  // Result of RayMarching (3D Shapes)
    float dif;// Diffuse
    
    
    /*****************************************************************************************************************
    * Body Start                                                                                                     *
    *****************************************************************************************************************/
    
    g_lightPos += vec3(sin(t), 0., cos(t)) * 3.0;
    
    d = RayMarch(ro, rd);
    p = ro + rd * d;
    dif = GetLight(p);
    
    /*****************************************************************************************************************
    *                                                                                                       Body End *
    *****************************************************************************************************************/
    
    
    // Draw Shapes =======================================================================================
    shp += dif;
        
    // Apply Colors ======================================================================================
    col += vec3(1.0, 1.0, 0.9);
    
    // End Point =========================================================================================
    fragColor.a = 1.0;
    fragColor.rgb = shp * col;
}
```

</details>
 
<br>
 
# 유니티 엔진에서의 간단한 구현 예시
---

## **[1]**

- <https://github.com/SebLague/Ray-Marching> 활용

 <center><img src="https://user-images.githubusercontent.com/42164422/105003713-5f831900-5a76-11eb-8090-bd2e8d6f9b87.png" width="500"></center>

<br>

## **[2]**

- 하나의 쉐이더 내에서 구현
- Cube Mesh에 쉐이더를 적용한다.

![2021_0703_Unity_Raymarching](https://user-images.githubusercontent.com/42164422/124320293-8feae980-dbb6-11eb-85ca-f861415b9785.gif)

<details>
<summary markdown="span"> 
Raymarching.shader
</summary>

```hlsl
// https://www.youtube.com/watch?v=S8AWd66hoCo

Shader "Rito/RayMarching"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST  100
            #define SURF_DIST 0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
                o.hitPos = v.vertex;

                return o;
            }
            
            /*****************************************************************
                                             Functions
            ******************************************************************/
            // 트랜스폼의 회전 행렬 추출
            float4x4 GetModelRotationMatrix()
            {
                float4x4 rotationMatrix;

                vector sx = vector(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20, 0);
                vector sy = vector(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21, 0);
                vector sz = vector(unity_ObjectToWorld._m02, unity_ObjectToWorld._m12, unity_ObjectToWorld._m22, 0);

                float scaleX = length(sx);
                float scaleY = length(sy);
                float scaleZ = length(sz);

                rotationMatrix[0] = float4(unity_ObjectToWorld._m00 / scaleX, unity_ObjectToWorld._m01 / scaleY, unity_ObjectToWorld._m02 / scaleZ, 0);
                rotationMatrix[1] = float4(unity_ObjectToWorld._m10 / scaleX, unity_ObjectToWorld._m11 / scaleY, unity_ObjectToWorld._m12 / scaleZ, 0);
                rotationMatrix[2] = float4(unity_ObjectToWorld._m20 / scaleX, unity_ObjectToWorld._m21 / scaleY, unity_ObjectToWorld._m22 / scaleZ, 0);
                rotationMatrix[3] = float4(0, 0, 0, 1);

                return rotationMatrix;
            }

            // 위치 벡터 회전
            float3 RotatePosObjectToWorld(float4x4 rotationMatrix, float3 pos)
            {
                return mul(rotationMatrix, pos).xyz;
            }

            float3 RotatePosWorldToObject(float4x4 rotationMatrix, float3 pos)
            {
                return mul(pos, rotationMatrix).xyz;
            }
            
            // 방향 벡터 회전
            float3 RotateDirObjectToWorld(float4x4 rotationMatrix, float3 dir)
            {
                return mul((float3x3)rotationMatrix, dir);
            }

            float3 RotateDirWorldToObject(float4x4 rotationMatrix, float3 dir)
            {
                return mul(dir, (float3x3)rotationMatrix);
            }

            /*****************************************************************
                                  Signed Distance Functions
            ******************************************************************/
            float SdSphere(float3 p, float3 pos, float radius)
            {
                return length(p - pos) - radius;
            }

            float SdSphere2(float3 p, float3 pos, float radius, float3 scale)
            {
                p -= pos;
                p /= scale;
                p += pos;

                return length(p - pos) - radius;
            }

            float SdTorus(float3 p, float3 pos, float radius, float width)
            {
                p = p - pos;
                float r = radius;
                float w = width;
                float2 q = float2(length(p.xz) - r, p.y);
                return length(q) - w;
            }

            float SdBox(float3 p, float3 pos, float3 size)
            {
                float3 q = abs(p - pos) - size;
                return length(max(q, 0.0)) + min( max(q.x, max(q.y,q.z) ), 0.0);
            }
            
            /*****************************************************************
                                        Operator Functions
            ******************************************************************/
            float2x2 GetRotationMatrix2x2(float degree)
            {
                float radian = radians(degree);
                float s = sin(radian);
                float c = cos(radian);

                return float2x2(c, -s, s, c);
            }

            float3 RotateX(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.yz = mul(GetRotationMatrix2x2(degree), p.yz);
                p += pos;

                return p;
            }
            float3 RotateY(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.xz = mul(GetRotationMatrix2x2(degree), p.xz);
                p += pos;

                return p;
            }
            float3 RotateZ(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.xy = mul(GetRotationMatrix2x2(degree), p.xy);
                p += pos;

                return p;
            }

            float3 Scale(float3 p, float3 pos, float3 scale)
            {
                p -= pos;
                p /= scale;
                p += pos;
                return p;
            }

            // Polynomial smooth min (k = 0.1);
            float smin(float a, float b, float k)
            {
                float h = saturate(0.5 + 0.5 * (b - a) / k);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float smin(float a, float b)
            {
                return smin(a, b, 0.2);
            }

            float3 Displacement(float3 p, float dist, float intensity)
            {
                float3 disp = sin(p * dist) * intensity;
                return p + disp;
            }
            
            /*****************************************************************
                                   Ray Marching Functions
            ******************************************************************/
            // Sphere + Torus + Sphere*8
            float SunShape(float3 p)
            {
                float t = _Time.y;
                float3 centerPos = float3(-1.0, 0, 2.0);

                float torus = SdTorus(RotateX(p, centerPos, 90), centerPos, 0.5, 0.1);
                float s1 = SdSphere(p, centerPos, 0.3 + sin(t * 3.0) * 0.1);

                float d = smin(torus, s1);
                
                float3 s2_pos = centerPos; s2_pos.y += 0.9;

                for(int i = 0; i < 8; i++)
                {
                    float3 s2_p = RotateZ(p, centerPos, 45.0 * (float)i + t * 50.0);
                    float s2 = SdSphere2(s2_p, s2_pos, 0.1, float3(1.0, 2.0, 1.0));

                    d = smin(d, s2);
                }

                return d;
            }

            // Final SD Functions
            float GetDist(float3 p)
            {
                float t = _Time.y;
                float d = SunShape(p);
                
                float3 pos2 = float3(1.0, 0, 2.0);
                float scale = 0.7 + sin(t * 2.0) * 0.1;

                float3 p2 = p;
                p2 = RotateX(p2, pos2, t * 60.0);
                p2 = RotateZ(p2, pos2, t * 90.0);

                float box = SdBox(p2, pos2, scale);
                float sp = SdSphere(p, pos2, scale * 1.3);

                float d2 = max(box, -sp);

                d = smin(d, d2, 0.4);

                return d;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(0.01, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy),
                    GetDist(p - e.yxy),
                    GetDist(p - e.yyx)
                );
                return normalize(n);
            }

            float GetLight(float3 N, float3 L)
            {
                return saturate(dot(N, L));
            }

            float Raymarch(float3 ro, float3 rd)
            {
                float dO = 0; // 누적 전진 거리
                float dS;     // 이번 스텝에서 전진할 거리

                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + dO * rd;
                    dS = GetDist(p);
                    dO += dS;

                    if(dS < SURF_DIST || dO > MAX_DIST)
                        break;
                }

                return dO;
            }

            /*****************************************************************
                                       Fragment Function
            ******************************************************************/
            fixed4 frag (v2f i) : SV_Target
            {
                float4x4 rotMatrix = GetModelRotationMatrix();

                // Object Light Direction
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                L = RotateDirWorldToObject(rotMatrix, L);

                float2 uv = i.uv - 0.5;
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);

                float d = Raymarch(ro, rd);
                fixed4 col = 0;
                col.a = 1;

                if(d < MAX_DIST)
                {
                    float3 p = ro + rd * d;
                    float3 N = GetNormal(p);
                    col.rgb = GetLight(N, L);
                }
                else
                    discard;

                return col;
            }
            ENDCG
        }
    }
}
```

</details>

<br>
 
# 장점
---
 - 메시(Mesh) 데이터가 필요하지 않다.
 - 부드러운 곡면이나 유체를 표현하기에 좋다.
 - 반복되는 패턴을 렌더링하기에 좋다.
 - 거리 함수, 연산 함수들을 이용하여 오브젝트들을 다양한 형태로 부드럽게 섞어 렌더링할 수 있다.
 - 각 레이를 GPU 연산을 통해 병렬적으로 연산하기에 적합하다.

<br>

# 연관 개념
---

## **레이 트레이싱(Ray Traycing)**
- 광원으로부터 나온 빛이 물체의 표면에 부딪히고, 그 다음 표면에 부딪히기를 반복해서 결국 카메라에 도달했을 때의 결과 색상을 화면에 출력하는 기법
- 현실적으로 모든 광선의 추적은 불가능하므로 역으로 카메라에서 픽셀마다 레이를 발사하여, 표면에 부딪힌 결과를 역연산하여 렌더링하는 방식을 사용한다.
- 기본적인 레이 트레이싱은 주로 반사/스페큘러 계산에 사용한다.

## **패스 트레이싱(Path Traycing)**
- 레이 트레이싱의 일종
- 반사, 굴절이 없는 물체에도 모두 레이를 추적하여, 보다 현실적인 그래픽을 표현하는 기법
- 레이 트레이싱을 이용해 **디퓨즈(Diffuse)** 및 **스페큘러(Specular)**, **전역 조명(GI, Global Illumination)**을 주로 계산한다.

<br>

- <https://blog.hybrid3d.dev/2019-11-15-raytracing-pathtracing-denoising>

<details>
<summary markdown="span">
Ray Tracing in Unity Tutorial
</summary>

- <https://www.gamedeveloper.com/programming/gpu-ray-tracing-in-unity-part-1>
- <http://three-eyed-games.com/2018/05/12/gpu-path-tracing-in-unity-part-2/>
- <https://www.gamedeveloper.com/programming/gpu-path-tracing-in-unity-part-3>

</details>

<br>

# References
---
 - <http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions>
 - <https://www.iquilezles.org/www/index.htm>
 - <https://github.com/SebLague/Ray-Marching>
 - [Youtube: Sebastian Lague](https://www.youtube.com/watch?v=Cp5WWtMoeKg)
 - [Youtube: The Art of Code](https://www.youtube.com/playlist?list=PLGmrMu-IwbgtMxMiV3x4IrHPlPmg7FD-P)
 - [Youtube: Peer Play](https://www.youtube.com/playlist?list=PL3POsQzaCw53iK_EhOYR39h1J9Lvg-m-g)