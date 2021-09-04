---
title: C# Reflection(리플렉션)
author: Rito15
date: 2021-02-19 03:50:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, reflection]
math: true
mermaid: true
---

# Reflection
---

## 필요 네임스페이스

```cs
using System;
using System.Reflection;
```

<br>

## 특정 클래스 타입 가져오기

```cs
Type targetType = Type.GetType("클래스명");
```

<br>

## 특정 네임스페이스 내에 있는 클래스 타입 가져오기

```cs
Type targetType = Type.GetType("네임스페이스명.클래스명");
```

<br>

## 특정 네임스페이스의 모든 클래스 타입 가져오기(모든 어셈블리 확인)

```cs
string asmName = "UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";
string nsName = "UnityEngine";

var classTypes =
    AppDomain.CurrentDomain.GetAssemblies()    // 모든 어셈블리 대상
        .Where(asm => asm.FullName == asmName) // 특정 어셈블리(exe, dll)로 필터링
        .SelectMany(asm => asm.GetTypes())     // 모든 타입들 가져오기
        .Where(t => t.IsClass && t.Namespace == nsName); // 클래스타입 && 특정 네임스페이스로 필터링
```

<br>

## 현재 어셈블리의 모든 클래스 타입 가져오기

```cs
var classTypes = 
    Assembly.GetExecutingAssembly().GetTypes()
        .Where(t => t.IsClass /*&& t.Namespace == nsName*/);
```

<br>

## 프로그램 내 모든 어셈블리에서 특정 타입 가져오기

```cs
Type type =
    AppDomain.CurrentDomain.GetAssemblies()
    .SelectMany(ass => ass.GetTypes())
    .Where(t => t.Name == "TargetType")
    .FirstOrDefault();

// 해당 타입이 아예 없는데 .First()를 호출하면 예외가 발생하므로,
// FirstOrDefault()를 호출하는 것이 안전하다.
```

<br>

## 다른 어셈블리(예: DLL) 내에 있는 클래스 타입 가져오기

```cs
Type targetType = Type.GetType("네임스페이스명.클래스명, 어셈블리명");

// 어셈블리명 예시
string shortName = "UnityEngine";
string fullName  = "UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";

// 실제 예시 - shortName 이용
Type.GetType("UnityEngine.Rigidbody, UnityEngine");

// 실제 예시 - fullName 이용
Type.GetType("UnityEngine.Rigidbody, UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null");
```

<br>

## 알고 있는 타입의 동일 어셈블리 내의 특정 클래스 가져오기

- 아주 유용함

```cs
Type knownType = ...; // 알고 있는 타입

Type goal = knownType.Assembly.GetType("네임스페이스명.클래스명");
```

<br>

## 타입으로 객체 생성하기

```cs
object instance = Activator.CreateInstance(targetType);
```

<br>

## 특정 클래스의 메소드 가져오기

```cs
MethodInfo targetMethod = targetType.GetMethod (
    "메소드명",
    new Type[] { typeof(파라미터1타입), typeof(파라미터2타입) }
);

// Binding Flag를 지정해야 하는 경우
targetType.GetMethod
(
    "메소드명",
    BindingFlags.~~, 
    null, // Binder -> null로 둔다.
    new Type[] { ~~ },
    null, // ParameterModifier[] -> null로 둔다.
);
```

<br>

## 가져온 메소드 호출하기

```cs
// 1. 정적 메소드가 아니고, 매개변수가 존재하는 경우
targetMethod.Invoke(instance, new object[]{ 파라미터1, 파라미터2 });

// 2. 정적 메소드가 아니고, 매개변수가 0개인 경우
targetMethod.Invoke(instance, null);

// 3. 정적 메소드이고, 매개변수가 0개인 경우
targetMethod.Invoke(null, null);
```

<br>

## 제네릭 메소드에 원하는 타입 넣어서 호출하기

```cs
private class TargetClass
{
    public void GMethod<T>()
    {
        Console.WriteLine($"Generic Method Call : {default(T)}");
    }
}

public static void Run()
{
    Type type = typeof(TargetClass);

    // 제네릭 메소드의 T에 int 타입 넣어서 메소드 정보 가져오기
    MethodInfo method = type.GetMethod("GMethod").MakeGenericMethod(new Type[] { typeof(int) });

    object instance = Activator.CreateInstance(type);
    method.Invoke(instance, null);
}
```

<br>

## 필드의 값 가져오기

- 필드의 값을 가져오려면 `FieldInfo`가 필요하다.

- 대상 필드가 동적일 경우 `GetValue(object)`의 인수로 객체가 필요하며,<br>
  정적일 경우 객체가 필요하지 않다. (`GetValue(null)`)

```cs
public class TestClass
{
    private float value = 4f;
    private static float staticValue = 5f;
}
```

```cs
TestClass tc = new TestClass();
Type t = tc.GetType();

// 1. 동적 필드의 값 가져오기
BindingFlags bf1 = BindingFlags.NonPublic | BindingFlags.Instance;
FieldInfo fi1 = t.GetField("value", bf1);

float value1 = (float)fi1.GetValue(tc);

// 2. 정적 필드의 값 가져오기
BindingFlags bf2 = BindingFlags.NonPublic | BindingFlags.Static;
FieldInfo fi2 = t.GetField("staticValue", bf2);

float value2 = (float)fi2.GetValue(null);
```

<br>


# 인터페이스 타입으로 구현 타입들 가져오기
---

```cs
interface IPoo { }
class Some1 : IPoo { }
class Some2 : IPoo { }
```

이런 인터페이스 구현 관계가 있을 경우,

`IPoo`의 타입을 통해 `Some1`, `Some2`를 찾을 수 있다.

<br>

```cs
Type targetType = typeof(IPoo);

var types =
    Assembly.GetAssembly(targetType).GetTypes()
        .Where(t => !(t.GetInterface(targetType.Name) is null))
        .ToArray();
```


<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.assembly.gettype>
- <https://www.csharpstudy.com/Mistake/Article/11>