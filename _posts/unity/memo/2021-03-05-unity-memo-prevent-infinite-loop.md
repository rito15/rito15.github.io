---
title: 무한 루프를 간편히 방지하기
author: Rito15
date: 2021-03-05 04:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

### 2021. 06. 17.
- 무한루프를 보다 간편히 방지할 수 있도록 코드 개선

<br>

# Note
---
- 유니티 엔진에서 무한 루프가 발생하면 에디터가 그대로 멈추어, 강제 종료해야 하는 경험을 겪은 적이 간혹 있을 것이다.

- 따라서 혹시나 무한 루프가 될 가능성이 있는 코드를 인지했다면 간단한 체크 로직을 넣어주는 것이 좋다.

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

    if(loopNum++ > 10000)
        throw new Exception("Infinite Loop");
}
```

이렇게 작성하면 무한 루프가 발생했을 때 유니티 엔진이 뻗어버리지 않고,

무한 루프에서 탈출하고 콘솔에 예외를 출력해줄 수 있다.

<br>

하지만 매번 이러면 번거롭기도 하고 혹시나 작성하고 잊을 수도 있으니,

아래와 같은 클래스를 작성하고 사용하면 편리하다.

<br>

# InfiniteLoopDetector
---

```cs
using UnityEngine;
using System;

/// <summary> 무한 루프 검사 및 방지(에디터 전용) </summary>
public static class InfiniteLoopDetector
{
    private static string prevPoint = "";
    private static int detectionCount = 0;
    private const int DetectionThreshold = 100000;

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    public static void Run(
        [System.Runtime.CompilerServices.CallerMemberName] string mn = "",
        [System.Runtime.CompilerServices.CallerFilePath] string fp = "",
        [System.Runtime.CompilerServices.CallerLineNumber] int ln = 0
    )
    {
        string currentPoint = $"{fp}{ln} : {mn}()";

        if (prevPoint == currentPoint)
            detectionCount++;
        else
            detectionCount = 0;

        if (detectionCount > DetectionThreshold)
            throw new Exception($"Infinite Loop Detected: \n{currentPoint}\n\n");

        prevPoint = currentPoint;
    }

#if UNITY_EDITOR
    [UnityEditor.InitializeOnLoadMethod]
    private static void Init()
    {
        UnityEditor.EditorApplication.update += () =>
        {
            detectionCount = 0;
        };
    }
#endif
}
```

위 스크립트를 작성하여 유니티 프로젝트 내에 넣어준다.


그리고 무한루프가 발생할 가능성이 있는 for 또는 while문 내에

다음처럼 간단히 작성하면 된다.

```cs
while( /* condition */ )
{
    // codes..

    InfiniteLoopDetector.Run(); // 이렇게 한 줄 추가 작성
}
```

성능도 거의 소모하지 않고 검사를 할 수 있으며, 

빌드 이후에는 호출하지 않기 때문에 굳이 지워줄 필요도 없다.

그리고 콘솔 창에 무한 루프 발생 지점을 정확히 에러 로그로 보여준다.

![image](https://user-images.githubusercontent.com/42164422/122255002-aaf80100-cf08-11eb-986e-63060ee94bcd.png)

<br>

## **주의사항**

루프 내에서 단 한 번씩만 호출해야 한다.

```cs
while( /* condition */ )
{
    InfiniteLoopDetector.Run();

    // codes..

    InfiniteLoopDetector.Run();
}
```

위와 같이 작성하면 의도대로 동작하지 않는다.

<br>

## **동작 원리**

1. 메소드를 호출할 때마다 호출 위치를 기억하고, 이전과 동일하면 카운트를 누적한다.<br>
   이전과 다를 경우 카운트를 0으로 초기화한다.

2. 누적된 카운트가 일정 값을 넘어서는 순간, 예외를 발생시키고 루프를 탈출한다.

<br>

# Download
---
- [InfiniteLoopDetector.zip](https://github.com/rito15/Images/files/6680557/InfiniteLoopDetector.zip)