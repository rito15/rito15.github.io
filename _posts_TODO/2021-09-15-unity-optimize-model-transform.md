---
title: 유니티 모델 트랜스폼 구조 최적화하기
author: Rito15
date: 2021-09-15 04:00:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization, model]
math: true
mermaid: true
---

# Note
---

## **문제점**

`Skinned Mesh`가 적용되는 게임 오브젝트의 경우,

하이라키에서 트랜스폼 구조를 확인해보면

![image](https://user-images.githubusercontent.com/42164422/133316015-d33fa2d4-9e48-4273-b44b-f9d4c4ade799.png)

이렇게 `Bone` 별로 각각 존재하여, 굉장히 많은 게임오브젝트들로 이루어져 있다.

그런데 유니티 엔진에서는 부모 게임 오브젝트의 트랜스폼에 변경사항이 생기면

모든 자식 트랜스폼에 변경이 발생한다.

한마디로, 위와 같이 무수히 많은 자식 오브젝트가 존재하면 성능에 좋지 않다는 의미이다.

<br>

## **해결책**

`Project` 윈도우에서 해당 모델 파일을 선택한다.

인스펙터 창에서 `Rig` 탭을 클릭한다.

![image](https://user-images.githubusercontent.com/42164422/133316610-83b8bf27-75e9-44d4-a8c4-e26305171c7e.png)

여기서 만약 `Optimize Game Objects` 옵션이 나타나지 않는다면

`Animation Type`을 `Generic` 또는 `Humanoid`로 바꾸고,

`Avatar Definition`을 `Create From This Model`로 선택한다.

마지막으로 `Optimize Game Objects`에 체크하고 `Apply` 버튼을 클릭한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/133316813-0cb693b1-1aab-4b30-bf6f-4719f16deb1a.png)

이제 트랜스폼 구조가 아주 단순화된 것을 확인할 수 있다.

<br>

## **특정 본 나타내기**

그런데 특정한 본을 기준으로 무기를 장착해야 한다거나 하는 이유로

본의 트랜스폼을 드러내야 하는 경우가 있을 수 있다.

이런 경우에는 `Optimize Game Objects` 하단의 `Extra Transforms to Expose`를 펼치고,

원하는 본을 찾아서 체크한 뒤 `Apply`를 누른다.

![image](https://user-images.githubusercontent.com/42164422/133317343-24981e1a-b624-4f3c-aeef-b86ec1d04f2c.png)

그러면 해당 트랜스폼이 드러난 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/133317396-af2f1911-1cdb-4154-831c-47656a0d89a6.png)

<br>

## **추가**

![image](https://user-images.githubusercontent.com/42164422/133320716-d0ac425f-0d18-4609-90d2-0a90e7214538.png)

해당 오브젝트의 루트에서 `Animator` 컴포넌트에 우클릭하고

`Optimize Transform Hierarchy`를 클릭하여,

해당 메시를 사용하는 모든 게임오브젝트가 아니라

특정 오브젝트만 최적화하도록 설정할 수도 있다.






