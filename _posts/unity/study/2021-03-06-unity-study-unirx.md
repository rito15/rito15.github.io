---
title: UniRx (Reactive Extensions for Unity)
author: Rito15
date: 2021-03-06 20:14:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, unirx]
math: true
mermaid: true
---

# 개요
---

## Rx란?

- Reactive Extensions
- .NET에도 다양한 언어로 구현되어 있다.
- 절차적 프로그래밍에서 다루기 쉽지 않은 비동기 프로그래밍을 손쉽게 다루기 위한 패러다임
- 비동기 데이터 스트림을 
- 스트림 내의 데이터에 변화가 발생했을 때 반응형으로 기능이 동작하는 방식을 사용한다.
- Observer Pattern + Iterator Pattern + Functional Programming

<br>

## UniRx
- .NET의 Rx를 유니티에서 사용할 수 없다는 한계를 극복하기 위해 만들어졌다.
- 유니티의 코루틴, 주요 이벤트 함수, UGUI 등과 상호작용하기 편하게 구현되어 있다.

```cs
using UniRx;
using UniRx.Triggers;
```

<br>

## UniRx의 대표적인 활용
- 비동기 구현
- 이벤트 대체
- UI의 변화에 따른 동작 구현
- 입력에 따른 동작 구현
- 네트워크로부터 비동기적으로 데이터 다운로드
- 특정 변수의 값이 바뀌는 순간의 처리

<br>

# 구성과 작동 방식
---

## 기본 작동 방식
 - Observable 객체를 만들거나, 대상을 Observable로 변환하여 스트림을 생성한다.
 - 스트림의 동작을 정의한다. (다양한 연산자 사용)
 - 대상을 구독(Subscribe)한다.
 - 대상의 변화가 감지될 때 스트림에 OnNext() 메시지가 전달된다.
 - 스트림이 종료될 때 OnCompleted() 메시지가 전달된다.

<br>

## 메시지의 구성

### **OnNext**
 - 일반적으로 사용되는 메시지

### **OnError**
 - 에러 발생 시 전달되는 메시지

### **OnCompleted**
 - 스트림이 완료되었을 때 전달되는 메시지

<br>

# 특징
---

## **종료 조건 직접 지정 필요**
- 일단 스트림이 생성되면 스트림에 설정한 종료 조건을 모두 달성하기 전까지는 끝나지 않는다.
- 스트림을 생성한 컴포넌트, 스트림에서 다루는 대상의 비활성화 및 파괴 여부도 직접 지정하지 않으면 확인하지 않는다.
- 따라서 스트림의 종료 조건을 섬세하게 지정해야 한다.

<br>

## **스트림의 자유로운 변환**
- 스트림의 메시지를 전달받아 조건을 설정하고 처리하는 방식이 자유롭다.

- 예를 들어 클릭 이벤트 발생 시 2초 후 다른 동작이 이어진다고 할 때, 기본적으로는 Invoke나 코루틴을 활용해야 한다.
- 클릭 이벤트가 3초 내로 2번 발생해야 다른 동작이 이어진다고 할 때, 이를 구현하려면 굉장히 번거롭다.

- 하지만 UniRx를 이용하면 연산자를 활용하여 간단히 스트림을 변환하여 구현할 수 있다.


<br>

# 연산자
---

## **생성**


<br>

## **수명(지속/종료 조건)**

### `TakeWhile(_ => bool)`
 - 지정한 값이 참일 경우에만 스트림 동작
 - 스트림에 OnNext가 발생하는 순간마다 확인
 - 스트림에 OnNext가 발생하여 확인했는데 지정한 값이 false이면 스트림 종료(+ OnCompleted 전달)

### `TakeUntilDisable(Component)`
 - OnNext마다 확인하지는 않음
 - 지정한 컴포넌트의 게임오브젝트가 비활성화되는 순간 스트림 종료

### `TakeUntileDestroy(Component)`
 - OnNext마다 확인하지는 않음
 - 지정한 컴포넌트의 게임오브젝트가 파괴되는 순간 스트림 종료

### `TakeUntil(IObservable<Unit>)`
 - 매개변수로 등록한 다른 Observable의 이벤트가 발생하는 순간 스트림 종료

<br>

# 대표적인 활용 모음
---

<details>
<summary markdown="span"> 
더블 클릭 판정
</summary>

```cs
// 좌클릭 입력을 감지하는 스트림 생성
var dbClickStream = 
    Observable.EveryUpdate()
        .Where(_ => Input.GetMouseButtonDown(0));

// 스트림의 동작 정의, 종료 가능한 객체 반환
var dbClickStreamDisposable =
    dbClickStream
        .Buffer(dbClickStream.Throttle(TimeSpan.FromMilliseconds(250)))
        .Where(xs => xs.Count >= 2)
        //.TakeUntilDisable(this) // 게임오브젝트 비활성화 시 스트림 종료
        .Subscribe(
            xs => Debug.Log("DoubleClick Detected! Count:" + xs.Count), // OnNext
            _  => Debug.Log("DoubleClick Stream - Error Detected"),     // OnError
            () => Debug.Log("DoubleClick Stream - Disposed")            // OnCompleted
        );

// 스트림 종료
//dbClickStreamDisposable.Dispose();
```

</details>

<br>

<details>
<summary markdown="span"> 
UI 이벤트 대체
</summary>

```cs

```

</details>

<br>

<details>
<summary markdown="span"> 
??
</summary>

```cs

```

</details>


<br>

# References
---
- <https://huns.me/development/2051>
- <https://github.com/neuecc/UniRx>
- <https://drive.google.com/file/d/1jMZyYRbSrc0-3LOjUqIwQK_5sGvnlTcf/view>
- <https://skuld2000.tistory.com/31>
- <https://www.slideshare.net/agebreak/160402-unirx>
- <https://kimsama.gitbooks.io/unirx/content/>