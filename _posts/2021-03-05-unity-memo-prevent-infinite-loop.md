---
title: 무한 루프를 방지하는 작은 습관
author: Rito15
date: 2021-03-05 04:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Note
---
- 유니티 엔진에서 무한루프가 발생하면 에디터가 그대로 뻗어버린다.

- 따라서 혹시나 무한루프가 될 가능성이 있는 코드를 인지했다면, 간단한 체크 로직을 넣어주는 것이 좋다.

```cs
while( /* condition */ )
{
    // codes..
}
```

이런 코드에서, 간단히 다음처럼 추가해준다.


```cs
int loopNum = 0;

while( /* condition */ )
{
    // codes..

    if(loopNum++ > 1000)
        throw new Exception("Infinite Loop");
}
```

이렇게 작성하면 무한 루프가 발생했을 때 유니티 엔진이 뻗어버리지 않고, 무한 루프에서 탈출하고 콘솔에 예외를 출력해줄 수 있다.

<br>

하지만 매번 이러면 번거롭기도 하고, 혹시나 작성하고 잊을 수도 있으니 에디터 전용으로 래핑해줄 수 있다.

## **InfineteLoopChecker**

```cs
/// <summary> 무한 루프 검사 및 방지 </summary>
public static class InfiniteLoopChecker
{
    private static int infiniteLoopNum = 0;

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void Reset() => infiniteLoopNum = 0;

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void Check(int maxLoopNumber = 10000)
    {
        if(infiniteLoopNum++ > maxLoopNumber)
            throw new Exception("Infinite Loop Detected.");
    }
}
```

<br>

그리고 while 루프 코드에서 다음처럼 사용하면 된다.

```cs
InfiniteLoopChecker.Reset();

while( /* condition */ )
{
    // codes..

    InfiniteLoopChecker.Check();
}
```

성능도 거의 소모하지 않고 검사를 할 수 있으며, 빌드 이후에는 호출하지 않기 때문에 굳이 지워줄 필요도 없다는 장점이 있다.

<br>

## 무한 루프 탐지 예시

![image](https://user-images.githubusercontent.com/42164422/110019481-ddbc2600-7d6b-11eb-97bd-494fb927eee4.png)