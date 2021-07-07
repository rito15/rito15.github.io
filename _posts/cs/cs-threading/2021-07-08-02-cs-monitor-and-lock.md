---
title: C# Monitor, lock
author: Rito15
date: 2021-07-08 01:02:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# Critical Section(임계 영역)
---

- 여러 프로세스 또는 여러 스레드가 공유 자원에 접근할 때 한 번에 하나만 접근할 수 있도록 보장해주는 영역
- C#에서는 대표적으로 `Monitor` 클래스 또는 `lock()` 구문을 통해 만들 수 있다.

<br>

# Monitor 클래스
---

- 크리티컬 섹션을 만들어줄 수 있다.

- Enter(진입), Exit(탈출)로 이루어져 있다.

<br>

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
class Program
{
    // 크리티컬 섹션을 위한 매개체
    private static readonly object _lock = new object();
    
    private const int Count = 500000;
    private static int number = 0;

    private static void ThreadBody1()
    {
        for (int i = 0; i < Count; i++)
        {
            Monitor.Enter(_lock); // Enter Critical Section

            number++;

            Monitor.Exit(_lock); // Exit Critical Section
        }
    }
        
    private static void ThreadBody2()
    {
        for (int i = 0; i < Count; i++)
        {
            Monitor.Enter(_lock);

            number--;

            Monitor.Exit(_lock);
        }
    }

    static void Main(string[] args)
    {
        Task t1 = new Task(ThreadBody1);
        Task t2 = new Task(ThreadBody2);

        t1.Start();
        t2.Start();

        Task.WaitAll(t1, t2);

        Console.WriteLine(number);
    }
}
```

</details>

<br>

크리티컬 섹션을 위한 매개체가 필요하다.

object 타입으로 `_lock` 객체를 만들어, 매개체로 이용한다.

`_lock` 객체는 특정 크리티컬 섹션에 대한 상태 공유를 위해 사용된다.

<br>

한 스레드에서 `Monitor.Enter(_lock)`을 통해 크리티컬 섹션에 진입하면,

다른 스레드에서 똑같이 `Monitor.Enter(_lock)`을 호출하는 경우

`_lock`에 대한 크리티컬 섹션이 해제될 때까지 대기하게 된다.(blocked)

`Monitor.Exit(_lock)`을 호출하여 크리티컬 섹션을 해제(또는 탈출)할 수 있다.

<br>

## **주의사항**

크리티컬 섹션에서 예기치 못하게 빠져나가거나 예외가 발생하는 경우,

크리티컬 섹션을 종료하지 않고 나가버리게 되어 데드락(Deadlock)이 발생할 수 있다.

이런 위험성이 존재하는 코드에서는

```cs
try
{
    Monitor.Enter(_lock);
    
    // Critical Section Codes..
    
    if(some_condition)
        return;
}
finally
{
    Monitor.Exit(_lock);
}
```

이렇게 작성하여 반드시 `Monitor.Exit(_lock)`이 호출되도록 해줄 수 있다.

`try` 구문 내에서 `return;`으로 빠져나오는 경우에도

`finally`구문을 반드시 실행하게 된다.

<br>

# lock 구문
---

위처럼 크리티컬 섹션을 안전하게 작성하기 위해

`try-finally`, `Monitor.Enter()`, `Monitor.Exit()`을 사용하는 것은

가독성에도 좋지 않고, 여간 번거로운 일이 아닐 수 없다.

따라서 C#에서는 간단히 크리티컬 섹션을 만들어주는 `lock` 구문이 존재한다.

<br>

```cs
lock(_lock)
{
    // Critical Section Codes..
}
```

사용법은 이렇게 매우 간단하다.

매개체 `_lock`을 이용해 위처럼 구문을 작성하면,

내부적으로 `Monitor`를 이용해 크리티컬 섹션을 만들어준다.

<br>

# Deadlock
---

## **대표적인 데드락 예시**

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
class Program
{
    private const int Count = 10000;
    private static readonly object _lock1 = new object();
    private static readonly object _lock2 = new object();

    private static void ThreadBody1()
    {
        for (int i = 0; i < Count; i++)
        {
            lock (_lock1)
            {
                Call2();
            }
        }
    }
    private static void ThreadBody2()
    {
        for (int i = 0; i < Count; i++)
        {
            lock (_lock2)
            {
                Call1();
            }
        }
    }
    private static void Call1()
    {
        Console.WriteLine("Call 1 - Begin");
        lock (_lock1)
        {
            Console.WriteLine("Call 1 - Busy");
        }
        Console.WriteLine("Call 1 - End");
    }
    private static void Call2()
    {
        Console.WriteLine("Call 2 - Begin");
        lock (_lock2)
        {
            Console.WriteLine("Call 2 - Busy");
        }
        Console.WriteLine("Call 2 - End");
    }

    static void Main(string[] args)
    {
        Task t1 = new Task(ThreadBody1);
        Task t2 = new Task(ThreadBody2);

        t1.Start();
        Thread.Sleep(10);
        t2.Start();

        Task.WaitAll(t1, t2);
        Console.WriteLine("Main Thread End");
    }
}
```

</details>

<br>

`t1`은 먼저 `_lock1`에 락을 걸고 `Call2()`를 호출하여, 이번에는 `_lock2`에 락을 걸고 작업을 수행한다.

`t2`도 같은 방식으로 먼저 `_lock1`, 그다음 `_lock2`에 락을 걸게 된다.

<br>

`t1_lock1` -> `t1_lock2` -> `t1_busy` -> `t2_` ... 또는

`t2_lock2` -> `t2_lock1` -> `t2_busy` -> `t1_` ...

이런 순서로 진행이 된다면 아무런 문제가 없다.

<br>

하지만 언젠가

`t1_lock1` -> `t2_lock2` 또는

`t2_lock2` -> `t1_lock1` 까지 진행된 상황에서

동시에

`t1`은 `lock1`을 건 상태에서 `lock2`를 요구하고,

`t2`은 `lock2`을 건 상태에서 `lock1`를 요구하는 상황이 온다면

결과적으로 두 스레드 중 아무도 크리티컬 섹션이 진입하지 못하게 된다.

이것이 대표적인 데드락 현상이다.

<br>

위의 프로그램을 실행해보면

처음에는 순차적으로 잘 실행되다가

어느 순간 교착 상태에 빠지게 됨을 알 수 있다.

<br>

# 데드락의 해결
---

## **해결 방안?**

### **Monitor.TryEnter()**

`Monitor.TryEnter()` 메소드는 일정 시간동안 락을 얻지 못하면 `false`를 리턴한다.

이론상으로는 그럴듯하지만, 이렇게 `false`를 리턴받는 상황이 온다는 것 자체가

락 구조에 문제가 있다는 의미가 되므로

추천하지 않는 방법이다.

<br>

### **그렇다면 어떻게 해결하나?**

데드락은 사실 완벽한 해결법이 없다?

그렇다고 한다.

대신 데드락의 특징을 통해 대응 방안을 세워볼 수는 있다.

<br>

## **데드락의 발생 조건**

1. **Mutual Exclusion(상호 배제)**
  - 여러 프로세스 또는 스레드가 공유 자원에 동시에 접근할 수 없다.
  
2. **Hold and Wait(점유 및 대기)**
  - 자원을 가지고 있는 상태(Enter lock1)에서 다른 자원(lock2)을 요청하며 기다린다.
  
3. **No Preemption(탈취 불가)**
  - 다른 스레드가 가진 자원을 강제로 뺏어올 수 없다.
  
4. **Circular Wait(순환 대기)**
   - A는 B의 종료를 기다린다. 그리고 B는 C를, C는 A를... 서로 기다린다.
   - 결국, 자신 작업 수행을 위해서는 자신 작업을 종료해야 하는 역설이 발생한다.
   
<br>

## **데드락 해결 대책**

1. **예방(Prevention)**
  - 데드락 발생 조건 4가지 중 하나라도 발생하지 않도록 원천 방지한다.

2. **회피(Avoidance)**
  - 데드락의 가능성을 배제하지 않고, 알고리즘을 통해 해결한다.
  - ex. 은행원 알고리즘
  
3. **탐지(Detection) 및 복구(Recovery)**
  - 데드락을 허용하고, 발생 시 원인을 찾아 해결한다.
  - ex. 자원 할당 그래프 알고리즘
  
4. **무시(Ignorance)**
  - 애초에 데드락이 발생해도 상관 없도록 구현하고, 데드락이 발생하면 무시한다.

<br>

## **데드락 방지 원칙**

- 크리티컬 섹션에서 또다른 크리티컬 섹션으로의 진입을 최대한 피한다.
- 가능하면 동일한 락 매개체를 사용한다.

<br>


# 정리
---

- 여러 스레드가 공유 데이터에 접근할 때는 `lock` 구문을 이용한다.
- 데드락은 해결하기 쉽지 않지만 매우 치명적이고 중요한 문제이다.
- 데드락이 발생하지 않도록 최대한 회피하거나, 데드락 발생 후 이를 수정한다.


<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://webie.tistory.com/99>
- <https://jhnyang.tistory.com/4>
- <https://nowonbun.tistory.com/427>
- <https://box0830.tistory.com/103>