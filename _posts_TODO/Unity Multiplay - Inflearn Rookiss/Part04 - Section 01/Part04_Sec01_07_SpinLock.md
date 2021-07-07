# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# 스핀 락(Spin Lock) 개념
---

스레드 동기화를 위해 락을 걸고 크리티컬 섹션에 진입할 경우, 대기하는 스레드는 블록된다.

다시 말해, 크리티컬 섹션에 진입하려고 대기하는 스레드는 CPU 점유를 포기하게 된다.

그리고 CPU 자원이 현재 활성화된 다른 스레드에게 넘어가게 되는데, 이 때 컨텍스트 스위칭이 발생하며 그에 따른 오버헤드 또한 발생한다.

<br>

스핀 락은 크리티컬 섹션의 진입을 위해 대기할 때도 CPU 점유를 포기하지 않고 계속 기다리는 형태를 의미한다.

이를 바쁜 대기(Busy Waiting)라고 하며, 컨텍스트 스위칭이 발생하지 않는다.

하지만 오랜 시간 동안 바쁜 대기를 할 경우 CPU 자원이 낭비되므로

락을 설정하고 해제하는 주기가 짧고, 스레드 동기화가 빈번한 경우에 컨텍스트 스위칭을 방지하기 위한 용도로 사용된다.

<br>


# 스핀 락 직접 구현하기
---

```cs
class CustomSpinLock
{
    private volatile bool _locked = false;

    public void Enter()
    {
        while (_locked)
        {
            // 락이 풀리기를 대기한다.
        }

        // 락을 걸고 진입한다.
        _locked = true;
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = false;
    }
}
```

기본적인 개념은 위와 같다.

하지만 `_locked` 필드에 읽고 쓰는 동안 동기화가 보장되지 않는다.

<br>

## **Interlocked.Exchange()** 사용하여 구현하기

```cs
class CustomSpinLock
{
    private const int UNLOCKED = 0;
    private const int LOCKED = 1;

    private volatile int _locked = UNLOCKED;

    public void Enter()
    {
        // 대기
        while (true)
        {
            // _locked의 값을 LOCKED(1)로 변경한다.
            // 변경되기 전의 값은 original로 가져온다.
            int original = Interlocked.Exchange(ref _locked, LOCKED);

            // 만약 변경되기 전의 값이 UNLOCKED였으면
            // 락이 풀려 있는 상태라는 의미이므로,
            // 대기를 종료하고 진입한다.
            if (original == UNLOCKED)
                break;
        }
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = UNLOCKED;
    }
}
```

`Interlocked.Exchange(ref location, value)` 메소드는

`location` 변수에 `value` 값을 초기화하고, 초기화되기 전의 값을 리턴한다.

그리고 이 과정에서 원자성이 보장된다.

따라서 위의 경우에는 `Enter()` 메소드 내에서 무한 루프를 통해

`_locked` 필드의 값을 `LOCKED`로 계속 초기화하며 초기화 이전 값을 확인한다.

초기화 이전 값이 `LOCKED`이면 락이 걸려있다는 의미이므로 대기하고,

`UNLOCKED`이면 락이 풀려있다는 의미이므로 진입하게 된다.

<br>

추가로, `while` 블록 내부의 두 문장은 원자성이 보장되지 않으니 문제가 된다고 생각할 수 있다.

하지만 `_locked`와 같은 공유 필드의 경우에는 값을 읽는 것 자체가 부정확한 결과를 낼 수 있으므로 문제가 될 수 있으나

여기서 `original` 변수는 해당 스레드만의 스택에 저장되는 변수이므로

값을 확인하거나 변경하는 것이 전혀 문제되지 않는다.

<br>

그렇다면 `Exit()` 내부에서 `_locked`에 값을 초기화하는 부분은 어떨까?

분명 `_locked`는 공유되는 필드 변수이므로 값을 그냥 넣어버리면 문제가 생길 것 같다.

하지만 이건 조금 더 넓게 볼 필요가 있다.

`Exit()`를 호출할 수 있다는 것은 이미 `Enter()`를 '단 하나의 스레드'가 지나왔다는 것을 의미한다.

그리고 다른 스레드들은 이 때 `Enter()` 내부의 반복문에서 확인하며 대기하는 상태이다.

따라서 `Exit()`로의 진입 자체가 한 번에 하나의 스레드만 가능하다는 것이 보장되므로

위와 같이 작성해도 문제가 생기지 않는다.


<br>

## **Interlocked.CompareExchange()** 사용하기

`.Exchange()`를 사용하면 값을 무조건 변경하면서 이전 값을 확인하므로,

의도에 부합되는 논리가 아니라고 할 수 있다.

따라서 `.CompareExchange()` 메소드를 통해 의도대로 구현할 수 있다.

<br>

```cs
class CustomSpinLock
{
    private const int UNLOCKED = 0;
    private const int LOCKED = 1;

    private volatile int _locked = UNLOCKED;

    public void Enter()
    {
        // 대기
        while (true)
        {
            // _locked의 값이 UNLOCKED(0)였으면 LOCKED(1)로 변경한다.
            // 변경되기 전의 값은 original로 가져온다.
            int original = Interlocked.CompareExchange(ref _locked, LOCKED, UNLOCKED);

            // 만약 변경되기 전의 값이 UNLOCKED였으면
            // 락이 풀려 있는 상태라는 의미이므로,
            // 대기를 종료하고 진입한다.
            if (original == UNLOCKED)
                break;
        }
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = UNLOCKED;
    }
}
```

`.CompareExchange(ref location, value, comparand)` 메소드는

`location`의 값이 `comparand`와 같으면 `location`을 `value`로 초기화하고,

`location`이 원래 갖고 있던 값을 리턴한다.

이렇게 값을 비교하여 변경하는 방식을 **CAS(Comapre-And-Swap)**이라고 한다.

<br>

## **테스트**

```cs
private static CustomSpinLock spinLock = new CustomSpinLock();

private const int Count = 100000;
private static int number = 0;

private static void ThreadBody1()
{
    for (int i = 0; i < Count; i++)
    {
        spinLock.Enter();
        number++;
        spinLock.Exit();
    }
}

private static void ThreadBody2()
{
    for (int i = 0; i < Count; i++)
    {
        spinLock.Enter();
        number--;
        spinLock.Exit();
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

의도대로 작동하면 결과가 0으로 출력된다.

<br>


# C# SpinLock 클래스
---

- C#에는 `SpinLock` 클래스가 이미 구현되어 있다.

- `SpinLock` 클래스도 `Monitor` 클래스와 마찬가지로, 크리티컬 섹션에서의 처리 도중 예외가 발생하여 락을 못푸는 경우를 대비하여 `try-finally` 구문을 통해 안전하게 작성해야 한다.

<br>

```cs
private const int Count = 100000;
private static int number = 0;

private static SpinLock spLock = new SpinLock();

private static void ThreadBody1()
{
    for (int i = 0; i < Count; i++)
    {
        bool lockTaken = false;
        try
        {
            spLock.Enter(ref lockTaken);

            // Do Something Here =========
            number++;
            // ===========================
        }
        finally
        {
            if (lockTaken)
            {
                spLock.Exit();
            }
        }
    }
}
private static void ThreadBody2()
{
    for (int i = 0; i < Count; i++)
    {
        bool lockTaken = false;
        try
        {
            spLock.Enter(ref lockTaken);

            // Do Something Here =========
            number--;
            // ===========================
        }
        finally
        {
            if (lockTaken)
            {
                spLock.Exit();
            }
        }
    }
}

static void Main(string[] args)
{
    Task t1 = new Task(ThreadBody1);
    Task t2 = new Task(ThreadBody2);

    t1.Start();
    t2.Start();

    Task.WaitAll(t1, t2);
    Console.WriteLine($"Result : {number}");
}
```

<br>