---
title: 유니티 투명 쉐이더와 스텐실
author: Rito15
date: 2021-02-06 01:29:00 +09:00
categories: [Unity Shader, Shader Study]
tags: [unity, csharp, shader, graphics, transparent, stencil]
math: true
mermaid: true
---

# 불투명과 투명
---

불투명(Opaque)과 투명(Transparent) 오브젝트는 그려지는 타이밍도, 그리기 위한 고려사항도 다르다.

유니티로 설명하자면 오브젝트를 렌더링하는 순서를 렌더 큐(Render Queue)를 통해 지정하는데 
지정한 숫자가 작은 순서대로 그리게 되며, 기본적으로 Opaque는 2000, Transparent는 3000의 값을 가진다.
따라서 Opaque를 전부 그린 후에 Transparent를 그린다.

<br>

## Z-buffer

카메라로부터 픽셀마다 가장 가까운 오브젝트까지의 거리를 (0.0 ~ 1.0) 값으로 기록해놓는 버퍼.

깊이 버퍼(Depth Buffer)라고도 한다.

![image](https://user-images.githubusercontent.com/42164422/107067589-d49a7080-6822-11eb-95d0-f8b4a103bece.png){:.normal}

<br>

## 불투명(Opaque)

![image](https://user-images.githubusercontent.com/42164422/107073497-cfd9ba80-682a-11eb-922e-9766ea42556f.png){:.normal}

불투명 오브젝트를 그리기 위해서 우선 Z버퍼를 참조한다.
각각의 픽셀마다 얻어낸 Z버퍼의 값을 통해 가장 가까운 오브젝트의 픽셀만 화면에 그리게 되는데, 이를 Z Test(Read)라고 한다.

따라서 불투명을 그릴 때는 해당 픽셀에서 가장 앞에 있는 오브젝트의 픽셀만 그리고 뒤에 있는 픽셀은 그리지 않음으로써 자원을 절약하게 된다.

### + 만약 동일한 Z 값을 가진다면?

![image](https://user-images.githubusercontent.com/42164422/107071993-e2eb8b00-6828-11eb-8f76-6ea2fdef82e0.png){:.normal}

- 어떤 것을 먼저 그릴지 알 수 없으므로 위처럼 보이게 되며, 이를 Z fighting이라고 한다.

<br>

## 투명(Transparent)

![image](https://user-images.githubusercontent.com/42164422/107073835-34951500-682b-11eb-843c-c78fb555b9c6.png){:.normal}

투명 오브젝트는 모든 불투명 오브젝트가 그려진 뒤에 그려진다.

앞에서 불투명 오브젝트가 가리지 않는 이상 투명 오브젝트는 겹쳐 있는 부분을 전부 그려야 하기 때문에, 불투명 오브젝트의 계산을 모두 끝내고 투명 오브젝트를 계산하게 되는 것이다.

따라서 같은 픽셀에 존재하는 모든 투명 오브젝트의 픽셀들은 전부 화면에 그려지며, 이를 **오버드로우(Overdraw)**라고 한다.

<br>

# 알파 소팅(Alpha Sorting)
---

투명 오브젝트는 불투명 오브젝트와 달리 멀리 있는 것부터 그리는데, 이를 알파 소팅이라고 한다.

https://m.blog.naver.com/plasticbag0/221299492724

<br>

# 알파 블렌딩(Alpha Blending)
---

겹쳐 있는 투명 오브젝트의 픽셀들을 서로 어떻게 섞어 그려낼지 계산하게 되는데, 이를 알파 블렌딩이라고 한다.

<br>

# 스텐실
---
- 

<br>

# References
---
- 정종필, 테크니컬 아티스트를 위한 유니티 쉐이더 스타트업, 비엘북스, 2017
- <https://m.blog.naver.com/plasticbag0/221299492724>