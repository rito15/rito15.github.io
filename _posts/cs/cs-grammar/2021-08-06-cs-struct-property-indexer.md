---
title: C# 구조체 프로퍼티, 구조체 인덱서
author: Rito15
date: 2021-08-06 15:00:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp, grammar]
math: true
mermaid: true
---

# 구조체의 특징
---
- 초기화(할당), 리턴 등의 동작을 통해 값을 전달할 경우, 구조체가 통째로 복제된다.

```cs
struct MyStruct
{
    public float value;
}

class MainClass
{
    private MyStruct ms;

    private MyStruct GetStruct()
    {
        return ms; // 복제하여 리턴
    }

    public void Main()
    {
        MyStruct ms1 = ms;          // 복제하여 초기화
        MyStruct ms2 = GetStruct(); // 복제하여 반환된 값 초기화
    }
}
```

<br>


# 프로퍼티의 특징
---

```cs
private float _value;
```

필드가 있다.

<br>

```cs
public float value
{
    get { return _value; }
    set { _value = value; }
}
```

그리고 이렇게 프로퍼티를 만들어서

프로퍼티에 값을 넣으면 특정 필드에 값을 넣고,

프로퍼티를 참조하면 특정 필드의 값을 리턴하도록 해서

프로퍼티 `value`가 필드 `_value`와 동일한 것처럼 사용할 수 있다.

<br>

하지만 실제로 프로퍼티는 메소드이다.

메소드를 필드처럼 사용할 수 있게 해주는 문법이며,

위에서 작성한 프로퍼티는

```cs
public float GetValue()
{
    return _value;
}

public void SetValue(float value)
{
    _value = value;
}
```

내부적으로 이 메소드들을 호출하는 것과 동일하다.

<br>

# 구조체 프로퍼티
---

유니티 엔진의 `Transform` 클래스와 `Vector3` 구조체를 예시로 살펴본다.

```cs
struct Vector3
{
    public float x, y, z;
}

class Transform
{
    public Vector3 position
    {
        get { return _position; }
        set { _position = value; }
    }
    private Vector3 _position;
}
```

실제로 위와 유사하게 구현되어 있다.

<br>

흔히 볼 수 있는 간단한 예제를 하나 살펴보자.

```cs
Transform transform = new Transform();

// [1]
transform.position = new Vector3();

// [2]
transform.position.x = 1f;
```

`[1]`의 경우에는 아무런 문제가 없다.

그런데 `[2]`의 경우에는 

```
'Transform.position'은(는) 변수가 아니므로 해당 반환 값을 수정할 수 없습니다.
```

이런 컴파일 에러가 발생한다.

<br>

에러가 발생하는 이유는 위에서 설명한 프로퍼티의 특징 때문이다.

`[1]`과 같은 `position = rValue` 꼴에서는 `position`의 `Setter`를 호출하지만

`[2]`와 같은 `position.x = rValue`에서는 `position.x`에서 이미 `Getter`가 호출된 상태가 된다.

따라서

```cs
transform.position.x = 1f;
```

이 문장은 내부적으로

```cs
transform.GetPosition().x = 1f;
```

이런 형태라고 할 수 있다.

<br>

`transform.GetPosition()`으로 구조체인 `_position`을 리턴받는 순간,

값이 복사가 되어 넘어온다.

그러니 `transform.position`을 참조한 순간에 넘어온 값은

이미 `transform._position` 필드와는 분리된 별개의 값인 것이다.

그렇다고 `transform.position`의 리턴값을 전달받는 지역 변수도 존재하지 않고

리턴값에 그대로 필드를 수정하려고 하니

실제로 아무런 동작도 수행하지 않는 '의미 없는 코드'이기 때문에

컴파일 에러가 발생하는 것이다.

<br>

만약 `Vector3`가 구조체가 아니라 클래스였다면

값이 복제되지 않고 객체 참조가 전달되므로

컴파일 에러가 발생하지 않고, 의도대로 값을 수정할 수 있다.

<br>

또는 `position`이 프로퍼티가 아니라 필드였다면

필드를 직접 참조하는 것이므로

마찬가지로 에러 없이 의도대로 값을 수정할 수 있을 것이다.

<br>

# 인덱서의 특징
---

```cs
class Container
{
    private Vector3 value;

    public Vector3 this[int index]
    {
        get
        {
            return value;
        }
        set
        {
            this.value = value;
        }
    }
}
```

이런 문법이 있다.

프로퍼티와 유사하지만, `객체[인덱스]` 꼴로 참조할 수 있는 인덱서이다.

내부 동작도 프로퍼티처럼 `Setter(value)`와 `Getter()` 메소드의 호출로 이루어진다.

<br>

하지만 인덱서와 배열의 인덱스 참조는 서로 다르다.

배열의 인덱스 참조는 배열 내의 해당 인덱스에 위치한 변수를 직접 참조하는 것이다.

반면에 인덱서를 통한 참조는 프로퍼티처럼 내부 메소드 호출이 발생한다.

<br>

# 구조체 인덱서
---

```cs
Vector3[] arrVec3 = new Vector3[1];

arrVec3[0] = new Vector3();
arrVec3[0].x = 1f;
```

구조체 `Vector3` 배열에 대한 인덱스 `[0]` 참조는

배열의 첫 번째 요소에 대한 직접 참조이므로 문제가 되지 않지만,

```cs
Container container = new Container();

container[0] = new Vector3();
container[0].x = 1f; // ERROR
```

인덱서를 통한 인덱스 `[0]` 참조는

인덱서 `Getter` 호출에 의해 복제된 구조체를 참조하게 되므로

위의 구조체 프로퍼티의 경우와 동일하게 컴파일 에러가 발생한다. 

<br>

이 문제를 가장 확실하게 느낄 수 있는 예시는 바로

`List<>`와 `Dictionary<,>` 타입이다.

리스트는 가변 배열처럼 사용되고, 딕셔너리는 `Key-Value` 꼴의 집합으로 사용된다.

공통점은 인덱스 참조를 통해 내부 값을 참조할 수 있다는 것이다.

<br>

이제 구조체 배열과 구조체 리스트를 비교해보자.

```cs
Vector3[] arr = new Vector3[1];

arr[0] = new Vector3();
arr[0].x = 1f;
```

위의 경우에는 아무런 문제도 없다.

```cs
List<Vector3> list = new List<Vector3>(1);

list.Add(default);

list[0] = new Vector3();
list[0].x = 1f; // ERROR
```

그런데 이 경우에는 마지막 줄에서 컴파일 에러가 발생한다.

역시나 위에서 설명한 문제와 동일하다.

`list[0].x`는 `list[0]`에서 이미 인덱서의 `Getter`가 호출되어

구조체 값이 복제된 상태이므로,

이 값의 필드를 수정하려고 하면 컴파일 에러가 발생한다.

<br>

리스트는 실제로 배열처럼 많이 사용되는 만큼

리스트의 인덱스 참조가 배열의 인덱스 참조와 동일할 것이라고 생각할 수 있는데,

인덱싱을 통한 배열 요소의 직접 참조와

인덱서 `Getter`를 통한 내부 메소드 호출은 결국 다른 것이다.

<br>

딕셔너리의 경우에도 마찬가지로,

`Dictionary<TKey, TValue>`에서 `TValue`가 구조체 타입인 경우

`dictionary[key]`는 인덱서의 `Getter`를 통해 구조체를 복제하여 리턴하므로

이 구조체의 필드를 직접 수정할 수는 없다.





