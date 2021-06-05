---
title:  유니티 이벤트 함수는 어떻게 실행되는 것일까?
author: Rito15
date: 2021-06-06 05:05:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Unity Event Functions
---

유니티엔진에서 '스크립트'를 작성한다고 하면, 보통 `MonoBahaviour`를 상속받는 클래스의 스크립트를 작성하는 것을 떠올릴 것이다.

그리고 자연스럽게 이 클래스 내에 `Awake()`, `Start()`, `Update()` 등의 메소드를 작성하게 된다.

심지어 비주얼 스튜디오 같은 개발 환경에서는 이런 메소드들에 대해 자동 완성도 해주고, 메소드 위에는 `Unity 메시지`라는 글자도 띄워준다.

이런 메소드들은 **'Unity Event Function'**, **'Unity Message'** 또는 **'Magic Method'**라고 불린다.

<br>

그런데 생각해보면 이 메소드들은 `MonoBehaviour` 또는 그 부모 클래스로부터 상속받은 메소드도 아닌데,

어떻게 유니티가 알아서 찾아 적절한 타이밍에 호출해줄 수 있는 걸까?

`SendMessage()` 메소드는 리플렉션을 기반으로 동작한다는데,

이벤트 함수도 마찬가지일까?

<br>

궁금해서 찾아보니,

![image](https://user-images.githubusercontent.com/42164422/120898406-aeb49980-c665-11eb-8b92-34ff97c068ff.png)

이런 내용을 찾을 수 있었다.

정리해보면,

- 유니티는 내부적으로 리플렉션을 이용해 매직 메소드를 호출하지 않는다.
- `Mono` 또는 `IL2CPP`와 같은 스크립팅 런타임에 의해 `MonoBehaviour`에 접근할 때, 매직 메소드의 작성 여부를 검사하여 이를 캐싱한다.

<br>

# Mono & IL2CPP
---

그렇다면 `Mono`와 `IL2CPP`란 무엇일까?

이를 이해하기 위해서는 일단 닷넷의 `CLR`과 `CIL`에 대해 이해할 필요가 있다.

<br>

Post Link : <https://rito15.github.io/posts/cs-dotnet-compile/>

<br>

다시 간단히 정리해보면,

## **CIL**
 - Common Intermediate Language, 공통 중간 언어
 - `.NET` 고유의 객체지향 어셈블리 언어
 - `.NET` 환경에서 타겟 플랫폼에 관계 없이 자유롭게 개발할 수 있도록 도와주는 녀석

## **CLR**
 - Common Language Runtime, 공통 언어 런타임
 - `CIL Code` -> `Native Code`로 컴파일해주는 가상 머신

<br>

![image](https://user-images.githubusercontent.com/42164422/120903808-42e12980-c683-11eb-8a6f-aeec25db5598.png)

`Mono`와 `IL2CPP`란, `CIL Code`를 `Native Code`로 컴파일해주는 스크립팅 백엔드이다.

그러니까, `.NET Framework`에서 `CLR`이 수행하는 역할을 유니티에서 해주는 녀석들이다.

<br>

`Mono`는 `JIT` 컴파일을 통해 `CIL Code` -> `Native Code`로 변환해주고,

`IL2CPP`는 `AOT` 컴파일을 통해 `CIL Code` -> `.NET Native Code`로 변환해준다.

<br>

`Mono`는 유니티 자체 개발이 아니며,

`IL2CPP`는 유니티 자체 개발이다.

<br>

빌드 시간은 `Mono`가 `IL2CPP`보다 빠르고,

성능과 보안성은 `IL2CPP`가 `Mono`보다 좋다.


<br>

# References
---
- <https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.html>
- <https://gamedev.stackexchange.com/questions/164892/why-does-unity-use-reflection-to-get-the-update-method>
- <https://blog.unity.com/technology/1k-update-calls>
- <https://stackoverflow.com/questions/30221987/in-unity-what-exactly-is-going-on-when-i-implement-update-and-other-messages/30222443#30222443>
- <https://everyday-devup.tistory.com/32>
- <https://blog.unity.com/technology/an-introduction-to-ilcpp-internals>
- <https://docs.unity3d.com/kr/2018.4/Manual/IL2CPP.html>
- <https://chp747.tistory.com/334>