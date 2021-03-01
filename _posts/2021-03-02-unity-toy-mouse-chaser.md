---
title: Mouse Chaser
author: Rito15
date: 2021-03-02 03:14:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 게임오브젝트가 마우스 커서를 따라오게 하는 스크립트


# How To Use
---
- 마우스 커서를 따라오게 할 게임오브젝트에 컴포넌트로 넣는다.

- `Distance From Camera`를 통해 카메라로부터의 거리를 지정할 수 있다.

- `Chasing Speed`를 통해 마우스를 따라올 속도를 지정할 수 있다.


# Preview
---

![image](https://user-images.githubusercontent.com/42164422/109540699-2f637700-7b06-11eb-9854-9397b24d8cd5.png)

![](https://user-images.githubusercontent.com/42164422/109502349-34133580-7adc-11eb-9a8f-ce9c347c8484.gif)


# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<details>
<summary markdown="span"> 
.
</summary>

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 2021. 03. 02. 03:02
// 작성자 : Rito
// 게임오브젝트가 카메라로부터 일정거리를 유지한 채 마우스 커서를 따라가게 한다.

namespace Rito
{
    public class MouseChaser : MonoBehaviour
    {
        // 카메라로부터의 거리
        public float _distanceFromCamera = 10f;

        [Range(0.01f, 1.0f)]
        public float _ChasingSpeed = 0.1f;

        private Vector3 _mousePos;
        private Vector3 _nextPos;

        private void OnValidate()
        {
            if (_distanceFromCamera < 0f)
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
}
```

</details>

