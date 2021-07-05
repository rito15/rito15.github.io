---
title: C# async Task
author: Rito15
date: 2021-07-06 03:34:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# 비동기 작업 : async-await
---

- `Task`를 `Thread`처럼 사용하는 대신, 비동기 작업을 위해 사용할 수 있다.

- `async`, `await` 키워드를 이용해 이루어지는 비동기 작업은 기존의 멀티 스레딩과는 다른 방식으로 이루어진다.

<br>

## **특징**

- 메소드 내부에서 `await`로 대기하려면, 해당 메소드의 리턴 타입 앞에 `async` 키워드를 작성한다.

- `await Task.Delay(n)`와 같이 `await`를 이용한 대기는 해당 스레드를 블록시키지 않는다.

- 비동기 작업을 기다리고, 끝날 경우 값을 리턴받을 수 있다.

- `async-await`로 실행 시킨 작업 역시 `ThreadPool`에 의해 관리된다.

<br>

## **작업이 실행되는 스레드 환경**

**WinForm**, **WPF**, **Unity Engine**과 같이 메인 스레드에서 UI 작업이 이루어지는 프로그램은 await가 실행되기 전에 당시 실행되고 있는 스레드를 캡쳐하여 `SynchronizationContext.Current`에 저장한다.

그리고 `await` 이후의 문장들을 캡쳐된 스레드에서 실행시킨다.

그런데 콘솔, 윈도우 서비스 프로그램 같은 경우에는 `SynchronizationContext.Current`를 `null`로 둔다.

그리고 `await` 이후의 문장들을 `ThreadPool`에서 제공하는 스레드 내에서 실행시킨다.

<br>

정리하자면,

- `await` 이전의 문장들은 호출 스레드에서 실행된다.

- **UI**가 존재하는 프로그램에서는 `await` 이후 문장들을 호출 스레드에서 실행시키도록 보장한다.

- 콘솔, 윈도우 서비스의 경우에는 `await` 이후 문장들을 `ThreadPool`에서 제공하는 스레드에서 실행시킨다.

- 그런데 애초에 `Task.Run()` 또는 `new Task().Start()`로 실행시켰으면 모두 `ThreadPool`의 스레드에서 실행된다.

```cs
private async Task ContextExample()
{
    Console.WriteLine($"Thread ID-A : {Thread.CurrentThread.ManagedThreadId}");
    await Task.Delay(1);
    Console.WriteLine($"Thread ID-B: {Thread.CurrentThread.ManagedThreadId}");
}

public void MainMethod()
{
    ContextExample().Wait();
    // ID-A : 1 (메인 스레드)
    // ID-B : 스레드풀에서 제공

    Task.Run(ContextExample).Wait();
    // ID-A : 스레드풀에서 제공
    // ID-B : 스레드풀에서 제공
}
```

<br>

# 1. 대기할 수 없는 작업
---

- `async void` 타입은 비동기로 시작되고, 의도적으로 대기할 수 없다.

```cs
private async void TaskAsync(int n)
{
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(500);
        Console.WriteLine($"Task : {i}");
    }
}

private void MainMethod()
{
    TaskAsync(10);
    Thread.Sleep(10_000);
}
```

<br>

# 2. 대기할 수 있는 작업
---

- `async Task` 타입은 비동기로 시작되며 `async void`와 마찬가지로 작업의 결과를 받아올 수는 없다.

- `Task` 타입을 리턴하며, 이를 통해 작업을 대기할 수 있다.

```cs
private async Task TaskAwaitable(int n)
{
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(100);
        Console.WriteLine($"Task : {i}");
    }
}

private void MainMethod()
{
    // 체인으로 대기
    TaskAwaitable(10).Wait();

    // 객체로 받아 대기
    Task t = TaskAwaitable(10);
    t.Wait();
}
```

<br>

# 3. 값을 리턴하는 작업
---

- 값을 리턴하는 비동기 메소드는 `Task<리턴타입>` 꼴로 리턴 타입을 지정한다.

- 비동기 메소드의 결과를 `.Result`와 같이 참조하려고 하는 경우, 결과를 얻을 때까지 대기하여 해당 지점에서 흐름이 일시 중단된다.

```cs
private async Task<int> TaskAsyncAndReturn()
{
    int sum = 0;
    for (int i = 0; i < 10; i++)
    {
        await Task.Delay(100);
        sum += i;
    }
    return sum;
}

private void MainMethod()
{
    Task<int> task = TaskAsyncAndReturn();
    Console.WriteLine(task.Result); // 결과를 얻을 때까지 대기
    Console.WriteLine("End");
}
```

<br>

- `.Wait()` 메소드를 통해 의도적으로 결과를 기다리며 흐름을 중단시킬 수도 있다.

```cs
private void MainMethod()
{
    Task<int> task = TaskAsyncAndReturn();
    task.Wait(); // 결과를 얻을 때까지 대기

    // -> 결과를 .Result로 참조하는 대신, .Wait()를 통해 대기 가능

    Console.WriteLine("End");
}
```

<br>

- `.Wait()` 이전에 다른 작업 또한 실행시켰다면, 해당 작업도 병렬적으로 수행된다.

```cs
private async Task<int> TaskAsyncAndReturn(int n)
{
    int sum = 0;
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(100);
        sum += i;
    }
    return sum;
}

// 동시에 여러 작업을 실행시키는 경우
private void MainMethod()
{
    Task<int> task1 = TaskAsyncAndReturn(10);  // 작업 1 시작
    Task<int> task2 = TaskAsyncAndReturn(20);  // 작업 2 시작

    // 작업1, 작업2 실행 중

    task1.Wait();                    // 작업 1 대기
    Console.WriteLine("End 1");

    // 작업 2 실행 중

    Console.WriteLine(task2.Result); // 작업 2 대기
    Console.WriteLine("End 2");
}

// 한 번에 하나의 작업씩 실행시키는 경우
private void MainMethod2()
{
    Task<int> task1 = TaskAsyncAndReturn(10);  // 작업 1 시작

    task1.Wait();                              // 작업 1 대기

    // 작업1 실행 중

    Console.WriteLine("End 1");

    Task<int> task2 = TaskAsyncAndReturn(20);  // 작업 2 시작

    // 작업 2 실행 중

    Console.WriteLine(task2.Result);           // 작업 2 대기
    Console.WriteLine("End 2");
}
```

<br>

# 4. 작업의 연계
---

## **완료 시 수행할 동작 등록하기**

- `Task` 수행 종료 시 동작을 `.ContinueWith()` 메소드를 통해 등록할 수 있다.

```cs
private async Task TaskAwaitable(int n)
{
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(100);
        Console.WriteLine($"Task : {i}");
    }
}

public void MainMethod()
{
    Task t = TaskAwaitable(5);
    t.ContinueWith(x => Console.WriteLine("END 1"));
    t.ContinueWith(x => Console.WriteLine("END 2"));
    t.ContinueWith(x => Console.WriteLine("END 3"));

    t.Wait();
}
```

<br>

- `.ContinueWith()` 메소드는 `Task` 타입을 리턴하므로, 체인으로 이어갈 수도 있다.

```cs
public void MainMethod()
{
    TaskAwaitable(8)
        .ContinueWith(_ => Console.WriteLine("End 1"))
        .ContinueWith(_ => Console.WriteLine("End 2"))
        .ContinueWith(_ => Console.WriteLine("End 3"))
        .Wait();
}
```

<br>

## **완료 즉시 결과 전달하기**

- `Task<TResult>` 꼴로 리턴 값이 존재하는 경우, `.ContinueWith()`를 이용해 완료 시 결과를 비동기적으로 전달할 수 있다.

```cs
private async Task<int> TaskAsyncAndReturn(int n)
{
    int sum = 0;
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(100);
        sum += i;
    }
    return sum;
}

public void MainMethod()
{
    TaskAsyncAndReturn(10)
        .ContinueWith(x => Console.WriteLine($"Result : {x.Result}"))
        .Wait();
}
```

<br>

# 5. await를 통한 또 다른 작업의 대기
---

- `async`로 선언된 메소드 내부에서 `await`를 통해 또다른 `Task`를 대기할 수 있다.

```cs
private async Task SomeTask()
{
    await Task.Delay(500);
}

private async Task TaskInTask()
{
    await SomeTask(); // 다른 async 메소드 실행 및 대기
}
```

<br>

- 매개변수로 또다른 비동기 메소드를 전달받아 대기할 수도 있다.

```cs
// 1. 매개변수로 전달받는 메소드의 리턴이 단순 Task인 경우
private async Task TaskInTask(Func<Task> insideTaskFunc)
{
    Console.WriteLine("Task Start - 1");
    await insideTaskFunc();
    Console.WriteLine("Task End - 1");
}

// 2. 매개변수로 전달받는 메소드의 리턴 값이 존재하는 경우
private async Task TaskInTask<T>(Func<Task<T>> insideTaskFunc)
{
    Console.WriteLine("Task Start - 2");
    T insideResult = await insideTaskFunc();
    Console.WriteLine($"Task End - 2 => Result : {insideResult}");

    // 이것도 가능
    //Console.WriteLine($"Result : {await insideTaskFunc()}");
}

public void MainMethod()
{
    Task t1 =
        TaskInTask(async () =>
        {
            Console.WriteLine("Inside Start - 1");
            await Task.Delay(1000);
            Console.WriteLine("Inside End - 1");
        });

    Task t2 =
        TaskInTask(async () =>
        {
            Console.WriteLine("Inside Start - 2");
            await Task.Delay(2000);
            Console.WriteLine("Inside End - 2");

            return 123;
        });

    Task.WaitAll(t1, t2);
}
```

<br>

# 6. 여러 Task를 묶어서 처리하기
---

## **[1] WaitAll**

- 인자로 전달한 모든 `Task`가 종료될 때까지 대기한다.

```cs
private async Task TaskAwaitable(int n)
{
    for (int i = 0; i < n; i++)
    {
        await Task.Delay(100);
        Console.WriteLine($"Task : {i}");
    }
}

public void MainMethod()
{
    Task t1 = TaskAwaitable(5);
    Task t2 = TaskAwaitable(10);

    Task.WaitAll(t1, t2);
}
```

<br>

## **[2] WaitAny**

- 인자로 전달한 `Task` 중 하나라도 종료될 때까지 대기한다.

```cs
public void MainMethod()
{
    Task t1 = TaskAwaitable(5);
    Task t2 = TaskAwaitable(10);

    Task.WaitAny(t1, t2);
}
```

<br>

## **[3] WhenAll**

- 인자로 전달한 `Task`들을 한데 묶어서 하나의 `Task`로 관리한다.

- 상태, 예외를 종합하여 확인할 때 사용된다.

- 등록된 모든 `Task`가 완료되면 `WhenAll()`이 리턴한 `Task`도 완료된다.

```cs
public void MainMethod()
{
    Task t1 = TaskAwaitable(5);
    Task t2 = TaskAwaitable(10);

    Task tAll = Task.WhenAll(t1, t2);

    Console.WriteLine(tAll.Status); // Waiting For Activation

    tAll.Wait(); // 모두 종료될 때까지 대기

    Console.WriteLine(tAll.Status); // Ran To Completion
}
```

<br>

## **[4] WhenAny**

- 등록된 `Task` 중 하나라도 완료되면 `WhenAll()`이 리턴한 `Task`도 완료된다.

```cs
public void MainMethod()
{
    Task t1 = TaskAwaitable(5);
    Task t2 = TaskAwaitable(10);

    Task tAny = Task.WhenAny(t1, t2);
    tAny.Wait(); // 하나라도 종료될 때까지 대기
}
```

<br>

# 7. 완료 여부 추적하기 : TaskCompletionSource
---

어떤 작업을 대기할 API가 제공되지 않는 경우가 있다.

예를 들어

```cs
public async void SomeTask()
{
    Console.WriteLine("Task Begin");
    await Task.Delay(1000);
    Console.WriteLine("Task End");
}
```

이런 `async void` 메소드가 있을 때, 이 메소드는 그저 비동기적으로 실행만 할 수 있고 대기할 수는 없다.

이럴 때 매개변수로 `TaskCompletionSource`를 이용하여 완료 여부를 직접 설정하고 대기할 수 있다.

<br>

```cs
public async void SomeTask(TaskCompletionSource<bool> tcs)
{
    Console.WriteLine("Task Begin");
    await Task.Delay(1000);
    Console.WriteLine("Task End");

    // tcs의 Task를 완료 처리(RanToCompletion 상태로 전환)
    tcs.SetResult(true);
}

public void MainMethod()
{
    TaskCompletionSource<bool> tcs = new TaskCompletionSource<bool>();

    SomeTask(tcs);

    tcs.Task.Wait();
}
```

위와 같이 `TaskCompletionSource` 객체를 미리 만들어서 메소드에 제공하고,

해당 비동기 메소드 내에서는 작업이 끝난 후 `.SetResult()` 메소드를 통해

작업 완료 처리를 할 수 있다.

그리고 이를 대기할 스레드 내에서는 해당 객체의 `.Task`를 참조하여 대기할 수 있다.

<br>

# 간단 정리
---

## **비동기 메소드의 형태**

### **[1] 대기 불가능**

```cs
private async void Method()
{
    await Something();
}
```

### **[2] 대기 가능**

```cs
private async Task Method()
{
    await Something();
}
```

### **[3] 대기 가능 및 값 리턴**

```cs
private async Task<int> Method()
{
    // (1) 차근차근
    int result = await Something();
    return result;

    // (2) 호출 + 대기 + 결과 받기 + 리턴
    return await Something();
}
```

<br>

## **대기**

### **[1] 비동기 메소드에서 비동기 메소드 대기**

```cs
private async Task Method()
{
    await Something();
}

private async void Main()
{
    Task t = Method();
    await t;
}
```

### **[2] 동기 메소드에서 비동기 메소드 대기**

```cs
private async Task Method()
{
    await Something();
}

private void Main()
{
    Task t = Method();
    t.Wait();
}
```

<br>

## **API**

`Task.Delay(int)`
 - `async` 메소드 내에서 호출하며, `await` 키워드를 통해 지정한 시간(ms)을 대기한다.

<br>

`.Wait()`
 - 실행 환경에서 비동기 작업을 대기한다.

<br>

`Task.WaitAll(params[] Task)`
 - 실행 환경에서 비동기 작업들이 모두 종료되기를 기다린다.

<br>

`.ContinueWith(Action<Task>)`
`.ContinueWith<T>(Func<Task, T>)`
 - 해당 비동기 작업 종료 시 연계될 작업을 등록한다.

<br>

`TaskCompletionSource<T>`
 - 작업의 대기가 불가능한 경우, 대기를 위한 매개체가 된다.
 - 작업 내에서 `tcs.SetResult(T)`를 통해 완료 상태를 통지한다.
 - 대기할 환경에서 `await tcs.Task`를 통해 완료 여부를 추적하고 대기할 수 있다.

<br>

# References
---
- <https://www.csharpstudy.com/CSharp/CSharp-async-await.aspx>
- <https://blog.naver.com/vactorman/220371896727>