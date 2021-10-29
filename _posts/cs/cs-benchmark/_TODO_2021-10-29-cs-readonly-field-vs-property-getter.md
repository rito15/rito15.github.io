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

그리고 프로퍼티의 **Getter**는 사실 메소드다.

<br>

그렇다면 구조체 타입 읽기 전용 프로퍼티는 **Getter**가 호출될 때마다 복제되어서 전달되지 않을까?

<br>


# Benchmark
---

## **테스트 조건**
- **Benchmark.NET**을 통해 테스트한다.
- 일부러 크기가 큰 구조체를 정의한다.
- 구조체의 크기는 `sizeof(float) * 18 = 72byte`
- 필드, 프로퍼티, 메소드로부터 값을 참조하여 다른 필드에 초기화한다.

<br>

## **테스트 대상**
1. 필드 값의 참조
2. 읽기 전용 프로퍼티 Getter를 통해 미리 초기화된 값 참조
3. 다른 읽기 전용 필드를 가리키는 읽기 전용 프로퍼티 Getter 참조
3. 매번 구조체를 생성하여 전달하는 읽기 전용 프로퍼티 Getter 참조
4. Getter 메소드 호출

<br>

## **구조체, 필드, 프로퍼티 정의**

<details>
<summary markdown="span">
...
</summary>

```cs
private struct Vector3
{
    public float x, y, z;
    public Vector3(float x, float y, float z)
    {
        this.x = x; this.y = y; this.z = z;
    }
}
private struct Transform
{
    public Vector3 position;
    public Vector3 localPosition;
    public Vector3 eulerAngles;
    public Vector3 localEulerAngles;
    public Vector3 scale;
    public Vector3 localScale;

    public static readonly Transform readonlyField = new Transform()
    {
        position         = new Vector3(1, 2, 3),
        localPosition    = new Vector3(1, 2, 3),
        eulerAngles      = new Vector3(1, 2, 3),
        localEulerAngles = new Vector3(1, 2, 3),
        scale            = new Vector3(1, 2, 3),
        localScale       = new Vector3(1, 2, 3),
    };

    public static Transform PropertyGetter1 { get; } = new Transform()
    {
        position         = new Vector3(1, 2, 3),
        localPosition    = new Vector3(1, 2, 3),
        eulerAngles      = new Vector3(1, 2, 3),
        localEulerAngles = new Vector3(1, 2, 3),
        scale            = new Vector3(1, 2, 3),
        localScale       = new Vector3(1, 2, 3),
    };

    public static Transform PropertyGetter2 => readonlyField;

    public static Transform PropertyGetter3 => new Transform()
    {
        position         = new Vector3(1, 2, 3),
        localPosition    = new Vector3(1, 2, 3),
        eulerAngles      = new Vector3(1, 2, 3),
        localEulerAngles = new Vector3(1, 2, 3),
        scale            = new Vector3(1, 2, 3),
        localScale       = new Vector3(1, 2, 3),
    };

    public static Transform GetterMethod() => new Transform()
    {
        position         = new Vector3(1, 2, 3),
        localPosition    = new Vector3(1, 2, 3),
        eulerAngles      = new Vector3(1, 2, 3),
        localEulerAngles = new Vector3(1, 2, 3),
        scale            = new Vector3(1, 2, 3),
        localScale       = new Vector3(1, 2, 3),
    };
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
private static Transform dest; // 값 초기화 목적지 필드

[Benchmark(Baseline = true)]
public void Test_ReadonlyField()
{
    dest = Transform.readonlyField;
}

[Benchmark]
public void Test_PropertyGetter1()
{
    dest = Transform.PropertyGetter1;
}

[Benchmark]
public void Test_PropertyGetter2()
{
    dest = Transform.PropertyGetter2;
}

[Benchmark]
public void Test_PropertyGetter3()
{
    dest = Transform.PropertyGetter3;
}

[Benchmark]
public void Test_GetterMethod()
{
    dest = Transform.GetterMethod();
}
```

</details>

<br>


# Result
---

![image](https://user-images.githubusercontent.com/42164422/139322125-d2870923-084d-466d-b8a7-66fbc983fcad.png)

<br>


# Conclusion
---

1. 읽기 전용 필드를 직접 호출하는 것이 가장 성능이 좋다.
2. 읽기 전용 프로퍼티를 호출하여, 미리 저장된 값을 받아오는 것은 필드 호출에 근접하게 성능이 좋다.
3. 프로퍼티 Getter 또는 Getter 메소드를 통해 값을 받아오는 것은 복제가 일어나므로 성능이 좋지 않다.

<br>


# Analysis - 1
---

각 프로퍼티(1, 2, 3)들이 컴파일러에 의해 어떻게 변하는지 디스어셈블러를 통해 확인해보았다.

<br>

<details>
<summary markdown="span">
...
</summary>

```cs
private struct Transform
{
  public Vector3 position;
  public Vector3 localPosition;
  public Vector3 eulerAngles;
  public Vector3 localEulerAngles;
  public Vector3 scale;
  public Vector3 localScale;
  
  public static readonly Transform readonlyField;
  [CompilerGenerated]
  private static readonly Transform \u003CPropertyGetter1\u003Ek__BackingField;

  public static Transform PropertyGetter1
  {
    [CompilerGenerated] get
    {
      return Transform.\u003CPropertyGetter1\u003Ek__BackingField;
    }
  }

  public static Transform PropertyGetter2
  {
    get
    {
      return Transform.readonlyField;
    }
  }

  public static Transform PropertyGetter3
  {
    get
    {
      Transform transform = new Transform();
      transform.position         = new Vector3(1f, 2f, 3f);
      transform.localPosition    = new Vector3(1f, 2f, 3f);
      transform.eulerAngles      = new Vector3(1f, 2f, 3f);
      transform.localEulerAngles = new Vector3(1f, 2f, 3f);
      transform.scale            = new Vector3(1f, 2f, 3f);
      transform.localScale       = new Vector3(1f, 2f, 3f);
      return transform;
    }
  }

  public static Transform GetterMethod()
  {
    Transform transform = new Transform();
    transform.position         = new Vector3(1f, 2f, 3f);
    transform.localPosition    = new Vector3(1f, 2f, 3f);
    transform.eulerAngles      = new Vector3(1f, 2f, 3f);
    transform.localEulerAngles = new Vector3(1f, 2f, 3f);
    transform.scale            = new Vector3(1f, 2f, 3f);
    transform.localScale       = new Vector3(1f, 2f, 3f);
    return transform;
  }
  
  static Transform()
  {
    Transform transform1 = new Transform();
    transform1.position         = new Vector3(1f, 2f, 3f);
    transform1.localPosition    = new Vector3(1f, 2f, 3f);
    transform1.eulerAngles      = new Vector3(1f, 2f, 3f);
    transform1.localEulerAngles = new Vector3(1f, 2f, 3f);
    transform1.scale            = new Vector3(1f, 2f, 3f);
    transform1.localScale       = new Vector3(1f, 2f, 3f);
    
    Transform.readonlyField = transform1;
    
    Transform transform2 = new Transform();
    transform1.position         = new Vector3(1f, 2f, 3f);
    transform1.localPosition    = new Vector3(1f, 2f, 3f);
    transform1.eulerAngles      = new Vector3(1f, 2f, 3f);
    transform1.localEulerAngles = new Vector3(1f, 2f, 3f);
    transform1.scale            = new Vector3(1f, 2f, 3f);
    transform1.localScale       = new Vector3(1f, 2f, 3f);
    
    Transform.\u003CPropertyGetter1\u003Ek__BackingField = transform2;
  }
}
```

</details>

<br>

```cs
public static Transform PropertyGetter1 { get; } = new Transform()
{
    position         = new Vector3(1, 2, 3),
    localPosition    = new Vector3(1, 2, 3),
    eulerAngles      = new Vector3(1, 2, 3),
    localEulerAngles = new Vector3(1, 2, 3),
    scale            = new Vector3(1, 2, 3),
    localScale       = new Vector3(1, 2, 3),
};
```

이랬던 녀석이, 컴파일러에 의해 **Backing Field**가 추가되면서

```cs
[CompilerGenerated]
private static readonly Transform \u003CPropertyGetter1\u003Ek__BackingField;

public static Transform PropertyGetter1
{
  [CompilerGenerated] get
  {
    return Transform.\u003CPropertyGetter1\u003Ek__BackingField;
  }
}
```

위와 같이 변했다는 것을 확인할 수 있었다.

<br>

그리고 `PropertyGetter3`은 `GetterMethod()`와 동일한 형태라고 볼 수 있다.

<br>



# Analysis - 2
---

가장 의아했던 점은, 프로퍼티 Getter 호출은 결국 메소드 호출일텐데

미리 초기화된 값을 받아올 때 필드를 직접 참조하는 것에 버금가는 성능을 보인다는 것이다.

그러면 이 경우에 구조체의 복제가 발생하지 않는다는 의미가 되는 걸까?

TODO



의문
1. 구조체 변수를 다른 변수에 초기화하면 모든 필드의 복제가 일어나는 것이 아닌가? 바로 가볍게 덮어씌울 수 있나?
2. 마찬가지로 구조체 변수를 메소드에서 리턴할 때도 생각보다 가볍게 전달되나?
3. 그럼 설마 매개변수로 전달할 때도? 그럼 in으로 전달할 때와의 차이점은?


TODO
- 구조체 타입 객체가 초기화/매개변수 및 반환을 통해 전달될 때의 메커니즘 정확하게 이해하기


# References
---
- <https://stackoverflow.com/questions/33307685/how-c-sharp-returns-structs>