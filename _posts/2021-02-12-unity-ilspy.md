---
title: ILSpy로 유니티 내부 구현 뜯어보기
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

# 유니티 구현 뜯어보기
---

```
C:\Program Files\유니티 버전\Editor\Data\Managed\UnityEngine
```

- 위 경로에 유니티 주요 dll들이 들어있다.
- 평소 자주 사용하는 기능들은 주로 `UnityEngine.CoreModule.dll`에 포함되어 있다.

<br>

# 예시
---

![image](https://user-images.githubusercontent.com/42164422/107696587-8212f580-6cf5-11eb-9ee3-1fef0ab19b23.png){:.normal}

UnityEngine.Mathf.Sin() 메소드는 System.Math.Sin() 메소드를 호출하고,

(그 결괏값은 double이므로 float로 캐스팅도 해주고,)

System.Math.Sin() 메소드는 네이티브 C++의 Sin() 메소드를 호출한다.

이를 통해 UnityEngine.Mathf 대신 System.Math를 사용하는 것이 성능상 이득이라는 것을 알 수 있다.

이렇게 찾다보면, 메소드를 직접 구현해 사용하는 것이 대부분의 경우 가장 이득이라는 결론도 내릴 수 있다.

<br>

# References
---
- <https://github.com/icsharpcode/ILSpy>