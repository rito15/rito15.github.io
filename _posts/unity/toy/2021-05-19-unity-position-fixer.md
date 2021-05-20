---
title: Position Fixer
author: Rito15
date: 2021-05-19 20:00:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Summary
---
- 부모 게임오브젝트의 이동에 영향받지 않고 트랜스폼 위치를 고정시키는 컴포넌트


# How To Use
---
- 위치를 고정/해제할 게임오브젝트에 컴포넌트로 넣는다.
- 인스펙터에서 `Activated`를 체크하거나 스페이스바를 눌러 기능을 활성화한다.


# Download
---
- [PositionFixer.zip](https://github.com/rito15/Images/files/6508336/PositionFixer.zip)


# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<details>
<summary markdown="span"> 
.
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 날짜 : 2021-05-19 PM 7:53:20
// 작성자 : Rito

public class PositionFixer : MonoBehaviour
{
    /// <summary> 위치 고정할지 여부 </summary>
    public bool _activated;

    /// <summary> 위치 고정/해제 기능 키 </summary>
    public KeyCode _functionKey = KeyCode.Space;

    private bool _prevActivated = false;
    private Vector3 _fixedPosition;

    private void OnValidate()
    {
        if (!_prevActivated && _activated)
            _fixedPosition = transform.position;

        _prevActivated = _activated;
    }

    private void Update()
    {
        if (Input.GetKeyDown(_functionKey))
            Fix(!_activated);

        if (_activated)
            transform.position = _fixedPosition;
    }

    /// <summary> 고정 / 해제 </summary>
    public void Fix(bool isTrue)
    {
        _fixedPosition = transform.position;
        _activated = isTrue;
    }
}
```

</details>
