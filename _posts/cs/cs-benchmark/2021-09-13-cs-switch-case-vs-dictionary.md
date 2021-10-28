---
title: C# - if-else if vs switch-case vs Dictionary
author: Rito15
date: 2021-09-13 00:01:00 +09:00
categories: [C#, C# Benchmark]
tags: [csharp]
math: true
mermaid: true
---

# 분기 처리
---

특정 변수의 값에 따라 분기를 나누어 처리해야 하는 경우,

일반적으로 `if-else if` 또는 `switch-case`문을 사용할 수 있다.

```cs
int value = someValue;

if(value == 0) DoSomething0();
else if(value == 1) DoSomething1();
else if(value == 2) DoSomething2();
```

```cs
int value = someValue;

switch(value)
{
    case 0 : DoSomething0() break;
    case 1 : DoSomething1() break;
    case 2 : DoSomething2() break;
}
```

그리고 이를 `Dictionary`를 통해 처리할 수도 있다.

```cs
// 딕셔너리 생성
Dictionary<int, Action> dict = new();

// 분기에 따른 처리 추가
dict.Add(0, DoSomething0);
dict.Add(1, DoSomething1);
dict.Add(2, DoSomething2);
```

```cs
int value = someValue;

// 처리 수행
dict[value].Invoke();
```

<br>

# 특징
---

## **[1] if-else if**

정해진 상수들에 대한 분기 처리는 컴파일 타임에 확정될 수밖에 없으며,

조건 값들을 저장하는 컬렉션과 `for` 또는 `foreach`를 활용하면

런타임에도 조건을 변경하여 사용할 수 있긴 하다.

하지만 어쨌든, 어느 경우든 간에 `if-else if`의 나열을 이용한 동일 값 비교는

대안이 없는 경우가 아니라면, 가독성, 성능, 유지보수 모든 면에서 좋지 않은 방법이다.

<br>

## **[2] switch-case**

`switch-case`를 통한 분기 처리는 컴파일 타임에 확정할 수밖에 없다.

만약, 런타임에 분기에 따른 처리를 추가/제거하려면 `Dictionary`를 써야만 한다.

`switch-case`는 실제로 `if-else if`로 해석되어 처리된다고 한다.

그리고 정수 또는 `enum` 타입의 경우, 각 `case`의 숫자가 일정 범위 내에서 연속되면

점프 테이블을 형성하여 `if-else if`보다 더 빠르게 처리된다.

<br>

## **[3] Dictionary**

컴파일 타임, 런타임에 분기를 추가하거나 제거할 수 있다.

대신, `Key`로부터 해시 계산을 하여 `Value`를 찾아오기 때문에

만약 해시 계산이 비싼 `string`의 경우 성능 차이가 크게 날 수 있다.

해시 계산이 저렴한 정수나 `enum`이라고 해도,

어쨌든 `Dictionary` 내부의 엔트리를 검색하는 과정을 거치기 때문에

점프 테이블을 생성하는 `switch-case`보다는 느릴 것으로 예상된다.

<br>

# 성능 테스트
---

- **Benchmark Dotnet**을 통해 테스트한다.

- 점프 테이블을 생성하는 `enum`, 생성하지 않는 `string` 타입에 대해 테스트한다.

- 단순히 참조 오버헤드만 비교하기 위해, 분기마다 실행되는 메소드는 최대한 간단히 작성한다.

<br>

# 테스트 1 : enum
---

## **테스트 코드**

<details>
<summary markdown="span"> 
...
</summary>

```cs
public enum MyEnum
{
    A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11,
}

[ParamsAllValues]// 모든 enum 순회
public MyEnum currentKey;

public Dictionary<MyEnum, Action> dict;
public int dest;

[GlobalSetup]
public void GlobalSetup()
{
    dict = new Dictionary<MyEnum, Action>();

    MyEnum[] allEnumValues =
        Enum.GetValues(typeof(MyEnum))
        .Cast<MyEnum>()
        .ToArray();

    foreach (var e in allEnumValues)
    {
        dict.Add(e, Job);
    }
}

[Benchmark(Baseline = true)]
public void Switch_Case()
{
    switch (currentKey)
    {
        case MyEnum.A0: Job(); break;
        case MyEnum.A1: Job(); break;
        case MyEnum.A2: Job(); break;
        case MyEnum.A3: Job(); break;
        case MyEnum.A4: Job(); break;
        case MyEnum.A5: Job(); break;
        case MyEnum.A6: Job(); break;
        case MyEnum.A7: Job(); break;
        case MyEnum.A8: Job(); break;
        case MyEnum.A9: Job(); break;
        case MyEnum.A10: Job(); break;
        case MyEnum.A11: Job(); break;
    }
}

[Benchmark]
public void If_Else()
{
    if (currentKey == MyEnum.A0) Job();
    else if (currentKey == MyEnum.A0) Job();
    else if (currentKey == MyEnum.A1) Job();
    else if (currentKey == MyEnum.A2) Job();
    else if (currentKey == MyEnum.A3) Job();
    else if (currentKey == MyEnum.A4) Job();
    else if (currentKey == MyEnum.A5) Job();
    else if (currentKey == MyEnum.A6) Job();
    else if (currentKey == MyEnum.A7) Job();
    else if (currentKey == MyEnum.A8) Job();
    else if (currentKey == MyEnum.A9) Job();
    else if (currentKey == MyEnum.A10) Job();
    else if (currentKey == MyEnum.A11) Job();
}

[Benchmark]
public void Dictionary()
{
    dict[currentKey].Invoke();
}

private void Job() => dest = (int)currentKey;
```

</details>

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/132987875-ec2cbc6a-de6f-4d48-b99c-b02fd7c30ea3.png)

`switch-case`는 값이 달라져도 언제나 일정한 시간을 소요하고,

`if-else`는 조건식을 많이 거칠수록 더 많은 시간을 소요했다.

그리고 `Dictionary`는 `switch-case`처럼 일정했지만

수행 시간이 4배 이상으로 더 많이 소요되는 것을 확인할 수 있었다.


<br>

# 테스트 2 : string
---

## **테스트 코드**

<details>
<summary markdown="span"> 
...
</summary>

```cs
public IEnumerable<object> stringKeys()
{
    yield return "0000000000";
    yield return "0000000001";
    yield return "0000000002";
    yield return "0000000003";
    yield return "0000000004";
    yield return "0000000005";
    yield return "0000000006";
    yield return "0000000007";
    yield return "0000000008";
    yield return "0000000009";
}

[ParamsSource(nameof(stringKeys))]
public string currentKey;

public Dictionary<string, Action> dict;
public volatile int dest;

[GlobalSetup]
public void GlobalSetup()
{
    dict = new Dictionary<string, Action>();

    foreach (string item in stringKeys())
    {
        dict.Add(item, Job);
    }
}

[Benchmark(Baseline = true)]
public void Switch_Case()
{
    switch (currentKey)
    {
        case "0000000000": Job(); break;
        case "0000000001": Job(); break;
        case "0000000002": Job(); break;
        case "0000000003": Job(); break;
        case "0000000004": Job(); break;
        case "0000000005": Job(); break;
        case "0000000006": Job(); break;
        case "0000000007": Job(); break;
        case "0000000008": Job(); break;
        case "0000000009": Job(); break;
    }
}

[Benchmark]
public void If_Else()
{
    if (currentKey == "0000000000") Job();
    else if (currentKey == "0000000001") Job();
    else if (currentKey == "0000000002") Job();
    else if (currentKey == "0000000003") Job();
    else if (currentKey == "0000000004") Job();
    else if (currentKey == "0000000005") Job();
    else if (currentKey == "0000000006") Job();
    else if (currentKey == "0000000007") Job();
    else if (currentKey == "0000000008") Job();
    else if (currentKey == "0000000009") Job();
}

[Benchmark]
public void Dictionary()
{
    dict[currentKey].Invoke();
}

private void Job() => dest = 123123;
```

</details>

<br>

## **결과**

![image](https://user-images.githubusercontent.com/42164422/132988493-a0d6b0ef-6c2f-4411-93f9-13643e46454c.png)

`switch-case`보다 `Dictionary`가 더 오랜 시간이 소요되는 것은 여전했다.

그런데 `switch-case`가 `if-else if`로 해석될 것이라고 생각했지만,

단순히 `if-else if`를 통해 문자열들을 직접 비교하는 것이 아니라

어떤 최적화를 통해 더 빠르게 비교를 수행하고 분기를 처리하는 것으로 보인다.

그리고 `if-else if`는 역시 모든 조건식을 순차적으로 탐색하므로

검사하는 조건식이 많을수록 더 많은 시간을 소요한다.

<br>

## **추가 : 문자열에 대한 switch-case 문 최적화**

<details>
<summary markdown="span"> 
...
</summary>

어셈블리를 디컴파일하여 CIL을 열어보면 `switch-case`는 시작 부분에

```
call       uint32 '<PrivateImplementationDetails>'::ComputeStringHash(string)
```

이런 부분이 있다.

`string`을 매개변수로 받아 `uint` 타입의 해시 결과를 리턴하는 메소드로 보인다.

이를 자세히 확인하기 위해 `DotPeek`을 이용해 컴파일러가 생성하는 코드를 살펴보았다.

```cs
public void Switch_Case()
{
  string currentKey = this.currentKey;
  switch (\u003CPrivateImplementationDetails\u003E.ComputeStringHash(currentKey))
  {
    case 1434475458:
      if (!(currentKey == "0000000009"))
        break;
      this.Job();
      break;
    case 1451253077:
      if (!(currentKey == "0000000008"))
        break;
      this.Job();
      break;
    case 1468030696:
      if (!(currentKey == "0000000007"))
        break;
      this.Job();
      break;
    case 1484808315:
      if (!(currentKey == "0000000006"))
        break;
      this.Job();
      break;
    case 1501585934:
      if (!(currentKey == "0000000005"))
        break;
      this.Job();
      break;
    case 1518363553:
      if (!(currentKey == "0000000004"))
        break;
      this.Job();
      break;
    case 1535141172:
      if (!(currentKey == "0000000003"))
        break;
      this.Job();
      break;
    case 1551918791:
      if (!(currentKey == "0000000002"))
        break;
      this.Job();
      break;
    case 1568696410:
      if (!(currentKey == "0000000001"))
        break;
      this.Job();
      break;
    case 1585474029:
      if (!(currentKey == "0000000000"))
        break;
      this.Job();
      break;
  }
}
```

각 `case` 값들이 문자열로 되어 있지 않고, 정수 값으로 되어 있다.

일단 컴파일 전 소스 코드의 `case` 문자열들을 해시 계산을 통해 미리 정수로 바꿔놓고,

런타임에 `switch-case`문이 실행될 때마다 입력되는 문자열을

`ComputeStringHash(string)` 메소드에 넣고 `uint` 정수를 반환받아

그 값을 통해 해당하는 `case`로 점프하여 실행하는 것으로 보인다.

그리고 각 `case`에 도달했더라도, 문자열이 정확히 일치하는지 재확인하는 코드도 확인할 수 있다.

</details>

<br>



# 최종 결론
---

- 컴파일 타임에 상수로 분기를 나누어 처리한다면 `switch-case`의 성능이 가장 좋다.

- 런타임에 분기를 나누어 처리한다면 `Dictionary`를 사용하는 것이 좋다.

- `if-else if`는 이런 방식으로는 쓰지 않는 것이 좋다.



<br>

# References
---
- <https://stackoverflow.com/questions/11617091/in-a-switch-vs-dictionary-for-a-value-of-func-which-is-faster-and-why>
- <https://codereview.stackexchange.com/questions/124733/switch-vs-dictionary-logic>
- <https://foreverframe.net/c-internals-string-switch-statement/>
- <https://coderethinked.com/how-c-compiler-looks-at-switch-case-statements/>