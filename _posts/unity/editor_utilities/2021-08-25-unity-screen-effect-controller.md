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

## **테스트 완료 에디터 버전**

- 2018.3.14f1
- 2019.4.9f1 
- 2020.3.14f1
- 2021.1.16f1

<br>



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

# Download & Import
---
- [Screen Effect Controller.unitypackage](https://github.com/rito15/Images/releases/download/0.3/Screen-Effect-Controller.unitypackage)

- 첨부 파일을 다운로드하고, 유니티 프로젝트가 켜져 있는 상태에서 실행합니다.

- 임포트 창이 나타나면 `Import` 버튼을 클릭하여 프로젝트에 임포트합니다.

<br>



# How to Create Screen Effect Shader
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



# How To Use
---

![image](https://user-images.githubusercontent.com/42164422/130844769-793fc3da-c313-4185-adad-2bf5c6937c2f.png)

- 하이라키 창에서 우클릭 - `Effects` - `Add Screen Effect`를 클릭합니다.



<br>


작 성 중....

