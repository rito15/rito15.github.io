---
title: 유니티 오브젝트 풀(Object Pool) 구현하기
author: Rito15
date: 2021-07-000000000000000000000000000000000 00:55:00 +09:00 변경!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 목표
---
- 오브젝트 풀 싱글톤 클래스 구현하기

<br>


# 개념
---

게임오브젝트를 생성, 파괴하는 것은 순간적으로 큰 성능 소모 및 프레임 저하를 발생시킬 수 있다.

따라서 생성, 파괴 대신 활성화, 비활성화 방식을 사용하면 순간적인 프레임 저하를 방지할 수 있다.

이를 오브젝트 풀링 기법이라고 하며, 동일한 여러 개의 오브젝트를 하나의 풀(예 : 리스트, 스택, 큐)에  미리 담아 관리한다.

파괴 대신 비활성화하여 풀에 저장하고, 생성 대신 풀에서 꺼내어 활성화하는 방식을 사용한다.

<br>

풀 내의 오브젝트는 파괴되지 않고 메모리에 계속 남아있기 때문에, 

CPU 성능 소모를 줄이고 메모리 사용량을 더 늘리는 기법이라고 할 수 있다.

<br>


# 참고
---

- 오브젝트 풀링의 대상이 되는 오브젝트 내에 생성되는 순간 발생해야 하는 이벤트가 있을 경우, 활성화 순간에 발생하도록 변경해주어야 한다.<br>
  예시 - `Awake()`, `Start()` -> `OnEnable()`로 이동

- 게임오브젝트 파괴(`Destroy(Object)`)를 사용하던 코드는 모두 오브젝트 풀에 의한 비활성화로 변경해야 한다.

- 자주 사용되지 않는 오브젝트가 계속 풀에 남아있으면 불필요하게 메모리를 소모하므로, 때때로 잘 판단하여 제거해줄 필요가 있다.

- `List<T>`, `Stack<T>`, `Queue<T>` 모두 성능은 크게 차이 없지만, `Stack<T>`이 그나마 가장 낫다고 한다.
  - <https://forum.unity.com/threads/object-pool-performance.453524/>

<br>


# 필드 구성
---

## **Dictionary<string, GameObject> sampleDict**
- 

## **Dictionary<string, Stack<GameObject>> poolDict**
- 


<br>

# 메소드 구성
---

## **Register(string key, GameObject go)**
- `key`에 게임오브젝트를 등록한다.


## **Spawn(string key)**
- `key`에 해당하는 게임오브젝트를 풀에서 꺼내며 활성화한다.
- 풀에 여유가 없을 경우, 새로 생성한다.

## **Despawn(GameObject go)**
- ===> 복제된 게임오브젝트에서 KEY를 어떻게 효율적으로 참조할 것인지????

<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>


# Download
---
- 



