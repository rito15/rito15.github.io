---
title: Camera Depth, Sorting Layer, Sorting Group
author: Rito15
date: 2021-06-25 20:40:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Camera Depth(Z)
---

- 카메라로부터의 거리

- 가까울수록 먼저 보인다.

<br>

# Sorting Layer vs. Camera Depth
---

- **Sorting Layer**가 **Camera Depth**보다 우선적으로 깊이를 결정한다.

- **Sorting Layer** 설정이 같은 경우, **Camera Depth**가 깊이를 결정한다.

<br>

# Sorting Layer
---

- 서로 다른 **Sorting Layer**의 경우, 인덱스의 값이 클수록(0 < 1 < 2 < ...) 먼저 보인다.

- 같은 **Sorting Layer** 내에서는 `Order In layer` 값이 클수록 먼저 보인다.

<br>

# Sorting Group
---

- 부모-자식 관계로 여러 스프라이트들이 하나의 캐릭터를 이룰 때 사용한다.

- 각 캐릭터의 최상위 부모 게임오브젝트에 `Sorting Group` 컴포넌트를 넣는다.

- 캐릭터 간에는 각 `Sprite Renderer`보다 `Sorting Group`끼리의 설정을 더 우선적으로 인식하게 된다.

<br>

# 우선순위 정리
---

- `Sorting Group` > `Sorting Layer` > `Camera Depth`
