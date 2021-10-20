---
title: 유니티 - 한 번씩만 실행되는 메소드들 순서 정리
author: Rito15
date: 2021-10-16 00:01:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---
- 실행되는 순서대로 작성

<br>


# Methods
---

## **[1] [InitializeOnEnterPlayMode]**
 - [Docs](https://docs.unity3d.com/2019.3/Documentation/ScriptReference/InitializeOnEnterPlayModeAttribute.html)

 - `namespace UnityEditor`
 - 메소드 애트리뷰트
 - 정적 메소드에 사용할 수 있다.

 - 플레이 모드에 진입하고, Awake()가 호출되기 전에 딱 1회 실행된다.
   - 씬을 재시작할 때는 실행되지 않는다.

 - 컴포넌트로 넣지 않고, 스크립트로만 존재해도 실행된다.

```cs
[InitializeOnEnterPlayMode]
private static void Method()
{
    // ...
}
```

<br>


## **[2] [InitializeOnLoad]**
 - [Docs](https://docs.unity3d.com/kr/530/Manual/RunningEditorCodeOnLaunch.html)

 - `namespace UnityEditor`
 - 클래스 애트리뷰트
 - 정적 생성자를 사용해야 한다.

 - 유니티 엔진 시작 시 실행된다.
 - 컴파일할 때마다 실행된다.
 - 플레이모드에 진입할 때마다 실행된다. (씬 시작마다 X 플레이모드 진입할 때만 O)
 - 컴포넌트로 넣지 않고, 스크립트로만 존재해도 실행된다.

```cs
[InitializeOnLoad]
public class MyClass
{
    static MyClass()
    {
        // ...
    }
}
```

<br>


## **[3] [InitializeOnLoadMethod]**
 - `namespace UnityEditor`
 - 메소드 애트리뷰트
 - 정적 메소드

 - 유니티 엔진 시작 시 실행된다.
 - 컴파일할 때마다 실행된다.
 - 플레이모드에 진입할 때마다 실행된다.
 - 컴포넌트로 넣지 않고, 스크립트로만 존재해도 실행된다.

<br>


## **[4] Awake()**
 - 인스턴스 메소드
 - 플레이 모드에 진입하거나 해당 컴포넌트가 생성되는 순간에 실행된다.

 - 게임오브젝트가 비활성화 상태이면 실행되지 않는다.
 - 게임오브젝트가 활성화 상태이면, 컴포넌트가 비활성화 상태여도 실행된다.

<br>


## **[5] OnEnable()**
 - 인스턴스 메소드
 - 플레이 모드 진입 후, 컴포넌트가 활성화될 때마다 실행된다.

 - 동일 컴포넌트 내에서는 `Awake()` 호출 이후 `OnEnable()`이 호출된다.
 - 한 컴포넌트의 `OnEnable()`이 다른 컴포넌트의 `Awake()`보다 앞설 수도 있다.

<br>


## **[6] [RuntimeInitializeOnLoadMethod]**
 - `namespace UnityEngine`
 - 메소드 애트리뷰트
 - 정적 메소드에 사용할 수 있다.

 - 플레이모드에 진입할 때마다 실행된다.
 - 컴포넌트로 넣지 않고, 스크립트로만 존재해도 실행된다.
 - `OnEnable()`이 지난 시점이기 때문에, 모든 컴포넌트들이 인스턴스화 되어 있다.

<br>


## **[7] Start()**
 - 인스턴스 메소드

 - 플레이 모드에 진입하거나 오브젝트가 생성될 때 단 한 번만 실행된다.
   - 컴포넌트가 비활성화 상태였다면, 활성화되고 `OnEnable()`이 호출된 이후에 실행된다.

<br>