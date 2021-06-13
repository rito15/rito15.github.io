---
title: UI(RectTransform)의 스크린 픽셀 크기 계산하기
author: Rito15
date: 2021-05-10 18:00:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Note
---

모든 UGUI 요소는 `RectTransform`을 통해 크기를 결정한다.

그리고 `RectTransform.rect`로 크기를 참조할 수 있다.

그런데 이 크기는 해상도가 변해도 항상 같은 값을 반환한다.

따라서 해상도를 기반으로 하는 드래그 등의 기능을 구현할 때

마우스 변위를 해상도 값으로 가져오고, 이를 `RectTransform`에 적용하면

해상도가 달라졌을 때 원치 않는 동작을 하게 된다.

`CanvasScaler`를 이용하면 현재 스크린에 따른 실제 픽셀 크기를 계산할 수 있다.

<br>

# 크기 계산
---

- `CanvasScaler`의 [UI Scale Mode]가 `Scale With Screen Size`일 경우에만 해당한다.

<br>

`CanvasScaler`는 `Reference Resolution` 값, `Match` 비율과 현재 해상도에 따라

`RectTransform`의 스크린 픽셀 크기를 계산한다.

`Match`는 `0` ~ `1` 값을 가지며,

`0`일 때는 기준 해상도와 현재 해상도의 너비 비율에 따라 `RectTransform`의 크기를 계산하고,

`1`일 때는 기준 해상도와 현재 해상도의 높이 비율에 따라 계산한다.

`0` ~ `1` 사이일 때는 너비, 높이 각각의 비율을 합산하여 결과 비율값을 계산한다.

<br>

## **Source Code**

```cs
CanvasScaler cs;
RectTransform rt;

float wRatio = Screen.width  / cs.referenceResolution.x;
float hRatio = Screen.height / cs.referenceResolution.y;

// 결과 비율값
float ratio =
    wRatio * (1f - cs.matchWidthOrHeight) +
    hRatio * (cs.matchWidthOrHeight);

// 현재 스크린에서 RectTransform의 실제 너비, 높이
float pixelWidth  = rt.rect.width  * ratio;
float pixelHeight = rt.rect.height * ratio;
```



