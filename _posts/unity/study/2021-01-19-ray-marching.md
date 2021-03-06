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

 - 모델의 정점 데이터를 이용하는 기존의 3D 렌더링 방식과는 달리, 레이를 전진시켜(Ray Marching) 표면의 정보를 얻어 오브젝트를 그려내는 기법
 
 - 레이 마칭의 모든 오브젝트들은 거리 함수(SDF : Signed Distance Function)로 표면의 정보가 계산된다.

 - SDF의 기초적인 예시 : 구체(Sphere)

```glsl
// point : 거리를 계산할 기준 좌표
// center : Sphere의 중심 좌표
// radius : Sphere의 반지름
float sdSphere(vec3 point, vec3 center, float radius)
{
    return length(point - center) - radius;
}

// sdSphere() 함수를 통해, 특정 좌표에서 구체의 표면까지의 최단 거리값을 계산할 수 있다.
```

<br>

<center><img src="https://user-images.githubusercontent.com/42164422/104993172-ce0bab00-5a65-11eb-9eda-705de2034f17.png" width="500"></center>
 
 - 한 점(RO : Ray Origin, 위의 그림에서 Camera)에서 스크린의 각각의 픽셀을 향한 방향(RD : Ray Direction, 위의 그림에서 Image)들을 향해 레이 캐스팅을 하여, 각 레이마다 여러 스텝(Step)으로 나누어 레이를 전진시키게 된다.
   
<br>

<center> <img src="https://user-images.githubusercontent.com/42164422/104993811-c1d41d80-5a66-11eb-9ad3-a861471cce8e.png" width="500"> </center>
   
 - 한 번의 스텝마다 존재하는 모든 SDF를 각각 계산하여 현재 레이 위치로부터 각 오브젝트와의 거리를 얻어낸다.

 - 그 중 현재 레이의 위치로부터 가장 가까운 거리값만큼 레이를 이동한다.
 
 - 레이의 다음 전진 거리가 매우 작으면(예: dS < 0.01) 레이가 표면에 닿았다고 판단하고, 레이의 전진을 중단한다.
 
 - 물체의 표면을 알아내지 못했는데 전진 횟수가 MAX_STEPS를 넘어서면 해당 픽셀에는 오브젝트의 표면이 존재하지 않는다고 판단한다.
 
 - 각 픽셀들에 대한 계산이 끝나면 표면의 노말과 라이팅 계산을 적용한다.
 
<br>
 
### [1] 거리 계산

 <center><img src="https://user-images.githubusercontent.com/42164422/104995624-f0072c80-5a69-11eb-9888-15b0f89edd41.png" width="500"></center>

### [2] 노멀 계산

 <center><img src="https://user-images.githubusercontent.com/42164422/104995731-1927bd00-5a6a-11eb-8f0b-c63f60abe394.png" width="500"> </center>

### [3] 라이트(Directional Light) 계산

 <center><img src="https://user-images.githubusercontent.com/42164422/104995793-2e045080-5a6a-11eb-86db-8c7601d12846.png" width="500"> </center>
 
### 간단한 구현 예시 (https://github.com/SebLague/Ray-Marching 활용)

 <center><img src="https://user-images.githubusercontent.com/42164422/105003713-5f831900-5a76-11eb-8090-bd2e8d6f9b87.png" width="500"></center>

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
    vec3  color; // TODO
};
    
struct Sphere
{
    vec3  pos;
    float radius;
    vec3  color;
};
    
struct Box
{
    vec3 pos;
    vec3 size;
    vec3 color;
};
    
// 속이 빈 박스
struct BoundingBox
{
    vec3  pos;
    vec3  size;
    float e;    // edge Thickness
    vec3  color;
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
        GetDist(p - e.yyx));
    
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
 
# 장점
---
 - 곡면을 부드럽게 렌더링할 수 있다.
 - 거리 함수, 연산 함수들을 이용하여 모델들을 다양하고 부드럽게 블렌딩하기에 좋다.
 - 각 레이를 GPU 연산을 통해 병렬적으로 연산하기에 적합하다.

<br>

# 단점
---
 - 성능 소모가 크다.

 <img src="https://user-images.githubusercontent.com/42164422/105004241-023b9780-5a77-11eb-9d91-015809da2d88.png" width="500">
 
<br>

# 연관 개념
---
 - https://blog.hybrid3d.dev/2019-11-15-raytracing-pathtracing-denoising

 - 레이 트레이싱(Ray Traycing)
   - 눈(RO)에서 출발한 빛이 광원에 도달할 때까지, 물체의 표면에 굴절되고 반사되는 것을 추적하는 기법
   - 기본적인 레이 트레이싱은 주로 반사/스페큘러 계산에 사용
 
 - 패스 트레이싱(Path Traycing)
   - 레이 트레이싱을 이용해 디퓨즈(Diffuse) 및 스페큘러(Specular), 전역 조명(GI, Global Illumination)을 계산하는 기법

<br>

# References
---
  - <http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions>
  - <https://www.youtube.com/watch?v=PGtv-dBi2wE> [The Art of Code]
  - <https://www.youtube.com/watch?v=Cp5WWtMoeKg> [Sebastian Lague]
  - <https://github.com/SebLague/Ray-Marching>