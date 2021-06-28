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











제대로된 스핀락 작성하기!!!!

https://www.inflearn.com/course/%EC%9C%A0%EB%8B%88%ED%8B%B0-mmorpg-%EA%B0%9C%EB%B0%9C-part4/lecture/37183?mm=close&tab=note


09:09











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