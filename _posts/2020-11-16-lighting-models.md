---
title: Lighting Models
author: Rito15
date: 2020-11-16 17:14:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics]
math: true
mermaid: true
---

# Vectors
---
![](https://user-images.githubusercontent.com/42164422/105632022-871e1b00-5e94-11eb-8a8a-06fa08406fa2.png)
- **L** (Light) : 정점에서 광원을 향하는 방향의 벡터
- **N** (Normal) : 정점의 노멀 벡터
- **V** (View) : 정점에서 카메라를 향하는 방향의 벡터
- **R** (Reflect) : 노멀벡터를 법선으로 하여 계산한 L의 반사 벡터 ( 2N(NdL)-L )
- **H** (Half) : 블린퐁에서 사용, L와 V의 중간 벡터 ( normalize(L + V) )  

- **NdL** = dot(N, L) : 기본 램버트 공식
- **NdV** = dot(N, V) : 림라이트에서 사용
- **RdV** = dot(R, V) : 퐁 스페큘러에서 사용
- **NdH** = dot(N, H) = dot(N, normalize(L + V) : 블린퐁 스페큘러에서 사용

<br>

# Lighting Models
---
## Lambert
- 조명 모델의 기본
```hlsl
Diffuse = saturate(NdL)
```

<br>
## Half Lambert
- 램버트의 계산 결과 범위를 [-1.0, 1.0]에서 [0.0, 1.0]으로 옮긴 것
```glsl
Diffuse = NdL * 0.5 + 0.5
```

<br>
# Specular
---
## Phong
- Phong Reflection의 기본 원리 : 보는 방향으로부터 반사된 방향에 조명이 있으면, 그 부분의 하이라이트가 가장 높다
- 반사 벡터 R = 2N(NdL) - L
- 또는 R = reflect(-L, N);
- RdV = dot(R, V)
- RdV를 기본으로, 연산을 다양하게 커스터마이징하여 스페큘러를 계산할 수 있다.
```hlsl
Specular = pow( saturate(RdV), 10) * 0.5
```

<br>
## Blinn Phong
- Phong 스페큘러에서 R 벡터 계산은 비싸기 때문에, 비슷하지만 더 저렴한 하프 벡터를 이용한다.
- 하프 벡터 H = normalize(L + V)
- NdH = dot(N, H)
```glsl
Specular = pow( saturate(NdH), 100 )
```

<br>
![](https://user-images.githubusercontent.com/42164422/105632082-d1070100-5e94-11eb-8863-189edb9fcb0d.png)


# Rim Light
---
- 프레넬 현상 : 물체를 바라볼 때 정면보다 측면일 수록 더 많은 빛을 반사하는 현상
- 노멀 벡터와 뷰 벡터의 도트 연산을 이용한다.
- 프레넬 공식
```hlsl
Fresnel = pow(1 - NdV, 3)
```

# 라이팅 함수 공식
---
```glsl
Diffuse * LightColor * distanceAtten * shadowAtten + Specular + RimLight
```
