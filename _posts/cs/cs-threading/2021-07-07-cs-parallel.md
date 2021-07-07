---
title: C# Parallel
author: Rito15
date: 2021-07-07 19:07:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# Parallel 클래스
---

- 반복적인 병렬 처리를 손쉽게 작성할 수 있는 API를 제공한다.

- `ThreadPool` 기반으로 작성되어, `ThreadPool`의 현재 스레드 개수를 차지하며 최소/최대 스레드 개수에 영향을 받는다.

- `ThreadPool`의 스레드 뿐만 아니라 호출 스레드도 병렬 처리에 포함된다.

- 동기적으로 수행된다. (호출 스레드가 병렬 처리의 종료를 자동적으로 대기한다.)

<br>

# Parallel.For()
---

- `for`문의 형태와 유사하게 병렬처리를 수행할 수 있다.

<br>

## **[1] 기초**

```cs
Parallel.For(0, 100, i =>
{
    Console.WriteLine($"[{i}] {Thread.CurrentThread.ManagedThreadId}");
});
```

- 첫 번째 매개변수 : 시작 인덱스
- 두 번째 매개변수 : 종료 인덱스 + 1
- 세 번째 매개변수 : 수행할 동작

<br>

## **[2] 수행 결과 확인하기**

```cs
ParallelLoopResult result = 
    Parallel.For(0, 100, (i, state) =>
    {
        if(i > 50)
            state.Stop();

        Console.WriteLine(i);
    });

Console.WriteLine(!result.IsCompleted ? 
    result.LowestBreakIteration == null ?
    "Suspended" :
    $"Completed to {result.LowestBreakIteration.Value}" :
    "Completed"
);
```

수행 결과는 `ParallelLoopResult` 타입의 변수로 확인할 수 있다.

루프가 모두 성공적으로 실행되었으면 `.IsCompleted`는 `true`,

도중에 중단되었을 경우 `false`가 된다.

<br>

## **[3] 결과 합산하기**

```cs
// 병렬처리 결과를 받아올 변수
int sum = 0;

Parallel.For(0, 101, 

    // Func<T> : 스레드 지역 변수 초깃값 설정
    () => 0,

    // Func<T, ParallelLoopState, T, T> : 루프 동작
    (i, state, local) =>
    {
        local += i;
        return local;
    },

    // Action<T> : 개별 스레드마다 루프 종료 시 동작
    local =>
    {
        Interlocked.Add(ref sum, local);
    }
);

Console.WriteLine(sum);
```

위와 같은 형태로 작성하여

동작하는 각각의 스레드마다 로컬 변수에 한 번 결과를 합산하고,

루프가 종료되면 스레드 동기화를 이용해

공유 변수에 결과를 저장하는 형태로 병렬 처리의 최종 결과를 합산할 수 있다.

<br>

여기서는 단순 정수 계산이므로 `Interlocked`를 사용했지만,

다른 경우에도 알맞은 형태의 스레드 동기화를 적용하면 된다.

<br>

## **[4] 옵션 설정하기**

```cs
Parallel.For(0, 101,

    // 병렬처리 옵션 설정
    new ParallelOptions
    {
        MaxDegreeOfParallelism = 2
    },

    // Func<T> : 스레드 지역 변수 초깃값 설정
    () => 0,

    // Func<T, ParallelLoopState, T, T> : 루프 동작
    (i, state, local) =>
    {
        local += i;
        return local;
    },

    // Action<T> : 개별 스레드마다 루프 종료 시 동작
    local =>
    {
        Interlocked.Add(ref sum, local);
    }
);
```

위와 같이 시작, 종료 인덱스 매개변수 뒤에

`ParallelOptions` 객체로 병렬 처리 옵션을 설정할 수 있다.

<br>

- `MaxDegreeOfParallelism` : 병렬 처리에 사용될 최대 스레드 개수
- `CancellationToken` : 연결할 취소 토큰 구조체
- `TaskScheduler` : 사용할 스케줄러 객체

<br>

# Parallel.ForEach()
---

- 배열, 리스트와 같은 컬렉션에 대해 병렬 처리를 수행한다.

- 정확히는, `IEnumerable<T>`를 상속하는 모든 타입에 대해 가능하다.

<br>

## **[1] 기초**

```cs
int[] intArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

Parallel.ForEach(intArray, item =>
{
    Console.WriteLine(item);
});
```

<br>

## **[2] 수행 결과 확인하기**

```cs
int[] intArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

ParallelLoopResult result = 
    Parallel.ForEach(intArray, item =>
    {
        Console.WriteLine(item);
    });
```

- `Parallel.For()`와 동일하다.

<br>

## **[3] 결과 합산하기, 옵션 설정하기**

```cs
int[] intArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int sum = 0;

Parallel.ForEach(
    
    // 대상 컨테이너
    intArray,

    // 병렬 처리 옵션 설정
    new ParallelOptions()
    {
        MaxDegreeOfParallelism = 4
    },

    // 스레드 지역 변수 초깃값 설정
    () => 0,

    // 루프 동작
    (item, state, local) =>
    {
        local += item;
        return local;
    },

    // 루프 종료 시 동작
    local =>
    {
        Interlocked.Add(ref sum, local);
    }
);

Console.WriteLine(sum);
```

- 역시 `Parallel.For()`와 유사하다.

<br>

# Parallel.Invoke()
---

## **[1] 기초**

```cs
private static void InvokeBody()
{
    Thread.Sleep(1000);
    Console.WriteLine($"Invoke : {Thread.CurrentThread.ManagedThreadId}");
}

private static void InvokeTest()
{
    Parallel.Invoke(
        InvokeBody,
        InvokeBody,
        InvokeBody
    );
}
```

- `Action` 타입의 매개변수들을 원하는 개수만큼 넣어 병렬적으로 실행시킬 수 있다.

- 역시 따로 `.Wait()` 같은 메소드를 호출할 필요 없이 호출 스레드가 알아서 종료까지 대기한다.

<br>

## **[2] 옵션 설정**

```cs
Parallel.Invoke(

    new ParallelOptions
    {
        MaxDegreeOfParallelism = 5
    },

    InvokeBody,
    InvokeBody,
    InvokeBody
);
```

- 첫 번째 매개변수로 `ParallelOptions` 객체를 넣어 옵션을 설정할 수 있다.

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.threading.tasks.parallel?view=net-5.0>
- <https://ibocon.tistory.com/118>
- <https://jacking75.github.io/csharp_TPL/>