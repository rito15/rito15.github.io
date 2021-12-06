---
title: Fisher-Yates Shuffle 간단 정리
author: Rito15
date: 2021-12-06 18:00:00 +09:00
categories: [Algorithm, Algorithms]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# 1. Original Fisher-Yates Shuffle
---

## **알고리즘**

<details>
<summary markdown="span">
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/144822308-2277ca67-fcb8-4f57-bc68-c56832b40251.png)

길이 `n`인 배열이 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144822332-40ad9ce9-4702-480d-b451-362100bae92a.png)

`[0, n-1]` 범위에서 무작위 인덱스를 뽑아, 그 위치의 원소를 새로운 배열의 인덱스 `0` 위치에 넣는다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144822362-3932a7ae-93df-490a-bb03-ee2fd0d61389.png)

기존 배열에서 `n-1` 인덱스에 있는 원소를 구멍 뚫린 위치에 채워 넣는다.

뒤에서 한 칸씩 밀어서 빈 칸을 채우는 방법도 있겠으나, 그러면 **O(n)**에 해당하므로 정말 굉장히 비효율적이다.

끝에서 꺼내어 채워 넣으면 **O(1)**이므로 쓸만하다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144822407-b3a8eb6e-95cf-4140-81af-1d3790decc47.png)

이번에는 `[0, n-2]` 범위에서 무작위 인덱스를 뽑아 새로운 배열의 인덱스 `1`에 넣고,

마찬가지로 `n-2` 인덱스의 원소를 구멍 뚫린 위치에 채워 넣는다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144822491-af2c08db-99af-45a9-aa2d-db3751c524bb.png)

새로운 배열을 모두 채울 때까지 반복하면 된다.

</details>

<br>

## **단점**
- 기존 배열 크기만큼의 새로운 배열이 필요하다.

<br>

## **소스 코드(C#)**

<details>
<summary markdown="span">
...
</summary>

```cs
private static System.Random random = new System.Random();

// Original Fisher-Yates Shuffle
private void Shuffle<T>(ref T[] array)
{
    int n = array.Length;
    T[] newArray = new T[n];

    for(int i = 0; i < n; i++)
    {
        // 현재 배열 내에서 셔플되지 않은 원소들 중 마지막 원소의 인덱스
        int last = n - 1 - i;

        // 1. 무작위 위치의 원소를 새로운 배열에 차곡차곡 넣기
        int r = random.Next(0, last + 1); // [0, n - 1 - i]
        newArray[i] = array[r];

        // 2. 기존 배열 빈칸 채우기
        array[r] = array[last];
    }

    array = newArray;
}
```

</details>

<br>


# 2. Modern Fisher-Yates Shuffle
---

## **알고리즘**

<details>
<summary markdown="span">
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/144824038-d2668452-f12c-4c03-9e2a-1c19d64ba64f.png)

길이 `n`인 배열이 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144824061-bb0073da-76b5-448a-a32d-e8a57a3ecdbd.png)

`[0, n-1]` 범위에서 무작위 인덱스를 뽑아, 그 원소를 인덱스 `0`에 위치한 원소와 서로 바꾼다.

`[1, n-1]`이 아니라 자기 자신을 포함하는 `[0, n-1]` 범위에서 뽑아, 위치가 바뀌지 않는 경우의 수도 포함하도록 한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144824102-f2999faa-21d1-48d0-8762-cda7f750b884.png)

다음에는 `[1, n-1]` 범위에서 무작위 인덱스를 뽑고, 그 원소를 인덱스 `1`에 위치한 원소와 서로 바꾼다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144824198-ee18c862-574d-427f-8387-c2f33aace941.png)

`[i, n-1]` 인덱스 범위의 무작위 원소와 인덱스 `i` 의 원소를 바꾸는 동작을

`i = 0`부터 `i = (n - 2)` 까지만 반복하고 끝낸다.

마지막 원소(인덱스 `n-1`)는 바꿀 대상이 자기 자신밖에 없으므로 포함하지 않는다.

</details>

<br>

## **장점**
- 새로운 배열이 필요하지 않다.

<br>

## **소스 코드(C#)**

<details>
<summary markdown="span">
...
</summary>

```cs
private static System.Random random = new System.Random();

// Modern Fisher-Yates Shuffle
private void Shuffle<T>(T[] array)
{
    int n = array.Length;
    int last = n - 2;

    for (int i = 0; i <= last; i++)
    {
        int r = random.Next(i, n); // [i, n - 1]
        Swap(i, r);
    }

    // Local Method
    void Swap(int idxA, int idxB)
    {
        T temp      = array[idxA];
        array[idxA] = array[idxB];
        array[idxB] = temp;
    }
}
```

</details>

<br>


# References
---
- <https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle>


<br>

<br>

# Note
---

<details>
<summary markdown="span">
푸념
</summary>

<br>

어떤 알고리즘 혹은 구현 방법에 대해 구글링 했을 때,

간략하고 명쾌하게 핵심만 짚어내는 블로그 포스트가 없는 경우가 있다.

대충 알고 있던 알고리즘을 구현하려고 보니 확실히 떠오르지 않아서 구글링을 하는데

정리되지 않은 장황한 설명과, 조금 지저분해 보이는 코드가 가득한 글들이 보인다.

<br>

공부하려는 목적이라면 전문을 읽어보면 되기 때문에 딱히 상관 없겠으나

한 1~2분 동안 빠르게 핵심만 살펴보고 '아, 이거였지!' 하고 싶은 상황에서는 아쉬운 부분이다.

<br>

사실 개발 블로그를 운영하는 가장 큰 이유 중 하나가 이것이다.

내 방식대로, 가끔은 아주 간략하게 핵심만 메모하고

나중에 기억이 나지 않을 때 빠르게 살펴보는 것.

이 포스트도 마찬가지로 핵심만 뽑아 작성하였다.

</details>

<br>