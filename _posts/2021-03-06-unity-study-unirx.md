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
- 비동기 데이터 스트림을 중심으로 동작한다.
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
- 코루틴 대체
- 이벤트 대체
- UI의 변화에 따른 동작 구현
- 입력에 따른 동작 구현
- 네트워크로부터 비동기적으로 데이터 다운로드
- 멀티스레딩

<br>

# 구성과 작동 방식
---

## 기본 작동 방식
 - Observable 객체를 만들거나, 대상을 Observable로 변환하여 스트림을 생성한다.
 - 스트림의 동작을 정의한다. (다양한 연산자 사용)
 - 구독(Subscribe)한다.
 - 스트림의 변화가 감지될 때 메시지가 호출된다.

<br>

## 메시지의 구성

### **OnNext**
 - 일반적으로 사용되는 메시지

### **OnError**
 - 에러 발생 시 전달되는 메시지

### **OnCompleted**
 - 스트림이 완료되었을 때 전달되는 메시지

<br>

# 연산자
---

## **생성**




## **수명**



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

UI 이벤트 대체

코루틴 대체

멀티스레딩(계산)

<br>

# References
---
- <https://huns.me/development/2051>
- <https://github.com/neuecc/UniRx>
- <https://drive.google.com/file/d/1jMZyYRbSrc0-3LOjUqIwQK_5sGvnlTcf/view>
- <https://skuld2000.tistory.com/31>
- <https://www.slideshare.net/agebreak/160402-unirx>
- <https://kimsama.gitbooks.io/unirx/content/>