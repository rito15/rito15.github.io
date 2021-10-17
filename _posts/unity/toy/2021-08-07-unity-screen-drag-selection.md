---
title: Screen Drag Selection(화면에 마우스 드래그 영역 표시하기)
author: Rito15
date: 2021-08-07 01:11:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Preview
---

![2021_0807_ScreenDragSelection](https://user-images.githubusercontent.com/42164422/128541062-96cc08bb-a6d8-4170-a968-0a6c5c1e9ef4.gif)

# Source Code
---

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-08-07 AM 1:12:20
// 작성자 : Rito

/// <summary> 화면에 마우스 드래그로 사각형 선택 영역 표시하기 </summary>
public class ScreenDragSelection : MonoBehaviour
{
    private Vector2 mPosCur;   // 실시간(현재 프레임) 마우스 좌표
    private Vector2 mPosBegin; // 드래그 시작 지점 마우스 좌표
    private Vector2 mPosMin;   // Rect의 최소 지점 좌표
    private Vector2 mPosMax;   // Rect의 최대 지점 좌표
    private bool showSelection;

    private void Update()
    {
        showSelection = Input.GetMouseButton(0);
        if (!showSelection) return;

        mPosCur = Input.mousePosition;
        mPosCur.y = Screen.height - mPosCur.y; // Y 좌표(상하) 반전

        if (Input.GetMouseButtonDown(0))
        {
            mPosBegin = mPosCur;
        }

        mPosMin = Vector2.Min(mPosCur, mPosBegin);
        mPosMax = Vector2.Max(mPosCur, mPosBegin);
    }

    private void OnGUI()
    {
        if (!showSelection) return;
        Rect rect = new Rect();
        rect.min = mPosMin;
        rect.max = mPosMax;

        GUI.Box(rect, "");
    }
}
```



<br>

# References
---
- 뇌