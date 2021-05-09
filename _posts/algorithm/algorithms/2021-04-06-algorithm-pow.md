---
title: O(logn) 거듭제곱 알고리즘
author: Rito15
date: 2021-04-06 18:00:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# Summary
---

- 일반적으로 $$ O(n) $$ 시간복잡도로 수행하는 거듭제곱 계산을 $$ O(log_{2}n) $$ 의 시간복잡도로 수행할 수 있는 알고리즘

- 2진수 연산을 이용한다.

<br>

# Details
---

$$a^n$$을 계산하는 가장 쉬운 방법은 $$a$$를 $$n$$ 번 곱하는 것이다.

예를 들어 $$ 4^9 $$을 구하려면 $$ 4 \cdot 4 \cdot 4 \cdot 4 \cdot 4 \cdot 4 \cdot 4 \cdot 4 \cdot 4 $$를 계산하면 된다.

하지만 이렇게 되면 $$ n - 1 $$ 번의 곱셈을 수행하므로 시간복잡도는 $$ O(n) $$에 해당한다.

<br>

거듭제곱의 특징은 같은 숫자(밑)을 연달아 곱한다는 것이다.

이때 지수를 살펴보면 곱셈이 아닌 덧셈으로 표현됨을 알 수 있다.

$$ 4^9 = 4^{1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1} $$

이 점을 이용해서, 덧셈으로 이루어진 지수부의 계산을 보다 빠른 알고리즘으로 수행하면 시간복잡도를 줄일 수 있다.

<br>

우선, 지수부를 이진수로 고친다.

$$ 4^9 $$에서 $$ 9 $$를 $$ 1001_{(2)} $$로 고치고,

각 자리수가 1인 이진수끼리의 덧셈으로 구성한다.

$$ 1001_{(2)} = 1000_{(2)} + 0001_{(2)} $$

그리고 이것을 지수부가 아닌 전체 계산으로 고려하면 

$$ 4^9 = 4^8 \cdot 4^1 $$이 된다.

여덟 번의 곱셈을 한 번의 곱셈으로 수행할 수 있게 되는 것이다.

<br>

이를 계산하기 위해서 지수부의 이진수 각 자리 숫자가 1인 경우를 차례대로 순회할 수 있어야 하는데, (`<<` 연산)

$$ a = a * a $$를 반복하면 지수부는 $$ 1_{(2)}, 10_{(2)}, 100_{(2)}, ... $$이므로 

지수를 `<<`연산하는 것과 같은 효과를 얻을 수 있다.

그리고 $$ a $$의 지수와 $$ n $$을 `&`연산하여 나온 결과가 0이 아닌 경우들만 모아서 곱해주면

답을 구할 수 있다.

<br>

## **시간복잡도**

지수부를 살펴볼 때, 1, 2, 4, 8, ... 로 순회하므로

지수가 n일 때 최대 $$ log_{2}n $$ 번 검사하게 된다.

따라서 시간복잡도는 $$ O(log_{2}n) $$에 해당한다.

<br>

# Pseudo Code
---

```
input : a, n

m = 1
res = 1

while (m <= n)
    if ((m & n) != 0)
        res *= a
    a *= a
    m <<= 1

return res
```

<br>

위 알고리즘을 살짝 수정하여

지역변수 m을 `<<` 연산하는 방식에서, 

지역변수 m을 아예 사용하지 않고 n을 `>>`연산하는 방식으로 바꾸어 공간을 절약할 수 있다.

```
input : a, n

res = 1

while (n > 0)
    if ((n & 1) != 0)
        res *= a
    a *= a
    n >> 1

return res
```


<br>

# Source Code
---

```cs
// O(n) 복잡도의 a^n
public static int Pow(int a, int n)
{
    int result = 1;
    for(int i = 0; i < n; i++)
        result *= a;
    return result;
}

// O(log n) 복잡도의 a^n
public static int Pow1(int a, int n)
{
    int res = 1;
    int m = 1;

    while (m <= n)
    {
        if((m & n) != 0)
            res *= a;

        a *= a;
        m <<= 1;
    }

    return res;
}

public static int Pow2(int a, int n)
{
    int res = 1;

    while (n > 0)
    {
        if ((n & 1) != 0)
            res *= a;

        a *= a;
        n >>= 1;
    }

    return res;
}
```

<br>

# Test
---

- 각각 100만 번 씩 수행

![image](https://user-images.githubusercontent.com/42164422/113708757-96cfa080-971c-11eb-93e8-776b719092a9.png)


<br>

# References
---

- <https://torbjorn.tistory.com/361>