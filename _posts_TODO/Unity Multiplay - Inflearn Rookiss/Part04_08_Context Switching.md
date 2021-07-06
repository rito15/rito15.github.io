# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# 컨텍스트 스위칭(Context Switching) 개념
---

현재 실행 되는 스레드가 있다면, 그 스레드는 CPU의 자원을 할당받아 동작하는 것이다.

동시에 실행될 수 있는 스레드의 개수는 사실 CPU 코어의 개수 이하인데,

예를 들어 CPU 코어가 4개라면 동시에 4개까지의 스레만 자원을 할당받아 동작할 수 있는 것이다.

그런데 CPU 코어가 4개라고 해도 실제로 5개 이상의 스레드가 동시에 동작할 수 있다.

그 이유는 컨텍스트 스위칭과 시분할(Time Slicing) 기법 때문이다.

<br>

운영체제 내부에는 스레드 스케줄러라는 것이 존재하며,

현재 실행 중인 스레드들에 각각 CPU 자원을 할당하고 수거하는 작업을 수행한다.

코어가 감당할 수 있는 개수를 초과하여 스레드가 동작할 경우

스케줄러에 의해 스레드 간 CPU 자원의 할당/수거를 반복하며

한정된 자원으로 동시에 여러 스레드가 동작하는 것처럼 보이게 되는데,

이것을 시분할 기법이라고 한다.

<br>

그리고 CPU 자원을 수거할 때 해당 스레드의 상태를 저장하고,

다시 CPU 자원을 할당할 때 기존에 저장했던 상태를 복원하여 다시 작업하게 되며

이것을 컨텍스트 스위칭이라고 한다.

<br>

조금 더 구체적으로 알아보자면,

스케줄러에 의해 각 스레드는 큐로 관리되며

큐의 맨 앞에 왔을 때 시간 할당량(Time Slice)을 할당받는다.

그리고 그 시간이 모두 지나면 컨텍스트 스위칭이 발생하면서

CPU 점유를 포기하고 큐의 맨 뒤로 이동하게 되는 것이다.


<br>

# 의도적인 컨텍스트 스위칭
---

여기서 의도적인 컨텍스트 스위칭을 발생시키는 상황이란,

CPU 자원 한계를 넘어서 스레드가 동작하는 상황을 가정하는 것이다.

만약 CPU 자원 한계 이하로 스레드가 동작하고 있을 경우,

애초에 자연스럽게 컨텍스트 스위칭이 발생하지도 않으며

굳이 의도적으로 현재 동작 중인 스레드에게 CPU 자원을 포기시킬 필요가 없다.

<br>

그러니까 목적은 **'CPU 자원이 필요한데 얻지 못하는 스레드가 발생하는 상황을 방지하는 것'**이다.

이를테면 대표적으로 스핀 락이 발생하는 경우를 생각해볼 수 있다.

스핀 락은 스레드가 락을 얻기 위해 CPU 자원을 가진 채로 무한히 대기하는데,

만약 CPU 자원이 활성 스레드 개수보다 적은 상황이라면

CPU 자원이 필요한 스레드가 스핀 락을 대기하는 스레드 때문에

자원을 얻지 못하고 기다리게 될 수 있는 것이다.

<br>

따라서 이런 경우에 현재 동작 중인 스레드에서 CPU 자원을 포기하고

컨텍스트 스위칭을 발생시켜 다른 스레드에 CPU 자원을 양보하는 것이 가능하다.

그리고 여기에는 세 가지 방법이 있다.

<br>

## **[1] Sleep(1)**

```cs
Thread.Sleep(1);
```

- 무조건 1ms 이상의 시간동안 블록되며, 컨텍스트 스위칭이 항상 발생한다.

<br>

## **[2] Sleep(0)**

```cs
Thread.Sleep(0);
```

- 자신보다 우선순위가 높은 스레드가 있을 경우, CPU 점유를 양보하며 컨텍스트 스위칭이 발생한다.

- 자신보다 우선순위가 높은 스레드가 없을 경우, CPU 점유를 양보하지는 않지만 컨텍스트 스위칭은 발생한다.

<br>

## **[3] Yield**

```cs
Thread.Yield();
```

- 우선순위에 관계 없이 CPU 점유를 양보하며 컨텍스트 스위칭이 항상 발생한다.

<br>

## **Note**

현재 스레드 개수가 CPU 자원의 수 이하라고 해도

위의 메소드들을 실행하면 즉시 타임 슬라이스를 포기하면서 컨텍스트 스위칭이 발생하고,

그에 따른 오버헤드가 발생한다.


<br>

# Test Code
---

- CPU 자원 한계를 넘었을 때의 스레드 동작과, 의도적인 컨텍스트 스위칭에 의한 오버헤드를 확인할 수 있는 예제 코드

```cs
class ContextSwitchingTest
{
    private const long Cycle = 1000000; // 콘솔에 출력할 주기
    private const int  ThreadCount = 3; // 동작할 스레드 개수

    private static void ThreadBody()
    {
        long i = 0;
        while (true)
        {
            i++;

            if(i % Cycle == 0)
                Console.WriteLine(Thread.CurrentThread.ManagedThreadId);

            //Thread.Yield();
            //Thread.Sleep(0);
            //Thread.Sleep(1);
        }
    }

    public static void Run()
    {
        Thread[] trs = new Thread[ThreadCount];
        for (int i = 0; i < trs.Length; i++)
        {
            trs[i] = new Thread(ThreadBody);
            trs[i].IsBackground = true;
            trs[i].Start();
        }

        for (int i = 0; i < trs.Length; i++)
        {
            trs[i].Join();
        }
    }
}
```

<br>

# 응용 : 락, 스핀락 보완하기
---

고전적인 락 기법(C#의 Monitor, lock)의 문제점은

락을 획득하지 못하는 즉시 CPU 점유를 포기하고 컨텍스트 스위칭이 발생하여

컨텍스트 스위칭에 의한 오버헤드가 발생한다는 것이다.

<br>

그리고 스핀락(Spin Lock)의 문제점은 바쁜 대기(Busy Waiting)로 인해

락을 획득하지 못해 대기하는 상황에서 CPU 자원을 계속 점유한다는 것이다.

따라서 대기가 길어질수록 성능 저하가 커지게 된다.

<br>

의도적인 컨텍스트 스위칭을 이용하면 두 가지 방법을

혼용하는 형태로 서로의 단점을 보완할 수 있다.

물론 C#의 `SpinLock` 클래스에는 이미 구현되어 있다. (`.TryEnter()`)

<br>

## **[1] 기본적인 스핀락 구현**

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

`Interlocked`를 이용하는 기초적인 스핀락 클래스 구현이다.

락을 획득하지 못하면, 획득할 때까지 무한정 바쁜 대기를 수행한다.

<br>

## **[2] 연속 시도 횟수 제한**

```cs
class CustomSpinLock
{
    private const int UNLOCKED = 0;
    private const int LOCKED = 1;

    private volatile int _locked = UNLOCKED;

    public void Enter(int maxTryCount = 5000)
    {
        // 대기
        while (true)
        {
            // 일정 횟수 동안 연속적으로 락 획득을 시도한다.
            for (int i = 0; i < maxTryCount; i++)
            {
                // _locked의 값이 UNLOCKED(0)였으면 LOCKED(1)로 변경한다.
                // 변경되기 전의 값은 original로 가져온다.
                int original = Interlocked.CompareExchange(ref _locked, LOCKED, UNLOCKED);

                // 만약 변경되기 전의 값이 UNLOCKED였으면
                // 락이 풀려 있는 상태라는 의미이므로,
                // 대기를 종료하고 진입한다.
                if (original == UNLOCKED)
                    return;
            }

            // maxTryCount번의 시도 동안 락을 획득하지 못한 경우, CPU 자원을 양보한다.
            Thread.Yield();
        }
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = UNLOCKED;
    }
}
```

위와 같이 `Enter()` 메소드 내에서 일정 횟수 동안에는 연속으로 락 획득 시도를 하며

CPU 자원을 계속 점유하고, 컨텍스트 스위칭이 발생하지 않는다.

그리고 지정한 횟수를 넘어가면 `Thread.Yield()`를 호출하여

다른 스레드에 CPU 점유를 양보하는 방식으로 구현한다.

<br>

## **[3] 타임아웃(연속 시도 시간 제한)**

```cs
class CustomSpinLock2
{
    private const int UNLOCKED = 0;
    private const int LOCKED = 1;

    private volatile int _locked = UNLOCKED;

    public void Enter(int timeoutMS = 1000) // 시간 단위 : ms
    {
        // 대기
        while (true)
        {
            DateTime begin = DateTime.Now;
            double elapsed = 0;

            // 일정 시간 동안 연속적으로 락 획득을 시도한다.
            while (elapsed < timeoutMS)
            {
                // 연속 경과 시간을 기록한다.
                elapsed = DateTime.Now.Subtract(begin).TotalMilliseconds;

                // _locked의 값이 UNLOCKED(0)였으면 LOCKED(1)로 변경한다.
                // 변경되기 전의 값은 original로 가져온다.
                int original = Interlocked.CompareExchange(ref _locked, LOCKED, UNLOCKED);

                // 만약 변경되기 전의 값이 UNLOCKED였으면
                // 락이 풀려 있는 상태라는 의미이므로,
                // 대기를 종료하고 진입한다.
                if (original == UNLOCKED)
                    return;
            }

            // timeoutMS 시간 동안 락을 획득하지 못한 경우, CPU 자원을 양보한다.
            Thread.Yield();
        }
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = UNLOCKED;
    }
}
```

연속 시도 횟수를 기록하는 **[2]**와는 달리, 연속 시도 경과 시간을 기록하고

지정한 한계 시간을 지난 경우 다시 경과 시간을 초기화하며 `Thread.Yield()`를 호출한다.

<br>

위와 같은 방법들을 통해,

고전적인 락처럼 대기하는 동안 무조건 컨텍스트 스위칭이 발생하거나

스핀락처럼 대기하는 동안 무조건 CPU를 점유하는 두 가지 방법에서

타협점을 찾아 락을 구현할 수 있다.

<br>

# References
---
- <https://jungwoong.tistory.com/40>
- <https://m.blog.naver.com/rhkdals1206/221575121342>
- <https://pasudo123.tistory.com/13>