---
title: C# 비동기 Task를 사용하면서 흔히 발생하는 실수
author: Rito15
date: 2021-09-04 04:09:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# Mistake
---

```cs
private static void Main()
{
    Task t = Task.Run(() => TaskBody(3));

    t.Wait(); // TaskBody(3)의 종료를 대기하려고 시도

    Console.WriteLine("End");
}

static async void TaskBody(int count)
{
    for (int i = 0; i < count; i++)
    {
        await Task.Delay(500);
        Console.WriteLine($"[{i}] Thread : {Thread.CurrentThread.ManagedThreadId}");
    }
}
```

위의 소스 코드는 얼핏 보면 문제가 없어 보인다.

하지만 실제로 실행하면 `t.Wait()` 부분에서 원하는 대로 대기가 되지 않는 것을 알 수 있다.

<br>

# Reason
---

`Task.Run(Action)` 메소드는 실행할 메소드 핸들을 받아

스레드풀의 큐에 집어넣고 실행시킨다.

그리고 이 `Action`의 종료를 대기할 수 있는 `Task`를 리턴한다.

여기서 이미 힌트가 있다.

`Action`의 종료를 대기할 수 있다는 것은,

`Action`의 로직 자체는 동기적으로 수행되어야 한다는 것이다.

<br>

그리고 위의 코드에서 이 `Action`을 살펴보면 다음과 같다.

`() => { TaskBody(3); }`

실행 블록만 떼어 늘여보면 다음과 같다.

```cs
{
    TaskBody(3);
}
```

`TaskBody` 메소드는 `async void`로 비동기 메소드이다.

그러니까 이 메소드 호출 `TaskBody(3);`은 호출자 스레드 내에서

비동기적으로(**Concurrently**) 수행된다.

<br>

이제 위의 실행 블록을 다시 살펴보면 흐름을 다음과 같이 두 개로 분리할 수 있다.

```cs
// [1] 메인 흐름
{
}

// [2] 분기된 비동기 흐름
TaskBody(3);
```

그러니까 `TaskBody(3);` 자체를 `Action`에 꽂아 넣어봐야

`Action`의 메인 흐름에서 분리되어 비동기적으로 수행된다는 것이다.

<br>

다시 `Task.Run(() => TaskBody(3))`을 살펴보면,

`Task.Run(Action)`은 `Action`의 종료를 대기할 수 있는 핸들을 제공하는데

`TaskBody(3)`은 여기에서 `Action`의 메인 흐름과 별개로 떨어져 나가므로

`Task t = Task.Run(...)`에서 얻어낸 `t`를 기다려봐야,

시작하자마자 대기가 끝나는 것이다.

<br>

# Solution 1
---

```cs
static async Task TaskBody(int count)
{
    for (int i = 0; i < count; i++)
    {
        await Task.Delay(500);
        Console.WriteLine($"[{i}] Thread : {Thread.CurrentThread.ManagedThreadId}");
    }
}
```

`async void TaskBody(int)`에서 `void`를 `Task`로 바꾼다.

이렇게 되면 `TaskBody` 메소드 자체가 대기 가능한 `Task`를 리턴한다.

그리고 `Task.Run(Action)` 대신 `Task.Run(Func<Task>)` 메소드로 이를 받아주게 되고,

`Task.Run(Func<Task>)`메소드는 내부의 `Func<Task>` 실행을 대기할 수 있는 `Task`를 리턴하게 된다.

그리고 여전히 `TaskBody` 메소드는 비동기 메소드이므로,

해당 메소드의 작업을 수행할 스레드가 이미 동기적으로 다른 작업을 하고 있더라도

**Concurrent**하게 함께 처리할 수 있다.

이런 것까지 고려하고 있었다면 완벽히 원하던 목표인 셈이다.

<br>

# Solution 2
---

```cs
static void TaskBody(int count)
{
    for (int i = 0; i < count; i++)
    {
        Thread.Sleep(500);
        Console.WriteLine($"[{i}] Thread : {Thread.CurrentThread.ManagedThreadId}");
    }
}
```

비동기 키워드를 모두 지워버린다.

그리고 `await Task.Delay()` 대신 `Thread.Sleep()`을 사용한다.

이렇게 되면 정석적인 스레드 바디로서 사용되고

**Concurrent**가 아닌, **Parallel**한 실행이므로

해당 스레드에서는 동시에 다른 작업을 수행할 수 없지만

`Action`의 메인 흐름과 함께 동작하므로, 대기할 수 있게 된다.




