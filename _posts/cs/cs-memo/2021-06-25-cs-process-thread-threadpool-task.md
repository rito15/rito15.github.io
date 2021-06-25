---
title: Process, Thread, ThreadPool, Task 개념 간단 정리
author: Rito15
date: 2021-06-25 21:21:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, process, thread, task]
math: true
mermaid: true
---


# Process
---

- 메모리에 적재되어 실행되는 프로그램

- 운영체제로부터 자원을 할당받아 수행되는 작업의 단위

- **Code, Data, Heap, Stack** 메모리 공간을 독립적으로 갖는다.


<br>

# Thread
---

- 프로세스의 자원을 사용하는 실행 흐름의 단위

- 프로세스의 **Code, Data, Heap** 영역을 공유한다.

- 각 스레드마다 **Stack** 영역만 독립적으로 갖는다.

- 컨텍스트 스위칭이 발생할 때 **Stack** 정보를 비롯해 간단한 정보만 저장하기 때문에, 프로세스의 컨텍스트 스위칭보다 빠르다.

- C#에는 `Thread` 클래스가 있다.

- 기본적으로 `Foreground` 상태로 동작하므로, 사용에 유의해야 한다.

- `Foreground` 스레드는 부모 스레드가 중단되어도 함께 중단되지 않고 계속 동작한다. (프로그램 종료 시, 수동적으로 스레드를 종료하지 않으면 미아로 남아 계속 수행된다.)

- 따라서 부모 스레드에 종속적인 생명 주기를 가지려면 `IsBackground = true`로 설정해야 한다.

<br>

## 예시

```cs
private static void ThreadBody()
{
    // Do Something
}

public static void Main()
{
    // 자식 스레드 생성 및 시작
    Thread t = new Thread(ThreadBody);
    t.Start();

    // 배경 스레드로 동작시키기
    //t.IsBackground = true;

    // 자식스레드 종료 기다리기
    t.Join();
}
```

<br>

# ThreadPool
---

- C#에 `ThreadPool` 클래스가 있다.

- Thread의 생성/해제 오버헤드를 방지하기 위해 사용한다.

- 미리 일정 개수의 Thread를 만들어놓고, 작업 요청 시 현재 사용 가능한 Thread에 할당하여 수행한다.

<br>

## 예시

```cs
// ThreadPool을 사용할 경우, object 타입 매개변수 필요
private static void ThreadBody(object state)
{
    // Do Something
}

public static void Main()
{
    // ThreadPool의 작업 큐에 간단히 등록
    ThreadPool.QueueUserWorkItem(ThreadBody);

    // ThreadPool은 Join 기능 없음
}
```

<br>

# Task
---

- C#에 `Task` 클래스가 있다.

- ThreadPool을 더 편리하게 사용하도록 만든 라이브러리이다.

<br>

## 예시

```cs
private static void ThreadBody()
{
    // Do Something
}

public static void Main()
{
    // Task 생성 및 시작
    Task t = new Task(ThreadBody);
    t.Start();

    // Task 종료 기다리기
    t.Wait();

    // 여러 Task의 종료를 기다리려면
    // Task.WaitAll(t1, t2, ...);
}
```

<br>

# Thread vs. Task
---

## **Thread**

- 스레드가 생성되어 장시간 동작해야 되는 경우 사용한다.

<br>

## **Task**

- 단발적이고 짧은 동작들을 수행하는 경우 사용한다.

- 장시간 동작해야 하는 경우, ThreadPool의 Thread를 하나 점유하지 않도록 다음과 같이 생성한다.

```cs
// Long Running
Task t = new Task(TaskBodyMethod, TaskCreationOptions.LongRunning);
```


