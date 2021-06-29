---
title: 워커 스레드에서 메인 스레드에 작업 요청하기
author: Rito15
date: 2021-06-30 01:11:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, mainthreaddispatcher]
math: true
mermaid: true
---

# 삽질
---
- 문득 떠오른 순수한 호기심에 삽질해보는 포스팅입니다.
- 의식의 흐름에 따라 작성합니다.

<br>

# 목표
---
- 워커 스레드에서 메인 스레드에 작업 요청하고, 결과를 기다렸다가 받아서 처리하기

<br>

# 배경지식
---

- 메인 스레드가 아닌, 다른 스레드들을 워커 스레드(Worker Thread, 작업자 스레드)라고 부른다.

- 유니티 API(트랜스폼, 컴포넌트, 게임오브젝트, ...)의 호출은 메인 스레드에서만 가능하다.

- 워커 스레드에서 유니티 API를 호출하면 `UnityException`이 호출되면서 해당 작업이 거부된다.

- 멀티 스레드 작업에서는 읽고 쓰는 작업에 대해 반드시 동기화를 수행해야 한다.

- 동기화를 하지 않으면 잘못된 값을 참조하거나, 복제되거나, 의도치 않은 다양한 모습을 볼 수 있다.

<br>

# 서론
---

다른 스레드에서 유니티 API 호출을 해야 하는 경우,

사실 메인 스레드 디스패처(Main Thread Dispatcher)라는 녀석을 만들어서

거기에 요청을 하는 방식을 사용하면 된다.

<https://github.com/PimDeWitte/UnityMainThreadDispatcher>

이런 것도 있고, UniRx에도 디스패처가 있고

동작만 이해하면 구현하기도 그렇게 어렵지는 않다.

<br>

그런데 이건 워커 스레드에서 메인 스레드에 "해줘"라고만 할 뿐이지

해당 작업이 언제 수행되는지, 언제 완료되는지 추적할 수는 없다.

물론 콜백으로 `isCompleted = true;`를 담아서 보내면 되기는 하겠지만

매번 하드코딩이 필요하므로 우아하지 않다.

그래서 이 기능을 해줄 수 있는 디스패처를 만들어본다.

그리고 모두 `Task`를 기반으로 작성할 것이다.

<br>

# 기능 구현
---

## [1] 테스트 작업 형태 구현

```cs
private void Start()
{
    Task.Run(() => JobTest(1000));
}

private async Task JobTest(int delay = 1000)
{
    Debug.Log("ID : " + Thread.CurrentThread.ManagedThreadId);

    int result = 0;
    try
    {
        // Do Something Busy..
        await Task.Delay(delay);

        result = UnityEngine.Random.Range(1, 1000);
        transform.position = Vector3.one * result;
    }
    catch (Exception e)
    {
        Debug.Log(e.Message);
    }

    // 작업 결과 확인
    Debug.Log($"Random Int : {result}");
}
```

간단히 위와 같은 작업을 워커 스레드에서 수행시켜본다.

당연히

![image](https://user-images.githubusercontent.com/42164422/123839980-c3c0d780-d948-11eb-85fc-123adcb58306.png)

이런 결과를 얻을 수 있다.

<br>

## [2] 구현 목표 재확인

구현 목표를 다시 확인해보면 다음과 같다.

- 워커 스레드에서 메인 스레드에 작업을 요청하고

- 워커 스레드는 메인 스레드의 작업 완료를 기다리고

- 메인 스레드는 이 작업을 수행하고 완료 여부를 알려주면

- 워커 스레드가 이 결과를 받아서 다시 흐름을 이어나가는데

- 동기화도 꼭 해줘야 한다.

<br>

워커 스레드에서 메인 스레드에 작업을 요청하고 처리하기 위해 큐를 사용할 것이다.

그리고 마침 C#에서 제공하는 좋은 것이 있다.

바로 `ConcurrentQueue<T>`이다.

```cs
// 네임스페이스 필요
//using System.Collections.Concurrent;

private readonly ConcurrentQueue<Action> jobQueue = new ConcurrentQueue<Action>();
```

`ConcurrentQueue<T>`는 스레드 안전성을 보장한다고 하니

```cs
lock(_queue)
{
    _queue.DoSomething();
}
```

이런걸 굳이 안해줘도 된다.

아마 내부에서 예쁘게 해줄 것 같다.

<br>

`T`에 들어가는 `Action`은 물론 워커 스레드가 메인 스레드에 요청할 작업을 의미한다.

그런데 해당 작업의 완료 여부도 깔끔하게 받아올 수 있어야 하므로

```cs
class Job
{
    public Action job;
    public bool completed;
}
```

대략 이런 형태로 묶어준다.

가비지가 발생하지 않게 `struct`로,

그것도 `readonly struct`로 구현하면 예쁘겠지만

워커 스레드가 메인 스레드에 작업을 던져주고, 다시 확인하는 과정을 거칠 것이므로

GC에게는 미안하지만 클래스로 작성한다.

<br>

## [3] Job 클래스 작성

그런데 `Job`이라는 이름은 너무 일반적이고

해당 작업을 처리할 주체는 메인 스레드니까

`MainThreadJob` 정도로 이름을 바꿔서 구현해준다.

`JobForMainThread`도 생각했지만 이건 너무 설명적인 느낌이다.

<br>

```cs
/// <summary> 메인 스레드에서 처리할 작업 </summary>
private class MainThreadJob
{
    private static readonly ReaderWriterLockSlim rwLock;
    private readonly Action job;
    private volatile bool completed;

    static MainThreadJob()
    {
        rwLock = new ReaderWriterLockSlim();
    }

    public MainThreadJob(Action job)
    {
        this.completed = false;
        this.job = job;
    }

    /// <summary> 메인 스레드에서 호출 : 작업 수행 </summary>
    public void Run()
    {
        // 작업 실행
        job?.Invoke();

        // 작업 종료 통지
        rwLock.EnterWriteLock();
        completed = true;
        rwLock.ExitWriteLock();
    }

    /// <summary> 워커 스레드에서 호출 : 작업 완료 대기 </summary>
    public async Task Wait(int timeoutMS = 100)
    {
        while (true)
        {
            // 작업 종료 여부 확인
            rwLock.EnterReadLock();
            bool flag = completed;
            rwLock.ExitReadLock();

            // 작업 종료시 탈출
            // 미종료시 대기
            if (flag) break;
            else await Task.Delay(timeoutMS);
        }
    }
}
```

락을 구현하는 방법은 다양하다.

`Interlocked`, `Monitor`, `lock(){}`, `AutoResetEvent`, `Mutex`, `Semaphore`, ...

그런데 락이 필요한 부분은 `completed` 필드이고,

워커 스레드는 이 값을 읽기만 하고

메인 스레드는 이 값에 쓰기만 수행하므로

`ReaderWriterLockSlim`을 이용한다.

그리고 해당 객체가 Job마다 생성되지는 않도록, `static`으로 만들어준다.

<br>

`Run()` 메소드는 메인 스레드가 호출한다.

메인 스레드에서 작업을 수행하고, WriterLock을 걸고 작업 완료 여부를 통지한다.

그리고 워커 스레드는 ReaderLock을 걸고 작업 완료 여부를 확인한다.

<br>

근데 아무리 생각해봐도 각각의 Job은 메인스레드와 워커스레드 하나씩만 접근한다.

그러니까 애초에 `completed`가 `false`로 시작해서

메인 스레드가 접근해서 `true`로 바꿔주기만 하면 되는 일이고,

여기서 메인 스레드가 `true`로 쓰는 작업과 워커 스레드가 이걸 읽는 작업이

동시에 수행되더라도 딱히 문제가 없다.

워커 스레드는 어쨌든 이 값이 `false` -> `true`로 변하는 타이밍만 캐치하면 된다.

<br>

결국 중요한 것은 메인 스레드와 워커 스레드가 작업을 주고받을 큐가 동기화 되는 것이지,

저기서 동기화시키는 것은 불필요하다는 것이 결론.

그래서 다이어트를 시켜보니

<br>

```cs
/// <summary> 메인 스레드에서 처리할 작업 </summary>
private class MainThreadJob
{
    private readonly Action job;
    private volatile bool completed;

    public MainThreadJob(Action job)
    {
        this.completed = false;
        this.job = job;
    }

    /// <summary> 메인 스레드에서 호출 : 작업 수행 </summary>
    public void Run()
    {
        // 작업 실행
        job?.Invoke();

        // 작업 종료 통지
        completed = true;
    }

    /// <summary> 워커 스레드에서 호출 : 작업 완료 대기 </summary>
    public async Task Wait(int timeoutMS = 100)
    {
        while (true)
        {
            // 작업 종료시 탈출
            // 미종료시 대기
            if (completed) break;
            else await Task.Delay(timeoutMS);
        }
    }
}
```

이렇게 깔끔해졌다.

그리고 큐의 제네릭 인수를 `MainThreadJob`으로 바꿔준다.

```cs
private readonly ConcurrentQueue<MainThreadJob> jobQueue
    = new ConcurrentQueue<MainThreadJob>();
```

<br>

## [4] 메인 스레드에서 작업 처리

업데이트로 해도 되고, 코루틴으로 해도 된다.

코루틴으로 작성해본다.

```cs
private IEnumerator MainThreadJobProcessor()
{
    while (true)
    {
        if (jobQueue.TryDequeue(out MainThreadJob job))
        {
            job.Run();
            Debug.Log($"Processed");
        }

        yield return null;
    }
}
```


큐에 작업이 있으면 받아와서 처리하고 없으면 해당 프레임을 넘기는 방식으로 구현한다.

큐에 작업이 있는 동안 모두 꺼내서 작업해도 되고,

위에서 소개했던 메인 스레드 디스패처의 방식으로

각각의 작업을 개별 코루틴으로 넘겨서 실행해도 되지만

일단은 이렇게 한 프레임에 하나씩 수행시킨다.

<br>

## [5] 테스트

```cs
private void Start()
{
    StartCoroutine(MainThreadJobProcessor());
    
    Task.Run(() => JobTest(2000));
    Task.Run(() => JobTest(1500));
    Task.Run(() => JobTest(1200));
    Task.Run(() => JobTest(1500));
    Task.Run(() => JobTest(1200));
}
```

![image](https://user-images.githubusercontent.com/42164422/123844540-2072c100-d94e-11eb-91b8-87a4a24cb27c.png)

원하는 대로 구현됨을 확인하였다.

<br>

# 메인 스레드 디스패처 작성
---

하려고 했는데

깃헙의 메인 스레드 디스패처에 `EnqueueAsync()` 메소드가 이미 다 해주므로

중단


<br>

# Source Code
---



