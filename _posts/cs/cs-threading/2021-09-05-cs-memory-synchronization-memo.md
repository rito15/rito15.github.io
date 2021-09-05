---
title: C# 메모리 동기화가 필요한 경우, 아닌 경우 간단 정리
author: Rito15
date: 2021-09-05 14:54:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

# 전혀 필요하지 않은 경우
---

- 싱글 스레드 환경인 경우

- 단일 공유 변수에 대해 하나의 스레드만 쓰기를 수행하는 경우

- 하나의 스레드가 공유 변수를 읽는 동안 다른 스레드가 변경할 염려가 없는 경우

- 어떤 작업을 동시에 하나의 스레드만 해야 할 필요가 없는 경우

<br>



# 원자성(Atomic) 보장이 필요한 경우
---

- 여러 스레드가 공유 변수에 쓰기를 수행하는 경우

- 완전히 동일한 순간에 접근하는 경우를 방지한다.

- `Interlocked`를 많이 사용한다.

```cs
static int sharedValue = 0;

static void TaskBody1()
{
    Interlocked.Increment(ref sharedValue);
}

static void TaskBody2()
{
    Interlocked.Decrement(ref sharedValue);
}
```

<br>



# 크리티컬 섹션(Critical Section) 생성이 필요한 경우
---

- 대상 작업을 한 번에 하나의 스레드만 수행해야 하는 경우

- 작업 도중 다른 스레드에 의한 변경이 발생하면 안되는 경우

- 단순히 읽기만 수행하는 경우에도, 읽는 동안 다른 스레드에 의한 변경이 생길 수 있다면 필요하다.

<br>

## **[1] Lock : Context Switching 방식**

- 대기하는 스레드는 CPU 자원을 양보한다.

- 대기 시간이 길어질 수 있는 경우 사용한다.

```cs
static object _lock = new object();

static void TaskBody()
{
    lock(_lock)
    {
        // Do Something
    }
}
```

<br>

## **[2] Spinlock : Busy Waiting 방식**

- 대기하는 스레드는 끊임없이 확인하며 CPU 자원을 놓지 않는다.

- 대기 시간이 매우 짧은 경우 사용한다.

```cs
const int TRUE = 1;
const int FALSE = 0;

static int isWorking = FALSE;

static void TaskBody1()
{
    while (true)
    {
        int original = Interlocked.CompareExchange(ref working, TRUE, FALSE);
        if (original == FALSE)
            break;
    }

    /* Do Something */

    isWorking = FALSE; // 여기서는 스레드 접근이 한 개라는 것이 보장되므로 동기화 필요 X
}

static void TaskBody2()
{
    int original;
    do
    {
        original = Interlocked.CompareExchange(ref working, TRUE, FALSE);
    }
    while (original == TRUE);

    /* Do Something */

    working = FALSE;
}
```

<br>

## **참고**

`CompareExchange()` 대신 `Exchange(ref isWorking, TRUE)`를 쓸 수도 있지만,

`isWorking` 변수의 의미와 목적에 맞게 사용하려면

`CompareExchange()`를 통해 진짜로 크리티컬 섹션에 진입하는 경우에만

`TRUE`로 값을 바꿔주는 것이 논리적으로 타당하다.

<br>


