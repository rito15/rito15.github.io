---
title: Magical Orb
author: Rito15
date: 2021-05-14 02:00:00 +09:00
categories: [Unity Shader, URP Shader Graph]
tags: [unity, csharp, urp, shadergraph]
math: true
mermaid: true
---

# Summary
---

- 꿀렁이며 움직이는 구체 쉐이더

- `Scene Color` 노드를 사용하므로, Render Pipeline Asset에서 Opaque Texture에 체크해야 한다.

- 마스터 노드의 `Surface`를 `Transparent`로 설정해야 한다.


# Preview
---

![2021_0514_MagicalOrb_01](https://user-images.githubusercontent.com/42164422/118161804-fb3bf900-b45a-11eb-85df-bd0e824eedef.gif)

![2021_0514_MagicalOrb_02](https://user-images.githubusercontent.com/42164422/118161810-fc6d2600-b45a-11eb-80db-63c444d387aa.gif)

![2021_0514_MagicalOrb_03](https://user-images.githubusercontent.com/42164422/118161814-fd05bc80-b45a-11eb-8f5a-ae3bf2682515.gif)

# Options
---

|프로퍼티|설명
|---|---|
|`Pattern Texture`|구체 표면의 패턴 텍스쳐(반복 연결되어야 함)|
|`Tiling X`|텍스쳐의 X 타일링|
|`Tiling Y`|텍스쳐의 Y 타일링|
|`Color`|패턴 색상|
|`Intensity`|패턴 색상 강도|
|`Scrolling Speed`|패턴 이동 속도|
|`Displacement Scale`|버텍스 애니메이션에 사용되는 노이즈 스케일|
|`Displacement Range`|버텍스 애니메이션 노멀 이동 범위|
|`DIsplacement Speed`|버텍스 애니메이션 진행 속도|
|`Distortion Scale`|왜곡에 사용되는 노이즈 스케일|
|`Distortion Intensity`|왜곡 강도|
|`DIstortion Speed`|왜곡 애니메이션 진행 속도|
|`Fresnel Color`|프레넬 색상|
|`Fresnel Intensity`|프레넬 색상 강도|
|`Fresnel Range`|프레넬 범위|

# Graph
---

![image](https://user-images.githubusercontent.com/42164422/118163728-4fe07380-b45d-11eb-98b9-ac932089096b.png)

![image](https://user-images.githubusercontent.com/42164422/118163853-6be41500-b45d-11eb-9f1b-5ecd8c05c58d.png)

![image](https://user-images.githubusercontent.com/42164422/118163890-756d7d00-b45d-11eb-9d65-860c98701511.png)

# Download
---
- [2021_0515_Magical Orb.zip](https://github.com/rito15/Images/files/6474116/2021_0515_Magical.Orb.zip)


# References
---
- <https://www.youtube.com/watch?v=DpXPhGeCqus>