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







IDEA

[1]
- 오브젝트 풀링의 대상이 될 프리팹을 미리 싹다 ObjectPoolManager 인스펙터에 담아놓고, string 타입으로 ID도 정해놓고, 이 ID를 기억해놨다가 다른 스크립트에서 사용하기??
- Despawn시 ID 참조 => ID를 게임오브젝트 이름으로 설정하면 해결

[2]
- 아래 작성하는 것처럼 PoolObject 컴포넌트 클래스를 따로 만들어서 사용하기?
- 컴포넌트를 하나 더 써야한다는 단점
- 숫자 ID를 쓰면 사용할때 불편
- 그러면 string 타입 ID를 쓰면 되나?

- 차라리 프로젝트 내에서 PoolObjectIDCache 같은걸로 미리 정하면 되나?
- 근데 이럴거면 정말로 차라리 [1]처럼 인스펙터에서 할당해놓고 쓰는게 낫지 않나..


- 아무래도 풀링할 대상들은 모두 정확히 알고 관리할 수 있는 만큼,
  [1]처럼 인스펙터에서 미리 풀링 대상 오브젝트 쫘악 만들어놓고
  ID도 string으로 지정해서 편리하게 쓰는게 나을듯

- 컴포넌트를 하나 더 쓰는것도 굉장히 불편

- [1]쪽으로 마음이 기운 상태

- 관리하게 편하게 커스텀 인스펙터로 이쁘게 꾸며주면 좋을듯
- 풀링 대상들은 클래스로 묶어서 `class PoolObjectData{ ID:string, Prefab:프리팹, MaxCount:int } 정도로 만들고


★ GameObject.name은 호출 한 번 당 하나씩 알뜰하게 가비지를 생성

★ ID는 string으로 하되, 게임오브젝트 이름이 아니라 PoolObject 컴포넌트의 변수로 사용

★ class PoolSO : ScriptableObject
{
    public string id;
    public GameObject prefab;
    public int maxCount;
}

★ Manager의 인스펙터에는 PoolSO 리스트 관리




# PoolObject 클래스
---

## **역할**

- 오브젝트 풀링의 대상이 될 각각의 게임오브젝트에 컴포넌트로 사용된다.

- 각각의 풀로 구분될 ID를 부여받고, 저장한다.<br>
  (동일 ID는 하나의 풀 내에서 함께 관리된다.)

- 게임오브젝트 생성, 파괴, 활성화, 비활성화 등의 API를 구현하여 제공한다.

<br>

## **[1] 필드**

### **static ushort nextUniqueID**
- `CreateUniqueID()` 호출 시 제공할 다음 ID 값

### **ushort id**
- 오브젝트가 갖는 고유 ID 값

<br>

## **[2] 메소드**

### **static ushort CreateUniqueID()**
- 새로운 고유 ID를 생성하여 리턴한다.




<br>

# ObjectPoolManager 클래스
---

## **[1] 필드**

### **Dictionary<ushort, PoolObject> sampleDict**
- 

### **Dictionary<string, Stack<PoolObject>> poolDict**
- 


<br>

## **[2] 메소드**

### **ushort Register(GameObject go)**
- 게임오브젝트를 복제하여 새롭게 풀에 등록하고 ID를 리턴한다.

### **void Prepare(ushort id, int count)**
- 해당 `id`의 오브젝트를 `count` 개수만큼 미리 생성하여 스택에 담아놓는다.

### **Spawn(ushort id)**
- `id`에 해당하는 게임오브젝트를 풀에서 꺼내며 활성화한다.
- 풀에 여유가 없을 경우, 새로 생성한다.

### **Despawn(PoolObject obj)**
- 대상 오브젝트를 비활성화하여 풀에 넣는다.
- `PoolObject`가 기억하는 자신의 ID에 해당되는 풀에 알아서 들어간다.

<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>


# Download
---
- 



