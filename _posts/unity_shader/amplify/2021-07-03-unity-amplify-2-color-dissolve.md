---
title: (Amplify) Directional 2 Color Dissolve Shader
author: Rito15
date: 2021-07-03 18:00:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
---

# Summary
---

- 디졸브 방향을 직접 지정할 수 있는 디졸브 쉐이더

- 디졸브 효과 색상 2가지를 지정할 수 있다.

- 포스트 프로세싱 Bloom 효과가 반드시 필요하다.
  - Preview 설정 : Intensity 3, Threshold 0.9

<br>

# Preview
---

![2021_0704_Dissolve](https://user-images.githubusercontent.com/42164422/124363829-aa859700-dc78-11eb-9ec4-a875cd7230e4.gif)

<br>


# Properties
---

![image](https://user-images.githubusercontent.com/42164422/134003689-48460bd2-9d21-4fc9-afc1-cbbf362b0047.png)

<br>


# Settings
---

## Blend Mode
 - `Transparent`

<br>


# Step by Step
---

## **[1] 디졸브 기본**

디졸브(Dissolve) 쉐이더를 만드려면 우선 UV에 따라 연속된 단일 채널 값이 분포하는,

예를 들면 `UV.x`나 `UV.y` 같은 일종의 마스크(Mask)가 필요하다.

![image](https://user-images.githubusercontent.com/42164422/133964354-f38bf710-61fb-477b-8000-a3e0eed08597.png)

> Tip : `Register Local Var(단축키 R)` 노드를 통해 원하는 값을 특정 이름으로 저장하고, `Get Local Var(단축키 G)` 노드에서 불러와 재사용할 수 있다.
> 위의 예시에서는 UV.y 값을 Gradient라는 이름으로 저장하여 재사용한다.

![2021_0920_UV_Step](https://user-images.githubusercontent.com/42164422/133964618-18947a7f-4264-48e5-9520-02d2bdbc07b8.gif)

연속된 마스크와 단일 값을 `Step` 노드의 입력에 각각 넣으면

위와 같이 기본적인 디졸브 효과를 만들 수 있다.

<br>

## **[2] 부드러운 디졸브**

우선 `Step` 대신 `SmoothStep`을 이용해 부드러운 디졸브 효과를 만든다.

![2021_0920_UV_Smoothstep](https://user-images.githubusercontent.com/42164422/133965686-8eab17a4-1c3d-4792-a1ee-d8cc3ff01a01.gif)

`0 ~ 1` 범위의 `Dissolve` 값을 통해 디졸브 진행도를 결정하고,

`0.01 ~ 1` 범위의 `Smoothness` 값을 통해 경계면의 부드러운 정도를 결정할 수 있다.

`Smoothness` 값의 시작이 `0`이 아니고 `0.01`인 이유는,

`0` 값이 되면 결과 영역의 색상이 반전 되어버리기 때문이다.

<br>

## **[3] 범위 재설정**

부드러운 디졸브 효과에서는 문제점이 하나 있다.

![image](https://user-images.githubusercontent.com/42164422/133965806-12cbf567-6d1f-458f-bc54-8d285fcd7cf0.png)

`Dissolve` 값이 `0`일 때는 모든 영역이 하얘야 하는데,

`Smoothness` 값에 따라 하단 영역에 까만 부분이 생기는 것이다.

이를 해결하기 위해서는 `Smoothness` 값이 `0.2`일 때 `Dissolve`는 `-0.2`, 

`0.5`일 때는 `-0.5` 이런 식으로 `Smoothness` 값의 변화에 따라 `Dissolve`의 시작점도 바뀌어야 한다.

해결을 위해 `Dissolve` 값의 범위를 `0 ~ 1`이 아니라 `-1 ~ 1`로 지정하는 방법도 있지만,

일관성이 없기도 하고, 사용자 입장에서 항상 `0 ~ 1`로 손쉽게 사용할 수 있도록 보장해주는 것이 좋다.

따라서 입력 값의 범위를 변경해주는 `Remap` 노드를 이용한다.

목표는 `0 ~ 1` 범위의 `Dissolve` 값을 `-Smoothness ~ 1` 값으로 변경하는 것이다.

![2021_0920_UV_Smoothstep_Remapped](https://user-images.githubusercontent.com/42164422/133966549-7f88b676-b41f-47cd-a0ae-ea84bd21b43c.gif)

위와 같이 구성하면 원하는 대로 구현할 수 있다.

<br>

## **[4] 노이즈 기반 디졸브**

위에서 완성한 부드러운 디졸브와 노이즈를 이용해 경계선이 굴곡진 디졸브를 만들 수 있다.

![2021_0920_NoiseDissolve](https://user-images.githubusercontent.com/42164422/133966843-dd1f150f-9766-4799-84de-af2deda25eee.gif)

노이즈를 생성하는 것은 간단하다.

`Noise Generator` 노드의 `UV` 입력에 `Vertex Texcoord(UV)`를 넣어주면 된다.

그리고 결과 노이즈와 위에서 만든 부드러운 디졸브를 `Step`의 입력으로 넣으면 굴곡진 디졸브가 완성된다.

`Dissolve` 값은 똑같이 디졸브 진행도를 표현하고,

`Smoothness` 값은 경계면의 노이즈 적용도를 결정한다.

그리고 더 미세한 노이즈를 표현하고 싶으면 `Noise Generator` 노드의 `Scale` 입력값을 높이면 된다.

<br>

## **[5] 디졸브 경계면 분리**

디졸브 경계면에 색상을 넣으려면, 우선 경계면을 기준으로 색상을 입힐 영역을 분리해야 한다.

![image](https://user-images.githubusercontent.com/42164422/133968051-412eecbb-d8fc-475c-8fc9-409e68a6a1b7.png)

디졸브 진행도(`Dissolve` 값)가 서로 다른 두 결괏값을 빼면 위와 같은 영역을 만들 수 있다.

그리고 이 영역에 색상을 입힌 뒤 원래의 디졸브 결과와 더해주면 된다.

우선 이 영역의 두께를 결정할 프로퍼티를 하나 만들고, 이름은 `Thickness`라고 짓는다.

이 프로퍼티의 범위는 `0 ~ 0.5` 정도로 설정해준다.

그리고 같은 이름으로 미리 `Register Local Var` 노드에 등록한다.

![image](https://user-images.githubusercontent.com/42164422/133971083-e5f1c82e-5525-4df8-8983-531348431430.png)

<br>

## **[6] 중간 정리**

그냥 진행할 수도 있지만, 그래프 간선 지옥이 되는 것을 피하기 위해

![image](https://user-images.githubusercontent.com/42164422/133968730-1b2c7510-142a-456b-9267-534b2596416f.png)

`Smoothstep`의 `Min`, `Max` 입력으로 넣을 두 값을 위와 같이

각각 `SMin`, `SMax`라는 이름으로 `Register Local Var` 노드에 등록해준다.

<br>

마찬가지로 노이즈 생성 결과도 `Noise`라는 이름으로 등록한다.

![image](https://user-images.githubusercontent.com/42164422/133969078-25031f41-530e-47cb-8e91-6cf3e1caa5a1.png)

<br>

그러면 이렇게 아주 깔끔하게 디졸브 생성 부분을 정리할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/133969134-6253bfd9-7411-497a-b4d3-207dc4c857af.png)

<br>

## **[7] 경계면 영역 생성**

이제 진행도가 다른 새로운 디졸브 영역을 생성하기 위해

![image](https://user-images.githubusercontent.com/42164422/133971954-c127819d-0dea-494d-9fd0-104e2d47e8b9.png)

이렇게 만들어준다.

![image](https://user-images.githubusercontent.com/42164422/133971866-f93f783c-3238-46ee-87d2-1e64a10a7044.png)

그 다음엔 이렇게 기존에 만든 영역을 `Subtract` 노드를 이용해 빼주면 경계면의 중간 영역을 만들 수 있다.

<br>

## **[8] Dissolve 범위 재조정**

그런데 `Dissolve` 값을 1가지 쭉 올렸을 때

![2021_0920_NoiseDissolve_Remained](https://user-images.githubusercontent.com/42164422/133972296-7832feb5-0eca-4175-9e82-abde66a83691.gif)

모두 까맣게 되지 않고, 이렇게 잔여 영역이 남아 있는 것을 확인할 수 있다.

이를 해결하기 위해 

![image](https://user-images.githubusercontent.com/42164422/133972521-9be26ba1-e440-4fd1-93a3-b46a3fbdbba2.png)

위의 `Dissolve` 값 범위를

![image](https://user-images.githubusercontent.com/42164422/133972628-18c7b474-bf01-4a24-96bb-78af3d091fa1.png)

이렇게 변경해준다.

<br>

## **[9] 경계면 색상 넣기**

![2021_0920_NoiseDissolve_Colored](https://user-images.githubusercontent.com/42164422/133973769-c96ce88a-9b36-4f9e-a7fe-2c843c109d3a.gif)

이제 위와 같이 노드를 구성해서 경계면에 색상을 넣어준다.

<br>

## **[10] 새로운 경계면 추가**

지금까지 경계면의 색상 하나를 추가했을 뿐이다.

이제 또 하나의 경계면을 만들고, 다른 색상을 넣을 준비를 해야 한다.

![image](https://user-images.githubusercontent.com/42164422/133974047-35f8aa8b-8eb0-4826-a25f-b321015a3ebd.png)

기존의 `Thickness` 프로퍼티와 `Regeister Local Var`에 등록된 이름을 위와 같이 `Thickness A`로 변경한다.

`Register Local Var`의 이름은 띄어쓰기를 허용하지 않으므로 언더바(`_`)를 사용한다.

그리고 새로운 프로퍼티를 만들고 `Thickness B`라고 이름 붙인 뒤,

두 `Thickness`를 더한 결과를 새로운 `Register Local Var`에 등록한뒤 이름은 `Thickness_A_Plus_B`로 짓는다.

이런 이름들은 보자마자 어떤 것을 의미하는지 쉽게 알 수 있도록, 위와 같이 직관적으로 짓는 것이 좋다.

<br>

그다음엔 `SMin`, `SMax`를 계산하는 부분에서

`Get Local Var`의 타겟을 `Thickness_A_Plus_B`로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/133974285-b757c117-6dcc-4ccd-83f0-ab347f384510.png)

<br>

## **[11] 새로운 경계면 완성**

`[7]` 과정에서 생성했던 부분을 선택하고 그대로 복제(`Ctrl + D`)한 뒤,

![image](https://user-images.githubusercontent.com/42164422/133977145-caa3f86f-c286-438f-9ea9-1ca3aab1a49a.png)

`Get Local Var`의 `Thickness_A` 참조를 `Thickness_A_Plus_B`로 변경한다.

그리고 같은 방식으로 `Subtract`를 통해 새로운 경계면 영역을 확보한 뒤 색상을 곱하고,

최종 결과에 더해준다.

![image](https://user-images.githubusercontent.com/42164422/133977580-af9e5691-cda6-4eeb-876e-f4841debdfdb.png)

<br>

## **[12] 중간 정리**

다시 한번 `Register & Get`을 이용해 정리한다.

![image](https://user-images.githubusercontent.com/42164422/133977990-9a42605f-e012-49f3-9c87-1396eb60d2bc.png)

디졸브 결과를 `Area_Main`이라는 이름으로 저장하고,

이 영역과 `A 영역`의 차이로 얻어진 경계면을 `Area_A`,

`A 영역`과 `B 영역`의 차이로 얻어진 경계면을 `Area_B`라는 이름으로 저장한다.

<br>

이제 위에서 저장한 값들을 사용하는 부분을 분리한다.

![image](https://user-images.githubusercontent.com/42164422/133978365-93a6bb6b-9e3e-4734-8ddb-33bcc740d13f.png)

그리고 정리하는 김에, `Area_Main`은 메인 텍스쳐의 색상이 적용되도록

텍스쳐 샘플러(단축키 `T`)를 만들고 이름을 `Main Texture`로 변경한 뒤 함께 곱해준다.

`A`, `B` 영역에 적용되는 색상들은 각각 `Color A`, `Color B`로 이름을 변경한 뒤

마테리얼에서 값을 변경할 수 있도록, `Constant`였다면 `Property`로 바꿔준다.

<br>

## **[13] 영역 정리**

마우스 왼쪽 드래그를 통해 여러 노드를 한 번에 선택한 뒤,

키보드 단축키 `C`를 누르면 하나의 영역으로 묶을 수 있다.

그리고 좌측의 속성에서 `Frame Title`에 각 영역의 이름을 설정해주면

![image](https://user-images.githubusercontent.com/42164422/133979044-9e4683b1-b88b-4431-a6b3-2d3f1cc17d1b.png)

이렇게 아주 깔끔하게 영역을 나누어 정리할 수 있다.

<br>

## **[14] 마스터 노드 입력 정리**

마스터 노드는 실시간 라이팅이 적용되는 `PBR Lit` 타입으로 사용한다.

딱히 거창한건 아니고, 앰플리파이 쉐이더를 `Surface`로 만들고

`Light Model`을 `Standard`로 그대로 놔두면 이 상태이다.

`Albedo`는 빛의 영향을 받는 색상이고, `Emission`은 빛의 영향을 받지 않는다.

따라서 `Main Texture`의 색상은 `Albedo`에 넣어야 하고,

두 경계면 색상은 `Emission`에 넣어야 한다.

<br>

추가적으로, `Blend Mode`는 `Transparent`로 설정해야 한다.

![image](https://user-images.githubusercontent.com/42164422/133980297-c86bcedf-c0c5-4d5f-9fa9-2a6f8f5d69d6.png)

<br>

![image](https://user-images.githubusercontent.com/42164422/133979620-1445b867-2b24-4b6c-acb0-50b9f40433fa.png)

영역에 색상을 곱해 적용하는 부분에서 위와 같이

`Main Texture` 색상 부분은 따로 빼서 `Color_Albedo`라는 이름으로 등록하고,

아래의 두 색상은 서로 더한 뒤 `Color_Emission`이라는 이름으로 등록해준다.

<br>

그리고 최종 노드의 알파값에 전체 디졸브 영역을 넣어 줘야 하는데,

`Area_B`를 등록하는 부분에서

![image](https://user-images.githubusercontent.com/42164422/133980165-a4679ca2-0b9c-4168-b222-45a5a7203d50.png)

위와 같이 `Step`의 결괏값을 `Opacity`라는 이름으로 등록해준다.

<br>

이제 마스터 노드의 입력으로 각각 알맞은 값들을 넣어주면

![image](https://user-images.githubusercontent.com/42164422/133980494-1e1d3252-7af4-4a6c-95bb-773bd9309338.png)

이렇게 깔끔하게 적용할 수 있다.

<br>

## **[15] 경계면 색상 HDR 옵션 추가하기**

이 디졸브 쉐이더의 묘미는 디졸브 경계면이 포스트 프로세싱 `Bloom`으로 인해 환하게 빛나는 것이다.

이를 위해서는 색상을 `HDR`로 적용해줄 필요가 있다.

`Color A`, `Color B` 프로퍼티 노드를 각각 선택하고

좌측의 속성에서 `Attributes` - `HDR`을 체크해준다.

![image](https://user-images.githubusercontent.com/42164422/133981488-e3065f3f-c614-4264-ab33-22dec37e30d0.png)

<br>

## **[16] 디졸브 방향 커스터마이징하기**

`UV.y`를 기반으로 디졸브를 적용하려면 이 상태에서 마치면 된다.

하지만 원하는 방향으로 커스텀하게 디졸브를 적용하기 위해서는

해당 방향을 기반으로 새로운 `0 ~ 1` 범위의 마스크를 생성하는 과정이 필요하다.

<br>

원하는 방향을 지정하기 위해, 우선 `Vector3` 타입 프로퍼티가 필요하다.

![image](https://user-images.githubusercontent.com/42164422/133982427-a7346f1e-0f6c-4eba-9553-7afb79750fb5.png)

이 벡터 값은 순전히 방향 벡터로 사용할 것이다.

다시 말해, 크기가 언제나 `1`이어야 한다.

따라서 `Normalize` 노드를 통해 정규화시켜준다.

![image](https://user-images.githubusercontent.com/42164422/133982494-08e550a7-6799-4466-801f-bb04810ed460.png)

<br>

이제 디졸브 방향은 프로퍼티를 통해 결정할 수 있게 되었다.

다음으로 마스크를 만들기 위해, `Vertex Position`을 방향 벡터로 사용할 것이다.

뜬금 없이 정점 위치 벡터를 왜 방향 벡터로 사용하냐는 생각이 들겠지만,

원하는 마스크를 만들기 위해서는 이 방법이 필요하다.

<br>

방향 벡터를 이용해 `0 ~ 1` 범위의 마스크를 만드는 원리는 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/133991304-f4a671df-8967-4b9b-a1ec-5af55ba8348d.png)

위의  점은 메시의 피벗 위치이고, 따라서 로컬 스페이스(Local Space)에서 위치 값은 `(0, 0, 0)` 이다.

그리고 원 테두리 부분은 메시의 각 정점이며, 위치 값을 예시로 표현하면 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/133991781-c0914868-4a6c-47e6-9774-51fb35873f4f.png)

<br>

이제 이 위치 값들을 방향 벡터로 사용하여 디졸브 방향 벡터와의 내적 연산을 수행한다.

예를 들어 디졸브 방향 벡터의 값이 `(0, 1, 0)`일 때를 가정한다.

![image](https://user-images.githubusercontent.com/42164422/133993142-e555ced4-15ae-43a0-88c1-3580f79f210e.png)

위치 값들(`Vertex Position`)과 디졸브 방향 벡터(`Dissolve Direction`)의

내적의 결과를 색상으로 표현하면 다음과 같다.

![image](https://user-images.githubusercontent.com/42164422/133995760-e1419535-7b73-449e-becc-1ab1e3b63993.png)

원하던 마스크가 얻어진 것이다.

그리고 방향을 바꿔보면 그 방향에 맞는 마스크를 얻을 수 있다.

![image](https://user-images.githubusercontent.com/42164422/133996029-6576b132-019a-4f0c-9b9e-c8a70585da25.png)

<br>

예시에서 내적의 결괏값 범위는 `-1 ~ 1`이다.

그리고 이 값을 디졸브의 근간인 `Gradient`로서 사용하려면, `0 ~ 1` 범위여야 하므로 `Remap`을 적용해야 한다.

![image](https://user-images.githubusercontent.com/42164422/133996349-e5db6c62-4929-496e-8b3f-c10892bfee64.png)

<br>

그런데 쉐이더가 적용될 메시마다 피벗 위치도 다르고, 정점 위치도 제각각이므로

내적값 범위가 항상 `-1 ~ 1`이라는 보장을 할 수 없다.

`1 ~ 2`일 수도 있고, `123 ~ 999`일 수도 있고, `-99.1 ~ 0.7`일 수도 있고,

정말로 메시마다 완전히 제각각이다.

이는 쉐이더 내에서 계산하지 못하므로 프로퍼티로 입력해 주어야 한다.

따라서 이름을 `Min Offset`, `Max Offset`이라고 짓고

두 개의 프로퍼티를 생성하여 다음과 같이 넣어준다.

![image](https://user-images.githubusercontent.com/42164422/133996650-cb3a7b69-c0ad-4e44-ac97-f5e0c8adda4e.png)

<br>

이제 기존에 `Gradient` 입력으로 사용하던 `UV.y` 대신, 위의 결과를 적용하여

![image](https://user-images.githubusercontent.com/42164422/133996833-6ea66017-3abd-4601-8654-d918f75c8b8c.png)

이렇게 완성해준다.

<br>

## **[17] Dissolve Helper 사용하기**

메시마다, 디졸브 방향마다 `Min Offset`과 `Max Offset`은 항상 달라진다.

그런데 이걸 알아내기 위해 매번 테스트를 해볼 수는 없는 노릇이다.

따라서 이를 쉽게 계산하고 바로 적용해주는 스크립트를 만들어서 첨부파일에 포함시켜 놓았다.

첨부 파일 내에

![image](https://user-images.githubusercontent.com/42164422/134002893-20f2d15f-197d-4051-8d31-735923fc5cf0.png)

이런 스크립트 파일이 있을 텐데,

디졸브를 적용할 게임오브젝트의 인스펙터에 드래그하여

![image](https://user-images.githubusercontent.com/42164422/134003214-e1904d8c-919e-4065-b5de-204707e69dd2.png)

이렇게 넣어준다. (반드시 해당 디졸브 마테리얼이 적용되는 게임오브젝트에 넣어 주어야 한다.)

그리고 원하는 디졸브 방향 값을 `Dissolve Direction`에 입력한 뒤

`Calculate Min/Max Offsets` 버튼을 클릭하면

![image](https://user-images.githubusercontent.com/42164422/134003395-1ce988fb-02a3-44f3-a47b-987bc52e4dd9.png)

이렇게 알아서 `Min/Max Offset` 값이 계산되고 마테리얼에 자동으로 적용된다.

<br>


# Nodes
---

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/4e1c0c46
```

<!--
AMPLIFY_CLIPBOARD_ID;-1983.421,-187.381,0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;89;-3027.76,126.5652;Inherit;False;693.0833;265.7795;.;5;71;72;54;41;70;Thickness Values;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;70;-2976.676,276.3447;Inherit;False;Property;_ThicknessB;Thickness B;6;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;41;-2977.76,176.5652;Inherit;False;Property;_ThicknessA;Thickness A;5;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;71;-2699.676,257.3447;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;71;0;41;0
WireConnection;71;1;70;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;88;-3036.053,-475.9767;Inherit;False;1084.495;530.75;.;10;37;34;44;43;36;33;63;61;28;57;Calculate SMin, SMax;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-2586.676,252.3447;Inherit;False;Thickness_A_Plus_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;72;0;71;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;57;-2986.053,-344.6226;Inherit;False;72;Thickness_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;62;-2900.773,-424.3446;Inherit;False;Constant;_Float6;Float 6;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;33;-2938.839,-58.8914;Inherit;False;Property;_Smoothness;Smoothness;4;1;[Header];Create;True;1;Options;0;0;False;1;Space(6);False;0.4;0.4;0.01;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2763.35,-365.3763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;61;0;62;0
WireConnection;61;1;57;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;86;-3035.66,-1056.8;Inherit;False;1085.006;511.9027;.;8;110;108;2;113;112;109;107;106;Make Gradient;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;28;-2935.603,-239.3666;Inherit;False;Property;_Dissolve;Dissolve;0;1;[Header];Create;True;1;Dissolve;0;0;False;1;Space(6);False;0.5;0.5;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2631.748,-258.9764;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;63;0;61;0
WireConnection;63;1;28;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;37;-2623.093,-110.1503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;37;0;33;0#CLIP_ITEM#Node;AmplifyShaderEditor.Vector3Node;106;-3013.371,-858.7871;Inherit;False;Property;_DissolveDirection;Dissolve Direction;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;36;-2481.272,-180.52;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;36;0;63;0
WireConnection;36;3;37;0#CLIP_ITEM#Node;AmplifyShaderEditor.PosVertexDataNode;108;-2860.771,-1002.986;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.NormalizeNode;107;-2829.371,-853.7871;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;107;0;106;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;112;-2612.111,-727.0927;Inherit;False;Property;_MinOffset;Min Offset;1;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.DotProductOpNode;109;-2661.371,-936.787;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
WireConnection;109;0;108;0
WireConnection;109;1;107;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;113;-2615.111,-655.0927;Inherit;False;Property;_MaxOffset;Max Offset;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2297.282,-80.22669;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;34;0;36;0
WireConnection;34;1;33;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;87;-3033.384,486.3759;Inherit;False;767.7477;309;.;4;30;29;47;73;Noise;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;110;-2411.371,-791.787;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;110;0;109;0
WireConnection;110;1;112;0
WireConnection;110;2;113;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;98;-1904.468,-1049.99;Inherit;False;1449.33;1110.381;.;30;53;38;49;50;40;51;52;39;42;55;31;26;45;46;48;27;83;74;75;76;77;78;79;80;82;81;90;91;92;105;Dissolve Areas;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-2177.09,-253.5955;Inherit;False;SMin;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;43;0;63;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;73;-2983.384,658.0266;Inherit;False;Property;_NoiseScale;Noise Scale;7;0;Create;True;0;0;0;False;0;False;10;0;0;20;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-2175.558,-84.02796;Inherit;False;SMax;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;44;0;34;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-2584.175,177.1987;Inherit;False;Thickness_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;54;0;41;0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;30;-2900.661,539.3759;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;81;-1854.468,-55.6091;Inherit;False;72;Thickness_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;55;-1833.169,-399.9308;Inherit;False;54;Thickness_A;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;49;-1828.506,-550.077;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;75;-1823.805,-210.9553;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;76;-1823.805,-137.9551;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NoiseGeneratorNode;29;-2715.661,536.3759;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
WireConnection;29;0;30;0
WireConnection;29;1;73;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;50;-1828.506,-477.077;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-2148.699,-796.6962;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;2;0;110;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;45;-1632.007,-848.1478;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;26;-1631.126,-920.5597;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;79;-1608.805,-277.9551;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1585.953,-542.0243;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;40;0;49;0
WireConnection;40;1;55;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-1581.252,-202.9026;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;77;0;75;0
WireConnection;77;1;81;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-1583.478,-86.90247;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;78;0;76;0
WireConnection;78;1;81;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;51;-1613.506,-617.077;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-2489.635,536.9152;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;47;0;29;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-1588.179,-426.0242;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;42;0;50;0
WireConnection;42;1;55;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;46;-1632.007,-772.7479;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;31;-1415.159,-916.3947;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;31;0;26;0
WireConnection;31;1;45;0
WireConnection;31;2;46;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;52;-1347.506,-630.077;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;80;-1342.805,-290.9551;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;38;-1407.203,-556.4539;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;38;0;51;0
WireConnection;38;1;40;0
WireConnection;38;2;42;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;48;-1359.038,-999.9899;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;74;-1402.503,-217.3321;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;74;0;79;0
WireConnection;74;1;77;0
WireConnection;74;2;78;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;39;-1137.071,-607.9316;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;39;0;52;0
WireConnection;39;1;38;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;82;-1132.37,-268.8098;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;82;0;80;0
WireConnection;82;1;74;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;27;-1151.809,-965.5722;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;27;0;48;0
WireConnection;27;1;31;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-888.2399,-770.7542;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;53;0;39;0
WireConnection;53;1;27;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-887.7125,-359.6436;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;83;0;82;0
WireConnection;83;1;39;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-685.7563,-775.213;Inherit;False;Area_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;91;0;53;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;99;-2181.949,159.0821;Inherit;False;966.2074;840.9506;.;12;101;100;69;97;96;85;94;68;93;95;84;67;Apply Colors;1,1,1,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-679.1382,-363.996;Inherit;False;Area_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;92;0;83;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;93;-2013.98,479.0965;Inherit;False;91;Area_A;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;95;-2012.167,746.8116;Inherit;False;92;Area_B;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.ColorNode;84;-2051.057,820.7536;Inherit;False;Property;_ColorB;Color B;10;1;[HDR];Create;True;0;0;0;False;0;False;4,3.858824,0.7686275,0;0.02271891,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.ColorNode;67;-2051.872,551.9167;Inherit;False;Property;_ColorA;Color A;9;1;[HDR];Create;True;0;0;0;False;0;False;0.7682998,3.073199,2.368924,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-898.825,-970.4484;Inherit;False;Area_Main;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;90;0;27;0#CLIP_ITEM#Node;AmplifyShaderEditor.SamplerNode;96;-2131.948,283.3225;Inherit;True;Property;_MainTexture;Main Texture;8;1;[Header];Create;True;1;Colors;0;0;False;1;Space(6);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;None#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1843.736,483.3716;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;68;0;93;0
WireConnection;68;1;67;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1842.62,750.9089;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;85;0;95;0
WireConnection;85;1;84;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;94;-2013.884,209.0821;Inherit;False;90;Area_Main;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1843.559,213.8319;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;69;-1598.629,627.9991;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;69;0;68;0
WireConnection;69;1;85;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1405.998,626.4787;Inherit;False;Color_Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;101;0;69;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1597.984,279.0186;Inherit;False;Color_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;100;0;97;0#CLIP_ITEM#Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-879.0135,-124.0634;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;105;0;82;0#CLIP_ITEM#Node;AmplifyShaderEditor.CommentaryNode;114;-1087.198,206.2058;Inherit;False;517.1199;524.9035;.;4;103;102;104;0;Master Node;0.4198113,1,0.9439446,1;0;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;104;-1012.741,469.0307;Inherit;False;105;Opacity;1;0;OBJECT;;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;103;-1037.198,324.9445;Inherit;False;101;Color_Emission;1;0;OBJECT;;False;1;COLOR;0#CLIP_ITEM#Node;AmplifyShaderEditor.GetLocalVarNode;102;-1028.307,256.2059;Inherit;False;100;Color_Albedo;1;0;OBJECT;;False;1;COLOR;0#CLIP_ITEM#
-->

</details>

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/134003785-237e1f39-0e70-4cec-b9a4-3ac6c8a53ca6.png)

<br>


# Download
---

- [2021_0920_Directional 2 Color Dissolve.zip](https://github.com/rito15/Images/files/7195870/2021_0920_Directional.2.Color.Dissolve.zip)

<br>


