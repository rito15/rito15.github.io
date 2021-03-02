---
title: 파티클 시스템 예제 - 02 - Mouse Chaser
author: Rito15
date: 2021-03-01 21:07:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---
- [목표](#목표)
- [준비물](#준비물)
- [1. 기본 준비](#1-기본-준비)
- [2. Heart](#2-heart)
- [3. Twinkle](#3-twinkle)

<br>

# Preview
---

## 기본

![2021_0301_MouseChaser02](https://user-images.githubusercontent.com/42164422/109498158-720d5b00-7ad6-11eb-9245-88bb937ceaa3.gif)

## Heart

![2021_0301_MouseChaser03_Heart](https://user-images.githubusercontent.com/42164422/109501018-5c9a3000-7ada-11eb-81b4-3d9c61ed92f7.gif)

## Twinkle

![2021_0301_MouseChaser04_Twinkle](https://user-images.githubusercontent.com/42164422/109502349-34133580-7adc-11eb-9a8f-ce9c347c8484.gif)

<br>

# 목표
---

- 실시간으로 마우스를 따라다니는 예쁜 이펙트 만들기

<br>

# 준비물
---

- 원하는 모양의 파티클 텍스쳐 (예제에서는 Heart, Twinkle), Additive 마테리얼

- 파티클이 마우스를 따라오게 만드는 스크립트

- 아래 소스코드를 다운로드하여 프로젝트 내에 넣어둔다.

- [MouseChaser.zip](https://github.com/rito15/Images/files/6061506/MouseChaser.zip)

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseChaser : MonoBehaviour
{
    // 카메라로부터의 거리
    public float _distanceFromCamera = 5f;

    [Range(0.01f, 1.0f)]
    public float _ChasingSpeed = 0.1f;

    private Vector3 _mousePos;
    private Vector3 _nextPos;

    private void OnValidate()
    {
        if(_distanceFromCamera < 0f)
            _distanceFromCamera = 0f;
    }

    void Update()
    {
        _mousePos = Input.mousePosition;
        _mousePos.z = _distanceFromCamera;

        _nextPos = Camera.main.ScreenToWorldPoint(_mousePos);
        transform.position = Vector3.Lerp(transform.position, _nextPos, _ChasingSpeed);
    }
}

```

</details>

<br>

# 1. 기본 준비
---

## 파티클이 마우스 커서를 쫓아오게 하기

- 파티클 게임오브젝트를 만들고, 트랜스폼 우측 상단의 `...`을 누르고 [Reset]을 눌러준다.

![image](https://user-images.githubusercontent.com/42164422/109497158-f9f26580-7ad4-11eb-88ab-d4dd0f6ad181.png)

<br>

- 준비한 `MouseChaser` 스크립트를 컴포넌트로 넣어준다.

![image](https://user-images.githubusercontent.com/42164422/109502831-d6cbb400-7adc-11eb-976e-ad03d6e3e0ce.png)

<br>

- 메인 모듈의 `Start Speed`를 0으로 설정한다.

- Shape 모듈을 체크 해제한다.

![image](https://user-images.githubusercontent.com/42164422/109496634-438e8080-7ad4-11eb-8102-3afeb484c6b6.png)

<br>

- 결과

![2021_0301_MouseChaser01](https://user-images.githubusercontent.com/42164422/109496899-a122cd00-7ad4-11eb-9c80-ee45aed8138a.gif)

게임을 시작하면 위처럼 마우스 커서를 따라오는 모습을 확인할 수 있다.

<br>

## 잔상 효과 추가하기

- 메인 모듈의 `Start Lifetime`을 1로 설정한다.

- 메인 모듈의 `Simulation Space`를 World로 설정한다.

- Emission 모듈의 `Rate over Lifetime`, `Rate over Distance`를 모두 10으로 설정한다.

- Color over Lifetime 모듈을 체크하고, `Color`를 다음과 같이 설정한다.

![](https://user-images.githubusercontent.com/42164422/108849307-5c56ec00-7625-11eb-8637-f363e4a01709.gif)

- Size over Lifetime 모듈을 체크하고, `Size`를 다음과 같이 설정한다.

![2021_0301_SizeOverLifetime](https://user-images.githubusercontent.com/42164422/109497648-b64c2b80-7ad5-11eb-9415-69cc36578a87.gif)

<br>

- 결과

![2021_0301_MouseChaser02](https://user-images.githubusercontent.com/42164422/109498158-720d5b00-7ad6-11eb-9245-88bb937ceaa3.gif)

<br>

# 2. Heart
---

- 위의 기본 준비를 모두 완료한다.

- 하트 모양 텍스쳐를 사용하는 Additive 마테리얼을 준비한다.

![image](https://user-images.githubusercontent.com/42164422/109501356-d29e9700-7ada-11eb-8638-dfb90e16d330.png)

<br>

## 메인 모듈
- `Start Speed` : 1

- `Start Color`에 원하는 색상을 지정한다.

- 예제에서는 Random Between Two Colors : (빨강, 분홍)

![image](https://user-images.githubusercontent.com/42164422/109621610-8ad14b80-7b7e-11eb-8fc4-ff4cd39a2bf4.png)

<br>

## Emission 모듈
- `Rate over Time` : 5
- `Rate over Distance` : 2

<br>

## Shape 모듈
- `Shape` : Sphere
- `Radius` : 0.0001

<br>

- 결과

![2021_0301_MouseChaser03_Heart](https://user-images.githubusercontent.com/42164422/109501018-5c9a3000-7ada-11eb-81b4-3d9c61ed92f7.gif)

<br>

# 3. Twinkle
---

- 위의 기본 준비를 모두 완료한다.

- 다음과 같은 텍스쳐와 마테리얼을 준비한다.

![image](https://user-images.githubusercontent.com/42164422/109501451-ef3acf00-7ada-11eb-9ba8-b5bf5e334053.png)

<br>

## 메인 모듈

- `Start Speed` : 1
- `Start Size` - [Random Between Two Constants] : (1, 2)
- `Start Color` : 원하는 색상들을 지정한다.

- 예제에서는 [Random Color] 사용

![image](https://user-images.githubusercontent.com/42164422/109502325-2e1d5480-7adc-11eb-863d-a80593336f6e.png)

<br>

## Emission 모듈

- `Rate over Time` : 12
- `Rate over Distance` : 12

<br>

## Shape 모듈
- `Shape` : Sphere
- `Radius` : 0.0001

<br>

- 결과

![2021_0301_MouseChaser04_Twinkle](https://user-images.githubusercontent.com/42164422/109502349-34133580-7adc-11eb-9a8f-ce9c347c8484.gif)