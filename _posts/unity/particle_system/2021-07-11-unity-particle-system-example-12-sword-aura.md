---
title: 파티클 시스템 예제 - 12 - Sword Aura
author: Rito15
date: 2021-07-11 14:55:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. 작업 환경 구성](#1-작업-환경-구성)
- [2. 하이라키 구성](#2-하이라키-구성)
- [3. Aura 이펙트](#3-aura-이펙트)
- [4. Smoke 이펙트](#4-smoke-이펙트)
- [5. Spark 이펙트](#5-spark-이펙트)
- [6. Glow 이펙트](#6-glow-이펙트)

<br>

# Preview
---

![2021_0711_SwordFire_Preview](https://user-images.githubusercontent.com/42164422/125174119-0498d600-e1fe-11eb-8220-cc6e0163b633.gif)

![2021_0711_SwordFire_Preview_3Col](https://user-images.githubusercontent.com/42164422/125174120-06629980-e1fe-11eb-8f21-0b09cdaae903.gif)

![2021_0711_SwordFire_Swing](https://user-images.githubusercontent.com/42164422/125174124-082c5d00-e1fe-11eb-948c-6e28b5e5850c.gif)


<br>

# 목표
---

- 검 모델링에 부착하여 사용할 수 있는, 타오르는 듯한 이펙트 만들기

<br>

# 준비물
---

## 검 모델링
  - <https://assetstore.unity.com/packages/3d/props/weapons/free-low-poly-swords-189978>

## Additive 마테리얼들과 텍스쳐
  - `SwordAura`, `SwordSmoke`, `PointGlow`
  - [SwordAura_Resources.zip](https://github.com/rito15/Images/files/6796564/SwordAura_Resources.zip)

<br>

# 1. 작업 환경 구성
---

이펙트를 제작하기 위해 게임 뷰에는 스카이박스 대신 단색의 배경이 보이도록 설정하는 것이 좋다.

- 하이라키의 [Main Camera] 게임오브젝트를 선택한다.

- 인스펙터의 `Camera` 컴포넌트를 확인한다.

- `Clear Flags`를 `Solid Color`로 변경한다.

- `Background` 색상을 검정색으로 변경한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/125188046-8411be00-e26d-11eb-91ac-92e63e3337ca.png)

<br>

# 2. 하이라키 구성
---

## **[1] 검 모델링 배치**

- [준비물](#준비물)에 첨부한 링크의 애셋을 프로젝트에 임포트한다.

- [Free_Swords/Prefabs] 폴더의 [PP_Sword_0177] 프리팹을 하이라키에 드래그 앤 드롭하여 가져온다.

- 하이라키에서 [PP_Sword_0177] 게임오브젝트를 우클릭하고 [Unpack Prefab]을 클릭한다.

- [PP_Sword_0177] 게임오브젝트의 위치를 (X : `0`, Y : `0.625`, Z : `-8.5`)로 설정하면 게임 뷰에서 적당한 위치에 오도록 할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/125188585-3b5b0480-e26f-11eb-95b3-f50a1159fe2e.png)

<br>

## **[2] 빈 파티클 시스템 생성**

- [PP_Sword_0177] 게임 오브젝트에 우클릭하고 [Effects] - [Particle System]을 클릭한다.

- 추가된 파티클 시스템 게임오브젝트를 선택하고 `F2`를 누른 뒤 이름을 [Sword Aura]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/125188753-d9e76580-e26f-11eb-8934-2b2588e6dd52.png)

- 인스펙터의 `Particle System` 컴포넌트에서 `Emission`, `Shape`, `Renderer` 모듈을 체크 해제하여 아무런 파티클도 생성되지 않도록 한다.

![image](https://user-images.githubusercontent.com/42164422/125194897-35285080-e28e-11eb-9efd-4b01792a72b8.png)

<br>

# 3. Aura 이펙트
---

## **[1] 파티클 시스템 생성**

- [Sword Aura] 게임오브젝트에 우클릭하고 [Effects] - [Particle System]을 클릭한다.

- 추가된 파티클 시스템 게임오브젝트를 선택하고 `F2`를 누른 뒤 이름을 [Aura]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/125188770-fb485180-e26f-11eb-950b-abf100f6b4d3.png)

<br>

## **[2] 마테리얼 적용**

- [준비물](#준비물)의 `SwordAura_Resources` 내에 있는 `Additive_TextureSheet_SwordAura` 마테리얼을 드래그하여 [Aura] 게임오브젝트에 적용한다.

<br>

## **[3] 텍스쳐 시트 애니메이션 설정**

- `Texture Sheet Animation` 모듈에 체크한다.

- `Tiles`를 (X : `8`, Y : `8`)로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125188865-6560f680-e270-11eb-8262-da4c2bca0716.png)

<br>

## **[4] 파티클 생성 영역 설정**

- `Shape` 모듈을 체크 해제하여 모든 파티클이 단 하나의 지점에서 생성되도록 한다.

<br>

## **[5] 메인 모듈 설정**

- 메인 모듈의 `Start Speed`를 `0`으로 설정한다.

- `Prewarm`에 체크한다.

- `Start Size`를 [Random Between Two Constants]로 설정하고, 값은 [`0.1`, `0.4`]로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/125189858-3305c800-e275-11eb-8115-27196fff6151.png)

<br>

## **[6] 파티클의 영역을 검날 전체로 넓히기**

- `Velocity over Lifetime` 모듈에 체크한다.

- `Linear`의 `Y` 값을 `0.21`로 지정한다.

- 이제 검날의 하단부에서 파티클이 생성되어 검날 상단부까지 이동하는 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/125189935-9bed4000-e275-11eb-9f16-f04df1cc1ef5.png)

<br>

## **[7] 투명도 설정**

- `Color over Lifetime` 모듈에 체크한다.

- `Color`를 다음과 같이 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125190377-c809c080-e277-11eb-9ff3-841c813f11b9.png)

- 색상은 그대로 유지하고, 알파값이 `0` ~ `48` ~ `0`으로 변하도록 설정한다.

<br>

- 알파값을 구간별로 설정하여 검날의 위치마다 오러의 두께를 다양하게 설정할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/125191630-6436c600-e27e-11eb-9bcf-b64a6281d04e.png)

![image](https://user-images.githubusercontent.com/42164422/125191647-757fd280-e27e-11eb-90ec-27d6e7756b89.png)

![image](https://user-images.githubusercontent.com/42164422/125191658-816b9480-e27e-11eb-944a-d75959954bbe.png)

<br>

## **[8] 파티클 생성 개수 설정**

- `Emission` 모듈의 `Rate over Time`을 `48`로 지정한다.

<br>

## **[9] 색상 설정**

- 메인 모듈의 `Start Color`를 원하는 대로 설정한다.

<br>

## **[10] 결과**

![2021_0711_SwordFire_Aura_Result](https://user-images.githubusercontent.com/42164422/125193122-d65ed900-e285-11eb-8e69-3f91b3e2e5d7.gif)

<br>

## **옵션 커스터마이징하기**

### **[1] 오러의 길이에 영향을 주는 설정**
- 메인 모듈의 `Start Lifetime`

- `Velocity over Lifetime` 모듈의 `Linear Y`

<br>

### **[2] 오러의 두께**
- 메인 모듈의 `Start Size`

<br>

### **[3] 오러의 강도(투명도)**
- `Emission` 모듈의 `Rate over Time`

- `Color over Lifetime` 모듈의 알파값

- 메인 모듈의 `Start Color` 알파값


<br>

# 4. Smoke 이펙트
---

## **[1] 파티클 시스템 생성**

- [Sword Aura] 게임오브젝트에 우클릭하고 [Effects] - [Particle System]을 클릭한다.

- 추가된 파티클 시스템 게임오브젝트를 선택하고 `F2`를 누른 뒤 이름을 [Smoke]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/125191782-1ff7f580-e27f-11eb-884e-f1f808021443.png)

<br>

## **[2] 마테리얼 적용**

- [준비물](#준비물)의 `SwordAura_Resources` 내에 있는 `Additive_TextureSheet_SwordSmoke` 마테리얼을 드래그하여 [Smoke] 게임오브젝트에 적용한다.

<br>

## **[3] 텍스쳐 시트 애니메이션 설정**

- `Texture Sheet Animation` 모듈에 체크한다.

- `Tiles`를 (X : `8`, Y : `8`)로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125188865-6560f680-e270-11eb-8262-da4c2bca0716.png)

<br>

## **[4] 메인 모듈 기본 설정**

- 메인 모듈의 `Start Speed`를 `0`으로 설정한다.

- `Prewarm`에 체크한다.

- `Start Lifetime`을 [Random Between Two Constants]로 설정하고, 값은 [`1`, `3`]으로 지정한다.

- `Start Size`를 [Random Between Two Constants]로 설정하고, 값은 [`2`, `3`]으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/125194092-b978d480-e28a-11eb-84b3-808297c36fa6.png)

<br>

## **[5] 파티클 생성 영역 설정**

- `Shape` 모듈의 `Shape`를 `Box`로 설정한다.

- `Position`의 `Y`를 `0.5`로 설정한다.

- `Scale`을 (X : `0.1`, Y : `1`, Z : `0.1`)로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125195073-0199f600-e28f-11eb-8064-daf320457b02.png)

<br>

## **[6] 투명도 설정**

- `Color over Lifetime` 모듈에 체크한다.

- 색상을 클릭하고, 알파값이 `48`에서 `0`으로 감소하도록 설정한다.

![2021_0711_SwordFire_SmokeAlphaSetting](https://user-images.githubusercontent.com/42164422/125192242-c2b17380-e281-11eb-93fa-ed2db15b4714.gif)

<br>

## **[7] 텍스쳐 시트 애니메이션 재생 속도 설정**

- `Texture Sheet Animation` 모듈의 `Time Mode`를 `FPS`로 변경한다.

- `FPS`를 `15`로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125195098-21311e80-e28f-11eb-82f0-93b644034a1b.png)

<br>

## **[8] 파티클 생성 개수 설정**

- `Emission`의 `Rate over Time`을 `16`으로 지정한다.

<br>

## **[9] 자연스럽게 사라지는 효과**

- 연기가 자연스럽게 공기 중에 스며들며 사라지는 듯한 효과를 줄 수 있다.

- `Size over Lifetime` 모듈에 체크하고, `Size`를 다음과 같이 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125192943-212c2100-e285-11eb-93ce-7be2349658df.png)

<br>

## **[10] 움직임 설정**

- 연기가 좌우로, 그리고 상단으로 자연스럽게 이동하는 효과를 만든다.

- 메인 모듈의 `Gravity Modifier` 를 [Random Between Two Constants]로 설정하고, 값은 (`0`, `-0.05`)로 지정한다.

- `Force over Lifetime` 모듈에 체크하고, 우측의 화살표를 클릭하여 [Random Between Two Constants]로 설정한 뒤, `X` 값을 (`-0.3`, `0.3`)으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/125192411-b24dc880-e282-11eb-9d03-3b1a3ac9aa97.png)

<br>

## **[11] 잔상 남기기 효과**

- 검이 움직였을 때 연기 이펙트가 추가적으로 생성되어, 검이 움직였던 자리에 자연스럽게 남는 듯한 효과를 만든다.

- 메인 모듈의 `Simulation Space`를 `World`로 설정한다.

- `Emission` 모듈의 `Rate over Distance`를 `16`으로 지정한다.

<br>

## **[12] 색상 설정**

- 메인 모듈의 `Start Color`에 원하는 색상을 지정한다.

- 연기를 더 은은하게 보이도록 하려면 `Start Color` 또는 `Color over Lifetime`의 알파값을 줄이면 된다.

<br>

## **[13] 결과**

![2021_0711_SwordFire_Smoke_Result](https://user-images.githubusercontent.com/42164422/125193125-d7900600-e285-11eb-8483-d2d7795a027d.gif)

<br>

# 5. Spark 이펙트
---

## **[1] 파티클 시스템 생성**

- [Sword Aura] 게임오브젝트에 우클릭하고 [Effects] - [Particle System]을 클릭한다.

- 추가된 파티클 시스템 게임오브젝트를 선택하고 `F2`를 누른 뒤 이름을 [Spark]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/125193161-07d7a480-e286-11eb-812f-be110ae8278f.png)

<br>

## **[2] 마테리얼 적용**

- [준비물](#준비물)의 `SwordAura_Resources` 내에 있는 `Additive_PointGlow` 마테리얼을 드래그하여 [Spark] 게임오브젝트에 적용한다.

<br>

## **[3] 메인 모듈 기본 설정**

- 메인 모듈의 `Start Speed`를 `0`으로 설정한다.

- `Prewarm`에 체크한다.

- `Start Lifetime`을 [Random Between Two Constants]로 설정하고, 값은 [`0.5`, `1`]으로 지정한다.

- `Start Size`를 [Random Between Two Constants]로 설정하고, 값은 [`0.01`, `0.06`]으로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/125194106-c8f81d80-e28a-11eb-8f7f-303d0315e87c.png)

<br>

## **[4] 파티클 생성 영역 설정**

- `Shape` 모듈의 `Shape`를 `Box`로 설정한다.

- `Position`의 `Y`를 `0.5`로 설정한다.

- `Scale`을 (X : `0.2`, Y : `1`, Z : `0.2`)로 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125195522-f47e0680-e290-11eb-9585-5a1b0115bae0.png)

<br>

## **[5] 투명도 설정**

- `Color over Lifetime` 모듈에 체크한다.

- 색상을 클릭하고, 알파값이 `0` ~ `255` ~ `0`으로 변화하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125193365-fe9b0780-e286-11eb-8d4b-122731dde4be.png)

<br>

## **[6] 파티클 생성 개수 설정**

- `Emission`의 `Rate over Time`을 `512`으로 지정한다.

<br>

## **[7] 파티클 크기 변화**

- `Size over Lifetime` 모듈에 체크하고, `Size`를 다음과 같이 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125193525-bc25fa80-e287-11eb-8781-dd324adf4658.png)

<br>

## **[8] 파티클 움직임 설정**

- 메인 모듈의 `Gravity Modifier` 를 [Random Between Two Constants]로 설정하고, 값은 (`0`, `-0.1`)로 지정한다.

- `Force over Lifetime` 모듈에 체크하고, 우측의 화살표를 클릭하여 [Random Between Two Constants]로 설정한다.

- `X`는 (`-1` ~ `1`), `Y`는 (`0` ~ `0.5`)로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/125193568-fb544b80-e287-11eb-9baa-e4624d72ec05.png)

<br>

## **[11] 잔상 남기기 효과**

- [Smoke] 이펙트와 마찬가지로, 검이 움직였을 때 움직인 자리에 이펙트가 남아 있게 하는 효과를 만든다.

- 메인 모듈의 `Simulation Space`를 `World`로 설정한다.

- 메인 모듈의 `Max Particles`를 `2000`으로 지정한다.

- `Emission` 모듈의 `Rate over Distance`를 `512`로 지정한다.

<br>

## **[12] 색상 설정**

- 메인 모듈의 `Start Color`에 원하는 색상을 지정한다.

<br>

## **[13] 결과**

![2021_0711_SwordFire_Spark_Result](https://user-images.githubusercontent.com/42164422/125193974-32c3f780-e28a-11eb-8e4e-ae1a9e7dbe62.gif)

<br>

# 6. Glow 이펙트
---

## **[1] 파티클 시스템 생성**

- [Sword Aura] 게임오브젝트에 우클릭하고 [Effects] - [Particle System]을 클릭한다.

- 추가된 파티클 시스템 게임오브젝트를 선택하고 `F2`를 누른 뒤 이름을 [Glow]로 변경한다.

![image](https://user-images.githubusercontent.com/42164422/125194013-5e46e200-e28a-11eb-8d55-60e0b6acdbb4.png)

<br>

## **[2] 마테리얼 적용**

- [준비물](#준비물)의 `SwordAura_Resources` 내에 있는 `Additive_PointGlow` 마테리얼을 드래그하여 [Glow] 게임오브젝트에 적용한다.

<br>

## **[3] 메인 모듈 기본 설정**

- 메인 모듈의 `Start Speed`를 `0`으로 설정한다.

- `Prewarm`에 체크한다.

- `Start Lifetime`을 `3`으로 설정한다.

- `Start Size`를 `0.3`으로 설정한다.

<br>

## **[4] 파티클 생성 영역 설정**

- `Shape` 모듈의 `Shape`를 `Mesh`로 설정한다.

- `Type`을 `Edge`로 설정한다.

- `Mode`를 `Loop`로 설정한다.

- `Mesh`를 검 모델링과 동일한 메시로 설정한다. (예제에서는 `PP_Sword_0177`)

![image](https://user-images.githubusercontent.com/42164422/125194472-6ef85780-e28c-11eb-81e6-83af9db4b78c.png)

<br>

## **[5] 파티클 생성 개수 설정**

- `Emission`의 `Rate over Time`을 `128`로 지정한다.

<br>

## **[6] 투명도 설정**

- `Color over Lifetime` 모듈에 체크한다.

- 색상을 클릭하고, 알파값이 `0` ~ `8` ~ `0`으로 변화하도록 설정한다.

![image](https://user-images.githubusercontent.com/42164422/125194729-7d933e80-e28d-11eb-9f10-a199e7ab06c3.png)

<br>

## **[7] 색상 설정**

- 메인 모듈의 `Start Color`에 원하는 색상을 지정한다.

<br>

## **[8] 결과**

![2021_0711_SwordFire_Glow_Result](https://user-images.githubusercontent.com/42164422/125194767-9b60a380-e28d-11eb-825e-2661ce451c8a.gif)




