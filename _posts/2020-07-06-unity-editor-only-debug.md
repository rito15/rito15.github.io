---
title: Unity Editor-only Debug
author: Rito15
date: 2020-07-06 15:00:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 유니티엔진의 콘솔 디버그는 빌드 이후에도 작동하여, 성능을 많이 소모할 수 있습니다.
- 이를 방지할 수 있게, 유니티 에디터에서만 작동하도록 래핑된 Debug 클래스입니다.

# How To Use
---
- 스크립트 상단에 다음과 같이 작성합니다.

```cs
using Debug = Rito.Debug;
```

# Source Code
---
- <https://github.com/rito15/Unity_Toys>

# Download
---
- [Debug_UnityEditorConditional.zip](https://github.com/rito15/Images/files/5864550/Debug_UnityEditorConditional.zip)