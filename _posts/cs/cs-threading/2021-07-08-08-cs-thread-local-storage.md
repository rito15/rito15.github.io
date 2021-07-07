---
title: C# TLS(Thread Local Storage)
author: Rito15
date: 2021-07-08 01:08:00 +09:00
categories: [C#, C# Threading]
tags: [csharp, thread]
math: true
mermaid: true
---

<br>

# 메모리 구조
---

![image](https://user-images.githubusercontent.com/42164422/124772075-a3ab9c80-df76-11eb-919e-f6700961037e.png)


<br>

# TLS(Thread Local Storage)
---

**Data** 영역의 전역 변수, **Heap** 영역의 객체는 모든 스레드가 공유한다.

그리고 **Stack** 영역의 지역 변수(또는 멤버 변수)는 해당 블록 내에서만 사용된다.

따라서 기본적으로 각각의 스레드마다 고유하게 갖는 메모리 영역은 없다.

이를 만들어 줄 수 있는 것이 바로 `TLS`이다.

<br>

`TLS`는 각각의 스레드마다 자기만의 변수를 저장할 수 있게 해준다.

따라서 이를 활용하여, 공유 변수로 인해 빈번한 스레드 동기화가 일어날 수 있는 경우

임시로 TLS에 저장하고 나중에 공유 변수에 동기화하는 방식으로

스레드 동기화에 의한 성능 저하를 줄여줄 수 있다.

<br>

# ThreadLocal&lt;T&gt;
---

- C#의 `ThreadLocal<T>` 타입은 각각의 스레드가 `TLS`를 사용할 수 있게 한다.

<br>

## **[1] 정적 변수 사용**

```cs
private static int tlValue;

private static void ThreadBody(int value)
{
    tlValue = value;

    Thread.Sleep(1000);
    Console.WriteLine($"ID : {Thread.CurrentThread.ManagedThreadId}, Value : {tlValue}");
}

public static void Run()
{
    Thread[] threads = new Thread[4];

    for (int i = 0; i < threads.Length; i++)
    {
        threads[i] = new Thread(() => ThreadBody(i));
        threads[i].IsBackground = true;
        threads[i].Start();
    }

    for (int i = 0; i < threads.Length; i++)
    {
        threads[i].Join();
    }
}
```


위와 같이 정적 변수를 참조하는 경우, 당연히 모든 스레드가 공유한다.

<br>

## **[2] TLS 사용**

```cs
private static ThreadLocal<int> tlValue = new ThreadLocal<int>();

private static void ThreadBody(int value)
{
    tlValue.Value = value;

    Thread.Sleep(1000);
    Console.WriteLine($"ID : {Thread.CurrentThread.ManagedThreadId}, Value : {tlValue.Value}");
}

public static void Run()
{
    Thread[] threads = new Thread[4];

    for (int i = 0; i < threads.Length; i++)
    {
        threads[i] = new Thread(() => ThreadBody(i));
        threads[i].IsBackground = true;
        threads[i].Start();
    }

    for (int i = 0; i < threads.Length; i++)
    {
        threads[i].Join();
    }
}
```

이렇게 `ThreadLocal<T>` 변수를 사용하면

각각의 스레드가 개별적으로 변수를 가질 수 있게 된다.

<br>

## **초깃값 설정하기**

- 따로 스레드바디에서 직접 값을 지정하지 않아도, 생성자에서 초깃값을 지정해줄 수 있다.

```cs
private static int number = 0;
private static ThreadLocal<int> tlNumber 
    = new ThreadLocal<int>(() => Interlocked.Increment(ref number));
```

이렇게 작성하면 각각의 스레드가 처음 `tlNumber` 변수에 접근할 때마다

차례대로 `1`, `2`, ... 값을 초기화해준다.

<br>

## **생성 여부 확인하기**

다음과 같은 경우들을 생각해볼 수 있다.

- 스레드가 생성될 때만 TLS 변수를 만들고 값을 부여하려는 경우

- 명시적으로 스레드를 만들지 않고, `ThreadPool`의 스레드를 이용하는 경우

이런 경우에 해당 TLS 변수가 이미 생성되었는지, 초기 생성 순간인지를 파악하고

그에 따른 분기 처리를 해야할 수 있다.

이럴 때 `.IsValueCreated` 프로퍼티를 통해 생성 여부를 `bool` 타입으로 확인할 수 있다.

<br>

## **제거하기**

- `.Dispose()` 메소드를 통해 메모리에서 해제할 수 있다.

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://joyeeeeeee.blogspot.com/2018/02/system-stack1.html>


