---
title: C# Deconstructor
author: Rito15
date: 2021-09-11 04:32:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Deconstructor
---

```cs
class Student
{
    public int id;
    public string name;
}
```

클래스가 있다.

```cs
Student student = new Student();
```

객체도 있다.

```cs
(int id, string name) = student;
```

위와 같이 한다고 해서 객체의 필드들이 각각의 변수에 할당되지는 않는다.

<br>

```cs
class Student
{
    public int id;
    public string name;

    public void Deconstruct(out int id, out string name)
    {
        id = this.id;
        name = this.name;
    }
}
```

그런데 이렇게 `Deconstruct()` 메소드를 작성하면


```cs
(int id, string name) = student;
```

이런 사용이 가능해진다.

이런 메소드를 `Deconstructor`라고 하며,

객체의 필드들을 각각의 변수로 분해할 수 있도록 해준다.

<br>

메소드 이름을 정확히 `Deconstruct`라고 작성해야 하며,

모든 매개변수가 `out` 한정자를 갖는 것이 특징이다.

<br>

여기서 주의할 점은, 튜플과는 다르다는 것이다.

```cs
(int id, string name) = student;
```

이것이 `Deconstruct()` 호출이고,

```cs
(int id, string name) tuple = student;
```

이건 튜플로의 형변환이다.

<br>


```cs
int id;
string name;
```

이렇게 이미 선언된 변수가 있을 경우

```cs
(id, name) = student;
```

곧바로 분해하여 전달할 수 있다.

<br>



```cs
string name;

(int id, name) = student; // 불가능
```

아쉽게도 이런건 안된다.


<br>

# References
---
- <https://www.csharpstudy.com/latest/CS7-deconstructor.aspx>