---
title: 유니티 - sRGB, Linear, Gamma 컬러 스페이스
author: Rito15
date: 2021-09-29 03:21:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 모니터의 색상 변환
---
- 모니터는 디스크에 저장된 이미지를 화면에 출력할 때 `Pow(color, 2.2)` 연산을 적용해서 더 어둡게 출력한다.

![image](https://user-images.githubusercontent.com/42164422/135145554-2579fc60-b16a-470d-acfb-9128ae21131f.png)


- 이유?
  - 베버의 법칙(Weber's law)
  - 사람의 시각은 어두운 부분의 밝기 변화를 부드럽지 않고 단절되게 감지한다.
  - 그래서 어두운 부분의 화질이 떨어져 보이는 현상이 발생한다.
  - 따라서 이를 부드럽게 감지하도록 하려면 어두운 부분을 더 풍부하게 표현할 필요가 있다.
  - 따라서 모니터 하드웨어적으로 이런 변환을 해준다.

- `Pow(color, 2.2)`이면 감마(Gamma)가 `2.2`라고 한다.

<br>

# Gamma Correction(감마 보정)이란?
---
- 이미지를 디스크에 저장할 때 `Pow(color, 1/2.2)` 연산을 적용해서 더 밝게 저장한다.
- 모니터의 색상 변환에 대응하여, 원본 색상을 화면에 제대로 출력하기 위해 수행한다.
- `1/2.2` = `0.4545....`

![image](https://user-images.githubusercontent.com/42164422/135145723-1227a70f-6009-4e6b-b219-8d852db80868.png)

<br>

# 색 공간(Color Space) 종류
---

> **Note**
> - 색 공간은 어디까지나 상대적인 개념이다.

<br>

## **sRGB**
 - 원본보다 밝아진 상태의 색 공간
 - 감마 보정(`Pow(color, 1/2.2)`)을 통해 밝게 저장된 이미지의 색 공간을 의미한다.

## **Linear**
 - 원본 색상을 저장하는 상태의 색 공간

## **Gamma**
 - 감마 보정에 의해 어두워진 상태의 색 공간
 - 모니터 출력 결과
 
 ![image](https://user-images.githubusercontent.com/42164422/135146948-1e03f0b5-37db-4a3e-8cd7-5f1ea58882ef.png)

<br>


# 유니티의 색 공간 파이프라인
---

## **설정 방법**

- `[Edit]` - `Project Settings` - `Player` - `Other Settings` - `Rendering`

![image](https://user-images.githubusercontent.com/42164422/135147438-447223c0-128d-4657-bfa7-7ab298351289.png)

<br>

## **Gamma Pipeline**

- 다른 짓 안하고 그냥 쉐이더 연산 결과를 바로 모니터로 보낸다.

![image](https://user-images.githubusercontent.com/42164422/134969719-2d0cde4e-61df-4dbb-9f3b-2fa1b38cce31.png)

- 텍스쳐가 `sRGB`로 밝게 저장된 상태 그대로(원본과 값이 다른 상태에서) 연산을 해버린다.
- 근데 텍스쳐를 사용하지 않는 쉐이더 연산(라이팅 등)에서는 정확한 값(`Linear`)으로 연산을 수행한다.
- 따라서 텍스쳐는 `sRGB`, 라이팅 연산 결과는 `Linear`인 불일치 상태에서 서로가 연산되는 참사가 발생한다.
- 그리고 심지어 `Linear`에서 이루어진 쉐이더 연산 결과가 그대로 모니터에 출력되므로, 의도보다 더 어두워진다는 것이 치명적이다.

![image](https://user-images.githubusercontent.com/42164422/134968092-a9946934-d4c9-4c65-a655-3dd666b3697c.png)

<br>

## **Linear Pipeline**

- `sRGB`로 저장된 텍스쳐를 다시 어둡게(원본으로) 바꾸고, 그 상태에서 정확한 값을 사용해 연산한다.
- 그리고 그 연산 결과를 다시 sRGB로 저장하여, 모니터에서는 다시 어두워져서 원본이 출력되도록 한다.

![image](https://user-images.githubusercontent.com/42164422/134970010-3b67678f-47d1-4911-ac85-d18f1528fd16.png)

- `sRGB`로 저장되었던 텍스쳐, 그리고 순수한 쉐이더 연산 모두 동일한 `Linear` 공간에서 같이 계산되므로 정확히 계산된다.
- 또한 `Linear`에서 계산된 결과를 `sRGB`로 올려서, 결과적으로 모니터에서는 통해 `Linear`로 내려져서 출력되므로 의도한 색상이 출력된다.

![image](https://user-images.githubusercontent.com/42164422/134969087-d63930ae-76b2-4108-865d-3e05e29eb4b0.png)

- 결과적으로, **Linear Pipeline**이 더 정확한 그래픽 결과를 얻을 수 있다.
- 구형 기기(OpenGLES 2.0까지만 지원하는 기기)에서는 사용할 수 없다.


<br>

## **Gamma vs. Linear**

- 화면의 모든 색상이 Gamma는 밝고 대비가 높으며, Linear는 비교적 차분하다.

- Gamma는 비교적 화질이 떨어져 보이고, Diffuse 같은 연속된 음영에 대해 특히 뚝뚝 끊기는 느낌을 준다.

- Linear는 더 부드러운 음영을 표현하며, Gamma보다 더 현실에 가까운 그래픽 연산 결과를 보여준다.

- 구형 기기를 지원하지 않아도 된다면 대부분의 경우 그냥 Linear Pipeline을 선택하는 것이 좋다.

- 색 공간 파이프라인을 Linear로 한다고 해서 성능 상 손해보지는 않는다.


<br>

## 유니티 렌더 파이프라인별 기본 색 공간 파이프라인
- **Built-in** : `Gamma Space`
  - Linear 파이프라인을 지원하지 못하는 구형 기기들을 모두 호환하기 위해서 기본 색공간이 `Gamma`로 설정된다.

- **SRP(URP, HDRP)** : `Linear Space`

<br>


## 유니티 텍스쳐의 sRGB 토글

![image](https://user-images.githubusercontent.com/42164422/135147634-6d07a907-20a5-4cfd-ac5b-fe75de24dfee.png)

- `Gamma` 파이프라인은 어차피 싹다 그대로 연산하니까 달라지는 것이 없고, `Linear` 파이프라인일 경우 달라진다.

- 색상 텍스쳐는 `sRGB` 색공간 텍스쳐로 간주하고, 연산을 위해 `Linear`로 끌어내려서(`^2.2`) 연산한다.

- 그런데 정확한 값이 요구되는, 데이터 텍스쳐의 경우(노말 맵, 메탈릭 맵, 플로우 맵, 렌더 텍스쳐 등)
  끌어내리면 오히려 부정확해지므로 `Linear` 그대로 사용해야 한다.

- 따라서 데이터 텍스쳐는 인스펙터 설정에서 `sRGB` 체크 해제하면 `Linear`로 간주하고, 정확한 값으로 사용할 수 있다.

- 근데 `sRGB`는 `R`, `G`, `B` 채널에만 적용된다.
- `sRGB`에 체크를 해도 `A` 채널은 언제나 `Linear`로 인식된다.

<br>

# 결론 : Gamma vs. Linear 파이프라인
---

![image](https://user-images.githubusercontent.com/42164422/134972937-f51ec163-443c-4ae2-b38f-8284660059d6.png)

- 위와 같은 단순 라이팅 결과만 보자면 `Gamma` 파이프라인 쪽이 더 부드럽고 예뻐 보일 수 있다.

- 하지만 `Gamma` 파이프라인은 애초에 치명적인 색공간 불일치 문제가 있다. (색상 텍스쳐는 `sRGB`, 쉐이더 연산 공간은 `Linear`)

- 더 정확하고 현실적인 그래픽을 보여주는 것은 `Linear` 파이프라인이며 어두운 부분에서도 더 높은 화질을 제공한다.

<br>

# 추가 : 쉐이더 그래프 유의사항
---

URP의 쉐이더 그래프에서 RGB `0.5`의 색상 노드 두개를 더해주면 `1.0`으로 완전한 흰색이 되어야 하지만,

![image](https://user-images.githubusercontent.com/42164422/135150389-5678100c-8888-4eb1-b621-2e4a28fd49d8.png)

위와 같이 완전한 흰색이 되지 않는다.

색상 노드의 색 자체를 `sRGB`로 간주하고 `^2.2`로 변환된 상태에서 연산한다는 의미이다.

<br>

따라서 이런 경우 정확하게 연산하려면

![image](https://user-images.githubusercontent.com/42164422/135150876-5f468851-3877-4347-84d1-d6f18aa52ef2.png)

색상마다 `Colorspace Conversion`으로 `^0.45` 연산을 적용해준 뒤 사용해야 한다.



<br>

# References
---
- <https://www.youtube.com/watch?v=Xwlm5V-bnBc>
- <https://www.youtube.com/watch?v=oVyqLhVrjhY>
- <https://www.youtube.com/watch?v=lUvsEfqOkUo>

- <https://blog.naver.com/PostView.nhn?blogId=cdw0424&logNo=221827528747>
- <https://www.slideshare.net/agebreak/color-space-gamma-correction>
- <https://chulin28ho.tistory.com/241>
- <https://chulin28ho.tistory.com/456>
- <https://chulin28ho.tistory.com/472>
- <https://www.cambridgeincolour.com/tutorials/gamma-correction.htm>

- <https://smartits.tistory.com/130>
- <http://rapapa.net/?p=3406>
- <https://boysboy3.tistory.com/58>

- <https://docs.unity3d.com/kr/2019.3/Manual/LinearLighting.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearOrGammaWorkflow.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearTextures.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-GammaTextures.html>