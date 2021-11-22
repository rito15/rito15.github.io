---
title: 유니티 - Material Property Block을 통해 프로퍼티 값 변경하기
author: Rito15
date: 2021-05-22 18:00:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization, material, batch]
math: true
mermaid: true
---

# 드로우 콜과 배칭의 개념
---

- [포스트 : 드로우 콜과 배칭](../unity-draw-call-and-batching/)

<br>

# 마테리얼 프로퍼티 값 변경하기
---

`MeshRenderer.material.Set~` 메소드를 통해

스크립트에서 마테리얼 특정 프로퍼티의 값을 실시간으로 변경할 수 있다.

하지만 이렇게 `.material`에 접근하여 프로퍼티를 수정하면

![image](https://user-images.githubusercontent.com/42164422/119224429-5cd62480-bb39-11eb-9070-75f745c403b8.png)

이런식으로 마테리얼이 개별 인스턴스로 복제되어, 배칭이 깨지게 된다.

(`.material`에 접근하기만 해도 바로 개별 인스턴스가 생성된다.)

<br>

이를 방지할 수 있는 것이 `Material Property Block`, `GPU Instancing`이다.

`Material Property Block`을 이용하여 프로퍼티 값을 수정할 경우,

마테리얼의 복사본을 생성하지 않고 값을 수정할 수 있다.

그리고 `GPU Instancing`을 적용하면 동일 마테리얼에 대해

드로우콜을 통합하여 동적 배칭을 적용할 수 있다.

<br>

# 1. 프로퍼티 값을 그냥 수정하는 경우
---

```cs
private MeshRenderer[] renderers;

private void Start()
{
    renderers = GetComponentsInChildren<MeshRenderer>();
    SetRandomProperty();
}

private void SetRandomProperty()
{
    foreach (var r in renderers)
    {
        r.material.SetColor("_Color", UnityEngine.Random.ColorHSV());
        r.material.SetFloat("_Metallic", UnityEngine.Random.Range(0f, 1f));
    }
}
```

<br>

## [1] GPU Instancing 미적용

![image](https://user-images.githubusercontent.com/42164422/119224609-31076e80-bb3a-11eb-9dd1-014b8685de72.png)

- Batches : 172
- 배칭이 전혀 되지 않는다.

<br>

## [2] GPU Instncing 적용

![image](https://user-images.githubusercontent.com/42164422/119224722-c7d42b00-bb3a-11eb-9619-9b7a682da0d5.png)

- Batches : 96
- 일부 배칭된다.

<br>

# 2. Material Property Block을 통해 수정하는 경우
---

`MaterialPropertyBlock` 객체를 생성하고,

`MaterialPropertyBlock.Set~` 메소드를 통해 프로퍼티 값을 수정한 뒤

`MeshRenderer.SetPropertyBlock()` 메소드를 통해 수정된 값을 적용한다.

마테리얼마다 `MaterialPropertyBlock` 객체를 따로 생성해도 되고, 객체를 재사용해도 된다.

```cs
private MeshRenderer[] renderers;
private MaterialPropertyBlock mpb;

private void Start()
{
    renderers = GetComponentsInChildren<MeshRenderer>();
    mpb = new MaterialPropertyBlock();
    SetRandomPropertyWithMPB();
}

private void SetRandomPropertyWithMPB()
{
    foreach (var r in renderers)
    {
        mpb.SetColor("_Color", UnityEngine.Random.ColorHSV());
        mpb.SetFloat("_Metallic", UnityEngine.Random.Range(0f, 1f));
        r.SetPropertyBlock(mpb);
    }
}
```

<br>

## [1] GPU Instancing 미적용

![image](https://user-images.githubusercontent.com/42164422/119225251-a0cb2880-bb3d-11eb-9584-8fae0cdcb790.png)

- Batches : 172
- `Material Property Block`을 통해 프로퍼티를 수정해도<br>
  `GPU Instancing`을 적용하지 않으면 배칭이 되지 않는다.

<br>

## [2] GPU Instancing 적용

![image](https://user-images.githubusercontent.com/42164422/119225287-d7a13e80-bb3d-11eb-910d-2eb05ceab02b.png)

- Batchs : 52
- 프로퍼티 블록을 쓰지 않는 것보다는 더 많이 배칭된다.

<br>

## [3] GPU Instancing + Instancing Buffer

스크립트를 통해 수정할 프로퍼티들을 쉐이더에서 Instancing Buffer 내에 선언해준다.

<br>

- 기존 쉐이더 코드(Surface Shader 예제)

```hlsl
fixed4 _Color;
half _Metallic;

void surf (Input IN, inout SurfaceOutputStandard o)
{
    fixed4 c = _Color;
    o.Metallic = _Metallic;

    o.Albedo = c.rgb;
}
```

- 변경된 쉐이더 코드

```hlsl


UNITY_INSTANCING_BUFFER_START(Props)

    UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
    UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)

UNITY_INSTANCING_BUFFER_END(Props)

void surf (Input IN, inout SurfaceOutputStandard o)
{
    fixed4 c   = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
    o.Metallic = UNITY_ACCESS_INSTANCED_PROP(Props, _Metallic);

    o.Albedo = c.rgb;
}
```

- 참고 : Vertex/Fragment Shader 예제
  - <https://docs.unity3d.com/kr/2021.1/Manual/GPUInstancing.html>

<br>

![image](https://user-images.githubusercontent.com/42164422/119225786-efc68d00-bb40-11eb-8bf9-6111f328bfe4.png)

- Batches : 8
- 이제 완벽히 배칭되는 것을 확인할 수 있다.

<br>

# 결론
---

프로퍼티 값을 스크립트에서 수정하면서 동적 배칭을 적용하기 위해서는

1. 수정할 프로퍼티를 쉐이더에서 `Instancing Buffer` 내에 선언한다.
2. 마테리얼에서 `Enable GPU Instancing`에 체크한다.
3. 스크립트에서 `Material Property Block`을 통해 값을 수정한다.

<br>

## 주의사항
 - 런타임에 정적 배칭 대상의 프로퍼티 값을 수정하면 배칭이 완전히 깨져버린다.
 - 따라서 런타임에 프로퍼티 값을 수정할 대상에는 동적 배칭을 적용해야 한다.

<br>

# References
---
- <https://cafe.naver.com/unityhub/41266>
- <https://funfunhanblog.tistory.com/301?category=818491>
- <https://thomasmountainborn.com/2016/05/25/materialpropertyblocks/>
- <https://docs.unity3d.com/kr/2021.1/Manual/GPUInstancing.html>
- <https://docs.unity3d.com/kr/current/Manual/DrawCallBatching.html>