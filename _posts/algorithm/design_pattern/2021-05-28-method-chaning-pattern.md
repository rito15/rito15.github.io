---
title: Method Chaining & Generic
author: Rito15
date: 2021-05-28 22:02:00 +09:00
categories: [Algorithm, Design Pattern]
tags: [algorithm, pattern, csharp]
math: true
mermaid: true
---

# 메소드 체이닝 패턴
---

## **특징**
- 메소드가 객체를 반환하는 형태로 작성한다.
- 문장을 마치지 않고 메소드 호출을 이어나갈 수 있다.
- 가독성을 향상시킬 수 있다.

<br>

## **주의사항**
- 한 문장에 여러번의 메소드 호출이 존재할 수 있으므로, 에러가 발생할 경우 정확한 지점을 한 번에 찾기 힘들다.
- C# 구조체의 메소드를 체이닝으로 구현할 경우, 매 번 구조체 전체의 복제가 발생하므로 바람직하지 않다.

<br>

## 예시

```cs
class Box
{
    private float width;
    private float height;

    public Box SetWidth(float width)
    {
        this.width = width;
        return this;
    }
    public Box SetHeight(float height)
    {
        this.height = height;
        return this;
    }
}

class MethodChaining
{
    public static void Run()
    {
        Box box = new Box()
            .SetWidth(10f)
            .SetHeight(20f);
    }
}
```

<br>

# 상속 관계에서의 메소드 체이닝
---

```cs
class Box
{
    protected float width;
    protected float height;

    public Box SetWidth(float width)
    {
        this.width = width;
        return this;
    }
    public Box SetHeight(float height)
    {
        this.height = height;
        return this;
    }
}

class OutlinedBox : Box
{
    protected float outlineWidth;

    public OutlinedBox SetOutlineWidth(float outlineWidth)
    {
        this.outlineWidth = outlineWidth;
        return this;
    }
}
```

클래스 상속 관계에서는 정상적으로 메소드 체이닝이 이루어질 수 없으며,

다양한 문제들이 발생한다.

<br>

```cs
// [1] 에러
OutlinedBox olBox1 = new OutlinedBox()
    .SetOutlineWidth(2f)
    .SetWidth(10f)
    .SetHeight(20f);
    // 리턴 타입이 Box이므로 변수 타입이 Box여야 한다.

// [2] 에러
OutlinedBox olBox2 = new OutlinedBox()
    .SetWidth(10f)
    .SetHeight(15f)
    .SetOutlineWidth(2f); // 현재 Box 타입이므로 호출 불가능

// [3] 정상
Box olBox3 = new OutlinedBox()
    .SetOutlineWidth(2f)
    .SetWidth(10f)
    .SetHeight(20f);

// [4] 정상
OutlinedBox olBox4 = new OutlinedBox()
    .SetOutlineWidth(2f)
    .SetWidth(10f)
    .SetHeight(20f) as OutlinedBox;

// [5] 정상
OutlinedBox olBox5 = (new OutlinedBox()
    .SetWidth(10f)
    .SetHeight(15f) as OutlinedBox)
    .SetOutlineWidth(2f);
```

상속 관계에서의 메소드 체이닝은 두 가지 문제점이 존재한다.

 1. 자식의 메소드를 부모의 메소드보다 우선 호출해야 한다.
 2. 변수의 타입이 부모의 타입이어야 한다.

`SetWidth()`, `SetHeight()` 메소드를 호출할 경우 리턴 타입은 `Box`이다.

따라서 부모의 메소드를 호출한 뒤에는 부모의 타입으로 변경되므로

자식의 메소드를 호출할 수 없으며,

결국 메소드 체인이 종료되면 결과 타입음 부모의 타입이므로

변수 역시 부모의 타입이어야 한다.

<br>

에러가 발생하지 않도록 하기 위해서는

[3]처럼 위의 문제점을 회피하여 작성하거나,

[4]와 [5]처럼 자식 타입으로의 명시적 캐스팅을 해야 한다.

하지만, 이렇게 되면 메소드 체이닝 패턴의 장점인 편의성과 가독성을 모두 해치게 된다.


<br>

# 메소드 체이닝과 제네릭
---

제네릭을 이용하면 위의 문제를 모두 해결할 수 있다.

```cs
class Box : Box<Box> { }
class Box<T> where T : Box<T>
{
    protected float width;
    protected float height;

    public T SetWidth(float width)
    {
        this.width = width;
        return this as T;
    }
    public T SetHeight(float height)
    {
        this.height = height;
        return this as T;
    }
}

class OutlinedBox : Box<OutlinedBox>
{
    protected float outlineWidth;

    public OutlinedBox SetOutlineWidth(float outlineWidth)
    {
        this.outlineWidth = outlineWidth;
        return this;
    }
}

class MethodChaining
{
    public static void Run()
    {
        Box box = new Box()
            .SetWidth(10f)
            .SetHeight(20f);

        OutlinedBox olBox = new OutlinedBox()
            .SetOutlineWidth(2f)
            .SetWidth(10f)
            .SetHeight(20f);
    }
}
```

부모 클래스인 `Box`의 제네릭 타입으로 `T`를 사용하고,

`where T : Box<T>`로 한정시킨다.

그리고 각각의 체인 메소드에서 리턴 타입을 `T`로 지정한 다음,

`return this as T`를 리턴하면 된다.

<br>

이제 자식 클래스들에서 `OutlinedBox : Box<OutlinedBox>`와 같이

`T`에 자신의 타입을 집어넣고 상속하게 되면

부모의 `Setter`가 리턴하는 `T`가 자신의 타입으로 추론되며

호출하는 모든 메소드가 부모의 타입이 아니라 자신의 타입으로

자기 자신을 리턴하도록 만든다.

<br>

그리고 `Box` 타입 역시 `new Box()` 형태로 객체를 생성할 수 있도록

`class Box : Box<Box> { }`처럼 빈 클래스를 작성해놓는다.

<br>

## 자식의 자식으로 상속이 이어지는 경우

- 같은 방식으로 이어나가면 된다.

```cs
class OutlinedBox : OutlinedBox<OutlinedBox> { }
class OutlinedBox<T> : Box<T> where T : OutlinedBox<T>
{
    protected float outlineWidth;

    public T SetOutlineWidth(float outlineWidth)
    {
        this.outlineWidth = outlineWidth;
        return this as T;
    }
}

class OutlinedColorBox : OutlinedBox<OutlinedColorBox>
{
    protected Color color;

    public OutlinedColorBox SetColor(Color color)
    {
        this.color = color;
        return this;
    }
}
```

<br>

## 추가1

위와 같이 작성하면 `Box<T>`,  `OutlinedBox<T>` 타입 역시 `T`를 직접 지정하여 객체를 생성할 수 있게 된다.

이를 막으려면 다음과 같이 클래스 선언에 `abstract`를 넣어 작성한다.

```cs
abstract class Box<T> where T : Box<T>
abstract class OutlinedBox<T> : Box<T> where T : OutlinedBox<T>
```

<br>

## 추가2

`Box` 타입과 `Box<T>` 타입은 이름이 같아 동일해 보일 수 있지만,

엄연히 서로 다른 타입이다.

`OutlinedBox`와 `OutlinedBox<T>` 타입 역시 마찬가지.

제네릭화 과정에서 자연스럽게 동일한 이름으로 남겨두었지만,

혼동할 가능성이 있으므로 다음과 같이 바꾸면 확실히 구분할 수 있다.

```cs
abstract class BoxBase<T> where T : BoxBase<T>
abstract class OutlinedBoxBase<T> : BoxBase<T> where T : OutlinedBoxBase<T>
```

<br>

## 결론

```cs
abstract class BoxBase<T> where T : BoxBase<T>
{
    protected float width;
    protected float height;

    public T SetWidth(float width)
    {
        this.width = width;
        return this as T;
    }
    public T SetHeight(float height)
    {
        this.height = height;
        return this as T;
    }
}

abstract class OutlinedBoxBase<T> : BoxBase<T> where T : OutlinedBoxBase<T>
{
    protected float outlineWidth;

    public T SetOutlineWidth(float outlineWidth)
    {
        this.outlineWidth = outlineWidth;
        return this as T;
    }
}

class Box : BoxBase<Box> { }

class OutlinedBox : OutlinedBoxBase<OutlinedBox> { }

class OutlinedColorBox : OutlinedBoxBase<OutlinedColorBox>
{
    protected Color color;

    public OutlinedColorBox SetColor(Color color)
    {
        this.color = color;
        return this;
    }
}
```

<br>

# 제네릭 클래스에 대한 메소드 체이닝
---

메소드 체이닝을 적용하기 전에 이미 제네릭으로 만들어진 클래스를 생각해볼 수 있다.


```cs
abstract class SliderBase<T> where T : struct
{
    protected T value;
    protected T minValue;
    protected T maxValue;

    public SliderBase<T> SetValue(T value)
    {
        this.value = value;
        return this;
    }
}

class IntSlider : SliderBase<int>
{
    protected string id;

    public IntSlider SetID(string id)
    {
        this.id = id;
        return this;
    }
}
```

기존에 제네릭 타입으로 `T`가 사용되는 상태.

여기에 제네릭 메소드 체이닝을 적용하려면,

두 번째 제네릭 타입 `R`을 추가하여 이전과 같이 작성하면 된다.

<br>

```cs
abstract class SliderBase<T, R>
    where T : struct
    where R : SliderBase<T, R>
{
    protected T value;
    protected T minValue;
    protected T maxValue;

    public R SetValue(T value)
    {
        this.value = value;
        return this as R;
    }
}

class IntSlider : SliderBase<int, IntSlider>
{
    protected string id;

    public IntSlider SetID(string id)
    {
        this.id = id;
        return this;
    }
}
```




