---
title: 유니티 - 쿨타임 아이콘 UI 만들기
author: Rito15
date: 2021-02-12 17:13:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, ui, cooldown]
math: true
mermaid: true
---

# 목표
---

![2012_0212_CooldownIcon](https://user-images.githubusercontent.com/42164422/107744663-71df3280-6d56-11eb-93d3-85813ca51263.gif){:.normal}

<br>

# 구현
---

## 1. 하이라키 구성

![image](https://user-images.githubusercontent.com/42164422/107747987-b3bea780-6d5b-11eb-8c1c-830ea4139774.png){:.normal}

### **[1] Outline**
  - Image 컴포넌트 : 원하는 모양의 스프라이트 사용, 아웃라인으로 지정할 색상 적용

### **[2] Mask**
  - RectTransform : Anchor Preset [stretch & stretch] 설정
  - Left, Top, Right, Bottom 4픽셀 설정
  - Image 컴포넌트 : Outline과 같은 스프라이트 사용
  - Mask 컴포넌트 : [Show Mask Graphic] 체크 해제

### **[3] Icon**
  - RectTransform : Anchor Preset [stretch & stretch] 설정
  - Left, Top, Right, Bottom 0
  - Image 컴포넌트 : 원하는 스프라이트 사용

### **[4] Fill**
  - RectTransform : Anchor Preset [stretch & stretch] 설정
  - Left, Top, Right, Bottom 0
  - Image 컴포넌트
    - Outline과 같은 모양 또는 가득찬 사각형 스프라이트 사용
    - Color : RGBA(0, 0, 0, 0.5)
    - Image Type : Filled
    - Fill Method : Radial 360
    - Fill Origin : Top
    - Fill Amount : 1
    - Clockwise : False

<br>
## 2. 스크립트 작성

```cs
public class CooldownUI : MonoBehaviour
{
    public UnityEngine.UI.Image fill;
    private float maxCooldown = 5f;
    private float currentCooldown = 5f;

    public void SetMaxCooldown(in float value)
    {
        maxCooldown = value;
        UpdateFiilAmount();
    }

    public void SetCurrentCooldown(in float value)
    {
        currentCooldown = value;
        UpdateFiilAmount();
    }

    private void UpdateFiilAmount()
    {
        fill.fillAmount = currentCooldown / maxCooldown;
    }

    // Test
    private void Update()
    {
        SetCurrentCooldown(currentCooldown - Time.deltaTime);

        // Loop
        if (currentCooldown < 0f)
            currentCooldown = maxCooldown;
    }
}
```

- 인스펙터에서 fill 필드에 Fill 게임오브젝트를 드래그해서 넣어준다.

<br>

# 구현 예시
---

![2012_0212_CooldownIcons](https://user-images.githubusercontent.com/42164422/107747801-60e4f000-6d5b-11eb-8dc6-00216437f23c.gif){:.normal}

