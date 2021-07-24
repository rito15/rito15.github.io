---
title: (Amplify) Tree Growth Shader
author: Rito15
date: 2021-07-24 17:21:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 나무가 성장하는 효과 표현하기

<br>


# Preview
---

![2021_0724_Growth](https://user-images.githubusercontent.com/42164422/126862472-ea627ebb-5702-4f84-8961-663c9d3b2f91.gif)

<br>


# 1. Tree - Body
---

## **프로퍼티 목록**

![image](https://user-images.githubusercontent.com/42164422/126862567-074abce2-ed4c-446a-8011-262390d063a6.png)

<br>


## **쉐이더 에디터 설정**

![image](https://user-images.githubusercontent.com/42164422/126862604-8ca6ec7f-64aa-4da3-a46f-fd210eacfa7d.png)

- 우측 상단을 클릭하여 `Blend Mode`를 `Masked`로 변경한다.

- `Mask Clip Value` 값을 쉐이더 에디터에서 직접 설정해도 되지만<br>
  마테리얼에서 프로퍼티를 통해 조정하려면 우측의 점을 누르고 드롭다운에서 프로퍼티를 선택한다.

<br>


## **쉐이더 노드**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126862659-90719507-5f1f-4b2d-a9fa-4c25e1eabe5b.png)

<br>


## **설명**

식물 성장을 표현하기 위해 사용되는 메시는 특별한 조건이 필요하다.

식물이 아래에서 위로 성장하는 것을 표현하기 위해

메시의 `UV.Y` 값은 가장 하단 정점에서 0을 갖고

+Y축 방향으로 상단에 위치한 정점일수록 점점 커지는 형태를 가져야 한다.

<br>

`UV.Y - Grow` 값을 마스크로 이용하여 총 두 군데에 사용하게 된다.

![2021_0724_Growth_Mask](https://user-images.githubusercontent.com/42164422/126863563-b13396f9-6f59-45ca-97f5-28cd6d28b46f.gif)

<br>

첫번째로 알파 값으로 사용하여

`Alpha Clip` 프로퍼티의 값보다 크거나 같은 부분은 렌더링하고

작은 부분을 렌더링하지 않는 용도로 사용되며

<br>

두번째로 정점의 위치를 노멀 벡터의 반대 방향으로 이동시킬 때

정점을 이동시키거나 이동시키지 않을 영역을 구분하기 위한 용도로 사용된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/126863063-5221d191-292a-4a44-be61-78b93a083359.png)

메시의 정상적인 상태는 위와 같다.

<br>

그리고 여기에 `Grow` 프로퍼티 값을 `0.14` 정도 지정했을 때

![image](https://user-images.githubusercontent.com/42164422/126863106-601540c2-c4e6-4765-9eca-b8d11bf2f288.png)

이런 모습을 확인할 수 있는데,

마스크 색상과 대조해보면 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/126863173-0cd53161-c703-44f7-aec5-c188950160b2.png)

빨간 선 기준으로 하단부는 마스크의 색상이 까만 부분이며

이 영역에 해당하는 정점들은 별도의 연산이 더해지지 않기 때문에

정상적인 모습으로 보인다.

<br>

빨간 선 기준으로 상단부는 마스크 색상이 0보다 큰 값을 가지며

이 영역에 해당하는 정점들은 각각 자신의 노멀 반대방향으로 이동하여

정점이 넓게 펼쳐진 듯한 모습을 확인할 수 있다.

<br>

이 상태에서 마스크를 `One Minus`로 반전시키고

`Alpha Clip`을 통해 렌더링될 영역을 구분시킨다.

![image](https://user-images.githubusercontent.com/42164422/126863329-fd75403f-c39f-4d14-9131-27337e3c522f.png)

그리고 이를 마스터 노드의 `Opacity Mask`에 적용하게 되면

![image](https://user-images.githubusercontent.com/42164422/126863468-2284d665-9218-4413-a138-d978538b9c08.png)

이렇게 빨간 선 기준으로 상단부는 렌더링되지 않고,

하단부는 정상적으로 렌더링되는 모습을 확인할 수 있다.

<br>

이 두 가지를 이용하면

![2021_0724_Growth_Wireframe](https://user-images.githubusercontent.com/42164422/126863657-39aeaa2c-36e2-4f79-86a1-93ba022fbf30.gif)

이와 같이 `Grow` 프로퍼티 값의 증가에 따라 식물이 성장하는 듯한 효과를 표현할 수 있다.

<br>


# 2. Tree - Leaves
---

## **프로퍼티 목록**

![image](https://user-images.githubusercontent.com/42164422/126863696-d18f1b03-5796-40d6-9790-aa51eca1b3b7.png)

<br>


## **쉐이더 에디터 설정**

- `Opaque` 그대로 두면 된다.

<br>


## **쉐이더 노드**

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/126863800-7cf44a76-4428-4edc-bdd4-ba85371d127c.png)

<br>


## **설명**

아주 간단한 연산을 적용한다.

`Grow` 프로퍼티 값이 `0`일 때는 `Local Vertex Offset`에 `Vertex Position`을 완전히 빼서

모든 정점이 메시의 피벗 위치에 모이도록 하여, 결국 아무 것도 보이지 않는다.

`Grow` 프로퍼티 값이 `1`일 때는 `Local Vertex Offset`에 `0`이 더해지므로

쉐이더에서 아무런 연산을 수행하지 않은 것처럼 정상적으로 보인다.

그리고 `Grow` 값이 `0` ~ `1` 사이일 때는 이 두 경우 사이에서 보간되어

`Grow` 값 증가에 따라 오브젝트가 점차 커지는 효과를 나타낼 수 있다.

<br>

![2021_0724_Growth_Leaf](https://user-images.githubusercontent.com/42164422/126864080-a53094e4-b5a2-498a-be20-fa68fca8b5dd.gif)

<br>


# Download
---

- [2021_0724_Growth.zip](https://github.com/rito15/Images/files/6872159/2021_0724_Growth.zip)


<br>

# References
---
- <https://www.youtube.com/watch?v=LKaEMBLIw9s>


