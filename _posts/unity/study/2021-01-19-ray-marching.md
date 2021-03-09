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

 - 폴리곤의 정점 데이터를 이용하는 기존의 3D 렌더링 방식과는 달리, 레이를 전진시켜(Ray Marching) 표면의 정보를 얻어 오브젝트를 그려내는 기법
 
 - 레이 마칭의 모든 오브젝트들은 폴리곤이 아닌 거리 함수(SDF : Signed Distance Function)로 표면의 정보가 계산된다.

<br>

<center><img src="https://user-images.githubusercontent.com/42164422/104993172-ce0bab00-5a65-11eb-9eda-705de2034f17.png" width="500"></center>
 
 - 한 점(RO : Ray Origin, 위의 그림에서 Camera)에서 스크린의 각각의 픽셀을 향한 방향(RD : Ray Direction, 위의 그림에서 Image)들을 향해
   레이 캐스팅을 하여, 각 레이마다 여러 스텝(Step)으로 나누어 레이를 전진시키게 된다.
   
<br>

<center> <img src="https://user-images.githubusercontent.com/42164422/104993811-c1d41d80-5a66-11eb-9ad3-a861471cce8e.png" width="500"> </center>
   
 - 한 번의 스텝마다 존재하는 모든 SDF를 각각 계산하여 현재 레이 위치로부터 각 오브젝트와의 거리를 얻어낸다.

 - 그 중 현재 레이의 위치로부터 가장 가까운 거리값만큼 레이를 이동한다.
 
 - 레이의 다음 전진 거리가 매우 작으면(예: dS < 0.01) 해당 위치가 물체의 표면이라고 판단하고, 레이의 전진을 중단한다.
 
 - 물체의 표면을 알아내지 못했는데 전진 횟수가 MAX_STEPS를 넘어서면 해당 픽셀에는 모델의 표면이 존재하지 않는다고 판단한다.
 
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

### ShaderToy에서의 구현

- [https://www.shadertoy.com/view/wstBW4](https://www.shadertoy.com/view/wstBW4)

 <center><img src="https://user-images.githubusercontent.com/42164422/105588245-d00e9a80-5dd4-11eb-88ac-a146ee0fc817.png" width="500"></center>
 
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