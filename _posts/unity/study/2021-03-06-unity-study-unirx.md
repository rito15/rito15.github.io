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
   - IObservable -> IDisposable로 변환된다.
   - 여기에 Dispose()를 호출하여 간단히 구독을 종료할 수 있다.

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

## 1. Observable 팩토리 메소드(생성 연산자)

<details>
<summary markdown="span"> 

</summary>

- 미리 만들어져 있는 기능들을 이용해 빠르게 스트림을 생성할 수 있다.

- [참고 : Wiki](https://github.com/neuecc/UniRx/wiki/UniRx#observable)

```cs
// Empty : OnCompleted()를 즉시 전달
Observable.Empty<Unit>()
    .Subscribe(x => Debug.Log("Next"), () => Debug.Log("Completed"));

// Return : 한 개의 메시지만 전달
Observable.Return(2.5f)
    .Subscribe(x => Debug.Log("value : " + x));

// Range(a, b) : a부터 (a + b - 1)까지 b번 OnNext()
// 5부터 14까지 10번 OnNext()
Observable.Range(5, 10)
    .Subscribe(x => Debug.Log($"Range : {x}"));

// Interval : 지정한 시간 간격마다 OnNext()
Observable.Interval(TimeSpan.FromSeconds(1))
    .Subscribe(_ => Debug.Log("Interval"));

// Timer : 지정한 시간 이후에 OnNext()
Observable.Timer(TimeSpan.FromSeconds(2))
    .Subscribe(_ => Debug.Log("Timer"));

// EveryUpdate : 매 프레임마다 OnNext()
Observable.EveryUpdate()
    .Subscribe(_ => Debug.Log("Every Update"));

// Start : 무거운 작업을 병렬로 처리할 때 사용된다.
//         멀티스레딩으로 동작한다.
Debug.Log($"Frame : {Time.frameCount}");
Observable.Start(() =>
{
    Thread.Sleep(TimeSpan.FromMilliseconds(2000));
    MainThreadDispatcher.Post(_ => Debug.Log($"Frame : {Time.frameCount}"), new object());
    return Thread.CurrentThread.ManagedThreadId;
})
    .Subscribe(
        id => Debug.Log($"Finished : {id}"),
        err => Debug.Log(err)
    );
```

</details>

<br>

## 2. UniRx.Triggers

<details>
<summary markdown="span"> 

</summary>

- `using UniRx.Triggers;` 필요

- 유니티의 모노비헤이비어 콜백 메소드들을 스트림으로 빠르게 변환하여 사용할 수 있다.

- 이를 활용하여 콜백 메소드를 완전히 대체할 수 있다.

- [참고 : UniRx.Triggers 위키](https://github.com/neuecc/UniRx/wiki/UniRx.Triggers)

```cs
// 필드 값을 매 프레임 조건 없이 출력
this.UpdateAsObservable()
    .Select(_ => this._intValue)
    .Subscribe(x => Debug.Log(x));
```

</details>

<br>

## 3. Subject<T>

<details>
<summary markdown="span"> 

</summary>

- `Subject<T>`는 델리게이트 또는 이벤트처럼 사용될 수 있다.

- 하지만 스트림의 다양한 연산자를 활용할 수 있으므로, 이벤트의 상위호환이라고 할 수 있다.

- `Subject<T>`를 잘 활용하면 커스텀한 Observable을 만들어 사용할 수 있다.
  - => 원하는 타이밍에 OnNext() 호출

- `Subject<T>`에는 직접 OnNext()를 호출할 수 있으므로, OnNext()를 호출할 수 없는 구독 전용 스트림을 제공하려면 `.AsObservable()`로 변환하면 된다.

```cs
Subject<string> strSubject = new Subject<string>();

strSubject.Subscribe(str => Debug.Log("Next : " + str));
strSubject
    .DelayFrame(10)
    .Subscribe(str => Debug.Log("Delayed Next : " + str));

strSubject.OnNext("A"); // OnNext()는 이벤트의 Invoke()와 같은 역할
strSubject.OnNext("B");

strSubject.OnCompleted(); // 스트림 종료

// 구독 전용 스트림
var obs = strSubject.AsObservable();
obs.Subscribe(str => Debug.Log(str));
```

</details>

<br>

## 4. ReactiveProperty<T>

<details>
<summary markdown="span"> 

</summary>

- 값이 초기화될 때마다 스트림에 `OnNext(T)` 메시지가 전달된다.

- 인스펙터에 표시하려면 `IntReactiveProperty`처럼 ~ReactiveProperty를 사용한다.

```cs
private ReactiveProperty<int> _intProperty = new ReactiveProperty<int>();
private IntReactiveProperty _intProperty2 = new IntReactiveProperty();

private void TestReactiveProperties()
{
    // 값 초기화할 때마다 OnNext(int)
    _intProperty
        .Subscribe(x => Debug.Log(x));

    // 5의 배수인 값이 초기화될 때마다 값을 10배로 증가시켜 OnNext(int)
    _intProperty
        .Where(x => x % 5 == 0)
        .Select(x => x * 10)
        .Subscribe(x => Debug.Log(x));

    for(int i = 0; i <= 5; i++)
        _intProperty.Value = i;
}
```

</details>

<br>

## 5. 이벤트를 스트림으로 변환

<details>
<summary markdown="span"> 

</summary>

- C#의 이벤트는 스트림으로 변환할 수 없다.

- UnityEvent 타입은 스트림으로 변환할 수 있다.

- UGUI의 이벤트들 역시 스트림으로 변환할 수 있다.

```cs
private UnityEngine.Events.UnityEvent MyEvent;

private void EventToStream()
{
    MyEvent = new UnityEngine.Events.UnityEvent();

    MyEvent
        .AsObservable()
        .Subscribe(_ => Debug.Log("Event Call"));

    MyEvent.Invoke();
    MyEvent.Invoke();
}
```

</details>

<br>

## 6. 코루틴을 스트림으로 변환

<details>
<summary markdown="span"> 

</summary>

- 코루틴을 스트림으로 변환하여 사용할 수 있다.

- `Coroutine().ToObservable()` 또는 `Observable.FromCoroutine(Coroutine))`

- `Subscribe()`를 호출하는 순간 코루틴이 시작된다.

<br>

### **[1] 코루틴 단순 변환**

- 코루틴이 종료되는 순간 `OnNext()`, `OnCompleted()`가 호출된다.

<br>

### **[2] 코루틴으로부터 리턴값 전달받기**

- `Observable.FromCoroutineValue<T>`를 통해 코루틴으로부터 리턴 값을 받아 사용할 수 있다.

- 지정한 `T` 타입으로 값을 넘기면 `OnNext(T)`의 인자로 들어오며, `OnNext(T)`가 호출된다.

- 다른 타입으로 값을 넘기면 `InvalidCastException`이 발생한다.

- `WaitForSeconds()`, `null` 등을 리턴할 때는 `OnNext(T)`를 호출하지 않고, 프레임을 넘기는 역할만 수행한다.

- 비동기 수행 후 값을 리턴받아 특정 동작을 수행해야 할 때 아주 유용할듯

```cs
private void CoroutineToStream()
{
    // 코루틴 변환 방법 1
    TestRoutine()
        .ToObservable()
        .Subscribe(_ => Debug.Log("Next 1"), () => Debug.Log("Completed 1"));

    // 코루틴 변환 방법 2
    Observable.FromCoroutine(TestRoutine)
        .Subscribe(_ => Debug.Log("Next 2"));

    // 코루틴에서 정수형 yield return 값 받아 사용하기
    // WaitForSeconds, null 등은 무시하며
    // 값을 리턴하는 경우 OnNext()의 인자로 들어온다.
    // 타입이 다른 값을 리턴하는 경우에는 InvalidCastException 발생
    Observable.FromCoroutineValue<int>(TestRoutine)
        .Subscribe(x => Debug.Log("Next : " + x), () => Debug.Log("Completed 3"));
}

private IEnumerator TestRoutine()
{
    Debug.Log("TestRoutine - 1");
    yield return new WaitForSeconds(1.0f);

    Debug.Log("TestRoutine - 2");
    yield return Time.frameCount; // 여기부터
    yield return 123;
    yield return Time.frameCount; // 여기까지 같은 프레임
    yield return null;
    yield return Time.frameCount; // 프레임 넘어감
    yield return 12.3;            // InvalidCastException
}
```

</details>

<br>

# 연산자
---

<details>
<summary markdown="span"> 
스트림의 종료에 영향을 주는 필터
</summary>

### `Take(int)`
 - 지정한 갯수의 메시지만 전달하고 종료한다.

### `TakeWhile(_ => bool)`
 - OnNext()가 발생했을 때 지정한 조건이 참이면 메시지를 전달하고, 거짓이면 스트림을 종료한다.

### `TakeUntil(IObservable)`
 - 매개변수로 등록한 다른 스트림의 이벤트가 발생하기 전까지만 메시지를 전달한다.
 - 매개변수의 이벤트가 발생하면 스트림을 종료한다. (OnCompleted())

### `TakeUntilDisable(Component)`
 - 지정한 컴포넌트의 게임오브젝트가 비활성화되는 순간 스트림을 종료한다.

### `TakeUntilDestroy(Component)`
 - 지정한 컴포넌트의 게임오브젝트가 파괴되는 순간 스트림을 종료한다.

### `IDisposable.AddTo()`
 - 매개변수는 GameObject, Component, IDisposable
 - 대상 게임오브젝트가 파괴되거나 IDisposable.Dispose()를 호출한 경우, 함께 스트림 종료
 - OnCompleted()을 호출하지 않으므로 주의한다.

</details>

<br>


<details>
<summary markdown="span"> 
필터(조건)
</summary>

### `Where(_ => bool)`
 - 조건이 true인 메시지만 통과시킨다.

### `Distinct()`
 - 기존에 OnNext()로 통지한 적 있는 값은 더이상 통지하지 않는다.

### `DistinctUntilChanged()`
 - 값이 변화할 때만 메시지를 전달한다.

### `Throttle(TimeSpan.~)`
 - 마지막 메시지로부터 지정한 시간만큼 추가적인 메시지가 발생하지 않으면 전달한다.
 - 메시지가 들어올 때마다 지정한 시간을 새롭게 체크하므로, 마지막 메시지로부터 실제 전달까지 지정한 시간만큼의 지연시간이 발생한다.

### `ThrottleFrame(int)`
 - 마지막 메시지로부터 지정한 프레임만큼 추가적인 메시지가 발생하지 않으면 전달한다.

### `ThrottleFirst(TimeSpan.~)`
 - 메시지를 받으면 지정한 시간 동안 들어오는 메시지들을 모두 무시한다.

### `ThrottleFirstFrame(int)`
 - 메시지를 받으면 지정한 프레임 동안 들어오는 메시지들을 모두 무시한다.

### `Skip(int)` or `Skip(TimeSpan)`
 - 지정한 개수만큼 또는 지정한 시간 동안 메시지를 무시한다.

### `SkipWhile(_ => bool)`
 - 조건이 true인 동안 메시지를 무시한다.

### `SkipUntil(IObservable)`
 - 매개변수의 스트림에 OnNext()가 발생할 때까지 계속 메시지를 무시하며, 그 이후에는 메시지를 모두 전달한다. (1회성)

</details>

<br>


<details>
<summary markdown="span"> 
변환
</summary>

### `Select(x => value)`
 - 스트림의 값을 변경하는 역할을 한다.
 - `x` 값을 가공하여 변경할 수 있다.
 - `x` 값과 관계 없는 값을 제공할 수도 있다.

### `SelectMany(_ => IObservable)`
 - 기존의 스트림을 새로운 스트림으로 대체한다.
 - 기존의 스트림에서 `OnNext()`가 발생하면, 매개변수로 입력한 스트림으로 기존 스트림이 대체된다.

<details>
<summary markdown="span"> 
예제 : 드래그 앤 드롭
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

### `Cast<T, V>()`
 - `T` 타입의 메시지를 `V` 타입으로 형변환한다.
 - 박싱과 언박싱이 발생한다.

</details>

<br>


<details>
<summary markdown="span"> 
메시지 합성
</summary>

### `Scan((a, b) => c)`
 - 지난 메시지와 현재 메시지의 값을 `a`, `b` 매개변수로 받아 `c`로 합성한다.

### `Buffer(int)` or `Buffer(TimeSpan)`
 - 지정한 횟수 또는 시간에 도달할 때까지 OnNext()를 하지 않고 메시지를 누적한다.
 - 도달할 경우, 누적된 메시지들을 리스트의 형태로 한번에 전달한다.
 - 시간을 지정하는 경우, OnNext() 타이밍과 관계 없이 스트림 시작 직후부터 반복적으로 시간 간격을 체크한다.

### `Buffer(int, int)` or `Buffer(TimeSpan, int)`
 - 정수형의 두 번째 매개변수는 `Skip`을 나타낸다.
 - 예를 들어, `Buffer(2, 3)`으로 지정한 경우, 2개의 메시지가 모이면 OnNext()를 호출하고, 이후 3개의 메시지를 모두 무시한 뒤 그다음 2개의 메시지가 모이면 다시 OnNext()를 호출한다.

### `Pairwise()`
 - 지난 메시지와 현재 메시지를 `Pair<T>` 구조체로 합성한다.
 - `.Previous`로 지난 메시지를, `.Current`로 현재 메시지를 참조할 수 있다.

</details>

<br>


<details>
<summary markdown="span"> 
스트림 합성
</summary>

### `Zip(IObservable, (a, b) => c)`
 - 두 스트림에 모두 OnNext()가 발생했을 때, 두 스트림의 메시지를 합성하여 전달한다.
 - 두 스트림 중 하나만 OnNext()가 발생하는 경우, 해당 스트림의 메시지를 큐에 차례로 보관한다.
 - 예를 들어 좌클릭과 우클릭 스트림을 합성했을 때, 좌클릭만 3번 했을 때는 아무 반응 없다가 이후 우클릭을 최대 3번까지 할 경우, n번째 좌클릭과 우클릭의 메시지를 합성하여 차례대로 전달한다.

|Index|`Left(a)`|`Right(b)`|`OnNext("${a} / {b}")`|
|:---:|:---:|:---:|:---:|
|0    |`1`  |     |     |
|1    |`2`  |     |     |
|2    |`3`  |     |     |
|3    |     |`1`  |`1 / 1`|
|4    |     |`2`  |`2 / 2`|
|5    |     |`3`  |`3 / 3`|
|6    |     |`4`  |     |

<details>
<summary markdown="span"> 
예제
</summary>

```cs
var leftMouseDownStream = this.UpdateAsObservable()
    .Where(_ => Input.GetMouseButtonDown(0));
var rightMouseDownStream = this.UpdateAsObservable()
    .Where(_ => Input.GetMouseButtonDown(1));

leftMouseDownStream
    .Select(_ => 1)
    .Scan((a, b) => a + b)
    .Zip
    (
        rightMouseDownStream
            .Select(_ => 1)
            .Scan((a, b) => a + b), 
        (a, b) => $"Left[{a}], Right[{b}]"
    )
    .Subscribe(x => Debug.Log(x));
```

</details>

<br>


### `ZipLatest(IObservable, (a, b) => c)`
 - 두 스트림에 모두 OnNext()가 발생했을 때, 두 스트림의 가장 최근 메시지를 합성하여 전달한다.
 - 두 스트림 중 하나만 OnNext()가 발생하는 경우에, 메시지들을 큐에 누적하여 보관하지 않고 가장 최근의 메시지만 갱신하며 저장한다.
 - 따라서 좌클릭과 우클릭 스트림을 합성했을 때, 좌클릭 3번 이후 우클릭을 할 경우 좌클릭 스트림에서 메시지를 하나씩 꺼내는 것이 아니라, '3번째 좌클릭과 1번째 우클릭'을 합성하여 전달한다.
 - 그리고 양측 모두에 OnNext()가 발생하여 합성 메시지를 전달한 이후, 다시 양측 모두에 OnNext()가 발생해야만 메시지를 전달한다.

|Index|`Left(a)`|`Right(b)`|`OnNext("${a} / {b}")`|
|:---:|:---:|:---:|:---:|
|0    |`1`  |     |     |
|1    |`2`  |     |     |
|2    |`3`  |     |     |
|3    |     |`1`  |`3 / 1`|
|4    |     |`2`  |     |
|5    |     |`3`  |     |
|6    |`4`  |     |`4 / 3`|

<br>


### `CombineLatest(IObservable, (a, b) => c)`
 - ZipLatest처럼 두 스트림의 가장 최근 메시지를 합성하여 전달한다.
 - ZipLatest와는 달리, 한쪽의 스트림에만 연속으로 OnNext()가 발생해도 다른쪽 스트림의 가장 최근 메시지를 계속 재활용하고 합성하여 전달한다.

|Index|`Left(a)`|`Right(b)`|`OnNext("${a} / {b}")`|
|:---:|:---:|:---:|:---:|
|0    |`1`  |     |     |
|1    |`2`  |     |     |
|2    |`3`  |     |     |
|3    |     |`1`  |`3 / 1`|
|4    |     |`2`  |`3 / 2`|
|5    |     |`3`  |`3 / 3`|
|6    |`4`  |     |`4 / 3`|

<br>


`WithLatestFrom(IObservable, (a, b) => c)`
 - CombineLatest 연산자와 매우 흡사하지만, 주체가 되는 스트림에 OnNext()가 발생했을 때만 메시지를 전달한다.
 - 주체를 `left`, 매개변수 스트림을 `right`라고 했을 때, `right` 스트림에 OnNext()가 발생한 이력이 있는 상태에서 `left` 스트림에 OnNext()가 발생할 때마다 메시지를 전달한다.

|Index|`Left(a)`|`Right(b)`|`OnNext("${a} / {b}")`|
|:---:|:---:|:---:|:---:|
|0    |`1`  |     |     |
|1    |`2`  |     |     |
|2    |     |`1`  |     |
|3    |     |`2`  |     |
|4    |`3`  |     |`3 / 2`|
|5    |     |`3`  |     |
|6    |`4`  |     |`4 / 3`|

<br>

`Amb(IObservable)`
 - 두 개의 스트림 중 먼저 OnNext()가 발생한 스트림만 유지시킨다.
 - 선택되지 못한 나머지 스트림은 즉시 종료된다.(OnCompleted() 발생 X)

`Merge(params[] IObservable)`
 - 여러 개의 스트림을 OR 연산처럼 합성한다.
 - 각 스트림의 반복, 종료 조건 등은 개별적으로 유지된다.

`Concat(params[] IObservable)`
 - 여러 개의 스트림을 차례로 연결한다.
 - 앞의 스트림이 종료(OnCompleted())될 경우, 그 다음 스트림으로 대체된다.

Catch

</details>

<br>


<details>
<summary markdown="span"> 
지연(딜레이)
</summary>

Delay

DelayFrame

TimeInterval

TimeStamp


</details>

<br>


<details>
<summary markdown="span"> 
스트림 종료 시 처리
</summary>

Repeat

RepeatSafe

RepeatUntilDisable

RepeatUntilDestroy

Finally

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
시작 ~ 종료 트리거 사이에서 매 프레임 메시지 전달
</summary>

```cs
// 시작 트리거
var beginStream = this.UpdateAsObservable()
    .Where(_ => Input.GetMouseButtonDown(0));

// 종료 트리거
var endStream = this.UpdateAsObservable()
    .Where(_ => Input.GetMouseButtonUp(0));

// 시작~종료 트리거 사이에서 매 프레임 OnNext()
this.UpdateAsObservable()
    .SkipUntil(beginStream)
    .TakeUntil(endStream)
    .RepeatUntilDisable(this)
    .Subscribe(_ => Debug.Log("Press"));
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

# Custom Observables
---

- 싱글톤을 활용하여 원하는 동작의 스트림을 직접 작성

<br>

## **목록**
 - 깔끔한 마우스 왼쪽 더블 클릭 감지

## **TODO**
 - 

## **Source Code**

<details>
<summary markdown="span"> 

</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using UniRx.Triggers;

// 날짜 : 2021-04-13 PM 5:27:28
// 작성자 : Rito

namespace Rito.UniRx
{
    public class CustomObservables : MonoBehaviour
    {
        /***********************************************************************
        *                               Singleton
        ***********************************************************************/
        #region .

        public static CustomObservables Instance
        {
            get
            {
                if(_instance == null)
                    CreateSingletonInstance();

                return _instance;
            }
        }
        private static CustomObservables _instance;

        /// <summary> 싱글톤 인스턴스 생성 </summary>
        private static void CreateSingletonInstance()
        {
            GameObject go = new GameObject("Custom Observables (Singleton Instance)");
            _instance = go.AddComponent<CustomObservables>();
            DontDestroyOnLoad(go);
        }

        /// <summary> 싱글톤 인스턴스를 유일하게 유지 </summary>
        private void CheckSingletonInstance()
        {
            if (_instance == null)
            {
                _instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else if (_instance != this)
            {
                Destroy(this);
            }
        }

        #endregion
        /***********************************************************************
        *                               Unity Events
        ***********************************************************************/
        #region .

        private float _deltaTime;

        private void Awake()
        {
            CheckSingletonInstance();
            MouseDoubleClickAsObservable = _mouseDoubleClickSubject.AsObservable();
        }

        private void Update()
        {
            _deltaTime = Time.deltaTime;
            CheckDoubleClick();
        }

        #endregion
        /***********************************************************************
        *                           Mouse Double Click Checker
        ***********************************************************************/
        #region .
        public IObservable<Unit> MouseDoubleClickAsObservable { get; private set; }
        private Subject<Unit> _mouseDoubleClickSubject = new Subject<Unit>();

        private bool _checkingDoubleClick;
        private float _doubleClickTimer;
        private const float DoubleClickThreshold = 0.3f;

        private void CheckDoubleClick()
        {
            if (Input.GetMouseButtonDown(0))
            {
                _doubleClickTimer = 0f;
                if (!_checkingDoubleClick)
                {
                    _checkingDoubleClick = true;
                }
                else
                {
                    _checkingDoubleClick = false;
                    _mouseDoubleClickSubject.OnNext(Unit.Default);
                }
            }

            if (_checkingDoubleClick)
            {
                if (_doubleClickTimer >= DoubleClickThreshold)
                {
                    _checkingDoubleClick = false;
                }
                else
                {
                    _doubleClickTimer += _deltaTime;
                }
            }
        }

        #endregion
    }
}
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