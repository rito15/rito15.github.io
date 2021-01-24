---
title: AfterImage(Motion Trail)
author: Rito15
date: 2021-01-19 22:56:00 +09:00
categories: [Unity, Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 게임오브젝트가 지나간 자리에 잔상을 생성합니다.
- 하위 게임오브젝트에도 렌더러가 있는 경우, 잔상을 함께 생성할 수 있습니다.

# How To Use
---
- 대상 게임오브젝트에 Mesh Renderer가 존재하는 경우, MeshAfterImage 스크립트를 부착합니다.
- Skinned Mesh Renderer가 존재하는 경우, SkinnedMeshAfterImage 스크립트를 부착합니다.
- After Image Material 필드에 동봉된 AfterImage 마테리얼을 지정합니다.

- After Image Gradient 옵션으로 잔상의 색상을 지정할 수 있습니다.
- Color Update Speed 옵션으로 그라디언트 색상 변화 속도를 조절할 수 잇습니다.
- Baking Cycle 옵션으로 잔상 생성 주기를 조절할 수 있습니다.
- Duration 옵션으로 잔상 지속 시간을 조절할 수 있습니다.
- Contain Children Meshes를 체크할 경우 해당 게임오브젝트의 모든 하위 오브젝트에 있는 메시들도 잔상을 생성합니다.

# Preview
---
## 1. Mesh AfterImage

![](https://user-images.githubusercontent.com/42164422/104916486-7c1b4480-59d5-11eb-9aa2-5ad96490d932.gif)
![](https://user-images.githubusercontent.com/42164422/104916405-6017a300-59d5-11eb-8527-f6090e3465d9.png)

## 2. Skinned Mesh AfterImage

![](https://user-images.githubusercontent.com/42164422/104916494-7e7d9e80-59d5-11eb-9bff-71be140535ea.gif)
![](https://user-images.githubusercontent.com/42164422/104916473-76bdfa00-59d5-11eb-98b1-bcedfc89eb63.png)


# Source Code
---
- <https://github.com/rito15/Unity_Toys>

# Download
---
- [AfterImage.zip](https://github.com/rito15/Images/files/5862734/2021_0118_AfterImage.zip)