---
title: Unity Script Optimization
author: Rito15
date: 2021-02-04 19:30:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, profiling, optimization]
math: true
mermaid: true
---

# Tips
---

## **1. GetComponent(), Find() 메소드 반복 호출하지 않기**

너무나 기본적인 것이라 간단히 짚고 넘어가지만,
매 프레임, 혹은 주기적으로 Get, Find류의 메소드를 호출하는 것은 매우 좋지 않다.
항상 처음에만 Get, Find로 필드에 담아놓고 사용해야 한다.

<br>

## **2. 필요하지 않은 경우, new로 생성하지 않기**

클래스 타입으로 생성한 객체는 항상 GC의 먹이가 된다.
따라서 가능하면 한 번만 생성하고 이후에는 재사용 하는 방식을 선택해야 한다.

데이터 클래스의 경우, 대신 구조체를 사용하는 것도 좋다.

<br>

## **3. 구조체 사용하기**

- <http://clarkkromenaker.com/post/csharp-structs/>

동일한 데이터를 하나는 구조체, 하나는 클래스로 작성할 경우 클래스는 참조를 위해 8~24 바이트의 추가적인 메모리를 필요로 한다.

따라서 데이터 클래스는 구조체로 작성하는 것이 좋으며, GC의 먹이가 되지 않는다는 장점도 있다.

그리고 구조체는 크기에 관계없이 항상 스택에, 클래스는 힙에 할당된다.
16kB를 초과한다고 해서 구조체가 힙에 할당되지는 않는다.

<br>

## **4. Transform 변경은 한번에**

position, rotation, scale을 한 메소드 내에서 여러 번 변경할 경우, 그 때마다 트랜스폼의 변경이 이루어진다.
그런데 트랜스폼이 여러 자식 트랜스폼들을 갖고 있는 경우, 자식 트랜스폼도 함께 변경된다.

따라서 벡터로 미리 담아두고 최종 계산 이후, 트랜스폼에 단 한 번만 변경을 지정하는 것이 좋다.
또한 position과 rotation을 모두 변경해야 하는 경우 `SetPositionAndRotation()` 메소드를 사용하는 것이 좋다.

<br>

## **5. LINQ 사용하지 않기**

LINQ는 개발자에게 굉장한 편의성을 제공해주지만, 성능이 좋지 않다.
따라서 성능에 민감한 부분에서는 사용하지 않는 것이 좋다.

<br>

## **6. 오브젝트 풀링 사용하기**

게임오브젝트의 잦은 생성/파괴가 이루어지는 경우,
반드시 오브젝트 풀링을 사용하는 것이 좋다.

<br>

## **7. 비어있는 유니티 콜백 메소드 방치하지 않기**

`Awake()`, `Update()` 등의 유니티 기본 콜백 메소드는 스크립트 내에 작성되어 있는 것만으로도 호출되어 성능을 소모한다.

따라서 내용이 비어있는 유니티 기본 콜백 메소드는 아예 지워야 한다.

`protected virtual` 등으로 지정하는 경우에도 혹시나 비워놓을 가능성이 있다면 지양하는 것이 좋다.

<br>

## **8. 필요하지 않은 경우, 리턴하지 않기**

```cs
private int SomeMethod()
{
    //...
    return 0;
}

private void Caller()
{
    SomeMethod(); // 메소드의 리턴값을 사용하지 않음
}
```

메소드를 호출하고 그 리턴값을 항상 사용하지는 않는 경우, 리턴값이 void인 메소드를 작성하는 것이 좋다.
리턴하는 것만으로 항상 메모리 소비가 발생하며, 심지어 참조형인 경우 GC의 먹이가 된다.

<br>

## **9. StartCoroutine() 자주 호출하지 않기**

`StartCoroutine()` 메소드는 `Coroutine` 타입을 리턴하므로 GC의 먹이가 된다.
따라서 짧은 주기로 코루틴을 자주 실행해야 하는 경우, UniTask, UniRx 등으로 대체하는 것이 좋다.

그리고 매 프레임 실행되는 코루틴의 경우(`yield return null`), 대신 Update를 사용하는 것이 성능상 효율적이라고 한다.

<br>

## **10. 코루틴의 yield 캐싱하기**

```cs
private IEnumerator SomeCoroutine()
{
    while(true)
    {
        // ...
        yield return new WaitForSeconds(0.01f);
    }
}
```

코루틴에서는 `WaitForSeconds()` 등의 객체를 yield return으로 사용한다.

그런데 위처럼 항상 new로 생성할 경우, 모조리 GC.Collect()의 대상이 된다.
따라서 아래처럼 캐싱하여 사용하는 것이 좋다.

```cs
private IEnumerator SomeCoroutine()
{
    var wfs = new WaitForSeconds(0.01f);
    while(true)
    {
        // ...
        yield return wfs;
    }
}
```

<br>

## **11. 컬렉션 재사용하기**

List를 메소드 내에서 할당하여 사용하는 경우가 많다.

```cs
private void SomeMethod()
{
    List<Transform> transformList = new List<Transform>();
    transformList.Add(...);
    // ... 
}
```

습관적으로 사용하게 되는 방식이지만, 이렇게 되면 가비지 할당이 반드시 발생한다.
따라서 다음과 같이 변경하여 사용하는 것만으로 컬렉션에 할당되는 가비지를 줄일 수 있다.

```cs
transformList = new List<Transform>();

private void SomeMethod()
{
    transformList.Clear();
    transformList.Add(...);
    // ... 
}
```

실제로 이렇게 바꿨을 때, 아래처럼 가비지를 굉장히 줄인 경우가 있었다.

![image](https://user-images.githubusercontent.com/42164422/106890595-e7327e00-672c-11eb-890c-3514859037ae.png){: .normal}

![image](https://user-images.githubusercontent.com/42164422/106890874-48f2e800-672d-11eb-81bc-7bb456287b6f.png){: .normal}

가비지 할당(GC.Alloc) 자체가 성능에 큰 영향을 미치지는 않지만, 결국 가비지가 수집(GC.Collect)될 때 성능에 많은 영향을 끼치게 되므로 반드시 신경써야 하는 부분이다.

<br>

## **12. StringBuilder 사용하기**

스트링의 연결(a + b)이 자주 발생하는 경우, StringBuilder.Append()를 활용하는 것이 좋다.

```cs
string a = "a1";
a = "a2";
```

스트링에 새로운 값을 초기화 하는 것은 GC를 호출하지 않지만,

```cs
string strA = "a";
string strB = "b";

strA = "a" + "b";
strA = strA + strB;
strA = $"{strB}c";
```

스트링끼리 연결하는 경우에는 하나의 연결마다 하나의 가비지를 생성한다.

```cs
StringBuilder sb = new StringBuilder("");
sb.Append("a");
sb.Append("b");
```

따라서 이렇게 StringBuilder를 사용하는 것이 좋다.

<br>

## **13. Enum HasFlag() 박싱 이슈**

- <https://medium.com/@arphox/the-boxing-overhead-of-the-enum-hasflag-method-c62a0841c25a>

`[Flags]`를 사용하는 enum의 경우, HasFlag()를 자주 사용하게 된다.
하지만 이 때 박싱이 발생한다.

따라서 이를 피하기 위해서는 다음과 같은 확장 메소드를 만들어 사용하는 것이 좋다.

```cs
public static bool IsSet2<T>(this T self, T flag) where T : Enum
{
    return (self & flag) == flag;
}
```

## **참고 : 해결된 박싱 이슈**

1. foreach 루프 박싱 이슈
  - foreach를 사용할 경우 매번 24kB의 추가적인 가비지가 발생한다는 이슈
  - 현재 버전에서는 해결되었다고 한다.

2. Dictionary의 키로 Enum을 사용할 경우 박싱 이슈
  - 역시 .Net 4.x 버전에서 해결되었다고 한다.

<br>

## **14. 빌드 이후 Debug.Log() 사용하지 않기**

`Debug`의 메소드들은 에디터에서 디버깅을 위해 사용하지만, 빌드 이후에도 호출되어 성능을 많이 소모한다.

따라서 아래처럼 Debug 클래스를 에디터 전용으로 래핑에서 사용할 경우, 이를 방지할 수 있다.

- <https://github.com/rito15/Unity_Toys/blob/master/Rito/2.%20Toy/2021_0125_EditorOnly%20Debug/Debug_UnityEditorConditional.cs>

```cs
public static class Debug
{
    [Conditional("UNITY_EDITOR")]
    public static void Log(object message)
        => UnityEngine.Debug.Log(message);
}
```

<br>

# References
---
- <https://coderzero.tistory.com/entry/유니티-최적화-유니티-최적화에-대한-이해>
