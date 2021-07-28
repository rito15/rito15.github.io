---
title: 유니티 GC 관련 메모, 팁 모음
author: Rito15
date: 2021-01-01 01:01:02 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# String
---

- `Object.name` 프로퍼티는 호출하는 것 자체만으로 가비지를 하나 생성한다.

- `GameObject.tag` 프로퍼티는 호출하는 것 자체만으로 가비지를 하나 생성한다.
  - 태그 비교 시 반드시 `.CompareTag()` 메소드를 사용해야 한다.

<br>

# Component
---

- `GetComponent<T>()` 메소드는 호출하는 것 자체만으로 가비지를 하나, 에디터에서는 `NullErrorWrapper`까지 하나 더 생성한다.
  - 반드시 `TryGetComponent()` 메소드를 사용하는 것이 좋다. (가비지를 생성하지 않는다.)

<br>

# Collections
---

- `List<T>`, `Dictionary<K,V>`와 같은 제네릭 컬렉션은 `new`를 통한 객체 생성을 최대한 피하고, 대신 `.Clear()`로 내부를 비우며 재사용하는 것이 좋다.

- 제네릭 컬렉션은 크기가 `4`부터 두배씩 증가할 때마다 내부의 기존 배열을 제거하고 새로운 배열을 할당하므로, 객체 생성 시 생성자의 매개변수로 `capacity`를 미리 지정해주는 것이 좋다.

