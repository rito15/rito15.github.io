---
title: 렌더링 파이프라인 간단 정리
author: Rito15
date: 2021-08-30 01:50:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics]
math: true
mermaid: true
---

# 렌더링 파이프라인 구조 요약(DirectX 9 기준)
---

## **입력 조립**
 - GPU가 CPU로부터 정점 데이터를 전달 받아서 프리미티브(삼각형)들을 만든다.

## **정점 쉐이더**
 - Object Space에서 Clip Space까지 정점들의 공간 변환을 수행한다.
 
## **래스터라이저**
 - Clip Space의 정점 데이터를 Viewport로 변환하고, <br>
   정점 데이터를 기반으로 보간된 프래그먼트(픽셀 데이터)를 생성한다.
 
## **픽셀(프래그먼트) 쉐이더**
 - 프래그먼트를 입력 받아 화면에 그려질 모든 픽셀의 색상과 깊이 값을 출력한다.
 
## **출력 병합**
 - Z-Test, Stencil Test, Alpha Blending 등을 통해 최종적으로 화면에 그려질 색상을 결정한다.

<br>

# 참고 : DirectX 11 렌더링 파이프라인 구조
---

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/133432245-c2001cb0-5a22-405d-9c4d-60ba5611eb1d.png)

## **지오메트리 쉐이더(Geometry Shader)**
- DirectX10에서 새롭게 추가된 쉐이더
- 입력 받은 정점 데이터에서는 존재하지 않았던 새로운 점, 선, 면(삼각형) 등을 새롭게 생성하거나 기존의 정점을 제거할 수 있다.
- 기존의 프리미티브(삼각형)를 다른 모양으로 바꿀 수도 있다.

## **테셀레이션 쉐이더(Tessellation Shader)**
- DirectX11에서 새롭게 추가된 쉐이더
- 프리미티브(삼각형)를 더 잘게 쪼개서 새로운 정점들을 생성한다.

</details>

<br>


# 1. 입력 조립(Input Assembly)
---

- 렌더링 파이프라인의 첫 단계

- 정점 데이터를 **CPU**에서 **GPU**로 운반하기 위한 자료 구조를 **정점 버퍼**라고 한다.

- 정점 버퍼는 **위치, 노말, 색상, UV**를 담고 있는데, <br>
  구조체로 이쁘게 담고 있는게 아니고 직렬화된 형태(배열)로 담고 있다.

- 그리고 GPU에서는 이렇게 전달 받은 정점 버퍼를, <br>
  미리 전달 받은 렌더 상태의 버텍스 명세를 통해 정점 데이터(구조체)로 조립한다.

- 그런데 이렇게 정점 버퍼를 정점 데이터로 조립한다고 입력 조립이 아니고, <br>
- 정점들을 모아서 삼각형과 같은 **기본 도형(프리미티브, Primitive)**으로 조립해주기 때문에 입력 조립 단계라고 한다.

- 이렇게 조립된 프리미티브가 정점 쉐이더의 입력이 된다.

<br>

<details>
<summary markdown="span"> 
...
</summary>

## **커맨드 큐(Command Queue)**
 - GPU는 CPU보다 훨씬 빠르다.
 - 그래서 CPU가 GPU에 처리를 요청할 때, 동기적으로 요청하면 반드시 병목이 발생할 수밖에 없다.

 - 따라서 CPU는 요청들을 **커맨드 버퍼(Command Buffer)**에 담아서 커맨드 큐에 넣어두고 <br>
   GPU는 큐에서 버퍼들을 꺼내어 처리해주는 방식으로 병목을 해결한다.

<br>

## **드로우 콜(Draw Call)**
 - CPU에서 GPU에 전달할 명령을 **커맨드 버퍼**에 담아 **커맨드 큐**에 넣는 과정
 - 쉽게 말해, CPU가 GPU에게 메시 좀 그려 달라고 요청하는 것이다.

 - 종류 예시
   - **Set Pass Call** : 렌더 상태 변경 요청(메시를 그리기 위한 환경 설정)
   - **DP Call**(Draw Primitive Call) : 메시 그리기 요청 <br>
 
 - 일반적으로 Set Pass Call 이후 DP Call로 이어진다.

<br>

 - 참고 : **배치(Batch)**
   - Set Pass Call과 DP Call을 합쳐서 지칭하는 드로우 콜
   - 흔히 말하는 드로우 콜이 바로 배치를 의미한다.

 - 참고2 : **배칭(Batching)**
   - 여러 번 나누어 발생할 드로우 콜을 하나로 통합하는 것
   - 같은 마테리얼을 사용하는 경우 등등

<br>

## **렌더 상태(Render States)**
 - 메시를 그리기 위해 필요한 데이터들

 - 정점 데이터(위치, 노말, 색상, UV)
 - 쉐이더
 - 알파 블렌딩 연산, Z-Test 여부 등

<br>

</details>


 
# 2. 정점 쉐이더(Vertex Shader)
---
 - 정점 데이터를 입력 받아 공간 변환을 수행한다.
 
<br>

## **공간 변환 과정**
 - 공간 변환은 각각의 행렬 연산을 통해 이루어진다.
 - 변환 행렬은 총 3가지로, 각각 `Model`, `View`, `Projection`이다.
 - **M, V, P**는 각각 변환 행렬 이름이기도 하고, 변환 자체를 가리키기도 한다.

![image](https://user-images.githubusercontent.com/42164422/131255338-489592de-9f80-4cc7-b69c-e20e871b58aa.png)

<br>

### **M (Model)**
 - **오브젝트 공간(Model Space, Object Space)** -> **월드 공간(World Space)**

 - 각 오브젝트마다 자신의 피벗 위치를 원점(0, 0, 0)으로 하는 좌표 공간을 갖고 있다.
 - 게임 내의 월드는 단 하나의 위치를 원점으로 하는 좌표 공간을 갖고 있다.
 - 모델 변환은 각 오브젝트의 좌표 공간을 변환하여 하나의 월드 공간에 통합하는 과정이다.
 
 - 이 과정에서 **이동(Translate)**, **회전(Rotate)**, **크기(Scale)** 변환이 이루어진다.
 - 이 세가지 변환은 각각 행렬을 통해 수행되고, 이를 하나의 행렬로 만든 것을 **TRS 행렬**이라고 한다.
 
 - **TRS 행렬은** 좌측부터 우측으로 S, R, T 순서로 곱해진다.
 - 그리고 벡터와 곱할 때 벡터가 우측에 온다.
 - 따라서 각각 따로 곱할 때는 행렬을 좌측에 놓고 T, R, S 순서로 곱한다.

<br>

### **V (View)**
 - **월드 공간(World Space)** -> **카메라 공간(View Space)**

 - 카메라 공간은 카메라의 위치가 원점(0, 0, 0)이고, 카메라가 바라보는 방향이 `+Z`축인 공간을 의미한다.
 - 뷰 변환은 모든 오브젝트를 화면에 그려내기 쉽도록 카메라 기준으로 공간을 변환하는 과정이다.

<br>

### **P (Projection)**
 - **카메라 공간(View Space)** -> **클립 공간(Clip Space)**

 - 카메라 기준의 정점 위치를 화면에 보이기 위한 정점 위치로 변환한다.

 - 화면에 렌더링될 수 있는 영역을 나타내는 **절두체(Frustum)**가 정의된다.
 - 절두체는 **Near Clipping Plane**, **Far Clipping Plane**, **Field of View**를 통해 정의한다.
 
 - 절두체를 완전히 벗어나는 폴리곤들은 모두 버려지고 <br>
   절두체의 경계에 걸쳐 있는 폴리곤들은 일단 유지한다.

 - 원근감이 없는 **직교 투영(Orthographic Projection)** 또는 <br>
   원근감이 있는 **원근 투영(Perspective Projection)**이 행해진다.

 - 클립 공간의 좌표계는 사실 3D가 아닌 4D이다.
 - 클립 공간의 모든 X, Y 좌표는 -1 ~ 1 범위에 존재하며, <br>
   Z 좌표는 0 ~ 1 범위에 존재한다.
 - W 값은 카메라에서 멀수록 커지며, 추후 NDC로의 변환에 사용된다.

 - 클립 공간의 4D 좌표계를 **동차 좌표계(Homogeneous Coordinates)**라고 한다.

 - 보통 클립 공간과 NDC를 혼용하는 경우가 많은데, <br>
   엄밀히 말하자면 버텍스 쉐이더의 최종 출력은 클립 공간의 정점 데이터이다. <br>

<br>



# 3. 래스터라이저(Rasterizer)
---

- 하드웨어 자체 알고리즘을 통해 동작한다.
- 프로그래밍이 불가능한, 고정 파이프라인 단계

- 클립 스페이스의 정점 데이터를 전달받아 프래그먼트를 구성하고, <br>
  화면에 출력할 픽셀들을 찾아낸다.
  
- 픽셀 색상 등의 데이터는 정점의 데이터를 기준으로 보간된다.
  
- **프래그먼트(Fragnemt)?**
  - 픽셀 하나의 색상을 화면에 그려내기 위한 정보를 담고 있는 데이터

<br>

## **래스터라이저의 역할**

### **[1] 클리핑(Clipping)**
  - 버텍스 쉐이더의 마지막 단계에서, 절두체를 완전히 벗어나는 폴리곤은 버려졌지만 <br>
    절두체 경계에 걸쳐 있는 폴리곤들은 아직 버려지지 않았다.

  - 래스터라이저에서 이렇게 걸쳐 있는 폴리곤들을 잘라내어, <br>
    절두체 내부와 외부 영역을 분리하여 절두체 외부 영역은 버린다.

<br>

### **[2] 원근 분할(Perspective Division)**
  - 클립 스페이스(동차 좌표계, 4D) 좌표의 모든 요소를 `w` 값으로 나누게 되는데, <br>
    이를 통해 모든 원근법 구현이 완료되며 이를 원근 분할이라고 한다.

  - 원근 분할을 마친 좌표계를 **NDC**라고 한다.

  - **NDC(Normalized Device Coordinates)**
    - **X, Y** 좌표는 모두 -1 ~ 1, **Z** 좌표는 0 ~ 1에 위치하는 좌표계
    - 스크린 좌표로 손쉽게 변환할 수 있도록 하기 위한 3D 공간 변환 상의 마지막 좌표계
    - 클립 스페이스의 (x, y, z)를 w로 나눈 결과이다.

<br>

### **[3] 후면 컬링(Back-face Culling)**
  - View 벡터와 Normal 벡터의 관계를 통해 후면을 찾아내어 <br>
    렌더링되지 않도록 면을 제거한다.

<br>

### **[4] 뷰포트 변환(Viewport Transformation)**
  - 3D NDC 공간 상의 좌표를 2D 스크린 좌표로 변환한다.
  - -1 ~ 1 범위였던 (X, Y) 좌표를 화면 해상도 범위로 변환한다.
  - 2D 공간으로 변환한다고 하지만, 실제로는 Z값을 깊이 값으로 사용하기 위해 그대로 유지한다.

<br>

### **[5] 스캔 변환(Scan Transformation)**
  - 프리미티브(기본 도형, 삼각형 등)를 통해 `프래그먼트`를 생성하고 <br>
    프래그먼트를 채우는 픽셀들을 찾아낸다.
  - 각 픽셀마다 정점 데이터(위치, 색상, 노멀, UV)들을 보간하여 할당한다.

<br>



# 4. 픽셀 쉐이더(Pixel Shader)
---
- DirectX에서는 픽셀 쉐이더,
  OpenGL과 유니티 엔진에서는 프래그먼트 쉐이더(Fragment Shader)라고 부른다.
 
- 픽셀 쉐이더는 모델이 화면에서 차지하는 픽셀의 개수만큼 실행된다.
- 쉐이더를 통해 색상을 변화시키는 것은 모두 픽셀 쉐이더의 역할이라고 보면 된다.

- 투명도를 결정 하는 것도 픽셀 쉐이더, <br>
  라이팅과 그림자를 적용하는 것도 픽셀 쉐이더, <br>
  텍스쳐 색상을 메시에 입히는 것도 모두 픽셀 쉐이더에서 하는 역할이다.

- 픽셀 쉐이더는 각 픽셀들의 색상과 깊이 값을 출력으로 전달한다.
- 깊이 값은 **Z-Buffer**에, 색상 값은 **Color Buffer**에 저장된다.

- 이 때 버퍼는 텍스쳐라고 생각하면 된다.
- 그리고 이런 버퍼들을 통칭하여 **스크린 버퍼(Screen Buffer)**라고 한다.

<br>


# 5. 출력 병합(Output Merge)
---

- 렌더링 파이프라인의 마지막 단계

- 픽셀들을 화면에 출력하기 위한 마지막 연산들을 수행한다.
  - Z-Test
  - Stencil Test
  - Alpha Blending <br>

- 각각의 픽셀 위치마다 여러 오브젝트의 픽셀이 겹쳐 있을 수 있다.
- 출력 병합 단계에서는 이렇게 겹치는 픽셀들을 연산 및 판단하여 픽셀의 최종적인 색상을 결정한다.

<br>

## **프레임 버퍼(Frame Buffer)**

- 한 프레임의 스크린 버퍼들

- 구조
  - **Color Buffer** : 색상 값 텍스쳐
  - **Z-Buffer** : 깊이 값 텍스쳐
  - **Stencil Buffer** : 픽셀을 렌더링 또는 폐기하기 위한 마스크 텍스쳐

<br>


# References
---
- <https://kblog.popekim.com/2011/11/01-part-1.html>
- <https://mingyu0403.tistory.com/110>
- <https://dlgnlfus.tistory.com/135>
- <https://heinleinsgame.tistory.com/11>
- <https://jidon333.github.io/blog/Rendering-pipeline>
- <https://m.blog.naver.com/opse89/221816708567>
- <https://www.youtube.com/playlist?list=PLctzObGsrjfyWa2CaxGtxsLD-W5zYC2JJ>
- <https://mentum.tistory.com/505>

