---
title: 유니티 - ILSpy로 유니티 API 구현 뜯어보기
author: Rito15
date: 2021-02-12 05:32:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, ilspy]
math: true
mermaid: true
---

# 다운로드
---
- <https://github.com/icsharpcode/ILSpy/releases>
- vsix를 받을 경우, 비주얼 스튜디오의 확장으로 추가하여 [도구] - [ILSpy]를 통해 바로 실행할 수 있다.

<br>

# 사용법
---
- ILSpy를 실행한다.

- File - Open으로 대상 어셈블리(dll, exe 등)를 불러온다.

- 검색을 통해 원하는 클래스, 메소드 등을 빠르게 찾을 수 있다.

<br>

# 유니티 API 구현 뜯어보기
---

```
C:\Program Files\유니티 버전\Editor\Data\Managed\UnityEngine
```

- 위 경로에 유니티 주요 dll들이 들어있다.
- 평소 자주 사용하는 기능들은 주로 `UnityEngine.CoreModule.dll`에 포함되어 있다.

<br>

# 예시
---

![image](https://user-images.githubusercontent.com/42164422/120445296-6e35f100-c3c3-11eb-8b3c-4387bf4e9fed.png)

.dll 내에 존재하여 평소에는 곧바로 확인할 수 없었던 내부 구현 코드를

위와 같이 ILSpy를 통해 찾아볼 수 있다.

이를 이용해 평소에 궁금하던 내부 구현을 확인하거나,

특히 유니티 에디터 스크립팅을 할 때

private/internal로 막혀 있던 기능들을 찾아 리플렉션으로 가져와서

자유로운 기능 구현을 해볼 수 있다.

<br>

# Tip
---

- 내부를 확인하고 싶은 클래스의 dll 파일 경로를 모를 경우
  - 비주얼 스튜디오의 스크립트 내에서 해당 클래스 이름에 Ctrl + 좌클릭한다.
  - `클래스명[메타데이터에서]` 페이지의 상단의 주석에서 파일 위치를 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/121644422-f0ae6700-cacd-11eb-8c19-6a610ebb7cea.png)

<br>

# References
---
- <https://github.com/icsharpcode/ILSpy>