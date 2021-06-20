---
title: Black Hole &amp; World Position Offset
author: Rito15
date: 2021-06-20 03:33:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

## **World Position Offset Shader**

- 정점이 순차적으로 월드의 특정 좌표에 빨려 들어가는 쉐이더

<br>

## **Black Hole Shader**

- 영역 내의 색상을 왜곡하는 쉐이더

<br>

# Preview
---

![2021_0619_BlackHole_Final](https://user-images.githubusercontent.com/42164422/122681742-de9c9900-d230-11eb-9528-f88e3427a557.gif)

<br>

# WPO - Step 1 : 정점 좌표의 이동
---

World Space의 좌표에 대해 계산해야 하지만,

마스터 노드의 `Vertex Position` 입력은 Object Space여야 한다.

따라서 두 가지 선택지가 있다.

<br>

## [1] World Space에서 계산하고 최종적으로 Object Space로 변환

![image](https://user-images.githubusercontent.com/42164422/122663818-34912280-d1d8-11eb-8229-e5573480a29a.png)

<br>

## [2] 처음부터 Object Space로 변환하고 Object Space에서 계산

![image](https://user-images.githubusercontent.com/42164422/122663999-871f0e80-d1d9-11eb-8aa2-798905ca9e71.png)

<br>

기본적으로 쉐이더 내에서의 계산은 대부분 Object Space에서 이루어진다.

따라서 World Space를 기준으로 계산하게 되면 공간변환의 횟수가 늘어날 수 있으므로

[2]처럼 Object Space를 기준으로 계산하는 방식을 선택한다.

여기서 World Space의 요소는 입력 프로퍼티인 `Target Position`만 존재하므로

해당 프로퍼티를 World -> Object Space로 공간변환한다.

<br>

## **Step 1-[2] 구현 결과**

- `Lerp` 노드를 이용해 정점 좌표를 `Target Position`으로 `t`(Progress) 값(0 ~ 1)에 따라 이동시킨다.

![2021_0619_BlackHole_Step1](https://user-images.githubusercontent.com/42164422/122663938-1972e280-d1d9-11eb-90e2-a5144abf91c7.gif)

<br>

# WPO - Step 2 : Dot를 이용한 마스크 만들기
---

Step 1에서는 모든 정점이 `Progress` 값의 변화에 따라 동일한 비율로 타겟 좌표를 향해 이동한다.

여기에 더 응용하여, 타겟 좌표에 더 가까운 정점일수록 더 빨리, 더 먼 정점일수록 더 나중에 이동할 수 있도록 구현할 것이다.

이를 구현하기 위해서는 각 정점과 타겟 좌표와의 관계를 구할 수 있어야 하는데,

이 때 [정점의 노멀 벡터]와 [정점 -> 타겟 좌표를 향하는 방향 벡터]를 이용한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/122667423-d5d6a380-d1ed-11eb-824a-87e3a847ceb5.png)

위 그림을 통해,

[노멀 벡터]와 [방향 벡터]가 이루는 각도가 작을수록

해당 정점은 타겟 위치에 더 가깝다는 사실을 알 수 있다.

따라서 이를 '마스크' 형태로 얻어내기 위해 `Dot` 노드를 이용한다.

<br>

`Dot` 노드는 크기가 1인 두 방향벡터가 이루는 각도에 따라서

0이면(두 방향벡터가 평행 또는 일치하면) `1`,

90이면 `0`, -90이면 `-1`의 결과값을 얻을 수 있다.

<br>

[노멀 벡터]는 애초에 크기가 1인 방향벡터이므로 그대로 사용하고,

[방향 벡터]는 `Normalize` 노드를 통해 크기가 1인 벡터로 바꾸어

두 벡터를 `Dot` 노드에 넣어주면

![image](https://user-images.githubusercontent.com/42164422/122665697-b5095080-d1e3-11eb-8bec-eb07b22d907b.png)

결과로 [-1, 1] 분포를 갖는 마스크를 얻을 수 있다.

<br>

# WPO - Step 3 : Progress에 따라 빨려들어가게 하기
---

Step 2를 이용해 구한 마스크의 값은 [-1, 1] 범위로 분포한다.

이 마스크를 이용하여 `Progress` 값의 변화에 따라 정점이 타겟 좌표로 순차적으로 빨려들어가게 만들어야 한다.

<br>

우선, 마스크와 같이 정지된 순간에 연속된 값의 분포는 [a, b]처럼 표기한다.

그리고 `Progress`와 같이 프로퍼티 또는 시간의 흐름에 따라 변화하는 값의 범위는 (a ~ b)처럼 표기한다.

예를 들어 `Progress`의 범위가 (0 ~ 1)이므로, `Progress + 1`은 (1 ~ 2)가 된다.

그리고 마스크의 분포가 [-1, 1]이므로 `Progress + 마스크`는 ([-1, 1] ~ [0, 2])가 된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/122666088-33ff8880-d1e6-11eb-982a-cc53364210aa.png)

Step 1의 `Lerp` 노드에서

`t` 값이 0이면 정점은 원래의 좌표에 위치하고,

`t` 값이 1이면 정점은 타겟 좌표에 완전히 빨려 들어가게 된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/122666261-2eef0900-d1e7-11eb-91e0-3cbcd94c07a0.png)

[-1, 1] 분포의 마스크를 그대로 Step 1 `Lerp` 노드의 `t`에 그대로 넣으면

`t`에서 -1 값을 갖는, 타겟 좌표에서 가장 멀리 떨어진 정점은 오히려 기존의 정점 좌표에서 타겟 좌표의 반대 방향으로 멀어지게 되고

`t`에서 1의 값을 갖는, 타겟 좌표와 가장 가까운 정점은 타겟 좌표에 정확히 위치하게 된다.

![image](https://user-images.githubusercontent.com/42164422/122666255-2bf41880-d1e7-11eb-85e2-8e03102eba7c.png)

<br>

![image](https://user-images.githubusercontent.com/42164422/122666360-a9b82400-d1e7-11eb-8ae8-d19e7de14887.png)

따라서 [-1, 1] 분포에서 [0, 1] 분포를 갖도록 `Saturate` 노드를 사용하면

![image](https://user-images.githubusercontent.com/42164422/122666368-bccaf400-d1e7-11eb-89f0-60b38e16a084.png)

마스크에서 [-1, 0] 분포에 있는 값은 `Saturate`로 인해 모두 0의 값을 갖게 되어

기존의 정점 위치에서 변하지 않고,

[0, 1] 분포에 있는 값들은 타겟 좌표에 연속적으로 빨려 들어가는 것을 확인할 수 있다.

<br>

**Saturate 노드?**

- 값의 범위를 0부터 1 사이로 제한하는 노드

- 예를 들어 -0.5, -1, -2, .. 값은 0으로, 1.5, 2, 3, ... 값은 1로 바꿔준다.

<br>

## **Step 3-1**

위에서 확인한 결과를 응용하여, 이번에는 `Progress` 값의 변화에 따라 순차적으로 빨려 들어가는 효과를 구현한다.

우선 `Progress` 값이 0일 때는 모든 정점이 원래 위치에 그대로 있어야 한다.

즉, `Progress` 값이 0일 때 마스크의 값은 [0 이하, 0] 분포를 가져야 한다.

`0 이하`가 허용되는 이유는, 결국 최종적으로 `Lerp`의 `t`로 넣기 전에

`Saturate`에 의해 0보다 작은 값은 0으로 바꿔줄 것이기 때문이다.

<br>

`Progress` 값이 1일 때는 모든 정점이 타겟 좌표에 이동해 있어야 한다.

즉, `Progress` 값이 1일 때 마스크의 값은 [1, 1 이상] 분포를 가져야 한다.

<br>

[-1, 1] 마스크와 `Progress`의 연산의 결과가 위의 조건을 충족하도록 계산한다.

![image](https://user-images.githubusercontent.com/42164422/122666552-e0db0500-d1e8-11eb-905c-02c21f89942d.png)

`Mask - 1`의 분포는 [-2, 0]이다.

그리고 `Progress x 3`의 범위는 (0 ~ 3)이다.

이를 서로 더해주면 ([-2, 0] ~ [1, 3])이 된다.

`Progress`가 0일 때 [0 이하, 0]의 분포를 만족하고,

`Progress`가 1일 때 [1, 1 이상]의 분포 또한 만족한다.

그리고 최종적으로 `Saturate` 노드에 넣어준 뒤, `Lerp`의 `t`로 사용한다.

![image](https://user-images.githubusercontent.com/42164422/122666621-6fe81d00-d1e9-11eb-89e4-9e2e87a31fb3.png)

<br>

![2021_0619_BlackHole_Step3-1](https://user-images.githubusercontent.com/42164422/122666718-07e60680-d1ea-11eb-93ec-492620ac2fee.gif)

모든 정점이 `Progress` 값의 변화에 따라 순차적으로 빨려들어가는 것을 확인할 수 있다.

<br>

## **Step 3-2**
Step 3-1에서 [-1, 1] 마스크에서 -1 값을 갖는, 타겟 좌표에서 가장 멀리 떨어진 정점은 `Progress` 값이 0.666 정도일 때부터 이동하기 시작한다.

이와는 다르게 처음부터 모든 정점이 타겟 좌표를 향해 이동하도록 연산을 바꿔볼 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/122666684-d2d9b400-d1e9-11eb-8201-b2a7f47dff30.png)

[-1, 1] 마스크에 2를 더하면 [1, 3]이 된다.

그리고 여기에 `Progress`를 곱해주게 되면

`Progress`의 값이 `0`일 때 결과값은 [0, 0], `1`일 때는 [1, 3]이므로 

`Progress`가 0일 때 [0 이하, 0]의 분포를 만족하고,

`Progress`가 1일 때 [1, 1 이상]의 분포 또한 만족한다.

<br>

`Progress`의 값이 `0.1`, `0.2, `0.3`일 때

결과값은 [0.1, 0.3], [0.2, 0.6], [0.3, 0.9]와 같이 변화한다.

따라서 Step 3-1과 달리 `Progress`의 초기 진행부터 모든 정점이 타겟 좌표를 향해 움직이는 것을 볼 수 있다.

<br>

![2021_0619_BlackHole_Step3-2](https://user-images.githubusercontent.com/42164422/122668070-61056880-d1f1-11eb-898a-bac886f4ae32.gif)

<br>

# WPO - Step 4 : Noise
---

- Step 3-2에 이어서 구현한다.

- 노이즈를 이용하여, 빨아들이면서 버텍스가 자글자글하게 엇나가는 효과를 적용한다.

<br>

## **Noise**

![image](https://user-images.githubusercontent.com/42164422/122669103-b728da80-d1f6-11eb-96e4-c1ca7c7c09f3.png)

Step 3-2에서 마스크를 연산하기 전에,

마스크에 위와 같이 `Simple Noise` 노드를 이용한 노이즈 연산을 추가해준다.

`Noise Strength` 프로퍼티는 (0, 1) 범위로 설정하여

인스펙터에서 직접 값을 수정할 수 있게 한다.

<br>

![2021_0619_BlackHole_Noise_Step1](https://user-images.githubusercontent.com/42164422/122669221-40401180-d1f7-11eb-8cc5-6ab3a1ab59a0.gif)

빨려들어갈 때 버텍스들이 노이즈에 따라 엇나가는 효과를 확인할 수 있다.

<br>

## **UV Tiling**

![image](https://user-images.githubusercontent.com/42164422/122669316-b5abe200-d1f7-11eb-8607-657358bc79e8.png)

`Tiling and Offset`, `Time` 노드를 이용하여

노이즈의 UV가 시간에 따라 움직이도록 하며,

`Speed` 프로퍼티는 인스펙터에서 원하는 값을 입력할 수 있게 한다.

<br>

![2021_0619_BlackHole_Noise_Step2](https://user-images.githubusercontent.com/42164422/122669384-058aa900-d1f8-11eb-9e1a-c6b60e5fd032.gif)

빨려들어갈 때 노이즈가 움직이는 모습을 확인할 수 있다.

<br>

# Black Hole - Step 1 : 화면의 왜곡
---

## **평면 게임오브젝트 사용**

블랙홀 쉐이더는 Quad 또는 Plane과 같은 평면 형태의 게임오브젝트에 적용한다.

<br>

## **초기 설정**

블랙홀 쉐이더에서는 화면의 색상을 `Scene Color` 노드로 가져올 것이다.

이를 위해서 두 가지 설정이 필요하다.

<br>

### **[1] Opaque Texture 체크**

![image](https://user-images.githubusercontent.com/42164422/122682252-553a9600-d233-11eb-9389-704505ddacf6.png)

현재 적용 중인 URP Asset - General에서 `Opaque Texture`에 체크한다.

<br>

### **[2] Surface - Transparent 설정**

![image](https://user-images.githubusercontent.com/42164422/122682177-e6f5d380-d232-11eb-82eb-80220fb27719.png)

쉐이더 그래프에서 Surface를 `Transparent`로 설정한다.

Opaque 표면으로는 `Scene Color`를 제대로 받아올 수 없다.

<br>

## **Scene Color**

![image](https://user-images.githubusercontent.com/42164422/122682836-b2841680-d236-11eb-8b48-a46c13dd7405.png)

`Scene Color` 노드를 그대로 마스터 노드의 `Color`에 넣어본다.

정상적으로 적용되었다면,

![image](https://user-images.githubusercontent.com/42164422/122682829-a8faae80-d236-11eb-90df-a4071f1e4125.png)

위와 같이 표면이 투명한 것처럼 보이는 효과를 얻을 수 있다.

`Scene Color` 노드는 이렇게 화면의 색상을 표면에 그대로 출력해서 마치 표면 색상이 투명한 것처럼 보여준다.

<br>

## **화면의 왜곡**

`Scene Color`를 통해 보여주는 영역을 왜곡시킨다.

![image](https://user-images.githubusercontent.com/42164422/122682984-65ed0b00-d237-11eb-820d-a58ee577ce04.png)

위와 같이 노드를 구성하고 적용하면,

![2021_0619_BlackHole_Step1_Distortion](https://user-images.githubusercontent.com/42164422/122683067-f9bed700-d237-11eb-904c-0f7ba078f94f.gif)

이렇게 영역 내에서 나선 형태로 물결치는 듯한 왜곡 효과를 얻을 수 있다.

<br>

# Black Hole - Step 2 : 영역 자르기
---

Step 1에서의 Quad 또는 Plane 메시를 그대로 사용하면,

사각형의 가장자리 부분이 도드라져 거슬리는 느낌을 받게 된다.

영역을 부드러운 원형으로 보여주기 위해,

![image](https://user-images.githubusercontent.com/42164422/122683139-502c1580-d238-11eb-84ba-62d503cd27ef.png)

위와 같이 노드를 구성하고 마스터 노드의 `Alpha` 부분에 넣어준다.

`Range` 프로퍼티는 Slider로 설정하고 범위는 [0, 1], 기본 값은 0.55,

`Smoothness` 프로퍼티도 Slider로 설정하고 범위는 [0.01, 1], 기본 값은 0.2로 지정한다.

<br>

![2021_0619_BlackHole_Step2_Circle](https://user-images.githubusercontent.com/42164422/122683231-da747980-d238-11eb-9436-3cd52a82e45a.gif)

이제 가장자리가 부드럽고 자연스로운 원형으로 보이게 된다.

<br>

# Black Hole - Step 3 : 블랙홀 색상 넣기
---

색상 없이 단순 왜곡이라 밋밋해 보인다면,

![image](https://user-images.githubusercontent.com/42164422/122684148-b5830500-d23e-11eb-9084-a2322838d8d5.png)

이렇게 노드를 구성하고 블랙홀에 검정색으로 색상을 넣어줄 수 있다.

`Color Intensity` 프로퍼티는 Slider [0, 2] 범위로 설정하고, 기본 값은 0으로 넣어준다.

<br>

![2021_0619_BlackHole_Step3_Black Color](https://user-images.githubusercontent.com/42164422/122684260-638eaf00-d23f-11eb-9cf9-e6414bd0b346.gif)

`Color Intensity` 값에 따라, 이렇게 블랙홀에 검정색으로 색상이 더해진다.

<br>

# Final Graphs
---

## **World Position Offset Shader**

![image](https://user-images.githubusercontent.com/42164422/122684558-fc71fa00-d240-11eb-843a-bf5af299b543.png)


## **Black Hole Shader**

![image](https://user-images.githubusercontent.com/42164422/122684549-ea905700-d240-11eb-9e3a-68cf8f764907.png)

<br>

# Download
---
- [2021_0619_Black Hole.zip](https://github.com/rito15/Images/files/6682879/2021_0619_Black.Hole.zip)


# References
---
- <https://www.youtube.com/watch?v=eujfez6W53E>