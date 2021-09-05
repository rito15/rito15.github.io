---
title: C# 간단한 트릭 - 널 체크
author: Rito15
date: 2021-09-06 04:40:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Note
---

```cs
public class MyClass
{
    public int[] dataArray;

    public bool IsEmpty()
    {
        return dataArray == null || dataArray.Length == 0;
    }
}
```

위와 같이 내부에 간단한 배열을 담고 있는 클래스가 있다.

```cs
MyClass m = null;

Console.WriteLine(m.IsEmpty());
```

그리고 위와 같이 객체가 `null`인 상태에서 인스턴스 메소드를 호출하면

당연히 `NullReferenceException`이 발생한다.

<br>

그런데 데이터의 유효성 검사만 확인하면 되고, 이 검사가 매우 빈번한 경우에

매번 `m != null && !m.IsEmpty()` 이런 식으로 검사하는 것은 다소 지저분해 보일 수 있다.

이런 경우 사용할 수 있는 간단한 트릭이 있다.

<br>

## **확장 메소드**

```cs
public static class MyClassExtension
{
    public static bool IsNull(this MyClass @this)
    {
        return @this == null; // 또는 @this is null
    }

    public static bool IsNullOrEmpty(this MyClass @this)
    {
        return IsNull(@this) || @this.IsEmpty();
    }
}
```

이렇게 `MyClass`를 위한 정적 클래스를 정의하고, 확장 메소드를 작성한다.

확장 메소드는 `m.IsNull()`과 같이 인스턴스 메소드인 것처럼 호출할 수 있지만

실제로는 `MyClassExtension.IsNull(m)`의 형태로 정적 메소드로서 동작한다.

따라서 호출 주체가 `null`이어도 호출할 수 있으며,

위에서 언급한 `m != null && !m.IsEmpty()`의 경우

이제 `!m.IsNullOrEmpty()`와 같이 깔끔하게 작성할 수 있다.

