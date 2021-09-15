---
title: 유니티 - UI 이미지에 구멍뚫기
author: Rito15
date: 2021-09-15 15:00:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts, mask, ugui]
math: true
mermaid: true
---

# Mask
---

![image](https://user-images.githubusercontent.com/42164422/133379454-0f73b2c3-44b2-44f4-a5d3-a07bfc13ddcc.png)

이런 이미지에

![image](https://user-images.githubusercontent.com/42164422/133379504-95202c76-a8e2-468a-b1f1-d05c58204b80.png)

이런 마스크를 씌우려면

- `Mask Image` (Image, Mask 컴포넌트 존재)
  - `Image` (Image 컴포넌트 존재)

이렇게 마스크 이미지, 보여질 이미지를 부모-자식 관계로 구성하면 된다.

![image](https://user-images.githubusercontent.com/42164422/133379740-e4a796b4-b75c-4d2d-9d7f-9990b8312b38.png)

그러면 이렇게 마스크 이미지와 겹치는 영역만 보인다.

<br>

# Punch
---

반대로 마스크 이미지와 겹치는 영역만 안보이도록,

마치 구멍이 뚫린 것 같이 표현하려면

우선 마테리얼 하나를 만든다.

![image](https://user-images.githubusercontent.com/42164422/133379975-8b46e614-1c01-43b9-814a-039a215fb8dc.png)

그리고 프로퍼티 값들을 위와 같이 설정한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/133380120-0721d433-6496-4973-9b49-40ad0a25ab54.png)

마스크의 자식으로 있는 이미지의 `Image` 컴포넌트에서

`Material`에 해당 마테리얼을 넣어주고, `Maskable` 옵션을 체크 해제한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/133380156-b0cf9f0c-c784-42bb-987e-6032ed659cdc.png)

이제 위와 같이 마스크 모양으로 구멍이 뚫린 모습을 확인할 수 있다.

