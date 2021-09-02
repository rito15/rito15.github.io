---
title: 동적 계획법(Dynamic Programming, DP)
author: Rito15
date: 2021-09-02 16:40:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# 개념
---

## **동적 계획법**

문제를 여러 개의 하위 문제들로 나누어 해결 및 기록한 뒤

이를 이용해 최종적인 문제를 해결해나가는 방법.

<br>

다시 말해,

문제 해결 과정을 메모리에 기록하고 이를 바탕으로 이후의 문제를 해결해나가는 방법이다.

한 번 기록한 적이 있다면 다시 계산할 필요 없이 곧바로 답을 도출해낼 수 있다.

<br>

## **메모이제이션(Memoization)**

동적 계획법의 핵심 개념.

하위 문제의 답을 구한 뒤 메모리에 저장하는 것을 의미한다.

이렇게 저장된 값은 동일한 하위 문제의 결과값이 필요할 때 재계산 없이 곧바로 사용될 수 있다.

<br>

# 예제 - 피보나치
---

- 동적 계획법의 기초 예제로 많이 볼 수 있는 피보나치.

```
Fibonacci(0) = 0
Fibonacci(1) = 1
Fibonacci(n) = Fibonacci(n - 1) + Fibonacci(n - 2), (n >= 2)
```

<br>

## **[1] Top-down**

- 재귀를 통해 문제를 하위 문제들로 나누고, 재귀의 결과를 합산하는 방식

- 재귀의 결과를 합산하는 과정에서 하위 문제들의 답을 메모리에 저장한다.

```cs
private static int[] fibonacciMemory = new int[100];

private static int GetFibonacciTopDown(int n)
{
    if (n <= 1) return n;

    // 이미 기록되어 있다면 곧바로 답을 도출한다.
    if (fibonacciMemory[n] > 0)
        return fibonacciMemory[n];

    // 재귀적으로 하위 문제들의 계산을 수행한다.
    return fibonacciMemory[n] =
        GetFibonacciTopDown(n - 1) + GetFibonacciTopDown(n - 2);
}
```

<br>

## **[2] Bottom-up**

- 문제의 답을 얻을 때까지 반복을 통해 하위 문제들을 차례로 순회한다.

- 반복 과정에서 하위 문제들의 답을 메모리에 저장한다.

```cs
private static int[] fibonacciMemory = new int[100];

// 이미 계산 완료된 마지막 인덱스
private static int lastCached;

// 문제 해결을 위한 기본 상태를 초기화한다.
private static void InitFibonacciMemory()
{
    fibonacciMemory[0] = 0;
    fibonacciMemory[1] = 1;
    lastCached = 1;
}

private static int GetFibonacciBottomUp(int n)
{
    //fibonacciMemory[0] = 0; // InitFibonacciMemory() 메소드로 분리
    //fibonacciMemory[1] = 1;

    if (n <= 1) return n;

    // 이미 기록되어 있다면 곧바로 답을 도출한다.
    if (fibonacciMemory[n] > 0)
        return fibonacciMemory[n];

    // 반복을 통해 하위 문제들의 계산을 수행한다.
    // 아직 계산되지 않은 지점부터 수행함으로써 비용을 절약한다.
    for (int i = lastCached + 1; i <= n; i++)
    {
        fibonacciMemory[i] = fibonacciMemory[i - 1] + fibonacciMemory[i - 2];
    }

    // 계산 완료 지점을 기록한다.
    lastCached = n;
    return fibonacciMemory[n];
}
```

<br>


# References
---
- <https://velog.io/@polynomeer/동적-계획법Dynamic-Programming>
- <https://wooder2050.medium.com/동적계획법-dynamic-programming-정리-58e1dbcb80a0>
- <https://janghw.tistory.com/entry/알고리즘-Dynamic-Programming-동적-계획법>
- <https://reakwon.tistory.com/3>
