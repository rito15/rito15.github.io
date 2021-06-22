
# 목표
---

- 앰플리파이 쉐이더 그래프를 다루기 위해 필요한, 아주 기초적인 60가지 노드 익히기

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
  - [Grab Scene Color](#grab-scene-color)

- **효과**
  - [Fresnel](#fresnel)


<br>




### **설명**
 - 단축키 : `[0]` 또는 없음
 - 

### **입력**
 - .

### **출력**
 - .

### **예시**
 - .

### **Wiki**
 - <URL>




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


## **Float**

![image](https://user-images.githubusercontent.com/42164422/122809614-4aeacb80-d309-11eb-8688-175d9576cfcf.png)

### **설명**
 - 단축키 : `[1]`
 - 실수 타입의 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Float>

<br>


## **Vector2**

![image](https://user-images.githubusercontent.com/42164422/122809619-4c1bf880-d309-11eb-8e80-431055041a11.png)

### **설명**
 - 단축키 : `[2]`
 - 두 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector2>

<br>


## **Vector3**

![image](https://user-images.githubusercontent.com/42164422/122809621-4de5bc00-d309-11eb-8365-b249da9aa6f0.png)

### **설명**
 - 단축키 : `[3]`
 - 세 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector3>

<br>


## **Vector4**

![image](https://user-images.githubusercontent.com/42164422/122809625-4f16e900-d309-11eb-9d6d-bcbe31d5c8cb.png)

### **설명**
 - 단축키 : `[4]`
 - 네 개의 실수(Float)로 이루어진 값
 - 노드 좌측 상단의 메뉴를 클릭하여 프로퍼티로 변경할 수 있다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vector4>

<br>


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



# 상수
---

## **PI**

![image](https://user-images.githubusercontent.com/42164422/122809710-6c4bb780-d309-11eb-8036-8926d4b67e89.png)

### **설명**
 - 단축키 : 없음
 - 상수 PI(파이)는 두 가지 의미를 지닌다.
   - 1. 값 : `3.14` (반올림된 값)
   - 2. 각도 : `180˚`

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

## **Tau**

![image](https://user-images.githubusercontent.com/42164422/122809715-6e157b00-d309-11eb-8afb-daed3801a663.png)

### **설명**
 - 단축키 : 없음
 - 상수 Tau(타우)는 두 가지 의미를 지닌다.
   - 1. 값 : `6.28` (반올림된 값)
   - 2. 각도 : `360˚`

### **예시**
 - **Rotator** 노드를 이용해 UV를 회전시켜 텍스쳐에 적용한다.
 - Float 프로퍼티의 값이 0부터 1까지 증가할 때 Float 프로퍼티와 Tau 노드를 곱한 값은 0부터 약 6.28까지 증가하며, 각도로는 0도부터 360도까지 증가하는 것과 같다.

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Tau>

<br>


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
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Position>

<br>

## **World Position**

![image](https://user-images.githubusercontent.com/42164422/122811434-71116b00-d30b-11eb-9878-1463a6742202.png)

### **설명**
 - 단축키 : 없음
 - 월드 공간(씬뷰 및 게임뷰)을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 위치값
 - 월드의 (0, 0, 0) 위치를 원점으로 하는 위치값을 의미한다.
 - `Vertex Position` 노드를 `Object To World`로 공간변환한 것과 같다.

### **출력**
 - `XYZ` : Vector3 타입의 위치값
 - `X`, `Y`, `Z` : Float 타입의 값

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/World_Position>

<br>

## **Vertex Normal**

![image](https://user-images.githubusercontent.com/42164422/122811442-72429800-d30b-11eb-88d6-2aabb0c679ab.png)

### **설명**
 - 단축키 : 없음
 - 오브젝트 공간을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 노멀 벡터
 - 화면에 렌더링되는 오브젝트의 노멀 벡터를 사용하려면 **World Normal** 노드를 이용해야 한다.

### **출력**
 - `XYZ` : Vector3 타입의 방향 벡터
 - `X`, `Y`, `Z` : Float 타입의 값

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Normal>

<br>

## **World Normal**

![image](https://user-images.githubusercontent.com/42164422/122811445-74a4f200-d30b-11eb-88d7-21bba7b635b8.png)

### **설명**
 - 단축키 : 없음
 - 월드 공간을 기준으로, 메시 내에 존재하는 각각의 모든 정점의 노멀 벡터
 - 실시간으로 월드에 존재하는 오브젝트의 각 정점이 갖고 있는 노멀 벡터를 의미한다.
 - `Vertex Normal` 노드를 `Object To World`로 공간변환한 것과 같다.
 - 크기가 항상 1이라는 보장이 없으므로, 필요하다면 정규화하여 사용해야 한다.

### **출력**
 - `XYZ` : Vector3 타입의 방향 벡터
 - `X`, `Y`, `Z` : Float 타입의 값

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/World_Normal>

<br>

## **Vertex Color**

![image](https://user-images.githubusercontent.com/42164422/122811457-78387900-d30b-11eb-9c15-0ca12346b2e6.png)

### **설명**
 - 단축키 : 없음
 - 각 정점이 갖고 있는 색상 데이터 값
 - 메시 내에는 각 정점마다 위치, 노멀, UV, 색상 등의 데이터를 갖고 있으며, 이 노드를 통해 그 중에서 색상 값을 참조한다.

### **출력**
 - `RGBA` : Color 또는 Vector4 타입으로 사용될 수 있는, 4채널로 이루어진 색상값
 - `R`, `G`, `B`, `A` : 각 채널의 Float 타입 값

=======================================================================


                   예                                 제


=======================================================================

### **예시**
 - .

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_Color>

<br>


<br>

# UV
---

## **Vertex TexCoord**

![image](https://user-images.githubusercontent.com/42164422/122812551-c69a4780-d30c-11eb-80d7-50114541318a.png)

### **설명**
 - 단축키 : 없음
 - 메시의 정점마다 갖고 있는 UV 좌표값

### **출력**
 - `UV` : Vector2 타입의 UV 값
 - `U`, `V` : 각각 **UV**의 X, Y 좌표값

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Vertex_TexCoord>

<br>

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

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Texture_Coordinates>

<br>

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
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Panner>

<br>

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
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Rotator>


<br>

# 사칙 연산
---

## **Add**

![image](https://user-images.githubusercontent.com/42164422/122884678-57a70800-d379-11eb-9135-a36b1e49a377.png)

### **설명**
 - 단축키 : `[A]`
 - 

### **입력**
 - .

### **출력**
 - .

### **예시**
 - .

=======================================================================


                   예                                 제


=======================================================================

### **Wiki**
 - <URL>

<br>

## **Subtract**

![image](https://user-images.githubusercontent.com/42164422/122884671-570e7180-d379-11eb-8376-17f7eb454907.png)

## **Multiply**

![image](https://user-images.githubusercontent.com/42164422/122884666-55dd4480-d379-11eb-9297-b8bb0f6f0ab7.png)

## **Divide**

![image](https://user-images.githubusercontent.com/42164422/122884658-54138100-d379-11eb-9486-669a2bffe197.png)


<br>

# 단항 연산
---

## **Abs**

![image](https://user-images.githubusercontent.com/42164422/122885353-f9c6f000-d379-11eb-87e3-05f2379c072d.png)

## **Ceil**

![image](https://user-images.githubusercontent.com/42164422/122885362-faf81d00-d379-11eb-9b24-8767f37a041a.png)

## **Floor**

![image](https://user-images.githubusercontent.com/42164422/122885365-fc294a00-d379-11eb-8053-6c67f303d328.png)

## **Round**

![image](https://user-images.githubusercontent.com/42164422/122885479-17945500-d37a-11eb-95e5-f74ca6fbe00e.png)

## **Fract**

![image](https://user-images.githubusercontent.com/42164422/122885483-182ceb80-d37a-11eb-8f9e-c786da4f1ea9.png)

## **One Minus**

![image](https://user-images.githubusercontent.com/42164422/122885497-19f6af00-d37a-11eb-9ace-7e8dc884393b.png)

## **Negate**

![image](https://user-images.githubusercontent.com/42164422/122885593-30046f80-d37a-11eb-981a-20fc42ef2b68.png)

## **Saturate**

![image](https://user-images.githubusercontent.com/42164422/122885602-31359c80-d37a-11eb-987e-170356a82d0a.png)

## **Scale**

![image](https://user-images.githubusercontent.com/42164422/122885608-3266c980-d37a-11eb-889f-6c8ca20610d6.png)


<br>

# 다항 연산
---

## **Power**

![image](https://user-images.githubusercontent.com/42164422/122887499-ecab0080-d37b-11eb-927f-ad7ab6f9ee06.png)

## **Min**

![image](https://user-images.githubusercontent.com/42164422/122887526-f59bd200-d37b-11eb-9079-f76964e4e865.png)

## **Max**

![image](https://user-images.githubusercontent.com/42164422/122887501-eddc2d80-d37b-11eb-8a8d-c03368ec8bbf.png)

## **Clamp**

![image](https://user-images.githubusercontent.com/42164422/122887699-1cf29f00-d37c-11eb-812f-9469b6b14a7a.png)

## **Lerp**

![image](https://user-images.githubusercontent.com/42164422/122887703-1e23cc00-d37c-11eb-8c0c-97a8cbfdca9a.png)

## **Step**

![image](https://user-images.githubusercontent.com/42164422/122887709-1fed8f80-d37c-11eb-8346-4fc6baf9b478.png)

## **Smoothstep**

![image](https://user-images.githubusercontent.com/42164422/122887881-44496c00-d37c-11eb-8c8f-890bee528eeb.png)

## **Remap**

![image](https://user-images.githubusercontent.com/42164422/122887885-46132f80-d37c-11eb-835f-0f9ee42cd279.png)


<br>

# 벡터 연산
---

## **Append**

![image](https://user-images.githubusercontent.com/42164422/122889081-71e2e500-d37d-11eb-8873-21366a340abc.png)

## **Component Mask**

![image](https://user-images.githubusercontent.com/42164422/122889086-73141200-d37d-11eb-87e5-a53540ba3620.png)

## **Split**

![image](https://user-images.githubusercontent.com/42164422/122889092-74453f00-d37d-11eb-9d18-1d9fd8679dad.png)

## **Swizzle**

![image](https://user-images.githubusercontent.com/42164422/122889203-8c1cc300-d37d-11eb-9d70-84ffe6473575.png)

## **Normalize**

![image](https://user-images.githubusercontent.com/42164422/122889208-8de68680-d37d-11eb-827c-e351e565e377.png)

## **Dot**

![image](https://user-images.githubusercontent.com/42164422/122889214-8f17b380-d37d-11eb-9876-c08148d3bdf2.png)

## **Cross**

![image](https://user-images.githubusercontent.com/42164422/122889304-a35bb080-d37d-11eb-90e1-7af2abd9a2ba.png)

## **Distance**

![image](https://user-images.githubusercontent.com/42164422/122889307-a48cdd80-d37d-11eb-8e17-621fc2ac97ef.png)

## **Length**

![image](https://user-images.githubusercontent.com/42164422/122889314-a5be0a80-d37d-11eb-86ca-c5e81f05c1da.png)


<br>

# 삼각함수
---

## **Sin**

![image](https://user-images.githubusercontent.com/42164422/122898343-c25e4080-d385-11eb-9e3a-3d5077815723.png)

## **Cos**

![image](https://user-images.githubusercontent.com/42164422/122898332-c12d1380-d385-11eb-8a71-1529ce7d23b4.png)

## **Tan**

![image](https://user-images.githubusercontent.com/42164422/122898319-bf635000-d385-11eb-8ec5-812ec28d0e68.png)


<br>

# 시간
---

## **Time**

![image](https://user-images.githubusercontent.com/42164422/122899734-069e1080-d387-11eb-8828-2cba07bc5ddf.png)

## **Sin Time**

![image](https://user-images.githubusercontent.com/42164422/122899847-27666600-d387-11eb-9e75-2cc6c6c8a361.png)

## **Cos Time**

![image](https://user-images.githubusercontent.com/42164422/122899855-28979300-d387-11eb-8d9e-dab956f4dab0.png)


<br>

# 공간 변환
---

## **Object To World**

![image](https://user-images.githubusercontent.com/42164422/122900120-61376c80-d387-11eb-9d1a-1a48eeb64c22.png)

## **World To Object**

![image](https://user-images.githubusercontent.com/42164422/122900125-62689980-d387-11eb-8f1c-ba9dee633b1a.png)


<br>

# 스크린 
---

## **Screen Position**

![image](https://user-images.githubusercontent.com/42164422/122900576-c5f2c700-d387-11eb-8a8c-e5830630c08e.png)

## **Grab Scene Color**

![image](https://user-images.githubusercontent.com/42164422/122900584-c7bc8a80-d387-11eb-950e-63325d17bd5f.png)


<br>

# 효과
---

## **Fresnel**

![image](https://user-images.githubusercontent.com/42164422/122900679-dc008780-d387-11eb-8ca6-b3ad7bb15cea.png)


<br>

# References
---
- <https://wiki.amplify.pt/index.php?title=Unity_Products:Amplify_Shader_Editor/Nodes>