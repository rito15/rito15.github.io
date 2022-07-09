---
title: 유니티 - 인스펙터에 프로퍼티 표시하기
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

프로퍼티는 앞에 `[SerializeField]`를 붙여도 인스펙터에 표시되지 않는다.

<br>

그런데,

```cs
[field: SerializeField]
public GameObject Property3 { get; private set; }
```

이렇게 프로퍼티의 앞에 `[field: SerializeField]`를 붙이면

![image](https://user-images.githubusercontent.com/42164422/106571323-5c118680-657a-11eb-8400-4ef143b6238c.png)

인스펙터에 표시할 수 있다.

<br>

## 제한사항
- 단순히 `get;`, `set;`만 작성한 자동 구현 프로퍼티만 인스펙터에 나타낼 수 있다.
- 읽기 전용 프로퍼티, Getter 또는 Setter의 블록을 구현한 프로퍼티는 인스펙터에 나타낼 수 없다.

```cs
// 자동 구현 프로퍼티 : 표시 가능
public GameObject Property1 { get; set; }
public GameObject Property2 { get; private set; }
```

```cs
// 읽기 전용 프로퍼티 : 표시 불가능
public GameObject Property3 { get; }

// Getter 구현 프로퍼티 : 표시 불가능
public GameObject Property4
{
    get
    {
        // ...
    }
}

// Getter/Setter 구현 프로퍼티 : 표시 불가능
public GameObject Property5
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
