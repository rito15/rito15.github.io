---
title: 앰플리파이 쉐이더 입문자를 위한 60가지 노드 모음
author: Rito15
date: 2021-06-24 01:23:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# 목표
---

- 앰플리파이 쉐이더 그래프를 다루기 위해 필요한, **아주** 기초적인 60가지 노드 익히기

<br>

# 목차
---

- **프로퍼티(변수)**
  - [Int (0)](#int)
  - [Float (1)](#float)
  - [Vector2 (2)](#vector2)
  - [Vector3 (3)](#vector3)
  - [Vector4 (4)](#vector4)
  - [Color (5)](#color)
  - [Texture Sample (T)](#texture-sample)

- **상수**
  - [PI](#pi)
  - [Tau](#tau)

- **정점 데이터**
  - [Vertex Position](#vertex-position)
  - [World Position](#world-position)
  - [Vertex Normal](#vertex-normal)
  - [World Normal](#world-normal)
  - [Vertex Color](#vertex-color)

- **UV**
  - [Vertex TexCoord](#vertex-texcoord)
  - [Texture Coordinates (U)](#texture-coordinates)
  - [Panner](#panner)
  - [Rotator](#rotator)

- **사칙 연산**
  - [Add (A)](#add)
  - [Subtract (S)](#subtract)
  - [Multiply (M)](#multiply)
  - [Divide (D)](#divide)

- **단항 연산**
  - [Abs](#abs)
  - [Ceil](#ceil)
  - [Floor](#floor)
  - [Round](#round)
  - [Fract](#fract)
  - [One Minus (O)](#one-minus)
  - [Negate](#negate)
  - [Saturate](#saturate)
  - [Scale](#scale)

- **다항 연산**
  - [Power (E)](#power)
  - [Min](#min)
  - [Max](#max)
  - [Clamp](#clamp)
  - [Lerp (L)](#lerp)
  - [Step](#step)
  - [Smoothstep](#smoothstep)
  - [Remap](#remap)

- **벡터 연산**
  - [Append (V)](#append)
  - [Component Mask (K)](#component-mask)
  - [Split (B)](#split)
  - [Swizzle (Z)](#swizzle)
  - [Normalize (N)](#normalize)
  - [Dot (.)](#dot)
  - [Cross (X)](#cross)
  - [Distance](#distance)
  - [Length](#length)

- **삼각함수**
  - [Sin](#sin)
  - [Cos](#cos)
  - [Tan](#tan)

- **시간**
  - [Time](#time)
  - [Sin Time](#sin-time)
  - [Cos Time](#cos-time)

- **공간 변환**
  - [Object To World](#object-to-world)
  - [World To Object](#world-to-object)

- **스크린**
  - [Screen Position](#screen-position)
  - [Grab Screen Color](#grab-screen-color)

- **효과**
  - [Fresnel](#fresnel)


<br>

<br>

# 프로퍼티(변수)
---

## **Int**

![image](https://user-images.githubusercontent.com/42164422/122809610-49210800-d309-11eb-939f-4e7dfd9ab93c.png)

### **설명**
 - 단축키 : `[0]`
 - 정수 타입의 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Int>


<br>

---

## **Float**

![image](https://user-images.githubusercontent.com/42164422/122809614-4aeacb80-d309-11eb-8688-175d9576cfcf.png)

### **설명**
 - 단축키 : `[1]`
 - 실수 타입의 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Float>


<br>

---

## **Vector2**

![image](https://user-images.githubusercontent.com/42164422/122809619-4c1bf880-d309-11eb-8e80-431055041a11.png)

### **설명**
 - 단축키 : `[2]`
 - 두 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector2>


<br>

---

## **Vector3**

![image](https://user-images.githubusercontent.com/42164422/122809621-4de5bc00-d309-11eb-8365-b249da9aa6f0.png)

### **설명**
 - 단축키 : `[3]`
 - 세 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector3>


<br>

---

## **Vector4**

![image](https://user-images.githubusercontent.com/42164422/122809625-4f16e900-d309-11eb-9d6d-bcbe31d5c8cb.png)

### **설명**
 - 단축키 : `[4]`
 - 네 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector4>


<br>

---

## **Color**

![image](https://user-images.githubusercontent.com/42164422/122809703-6b1a8a80-d309-11eb-8c7f-8445967edd18.png)

### **설명**
 - 단축키 : `[5]`
 - 네 개의 실수(Float)를 통해 색상을 표현하는 값
 - Vector4와 동일하게 사용될 수 있다.
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Color>


<br>

---

## **Texture Sample**

![image](https://user-images.githubusercontent.com/42164422/122810584-7de18f00-d30a-11eb-9bf3-d25a83e8977a.png)

### **설명**
 - 단축키 : `[T]`
 - 텍스쳐 오브젝트와 샘플링 기능이 합쳐진 형태의 노드
 - 다른 텍스쳐 오브젝트로부터 `Tex`를 입력받거나, 텍스쳐를 직접 선택하여 사용할 수 있다.
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.
 - 노드 내에 보이는 프리뷰에 좌클릭하여, RGBA 채널 중 프리뷰에 나타낼 채널을 선택할 수 있다.

### **입력**
 - `Tex` : 다른 텍스쳐 오브젝트로부터 텍스쳐를 입력받는다. 비워둘 경우, 이 노드 내에서 텍스쳐를 직접 선택해 사용한다.
 - `UV` : 텍스쳐를 적용할 UV를 입력받는다. 비워둘 경우, 메시의 정점 UV 데이터를 사용한다.
 - `SS` : 텍스쳐를 색상으로 변환할 때의 정보를 입력받는다. 보통은 비워둔다.

### **출력**
 - `RGBA` : Color 또는 Vector4 타입으로 사용될 수 있는, 4채널로 이루어진 색상값
 - `R`, `G`, `B`, `A` : 각 채널의 Float 타입 값
 
### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Texture_Sample>


<br>

<br>

---

# 상수
---

## **PI**

![image](https://user-images.githubusercontent.com/42164422/122809710-6c4bb780-d309-11eb-8036-8926d4b67e89.png)

### **설명**
 - 단축키 : 없음
 - 상수 PI(파이)는 세 가지 의미를 지닌다.
   1. 실수 값 : `3.14`
   2. Radian(라디안) 각도 : `3.14`
   3. Degree 각도 : `180˚`

### **입력**
 - `Multiplier` : PI에 곱해질 값. 기본 값은 1이다.

### **출력**
 - `Multiplier` X `PI`의 계산값

### **예시**
 - **Rotator** 노드를 이용해 UV를 회전시켜 텍스쳐에 적용한다.
 - Float 프로퍼티의 값이 0부터 2까지 증가할 때 PI 노드의 결과값은 0부터 약 6.28까지 증가하며, 각도로는 0도부터 360도까지 증가하는 것과 같다.
 
![2021_0622_PI_Node_Example](https://user-images.githubusercontent.com/42164422/122925138-81742500-d3a1-11eb-90a3-3c2819897940.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/PI>


<br>

---

## **Tau**

![image](https://user-images.githubusercontent.com/42164422/122809715-6e157b00-d309-11eb-8afb-daed3801a663.png)

### **설명**
 - 단축키 : 없음
 - 상수 Tau(타우)는 세 가지 의미를 지닌다.
   1. 실수 값 : `6.28`
   2. Radian(라디안) 각도 : `6.28`
   3. Degree 각도 : `360˚`

### **예시**
 - **Rotator** 노드를 이용해 UV를 회전시켜 텍스쳐에 적용한다.
 - **Float** 프로퍼티의 값이 0부터 1까지 증가할 때 **Float** 프로퍼티와 **Tau** 노드를 곱한 값은 0부터 약 6.28까지 증가하며, 각도로는 0도부터 360도까지 증가하는 것과 같다.

![2021_0622_Tau_Node_Example](https://user-images.githubusercontent.com/42164422/123140616-73520180-d492-11eb-8300-166c838c86c1.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Tau>

<br>

<br>

---

# 정점 데이터
---

## **Vertex Position**

![image](https://user-images.githubusercontent.com/42164422/122811433-6eaf1100-d30b-11eb-8b48-35c7026a22c5.png)

### **설명**
 - 단축키 : 없음
 - 오브젝트 공간을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 위치값
 - 메시 내의 피벗 위치를 원점으로 하는 위치값을 의미한다.

### **출력**
 - `XYZ` : Vector3 타입의 위치값
 - `X`, `Y`, `Z` : Float 타입의 값

### **예시**
 - 0부터 1까지 변화하는 **T** 값에 따라 기존의 정점 위치에서 타겟 월드 좌표로 정점을 이동시킨다.

 - 위치값의 공간 변환 수행 시, `Append` 노드를 이용해 `W` 채널을 `1`로 넣어야 한다.

 - 앰플리파이 쉐이더의 마스터 노드는 `Local Vertex`가 아니라 `Local Vertex Offset`을 입력받으므로, 이 경우에는 최종 계산 결과에서 `Vertex Position`을 빼주어야 한다.

![2021_0626_MoveToWPos1](https://user-images.githubusercontent.com/42164422/123471653-150f5500-d631-11eb-98f6-b6480c3d65d2.gif)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Position>


<br>

---

## **World Position**

![image](https://user-images.githubusercontent.com/42164422/122811434-71116b00-d30b-11eb-9878-1463a6742202.png)

### **설명**
 - 단축키 : 없음
 - 월드 공간을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 위치값
 - 월드의 (0, 0, 0) 위치를 원점으로 하는 위치값을 의미한다.
 - `Vertex Position` 노드를 `Object To World` 노드를 통해 공간 변환한 것과 같다.

### **출력**
 - `XYZ` : Vector3 타입의 위치값
 - `X`, `Y`, `Z` : Float 타입의 값

### **예시**
 - 0부터 1까지 변화하는 **T** 값에 따라 기존의 정점 위치에서 타겟 월드 좌표를 향해 오브젝트 크기를 유지시킨 채로 정점을 이동시킨다.

![2021_0626_MoveToWPos2](https://user-images.githubusercontent.com/42164422/123471661-16408200-d631-11eb-9092-fb65e96208d9.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/World_Position>


<br>

---

## **Vertex Normal**

![image](https://user-images.githubusercontent.com/42164422/122811442-72429800-d30b-11eb-88d6-2aabb0c679ab.png)

### **설명**
 - 단축키 : 없음
 - 오브젝트 공간을 기준으로, 메시 내에 존재하는 모든 정점의 노멀 벡터
 - 화면에 렌더링되는 오브젝트의 노멀 벡터를 사용하려면 `World Normal` 노드를 이용해야 한다.

### **출력**
 - `XYZ` : Vector3 타입의 방향 벡터
 - `X`, `Y`, `Z` : Float 타입의 값

### **특징**
 - 트랜스폼의 스케일 값에 영향을 받는다.(`lossyScale`로 나눈 값이 된다.)
 - 따라서 방향벡터로 사용하려면 `Normalize`하여 사용해야 한다.
 - `Object To World`를 통해 월드 노멀로 변환하는 경우에는 `Normalize`하지 않고 바로 입력으로 넣어야 한다.






### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Normal>


<br>

---

## **World Normal**

![image](https://user-images.githubusercontent.com/42164422/146540311-07547431-10a0-437a-b102-0ab44d7c2de6.png)

### **설명**
 - 단축키 : 없음
 - 월드 공간을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 노멀 벡터
 - 실시간으로 월드에 존재하는 오브젝트의 각 정점이 갖고 있는 노멀 벡터를 의미한다.
 - `Vertex Normal` 노드를 `Object To World` 노드를 통해 공간 변환한 것과 같다.

### **출력**
 - `XYZ` : Vector3 타입의 방향 벡터
 - `X`, `Y`, `Z` : Float 타입의 값

### **특징**
 - `Vertex Normal` 노드와 달리, 트랜스폼의 `Scale` 값에 영향을 받지 않는다.
 - 따라서 `Normalize`하지 않고 즉시 방향벡터로 사용될 수 있다.

### **예시**
 - 커스텀 라이팅에서 `Dot(N, L)`의 `N`으로 사용

![image](https://user-images.githubusercontent.com/42164422/123553686-b32d2780-d7b7-11eb-883f-97094b9fc710.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/World_Normal>


<br>

---

## **Vertex Color**

![image](https://user-images.githubusercontent.com/42164422/122811457-78387900-d30b-11eb-9c15-0ca12346b2e6.png)

### **설명**
 - 단축키 : 없음
 - 각 정점이 갖고 있는 색상 데이터 값
 - 오브젝트의 메시는 각 정점마다 위치, 노멀, UV, 색상 등의 데이터를 갖고 있다. 이 노드는 통해 그 중에서 색상 값을 참조하여 출력한다.

### **출력**
 - `RGBA` : Color 또는 Vector4 타입으로 사용될 수 있는, 4채널로 이루어진 색상값
 - `R`, `G`, `B`, `A` : 각 채널의 Float 타입 값

### **예시**
 - 파티클 시스템의 색상은 `Vertex Color`를 통해 전달되므로, 파티클 시스템 쉐이더를 작성할 때 이용한다.

![](https://user-images.githubusercontent.com/42164422/132753357-8e6285cb-5975-4646-9664-41b5be105fa8.png)




### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Color>


<br>

<br>

---

# UV
---

## **Vertex TexCoord**

![image](https://user-images.githubusercontent.com/42164422/122812551-c69a4780-d30c-11eb-80d7-50114541318a.png)

### **설명**
 - 단축키 : 없음
 - 오브젝트가 픽셀마다 갖고 있는 텍스쳐 좌표값
 - `U`, `V`는 각각 `X축`, `Y축` 성분이며, **0 ~ 1** 범위의 값을 가진다.

### **출력**
 - `UV` : Vector2 타입의 UV 값
 - `U`, `V` : 각각 **UV**의 X, Y 좌표값

### **예시**
 - UV의 특정 `U` 값을 기준으로 흑백의 마스크를 생성한다.

![](https://user-images.githubusercontent.com/42164422/123144900-2cb2d600-d497-11eb-9b17-cfa9f1a730fc.gif)




### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_TexCoord>


<br>

---

## **Texture Coordinates**

![image](https://user-images.githubusercontent.com/42164422/122812556-c7cb7480-d30c-11eb-89fc-102be50ae7d4.png)

### **설명**
 - 단축키 : `U`
 - 기본적으로 `Vertex TexCoord` 노드와 동일하지만, UV 타일링과 오프셋(좌표 이동) 설정이 가능하다.

### **입력**
 - `Tex` : UV를 참조할 대상 텍스쳐(비워도 된다.)
 - `Tiling` : U, V를 타일링할 수치를 Vector2 값으로 입력한다.
 - `Offset` : UV 좌표를 이동시킬 수치를 Vector2 값으로 입력한다.

### **출력**
 - `UV` : **Tiling**, **Offset**이 계산된, Vector2 타입의 UV 값
 - `U`, `V` : 각각 **UV**의 X, Y 좌표값

<!-- 예시 없음 -->

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Texture_Coordinates>


<br>

---

## **Panner**

![image](https://user-images.githubusercontent.com/42164422/122812564-c8fca180-d30c-11eb-9b8c-1350e778efa6.png)

### **설명**
 - 단축키 : 없음
 - UV를 원하는 방향과 속도로 이동시킬 때 사용한다.
 - 사실상 `Texture Coordinates` 노드를 조금 다른 방식으로 바꾼 것과 다름없다.

### **입력**
 - `UV` : 이동시킬 대상 UV. 주로 **Vertex TexCoord** 또는 **Texture Coordinate** 노드의 출력 **UV** 값을 연결해 사용한다.
 
 - `Speed` : Vector2 타입의 값으로, 각각 **U**, **V**를 이동시킬 속도를 결정한다. 노드를 클릭해서 **Speed** 값을 직접 입력할 수도 있고, **Vector2** 노드를 연결할 수도 있다.
 
 - `Time` : 주로 **Time** 노드를 연결해 사용하며, 현재 UV의 이동 오프셋(위치 변화량)을 결정한다. **Time** 노드를 연결하지 않아도 자동으로 **Time** 노드를 연결한 것처럼 적용된다.

### **출력**
 - `Out` : Vector2 타입. 최종적으로 계산된 **UV**를 출력한다.

### **예시**
 - `UV`의 `U`를 시간에 따라 이동시키기

![2021_0628_PannerExample](https://user-images.githubusercontent.com/42164422/123555197-2edea280-d7bf-11eb-93b6-026442aeba3d.gif)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Panner>


<br>

---

## **Rotator**

![image](https://user-images.githubusercontent.com/42164422/122812569-cac66500-d30c-11eb-8b9d-087c3aa9ef8e.png)

### **설명**
 - 단축키 : 없음
 - 특정 UV 좌표를 기준으로 전체 UV를 회전시킨다.
 - `Time`이 양수일 경우, 시계 반대방향으로 회전한다.

### **입력**
 - `UV` : 회전시킬 대상 UV. 주로 **Vertex TexCoord** 또는 **Texture Coordinate** 노드의 출력 **UV** 값을 연결해 사용한다.
 
 - `Anchor` : 회전의 기준점이 될 UV 좌표. 노드를 클릭해서 **Anchor** 값을 직접 입력할 수도 있고, `Vector2` 노드를 연결할 수도 있다.
 
 - `Time` : 주로 **Time** 노드를 연결해 사용하며, 현재 UV의 회전 각도를 결정한다. **Time** 노드를 연결하지 않아도 자동으로 **Time** 노드를 연결한 것처럼 적용된다.

### **출력**
 - `Out` : Vector2 타입. 최종적으로 계산된 **UV**를 출력한다.

### **예시**
 - UV 좌표 (0.5, 0.5)를 기준으로 360도 회전시키기

![2021_0917_Rotator_Example](https://user-images.githubusercontent.com/42164422/133803886-42ee1753-248f-4408-8151-4c25e2fa4178.gif)

### **Rotator 노드 내부 구조**

![image](https://user-images.githubusercontent.com/42164422/133809084-290c14ef-1a5f-4312-aeea-fb99e2f65971.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Rotator>


<br>

<br>

---

# 사칙 연산
---

## **Add**

![image](https://user-images.githubusercontent.com/42164422/122884678-57a70800-d379-11eb-9135-a36b1e49a377.png)

### **설명**
 - 단축키 : `[A]`
 - 연결된 노드들의 값을 더한다.
 - 원하는 개수만큼 노드들을 연결할 수 있다.
 
### **입력**
 - `A`, `B`, ... : 더해질 값들. 노드들을 입력에 연결하여 더할 수 있다.

### **출력**
 - 덧셈 결과값. 입력 노드들의 차원이 다를 경우 더 높은 차원의 결과값을 출력한다.
 
 - **Float**와 **Vector2**를 서로 더할 경우, **Float** 값을 **Vector2**의 **X, Y**에 모두 더한 결과를 **Vector2** 타입으로 출력한다. (**Float**와 다른 벡터 타입의 덧셈도 마찬가지)
 
 - **Vector2**와 **Vector3**를 서로 더할 경우, **X, Y**를 각각 더하고 **Vector3**의 **Z**는 그대로 유지한 채로 덧셈 결과를 **Vector3** 타입으로 출력한다.

### **예시**
 - 색상은 더하면 밝아진다.

![image](https://user-images.githubusercontent.com/42164422/134781559-62cffcf8-a266-4d4f-873b-30337607331f.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Add>


<br>

---

## **Subtract**

![image](https://user-images.githubusercontent.com/42164422/122884671-570e7180-d379-11eb-8376-17f7eb454907.png)

### **설명**
 - 단축키 : `[S]`
 - 연결된 노드들의 뺄셈을 수행한다.
 - 두 노드만 연결할 수 있으며, `A - B`를 수행한다.
 - 두 노드의 차원이 다를 경우, 낮은 차원의 값을 높은 차원으로(예 : Float -> Vector2) 끌어올려 계산한다.
 
### **예시**
 - `1 - float4(0, 1, 1, 0)`은 `float4(1, 1, 1, 1) - float4(0, 1, 1, 0)`으로 계산된다.

![image](https://user-images.githubusercontent.com/42164422/134781676-1351a601-8969-4147-ad73-5cfd557a2823.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Subtract>


<br>

---

## **Multiply**

![image](https://user-images.githubusercontent.com/42164422/122884666-55dd4480-d379-11eb-9297-b8bb0f6f0ab7.png)

### **설명**
 - 단축키 : `[M]`
 - 연결된 노드들의 값을 곱한다.
 - 원하는 개수만큼 노드들을 연결할 수 있다.
 
### **입력**
 - `A`, `B`, ... : 곱해질 값들. 노드들을 입력에 연결하여 곱할 수 있다.

### **출력**
 - 곱셈 결과값. 입력 노드들의 차원이 다를 경우 더 높은 차원의 결과값을 출력한다.
 
 - **Float**와 **Vector2**를 서로 곱할 경우, **Float** 값을 **Vector2**의 **X, Y**에 모두 곱한 결과를 **Vector2** 타입으로 출력한다. (**Float**와 다른 벡터 타입의 곱셈도 마찬가지)
 
 - **Vector2**와 **Vector3**를 서로 곱할 경우, **X, Y**를 각각 곱하고 **Vector3**의 **Z**는 그대로 유지한 채로 곱셈 결과를 **Vector3** 타입으로 출력한다.

### **예시**
 - `float4(1, 1, 1, 0) * float2(0, 1)`은 `float4(1, 1, 1, 0) * float4(0, 1, 0, 0)`으로 계산된다.

![image](https://user-images.githubusercontent.com/42164422/134781759-fb72b92b-4283-4b3f-8805-4aa11fe55bfc.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Multiply>


<br>

---

## **Divide**

![image](https://user-images.githubusercontent.com/42164422/122884658-54138100-d379-11eb-9486-669a2bffe197.png)

### **설명**
 - 단축키 : `[D]`
 - 연결된 노드들의 나눗셈을 수행한다.
 - 두 노드만 연결할 수 있으며, `A / B`를 수행한다.
 - 두 노드의 차원이 다를 경우, 낮은 차원의 값을 높은 차원으로(예 : Float -> Vector2) 끌어올려 계산한다.
 
### **예시**
 - 색상을 1보다 큰 값으로 나누면 어두워지고, 1보다 큰 값으로 나누면 밝아진다.

![image](https://user-images.githubusercontent.com/42164422/134782577-3597e0d8-fcd4-47dc-8aa6-ee42a36a728c.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Divide>


<br>

<br>

---

# 단항 연산
---

## **Abs**

![image](https://user-images.githubusercontent.com/42164422/122885353-f9c6f000-d379-11eb-87e3-05f2379c072d.png)

### **설명**
 - 단축키 : 없음
 - 입력 값의 절댓값을 출력한다.
 - 양수는 그대로 양수, 음수는 양수로 바꾸어 출력한다.
 
### **예시**

![image](https://user-images.githubusercontent.com/42164422/134782613-e5de2155-2179-4f57-b64e-85bfff69b7cd.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Abs>


<br>

---

## **Ceil**

![image](https://user-images.githubusercontent.com/42164422/122885362-faf81d00-d379-11eb-9b24-8767f37a041a.png)

### **설명**
 - 단축키 : 없음
 - 입력 값을 올림한 값을 출력한다.
 - 예를 들어 **1.1**은 `2`, **5**는 `5`, **-2.3**은 `-2`가 된다.
 
### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Ceil>


<br>

---

## **Floor**

![image](https://user-images.githubusercontent.com/42164422/122885365-fc294a00-d379-11eb-8053-6c67f303d328.png)

### **설명**
 - 단축키 : 없음
 - 입력 값을 내림한 값을 출력한다.
 - 예를 들어 **1.1**은 `1`, **5**는 `5`, **-2.3**은 `-3`이 된다.
 
### **예시**
 - `UV`를 타일링시켜 범위를 늘린다.
 - 예시 : **Tiling = 4 -> UV : 0.0 ~ 4.0**
 - 그리고 `U`와 `V`를 각각 내림하여 서로 더한다.
 - 더한 결과를 `2`로 나머지 연산하면 짝수였던 부분은 `0`, 홀수였던 부분은 `1`이 되어 각각 검은색, 흰색이 된다.

![2021_0626_CheckerBoard](https://user-images.githubusercontent.com/42164422/123473821-0fffd500-d634-11eb-988c-3ed1c20f4130.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Floor>


<br>

---

## **Round**

![image](https://user-images.githubusercontent.com/42164422/122885479-17945500-d37a-11eb-95e5-f74ca6fbe00e.png)

### **설명**
 - 단축키 : 없음
 - 입력 값을 반올림한 값을 출력한다.
 - 예를 들어 **1.5 ~ 2.4**는 `2`, **2.5 ~ 3.4**는 `3`이 된다.
 
### **예시**

![image](https://user-images.githubusercontent.com/42164422/134782889-47f5ce60-a67d-4b61-9db3-faf605acc5c1.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Round>


<br>

---

## **Fract**

![image](https://user-images.githubusercontent.com/42164422/122885483-182ceb80-d37a-11eb-8f9e-c786da4f1ea9.png)

### **설명**
 - 단축키 : 없음
 - 입력 값의 소수 부분만 출력한다.
 - 예를 들어 **1.23**은 `0.23`, **123**은 `0`, **-5.67**은 `-0.67`이 된다.
 
### **예시**
 - 연속적으로 증가 또는 감소하는 값의 경우, 0 ~ 1 사이의 구간이 반복되게 할 수 있다.(타일링)

![image](https://user-images.githubusercontent.com/42164422/134783377-b7c7fea5-c506-4936-8da2-9ca32cddb954.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Fract>


<br>

---

## **One Minus**

![image](https://user-images.githubusercontent.com/42164422/122885497-19f6af00-d37a-11eb-9ace-7e8dc884393b.png)

### **설명**
 - 단축키 : 없음
 - `1 - 입력값`을 출력한다.
 - 색상을 반전시킬 때 주로 사용된다.
 
### **예시**

![image](https://user-images.githubusercontent.com/42164422/134783493-c4f3bb2f-af71-4e4d-8374-223a5b40651a.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/One_Minus>


<br>

---

## **Negate**

![image](https://user-images.githubusercontent.com/42164422/122885593-30046f80-d37a-11eb-981a-20fc42ef2b68.png)

### **설명**
 - 단축키 : 없음
 - 양수는 음수로, 음수는 양수로 부호를 반전시켜 출력한다.
 
### **예시**

![image](https://user-images.githubusercontent.com/42164422/134783838-22d272cc-9575-42c3-93c9-7f107241c41d.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Negate>


<br>

---

## **Saturate**

![image](https://user-images.githubusercontent.com/42164422/122885602-31359c80-d37a-11eb-987e-170356a82d0a.png)

### **설명**
 - 단축키 : 없음
 - 입력값의 범위를 0과 1 사이로 제한한다.
 - 0보다 작은 값은 0으로, 1보다 큰 값은 1로 출력한다.
 - 0과 1 사이의 값은 그대로 출력한다.
 - 라이트, 색상 연산 등에서 매우 자주 쓰인다.
 - `Saturate`를 통해 0 ~ 1 범위 바깥의, 의도치 않은 값들을 제거할 수 있다.
 
### **예시**
 - 가장 기본적인 라이팅(디퓨즈) 연산 `Dot(N, L)`의 결과는 `-1 ~ 1` 범위로 출력된다.
 - 하지만 라이팅 결과 값이 음수가 나오면 이를 활용할 때 의도치 않은 결과가 발생할 수 있으므로, `Saturate`를 통해 범위를 `0 ~ 1` 사이로 제한 해주어야 한다.

![image](https://user-images.githubusercontent.com/42164422/134783929-cfd43a62-a1a9-4c9f-94ac-b33cbfd3fde5.png)





### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Saturate>


<br>

---

## **Scale**

![image](https://user-images.githubusercontent.com/42164422/122885608-3266c980-d37a-11eb-889f-6c8ca20610d6.png)

### **설명**
 - 단축키 : 없음
 - 입력값(Input Port)과 노드 내에 입력한 값을 서로 곱하여 출력한다.
 

<!-- 이건 예시 안쓸 예정 -->



### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Scale>


<br>

<br>

---

# 다항 연산
---

## **Power**

![image](https://user-images.githubusercontent.com/42164422/122887499-ecab0080-d37b-11eb-927f-ad7ab6f9ee06.png)

### **설명**
 - 단축키 : `[E]`
 - `Base`에 `Exp` 제곱한 결과를 출력한다.
 
### **예시**
 - `Fresnel`, `Specular`와 같이 `0 ~ 1` 사이의 값을 갖는 연속 범위 값은 `Power` 노드를 통해 범위를 좁힐 수 있다.
 - 아래의 예시는 `Fresnel` 연산.

![image](https://user-images.githubusercontent.com/42164422/134821266-d2a6823b-db4f-4b87-aaa3-31a02cabd09b.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Power>


<br>

---

## **Min**

![image](https://user-images.githubusercontent.com/42164422/122887526-f59bd200-d37b-11eb-9079-f76964e4e865.png)

### **설명**
 - 단축키 : 없음
 - 두 입력값 중에 더 작은 값을 출력한다.
 - 입력 값이 다중 채널일 경우(Vector2, Vector3, Vector4) 각 채널마다 따로 계산한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Min>


<br>

---

## **Max**

![image](https://user-images.githubusercontent.com/42164422/122887501-eddc2d80-d37b-11eb-8a8d-c03368ec8bbf.png)

### **설명**
 - 단축키 : 없음
 - 두 입력값 중에 더 큰 값을 출력한다.
 - 입력 값이 다중 채널일 경우(Vector2, Vector3, Vector4) 각 채널마다 따로 계산한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Max>


<br>

---

## **Clamp**

![image](https://user-images.githubusercontent.com/42164422/122887699-1cf29f00-d37c-11eb-812f-9469b6b14a7a.png)

### **설명**
 - 단축키 : 없음
 - 입력 값을 `Min` ~ `Max` 사이 범위로 제한한다.
 - 입력 값이 `Min`보다 작다면 `Min`으로 바꾸어 출력한다.
 - 입력 값이 `Max`보다 크다면 `Max`로 바꾸어 출력한다.
 - 입력 값이 `Min`과 `Max` 사이라면 그대로 출력한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Clamp>


<br>

---

## **Lerp**

![image](https://user-images.githubusercontent.com/42164422/122887703-1e23cc00-d37c-11eb-8c0c-97a8cbfdca9a.png)

### **설명**
 - 단축키 : `[L]`
 - 두 입력값 `A`, `B`를 `Alpha` 값을 기반으로 선형 보간하여 출력한다.
 - `Alpha`가 0인 부분은 `A`, 1인 부분은 `B`를 출력하며, <br>
   0 ~ 1 사이의 값은 해당 값에 따라 `A`와 `B`를 부드럽게 보간하여(섞어서) 출력한다.
 - 기준이 되는 값 또는 마스크 텍스쳐 등을 이용해 두 색상이나 텍스쳐를 혼합할 때 주로 사용된다.

### **입력**
 - `A`, `B` : 선형 보간의 대상이 될 입력값
 - `Alpha` : 선형 보간의 판단 기준값. <br>
   보통 0 ~ 1 사이의 값을 사용한다.

### **출력**
 - `A`, `B`가 선형 보간된 결과값

### **예시**
 - `UV`의 `U` 값을 기준으로 색상 혼합하기

![image](https://user-images.githubusercontent.com/42164422/123555001-eecaf000-d7bd-11eb-9a1b-9353a561d5a3.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Lerp>


<br>

---

## **Step**

![image](https://user-images.githubusercontent.com/42164422/122887709-1fed8f80-d37c-11eb-8346-4fc6baf9b478.png)

### **설명**
 - 단축키 : 없음
 - 입력한 두 값의 관계에 따라 0 또는 1을 출력한다.
 - `A > B` 인 부분에는 0을 출력한다.
 - `A <= B` 인 부분에는 1을 출력한다.
 - UV와 같이 연속된 값들을 불연속 영역으로 양분할 때 주로 사용한다.

### **예시**
 - 가장 흔한 예시 중 하나로, `B`에 `UV.x`나 `UV.y`를 넣고 `A`에 `0.0` ~ `1.0` 사이의 상수를 넣으면 해당 상수를 기준점으로 흑백 양분하는 UV 마스크가 만들어진다.

![2021_0624_Step_Example](https://user-images.githubusercontent.com/42164422/123144900-2cb2d600-d497-11eb-9b17-cfa9f1a730fc.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Step>


<br>

---

## **Smoothstep**

![image](https://user-images.githubusercontent.com/42164422/122887881-44496c00-d37c-11eb-8c8f-890bee528eeb.png)

### **설명**
 - 단축키 : 없음
 - **Step**, **Lerp** 노드가 혼합된 듯한 기능을 제공한다.
 - 입력 값이 `Min`보다 작을 경우 0을 출력한다.
 - 입력 값이 `Max`보다 클 경우 1을 출력한다.
 - 입력 값이 `Min`, `Max` 사이일 경우 부드럽게 보간된 값을 출력한다.

### **예시**
 - Dissolve 효과

![2021_0623_Basic_Dissolve_Nodes](https://user-images.githubusercontent.com/42164422/123069599-e2f1cd80-d44d-11eb-950e-2088585127ae.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Smoothstep>


<br>

---

## **Remap**

![image](https://user-images.githubusercontent.com/42164422/122887885-46132f80-d37c-11eb-835f-0f9ee42cd279.png)

### **설명**
 - 단축키 : 없음
 - `Min Old` ~ `Max Old` 범위 내에서의 입력 값을 `Min New` ~ `Max New` 범위로 옮겨 출력한다.
 - 범위 재정의를 위한 복잡한 계산을 **Remap** 노드를 통해 간략화할 수 있다.
 - `0.6` 값을 Old (0, 1)에서 New (0, 10)으로 **Remap**할 경우, `6`이 출력된다.
 - `0.6` 값을 Old (0, 1)에서 New (8, 9)으로 **Remap**할 경우, `8.6`이 출력된다.

### **예시**
 - Degree 프로퍼티를 0 ~ 360 사이로 입력하여, 0 ~ Tau(6.28) 범위로 **Remap** 시킨다.

![2021_0623_Remap_Example](https://user-images.githubusercontent.com/42164422/123075325-197e1700-d453-11eb-9e8e-95d87e2934d8.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Remap>


<br>

<br>

---

# 벡터 연산
---

## **Append**

![image](https://user-images.githubusercontent.com/42164422/122889081-71e2e500-d37d-11eb-8873-21366a340abc.png)

### **설명**
 - 단축키 : `[V]`
 - Float 값들을 모아서 하나의 벡터로 만들어 출력한다.
 - 노드 좌측 상단의 메뉴 버튼을 클릭하여 출력 타입을 선택할 수 있다.
 - 선택 가능한 출력 타입 : **Vector2**, **Vector3**, **Vector4**, **Color**

### **예시**

![image](https://user-images.githubusercontent.com/42164422/123089783-5d2c4d00-d462-11eb-9572-107863a5e51c.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Append>


<br>

---

## **Component Mask**

![image](https://user-images.githubusercontent.com/42164422/122889086-73141200-d37d-11eb-87e5-a53540ba3620.png)

### **설명**
 - 단축키 : `[K]`
 - 입력 벡터에서 원하는 채널만 선택하여 출력할 수 있다.
 - 노드를 클릭하여 쉐이더 에디터 좌측의 정보 탭에서 출력할 채널에 체크/해제할 수 있다.
 - 예를 들어 입력 타입이 **Vector4**이고 **X**, **W**에만 체크할 경우, 입력 벡터의 **X**, **W**를 새로운 **Vector2**의 **X**, **Y**에 각각 할당하여 출력한다.

### **예시**

![image](https://user-images.githubusercontent.com/42164422/123089568-13436700-d462-11eb-9218-1be57e4a63ae.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Component_Mask>


<br>

---

## **Split**

![image](https://user-images.githubusercontent.com/42164422/122889092-74453f00-d37d-11eb-9d18-1d9fd8679dad.png)

### **설명**
 - 단축키 : `[B]`
 - 벡터의 각 채널을 나누어 출력한다.
 - 예를 들어 **Vector3** 값을 입력할 경우, **X**, **Y**, **Z** 값을 각각 나누어 사용할 수 있다.

### **예시**
 - **Color** 연산의 결과를 각각 **R**, **G**, **B**, **A** 채널로 나누어 사용한다.

![image](https://user-images.githubusercontent.com/42164422/123145615-fcb80280-d497-11eb-8944-c8ab18b49565.png)

### **Wiki**
 - <http://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Split>


<br>

---

## **Swizzle**

![image](https://user-images.githubusercontent.com/42164422/122889203-8c1cc300-d37d-11eb-9d70-84ffe6473575.png)

### **설명**
 - 단축키 : `[Z]`
 - 입력 벡터의 각 채널 순서를 원하는 대로 변경하여 출력할 수 있다.
 - 노드를 선택하고 에디터 좌측의 정보 탭에서 각 채널에 출력할 요소를 선택할 수 있다.

### **예시**

![image](https://user-images.githubusercontent.com/42164422/123092087-12600480-d465-11eb-8f5a-4db78267de53.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Swizzle>


<br>

---

## **Normalize**

![image](https://user-images.githubusercontent.com/42164422/122889208-8de68680-d37d-11eb-827c-e351e565e377.png)

### **설명**
 - 단축키 : `[N]`
 - 입력 벡터를 정규화하여 크기가 1인 벡터로 출력한다.
 - 방향 벡터를 만들기 위해 주로 사용된다.

### **예시**
 - 버텍스의 월드 위치로부터 특정 월드 위치를 향하는 방향 벡터를 구하기 위해, 두 위치 벡터를 서로 뺀 뒤 `Normalize` 노드의 입력으로 넣어주었다.

![2021_0629_NormalizeExample](https://user-images.githubusercontent.com/42164422/123691289-65382280-d890-11eb-8442-52698c2c6295.gif)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Normalize>


<br>

---

## **Dot**

![image](https://user-images.githubusercontent.com/42164422/122889214-8f17b380-d37d-11eb-9876-c08148d3bdf2.png)

### **설명**
 - 단축키 : `[.]`
 - 두 입력 벡터를 내적한 결과를 **Float**로 출력한다.

### **예시**
 - 흔히 사용되는 `Fresnel` 노드는 내부적으로 `World Normal`과 `View Dir`의 내적 연산을 이용한다.

![image](https://user-images.githubusercontent.com/42164422/123689008-b266c500-d88d-11eb-8790-65f2ec4865a3.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Dot>


<br>

---

## **Cross**

![image](https://user-images.githubusercontent.com/42164422/122889304-a35bb080-d37d-11eb-90e1-7af2abd9a2ba.png)

### **설명**
 - 단축키 : `[X]`
 - 두 입력 벡터를 외적한 결과를 출력한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Cross>


<br>

---

## **Distance**

![image](https://user-images.githubusercontent.com/42164422/122889307-a48cdd80-d37d-11eb-8e17-621fc2ac97ef.png)

### **설명**
 - 단축키 : 없음
 - 두 벡터 좌표 사이의 거리를 **Float**로 출력한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Distance>


<br>

---

## **Length**

![image](https://user-images.githubusercontent.com/42164422/122889314-a5be0a80-d37d-11eb-86ca-c5e81f05c1da.png)

### **설명**
 - 단축키 : 없음
 - 입력 벡터의 길이를 **Float**로 출력한다.

### **예시**
 - **UV**와 **Length**를 이용해 간단히 원 그리기

![image](https://user-images.githubusercontent.com/42164422/123304885-7284a280-d55a-11eb-9d58-8fb06ff5de44.png)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Length>


<br>

<br>

---

# 삼각함수
---

## **Sin**

![image](https://user-images.githubusercontent.com/42164422/122898343-c25e4080-d385-11eb-9e3a-3d5077815723.png)

### **설명**
 - 단축키 : 없음
 - `Sin(Input)` 값을 출력한다.
 - 사인 함수는 `2 * PI`의 주기를 갖는 주기 함수이다.
 - 사인 함수의 출력 값의 범위는 `-1 ~ 1`이다.
 - `Sin(0) = 0`이다.
 - 일정한 주기와 깔끔한 출력 값 범위를 갖는 특성 덕분에 `Time` 노드와 연계하여 많이 사용된다.

![image](https://user-images.githubusercontent.com/42164422/123308214-5d117780-d55e-11eb-8615-7de519dce748.png)

### **예시**
 - **Time** 노드의 출력을 **Sin** 노드의 입력으로 넣고 `0.1`을 곱하여 시간에 따라 `-0.1 ~ 0.1` 범위로 변하는 값을 만든다.
 - 이 값을 **Vertex Normal** 노드에 곱하여 시간에 따라 정점 노멀 방향과 역방향을 오가는 벡터를 생성하고, 마스터 노드의 **Local Vertex Offset** 입력으로 넣어 정점이 노멀 방향으로 박동하게 한다.

![2021_0625_Sin_Example](https://user-images.githubusercontent.com/42164422/123306240-00ad5880-d55c-11eb-847a-feeba45ffa89.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Sin>


<br>

---

## **Cos**

![image](https://user-images.githubusercontent.com/42164422/122898332-c12d1380-d385-11eb-8a71-1529ce7d23b4.png)

### **설명**
 - 단축키 : 없음
 - `Cos(Input)` 값을 출력한다.
 - 코사인 함수는 `2 * PI`의 주기를 갖는 주기 함수이다.
 - 코사인 함수의 출력 값의 범위는 `-1 ~ 1`이다.
 - `Cos(0) = 1`이다.
 - 코사인 함수는 사인 함수를 x축 방향으로 `-0.5 * PI` 또는 `1.5 * PI` 만큼 옮긴 것과 같다.

![image](https://user-images.githubusercontent.com/42164422/123308372-88946200-d55e-11eb-9b0c-92a81c682f32.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Cos>


<br>

---

## **Tan**

![image](https://user-images.githubusercontent.com/42164422/122898319-bf635000-d385-11eb-8ec5-812ec28d0e68.png)

### **설명**
 - 단축키 : 없음
 - `Tan(Input)` 값을 출력한다.
 - 탄젠트 함수는 잘 쓰이지는 않지만, 대표적인 삼각함수 중 하나이므로 개념을 알고 있는 것이 좋다.

![image](https://user-images.githubusercontent.com/42164422/123310330-ef1a7f80-d560-11eb-8bbe-3f8ffeffe705.png)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Tan>


<br>

<br>

---

# 시간
---

## **Time**

![image](https://user-images.githubusercontent.com/42164422/122899734-069e1080-d387-11eb-8828-2cba07bc5ddf.png)

### **설명**
 - 단축키 : 없음
 - 시간이 지남에 따라 계속 증가하는 값을 출력한다.
 
### **입력**
 - `Scale` : 시간에 곱해질 값을 입력한다.

### **출력**
 - `Out` : **Scale**이 곱해진 결과값을 출력한다.
 
### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Time>


<br>

---

## **Sin Time**

![image](https://user-images.githubusercontent.com/42164422/122899847-27666600-d387-11eb-9e75-2cc6c6c8a361.png)

### **설명**
 - 단축키 : 없음
 - `Time` 노드의 값을 `Sin` 노드의 입력으로 넣은 `Sin(Time)` 값을 출력한다.

### **출력**
 - `t` : `Sin(Time)` 값을 출력한다.
 - `t/2` : `Sin(Time / 2)` 값을 출력한다.
 - `t/4` : `Sin(Time / 4)` 값을 출력한다.
 - `t/8` : `Sin(Time / 8)` 값을 출력한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Sin_Time>


<br>

---

## **Cos Time**

![image](https://user-images.githubusercontent.com/42164422/122899855-28979300-d387-11eb-8d9e-dab956f4dab0.png)

### **설명**
 - 단축키 : 없음
 - `Time` 노드의 값을 `Cos` 노드의 입력으로 넣은 `Cos(Time)` 값을 출력한다.

### **출력**
 - `t` : `Cos(Time)` 값을 출력한다.
 - `t/2` : `Cos(Time / 2)` 값을 출력한다.
 - `t/4` : `Cos(Time / 4)` 값을 출력한다.
 - `t/8` : `Cos(Time / 8)` 값을 출력한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Cos_Time>


<br>

<br>

---

# 공간 변환
---

## **Object To World**

![image](https://user-images.githubusercontent.com/42164422/122900120-61376c80-d387-11eb-9d1a-1a48eeb64c22.png)

### **설명**
 - 단축키 : 없음
 - 오브젝트 공간의 위치 또는 방향 벡터를 월드 공간으로 변환하여 출력한다.
 - **위치 벡터**를 변환할 때 입력 벡터의 `W` 값은 `1`이어야 한다.
 - **방향 벡터**를 변환할 때 입력 벡터의 `W` 값은 `0`이어야 한다.
 - **Vector3** 타입의 위치 벡터를 입력으로 넣을 때, 바로 넣지 말고 `Append` 노드를 통해 `W` 값을 1로 입력하여 **Vector4** 타입으로 전달해야 한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Object_To_World>


<br>

---

## **World To Object**

![image](https://user-images.githubusercontent.com/42164422/122900125-62689980-d387-11eb-8f1c-ba9dee633b1a.png)

### **설명**
 - 단축키 : 없음
 - 월드 공간의 위치 또는 방향 벡터를 오브젝트 공간으로 변환하여 출력한다.
 - **위치 벡터**를 변환할 때 입력 벡터의 `W` 값은 `1`이어야 한다.
 - **방향 벡터**를 변환할 때 입력 벡터의 `W` 값은 `0`이어야 한다.
 - **Vector3** 타입의 위치 벡터를 입력으로 넣을 때, 바로 넣지 말고 `Append` 노드를 통해 `W` 값을 1로 입력하여 **Vector4** 타입으로 전달해야 한다.

### **예시**
 - .







### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/World_To_Object>


<br>

<br>

---

# 스크린 
---

## **Screen Position**

![image](https://user-images.githubusercontent.com/42164422/122900576-c5f2c700-d387-11eb-8a8c-e5830630c08e.png)

### **설명**
 - 단축키 : 없음
 - 현재 화면의 좌하단을 (0, 0), 우상단을 (1, 1)로 하는 **스크린 UV** 좌표 중에서 오브젝트 표면이 위치한 픽셀의 좌표를 받아 출력한다.
 - 노드 좌측 상단의 메뉴 버튼을 통해 **타입**을 설정할 수 있다.

### **타입**
 - `Normalized` : 화면의 UV를 (0, 0) ~ (1, 1) 사이 값으로 받아온다.
 - `Screen` : 화면의 UV를 (0, 0) ~ (화면의 실제 너비, 높이) 사이 값으로 받아온다.

### **출력**
 - `XYZW` : 화면의 UV 좌표값
 - `X`, `Y`, `Z`, `W` : 각 채널의 **Float** 값

### **예시**
 - 화면의 UV를 그대로 색상 값으로 출력하기

![image](https://user-images.githubusercontent.com/42164422/123128331-06386f00-d486-11eb-88b1-3eb902b672c2.png)

![2021_0624_Grab_ScreenUV](https://user-images.githubusercontent.com/42164422/123140137-eb6bf780-d491-11eb-8a50-a82bcadbf432.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Grab_Screen_Position>


<br>

---

## **Grab Screen Color**

![image](https://user-images.githubusercontent.com/42164422/122900584-c7bc8a80-d387-11eb-950e-63325d17bd5f.png)

### **설명**
 - 단축키 : 없음
 - **Grab Pass**를 추가하여 현재 렌더링되는 스크린의 색상을 받아온다.
 - 입력 **UV**에 맞추어 오브젝트 표면에 스크린 색상을 출력한다.
 - 반드시 에디터 좌측의 **Output Node** 속성에서 **Blend Mode**를 `Transparent`로 설정해야 정상적으로 스크린 색상을 출력할 수 있다.

### **입력**
 - `UV` : 스크린 색상을 출력할 **UV**. 보통의 경우 **Screen Position** 노드를 연결하여 사용한다.

### **출력**
 - `RGBA` : 스크린 색상값
 - `R`, `G`, `B`, `A` : 출력 색상의 각 채널 **Float** 값

### **예시**
- 뒤에 보이는 화면의 일렁임 효과

![image](https://user-images.githubusercontent.com/42164422/123121601-41d03a80-d480-11eb-87d2-95a447fbd617.png)

![2021_0624_Grab_Screen_Color_Example](https://user-images.githubusercontent.com/42164422/123121898-81972200-d480-11eb-8910-6f5d89ffce29.gif)


### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Grab_Screen_Color>


<br>

<br>

---

# 효과
---

## **Fresnel**

![image](https://user-images.githubusercontent.com/42164422/122900679-dc008780-d387-11eb-8ca6-b3ad7bb15cea.png)

### **설명**
 - 단축키 : 없음
 - 월드 노멀 벡터와 뷰 벡터(카메라의 방향벡터)의 **Dot** 연산을 통해 오브젝트의 외곽 영역을 강조하는 **Fresnel Effect** 계산의 결과를 출력한다.
 - 공식 : `Bias + Scale * ( pow( 1- dot(N, V), Power) )`

### **입력**
 - `Bias` : 전체 계산 결과에 더해질 값 (기본값 : 0)
 - `Scale` : Fresnel 계산 결과에 곱해질 값 (기본값 : 1)
 - `Power` : **dot(N, V)** 계산 결과를 제곱할 지수값 (기본값 : 5)

### **출력**
 - `Out` : Fresnel 계산 결과값

### **예시**

![2021_0624_Fresnel_Example](https://user-images.githubusercontent.com/42164422/123135507-d771c700-d48c-11eb-8b7e-aee274833e43.gif)

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Fresnel>

<br>

<br>

# References
---
- <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Nodes>