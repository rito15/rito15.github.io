---
title: 텍스트 메쉬 프로(TMPro) 사용하기
author: Rito15
date: 2021-02-12 02:09:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, ugui, ui, text, textmeshpro]
math: true
mermaid: true
---

# 특징
---
- SDF(Signed Distance Field)를 이용하여 UGUI 텍스트보다 외곽선을 더 깔끔하게 표현한다.

- 마테리얼을 이용하여 다양한 효과를 줄 수 있다.

- UGUI 텍스트에 비해 성능이 좋다.

- 미리 고해상도의 Font Texture Atlas를 생성하여 사용하기 때문에 실시간으로 크기가 변경되어도 픽셀을 부드럽게 나타낼 수 있다.

<br>

# 폰트 애셋 생성하기
---

## 1. 필요 리소스 임포트

- [Window] - [TextMeshPro] - [Import Essential Resources] - [Import]

<br>

## 2. 폰트 준비

- 한글을 지원하는 폰트 파일(.ttf)을 유니티 프로젝트로 가져온다.

- C:\Windows\Fonts 경로에서 윈도우에서 기존에 사용하던 폰트들을 가져올 수도 있다.

<br>

## 3. 폰트 애셋 만들기

- [Window] - [TextMeshPro] - [Font Asset Creator]

![image](https://user-images.githubusercontent.com/42164422/107680196-e081a900-6ce0-11eb-9195-c3ab29007048.png){:.normal}

<br>
### Source Font File
  - 미리 준비한 폰트 파일을 넣는다.

<br>
### Sample Point Size
  - Auto Sizing을 선택하면 텍스쳐 아틀라스 내에 모든 텍스트가 포함될 수 있는 최대의 크기로 설정된다.
  - Custom Size를 선택하면 텍스쳐 아틀라스에 들어갈 텍스트들의 크기를 직접 지정할 수 있지만, 너무 크게 설정하면 아틀라스에 들어가지 못하는 텍스트가 생길 수 있고 너무 작게 설정하면 아틀라스가 낭비될 수 있다.
  - 결론적으로, Auto Sizing을 선택하고 하단의 다른 옵션들을 적절히 설정해주는 것이 좋다.

<br>
### Padding
  - 텍스쳐 내에서 각 텍스트가 차지할 영역의 크기를 결정한다.
  - 패딩 값이 크면 더 높은 품질의 렌더링을 보장하지만, 더 넓은 텍스쳐가 필요하며 아틀라스 생성 시간도 더 오래걸린다.
  - 일반적으로 5 정도가 적당하다.

<br>
### Packing Method
  - Fast : 빠르게 생성하지만, 중복된 문자가 포함될 수 있다.
  - Optimum : 중복 문자를 제거하여 더 좋은 효율을 보이지만, 느리다.
  - 그런데 사실상 별 차이가 없으므로 보통 Fast를 사용한다.

<br>
### Atlas Resolution
  - 생성할 폰트 텍스쳐 아틀라스의 크기를 결정한다.
  - Sampling 옵션을 Auto Size로 선택했을 때, Atlas Resolution에 따라 텍스트의 품질이 결정된다.
  - Generate 이후 결과창에 나타난 Point Size가 32~64 사이로 나오도록 하면 적당하다.
  - 웬만해서 2048 ~ 4096 정도를 선택한다.

<br>
### Character Set
  - Custom Range : 생성할 글자의 유니코드 범위를 10진수로 지정한다.
  - Unicode Range(Hex) : 유니코드 범위를 16진수로 지정한다.
  - Custom Characters : 생성할 글자들을 모두 직접 입력한다.
  - Characters from File : 생성할 글자들이 적혀 있는 텍스트 파일을 선택한다.

  - 결론적으로, Custom Range를 선택하고 Character sequence 부분에 하단의 내용을 입력하면 된다.

```
32-126,44032-55203,12593-12643,8200-9900
```

- 32-126 : 영문자
- 44032-55203 : 한글
- 12593-12643 : 한글자모
- 8200-9900 : 특수문자

<br>
### Select Font Asset
  - 이미 생성된 다른 폰트 애셋으로부터 텍스트 생성 범위를 가져올 수 있다.
  - 처음 생성할 경우 None으로 비워두면 된다.

<br>

### Render Mode

- **기본 방식(비트맵)**
  - Smooth_Hinted : 힌팅(뚜렷하게 보이도록 글자 스스로 모양 변경), 안티 앨리어싱 적용
  - Smooth : 안티 앨리어싱만 적용
  - Raster_Hinted : 기본 폰트 상태에서 힌팅만 적용
  - Raster : 아무 것도 적용되지 않은 기본 폰트 상태


- **SDF(Signed Distance Field)**
  - 거리에 따라 선명도를 계산하여 렌더링
  - SDF 뒤에 붙은 숫자에 비례하여 품질을 결정한다.
  - Smooth는 안티 앨리어싱, Hinted는 힌팅 적용<br>


잘 모르겠으면 SDF32를 선택하는 것이 무난하다.

아웃라인, 글로우, 다른 쉐이더 효과들을 사용할 것이라면 특히 SDF를 선택해야 한다.

<br>
### Get Kerning Pairs
  - 폰트가 특정 문자들 간의 여백 정보를 갖고 있는 경우, 이를 가져와 사용한다.
  - 대부분의 폰트는 이 정보를 갖고 있지 않으므로, 딱히 상관 없다

<br>
### Generate Font Atlas
  - 위 옵션들을 설정한 뒤, 누른다.
  - 그리고 기다린 후 Save 또는 Save as를 눌러 폰트 애셋을 저장한다.

<br>

### 생성 결과

![image](https://user-images.githubusercontent.com/42164422/107690794-f053ba00-6ced-11eb-9177-c85234fee5fa.png){:.normal}

8200번대의 특수문자들이 없다고 나오는 것은 상관없다.

그리고 위처럼 텍스쳐의 일부가 살짝 까맣게 비어있는 상태가 알맞으며,

만약 Custom Size를 통해 크기를 직접 지정했는데 텍스쳐의 모든 부분에 글자가 빼곡히 채워져 있다면 텍스쳐 내에 포함되지 않은 글자가 있을 수 있으므로(그러면 해당 글자는 네모로 나온다) Point Size를 살짝 줄여서 다시 생성하는 것이 좋다.

<br>

# Text 생성하기
---

## 3D Text
  - 하이라키 우클릭 - [3D Object] - [Text - TextMeshPro]
  - 또는 빈 게임오브젝트에서 AddComponent - [TextMeshPro - Text]

## UI Text
  - 하이라키 우클릭 - [UI] - [Text - TextMeshPro]
  - 또는 빈 게임오브젝트에서 AddComponent - [TextMeshPro - Text(UI)]

<br>

# 예시
---

![image](https://user-images.githubusercontent.com/42164422/107694745-14fe6080-6cf3-11eb-8eef-75ef2ffd8c64.png){:.normal}

- 4 Corners Gradient
- Outline
- Glow

<br>

# References
---
- <https://scahp.tistory.com/17>
- <http://digitalnativestudios.com/textmeshpro/docs/font/>
- <https://blogs.unity3d.com/kr/2018/10/16/making-the-most-of-textmesh-pro-in-unity-2018>