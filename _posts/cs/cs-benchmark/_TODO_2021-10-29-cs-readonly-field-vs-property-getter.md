---
title: C# - Readonly Field vs Property Getter
author: Rito15
date: 2021-10-29 04:00:00 +09:00
categories: [C#, C# Benchmark]
tags: [csharp]
math: true
mermaid: true
---

# Question
---

유니티 엔진으로 코드를 짜다가 문득 의문이 들었다.

```cs
public struct Vector3 : IEquatable<Vector3>
{
    private static readonly Vector3 zeroVector = new Vector3(0f, 0f, 0f);
    public static Vector3 zero => zeroVector;
}
```

```cs
public struct Color : IEquatable<Color>
{
    public static Color white => new Color(1f, 1f, 1f, 1f);
}
```

<br>

`Vector3.zero`, `Color.white`는 **Getter**만 존재하는, 구조체 타입의 읽기 전용 프로퍼티다.

구조체 타입의 변수는 메소드의 매개변수 또는 반환 값으로 전달될 때 복제된다.

그리고 프로퍼티의 **Getter**는 사실 메소드와 동일하게 동작한다.

<br>

의문을 정리해보면 다음과 같다.

1. 구조체 타입 읽기 전용 프로퍼티는 **Getter**가 호출될 때마다 복제되어서 전달될텐데, `readonly` 필드에 비해 성능 상 손해가 아닐까?
2. 위에서 `Color.white` 프로퍼티는 호출할 때마다 매번 `Color` 생성자를 호출하여 새로운 구조체 값을 만들어 전달하는데, 이러면 할당과 복제가 한 번씩 일어나므로 성능 상 굉장히 손해가 아닐까?
3. 동일한 경우에 대해, 주솟값을 복제하여 전달하는 클래스 타입은 괜찮을까?

<br>


# Benchmark 1
---

## **테스트 조건**
- **Benchmark.NET**을 통해 테스트한다.
- 4개의 `float` 필드를 갖는 구조체를 정의한다.
- 구조체의 크기는 `sizeof(float) * 4 = 16byte`
- 필드, 프로퍼티, 메소드로부터 값을 참조하여 다른 필드에 초기화한다.

<br>

## **테스트 대상**
1. `readonly` 필드 참조
2. 읽기 전용 프로퍼티 통해 미리 초기화된 값 참조
3. 다른 `readonly` 필드를 가리키는 읽기 전용 프로퍼티 참조
4. 호출될 때마다 구조체 객체를 생성하여 전달하는 읽기 전용 프로퍼티 참조
5. 필드를 리턴하는 Getter 메소드 호출

<br>

## **구조체, 필드, 프로퍼티 정의**

<details>
<summary markdown="span">
...
</summary>

```cs
private struct Color
{
    public float r, g, b, a;

    public Color(float r, float g, float b, float a)
    {
        this.r = r; this.g = g; this.b = b; this.a = a;
    }

    public static readonly Color readonlyField = new Color(1, 1, 1, 1);

    public static Color ReadonlyProperty1 { get; } = new Color(1, 1, 1, 1);

    public static Color ReadonlyProperty2 => readonlyField;

    public static Color ReadonlyProperty3 => new Color(1, 1, 1, 1);

    public static Color GetterMethod()
    {
        return readonlyField;
    }
}
```

</details>

<br>

## **벤치마크 소스코드**

<details>
<summary markdown="span">
...
</summary>

```cs
// 값 초기화 목적지 필드
private static Color dest;

[Benchmark(Baseline = true)]
public void ReadonlyField()
{
    dest = Color.readonlyField;
}

[Benchmark]
public void ReadonlyProperty1()
{
    dest = Color.ReadonlyProperty1;
}

[Benchmark]
public void ReadonlyProperty2()
{
    dest = Color.ReadonlyProperty2;
}

[Benchmark]
public void ReadonlyProperty3()
{
    dest = Color.ReadonlyProperty3;
}

[Benchmark]
public void GetterMethod()
{
    dest = Color.GetterMethod();
}
```

</details>

<br>


# Result 1
---

![image](https://user-images.githubusercontent.com/42164422/139434578-92dcbaec-9e46-4f35-af0f-10a130b43e24.png)

<br>

## **결과 해석**

1. 읽기 전용 필드의 직접 참조가 가장 성능이 좋다.
2. 미리 초기화된 필드를 참조하여 반환하는 것이 그 다음으로 성능이 좋다.
3. 호출할 때마다 새로운 구조체 객체를 생성하여 반환하는 것은 가장 성능이 좋지 않다.

<br>


# Analysis 1
---

각 프로퍼티들이 컴파일러에 의해 어떻게 변하는지 디스어셈블러를 통해 확인해 본다.

<br>

<details>
<summary markdown="span">
...
</summary>

```cs
private struct Color
{
  public float r;
  public float g;
  public float b;
  public float a;
  public static readonly Color readonlyField;
  
  [CompilerGenerated]
  private static readonly Color \u003CReadonlyProperty1\u003Ek__BackingField;

  public Color(float r, float g, float b, float a)
  {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  public static Color operator +(
    Color A,
    Color B)
  {
    return new Color(A.r + B.r, A.g + B.g, A.b + B.b, A.a + B.a);
  }

  public static Color ReadonlyProperty1
  {
    [CompilerGenerated] get
    {
      return Color.\u003CReadonlyProperty1\u003Ek__BackingField;
    }
  }

  public static Color ReadonlyProperty2
  {
    get
    {
      return Color.readonlyField;
    }
  }

  public static Color ReadonlyProperty3
  {
    get
    {
      return new Color(1f, 1f, 1f, 1f);
    }
  }

  public static Color GetterMethod()
  {
    return Color.readonlyField;
  }

  static Color()
  {
    Color.readonlyField = new Color(1f, 1f, 1f, 1f);
    Color.\u003CReadonlyProperty1\u003Ek__BackingField = new Color(1f, 1f, 1f, 1f);
  }
}
```

</details>

<br>

```cs
public static Color ReadonlyProperty1 { get; } = new Color(1, 1, 1, 1);
```

이랬던 녀석이, 컴파일러에 의해 **Backing Field**가 추가되면서

```cs
[CompilerGenerated]
private static readonly Color \u003CReadonlyProperty1\u003Ek__BackingField;

public static Color ReadonlyProperty1
{
  [CompilerGenerated] get
  {
    return Color.\u003CReadonlyProperty1\u003Ek__BackingField;
  }
}

static Color()
{
  // ...
  Color.\u003CReadonlyProperty1\u003Ek__BackingField = new Color(1f, 1f, 1f, 1f);
}
```

위와 같이 변했다는 것을 확인할 수 있다.

<br>

그리고 `ReadonlyProperty3`을 살펴보면

```cs
public static Color ReadonlyProperty3 => new Color(1, 1, 1, 1);
```

위와 같은 코드에서

```cs
public static Color ReadonlyProperty3
{
  get
  {
    return new Color(1f, 1f, 1f, 1f);
  }
}
```

이렇게 바뀌면서, 역시나 호출될 때마다 새로운 객체를 생성하여 반환한다는 것을 알 수 있다.

<br>



# Benchmark 2
---

## **테스트 대상**
- 완전히 동일한 구조의 구조체와 클래스를 정의한다.
- 미리 정의된 필드를 반환하는 읽기 전용 프로퍼티를 각각 호출한다.




<br>

# Conclusion
---



<br>

# References
---
- <https://stackoverflow.com/questions/33307685/how-c-sharp-returns-structs>