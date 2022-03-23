# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# 하드웨어 최적화 문제
---

```cs
class Program
{
    private static int x = 0;
    private static int y = 0;
    private static int r1 = 0;
    private static int r2 = 0;

    private static void ThreadBody1()
    {
        y = 1;  // Store y
        r1 = x; // Load x
    }
    private static void ThreadBody2()
    {
        x = 1;  // Store x
        r2 = y; // Load y
    }

    static void Main(string[] args)
    {
        int count = 0;
        while (true)
        {
            count++;
            x = y = r1 = r2 = 0;

            Task t1 = new Task(ThreadBody1);
            Task t2 = new Task(ThreadBody2);
            t1.Start();
            t2.Start();

            Task.WaitAll(t1, t2);

            if (r1 == 0 && r2 == 0)
                break;
        }

        Console.WriteLine($"Count : {count}");
    }
}
```

위의 프로그램을 실행한다.

매 시행마다 `x`, `y`, `r1`, `r2`의 값을 0으로 초기화하고

`t1`에서는 `y`에 `1`을 넣은 뒤 `r1`에 `x`의 값을 넣으며,

`t2`에서는 `x`에 `1`을 넣은 뒤 `r2`에 `y`의 값을 넣는다.

두 Task는 거의 동시에 실행된다.

<br>

루프를 빠져나오려면 `r1 == 0 && r2 == 0`을 동시에 만족해야 한다.

논리적으로는 루프를 빠져나오는 것이 절대 불가능하다.

어쨌든 `x = 1` 또는 `y = 1` 둘 중 하나가 무조건 먼저 실행되어야 하는데,

그렇게 되면 `r1`, `r2` 둘 모두가 `0`을 갖는 경우는 존재할 수 없다.

그런데 결과적으로 `count` 값은 3, 10, 24, 35, 62, ...으로

시행마다 다르지만, 어쨌든 루프를 빠져나오는데 성공한다.

<br>

## **이유**

무엇 때문에 위와 같은 현상 발생했을까?

이유는 `하드웨어 최적화`에 있다.

CPU는 서로 의존성이 없는 명령어들에 한해

최적화를 위해 서로 순서를 뒤바꾸기도 한다.

<br>

따라서

```cs
// Thread 1
y = 1;
r1 = x;

// Thread 2
x = 1;
r2 = y;
```

이랬던 코드가

각각 하드웨어 최적화로 인해 순서가 바뀌어


```cs
// Thread 1
r1 = x;
y = 1;

// Thread 2
r2 = y;
x = 1;
```

이렇게 실행되는 순간, 루프를 빠져나오게 된다.

<br>

사실 싱글스레드에서는 서로 의존성 없는 두 명령어의 재배치이므로

전혀 상관이 없을 수 있다.

하지만 멀티스레딩 환경에서는 위와 같은 문제가 발생할 수 있다.

<br>

# 메모리 배리어(Memory Barrier)
---

위의 문제를 해결할 방법이 있다.

바로 메모리 배리어를 사용하는 것이다.

메모리 배리어를 이용하면 하드웨어에 의한 코드 재배치를 방지할 수 있다.

<br>

각각의 스레드 바디에

```cs
private static void ThreadBody1()
{
    y = 1;  // Store y
    
    Thread.MemoryBarrier();
    
    r1 = x; // Load x
}
private static void ThreadBody2()
{
    x = 1;  // Store x
    
    Thread.MemoryBarrier();
    
    r2 = y; // Load y
}
```

이렇게 재배치될 가능성이 존재하는 두 문장 사이에

`Thread.MemoryBarrier()`를 호출하면

메모리 배리어 앞에 존재하는 Store/Load 연산이

메모리 배리어 뒤의 Store/Load 연산들에 앞서

**메모리에 커밋되도록 보장**해주며,

결국 하드웨어에 의한 명령어 재배치가 발생하지 않게 되어

원래 의도대로 동작하게 된다.

<br>

## **메모리 배리어 종류**

### **[1] Full Memory Barrier**
 - 어셈블리의 `MFENCE`, C#의 `Thread.MemoryBarrier()`에 해당한다.
 - Store, Load 명령어 재배치를 모두 방지한다.
 
### **[2] Store Memory Barrier**
 - 어셈블리의 `SFENCE`에 해당한다.
 - Store 명령어 재배치를 방지한다.
 
### **[3] Load Memory Barrier**
 - 어셈블리의 `LFENCE`에 해당한다.
 - Load 명령어 재배치를 방지한다.

<br>

# 정리
---

- CPU에 의한 명령어 재배치에 의해 의존성 없는 코드들의 실행 순서가 바뀔 수 있다.
- 싱글 스레드에서는 문제가 없지만, 멀티 스레드에서는 문제가 발생할 수 있다.
- `Thread.MemoryBarrier()`를 통해 명령어 재배치를 방지하고, 메모리 커밋을 보장해줄 수 있다.

