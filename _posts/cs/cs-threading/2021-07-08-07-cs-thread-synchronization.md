---
title: C# Thread Synchronization and Locks
author: Rito15
date: 2021-07-08 01:07:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# 동기화 영역에 따른 구분
---

## **1. 유저 모드 동기화**

- 유저 객체(커널에서 제공하지 않는 객체)를 사용한다.

- 대표적으로 **크리티컬 섹션(Critical Section)**, **인터락(Interlocked)**이 있다.

- 커널 모드 동기화보다 빠르다.

- 동일 프로세스 내에서만 동기화 가능하다.

<br>

## **2. 커널 모드 동기화**

- 커널 객체를 사용한다.

- 대표적으로 **뮤텍스(Mutex), 세마포어(Semaphore), 이벤트(Event)**가 있다.

- 다른 프로세스에 존재하는 스레드 간 동기화가 가능하다.

- 유저 모드에서 커널 모드로 변경해야 하므로, 유저 모드 동기화에 비해 성능 소모가 크다.

<br>

# 동기화 방법론에 따른 구분
---

## **1. 양보(Yield)**

- 고전적인 락 기법에 해당한다.
- 락을 얻지 못할 경우, CPU 자원을 다른 스레드에 양보한다.
- Lock (Monitor)

## **2. 바쁜 대기(Busy Waiting)**

- 락을 얻을 때까지 CPU를 점유하면서 무한 대기한다.
- Spin Lock

## **3. 이벤트(Event)**

- 락을 획득 가능한 타이밍을 커널로부터 통보받는다.
- ManualResetEvent, AutoResetEvent

<br>

# Lock vs. Spin Lock
---

## **공통**

- 한 번에 하나의 스레드만 접근 가능한 영역(**Critical Section**)을 만든다.

- 하나의 스레드가 이미 영역을 점유한 경우, 진입을 원하는 다른 스레드는 대기한다.

<br>

## **Lock**

- 락을 기다리며 대기하는 스레드는 블록(Block)되며, CPU 점유를 하지 않게 된다.

- 블록될 때 CPU 자원을 다른 스레드에게 넘기므로 **컨텍스트 스위칭**으로 인한 오버헤드가 발생한다.

- 오래 걸리는 작업에 사용한다.

<br>

## **Spin Lock**

- **바쁜 대기(Busy Waiting)**가 발생한다.

- 락을 기다리는 동안에도 CPU 점유를 넘기지 않고, 계속 락 상태를 확인한다.

- 락이 길게 유지되는 동안에는 대기하는 스레드가 CPU 자원을 계속 소모하므로 낭비가 발생할 수 있다.

- **컨텍스트 스위칭**이 발생하지 않는다.

- 비교적 짧은 동작을 자주 수행해야 한다면 스핀 락을 사용하는 것이 좋다.

<br>

# C#의 동기화 방법 정리
---

## **[1] Interlocked**

 - 특정 변수에 대해 동기화 및 원자적 연산을 수행한다.

<br>

## **[2] Monitor**

 - 크리티컬 섹션을 만들고(진입하고), 해제한다.

 - `object` 타입 매개체가 필요하다.

 - `Monitor.Enter(obj)` ~ `Monitor.Exit(obj)`

 - 크리티컬 섹션 내부에서 예외가 발생했을 경우를 위한 `try-finally` 처리가 필요하다.

<br>

## **[3] lock 구문**

 - 내부적으로 Monitor 객체를 이용해 크리티컬 섹션을 만든다.

 - `lock(obj) { ~ }`

<br>

## **[4] SpinLock**

 - 직접 구현하거나 `SpinLock` 클래스를 사용한다.

 - 락 진입/해제의 간격이 짧고 빈번한 경우에 사용한다.

 - `try-finally` 처리가 필요하다.

<br>

## **[5] ReaderWriterLock**

 - 직접 구현하거나, `ReaderWriterLock` 또는 `ReaderWriterLockSlim` 클래스를 사용한다.

 - 읽기 스레드와 쓰기 스레드의 역할이 구분되는 경우에 사용한다.

 - 자주 읽고, 가끔 쓰는 경우에 사용하면 좋다.

 - `try-finally` 처리가 필요하다.

<br>

## **[6] ManualResetEvent, AutoResetEvent**

 - 크리티컬 섹션에 진입하려는 스레드끼리 락을 공유하는 lock 방식처럼 사용할 수 있고,<br>
   해당 락에 관련 없는 다른 스레드가 락의 설정/해제를 관리할 수도 있다.

 - 다수의 스레드의 임계 영역 진입 관리를 해야 할 때 사용한다.

 - 커널 영역 동기화이므로 성능을 고려해야 한다.

<br>

## **[7] Mutex**

 - 커널 영역에서의 동기화를 수행하므로 비교적 느리다.

 - 프로세스 간의 데이터 동기화가 필요한 경우 사용한다.

<br>

## **[8] Semaphore**

 - 커널 영역에서의 동기화를 수행하므로 비교적 느리다.

 - 프로세스 간의 데이터 동기화가 필요한 경우 사용한다.

 - 다수의 프로세스 또는 스레드가 동시에 크리티컬 섹션에 진입하도록 할 수 있다.

<br>

# 최종 정리 : 스레드 동기화 방법 선택
---

## **[1] Interlocked**

- 공유 변수에 대해 원자적으로 읽고, 쓰고, 더하는 경우 간단히 사용할 수 있다.

```cs
private static int location = 0;
private const int Expected = 1, Desired = 2;

public static void Example()
{
    // 값을 하나 증가시키고, 결과값을 리턴한다.
    int res1 = Interlocked.Increment(ref location);

    // 값을 하나 감소시키고, 결과값을 리턴한다.
    int res2 = Interlocked.Decrement(ref location);

    // 값을 더하고, 결과값을 리턴한다.
    int res3 = Interlocked.Add(ref location, 100);

    // 값을 초기화 하고, 바뀌기 전의 값을 리턴한다.
    int res4 = Interlocked.Exchange(ref location, 100);

    // location의 값이 Expected였을 경우 Desired로 초기화한다.
    // 아닐 경우 초기화하지 않는다.
    // 초기화 이전에 location이 갖고 있던 값을 리턴한다.
    int res5 = Interlocked.CompareExchange(ref location, Desired, Expected);
}
```

<br>

## **[2] lock 구문**

- 락을 걸고 짧지 않은 동작들을 수행하는 경우에 사용한다.

- 간편히 `lock(){}` 구문을 사용하면 된다.

```cs
private readonly object _lock = new object();

private void ThreadBodyMethod()
{
    lock (_lock)
    {
        // Do Something
    }
}
```

<br>

## **[3] SpinLock 클래스**

- 락을 빈번하게 걸고 짧은 동작들을 수행하는 경우에 사용한다.

- `try-finally` 처리가 필요하다.

```cs
private SpinLock spinLock = new SpinLock();

private void ThreadBodyMethod()
{
    bool lockTaken = false; // 락을 획득했는지 여부
    try
    {
        spinLock.Enter(ref lockTaken);

        // Do Something Here =========

        // ===========================
    }
    finally
    {
        if (lockTaken)
        {
            spinLock.Exit();
        }
    }
}
```

<br>

## **[4] ReaderWriterLockSlim 클래스**

- 자주 읽어들이지만 쓰기 수행이 적은 경우에 사용한다.

- 소수의 쓰기 스레드, 다수의 읽기 스레드로 나뉜 경우에 사용하면 좋다.

- `try-finally` 처리가 필요하다.

```cs
private ReaderWriterLockSlim rwLock = new ReaderWriterLockSlim();

private void WriterThreadBody()
{
    try
    {
        rwLock.EnterWriteLock();

        // Do Something Here =========

        // ===========================
    }
    finally
    {
        rwLock.ExitWriteLock();
    }
}

private void ReaderThreadBody()
{
    try
    {
        rwLock.EnterReadLock();

        // Do Something Here =========

        // ===========================
    }
    finally
    {
        rwLock.ExitReadLock();
    }
}
```

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/threading/overview-of-synchronization-primitives>
- <https://mtding00.tistory.com/47>
- <https://iteenote.tistory.com/118>
- <https://brownbears.tistory.com/45>
- <https://3dmpengines.tistory.com/611>
- <https://rammuking.tistory.com/entry/Lock-종류-및-설명>