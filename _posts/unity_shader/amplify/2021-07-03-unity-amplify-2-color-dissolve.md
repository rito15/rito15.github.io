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

![image](https://user-images.githubusercontent.com/42164422/124363842-cbe68300-dc78-11eb-8830-13e81def11d2.png)

<br>

# Settings
---

## Blend Mode
 - `Transparent`

<br>

# Nodes
---

![ScreenshotASE](https://user-images.githubusercontent.com/42164422/124362158-55dd1e80-dc6e-11eb-9fa0-739f44e46108.png)

<br>

# Note
---

쉐이더 프로퍼티 중, `Min Offset`, `Max Offset`은 각각 디졸브의 시작과 끝 지점을 조정한다.

메시 정보 또는 디졸브 방향이 다르면 이 값들은 모두 달라질 수 있다.

이를 직접 계산하려면 굉장히 번거로우므로,

해당 마테리얼이 적용된 게임오브젝트에 첨부된 `Dissolve Shader Helper` 스크립트를 컴포넌트로 추가하고

원하는 `Dissolve Direction`을 컴포넌트 내에서 지정한 뒤

`Calculate and Apply To Material` 버튼을 클릭하면

자동으로 계산된 `Min Offset`, `Max Offset` 값이 마테리얼에 적용된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/124364171-a78ba600-dc7a-11eb-9862-c4ddf1977bd0.png)

첫 번째 버튼은 빠르게 값을 계산하지만 정확도가 낮고,

두 번째 버튼은 계산 속도가 느리지만 정확도가 높다.

<br>

# Download
---

- [2021_0703_Directional 2 Color Dissolve.zip](https://github.com/rito15/Images/files/6758892/2021_0703_Directional.2.Color.Dissolve.zip)

<br>


