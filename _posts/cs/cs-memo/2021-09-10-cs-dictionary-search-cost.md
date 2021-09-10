---
title: C# Dictionary 탐색 성능 - 선형 탐색과 비교
author: Rito15
date: 2021-09-11 00:01:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Curiosity
---

`Dictionary<TKey, TValue>`는 해시 테이블 자료구조의 제네릭 구현 클래스로서,

**Key-Value** 꼴로 데이터를 저장하고

**Key**에 대한 해시 계산을 통해 **Value**를 탐색할 수 있다.

그렇다면 **Key-Value**를 저장하는 배열의 선형 탐색과 비교했을 때,

`Dictionary`의 탐색 성능은 어느 정도일까?

<br>

# Benchmark
---

**Benchmark DotNet**을 이용하여

`<TKey, TValue>` 꼴의 딕셔너리, 이를 페어로 저장하는 배열을 비교한다.

`TKey`와 `TValue`는 임의의 클래스 타입을 사용한다.

```cs
public class Data { } // 임의의 클래스 타입

public class Pair
{
    public Data key;
    public Data value;

    public Pair()
    {
        this.key = new Data();
        this.value = new Data();
    }
}

public Dictionary<Data, Data> dict;
public Pair[] array;
```

<br>

```cs
[Params(6, 8, 10, 12, 14, 16, 18)]
public int lastIndex;

public Data targetKey;
public Data destValue;

// 벤치마크 실행 시 초기 설정
[GlobalSetup]
public void GlobalSetup()
{
    array = new Pair[100];

    for (int i = 0; i < 100; i++)
    {
        array[i] = new Pair();
    }
}

// 파라미터를 바꾸어 반복을 시작할 때마다 실행
[IterationSetup]
public void IterationSetup()
{
    // 딕셔너리의 Capacity를 개수(lastIndex)에 딱 맞게 설정
    dict.Clear();
    dict.EnsureCapacity(lastIndex);

    for (int i = 0; i <= lastIndex; i++)
    {
        dict.Add(array[i].key, array[i].value);
    }

    targetKey = array[lastIndex].key;
}
```


매 벤치마크마다 `lastIndex` 값을 변경하며,

`targetKey`는 배열의 `lastIndex`위치에 들어있는 **Key**로 초기화한다.

<br>

```cs
[Benchmark(Baseline = true)]
public void DictionarySearch()
{
    destValue = dict[targetKey];
}

[Benchmark]
public void ArrayLinearSearch()
{
    // 일치하는 요소를 찾을 때까지 인덱스 0부터 선형 탐색
    for (int i = 0; i <= lastIndex; i++)
    {
        if (array[i].key == targetKey)
        {
            destValue = array[i].value;
            break;
        }
    }
}
```

딕셔너리는 단순히 키로 대상을 탐색하고,

배열은 일치하는 키를 찾을 때까지 선형 탐색한다.

예를 들어 `lastIndex`가 15일 때, 딕셔너리는 지정된 키로 탐색하고

배열은 인덱스 0부터 15까지 탐색하여 키가 일치하는 목표를 찾아낸다.

<br>

# Result
---

![image](https://user-images.githubusercontent.com/42164422/132871643-d31fee4d-f575-44bc-966f-6dcadc3de3a5.png)

딕셔너리의 해시 탐색은 동일 타입의 배열 인덱스를 `0`부터 `10` ~ `12`까지 선형 탐색하는 비용과 비슷하다는 것을 확인할 수 있었다.

물론 `TKey` 타입에 대한 해시 비용에 따라 천차만별로 달라질 수 있으므로,

단순히 호기심 해결용으로 보면 될 듯하다.

참고로, `TKey` 타입이 `int`일 때도 비슷한 결과를 보였다.

