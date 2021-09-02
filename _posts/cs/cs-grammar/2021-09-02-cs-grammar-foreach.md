---
title: C# Foreach 구문 심층 파헤치기
author: Rito15
date: 2021-09-02 16:00:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Foreach 구문
---

- 컬렉션의 요소를 간편히 순차 탐색할 수 있는 구문

```cs
List<int> list = new List<int>();

foreach (var item in list)
{
    Console.WriteLine(item);
}
```

<br>

# Foreach 구문이 실제로 생성하는 코드?
---

- 위의 소스 코드는 실제로 다음과 같은 코드를 생성한다고 한다.

```cs
List<int> list = new List<int>();

List<int>.Enumerator enumerator = list.GetEnumerator();

while (enumerator.MoveNext())
{
    Console.WriteLine(enumerator.Current);
}
```

<br>

# CIL 코드 확인
---

- 정말로 저런 코드를 생성하는지 디스어셈블러를 통해 확인해본다.

<br>

## **[1] foreach 구문 코드**

<details>
<summary markdown="span"> 
...
</summary>

```cs
foreach (var item in list)
{
    Console.WriteLine(item);
}
```

```
  .entrypoint
  // 코드 크기       51 (0x33)
  .maxstack  1
  .locals init (valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32> V_0)
  IL_0000:  ldsfld     class [System.Collections]System.Collections.Generic.List`1<int32> CSharp_DotNet_Core_Test.CoreMainClass::list
  IL_0005:  callvirt   instance valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<!0> class [System.Collections]System.Collections.Generic.List`1<int32>::GetEnumerator()
  IL_000a:  stloc.0
  .try
  {
    IL_000b:  br.s       IL_0019
    IL_000d:  ldloca.s   V_0
    IL_000f:  call       instance !0 valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::get_Current()
    IL_0014:  call       void [System.Console]System.Console::WriteLine(int32)
    IL_0019:  ldloca.s   V_0
    IL_001b:  call       instance bool valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::MoveNext()
    IL_0020:  brtrue.s   IL_000d
    IL_0022:  leave.s    IL_0032
  }  // end .try
  finally
  {
    IL_0024:  ldloca.s   V_0
    IL_0026:  constrained. valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>
    IL_002c:  callvirt   instance void [System.Runtime]System.IDisposable::Dispose()
    IL_0031:  endfinally
  }  // end handler
  IL_0032:  ret
```

</details>

<br>

## **[2] 예상 코드**

<details>
<summary markdown="span"> 
...
</summary>

```cs
List<int>.Enumerator enumerator = list.GetEnumerator();

while (enumerator.MoveNext())
{
    Console.WriteLine(enumerator.Current);
}
```

```
  // 코드 크기       35 (0x23)
  .maxstack  1
  .locals init (valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32> V_0)
  IL_0000:  ldsfld     class [System.Collections]System.Collections.Generic.List`1<int32> CSharp_DotNet_Core_Test.CoreMainClass::list
  IL_0005:  callvirt   instance valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<!0> class [System.Collections]System.Collections.Generic.List`1<int32>::GetEnumerator()
  IL_000a:  stloc.0
  IL_000b:  br.s       IL_0019
  IL_000d:  ldloca.s   V_0
  IL_000f:  call       instance !0 valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::get_Current()
  IL_0014:  call       void [System.Console]System.Console::WriteLine(int32)
  IL_0019:  ldloca.s   V_0
  IL_001b:  call       instance bool valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::MoveNext()
  IL_0020:  brtrue.s   IL_000d
  IL_0022:  ret
```

언뜻 비슷해 보이는 부분들은 보이지만,

`[1]`의 `foreach` 구문의 코드에는 `try-finally`도 포함되어 있었다.

`catch` 블록은 따로 보이지 않으며, 위의 CIL 코드의 내용에 따라 추측하여

다음에는 `[2]`의 소스코드에 `try-finally`를 넣어본다.

</details>

<br>

## **[3] try-finally 추가**

<details>
<summary markdown="span"> 
...
</summary>

```cs
List<int>.Enumerator enumerator = list.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        Console.WriteLine(enumerator.Current);
    }
}
finally
{
    IDisposable disposable = enumerator as IDisposable;
    disposable.Dispose();
}
```

```cs
  // 코드 크기       49 (0x31)
  .maxstack  1
  .locals init (valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32> V_0)
  IL_0000:  ldsfld     class [System.Collections]System.Collections.Generic.List`1<int32> CSharp_DotNet_Core_Test.CoreMainClass::list
  IL_0005:  callvirt   instance valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<!0> class [System.Collections]System.Collections.Generic.List`1<int32>::GetEnumerator()
  IL_000a:  stloc.0
  .try
  {
    IL_000b:  br.s       IL_0019
    IL_000d:  ldloca.s   V_0
    IL_000f:  call       instance !0 valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::get_Current()
    IL_0014:  call       void [System.Console]System.Console::WriteLine(int32)
    IL_0019:  ldloca.s   V_0
    IL_001b:  call       instance bool valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>::MoveNext()
    IL_0020:  brtrue.s   IL_000d
    IL_0022:  leave.s    IL_0030
  }  // end .try
  finally
  {
    IL_0024:  ldloc.0
    IL_0025:  box        valuetype [System.Collections]System.Collections.Generic.List`1/Enumerator<int32>
    IL_002a:  callvirt   instance void [System.Runtime]System.IDisposable::Dispose()
    IL_002f:  endfinally
  }  // end handler
  IL_0030:  ret
```

`IL_0025` 부분에서 실제 코드는 `box` 대신 `constrained`를 호출한다는 점을 빼면 거의 동일하다는 것을 확인할 수 있다.

`constrained`는 상속/구현된 메소드를 호출하도록 강제하는 **OpCode**라고 한다.

</details>

<br>

## **[4] 결론**

<details>
<summary markdown="span"> 
...
</summary>

`List<int>` 타입의 컬렉션에 대해,

```cs
foreach (var item in list)
{
    Console.WriteLine(item);
}
```

위 코드는 실제로 다음과 같은 코드를 생성한다.

```cs
List<int>.Enumerator enumerator = list.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        Console.WriteLine(enumerator.Current);
    }
}
finally
{
    IDisposable disposable = enumerator as IDisposable;
    disposable.Dispose();
}
```

</details>

<br>

# 배열에서의 Foreach 구문
---

`List<int>` 타입에 대한 `foreach` 구문이 실제로 생성하는 코드를 알게 되었다.

그러면 배열은 어떨까?

```cs
int[] arr = { 1, 2, 3};
```

위와 같은 배열에 대한 `foreach` 구문을 살펴본다.

<br>

## **[1] foreach 구문 소스코드와 CIL**

<details>
<summary markdown="span"> 
...
</summary>

```cs
foreach (var item in arr)
{
    Console.WriteLine(item);
}
```

```
  .entrypoint
  // 코드 크기       29 (0x1d)
  .maxstack  2
  .locals init (int32[] V_0,
           int32 V_1)
  IL_0000:  ldsfld     int32[] CSharp_DotNet_Core_Test.CoreMainClass::arr
  IL_0005:  stloc.0
  IL_0006:  ldc.i4.0
  IL_0007:  stloc.1
  IL_0008:  br.s       IL_0016
  IL_000a:  ldloc.0
  IL_000b:  ldloc.1
  IL_000c:  ldelem.i4
  IL_000d:  call       void [System.Console]System.Console::WriteLine(int32)
  IL_0012:  ldloc.1
  IL_0013:  ldc.i4.1
  IL_0014:  add
  IL_0015:  stloc.1
  IL_0016:  ldloc.1
  IL_0017:  ldloc.0
  IL_0018:  ldlen
  IL_0019:  conv.i4
  IL_001a:  blt.s      IL_000a
  IL_001c:  ret
```

`try-finally`도 안보이고, 심지어 `GetEnumerator()`, `MoveNext()`, `Current`의 호출도 보이지 않는다.

</details>

<br>

## **[2] 예상 코드 1**

<details>
<summary markdown="span"> 
...
</summary>

```cs
IEnumerator enumerator = arr.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        Console.WriteLine(enumerator.Current);
    }
}
finally
{
    IDisposable disposable = enumerator as IDisposable;
    disposable.Dispose();
}
```

```
  // 코드 크기       47 (0x2f)
  .maxstack  1
  .locals init (class [System.Runtime]System.Collections.IEnumerator V_0)
  IL_0000:  ldsfld     int32[] CSharp_DotNet_Core_Test.CoreMainClass::arr
  IL_0005:  callvirt   instance class [System.Runtime]System.Collections.IEnumerator [System.Runtime]System.Array::GetEnumerator()
  IL_000a:  stloc.0
  .try
  {
    IL_000b:  br.s       IL_0018
    IL_000d:  ldloc.0
    IL_000e:  callvirt   instance object [System.Runtime]System.Collections.IEnumerator::get_Current()
    IL_0013:  call       void [System.Console]System.Console::WriteLine(object)
    IL_0018:  ldloc.0
    IL_0019:  callvirt   instance bool [System.Runtime]System.Collections.IEnumerator::MoveNext()
    IL_001e:  brtrue.s   IL_000d
    IL_0020:  leave.s    IL_002e
  }  // end .try
  finally
  {
    IL_0022:  ldloc.0
    IL_0023:  isinst     [System.Runtime]System.IDisposable
    IL_0028:  callvirt   instance void [System.Runtime]System.IDisposable::Dispose()
    IL_002d:  endfinally
  }  // end handler
  IL_002e:  ret
```

`List<int>`와 같은 방식으로 작성하면 위와 같은 코드를 얻게 된다.

그리고 참고로, 이 방식에서 `foreach` 블록 내에서 `item`을 `int` 타입으로 캐스팅하여 사용하려고 하면 `object`를 `int`로 캐스팅하기 때문에 박싱이 발생한다.

그러니 굉장히 손해를 보는 코드인데다가, 실제 `foreach` 구문의 **CIL** 코드와도 전혀 다르다.

</details>

<br>

## **[3] 예상 코드 2**

<details>
<summary markdown="span"> 
...
</summary>

```cs
for (int i = 0; i < arr.Length; i++)
{
    Console.WriteLine(arr[i]);
}
```

```
  // 코드 크기       31 (0x1f)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.0
  IL_0001:  stloc.0
  IL_0002:  br.s       IL_0014
  IL_0004:  ldsfld     int32[] CSharp_DotNet_Core_Test.CoreMainClass::arr
  IL_0009:  ldloc.0
  IL_000a:  ldelem.i4
  IL_000b:  call       void [System.Console]System.Console::WriteLine(int32)
  IL_0010:  ldloc.0
  IL_0011:  ldc.i4.1
  IL_0012:  add
  IL_0013:  stloc.0
  IL_0014:  ldloc.0
  IL_0015:  ldsfld     int32[] CSharp_DotNet_Core_Test.CoreMainClass::arr
  IL_001a:  ldlen
  IL_001b:  conv.i4
  IL_001c:  blt.s      IL_0004
  IL_001e:  ret
```

이제서야 실제 `foreach` 코드와 유사한 코드를 얻을 수 있었다.

그러니까 `int[]`와 같은 배열 타입에 대해서는 `foreach`가 실제로 `for`문을 생성한다는 것이다.

</details>

<br>

## **[4] 클래스 타입 배열에 대한 foreach 코드**

<details>
<summary markdown="span"> 
...
</summary>

혹시나 기본 타입들에 대해서만 `for`문을 생성하는 것인지 확인하기 위해,

임의의 클래스 타입을 작성하고 해당 타입의 배열에 대한 `foreach` 코드의 **CIL**을 확인해보았다.

```cs
//class MyClass {}

MyClass[] arr = new MyClass[3];

foreach (var item in arr)
{
    Console.WriteLine(item);
}
```

```
  // 코드 크기       31 (0x1f)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.0
  IL_0001:  stloc.0
  IL_0002:  br.s       IL_0014
  IL_0004:  ldsfld     class CSharp_DotNet_Core_Test.CoreMainClass/MyClass[] CSharp_DotNet_Core_Test.CoreMainClass::myClassArr
  IL_0009:  ldloc.0
  IL_000a:  ldelem.ref
  IL_000b:  call       void [System.Console]System.Console::WriteLine(object)
  IL_0010:  ldloc.0
  IL_0011:  ldc.i4.1
  IL_0012:  add
  IL_0013:  stloc.0
  IL_0014:  ldloc.0
  IL_0015:  ldsfld     class CSharp_DotNet_Core_Test.CoreMainClass/MyClass[] CSharp_DotNet_Core_Test.CoreMainClass::myClassArr
  IL_001a:  ldlen
  IL_001b:  conv.i4
  IL_001c:  blt.s      IL_0004
  IL_001e:  ret
```

동일하게 `for`문을 생성한다는 것을 알 수 있다.

</details>

<br>

## **[5] 결론**

<details>
<summary markdown="span"> 
...
</summary>

- `foreach` 구문은 배열 타입에 대해 실제로 `for`문을 생성한다.

- 그 외의 타입에 대해서는 `GetEnumerator()`, `MoveNext()`, `Current`를 사용하는 코드를 생성한다.
  - 아직 모든 경우에 대해서 확인한 것은 아니므로, 예외가 존재할 수 있다.

</details>

<br>



# Foreach 구문을 사용하기 위한 조건
---

`GetEnumerator()`, `MoveNext()`, `Current` 이렇게 세 가지만 구현하면

`foreach` 구문을 사용하기 위한 최소 조건을 만족한다.

`GetEnumerator()`는 무엇이든 상관 없지만 클래스 또는 구조체 타입 객체를 반환해야 하고,

해당 타입 내에서 `bool MoveNext()`, `T Current { get; }`가 반드시 선언되어 있어야 한다.

<br>

## **간단한 범위 출력 예제**

### **[1] 자기 자신을 enumerator로 사용하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

```cs
class IntRange
{
    private int from, to;
    public int Current { get; private set; }

    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public bool MoveNext()
    {
        return Current++ < to;
    }

    public IntRange GetEnumerator()
    {
        Current = from - 1;
        return this;
    }
}
```

</details>

<br>

### **[2] 별개의 enumerator를 사용하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- `foreach` 구문마다 가비지가 발생하는 것을 피하기 위해, **Enumerator**를 구조체로 작성한다.

```cs
class IntRange
{
    private int from, to;

    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public struct IntRangeEnumerator
    {
        private int from, to;
        public IntRangeEnumerator(int from, int to)
        {
            this.from = from - 1;
            this.to = to;
        }

        public int Current { get { return from; } }

        public bool MoveNext()
        {
            return from++ < to;
        }
    }

    public IntRangeEnumerator GetEnumerator()
    {
        return new IntRangeEnumerator(from, to);
    }
}
```

</details>

<br>

### **[3] Foreach 구문**

<details>
<summary markdown="span"> 
...
</summary>

```cs
IntRange range = new IntRange(2, 8);

foreach (var i in range)
{
    Console.WriteLine(i); // 2 ~ 8까지 한 줄씩 출력
}
```

</details>

<br>



# IEnumerator와 IEnumerable
---

`IEnumerator`와 `IEnumerable`, 또는

`IEnumerator<T>`와 `IEnumerable<T>`를 상속 받아야

`foreach` 구문을 쓸 수 있다고 알고 있는 경우가 많다.

<br>

왜냐하면,

```cs
public interface IEnumerable
{
    IEnumerator GetEnumerator();
}

public interface IEnumerator
{
    object? Current { get; }
    bool MoveNext();
    void Reset();
}
```

이렇게 `IEnumerable`은 `GetEnumerator()`를 구현하도록 강제하고,

`IEnumerator`는 `MoveNext()`와 `Current`를 구현하도록 강제하기 때문이다.

그러니까 저 둘을 상속 받아야만 `foreach` 구문을 사용할 수 있는게 아니고,

저 둘을 상속 받으면 자연스럽게 `foreach` 구문을 사용할 수 있게 되는 셈이다.

<br>

## **foreach를 사용할 수 있는 간단한 클래스 작성**

<details>
<summary markdown="span"> 
...
</summary>

`GetEnumerator()` 메소드가 `IEnumerator` 또는 `IEnumerator<T>`를 리턴하도록 하기만 하면 자연스레 `foreach`를 사용할 수 있다.

그러니까,

```cs
class IntRange
{
    public IEnumerator<int> GetEnumerator()
    {
        yield return 0;
        yield return 1;
        yield return 2;
    }
}
```

위와 같이 구현하면 `foreach` 구문으로 `0`, `1`, `2`를 차례로 얻어올 수 있다는 것이다.

<br>

`IEnumerator` 또는 `IEnumerator<T>` 타입을 리턴하는 메소드는

다른 메소드와는 다르게 `yield return`이라는 독자적인 문법을 통해,

메소드 내부에 정지와 순회가 가능한 독립적인 공간을 구성한다.

`Current`를 참조하면 현재 차례인 값을 리턴하고,

`MoveNext()`를 호출하면 다음 `yield return`으로 이동한다.

따라서 `foreach` 구문 내부에서 `yield return`들을 순회하며 리턴 값들을 참조할 수 있다.

</details>

<br>

## **IEnumerable 상속 받는 클래스 작성하기**

<details>
<summary markdown="span"> 
...
</summary>

```cs
class IntRange : IEnumerable
{
    IEnumerator IEnumerable.GetEnumerator()
    {
        yield return 0;
        yield return 1;
        yield return 2;
    }
}
```

이렇게 작성하면 `foreach` 구문에 곧바로 사용할 수 있다.

하지만 `Current`를 `int` 타입이 아닌 `object` 타입으로 받게 되므로,

`int`로 캐스팅하여 사용하면 박싱이 발생한다.

<br>

그래서 `IEnumerable<int>`를 상속 받게되면,

```cs
class IntRange : IEnumerable<int>
{
    IEnumerator IEnumerable.GetEnumerator()
    {
        // 여기서 return 대신 yield return을 호출하면
        // Current가 아래의 IEnumerator<int> 객체 자체를 리턴하고, 반복이 종료된다.
        return GetEnumerator();
    }

    public IEnumerator<int> GetEnumerator()
    {
        yield return 0;
        yield return 1;
        yield return 2;
    }
}
```

이렇게 구현하면 되고,

`foreach`로부터 참조되는 `Current`는 `int` 타입을 갖게 된다.

</details>

<br>

## **두 개의 GetEnumerator() 메소드**

<details>
<summary markdown="span"> 
...
</summary>

`IEnumerable<T>` 인터페이스를 상속받을 때 `IEnumerable.GetEnumerator()`도 함께 구현해야 한다.

왜냐하면 `IEnumerable<T>` 인터페이스가 `IEnumerable` 인터페이스의 자식이기 때문이다.

<br>

하나는 인터페이스 메소드의 명시적 구현(`IEnumerable.GetEnumerator()`),

하나는 기본 구현(`GetEnumerator()`)을 했을 경우

기본 구현으로 작성된 메소드가 `foreach` 구문을 통해 호출된다.

<br>

두 `GetEnumerator()` 메소드 모두 명시적 구현을 했을 경우,

`IEnumerator<T>.GetEnumerator()` 메소드가 `foreach` 구문을 통해 호출된다.

<br>

`IEnumerable<T>`를 상속받을 때는

```cs
class IntRange : IEnumerable<int>
{
    IEnumerator IEnumerable.GetEnumerator()
    {
        // IEnumerable<int>.GetEnumerator() 호출
        return GetEnumerator();
    }

    public IEnumerator<int> GetEnumerator()
    {
        // 여기에 구현 제대로 작성
        yield return ...;
    }
}
```

이렇게 구현하는 것이 가장 효율적이라고 할 수 있다.

</details>

<br>



# 추가 : 경우에 따라 foreach가 생성하는 소스코드
---

- `foreach` 구문 소스코드 공통

```cs
IntRange range = IntRange(1, 5);

foreach (var i in new range)
{
    Console.WriteLine(i);
}
```

<br>

## **[1] GetEnumerator()가 구조체 타입을 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 생성되는 소스코드

```cs
IntRange range = new IntRange(1, 5);
IntRange.IntRangeEnumerator enumerator = range.GetEnumerator();

while (enumerator.MoveNext())
{
    Console.WriteLine(enumerator.Current);
}
```

- CIL 코드

```
  .locals init (valuetype IntRange/IntRangeEnumerator V_0)
  IL_0000:  ldc.i4.1
  IL_0001:  ldc.i4.5
  IL_0002:  newobj     instance void IntRange::.ctor(int32, int32)
  IL_0007:  callvirt   instance valuetype IntRange/IntRangeEnumerator IntRange::GetEnumerator()
  IL_000c:  stloc.0
  IL_000d:  br.s       IL_001b
  IL_000f:  ldloca.s   V_0
  IL_0011:  call       instance int32 IntRange/IntRangeEnumerator::get_Current()
  IL_0016:  call       void [System.Console]System.Console::WriteLine(int32)
  IL_001b:  ldloca.s   V_0
  IL_001d:  call       instance bool IntRange/IntRangeEnumerator::MoveNext()
  IL_0022:  brtrue.s   IL_000f
  IL_0024:  ret
```

</details>

<br>

## **[2] GetEnumerator()가 클래스 타입을 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 생성되는 소스코드

```cs
IntRange range = new IntRange(1, 5);
IntRange.IntRangeEnumerator enumerator = range.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        Console.WriteLine(enumerator.Current);
    }
}
finally
{
    if (enumerator is IDisposable disposible)
    {
        disposible.Dispose();
    }
}

```

- CIL 코드

```
  .locals init (class IntRange/IntRangeEnumerator V_0,
           class [System.Runtime]System.IDisposable V_1)
  IL_0000:  ldc.i4.1
  IL_0001:  ldc.i4.5
  IL_0002:  newobj     instance void IntRange::.ctor(int32, int32)
  IL_0007:  call       instance class IntRange/IntRangeEnumerator IntRange::GetEnumerator()
  IL_000c:  stloc.0
  .try
  {
    IL_000d:  br.s       IL_001a
    IL_000f:  ldloc.0
    IL_0010:  callvirt   instance int32 IntRange/IntRangeEnumerator::get_Current()
    IL_0015:  call       void [System.Console]System.Console::WriteLine(int32)
    IL_001a:  ldloc.0
    IL_001b:  callvirt   instance bool IntRange/IntRangeEnumerator::MoveNext()
    IL_0020:  brtrue.s   IL_000f
    IL_0022:  leave.s    IL_0035
  }  // end .try
  finally
  {
    IL_0024:  ldloc.0
    IL_0025:  isinst     [System.Runtime]System.IDisposable
    IL_002a:  stloc.1
    IL_002b:  ldloc.1
    IL_002c:  brfalse.s  IL_0034
    IL_002e:  ldloc.1
    IL_002f:  callvirt   instance void [System.Runtime]System.IDisposable::Dispose()
    IL_0034:  endfinally
  }  // end handler
  IL_0035:  ret
```

클래스일 경우 `finally` 구문에서 `IDisposable` 타입인지 확인하여

맞으면 `.Dispose()`를 호출해주는 이유는

`foreach` 구문 내에서 예외가 발생하여 탈출하게 되는 경우에

예기치 못한 메모리 누수를 방지하기 위함인 것으로 보인다.

</details>

<br>

## **[3] GetEnumerator()가 IEnumerator&lt;T&gt; 타입을 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 생성되는 소스코드

```cs
IntRange range = new IntRange(1, 5);
IEnumerator<int> enumerator = range.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        Console.WriteLine(enumerator.Current);
    }
}
finally
{
    if (enumerator is IDisposable disposible)
    {
        disposible.Dispose();
    }
}
```

- CIL 코드

```
  .locals init (class IntRange/IntRangeEnumerator V_0,
           class [System.Runtime]System.IDisposable V_1)
  IL_0000:  ldc.i4.1
  IL_0001:  ldc.i4.5
  IL_0002:  newobj     instance void IntRange::.ctor(int32, int32)
  IL_0007:  call       instance class IntRange/IntRangeEnumerator IntRange::GetEnumerator()
  IL_000c:  stloc.0
  .try
  {
    IL_000d:  br.s       IL_001a
    IL_000f:  ldloc.0
    IL_0010:  callvirt   instance int32 IntRange/IntRangeEnumerator::get_Current()
    IL_0015:  call       void [System.Console]System.Console::WriteLine(int32)
    IL_001a:  ldloc.0
    IL_001b:  callvirt   instance bool IntRange/IntRangeEnumerator::MoveNext()
    IL_0020:  brtrue.s   IL_000f
    IL_0022:  leave.s    IL_0035
  }  // end .try
  finally
  {
    IL_0024:  ldloc.0
    IL_0025:  isinst     [System.Runtime]System.IDisposable
    IL_002a:  stloc.1
    IL_002b:  ldloc.1
    IL_002c:  brfalse.s  IL_0034
    IL_002e:  ldloc.1
    IL_002f:  callvirt   instance void [System.Runtime]System.IDisposable::Dispose()
    IL_0034:  endfinally
  }  // end handler
  IL_0035:  ret
```

</details>

<br>



# 최종 정리
---

## **Foreach 구문을 사용할 수 있는 타입을 정의하는 방법**

### **[1] 3가지 필수 요소 구현하기**

1. 어떤 객체를 리턴하는 `GetEnumerator()` 메소드 구현하기

2. `1`에서 리턴하는 타입 내에 `bool MoveNext()` 메소드 구현하기

3. `1`에서 리턴하는 타입 내에 `Current {get;}` 프로퍼티 구현하기

<details>
<summary markdown="span"> 
...
</summary>

```cs
// Case 1 : GetEnumerator()로 동일 타입 객체(자신) 호출하기
class IntRange
{
    private int from, to;
    public int Current { get; private set; }

    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public bool MoveNext()
    {
        return Current++ < to;
    }

    public IntRange GetEnumerator()
    {
        Current = from - 1;
        return this;
    }
}
```

```cs
// Case 2 : GetEnumerator()로 다른 타입 객체 호출하기
class IntRange
{
    public int from, to;
    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public struct IntRangeEnumerator
    {
        public int from, to;
        public IntRangeEnumerator(int from, int to)
        {
            this.from = from - 1;
            this.to = to;
        }
        public int Current { get => from; }
        public bool MoveNext()
        {
            return from++ < to;
        }
    }

    public IntRangeEnumerator GetEnumerator()
    {
        return new IntRangeEnumerator(from, to);
    }
}
```

</details>

<br>

### **[2] 특별한 GetEnumerator() 메소드 구현하기**

- `IEnumerator` 또는 `IEnumerator<T>`를 리턴하는 메소드를 구현한다.

- 단순한 규칙의 순회 또는 내부 컬렉션 순회가 목적이라면 가장 편리한 방법이다.

- `IEnumerator`는 `Current`, `MoveNext()`를 멤버로 갖고 있기 때문에 자연스레 `foreach` 구문 사용이 가능해진다.

<details>
<summary markdown="span"> 
...
</summary>

```cs
class IntRange
{
    public int from, to;
    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    public IEnumerator<int> GetEnumerator()
    {
        for (int i = from; i <= to; i++)
        {
            yield return i;
        }
    }
}
```

</details>

<br>

### **[3] IEnumerable 또는 IEnumerable&lt;T&gt; 상속받기**

- `[2]`의 방법을 사용하면서, 다양한 컬렉션과의 호환성도 얻을 수 있는 방법이다.

<details>
<summary markdown="span"> 
...
</summary>

```cs
class IntRange : IEnumerable<int>
{
    public int from, to;
    public IntRange(int from, int to)
    {
        this.from = from;
        this.to = to;
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public IEnumerator<int> GetEnumerator()
    {
        for (int i = from; i <= to; i++)
        {
            yield return i;
        }
    }
}
```

</details>

<br>

## **Foreach 구문이 생성하는 실제 소스 코드**

### **[1] GetEnumerator()가 구조체 타입을 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 작성 소스코드

```cs
foreach(var item in foo)
{
    DoSomething(item);
}
```

- 실제로 생성되는 소스코드

```cs
StructTypeEnumerator enumerator = foo.GetEnumerator();

while (enumerator.MoveNext())
{
    DoSomething(enumerator.Current);
}
```

</details>

<br>

### **[2] GetEnumerator()가 클래스 타입을 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 작성 소스코드

```cs
foreach(var item in foo)
{
    DoSomething(item);
}
```

- 실제로 생성되는 소스코드

```cs
ClassTypeEnumerator enumerator = foo.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        DoSomething(enumerator.Current);
    }
}
finally
{
    if (enumerator is IDisposable disposible)
    {
        disposible.Dispose();
    }
}
```

</details>

<br>

### **[3] GetEnumerator()가 IEnumerator&lt;T&gt;를 리턴하는 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 작성 소스코드

```cs
foreach(var item in foo)
{
    DoSomething(item);
}
```

- 실제로 생성되는 소스코드

```cs
var enumerator = foo.GetEnumerator();

try
{
    while (enumerator.MoveNext())
    {
        DoSomething(enumerator.Current);
    }
}
finally
{
    if (enumerator is IDisposable disposible)
    {
        disposible.Dispose();
    }
}
```

</details>

<br>

### **[4] 배열 타입의 경우**

<details>
<summary markdown="span"> 
...
</summary>

- 작성 소스코드

```cs
foreach(var item in array)
{
    DoSomething(item);
}
```

- 실제로 생성되는 소스코드

```cs
for(int i = 0; i < array.Length; i++)
{
    DoSomething(array[i]);
}
```

</details>


<br>

# References
---
- <https://intellitect.com/the-internals-of-foreach/>
- <https://intellitect.com/c-foreach-with-arrays/>
- <https://docs.microsoft.com/en-us/archive/msdn-magazine/2017/april/essential-net-understanding-csharp-foreach-internals-and-custom-iterators-with-yield>
- <https://kodify.net/csharp/loop/foreach-interface/>
- <https://stackoverflow.com/questions/11179156/how-is-foreach-implemented-in-c>