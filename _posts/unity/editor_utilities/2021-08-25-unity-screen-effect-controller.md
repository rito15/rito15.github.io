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

- `스크린 이펙트`(포스트 프로세싱)를 간단히 적용할 수 있게 해주는 애셋입니다.

- 게임 오브젝트의 단순 활성화/비활성화 방식으로 스크린 이펙트를 적용/해제합니다.

- 시간에 따른 마테리얼 프로퍼티의 값 변화 `애니메이션`을 쉽게 제작할 수 있습니다.

- 유니티 `타임라인`에도 손쉽게 연동할 수 있습니다.

- 유니티 기본 렌더 파이프라인(Built-in Render Pipeline)에서 사용할 수 있습니다.
  - SRP, URP, HDRP에서는 사용할 수 없습니다.

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

## **[1] Demo Scene Preview**

<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/wwrVsWvl5LA' frameborder='0' allowfullscreen></iframe></div>

<br>

<details>
<summary markdown="span"> 
예제 다운로드
</summary>

- [Screen-Effect-Controller-Demo.zip](https://github.com/rito15/Images/files/7072067/Screen-Effect-Controller-Demo.zip)

</details>

<br>

## **[2] Component Preview**

![image](https://user-images.githubusercontent.com/42164422/131242291-405c51ac-50f5-4b42-aa79-79d44231e259.png)


<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# Download & Import
---

## **Screen Effect Controller**

- [Screen Effect Controller.unitypackage](https://github.com/rito15/Unity-Useful-Editor-Assets/releases/download/1.02/Screen-Effect-Controller.unitypackage)

- 첨부 파일을 다운로드하고, 유니티 프로젝트가 켜져 있는 상태에서 실행합니다.

- 임포트 창이 나타나면 `Import` 버튼을 클릭하여 프로젝트에 임포트합니다.

![image](https://user-images.githubusercontent.com/42164422/131219650-3a6e5e1d-b808-4bc7-9a75-f301806f1d0a.png)

<br>

## **추가 : 스크린 이펙트 쉐이더 모음집**

- [Screen Effect Shaders.unitypackage](https://github.com/rito15/Unity-Useful-Editor-Assets/releases/download/1.03/Screen-Effect-Shaders.unitypackage)

- 지금까지 직접 만든 스크린 이펙트 쉐이더들을 모아 놓았습니다.

- 추후 조금씩 업데이트할 예정입니다.

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

# 사용 방법
---

## **[1] 스크린 이펙트 추가, 적용하기**

![image](https://user-images.githubusercontent.com/42164422/131219054-6ee1a5a4-bad9-4301-a948-bd9e2ee64cf7.png)

![image](https://user-images.githubusercontent.com/42164422/131091349-f30ff002-17c4-469e-b099-049f20f95ee8.png)

- 하이라키 창에서 우클릭 - `Effects` - `Screen Effect`를 클릭합니다.

- 새로운 게임오브젝트가 생성되며, `ScreenEffect` 컴포넌트가 추가됩니다.

- 씬에 존재하는 카메라에 `ScreenEffectController` 컴포넌트가 자동으로 추가됩니다.

- 생성된 `ScreenEffect` 컴포넌트의 **Effect Material**에 스크린 이펙트로 적용할 마테리얼을 넣어줍니다.

- 해당 게임오브젝트를 활성화/비활성화 하거나 On/Off 버튼을 클릭함으로써 해당 스크린 이펙트를 적용/해제 할 수 있습니다.


<br>

<!-- -------------------------------------------------------------------- -->

## **[2] 하이라키 표시**

![image](https://user-images.githubusercontent.com/42164422/131214096-614619f7-7f53-4013-8d1c-95ad47291e41.png)

- 현재 활성화된 스크린 이펙트는 하이라키 좌측에 하늘색 아이콘이 표시됩니다.
- 마테리얼 등록 시 쉐이더 이름이 게임오브젝트 이름에 함께 표시됩니다. (`Screen Effect [ShaderName]`)
- 게임오브젝트 이름 우측에는 이펙트 적용 우선순위가 표시됩니다.
- 가장 우측에는 ON/OFF 버튼이 표시되며, 이를 클릭하여 간단히 활성화/비활성화할 수있습니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[3] 옵션 설정**

- 마테리얼이 등록되지 않은 경우

![image](https://user-images.githubusercontent.com/42164422/131123037-271a6b90-1eca-4c24-ae9b-9ef3f66a2314.png)

- 마테리얼이 등록된 경우

![image](https://user-images.githubusercontent.com/42164422/131242408-c76d8eb7-0a52-4c75-8b3d-642edcad2c31.png)

- 지속 시간을 설정한 경우

![image](https://user-images.githubusercontent.com/42164422/131242420-6a6a35fd-3b84-4ee4-9a07-e3db281fcb6f.png)

- 시간 계산 방식을 `프레임`으로 설정하고, `기준 FPS 사용`에 체크한 경우

![image](https://user-images.githubusercontent.com/42164422/131242429-44c90232-355f-4c30-b541-87046690c29d.png)

<br>

- **On/Off 스위치**
  - 게임 오브젝트를 활성화/비활성화 합니다.
  
  <br>
  
- **영어/한글 버튼**
  -  표시할 언어를 영어 또는 한글로 변경합니다.
  
  <br>
  
- **이펙트 마테리얼**
  - 스크린 이펙트로 적용할 마테리얼을 등록합니다.
  - 에러가 발생하거나 쉐이더에 변경사항이 생겼을 때 `Reload` 버튼을 클릭하면 데이터가 다시 로드됩니다.
  
  <br>

- **우선순위**
  - 여러 개의 스크린 이펙트가 적용될 때, 이펙트가 적용될 순서를 결정합니다.
  - 우선순위 값이 작을수록 화면에 먼저 적용됩니다.
  - 우선순위 값은 하이라키의 ON/OFF 버튼 왼쪽에 표시됩니다.
  
  <br>

- **시간 계산 방식**
  - 적용될 시간 계산 방식을 `프레임`/`시간(초)` 중에 결정합니다. 
  - `프레임`을 선택한 경우, 매 프레임마다 애니메이션이 갱신됩니다.
  - `시간(초)`을 선택한 경우, 기기의 성능에 관계 없이 실제 시간을 기준으로 시간이 계산됩니다.
  
  <br>
  
- **지속 시간**
  - 스크린 이펙트가 활성화된 이후 유지될 시간을 설정합니다.
  - 0을 입력할 경우, 항상 지속되지만 프로퍼티 애니메이션을 사용할 수 없습니다.
  
  <br>
  
- **지속 시간 변경 시 동작**
  - 프로퍼티 애니메이션이 존재하는 경우, 지속 시간을 변경했을 때 동작을 지정합니다.
  - `시간 비율 유지`
    - 시간 비율을 유지한 채로 각 애니메이션 키의 시간 값을 변경합니다.
    - 예시 : 지속 시간이 2초, 애니메이션 키가 0초, 1초, 2초에 있었을 경우, 지속 시간을 4초로 변경하면 각각 0초, 2초, 4초로 변경됩니다.
  - `시간 값 유지`
    - 각 애니메이션 키의 시간 값을 그대로 유지한 채로 전체 지속 시간만 변경합니다.
    - 지속 시간을 감소시켰을 경우, 지속 시간보다 큰 시간 값을 갖는 애니메이션 키는 제거됩니다.
    - 예시 : 지속 시간이 4초, 애니메이션 키가 0초, 1초, 2초, 3초, 4초에 있었을 경우, 지속 시간을 2초로 변경하면 3초, 4초의 애니메이션 키는 제거됩니다.
  
  <br>
  
- **기준 FPS 사용**
  - 시간 계산 방식을 `프레임`으로 설정한 경우 사용할 수 있습니다.
  - `기준 FPS 사용`에 체크 해제한 경우, 기기의 성능에 따라 다른 결과를 나타낼 수 있습니다.
  - `기준 FPS 사용`에 체크한 경우, 기기의 성능에 관계 없이 일정한 시간 동안 지속됩니다.
  
  <br>
  
- **기준 FPS**
  - 시간 계산 방식을 `프레임`으로 설정하고 `기준 FPS 사용`에 체크한 경우 설정할 수 있습니다.
  - 프레임 계산을 실제 시간에 동기화하기 위한 `기준 FPS` 값을 설정합니다.
  - 예를 들어 지속 프레임이 `120프레임`, 기준 FPS가 `60`인 경우 기기의 성능에 관계 없이 항상 `2초` 동안 지속됩니다.
  - 타임라인을 사용할 때, 타임라인의 `Frame Rate`와 동일하게 설정하면 됩니다.
  
  <br>

- **종료 동작**
  - 지속 시간이 모두 진행되고 수행될 동작을 선택합니다.
  - `마지막 상태 유지`를 선택할 경우, 설정된 시간까지 진행되면 그 상태를 계속 유지합니다.
  - `비활성화`를 선택할 경우, 설정된 시간까지 진행되면 게임오브젝트가 비활성화됩니다.
  - `파괴`를 선택할 경우, 설정된 시간까지 진행되면 게임오브젝트가 파괴됩니다.
  - `반복`을 선택할 경우, 설정된 시간까지 진행되면 처음부터 다시 진행되며, 계속 반복합니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[4] 마테리얼 프로퍼티 목록**

![image](https://user-images.githubusercontent.com/42164422/131123532-d4cdfb6c-1164-49e7-a222-a63a4c763ea5.png)

- 해당 마테리얼이 갖고 있는 프로퍼티의 목록을 표시합니다.
- 해당 이펙트 마테리얼의 프로퍼티 값을 언제든 수정할 수 있습니다.

- `[R]` 버튼을 클릭할 경우 해당 프로퍼티의 값을 초기값으로 변경합니다.
- 각 프로퍼티마다 우측의 `[+]` 버튼을 클릭하여 프로퍼티 애니메이션을 생성할 수 있습니다.

- 애니메이션이 활성화된 프로퍼티의 `[E]` 버튼을 클릭할 경우, 애니메이션이 동작하지 않도록 비활성화합니다.
- 애니메이션이 비활성화된 프로퍼티의 `[D]` 버튼을 클릭할 경우, 애니메이션이 동작하도록 활성화합니다.
- 애니메이션이 등록된 프로퍼티의 `[-]` 버튼을 클릭할 경우, 해당 프로퍼티의 애니메이션이 제거됩니다.

- 애니메이션이 존재하지 않는 프로퍼티는 하얀색으로 표시됩니다.
- 애니메이션이 존재하며, 활성화된 프로퍼티는 하늘색으로 표시됩니다.
- 애니메이션이 존재하지만 비활성화된 프로퍼티는 회색으로 표시됩니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[5] 프로퍼티 애니메이션**

![image](https://user-images.githubusercontent.com/42164422/131243123-549dd05a-fc1d-4a8b-a393-4a4e2e4f7815.png)

- 정해진 지속 시간 동안, 시간 진행에 따른 마테리얼 프로퍼티의 값 변화를 애니메이션으로 정의합니다.

- 타이틀 바의 좌측에는 프로퍼티의 이름과 타입이 표시됩니다.

- `Enabled`/`Disabled` 버튼을 클릭하여 애니메이션을 활성화/비활성화 할 수 있습니다.
- 활성화된 애니메이션은 타이틀 바가 하늘색으로 표시됩니다.
- 비활성화된 애니메이션은 타이틀 바가 검은색으로 표시됩니다.

- `[-]` 버튼을 클릭하여 해당 프로퍼티 애니메이션을 제거할 수 있습니다.

<br>

### **[5-1] 애니메이션 키 목록**

![image](https://user-images.githubusercontent.com/42164422/131462679-a04bcede-29d0-48c9-bece-5a0598895f06.png)

- 애니메이션을 이루는 애니메이션 키 목록을 표시합니다.
- 쉐이더에서 직접 정의하기 힘든, 시간에 따른 값의 변화를 애니메이션을 통해 손쉽게 정의할 수 있습니다.

<br>

- `애니메이션 표시`/`애니메이션 숨기기` 버튼을 클릭하여 애니메이션 키 목록을 표시하거나 숨길 수 있습니다.
- 각 애니메이션 키 사이사이의 `[+]` 버튼을 클릭하여, 해당 위치에 새로운 애니메이션 키를 추가할 수 있습니다.
- 각 애니메이션 키 우측의 `[-]` 버튼을 클릭하여, 해당 키를 제거할 수 있습니다.

- 각 애니메이션 키 우측의 `[C]` 버튼을 클릭할 경우, 해당 키의 프로퍼티 값을 복사합니다.
- 이후 `[P]` 버튼을 누를 경우, 복사된 값을 해당 키에 붙여넣습니다. (타입이 일치해야 합니다.)

<br>

- 애니메이션 키의 사이에서, 해당 프로퍼티의 값은 선형 보간되어 적용됩니다.

- 예를 들어 위 애니메이션의 경우, `Range` 프로퍼티의 값이 시간에 따라 다음과 같이 변화합니다.
  - `0.0초` ~ `1.0초` : 값이 `0.0`에서부터 `0.5`까지 순차적으로 증가합니다.
  - `1.0초` ~ `2.0초` : 값이 `0.5`에서부터 `0.0`까지 순차적으로 감소합니다.
  - `2.0초` ~ `2.5초` : 값이 `0.0`에서부터 `1.0`까지 순차적으로 증가합니다.
  - `2.5초` ~ `4.0초` : 값이 `1.0`에서부터 `0.0`까지 순차적으로 감소합니다.

<br>

### **[5-2] 애니메이션 그래프**

![image](https://user-images.githubusercontent.com/42164422/131182088-bb164819-5965-45d6-a6f5-bba86ea84613.png)

- 현재 등록된 애니메이션 정보에 따라, 해당 프로퍼티 값의 변화를 그래프를 통해 시각적으로 확인할 수 있습니다.

- 그래프 내에 반투명한 실선을 통해 애니메이션 키가 표시됩니다.

- 그래프 하단에 각 키의 `인덱스` 또는 `시간`/`프레임`이 표시됩니다.

- 그래프 좌측 상단의 버튼을 클릭하여 `인덱스`를 표시할지, `시간`/`프레임`을 표시할지 결정할 수 있습니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131463600-be454021-79d5-443f-881c-0da31aa86e5e.png)

- `Vector`, `Color` 타입의 경우, `X`, `Y`, `Z`, `W` 값의 변화를 각각의 그래프로 확인할 수 있습니다.

- `X`, `Y`, `Z`, `W` 또는 `R`, `G`, `B`, `A` 토글 버튼을 클릭하여, 원하는 요소의 그래프만 필터링하여 표시할 수 있습니다.

<br>

### **추가 기능 : 키 이동, 추가, 삭제**

![2021_0830_ScreenEffect_MoveKey](https://user-images.githubusercontent.com/42164422/131262483-69013877-dd99-43f0-872a-23236d7daf4b.gif)

- 그래프 하단의 키 부분을 마우스 좌클릭 및 드래그하여 좌우로 이동할 수 있습니다.
- `Control` 키를 누른 채로 드래그할 경우, 시간은 `0.1`초, 프레임은 `10` 단위로 이동합니다.
- `Shift` 키를 누른 채로 드래그할 경우, 시간은 `0.05`초, 프레임은 `5` 단위로 이동합니다.

![2021_0830_ScreenEffect_RemoveKey](https://user-images.githubusercontent.com/42164422/131262484-409f0c2a-df31-43af-bfa4-1ed265cf1d32.gif)

- 그래프 하단의 키 부분을 마우스 우클릭하여 해당 키를 제거할 수 있습니다.

![2021_0830_ScreenEffect_InsertKey](https://user-images.githubusercontent.com/42164422/131304959-d3b465d7-21c6-4f87-bac6-c19e1ef9e7d3.gif)

- 그래프 하단에서 키가 없는 부분을 마우스 우클릭하여 새로운 키를 추가할 수 있습니다.

<br>

### **[5-3] 애니메이션 그라디언트**

![image](https://user-images.githubusercontent.com/42164422/131463898-44345965-0634-4156-bc2d-f956d3d8224f.png)

- `Color` 타입의 경우, 우측 상단의 `그라디언트`/`그래프` 버튼을 클릭하여 색상 표시 방법을 변경할 수 있습니다.

- 애니메이션 키의 개수가 8개를 초과하는 경우, `그라디언트`로 표시할 수 없습니다.

<br>

<!-- -------------------------------------------------------------------- -->

## **[6] 플레이모드 기능**

![2021_0827_ScreenEffect_EditorOptions](https://user-images.githubusercontent.com/42164422/131140754-5ab2e195-3bfe-4d17-b637-21e3cc043b07.gif)

- 지속 시간이 0보다 큰 경우에만 표시됩니다.

- 유니티 에디터가 플레이모드에 진입한 경우, `에디터 기능` 탭에서 현재 경과 시간을 실시간으로 확인할 수 있습니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131140912-3c27f154-8932-4cd2-a72e-0269b323bf7c.png)

- `편집 모드`에 체크한 경우 시간 진행이 일시 정지되며, 슬라이더를 조작하여 원하는 시간으로 이동할 수 있습니다.

<br>

![2021_0827_ScreenEffect_EditorOptions_MoveKey](https://user-images.githubusercontent.com/42164422/131184561-b0ccfa2d-f435-4ceb-9fe4-e01dd1c45ffd.gif)

- `편집 모드`에 체크된 상태에서 각 애니메이션 그래프를 클릭하여 원하는 시간으로 이동할 수 있습니다.

- `편집 모드`가 아닌 상태에서 각 애니메이션 그래프를 클릭한 경우, `편집 모드`로 진입하며 시간 진행이 정지됩니다.

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# Animator Event Controller와 연동하기(예시)
---

- **Animator Event Controller**
  - <https://rito15.github.io/posts/unity-animator-event-controller/>
  - 애니메이터의 애니메이션 클립마다 원하는 프레임에 이펙트를 생성할 수 있는 애셋입니다.

<br>

## **[1] 스크린 이펙트 준비**

- <https://rito15.github.io/posts/unity-amplify-screen-shake/>

![image](https://user-images.githubusercontent.com/42164422/131215160-5b6e6db0-01b6-4863-bed8-945791a09551.png)

![image](https://user-images.githubusercontent.com/42164422/131214510-5d1b10f4-fc5a-4035-b4c1-0c31e84eff39.png)

- 하이라키 우클릭 - `Effects` - `Screen Effect`를 통해 새로운 스크린 이펙트를 생성합니다.

- 화면을 흔드는 효과가 구현된 **Screen Shake** 마테리얼을 `이펙트 마테리얼`에 넣어줍니다.

- 지속 시간을 `0.3초`로 지정하고, 종료 동작을 `파괴`로 설정합니다.

- 마테리얼 프로퍼티 목록에서 각 프로퍼티들을 원하는 값으로 설정합니다.

- 종료 동작이 `파괴`이므로 게임 시작 후 `0.3초`가 지나면 게임오브젝트가 파괴됩니다.<br>
  따라서 원본 오브젝트가 파괴되지 않도록 `Off`를 클릭하여 게임오브젝트를 비활성화 상태로 만들어줍니다.

- 비활성화 상태로 씬에 그대로 두어도 되고, 따로 프리팹으로 추출해도 됩니다.

<br>

## **[2] 애니메이션 제작**

![2021_0827_ScreenEffect_Example_Anim](https://user-images.githubusercontent.com/42164422/131207929-544b4505-5ad2-4c6a-9f79-34f8ac48c61e.gif)

- Sphere가 공중으로 뛰어올랐다가 바닥으로 착지하기를 반복하는 간단한 애니메이션을 제작합니다.

- `Animator Controller`를 생성하여 제작한 애니메이션 클립을 추가하고 시작 애니메이션으로 설정합니다.

- 게임오브젝트에 `Animator` 컴포넌트를 추가하고, `Controller`를 등록해줍니다.

<br>

## **[3] 애니메이터 이벤트 생성**

![image](https://user-images.githubusercontent.com/42164422/131208243-41ec765a-5c22-4273-94d3-31bcb36a923e.png)

- `Animator` 컴포넌트에 우클릭하여 `Add Animator Event Controller`를 클릭하면 `Animator Event Controller` 컴포넌트가 추가됩니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131208269-317df8e1-4220-4fa3-b8f3-a0fdba676d31.png)

- `[+]` 버튼을 클릭하여 새로운 이벤트를 추가합니다.

- `프리팹 오브젝트`에 위에서 생성한 `Screen Shake` 게임오브젝트를 드래그하여 넣어줍니다.

- 생성 프레임을 알맞게 설정합니다. (땅에 찍는 순간인 `79` 프레임으로 설정하였습니다.)

<br>

## **[4] 결과 확인**

![2021_0827_ScreenEffect_Example_Anim2](https://user-images.githubusercontent.com/42164422/131208342-e8d635dc-8b0a-4d73-980b-8d42048032d4.gif)

![2021_0827_ScreenEffect_Example_Anim3](https://user-images.githubusercontent.com/42164422/131208366-47c1ac80-1bf6-464e-ac0c-bbb4b49e4c13.gif)

- **Sphere**가 땅에 찍을 때마다 `Screen Shake` 이펙트 게임오브젝트가 생성되고, `0.3초` 후에 파괴되며 그동안 스크린 이펙트가 적용되는 것을 확인할 수 있습니다.

<br>

## **데모 씬 다운로드**

- 반드시 [Animator-Event-Controller](https://github.com/rito15/Unity-Useful-Editor-Assets/releases/download/1.01/Animator-Event-Controller.unitypackage) 를 프로젝트에 임포트 완료한 상태에서 아래의 데모 씬을 임포트 해야 합니다.

- [Screen-Effect-Controller-Demo2.zip](https://github.com/rito15/Images/files/7070845/Screen-Effect-Controller-Demo2.zip)

<br>

<!-- -------------------------------------------------------------------- -->
<!-- -------------------------------------------------------------------- -->

# 타임라인과 연동하기(예시)
---

- 이 애셋은 게임오브젝트 활성화/비활성화 동작에 따라 스크린 이펙트가 적용/해제됩니다.

- 따라서 타임라인의 `Activation Track`을 통해 편리하게 사용할 수 있습니다.

<br>

## **[1] Meteor 이펙트**

![2021_0827_SE_TimelineDemo_01](https://user-images.githubusercontent.com/42164422/131216116-a42c000d-9e12-444d-a1d6-20965caac62c.gif)

- 파티클 시스템을 통해, 운석들이 낙하하는 이펙트를 제작합니다.

- 대략 2~3초간 지속됩니다.

<br>

## **[2] 스크린 이펙트 : Shake**

![image](https://user-images.githubusercontent.com/42164422/131216692-8f6fcffe-1a88-4e9e-b97d-22ce1ee5605b.png)

- <https://rito15.github.io/posts/unity-amplify-screen-shake/>

- 화면이 흔들리는 단순한 이펙트입니다.

- 타임라인과 연동할 예정이므로, 시간 계산 방식을 `프레임`으로 설정하고 `기준 FPS`를 `60`으로 지정합니다.

- 타임라인에 의해 활성화/비활성화가 제어되므로 종료 동작 무엇이든 상관 없지만, 일단 `비활성화`로 설정합니다.

- 0프레임부터 180프레임까지 `Shake Intensity` 값이 `0`부터 `0.2`까지 증가하도록 애니메이션을 설정합니다.

- 시간 흐름에 따라 흔들리는 강도가 점차 강해집니다.

- `Meteor` 이펙트의 첫 운석이 땅에 처음 부딪히는 순간부터 마지막 운석이 부딪히는 순간까지 `Shake` 이펙트가 동작하도록 할 예정이며, 구체적인 시간 조정은 타임라인 구성과 함께 할 것이므로, 일단 지속 시간을 `180` 프레임으로 설정합니다.

<br>

## **[3] 스크린 이펙트 : Hexagonal Pattern**

![image](https://user-images.githubusercontent.com/42164422/131216887-0abf6e8c-1274-4f03-b0f9-658cdce69295.png)

- <https://rito15.github.io/posts/unity-amplify-screen-hexagons/>

- 마찬가지로 지속 시간은 `180` 프레임으로 대강 설정합니다.

- `Hexagon` 이펙트가 `Shake` 이펙트로 인해 흔들리지 않도록, 우선순위를 `1`로 설정합니다.

- 운석이 떨어지기 전에 이 스크린 이펙트가 화면 가장자리에서부터 화면을 뒤덮고,<br>
  운석이 모두 떨어지고 나서 화면에서 부드럽게 사라지도록 애니메이션을 제작할 것입니다.
  
- 이펙트의 영역 크기에 영향을 주는 프로퍼티는 `Area Range`, `Area Power` 입니다.

- 두 프로퍼티에 대해 애니메이션을 제작합니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131216918-9afa688f-4aab-4c69-8dc9-c6aa48e54d4a.png)

- 우선, `마테리얼 프로퍼티 목록`에서 두 프로퍼티의 우측 `[+]` 버튼을 각각 클릭하여 애니메이션을 추가합니다.

- 애니메이션 확인 및 수정은 플레이모드에 진입 후, `에디터 기능` - `편집 모드`를 설정하여 진행하는 것이 좋습니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131217077-effef320-ff18-48c8-9575-931be1d2f1c0.png)

- `Area Range` 프로퍼티에 대한 애니메이션을 위와 같이 제작합니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131217317-ccb3bcb8-b220-41b0-8670-6d2279b4cb45.png)

- 마찬가지로 `Area Power` 프로퍼티 애니메이션을 위와 같이 제작합니다.

<br>

![2021_0827_SE_TimelineDemo_02](https://user-images.githubusercontent.com/42164422/131217342-7319d116-d007-4ccc-bc8b-964020b9b9da.gif)

- 위와 같은 결과를 확인할 수 있습니다.

<br>

## **[4] 타임라인 제작**

- 빈 게임 오브젝트를 만들고, 이름을 `Timeline`으로 변경합니다.

- `Window` - `Sequencing` - `Timeline`을 통해 타임라인 윈도우를 엽니다.

- 생성한 빈 게임오브젝트를 클릭한 상태로 타임라인 윈도우에서

![image](https://user-images.githubusercontent.com/42164422/131217410-8729b3c3-c2a1-4115-812c-aa1bdb6c7ac4.png)

- `Create` 버튼을 클릭하여 새로운 타임라인 애셋을 생성합니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131217440-34ed4d24-1aaf-4b0b-b48b-698b223459c2.png)

- `[+]` 버튼을 클릭하여 `Activation Track` 세 개를 생성합니다.

![image](https://user-images.githubusercontent.com/42164422/131217494-daab9794-4db9-4a74-a6c0-e73683f979be.png)

- 각각 씬에 있는 `Meteor`, `Shake`, `Hexagon` 이펙트 게임오브젝트들을 넣어줍니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131218454-c0c9cf73-023e-4ae2-9594-0c8b6df3600b.png)

- 각 트랙을 선택하여, 시작 프레임은 `60`, 지속 프레임은 `180`으로 설정합니다.

- 이 상태를 기점으로, 원하는 결과를 얻을 때까지 `Shake`, `Hexagon` 이펙트의 시작 프레임과 지속 프레임을 변경하며 테스트합니다.

- 트랙의 지속 프레임을 수정할 때마다, 해당 `Screen Effect`의 지속 프레임도 함께 변경해주어야 합니다.

<br>

- `Screen Effect`의 `Activation Track` 종료 부분이 타임라인의 마지막 시점과 일치하는 경우, 타임라인 종료와 동시에 다시 활성화되는 경우가 있습니다.

![image](https://user-images.githubusercontent.com/42164422/131218685-eb3ea663-bb19-419c-9ef5-484089279e1c.png)

- 이럴 때는 위와 같이 타임라인의 눈금자 부분을 우클릭하여 `Duration Mode` - `Fixed Length`로 설정하고,

![image](https://user-images.githubusercontent.com/42164422/131218702-ed1dac8c-abc5-4047-91bd-07a66c152471.png)

- 파란 선을 드래그하여 여유 있게 약간 우측으로 이동시켜주면 됩니다.

<br>

## **[5] 최종 결과**

![2021_0827_SE_TimelineDemo_03](https://user-images.githubusercontent.com/42164422/131218844-a6e5bdc2-78a3-4da2-9efb-d5670ebbc5db.gif)

![image](https://user-images.githubusercontent.com/42164422/131218774-0b22bde4-6450-46db-a156-428efd17254a.png)

- `Meteor` - 시작 : `60`, 지속 : `180` (60 ~ 240)
- `Shake` - 시작 : `100`, 지속 : `120` (100 ~ 220)
- `Hexagon` - 시작 : `40`, 지속 : `220` (40 ~ 260)

<br>

# Future Works
---

- SRP 지원
- 애니메이션 그라디언트 뷰 : 키 개수가 8개를 초과하는 경우에도 표시할 수 있는 커스텀 그라디언트 필드 구현
