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
- 시간을 상당히 간단하게 취급할 수 있게 된다.
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
- 변수의 값이 바뀌는 순간의 처리
- Update()의 로직을 모두 스트림화하여 Update() 없애기
- 코루틴과의 결합

<br>

# 구성과 작동 방식
---

## 기본 작동 방식
 - Observable 객체를 만들거나, 대상을 Observable로 변환하여 스트림을 생성한다.
 - 다양한 연산자를 통해 스트림을 가공한다.
 - 스트림을 구독(Subscribe)한다.<br>
   (IObservable -> IDisposable로 변환됨)
 - 스트림의 변화가 감지될 때 옵저버에게 OnNext() 메시지가 전달된다.
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
- 스트림을 생성한 컴포넌트, 스트림에서 다루는 대상의 비활성화 및 파괴 여부도 직접 지정하지 않으면 확인하지 않는다.<br>
  (this.~ 처럼 컴포넌트에서 동적으로 생성하는 경우에는 게임오브젝트에 종속)
- 따라서 스트림의 종료 조건을 섬세하게 지정해야 한다.

<br>

## **스트림의 자유로운 가공**
- 스트림의 메시지를 전달받아 조건을 설정하고 처리하는 방식이 자유롭다.

- 예를 들어 클릭 이벤트 발생 시 2초 후 다른 동작이 이어진다고 할 때, 기본적으로는 Invoke나 코루틴을 활용해야 한다.
- 클릭 이벤트가 3초 내로 2번 발생해야 다른 동작이 이어진다고 할 때, 이를 구현하려면 굉장히 번거롭다.

- 하지만 UniRx를 이용하면 연산자를 활용하여 간단히 스트림을 변환하여 구현할 수 있다.


<br>

# Observable 스트림의 생성
---

## 1. Observable 팩토리 메소드


## 2. UniRx.Triggers


## 3. Subject<T>


## 4. ReactiveProperty<T>

- 인스펙터에 표시하려면 `IntReactiveProperty`처럼 ~ReactiveProperty를 사용한다.


## 5. 이벤트를 변환



## 6. 코루틴을 변환



<br>

# 연산자
---

<details>
<summary markdown="span"> 
스트림의 종료에 영향을 주는 필터
</summary>

### `IObservable.TakeWhile(_ => bool)`
 - 지정한 값이 참일 경우에만 스트림 동작
 - 스트림에 OnNext()가 발생하는 순간에만 확인
 - 스트림에 OnNext()가 발생하여 확인했는데 지정한 값이 false이면 스트림 종료(+ OnCompleted() 전달)

### `IObservable.TakeUntil(IObservable<Unit>)`
 - 매개변수로 등록한 다른 Observable의 이벤트가 발생하기 전까지만 통지
 - 매개변수의 이벤트가 발생하면 스트림 종료, OnCompleted()

### `IObservable.TakeUntilDisable(Component)`
 - 지정한 컴포넌트의 게임오브젝트가 비활성화되는 순간 스트림 종료, OnCompleted()

### `IObservable.TakeUntilDestroy(Component)`
 - 지정한 컴포넌트의 게임오브젝트가 비활성화되는 순간 스트림 종료, OnCompleted()

### `IDisposable.AddTo()`
 - 매개변수는 GameObject, Component, IDisposable
 - 대상 게임오브젝트가 파괴되거나 IDisposable.Dispose()를 호출한 경우, 함께 스트림 종료
 - OnCompleted()을 호출하지 않으므로 주의.

</details>

<br>


<details>
<summary markdown="span"> 
필터(조건)
</summary>

### `Where(_ => bool)`
 - 조건이 true인 메시지만 통과

### `Distinct()`
 - 기존에 OnNext()로 통지한 적 있는 값은 더이상 통지하지 않는다.

### `DistinctUntilChanged()`
 - 값이 변화할 때만 통지

</details>

<br>


<details>
<summary markdown="span"> 
변환
</summary>



</details>

<br>


<details>
<summary markdown="span"> 
합성
</summary>



</details>

<br>


<details>
<summary markdown="span"> 
지연(딜레이)
</summary>



</details>

<br>



# NOTE
---

<details>
<summary markdown="span"> 
this.UpdateAsObservable(), Observable.EveryUpdate(), this.ObserveEveryValueChanged()
</summary>

## this.UpdateAsObservable()
 - 해당 컴포넌트의 게임오브젝트가 활성화된 동안에만 OnNext()를 통지한다.
 - 컴포넌트의 활성화 여부에는 영향 받지 않는다.
 - 게임오브젝트가 파괴되면 OnCompleted()를 통지한다.

## Observable.EveryUpdate()
 - 어디에 종속되지 않고 완전히 독자적으로 실행된다.
 - 종료 조건을 직접 지정해야 한다.

<br>
+

## this.ObserveEveryValueChanged()
 - 값의 변화만 통지하는 스트림
 - 대상 객체(컴포넌트)가 활성화된 동안에만 OnNext()를 통지한다.
 - 대상 객체(컴포넌트)가 파괴되면 OnCompleted()를 통지한다.
 - 스트림의 활성/생존이 객체에 종속적인, 가장 이상적인 형태

</details>

<br>

<details>
<summary markdown="span"> 
값의 변화를 매 프레임 검사할 때 주의점
</summary>

- ObserveEveryValueChanged(_ => __), DistinctUntilChanged() 등을 사용하여 값의 변화를 매 프레임 검사할 때, 게임 시작 후 첫 프레임에 무조건 OnNext()가 발생할 수 있다.

- 이럴 때는 Subscribe() 직전에 `.Skip(TimeSpan.Zero)`을 사용하여 게임 시작 직후 첫 프레임을 무시하도록 한다.

- 예시 : 

```cs
this.ObserveEveryValueChanged(_ => this._intValue)
    .Skip(TimeSpan.Zero)
    .Subscribe(x => Debug.Log("Value : " + x));
```

</details>

<br>



# 대표적인 활용 모음
---


<details>
<summary markdown="span"> 
웹 통신 결과 비동기 통지
</summary>

```cs
// Obsolete : Use UnityEngine.Networking.UnityWebRequest Instead.

ObservableWWW.Get("http://google.co.kr/")
    .Subscribe(
        x => Debug.Log(x.Substring(0, 20)), // onSuccess
        ex => Debug.LogException(ex)       // onError
    );
```

</details>

<br>


<details>
<summary markdown="span"> 
대상 스트림이 모두 결과를 얻으면 통지
</summary>

```cs
var parallel = Observable.WhenAll(
    ObservableWWW.Get("http://google.com/"),
    ObservableWWW.Get("http://bing.com/"),
    ObservableWWW.Get("http://unity3d.com/")
);

parallel.Subscribe(xs =>
{
    Debug.Log(xs[0].Substring(0, 100)); // google
    Debug.Log(xs[1].Substring(0, 100)); // bing
    Debug.Log(xs[2].Substring(0, 100)); // unity
});
```

</details>

<br>


<details>
<summary markdown="span"> 
단순 타이머 : 게임오브젝트 수명 지정
</summary>

```cs
Observable.Timer(TimeSpan.FromSeconds(3.0))
    .TakeUntilDisable(this)
    .Subscribe(_ => Destroy(gameObject));
```

</details>

<br>


<details>
<summary markdown="span"> 
값이 변화하는 순간을 포착하기
</summary>

```cs
// 마우스 클릭, 떼는 순간 모두 포착
this.UpdateAsObservable()
    .Select(_ => Input.GetMouseButton(0))
    .DistinctUntilChanged()
    .Skip(1) // 시작하자마자 false값에 대한 판정 때문에 "Up" 호출되는 것 방지
    .Subscribe(down =>
    {
        if (down)
            Debug.Log($"Down : {Time.frameCount}");
        else
            Debug.Log($"Up : {Time.frameCount}");
    });


// 값이 false -> true로 바뀌는 순간만 포착
this.UpdateAsObservable()
    .Select(_ => this._boolValue)
    .DistinctUntilChanged()
    .Where(x => x)
    .Skip(TimeSpan.Zero) // 첫 프레임 때의 호출 방지
    .Subscribe(_ => Debug.Log("TRUE"));

// 매 프레임, 값의 변화 포착만을 위한 간단한 구문 (위 구문을 간소화)
this.ObserveEveryValueChanged(_ => this._boolValue)
    .Where(x => x)
    .Skip(TimeSpan.Zero)
    .Subscribe(_ => Debug.Log("TRUE 2"));


// .Skip(TimeSpan.Zero)
// => 초기값이 true일 때 첫 프레임에 바로 호출되는 것을 방지한다.



// ObserveEveryValueChanged : 클래스 타입에 대해 모두 사용 가능
this.ObserveEveryValueChanged(x => x._value)
    .Subscribe(x => Debug.Log("Value Changed : " + x));
```

</details>

<br>


<details>
<summary markdown="span"> 
급변하는 값을 정제하기
</summary>

```cs
// ObserveEveryValueChanged : 값이 변화했을 때 통지
// ThrottleFrame(5) : 마지막 통지로부터 5프레임동안 값의 통지를 받지 않으면 OnNext()

// 따라서 값이 급변하는 동안에는 OnNext() 하지 않고
// 5프레임 이내로 값이 변하지 않았을 때 마지막으로 기억하는 값을 전달

// 5프레임 이내에서 순간적으로 급변하는 값들을 무시하여, 값을 정제하는 효과가 있음

// 사용 예시 : 닿았는지 여부 검사, 비탈길에서의 isGrounded 검사

this.ObserveEveryValueChanged(_ => this._isTouched)
    .ThrottleFrame(5)
    .Subscribe(x => _isTouchedRefined = x);


// 위의 ObserveEveryValueChanged와 정확히 같은 용법

TryGetComponent(out CharacterController cc);
cc.UpdateAsObservable()
    .Select(_ => cc.isGrounded)
    .DistinctUntilChanged()
    .ThrottleFrame(5)
    .Subscribe(x => _isGroundedRefined = x);
```

</details>

<br>


<details>
<summary markdown="span"> 
더블 클릭 판정
</summary>

```cs
// * 마지막 입력으로부터 인식 딜레이 발생

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
더블 클릭 판정(즉시)
</summary>

```cs
// * 인식 딜레이는 없지만, 간혹 제대로 인식하지 못하는 버그 존재

// 0.3초 내로 두 번의 클릭을 인지하면 더블클릭 판정
Observable.EveryUpdate().Where(_ => Input.GetMouseButtonDown(0))
    .Buffer(TimeSpan.FromMilliseconds(300), 2)
    .Where(buffer => buffer.Count >= 2)
    .Subscribe(_ => Debug.Log("DoubleClicked!"));
```

</details>

<br>


<details>
<summary markdown="span"> 
동일 키보드 연속 입력 및 유지 판정
</summary>

```cs
// * 마지막 입력으로부터 인식 딜레이 존재

var keyDownStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKeyDown(key));

var keyUpStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKeyUp(key));

var keyPressStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKey(key))
        .TakeUntil(keyUpStream);

var dbKeyStreamDisposable =
    keyDownStream
        .Buffer(keyDownStream.Throttle(TimeSpan.FromMilliseconds(300)))
        .Where(x => x.Count >= 2)
        .SelectMany(_ => keyPressStream)
        .TakeUntilDisable(this)
        .Subscribe(_ => action());

```

</details>

<br>


<details>
<summary markdown="span"> 
동일 키보드 연속 입력 및 유지 판정 (즉시)
</summary>

```cs
// * 마지막 입력으로부터 인식 딜레이는 없지만, 홀수 입력 인식 불가

var keyDownStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKeyDown(key));

var keyUpStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKeyUp(key));

var keyPressStream = 
    Observable.EveryUpdate().Where(_ => Input.GetKey(key))
        .TakeUntil(keyUpStream);

var dbKeyStreamDisposable =
    keyDownStream
        .Buffer(keyDownStream.Throttle(TimeSpan.FromMilliseconds(300)))
        .Where(x => x.Count >= 2)
        .SelectMany(_ => keyPressStream)
        .TakeUntilDisable(this)
        .Subscribe(_ => action());

```

</details>

<br>


<details>
<summary markdown="span"> 
UI 이벤트 대체
</summary>

```cs
var buttonStream =
_targetButton.onClick.AsObservable()
    .TakeUntilDestroy(_targetButton)
    .Subscribe(
        _  => Debug.Log("Click!"),
        _  => Debug.Log("Error"),
        () => Debug.Log("Completed")
    );
```

</details>

<br>


<details>
<summary markdown="span"> 
드래그 앤 드롭(OnMouseDrag()와 동일)
</summary>

```cs
this.OnMouseDownAsObservable()
    .SelectMany(_ => this.UpdateAsObservable())
    .TakeUntil(this.OnMouseUpAsObservable())
    .Select(_ => Input.mousePosition)
    .RepeatUntilDestroy(this) // Safe Repeating
    .Subscribe(x => Debug.Log(x));
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
- <https://www.youtube.com/watch?v=NN1_41TE1N0&ab_channel=UnityKorea>