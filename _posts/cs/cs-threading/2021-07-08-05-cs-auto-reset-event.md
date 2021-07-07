---
title: C# AutoResetEvent
author: Rito15
date: 2021-07-08 01:05:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# 이벤트(Event) 동기화 기법
---

기존의 락과는 조금 다르게,

락을 얻고자 하는 각각의 스레드만 직접 락을 설정하고 해제할 수 있는 것이 아니라

제 3자도 락을 설정/해제할 수 있는 방식이다.

여기서 제 3자는 커널을 의미하며

커널 영역으로 요청을 보내기 때문에 다른 방식보다 성능 소모가 좀더 크다.

그리고 기존의 락 방식과 동일하게 사용될 수도 있다.

<br>

# ManualResetEvent
---

- C#에서 이벤트 동기화가 구현된 형태.

<br>

## 객체 생성

```cs
ManualResetEvent mre = new ManualResetEvent(true);
```

- 생성자에는 `bool` 타입 값으로 초기 상태를 지정할 수 있다.
- `true`는 락에 진입할 수 있다는 것을 의미한다.

<br>

## 진입 시도

```cs
mre.WaitOne();
```

- `.WaitOne()` 메소드는 임계 영역에 진입을 시도하는 것과 같다.
- 진입하지 못한 경우, 스레드는 블록된 상태로 계속 대기하게 된다.

<br>

## 락 설정

```cs
mre.Reset();
```

- `.Reset()` 메소드는 락을 설정하고 진입 불가능 상태로 만들어준다.
- 일반적인 락처럼 사용할 경우, `.WaitOne()`에 연이어 사용해야 한다.

<br>

## 락 해제

```cs
mre.Set();
```

- `.Set()` 메소드는 락을 해제하고 진입 가능 상태로 만들어준다.
- 일반적인 락처럼 사용할 경우, 임계 영역에서 작업을 끝낸 스레드가 호출한다.

<br>

## 락 구현?
- `ManualResetEvent`는 진입과 락 설정이 원자적으로 이루어지지 않으므로 일반적인 락을 구현하기는 힘들다.

<br>

# AutoResetEvent
---

`AutoResetEvent`는 `ManualResetEvent`와 유사하지만 한가지가 다르다.

`.WaitOne()`을 호출했을 때 내부적으로 `.Reset()`도 함께 호출되면서

진입에 성공했을 때 락도 함께 설정된다.

<br>

# AutoResetEvent 기반 락 작성
---

## [1] Lock 클래스 작성

```cs
class Lock
{
    // 생성자의 true : 락 진입 가능 여부
    private AutoResetEvent are = new AutoResetEvent(true);

    public void Enter()
    {
        are.WaitOne(); // 락 진입 시도 및 대기
    }

    public void Exit()
    {
        are.Set(); // 락 해제
    }
}
```

## [2] 테스트

```cs
private static readonly Lock _lock = new Lock();

private const int Count = 100000;
private static int number = 0;

private static void ThreadBody1()
{
    for (int i = 0; i < Count; i++)
    {
        _lock.Enter();
        number++;
        _lock.Exit();
    }
}

private static void ThreadBody2()
{
    for (int i = 0; i < Count; i++)
    {
        _lock.Enter();
        number--;
        _lock.Exit();
    }
}

public static void Run()
{
    Task t1 = new Task(ThreadBody1);
    Task t2 = new Task(ThreadBody2);

    t1.Start();
    t2.Start();

    Task.WaitAll(t1, t2);
    Console.WriteLine(number);
}
```

한 스레드는 락 획득 후 `number` 값을 1씩 더하고,

다른 스레드는 `number` 값을 1씩 빼는 간단한 테스트를 구성하였다.

실행 결과, `0` 값으로 성공적으로 락이 구현되었음을 알 수 있다.

<br>

하지만 아무래도 커널 영역에서 락이 작동하기 때문에

다른 락 보다는 수행 시간이 오래 걸린다는 점도 확인할 수 있었다.

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.threading.manualresetevent?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.threading.autoresetevent?view=net-5.0>


