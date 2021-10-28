---
title: C# - If vs try-catch 성능
author: Rito15
date: 2021-08-09 14:41:00 +09:00
categories: [C#, C# Benchmark]
tags: [csharp]
math: true
mermaid: true
---

# Note
---

개발을 하다보면 고민되는 경우가 많다.

예외 조건을 처리할 때 `if`로 예외를 회피할지, `try-catch`로 처리할지,

실제 성능은 어떻게 될지도 궁금한 부분이다.

<br>

`try-catch`는 예외가 발생하지 않으면 성능 소모가 없다고도 하고,

성능 소모가 있지만 `O(1)`이라고도 하고,

찾아보면 다양한 주장들을 확인해볼 수 있다.

<br>

대신 공통적인 사실은

`try-catch`를 통해 예외를 핸들링하게 되면

무조건 `if`보다 성능 소모가 크다는 점이다.

`try-catch`는 예외 발생 지점의 스택을 거슬러 올라가서

모두 추적하고 기록하게 되는데,

이 과정에서 성능 소모가 크게 발생한다는 것이다.

<br>

이제 몇가지 테스트 케이스를 통해서 성능을 테스트하고,

`if`와 `try-catch` 선택을 위한 원칙을 세우려고 한다.

성능 테스트에는 `Benchmark DotNet`을 이용한다.

<br>

# Test Case 1
---

```cs
int[] array = new int[1000];

for (int i = min; i < max; i++)
{
    array[i] = i;
}
```

배열의 인덱스를 참조하여, 해당 위치에 간단히 값을 넣는다.

잘못된 인덱스를 참조하게 되면 `IndexOutOfRangeException`이 발생한다.

<br>

## **테스트 대상**

```cs
// [1]
for (int i = min; i < max; i++)
{
    if (i < 0) continue;

    array[i] = i;
}

// [2]
for (int i = min; i < max; i++)
{
    if (i < 0) continue;
    if (i >= array.Length) continue;

    array[i] = i;
}

// [3]
for (int i = min; i < max; i++)
{
    try
    {
        array[i] = i;
    }
    catch(IndexOutOfRangeException)
    {
        continue;
    }
}

// [4]
for (int i = min; i < max; i++)
{
    try
    {
        array[i] = i;
    }
    catch(Exception)
    {
        continue;
    }
}
```

모두 공통적으로 잘못된 인덱스 참조 시 `continue`를 통해 다음 반복을 이어나간다.

`[1]`에서는 인덱스의 하한만 검사하고,

`[2]`에서는 인덱스의 하한과 상한을 모두 검사한다.

`[3]`에서는 `IndexOutOfRangeException`만 `catch`를 통해 체크하고,

`[4]`에서는 `Exception`으로 모든 예외를 체크한다.

<br>

## **테스트 조건**

`min`, `max` 값을 다음과 같이 설정하여 테스트를 진행한다.

- `-1000, 0` (모두 예외 발생)

- `-500, 500`

- `-100, 900`

- `0, 1000` (예외 미발생)

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/128664736-ee4a8dcd-aab2-45ac-822d-854d86196a82.png)

예외가 발생하는 경우에는 비교조차 불가능할 정도로 `If`가 빨랐으며,

심지어 예외가 발생하지 않는 경우에도 `If`가 빠르다.

<br>

## **결론**

- 항상 `If`가 `try-catch`보다 성능이 좋다.

- 예외가 발생하는 경우, 압도적으로 `If`의 성능이 좋다.

- `catch`를 통해 특정 예외만 검사하는 것과 `Exception`을 모두 검사하는 것은 성능 차이가 없다.

<br>


# Test Case 2
---

```cs
public class TestClass
{
    public float value;

    public void SetValue(float value)
    {
        this.value = value;
    }
}

public TestClass[] array = new TestClass[1000];

[Params(1000, 900, 500, 100, 0)]
public int NullCount;

[GlobalSetup]
public void GlobalSetup()
{
    for (int i = NullCount; i < 1000; i++)
    {
        array[i] = new TestClass();
    }
}

[GlobalCleanup]
public void GlobalCleanUp()
{
    for (int i = 0; i < 1000; i++)
    {
        array[i] = null;
    }
}
```

<br>

```cs
for (int i = 0; i < 1000; i++)
{
    array[i].SetValue(i);
}
```

크기 `1000`인 배열에 간단한 클래스 객체를 생성해 넣는다.

`NullCount`에 따라 `null`인 영역의 비율이 정해진다.

그리고 해당 인덱스에 있는 객체로부터 `.SetValue()`를 호출하며,

객체가 `null`일 경우 `NullReferenceException`이 발생하게 된다.

<br>

## **테스트 대상**

```cs
// [1]
for (int i = 0; i < 1000; i++)
{
    if (array[i] != null)
        array[i].SetValue(i);
}

// [2]
for (int i = 0; i < 1000; i++)
{
    array[i]?.SetValue(i);
}

// [3]
for (int i = 0; i < 1000; i++)
{
    try
    {
        array[i].SetValue(i);
    }
    catch(NullReferenceException)
    {
        continue;
    }
}

// [4]
for (int i = 0; i < 1000; i++)
{
    try
    {
        array[i].SetValue(i);
    }
    catch(Exception)
    {
        continue;
    }
}
```

`[1]`에서는 `if`를 통해 `null`인지 검사하여, `null`이 아닌 경우에만 메소드를 호출하고

`[2]`에서는 널 조건 연산자 `?`를 통해 메소드를 호출한다.

`[3]`에서는 `try-catch`를 통해 `NullReferenceException`을 검사하고,

`[4]`에서는 모든 예외를 검사한다.

공통적으로, 객체가 `null`일 경우 아무 것도 수행하지 않는다.

<br>

## **테스트 조건**

배열 내 `1000`개의 객체 중 `null`인 객체의 개수를 각각 테스트마다 다르게 지정한다.

`0`, `100`, `500`, `900`, `1000`개로 지정하여 각각 테스트한다.

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/128670006-f737ea46-4713-467e-a41f-19dbc7d4559e.png)

<br>

## **결론**

- 예외가 발생하지 않을 때도 `try-catch`가 느리다.

- 예외가 발생하면 압도적으로 `try-catch`가 느리다.

- `if`에 의한 `null` 조건 분기와 `?` 연산자 사용은 성능 차이가 없다.

- `try-catch`에서 예외를 특정하는 것과 모든 예외를 처리하는 것은 성능 차이가 없다.

<br>


# 최종 결론
---

`if`와 `try-catch`에 관한 개발자들의 여론에 비해

이번 테스트 결과는 신빙성이 없을 정도로 `try-catch`의 성능이 압도적으로 좋지 않았다.

그래서 더 다양한 테스트 케이스를 설정하고 다시 검증을 하는 것이 좋을 것 같다.

<br>

그래도 테스트 결과만으로 결론을 내리고, 원칙을 세워보자면 다음과 같다.

1. `if`로 검사할 수 없는 예외는 `try-catch`로 처리한다.

2. `if`로 검사할 수 있는 예외는 최대한 `if`로 처리한다.

3. 예외 종류에 관계 없이 동일한 처리를 수행한다면, 굳이 `catch`를 늘려서 예외를 특정하여 나열할 필요 없이 `Exception`으로 받아 처리해도 된다.


<br>

# References
---
- <https://stackoverflow.com/questions/1308432/do-try-catch-blocks-hurt-performance-when-exceptions-are-not-thrown>
- <https://stackoverflow.com/questions/39710941/try-catch-vs-if-performance-in-c-sharp>
- <https://www.c-sharpcorner.com/blogs/impact-of-trycatch-on-performance>
- <https://juststudy.tistory.com/43>
- <https://www.jacksondunstan.com/articles/3368>