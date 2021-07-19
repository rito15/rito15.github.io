---
title: C# 구조체가 IEquatable&lt;T&gt;를 상속해야 하는 이유
author: Rito15ㅔ
date: 2021-07-19 20:00:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# System.Object.Equals(object)
---

`C#`의 모든 타입의 최상위 클래스인 `Object`에는 `.Equals(object)` 메소드가 존재한다.

그리고 이를 통해 다른 값과의 동일 비교를 수행할 수 있다.

<br>

구조체나 클래스를 직접 정의하고, 해당 객체로 `.Equals(object)`를 호출하면

`object.Equals(object)`가 호출된다.

우선, 이것이 핵심이다.

<br>

## **박싱**

```cs
int a = 1;
object oa = a;
```

**Value Type**을 `object` 타입으로 캐스팅하면 박싱이 일어난다.

```
IL_0001:  ldc.i4.1
IL_0002:  stloc.0
IL_0003:  ldloc.0
IL_0004:  box        [mscorlib]System.Int32
IL_0009:  stloc.1
```

디스어셈블러를 통해 `CIL` 코드를 열어보면 위와 같이 확인할 수 있다.

<br>

## **.Equals(object)에서의 박싱**

```cs
int a = 1;
object oa = a;

_ = a.Equals(oa);
_ = oa.Equals(a);
```

먼저 `int` 타입의 변수에 `.Equals(object)`를 호출하여 `object` 타입과 비교하고,

`object` 타입의 변수에 `.Equals(object)`를 호출하여 `int` 타입과 비교해본다.

<br>

```
IL_0015:  ldloca.s   a
IL_0017:  ldloc.1
IL_0018:  call       instance bool [mscorlib]System.Int32::Equals(object)
IL_001d:  pop

IL_0029:  ldloc.1
IL_002a:  ldloc.0
IL_002b:  box        [mscorlib]System.Int32
IL_0030:  callvirt   instance bool [mscorlib]System.Object::Equals(object)
IL_0035:  pop
```

첫 번째 경우에는 `System.Int32::Equals(object)`가 호출되며 박싱이 일어나지 않았고,

두 번째 경우에는 `System.Object::Equals(object)`가 호출되며 박싱이 발생했다.

<br>

조금 더 다양하게 테스트해본다.

```cs
object oa = 1;

// object.Equals(object)
oa.Equals(1.1f); // Boxing O (float  -> object)
oa.Equals(1.1);  // Boxing O (double -> object)
oa.Equals('a');  // Boxing O (char   -> object)
oa.Equals("a");  // Boxing X (string -> object)

// int.Equals(object), int.Equals(int)
1.Equals(1.1f);  // Boxing O (float  -> object)
1.Equals(1.1);   // Boxing O (double -> object)
1.Equals('a');   // Boxing X (char   -> int)
1.Equals("a");   // Boxing X (string -> object)

1.1f.Equals(oa); // Boxing X
1.1.Equals(oa);  // Boxing X
'a'.Equals(oa);  // Boxing X
"a".Equals(oa);  // Boxing X
```

<br>

다음과 같이 결론내릴 수 있다.

- `.Equals(object)` 메소드에 `Value Type`의 값이 매개변수로 들어가면 박싱이 발생한다.

- `string`은 클래스 타입이기 때문에 박싱이 발생하지 않는다.

- `int.Equals(int)`와 같이 `.Equals()` 메소드를 특정 타입의 매개변수로 적절히 오버로딩한 경우 박싱을 피할 수 있다.

<br>



# 구조체의 .Equals()
---

## **[1] .Equals(object) 메소드를 재정의하지 않는 경우**

```cs
private struct Struct1
{
    public int a;
    public Struct1(int v) => a = v;
}

public static void StructTest1()
{
    Struct1 t1 = new Struct1(1);
    Struct1 t2 = new Struct1(1);
    object o2 = t2;          // Boxing O

    // 결과는 모두 true
    bool b1 = t1.Equals(t2); // Boxing O
    bool b2 = t1.Equals(o2); // Boxing X
    bool b3 = o2.Equals(t1); // Boxing O
}
```

언제나 박싱이 발생하는 것을 확인할 수 있다.

두 번째 경우에는 `object` 타입을 넣었기에 박싱이 발생하지 않았지만,

미리 `object` 타입으로 캐스팅하는 과정에서 박싱이 발생한다.

<br>


## **[2] .Equals(object) 메소드를 재정의하는 경우**

```cs
private struct Struct2
{
    public int a;
    public Struct2(int v) => a = v;

    public override bool Equals(object obj)
    {
        if (obj is Struct2 other)
        {
            return this.a == other.a;
        }
        else
            return false;
    }
}

public static void StructTest2()
{
    Struct2 t1 = new Struct2(1);
    Struct2 t2 = new Struct2(1);
    object o2 = t2;          // Boxing O

    // 결과는 모두 true
    bool b1 = t1.Equals(t2); // Boxing O
    bool b2 = t1.Equals(o2); // Boxing X
    bool b3 = o2.Equals(t1); // Boxing O
}
```

`Struct2` 외의 타입에 대해서는 곧바로 `false`를 리턴하도록 작성했지만,

애초에 매개변수로 들어오는 순간 `Value Type`은 박싱이 발생하므로

박싱 문제에 대해서는 다를 것이 없다.


<br>

## **[3] IEquatable&lt;T&gt;.Equals(T) 메소드를 구현하는 경우**

```cs
private struct Struct3 : IEquatable<Struct3>
{
    public int a;
    public Struct3(int v) => a = v;

    public bool Equals(Struct3 other)
    {
        return this.a == other.a;
    }
}

public static void StructTest3()
{
    Struct3 t1 = new Struct3(1);
    Struct3 t2 = new Struct3(1);
    object o2 = t2;          // Boxing O

    bool b1 = t1.Equals(t2); // Boxing X
    bool b2 = t1.Equals(o2); // Boxing X
    bool b3 = o2.Equals(t1); // Boxing O
}
```

`.Equals()` 메소드의 호출자와 매개변수 모두 `Struct3` 타입인 경우,

`Struct3.Equals(Struct3)`를 호출하므로 박싱을 피할 수 있다.

<br>

### **IEquatable&lt;T&gt; 인터페이스를 상속받아야 하는 이유?**

위처럼 동일 타입 또는 특정 타입을 매개변수로 하는 `.Equals(T)` 메소드를 작성하여 박싱을 피할 수 있다.

그런데 `IEquatable<T>`를 상속받지 않고도 해결할 수 있는 문제인데

굳이 해당 인터페이스를 상속받아야 하는 이유가 있을까?

<br>

바로 제네릭 컬렉션에서의 비교 때문이다.

`Dictionary<TKey, TValue>`, `List<T>` 등의 제네릭 컬렉션 타입에서

`.Contains()`, `.IndexOf()`, `.Remove()`와 같이 비교가 필요한 경우에

`IEquatable<T>.Equals(T)`가 구현되어 있으면 이 메소드를 호출하고,

그렇지 않으면 `object.Equals(object)`를 호출하여 동일 비교를 수행한다.

따라서 `IEquatable<T>.Equals(T)`를 미리 구현해놓으면 

다양한 경우에서 의도치 않은 박싱을 피할 수 있다.

<br>



# 결론
---

구조체나 클래스를 만들 때는 `IEquatable<T>`를 상속받고 `IEquatable<T>.Equals(T)`를 구현하여 동일 타입에 대응하고,

`object.Equals(object)`도 재정의하여 타입별로 구분하여 대응하는 것이 좋다.

<br>

```cs
/* Best Case */

private struct MyStruct : IEquatable<MyStruct>
{
    public int a;
    public MyStruct(int v) => a = v;

    public bool Equals(MyStruct other)
    {
        return this.a == other.a;
    }

    public override bool Equals(object obj)
    {
        if (obj is MyStruct other)
        {
            // 동일 타입에 대해 IEquatable<T>.Equals(T) 호출
            return this.Equals(other);
        }
        else
            return false;
    }

    public static bool operator ==(MyStruct a, MyStruct b)
    {
        return a.Equals(b);
    }
    public static bool operator !=(MyStruct a, MyStruct b)
    {
        return !a.Equals(b);
    }
}
```


<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.iequatable-1.equals?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/programming-guide/statements-expressions-operators/how-to-define-value-equality-for-a-type>
- <https://stackoverflow.com/questions/2476793/when-to-use-iequatablet-and-why>
- <https://stackoverflow.com/questions/1502451/what-needs-to-be-overridden-in-a-struct-to-ensure-equality-operates-properly>
- <https://nochoco-lee.tistory.com/422>

