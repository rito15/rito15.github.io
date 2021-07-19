---
title: C# Enum 관련 메모
author: Rito15
date: 2021-02-28 04:00:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, enum]
math: true
mermaid: true
---

## enum의 모든 요소를 배열로 가져오기

```cs
enum MyEnum { A, B }

Array allValues = Enum.GetValues(typeof(MyEnum));
```

<br>

## enum의 마지막 요소 가져오기

```cs
// System.Linq;

MyEnum last = 
    Enum.GetValues(typeof(EditorWindowType)).Cast<MyEnum>().Last();
```