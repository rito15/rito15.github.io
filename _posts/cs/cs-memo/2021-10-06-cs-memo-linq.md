---
title: C# 배열에 같은 값을 넣으면서 선언하기
author: Rito15
date: 2021-10-06 22:00:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# Memo
---

```cs
// 인덱스 0부터 99까지 정수 1로 채우기
int[] arr = Enumerable.Repeat(1, 100).ToArray();
```

물론 LINQ를 쓰는 만큼, 중간 버퍼의 가비지는 감안해야 한다.

<br>

`.NET 5.0` 버전이라면 `Array.Fill()` 메소드를 사용하면 된다.

```cs
int[] arr = new int[100];
Array.Fill(arr, 1); // 배열 전체에 1로 채우기
```