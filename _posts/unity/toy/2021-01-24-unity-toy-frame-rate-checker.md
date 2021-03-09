---
title: Frame Rate Checker
author: Rito15
date: 2021-01-24 17:00:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 실제 FPS 값을 실시간, 최근 N개의 평균, 최소, 최댓값으로 확인할 수 있다.
- 게임 진행 동안 텍스트의 위치, 색상, 크기, GUI 표시 상태를 실시간으로 변경할 수 있다.


# Preview
---
![](https://user-images.githubusercontent.com/42164422/105624478-6d191400-5e65-11eb-89ba-5a894dcfdce3.gif)
![](https://user-images.githubusercontent.com/42164422/105624575-16f8a080-5e66-11eb-840e-385845be4d48.png)


# Download
---
- [FrameRateChecker.zip](https://github.com/rito15/Images/files/5862736/FrameRateChecker.zip)


# Source Code
---

<details>
<summary markdown="span"> 
.
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 날짜 : 2021-01-24 PM 4:11:02
// 작성자 : Rito

namespace Rito
{
    public class FrameRateChecker : MonoBehaviour
    {
        [Range(0, 2000)]
        public float _posX = 30f;
        [Range(0, 1000)]
        public float _posY = 30f;

        public Color _textColor = Color.yellow;
        [Range(16, 80)]
        public int _textSize = 40;
        [Range(5, 500)]
        public int _frameCheckLength = 100;
        public bool _showGUI = true;

        private float[] _arrFPS;
        private int _counter = 0;

        private float _curFPS; // 실시간 프레임률
        private float _avgFPS; // 최근 _frameCheckLength 개수만큼의 프레임률 평균
        private float _maxFPS; // 최근 _frameCheckLength 개수만큼의 프레임률 최댓값
        private float _minFPS; // 최근 _frameCheckLength 개수만큼의 프레임률 최솟값

        private void OnEnable()
        {
            Debug.Log("Frame Rate Checker Running");
            _arrFPS = new float[_frameCheckLength];
            _maxFPS = -9999f;
            _minFPS = 9999f;
            _curFPS = 0f;
            _counter = 0;
        }

        private void Update()
        {
            // Trace Array Length
            if (_arrFPS.Length != _frameCheckLength) _arrFPS = new float[_frameCheckLength];
            if (_counter >= _frameCheckLength) _counter = 0;

            // Set FPS
            _curFPS = 1 / Time.deltaTime;
            _arrFPS[_counter] = _curFPS;

            float sum = 0;
            _maxFPS = -9999;
            _minFPS = 9999;
            foreach (var fps in _arrFPS)
            {
                // Min Max
                if (fps > _maxFPS) _maxFPS = fps;
                if (fps < _minFPS) _minFPS = fps;

                // Average
                sum += fps;
            }
            _avgFPS = sum / _arrFPS.Length;

            // Add Counter
            _counter++;
        }

        private void OnGUI()
        {
            if (!_showGUI) return;

            GUIStyle labelStyle = GUI.skin.label;
            labelStyle.normal.textColor = _textColor;
            labelStyle.fontSize = _textSize;

            GUILayout.BeginArea(new Rect(_posX, _posY, 1000, 500));
            GUILayout.Label($"Current : {_curFPS, 9: 000.00}", labelStyle);
            GUILayout.Label($"Average : {_avgFPS, 8: 000.00}", labelStyle);
            GUILayout.Label($"Max : {_maxFPS, 15: 000.00}", labelStyle);
            GUILayout.Label($"Min : {_minFPS, 16: 000.00}", labelStyle);
            GUILayout.EndArea();
        }
    }
}
```

</details>
