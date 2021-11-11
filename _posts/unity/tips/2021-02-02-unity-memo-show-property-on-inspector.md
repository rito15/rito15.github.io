---
title: 유니티 - 인스펙터에 오토 프로퍼티 표시하기
author: Rito15
date: 2021-02-02 17:08:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp, property]
math: true
mermaid: true
---

# Memo
---

```cs
public GameObject Property1 => Field1;
private GameObject Field1;
```

이렇게 다른 필드와 연결된 프로퍼티라면

```cs
public GameObject Property1 => field1;

[SerializeField]
private GameObject field1;
```

대상 필드에 `[SerializeField]`를 붙여서 인스펙터에 표시할 수 있다.

하지만

```cs
[SerializeField]
public GameObject Property2 { get; private set; }
```

이런 오토 속성 프로퍼티는 프로퍼티 앞에 `[SerializeField]`를 붙여도 인스펙터에 표시되지 않는다.

<br>

그런데,

```cs
[field: SerializeField]
public GameObject Property3 { get; private set; }
```

이렇게 오토 속성 프로퍼티의 앞에 `[field: SerializeField]`를 붙이면

![image](https://user-images.githubusercontent.com/42164422/106571323-5c118680-657a-11eb-8400-4ef143b6238c.png)

인스펙터에 표시할 수 있다.

<br>

## 예외

```cs
public GameObject Property1 { get; }

public GameObject Property2
{
    get
    {
        // ...
    }
}

public GameObject Property3
{
    get
    {
        // ...
    }
    set
    {
        // ...
    }
}
```

- 위와 같은 읽기 전용 프로퍼티, Getter 또는 Setter의 블록을 구현한 프로퍼티의 경우에는 인스펙터에 표시할 수 없다.