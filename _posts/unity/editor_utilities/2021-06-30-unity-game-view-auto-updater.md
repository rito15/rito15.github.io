---
title: Game View Auto Updater(에디터 모드에서 게임 뷰 자동으로 갱신)
author: Rito15
date: 2021-06-30 22:00:00 +09:00
categories: [Unity, Unity Editor Utilities]
tags: [unity, editor, csharp, utility]
math: true
mermaid: true
---

# Summary
---

플레이 모드에 진입하지 않으면 게임 뷰는 GUI에 변화가 있을 때만 갱신됩니다.

따라서 쉐이더를 통해 각종 애니메이션이나 효과를 만들고 마테리얼을 통해 적용해도

에디터 모드에서는 이를 정상적으로 확인할 수 없습니다.

이 애셋은 에디터 모드에서도 마테리얼 효과를 정상적으로 확인할 수 있게 합니다.

<br>

# How To Use
---
- 첨부된 `Game-View-Auto-Updater.unitypackage` 파일을 다운받습니다.

- 유니티 프로젝트가 켜진 상태로 해당 파일을 실행하여 프로젝트 내에 임포트합니다.

- 에디터 상단의 플레이 버튼 좌측에 위치한 `Auto Update Game View` 버튼을 활성화/비활성화합니다.

![image](https://user-images.githubusercontent.com/42164422/123966859-c119bd00-d9f0-11eb-95d3-12a4cc90de36.png)

<br>

# Preview
---

![2021_0702_GameViewUpdater](https://user-images.githubusercontent.com/42164422/124244150-972fda00-db59-11eb-9dc0-7a2607272dd2.gif)

<br>

# Download
---
- [Game-View-Auto-Updater.unitypackage](https://github.com/rito15/Images/releases/download/0.1/Game-View-Auto-Updater.unitypackage)


<br>

# References
---
- <https://github.com/marijnz/unity-toolbar-extender>