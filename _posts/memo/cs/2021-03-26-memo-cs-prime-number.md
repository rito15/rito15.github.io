---
title: Prime Number(소수)
author: Rito15
date: 2021-03-26 18:12:00 +09:00
categories: [Memo, Csharp Memo]
tags: [csharp]
math: true
mermaid: true
---

# Memo
---

## 1. 소수인지 확인하기

```cs
/// <summary> 지정한 수가 소수인지 확인 </summary>
public static bool IsPrime(int value)
{
    bool isEvenNumber = (value % 2) == 0;

    // 짝수일 경우 2만 소수
    if (isEvenNumber) return value == 2;

    // 1은 소수 아님
    if (value == 1) return false;

    // 제곱근까지만 확인
    int sqrtNum = (int)Math.Sqrt(value);

    // 제곱근보다 작은 홀수들을 순회하여, 약수가 존재하면 소수가 아님
    for (int i = 3; i <= sqrtNum; i += 2)
    {
        if((value % i) == 0)
            return false;
    }

    return true;
}
```

## 2. 근처의 소수 확인하기

```cs
/// <summary> 지정한 수보다 작거나 같은 수 중에서 가장 큰 소수 </summary>
public static int GetMaxPrimeLessThan(int value)
{
    if (value < 2)
        throw new ArgumentException("Prime number must be greater than 1");

    else if (value == 2)
        return value;

    for (int i = (value - 1) | 1; i > 1; i -= 2)
    {
        if(IsPrime(i))
            return i;
    }

    throw new Exception("Unreachable Code");
}

/// <summary> 지정한 수보다 크거나 같은 수 중에서 가장 작은 소수 </summary>
public static int GetMinPrimeGreaterThan(int value)
{
    if (value <= 2) return 2;

    for (int i = value | 1; i <= int.MaxValue; i += 2)
    {
        if (IsPrime(i))
            return i;
    }

    throw new Exception("Unreachable Code");
}
```

<br>

# Example
---

- 테스트 값 : 45, 89, (int.MaxValue - 1)

![image](https://user-images.githubusercontent.com/42164422/112610668-4cb70700-8e60-11eb-8502-ac6300917077.png)