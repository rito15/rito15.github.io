# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# Reader Writer Lock 개념
---

스레드 간에 공유되는 데이터가 있을 때,

항상 모든 스레드가 그 데이터를 읽고 쓰는 것은 아니다.

어떤 스레드는 해당 데이터를 읽기만 하고,

어떤 스레드는 해당 데이터를 쓰기만 하는 구조로 이루어져 있을 수 있다.

그리고 소수의 쓰기 스레드가 상대적으로 적은 횟수로 쓰기를 수행하고,

다수의 읽기 스레드가 상대적으로 빈번하게 읽기를 수행하는 경우가 많다.

<br>

이런 경우에도 일반적인 락을 구현하여 읽기/쓰기를 수행하는 동안에 항상 락을 설정하고 해제한다면

데이터를 단순히 읽기만 하여 값이 변경되지 않는 상황에도 불필요하게 임계 영역을 만들게 되므로

성능상 굉장히 손해라고 할 수 있다.

<br>

**ReaderWriterLock**은 데이터에 쓰기 위해 접근할 때는 락을 설정하고,

데이터를 단순히 읽기만 하는 동안에는 락을 설정하지 않도록 비대칭적인 락을 구현함으로써

위의 경우 성능상 이득을 얻을 수 있도록 한다.

<br>

# ReaderWriterLockSlim 클래스
---

- C#에는 이미 클래스로 사용하기 편리하게 구현되어 있다.

- `ReaderWriterLock`, `ReaderWriterLockSlim` 클래스가 구현되어 있으며, 후자가 최신버전이므로 이를 사용하면 된다.

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

# Reader Writer Lock 설계
---

- ReaderWriterLock을 직접 구현하기 위해, 미리 필요한 구조와 개념을 정리한다.

<br>

## **[1] 정책 설정**
  
- **스핀락 정책**
  - 기본적으로 락은 스핀락으로 구현한다.
  - 스레드가 스핀락을 획득하기 위해 연속으로 시도하는 최대 횟수를 지정한다.
  - 최대 횟수를 넘어설 경우, `Yield()`를 통해 다른 스레드에게 CPU 점유를 넘긴다.

- **재귀적 락 허용 여부**
  - `WriteLock`을 획득한 상태에서 다시 락을 획득할 수 있는지 여부를 결정한다.
  - 허용한다면, 가능한 중첩 횟수도 지정한다.

<br>

## **[2] 플래그 구조 설정**

- 현재 쓰기를 수행 중인 스레드의 ID, 읽기를 수행 중인 스레드 개수를 기록하기 위한 플래그를 사용한다.
- 두 가지 정보를 저장해야 하지만, 동기화를 위해 하나의 변수에 영역을 나누어 저장한다.
- 플래그 크기 : `32 bit`

|위치|크기|이름|설명
|---|---|---|---|
|0  |1  |`Unused`       |사용되지 않는 영역|
|1  |15 |`WriteThreadID`|현재 쓰기를 수행 중인 스레드의 ID|
|16 |16 |`ReadCount`    |현재 읽기를 수행 중인 스레드 개수|

<br>

## **[3] 동작 설계**

### **Enter Write Lock**
- 아무도 읽거나 쓰지 않는 경우에만 쓸 수 있다.
- 쓰기 직전에 `WriteThreadID`에 자신의 스레드 ID를 작성한다.

### **Exit Write Lock**
- 쓰기가 끝나면 `WriteThreadID`를 `0`으로 바꾼다.

### **Enter Read Lock**
- 아무도 쓰기를 수행 중이지 않은 경우, 자유롭게 읽을 수 있다.
- 현재 쓰기를 수행 중인 스레드가 있을 경우, 대기한다.
- 읽기 직전에 `ReadCount`를 하나 증가시킨다.

### **Exit Read Lock**
- 읽기가 끝나면 `ReadCount`를 하나 감소시킨다.

<br>

# Reader Writer Lock 구현
---

## 정책 공통
- 스핀락 정책 : 5000 번 시도마다 양보

<br>

## [1] 기본 구현

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
class RWLock
{
    const int EMPTY_FLAG = 0x00000000; // 플래그 기본 값
    const int WRITE_MASK = 0x7FFF0000; //  1 ~ 15번째 비트 (15개)
    const int READ_MASK  = 0x0000FFFF; // 16 ~ 31번째 비트 (16개)

    const int MAX_SPIN_COUNT = 5000;   // 스핀 락 연속 시도 제한 횟수

    // [Unused(0)] [WriterThreadID(15)] [ReadCount(16)]
    private int _flag = 0x00000000;

    public void EnterWriteLock()
    {
        // 플래그 값이 expected 값이었을 경우, desired로 초기화한다.
        // WriterThreadID : 0
        // ReadCount      : 0
        //int expected = EMPTY_FLAG;

        // 플래그에 초기화 하고자 하는 값
        // WriterThreadID : 자신의 스레드 ID
        // ReadCount      : 0
        int desired = (Thread.CurrentThread.ManagedThreadId << 16) & WRITE_MASK;

        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 아무도 읽거나 쓰지 않는 상황이었을 경우,
                // 자신의 스레드 ID를 WriterThreadID 부분에 작성하고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, desired, EMPTY_FLAG) == EMPTY_FLAG)
                    return;
            }

            Thread.Yield();
        }
    }

    public void ExitWriteLock()
    {
        // 여기에는 항상 스레드가 하나씩 접근하므로 동기화 필요 X
        _flag = EMPTY_FLAG;
    }

    public void EnterReadLock()
    {
        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 예상한 값
                // WriterThreadID : 0 (아무도 쓰고 있지 않음)
                // ReadCount      : n (0 ~ n 명이 읽고 있음)
                int expected = (_flag & READ_MASK);

                // 쓰고 있는 스레드가 없을 경우,
                // 읽기 카운트를 +1로 만들고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, expected + 1, expected) == expected)
                    return;
            }

            Thread.Yield();
        }
    }

    public void ExitReadLock()
    {
        // 단순히 플래그의 값을 하나 감소시킨다.
        // ReadCount의 값을 하나 감소시키는 것과 같다.
        Interlocked.Decrement(ref _flag);
    }
}
```

</details>

<br>

## [2] WriterLock의 우선순위 보장하기

현재 구현한 방식에서는 `ReadCount`가 `0`보다 큰 동안 쓰기 스레드는 계속 대기하게 된다.

읽기 동작은 상대적으로 오래 걸리지 않으므로 보통은 괜찮을 수 있지만,

만에 하나 읽기가 지속적으로 발생하여 `ReadCount`가 계속 `0`보다 크게 유지되는 경우를 생각해볼 수 있다.

<br>

이런 경우를 대비한다면,

`EnterWriteLock()` 메소드에서 `ReadCount`가 `0`이 될 때까지 계속 대기하는 것보다

`WriteThreadID`가 `0`인 경우, 바로 자신의 스레드 ID를 기록해놓고 대기하다가

`ReadCount`가 `0`이 되면 임계 영역을 만들고 진입하는 방식을 통해 해결할 수 있다.

<br>

이렇게 된다면 쓰기 스레드가 `EnterWriteLock()`으로 진입을 시도하는 동안

현재 읽기 중이었던 스레드들은 자연스럽게 읽기를 마치고 나가고,

읽으려고 시도하는 스레드는 `EnterReadLock()`에서 `WriteThreadID`를 확인하여

값이 `0`이 아니므로 대기하게 된다.

따라서 읽기가 무한히 지속되는 동안 계속 쓰지 못하는 상황은 발생하지 않게 된다.

<br>

`ReaderWriterLockSlim` 클래스를 테스트 해보니,

이와 비슷하게 구현되어 있는 것 같다.

<br>

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
class RWLock2
{
    const int EMPTY_FLAG = 0x00000000; // 플래그 기본 값
    const int WRITE_MASK = 0x7FFF0000; //  1 ~ 15번째 비트 (15개)
    const int READ_MASK  = 0x0000FFFF; // 16 ~ 31번째 비트 (16개)

    const int MAX_SPIN_COUNT = 5000;   // 스핀 락 연속 시도 제한 횟수

    // [Unused(0)] [WriterThreadID(15)] [ReadCount(16)]
    private int _flag = 0x00000000;

    private int WriteMaskedThreadID => (Thread.CurrentThread.ManagedThreadId << 16) & WRITE_MASK;

    /// <summary> 쓰기 수행 중인 스레드가 없을 때의 읽기 카운트 </summary>
    private int ReadCountWithNoWrites => _flag & READ_MASK;

    public void EnterWriteLock()
    {
        int expected, desired;

        // 1. 이미 쓰기 작업 수행 중인 스레드가 있을 경우, 대기한다.
        // 진입하면 일단 자신의 스레드 ID를 WriterThreadID에 작성한다.

        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 기대하는 플래그 값
                // WriterThreadID : 0
                // ReadCount      : n
                expected = ReadCountWithNoWrites;

                // 플래그에 초기화 하고자 하는 값
                // WriterThreadID : 자신의 스레드 ID
                // ReadCount      : n
                desired = WriteMaskedThreadID | expected;

                // 아무도 쓰지 않는 상황이었을 경우,
                // 자신의 스레드 ID를 WriterThreadID 부분에 작성하고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, desired, expected) == expected)
                    goto _NEXT;
            }

            Thread.Yield();
        }

        _NEXT:

        // 2. 자신의 스레드 ID를 작성하는 데 성공했을 경우,
        // 읽기 중인 스레드가 모두 나가기를 기다린다.

        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                expected = WriteMaskedThreadID;

                // 자신만 쓰기를 대기하고, 아무도 읽지 않는 경우, 진입한다.
                if (_flag == expected)
                    return;
            }

            Thread.Yield();
        }
    }

    public void ExitWriteLock()
    {
        // 여기에는 항상 스레드가 하나씩 접근하므로 동기화 필요 X
        _flag = EMPTY_FLAG;
    }

    public void EnterReadLock()
    {
        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 예상한 값
                // WriterThreadID : 0 (아무도 쓰고 있지 않음)
                // ReadCount      : n (0 ~ n 명이 읽고 있음)
                int expected = ReadCountWithNoWrites;

                // 쓰고 있는 스레드가 없을 경우,
                // 읽기 카운트를 +1로 만들고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, expected + 1, expected) == expected)
                    return;
            }

            Thread.Yield();
        }
    }

    public void ExitReadLock()
    {
        // 단순히 플래그의 값을 하나 감소시킨다.
        // ReadCount의 값을 하나 감소시키는 것과 같다.
        Interlocked.Decrement(ref _flag);
    }
}
```

</details>

<br>

## [3] 재귀적 락을 허용하는 경우

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
class RWLock3
{
    const int EMPTY_FLAG = 0x00000000; // 플래그 기본 값
    const int WRITE_MASK = 0x7FFF0000; //  1 ~ 15번째 비트 (15개)
    const int READ_MASK = 0x0000FFFF;  // 16 ~ 31번째 비트 (16개)

    const int MAX_SPIN_COUNT = 5000;   // 스핀 락 연속 시도 제한 횟수

    // [Unused(0)] [WriterThreadID(15)] [ReadCount(16)]
    private int _flag = 0x00000000;

    // 동일 스레드가 WriteLock을 획득한 횟수
    private int writeLockCount = 0;

    public void EnterWriteLock()
    {
        // 이미 동일 스레드가 WriteLock을 획득하고 있는 상태인 경우,
        // writeLockCount만 증가시키고 퇴장
        int lockThreadID = (_flag & WRITE_MASK) >> 16;
        if (Thread.CurrentThread.ManagedThreadId == lockThreadID)
        {
            writeLockCount++;
            return;
        }

        // 플래그에 초기화 하고자 하는 값
        // WriterThreadID : 자신의 스레드 ID
        // ReadCount      : 0
        int desired = (Thread.CurrentThread.ManagedThreadId << 16) & WRITE_MASK;

        while (true)
        {
            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 아무도 읽거나 쓰지 않는 상황이었을 경우,
                // 자신의 스레드 ID를 WriterThreadID 부분에 작성하고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, desired, EMPTY_FLAG) == EMPTY_FLAG)
                {
                    // 쓰기 락 획득 횟수 기록
                    writeLockCount = 1;
                    return;
                }
            }

            Thread.Yield();
        }
    }

    public void ExitWriteLock()
    {
        // 일단 쓰기 락 중첩 횟수 하나 감소
        writeLockCount--;

        // 모든 락 중첩이 풀린 경우
        if (writeLockCount == 0)
            Interlocked.Exchange(ref _flag, EMPTY_FLAG);
    }

    public void EnterReadLock()
    {
        while (true)
        {
            // 이미 동일 스레드가 WriteLock을 획득하고 있는 상태인 경우,
            // ReadCount를 하나 증가시킨다.
            int lockThreadID = (_flag & WRITE_MASK) >> 16;
            if (Thread.CurrentThread.ManagedThreadId == lockThreadID)
            {
                Interlocked.Increment(ref _flag);
                return;
            }

            // 연속으로 일정 횟수만큼 스핀 락 진입을 시도하고, Yield()로 양보한다.
            for (int i = 0; i < MAX_SPIN_COUNT; i++)
            {
                // 예상한 값
                // WriterThreadID : 0 (아무도 쓰고 있지 않음)
                // ReadCount      : n (0 ~ n 명이 읽고 있음)
                int expected = (_flag & READ_MASK);

                // 쓰고 있는 스레드가 없을 경우,
                // 읽기 카운트를 +1로 만들고 진입한다.
                if (Interlocked.CompareExchange(ref _flag, expected + 1, expected) == expected)
                    return;
            }

            Thread.Yield();
        }
    }

    public void ExitReadLock()
    {
        // 단순히 플래그의 값을 하나 감소시킨다.
        // ReadCount의 값을 하나 감소시키는 것과 같다.
        Interlocked.Decrement(ref _flag);
    }
}
```

</details>

<br>

재귀적 락을 허용한다는 것은

```cs
_lock.EnterWriteLock();
_lock.EnterWriteLock();

// Write ..

_lock.ExitWriteLock();
_lock.ExitWriteLock();
```

이렇게 WriteLock을 여러 번 획득하고 해제하거나

<br>

```cs
_lock.EnterWriteLock();

// Write ..

_lock.EnterReadLock();

// Read ..

_lock.ExitReadLock();
_lock.ExitWriteLock();
```

이렇게 WriteLock 이후 ReadLock을 허용한다는 의미이다.

<br>

재귀적 락을 허용하지 않는 경우,

위와 같이 사용하면 영겁의 굴레에 빠진다.


<br>

# ReaderWriterLock 테스트
---

## **[1] WriterLock 테스트**

- 여러 스레드가 동시에 Write를 수행하는 경우만 테스트한다.

- 위에서 작성한 3가지 ReaderWriterLock과 C#에 기본적으로 만들어져 있는 `ReaderWriterLockSlim`을 각각 테스트해본다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private static int count = 100000;
private static volatile int number = 0;
private static RWLock _lock = new RWLock();
//private static RWLock2 _lock = new RWLock2();
//private static RWLock3 _lock = new RWLock3();
//private static ReaderWriterLockSlim _lock = new ReaderWriterLockSlim();

private static void ThreadBody1()
{
    for (int i = 0; i < count; i++)
    {
        _lock.EnterWriteLock();
        number++;
        _lock.ExitWriteLock();
    }
}

private static void ThreadBody2()
{
    for (int i = 0; i < count; i++)
    {
        _lock.EnterWriteLock();
        number--;
        _lock.ExitWriteLock();
    }
}

/// <summary> 쓰기만 번갈아 수행하여 동기화가 제대로 되는지 테스트 </summary>
public static void WriterSyncTest(int maxCount = 100000)
{
    count = maxCount;

    Task t1 = new Task(ThreadBody1);
    Task t2 = new Task(ThreadBody2);

    t1.Start();
    t2.Start();

    Task.WaitAll(t1, t2);

    Console.WriteLine($"Suceeded : {number == 0}");
}
```

</details>

<br>

## **[2] Write, Read 테스트**

- 마찬가지로 4가지 ReaderWriterLock을 모두 테스트한다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private static int count = 100000;
private static volatile int number = 0;

private static RWLock _lock = new RWLock();
//private static RWLock2 _lock = new RWLock2();
//private static RWLock3 _lock = new RWLock3();
//private static ReaderWriterLockSlim _lock = new ReaderWriterLockSlim();

private static void WriterThreadBody(int interval)
{
    for (int i = 0; i < count; i++)
    {
        _lock.EnterWriteLock();
        number++;
        Console.WriteLine($"WRITE : {number}");
        _lock.ExitWriteLock();

        Thread.Sleep(interval);
    }
}

private static void ReaderThreadBody(int begin, int interval)
{
    Thread.Sleep(begin);

    for (int i = 0; i < count; i++)
    {
        _lock.EnterReadLock();
        Thread.Sleep(1000);
        Console.WriteLine($"READ : {number}, Thread ID : {Thread.CurrentThread.ManagedThreadId}");
        _lock.ExitReadLock();

        Thread.Sleep(interval);
    }
}

/// <summary> 쓰기, 읽기를 모두 테스트 </summary>
public static void WriteAndReadTest()
{
    Task[] tasks =
    {
        new Task(() => WriterThreadBody(500)),
        new Task(() => ReaderThreadBody(000, 300)),
        new Task(() => ReaderThreadBody(300, 400)),
        new Task(() => ReaderThreadBody(500, 500)),
    };

    foreach (var t in tasks)
    {
        t.Start();
    }

    Task.WaitAll(tasks);
}
```

</details>

<br>

## **테스트 결과**

### **RWLock, RWLock3**

- WriterLock의 우선순위를 보장하지 않았으므로, Read가 영원히 반복되는 동안 Write는 영원히 불가능하다.

```
WRITE : 1
READ : 1, Thread ID : 6
READ : 1, Thread ID : 7
READ : 1, Thread ID : 8
READ : 1, Thread ID : 6
READ : 1, Thread ID : 7
READ : 1, Thread ID : 8
READ : 1, Thread ID : 6
READ : 1, Thread ID : 7
READ : 1, Thread ID : 8
READ : 1, Thread ID : 6
READ : 1, Thread ID : 7
READ : 1, Thread ID : 8
READ : 1, Thread ID : 6
READ : 1, Thread ID : 7
READ : 1, Thread ID : 8
READ : 1, Thread ID : 6
```

### **RWLock2, ReaderWriterLockSlim**

- Write의 우선순위가 보장되며, 동기화도 문제 없이 이루어짐을 확인할 수 있다.

```
WRITE : 1
READ : 1, Thread ID : 7
READ : 1, Thread ID : 5
WRITE : 2
READ : 2, Thread ID : 7
READ : 2, Thread ID : 6
READ : 2, Thread ID : 5
WRITE : 3
READ : 3, Thread ID : 7
READ : 3, Thread ID : 6
READ : 3, Thread ID : 5
WRITE : 4
READ : 4, Thread ID : 7
READ : 4, Thread ID : 6
READ : 4, Thread ID : 5
WRITE : 5
READ : 5, Thread ID : 7
READ : 5, Thread ID : 6
READ : 5, Thread ID : 5
```




