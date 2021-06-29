# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# Context Switching 개념
---

현재 실행 되는 스레드가 있다면, 그 스레드는 CPU의 자원을 할당받아 동작하는 것이다.

동시에 실행될 수 있는 스레드의 개수는 사실 CPU 코어의 개수 이하인데,

예를 들어 CPU 코어가 4개라면 동시에 4개까지의 스레만 자원을 할당받아 동작할 수 있는 것이다.

그런데 CPU 코어가 4개라고 해도 실제로 5개 이상의 스레드가 동시에 동작할 수 있다.

그 이유는 시분할(Time Slicing)에 의한 컨텍스트 스위칭 때문이다.

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

# 의도적인 컨텍스트 스위칭
---

현재 동작 중인 스레드에서 CPU 자원을 포기하고 컨텍스트 스위칭을 발생시켜

다른 스레드에 CPU 자원을 양보하는 것이 가능하다.

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

- 자신보다 우선순위가 높은 스레드가 없을 경우, 아무런 동작을 수행하지 않는다.

<br>

## **[3] Yield**

```cs
Thread.Yield;
```

- 우선순위에 관계 없이 CPU 점유를 양보하며 컨텍스트 스위칭이 항상 발생한다.

<br>

# 응용 : 스핀락 보완하기
---

스핀락(Spin Lock)의 문제점은 바쁜 대기(Busy Waiting) 사용하기 때문에

락을 획득하지 못해 대기하는 상황에서 CPU 자원을 계속 점유한다는 것이다.

따라서 대기가 길어질수록 성능 저하가 커지게 된다.

의도적인 컨텍스트 스위칭을 이용하면 고전적인 락 기법(대기할 경우 CPU 점유 포기)과

스핀 락을 혼용하는 형태로 서로의 단점을 보완할 수 있다.

물론 C#의 `SpinLock` 클래스에는 이미 구현되어 있다. (`.TryEnter()`)

<br>

## **[1] 스핀락 구현

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

## **[2] 타임아웃 기능 추가**

```cs
class CustomSpinLock
{
    private const int UNLOCKED = 0;
    private const int LOCKED = 1;

    private volatile int _locked = UNLOCKED;

    public void Enter(int timeout)
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

            // 락을 획득하지 못한 경우, CPU 자원을 지정된 시간동안 양보한다.
            else
                Thread.Sleep(timeout); // 단위 : ms
        }
    }

    public void Exit()
    {
        // 락을 해제한다.
        _locked = UNLOCKED;
    }
}
```

위와 같이 `Enter()` 메소드 내에서 락을 획득 하지 못한 경우의 분기를 추가하여

락을 획득하지 못하면 의도적으로 컨텍스트 스위칭을 발생시키고

지정된 시간동안 `Thread.Sleep()`을 통해 CPU 자원을 양보하도록 할 수 있다.

<br>

이 방법을 통해,

고전적인 락처럼 대기하는 동안 무조건 컨텍스트 스위칭이 발생하거나

스핀락처럼 대기하는 동안 무조건 CPU를 점유하는 두 가지 방법에서

타협점을 찾아 락을 구현할 수 있다.

<br>

# References
---
- <https://jungwoong.tistory.com/40>