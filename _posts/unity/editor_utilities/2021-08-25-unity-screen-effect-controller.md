---
title: Screen Effect Controller(스크린 이펙트, 포스트 프로세싱)
author: Rito15
date: 2021-08-25 21:00:00 +09:00
categories: [Unity, Unity Editor Utilities]
tags: [unity, editor, csharp, utility]
math: true
mermaid: true
---

# Summary
---
- 유니티 기본 렌더 파이프라인(Built-in Render Pipeline)에서 사용할 수 있습니다.
  - SRP, URP, HDRP에서는 사용할 수 없습니다.

- 스크린 이펙트(포스트 프로세싱 이펙트)를 간단히 적용할 수 있습니다.

- 게임 오브젝트의 단순 활성화/비활성화 방식으로 스크린 이펙트 적용/해제가 가능합니다.

- 유니티 타임라인을 통해 편리하게 사용할 수 있습니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **테스트 완료 에디터 버전**

- 2018.3.14f1
- 2019.4.9f1 
- 2020.3.14f1
- 2021.1.16f1

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# Preview
---

<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/wwrVsWvl5LA' frameborder='0' allowfullscreen></iframe></div>


<details>
<summary markdown="span"> 
.
</summary>

[2021_0825_Screen_Effect_Demo.zip](https://github.com/rito15/Images/files/7048827/2021_0825_Screen_Effect_Demo.zip)

</details>



<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# Download & Import
---
- [Screen Effect Controller.unitypackage](https://github.com/rito15/Images/releases/download/0.3/Screen-Effect-Controller.unitypackage)

- 첨부 파일을 다운로드하고, 유니티 프로젝트가 켜져 있는 상태에서 실행합니다.

- 임포트 창이 나타나면 `Import` 버튼을 클릭하여 프로젝트에 임포트합니다.

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# 스크린 이펙트 쉐이더 작성 방법
---

- 스크린 이펙트를 적용하기 위해서는 일정 조건에 부합하는 쉐이더를 작성해야 합니다.

- 스크린 이펙트는 다음과 같은 방식으로 적용됩니다.

<br>

1. 쉐이더로부터 `_MainTex` 텍스쳐 프로퍼티가 있는지 확인합니다.
2. `_MainTex` 텍스쳐 프로퍼티에 현재 렌더링되는 화면의 색상이 입력됩니다.
3. 이 때, 스크린의 **UV**가 해당 텍스쳐의 **UV**로 사용됩니다.
4. 프래그먼트 쉐이더의 최종 출력이 화면에 렌더링됩니다.

<br>

- 정리하자면, 쉐이더의 `_MainTex` 프로퍼티에 스크린 색상이 입혀지고, 프래그먼트 쉐이더의 연산 결과가 다시 스크린에 입혀지는 간단한 흐름입니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[1] Image Effect Shader(Script)**

![image](https://user-images.githubusercontent.com/42164422/130840008-5463f98c-58b6-49c7-9d9e-2f3faca3b396.png)

- 유니티 엔진의 `Project` 윈도우에서 우클릭 - `Create` - `Shader` - `Image Effect Shader`를 통해 새로운 이미지 이펙트 쉐이더를 생성합니다.

- 그러면 다음과 같이 단순히 화면의 색상이 반전되는 프래그먼트 쉐이더를 확인할 수 있습니다.

```hlsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    // just invert the colors
    col.rgb = 1 - col.rgb;
    return col;
}
```

- `_MainTex`를 샘플링하여 얻은 색상을 기반으로 연산을 적용하고, `frag` 함수의 리턴으로 내보냄으로써 원하는 스크린 효과를 만들 수 있습니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[2] Amplify Shader**

![image](https://user-images.githubusercontent.com/42164422/130843833-8af3926e-5c80-4124-925c-04bc13521c8e.png)

- 유니티 엔진의 `Project` 윈도우에서 우클릭 - `Create` - `Amplify Shader` - `Legacy` - `Unlit`을 통해 새로운 쉐이더를 생성합니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/130844248-b3940234-383e-40fd-b755-b5efc6b4fee5.png)

에디터의 좌측 옵션에서 다음과 같이 설정합니다.

- Cull Mode : `Off`
- ZWrite Mode : `Off`
- ZTest Mode : `Always`

<br>

![image](https://user-images.githubusercontent.com/42164422/130844450-0d320308-4050-4f83-80db-df676b33487c.png)

- 새로운 `Texture Sample` 노드를 생성합니다. (단축키 : `T`)

- 이름을 `MainTex`로 변경합니다.

- `MainTex` 노드의 `RGBA` 출력을 마스터 노드의 `Frag Color`에 연결합니다.

- `MainTex` 노드의 색상을 기반으로 연산을 적용한 뒤 `Frag Color`에 최종 색상을 넣어주면 원하는 스크린 효과를 만들 수 있습니다.

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# How To Use
---

## **[1] 스크린 이펙트 추가, 적용하기**

![image](https://user-images.githubusercontent.com/42164422/130844769-793fc3da-c313-4185-adad-2bf5c6937c2f.png)

- 하이라키 창에서 우클릭 - `Effects` - `Screen Effect`를 클릭합니다.

- 새로운 게임오브젝트가 생성되며, `ScreenEffect` 컴포넌트가 추가됩니다.

- 씬에 존재하는 카메라에 `ScreenEffectController` 컴포넌트가 자동으로 추가됩니다.

- 생성된 `ScreenEffect` 컴포넌트의 **Effect Material**에 스크린 이펙트로 적용할 마테리얼을 넣어줍니다.

- 해당 게임오브젝트를 활성화/비활성화 하거나 On/Off 버튼을 클릭함으로써 해당 스크린 이펙트를 적용/해제 할 수 있습니다.


<br>

<!-- -------------------------------------------------------------------- -->

## **[2] 하이라키 표시**

IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 

- 현재 활성화된 스크린 이펙트는 하이라키 좌측에 하늘색 아이콘이 표시됩니다.
- 게임 오브젝트 이름 우측에는 해당 이펙트 마테리얼 이름, 우선순위가 표시됩니다.
- 가장 우측에는 활성화/비활성화 버튼이 표시되며, 이를 클릭하여 간단히 활성화/비활성화할 수있습니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[3] 옵션 설정**

IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 

- **On/Off 스위치**
  - 게임 오브젝트를 활성화/비활성화 합니다.
  
- **영어/한글 버튼**
  -  표시할 언어를 영어 또는 한글로 변경합니다.
  
- **이펙트 마테리얼**
  - 스크린 이펙트로 적용할 마테리얼을 등록합니다.
  - 에러가 발생하거나 쉐이더에 변경사항이 생겼을 때 `Reload` 버튼을 클릭하면 데이터가 다시 로드됩니다.

- **마테리얼 이름 표시**
  - 체크할 경우, 하이라키의 해당 이펙트 게임오브젝트 이름 우측에 마테리얼의 이름이 표시됩니다.

- **우선순위**
  - 여러 개의 스크린 이펙트가 적용될 때, 이펙트가 적용될 순서를 결정합니다.
  - 우선순위 값이 작을수록 화면에 먼저 적용됩니다.

- **시간 계산 방식**
  - 적용될 시간 계산 방식을 프레임/시간(초) 중에 결정합니다. 
  - 프레임을 선택한 경우, 기기의 성능에 따라 다른 결과를 나타낼 수 있습니다. 
  - 시간(초)을 선택한 경우, 기기의 성능에 관계 없이 실제 시간을 기준으로 시간이 계산됩니다.
  
- **지속 시간**
  - 스크린 이펙트가 활성화된 이후 유지될 시간을 설정합니다.
  - 0을 입력할 경우, 항상 지속되지만 시간별 이벤트를 사용할 수 없습니다.

- **종료 동작**
  - 지속 시간이 모두 진행되고 수행될 동작을 선택합니다.
  - `파괴`를 선택할 경우, 설정된 시간까지 진행되면 게임오브젝트가 파괴됩니다.
  - `비활성화`를 선택할 경우, 설정된 시간까지 진행되면 게임오브젝트가 비활성화됩니다.
  - `반복`을 선택할 경우, 설정된 시간까지 진행되면 처음부터 다시 진행되며, 계속 반복합니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[4] 마테리얼 프로퍼티 목록**

IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
-NOTE- 회색 흰색 시안 등등 각종 경우를 한 스샷에 다 보여주기

- 해당 마테리얼이 갖고 있는 프로퍼티의 목록을 표시합니다.
- 해당 이펙트 마테리얼의 프로퍼티 값을 언제든 수정할 수 있습니다.

- `[R]` 버튼을 클릭할 경우 해당 프로퍼티의 값을 초기값으로 설정합니다.
- 각 프로퍼티마다 우측의 `[+]` 버튼을 클릭하여 프로퍼티 이벤트를 생성할 수 있습니다.

- 이벤트가 생성된 프로퍼티의 `[E]` 버튼을 클릭할 경우, 이벤트가 동작하지 않도록 비활성화합니다.
- 이벤트가 비활성화된 프로퍼티의 `[D]` 버튼을 클릭할 경우, 이벤트가 동작하도록 활성화합니다.
- 이벤트가 등록된 프로퍼티의 `[-]` 버튼을 클릭할 경우, 해당 프로퍼티의 모든 이벤트가 제거됩니다.

- 이벤트가 존재하지 않는 프로퍼티는 하얀색으로 표시됩니다.
- 이벤트가 존재하며, 활성화된 프로퍼티는 청록색으로 표시됩니다.
- 이벤트가 존재하지만 비활성화된 프로퍼티는 회색으로 표시됩니다.


<br>

<!-- -------------------------------------------------------------------- -->

## **[5] 프로퍼티 이벤트**

IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 
IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE 

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# 타임라인과 연동하기(예시)
---



<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# Animator Event Controller와 연동하기(예시)
---

