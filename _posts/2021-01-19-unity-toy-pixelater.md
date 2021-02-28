---
title: Pixelater
author: Rito15
date: 2021-01-19 22:56:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 렌더 텍스쳐의 해상도를 강제로 변경하여 화면을 픽셀화시킨다.
- 스크립트를 카메라에 부착하여 사용한다.


# Preview
---
![](https://user-images.githubusercontent.com/42164422/105009217-90b31780-5a7d-11eb-8feb-bf1062c91286.gif)


# Download
---
- [Pixelater.zip](https://github.com/rito15/Images/files/5862729/Pixelater.zip)


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

// 날짜 : 2021-01-19 PM 5:01:57
// 작성자 : Rito

namespace Rito
{
    [ExecuteInEditMode]
    public class Pixelater : MonoBehaviour
    {
        [Range(1, 100)]
        public int _pixelate = 1;

        public bool _showGUI = true;

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            source.filterMode = FilterMode.Point;
            RenderTexture resultTexture = RenderTexture.GetTemporary(source.width / _pixelate, source.height / _pixelate, 0, source.format);
            resultTexture.filterMode = FilterMode.Point;

            Graphics.Blit(source, resultTexture);
            Graphics.Blit(resultTexture, destination);
            RenderTexture.ReleaseTemporary(resultTexture);
        }

        private void OnGUI()
        {
            if (!_showGUI) return;
            string text = $"Pixelate : {_pixelate,3}";

            Rect textRect = new Rect(60f, 60f, 440f, 100f);
            Rect boxRect = new Rect(40f, 40f, 460f, 120f);

            GUIStyle boxStyle = GUI.skin.box;
            GUI.Box(boxRect, "", boxStyle);

            GUIStyle textStyle = GUI.skin.label;
            textStyle.fontSize = 70;
            GUI.TextField(textRect, text, 50, textStyle);
        }
    }
}
```

</details>


# References
---
- <https://www.youtube.com/watch?v=5rMkh9sl2bM>