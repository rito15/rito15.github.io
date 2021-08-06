---
title: 유니티 오브젝트 풀링(Object Pooling)
author: Rito15
date: 2021-08-06 01:22:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 1. 목표
---
- 오브젝트 풀링 기법 이해하기

- `Key` 기반 다중 풀링 기법 이해하기

- 오브젝트 풀 매니저 클래스 구현하기

<br>


# 2. 개념
---

게임오브젝트를 생성, 파괴하는 것은 순간적으로 큰 성능 소모 및 프레임 저하를 발생시킬 수 있다.

따라서 생성, 파괴 대신 활성화, 비활성화 방식을 사용하면 순간적인 프레임 저하를 방지할 수 있다.

이를 오브젝트 풀링 기법이라고 하며, 동일한 여러 개의 오브젝트를 하나의 풀(예 : 리스트, 스택, 큐)에  미리 담아 관리한다.

파괴 대신 비활성화하여 풀에 저장하고, 생성 대신 풀에서 꺼내어 활성화하는 방식을 사용한다.

<br>

풀 내의 오브젝트는 파괴되지 않고 메모리에 계속 남아있기 때문에, 

CPU 성능 소모를 줄이고 메모리 사용량을 더 늘리는 기법이라고 할 수 있다.

<br>


# 3. 참고사항
---

- 오브젝트 풀링의 대상이 되는 오브젝트 내에 생성되는 순간 발생해야 하는 이벤트가 있을 경우, 활성화 순간에 발생하도록 변경해주어야 한다.<br>
  - 예시 : `Awake()`, `Start()` -> `OnEnable()`로 이동

- 게임오브젝트 파괴(`Destroy(Object)`)를 사용하던 코드는 모두 오브젝트 풀에 의한 비활성화로 변경해야 한다.

- 자주 사용되지 않는 오브젝트가 계속 풀에 남아있으면 불필요하게 메모리를 소모하므로, 때때로 잘 판단하여 제거해줄 필요가 있다.

- 풀로 사용될 컨테이너 타입으로는 `List<T>`, `Stack<T>`, `Queue<T>` 등을 고려해볼 수 있으며, 각각 성능은 크게 차이 없지만 `Stack<T>`이 그나마 가장 낫다고 한다.
  - <https://forum.unity.com/threads/object-pool-performance.453524/>

<br>

# 4. 설계
---

## **[1] 오브젝트 풀링**

오브젝트 풀링의 개념은 간단하다.

게임오브젝트를 파괴하는 대신 비활성화하여 풀에 넣고,

생성하는 대신 풀에서 꺼내어 활성화하면 된다.

따라서 동일한 게임오브젝트 여러 개를 풀링하려면 하나의 풀로 간단히 구현할 수 있다.

풀을 스택으로 구현한다고 할 때, 스택에 단순히 `GameObejct`를 담는다면

풀은 `Stack<GameObject>` 타입이 된다.

<br>

## **[2] 다중 풀링**

서로 다른 게임오브젝트들을 각각 풀링하려면 조금 더 복잡해진다.

우선 각각의 풀을 하나의 컨테이너에서 관리해야 한다.

그리고 컨테이너 내의 풀에 접근할 때마다 선형 탐색, 이진 탐색과 같은 방법을 사용하는 것은 비효율적이며, 해시 테이블 형태의 컨테이너를 사용하는 것이 좋다.

`C#`에서는 `Dictionary<,>`를 사용하면 된다.

따라서 각각의 풀마다 접근할 `Key`를 미리 정의하고,

다중 풀링 컨테이너는 `Dictionary<KeyType, Stack<GameObject>>` 형태로 구현하여

`Key`를 이용해 풀에 접근하게 될 것이다.

<br>

## **[3] 샘플 오브젝트**

동일한 게임오브젝트를 복제하여 다수를 풀에 넣어 놓기 위해서는

복제의 대상이 될 샘플 게임오브젝트가 하나씩 필요하다.

`Key`를 이용해 풀을 관리하는 것처럼,

샘플 오브젝트 역시 `Key`를 통해 참조할 수 있도록

`Dictionary<KeyType, GameObject>`와 같은 형태로 관리한다.

그리고 샘플 오브젝트는 반드시 파괴되지 않도록 보장해줘야 한다.

<br>

## **[4] Key 선택**

다중 풀링에서 각각의 풀에 접근하기 위해서는 `Key`가 필요하다.

그리고 우선 `Key`를 어떻게 정할 것인지, 타입은 무엇으로 할지 결정해야 한다.

사실 가장 간편하면서도 좋은 선택이 될 수 있는 것은 게임오브젝트의 이름 또는 태그를 사용하는 것이다.

항상 동일하게 유지될 샘플 오브젝트의 이름을 `Key`로 사용하고,

샘플로부터 복제하여 풀에 넣는 오브젝트들도 동일한 이름을 사용하게 한다.

이렇게 되면 풀에 다시 집어넣을 때,

복제된 오브젝트로부터 번거로운 방식으로 `Key`를 알아내는 과정 없이

곧바로 해당 오브젝트의 이름을 `Key`로 사용하여 알맞은 풀을 참조하여

곧장 풀에 다시 회수할 수 있다는 이점이 있다.

<br>

그런데 현재 유니티에서 이 방식은 치명적인 단점이 있다.

게임오브젝트의 이름과 태그는 각각 `.name`, `.tag` 프로퍼티로 참조할 수 있는데

이 프로퍼티들을 참조할 때마다 스트링이 동적으로 생성되어 가비지를 남기고,

결국 `GC`의 수집 대상이 된다는 점이다.

이렇게 되면 풀링을 통한 활성화/비활성화를 수행할 때마다 `GC` 호출이 일어나므로

불필요한 성능 저하가 발생할 수 있다.

<br>

## **[5] GC 문제 해결을 위한 2가지 방법**

위의 문제가 발생하는 근본 원인은 다음과 같다.

풀에 저장된 오브젝트를 꺼내어 활성화하는 것(`Spawn`)은 아무런 문제가 없지만

오브젝트를 풀에 다시 집어넣을 때(`Despawn`),

해당 오브젝트로부터 `Key`를 알아내는 과정이 문제가 된다.

이를 해결하기 위해서 두 가지 방안이 있다.

<br>

### **[5-1] 컴포넌트를 추가로 사용하기**

복제된 오브젝트에 `Key`의 정보를 갖고 있는 컴포넌트를 추가한다.

그러면 복제된 오브젝트를 다시 풀에 넣을 때 이 컴포넌트의 `Key`를 직접 참조하여

해당되는 풀에 넣어주면 해결된다.

대신, 간단히 `GameObject`로 풀링 대상을 참조하던 모든 코드에서

이 컴포넌트의 타입을 참조하도록 해주어야 하며

외부에서 복제된 컴포넌트를 다시 풀에 넣으려고 할 때도

반드시 이 컴포넌트를 참조해야만 한다.

<br>

### **[5-2] 복제된 오브젝트를 모두 캐싱하기**

`Dictionary<GameObject, Stack<GameObject>>` 타입으로

복제된 오브젝트를 키로 사용해 해당하는 풀을 곧바로 참조하는 방법이다.

이를 이용하면 굳이 `[5-1]`처럼 별도의 컴포넌트를 사용할 필요가 없고,

`GameObject` 타입으로 오브젝트를 곧장 참조할 수 있다는 장점이 있다.

대신, 복제된 모든 오브젝트를 `Dictionary`에 저장하므로

생성, 파괴 시 반드시 `Dictionary`에 추가, 제거하는 과정을 거쳐야 한다.

<br>

### **[6] Key 타입 결정**

이제 위의 두 가지 방법 중 하나를 선택하여 문제를 해결할 수 있다.

그리고 `Key`의 타입을 원하는 대로 결정할 수 있는데,

`string` 타입을 우선 생각해볼 수 있다.

문자열을 `Key`로 사용하면 직관적이라는 것이 가장 큰 장점이다.

하지만 스크립팅 시 오탈자가 발생하면 치명적일 수 있다는 단점이 있고

혹여나 동적으로 스트링을 생성하면 그대로 `GC`의 먹이가 된다는 문제점이 있다.

<br>

그 다음으로는 숫자 타입을 고려해볼 수 있다.

`int`와 같은 숫자 타입을 사용하게 되면,

풀링 대상이 미리 정해져 있는 경우

```cs
const int BulletKeyA = 101;
const int BulletKeyB = 102;
```

이렇게 미리 상수를 정의하여 참조할 수도 있고

동적으로 풀에 추가된다고 해도, 키가 중복되지 않도록 키 관리 매니저를 만들어서

키를 차례로 발급하여 사용할 수도 있다.

<br>

마지막으로 사용자 정의 `enum`을 생각해볼 수 있는데,

이는 오로지 모든 풀링 오브젝트가 컴파일 타임에 결정된 경우에 한해 사용한다.

하나의 `enum`으로 모든 풀링 오브젝트의 키 정보를 관리할 수 있고

스크립팅 시 문자열과는 다르게 오탈자를 걱정하지 않아도 되므로

컴파일 타임에 미리 풀링 오브젝트를 모두 결정하는 경우라면 굉장히 편리한 방법이라고 할 수 있다.

<br>

### **[7] 풀의 오브젝트 개수 제한**

풀에서 오브젝트를 꺼내려고 할 때,

풀이 완전히 비어있는 경우를 생각해볼 수 있다.

이런 경우에는 어쩔 수 없이 샘플 오브젝트로부터 새롭게 복제하여 전달해야 한다.

<br>

따라서 평소에는 50개 정도의 오브젝트를 만들고 풀에 넣어 사용하다가

순간적으로 500개의 오브젝트를 새로 복제하는 경우가 발생했다고 가정해보자.

이제 500개의 오브젝트를 다시 풀에 전부 집어넣게 되면,

실제로 50개만 필요한데 500개의 오브젝트가 메모리를 점유하게 된다.

<br>

따라서 이런 경우를 대비해 미리 각각의 풀마다 개수 한도를 지정해 놓고,

풀 내의 오브젝트가 한도에 도달했을 때 풀에 넣으려고 시도하면

풀에 넣지 않고, 대신 파괴하는 방법을 사용해야 한다.

<br>

그런데 위와 같은 경우처럼 500개를 한 번에 파괴하려고 하면

순간적으로 극심한 성능 저하가 발생할 수 있다.

따라서 이를 피하기 위해 일단 한도 이상의 오브젝트를 풀에 회수하는 것을 허용하고,

한도에 도달할 때까지 차근차근 풀 내의 오브젝트들을 파괴하는 방법을 통해 최적화를 고려해볼 수 있다.

<br>



# 5. 별도의 컴포넌트 기반으로 구현하기
---

`4 - [5-1]`의 방법대로 구현한다.


## **[1] Key 타입**

하나의 타입으로 지정할 수도 있고,

제네릭으로 클래스를 정의한 다음 타입을 특정하여 상속받아 사용할 수도 있지만

다음과 같이 `using`을 활용하여 스크립트 상단에서 정하도록 한다.

```cs
using KeyType = System.String;
```

<br>

## **[2] PoolObjectData 클래스**

각각의 풀에 대한 정보를 하나의 클래스로 묶어 정의한다.

추후 작성할 풀 매니저의 인스펙터에서 리스트에 담아 사용하며,

풀 매니저는 이를 기반으로 풀링 데이터를 생성한다.

인스펙터에서 표시해야 하므로 `[System.Serializable]` 애트리뷰트를 붙여준다.

<br>

<details>
<summary markdown="span"> 
PoolObjectData.cs
</summary>

```cs
using UnityEngine;
using KeyType = System.String;

/// <summary> 풀 대상 오브젝트에 대한 정보 </summary>
[System.Serializable]
public class PoolObjectData
{
    public const int INITIAL_COUNT = 10;
    public const int MAX_COUNT = 50;

    public KeyType key;
    public GameObject prefab;
    public int initialObjectCount = INITIAL_COUNT; // 오브젝트 초기 생성 개수
    public int maxObjectCount     = MAX_COUNT;     // 큐 내에 보관할 수 있는 오브젝트 최대 개수
}
```

</details>

<br>

## **[3] PoolObject 클래스**

복제된 오브젝트의 컴포넌트로 들어가는 클래스.

필드로 키값을 보관한다.

<br>

<details>
<summary markdown="span"> 
PoolObject.cs
</summary>

```cs
using UnityEngine;
using KeyType = System.String;

[DisallowMultipleComponent]
public class PoolObject : MonoBehaviour
{
    public KeyType key;

    /// <summary> 게임오브젝트 복제 </summary>
    public PoolObject Clone()
    {
        GameObject go = Instantiate(gameObject);
        if (!go.TryGetComponent(out PoolObject po))
            po = go.AddComponent<PoolObject>();
        go.SetActive(false);

        return po;
    }

    /// <summary> 게임오브젝트 활성화 </summary>
    public void Activate()
    {
        gameObject.SetActive(true);
    }

    /// <summary> 게임오브젝트 비활성화 </summary>
    public void Deactivate()
    {
        gameObject.SetActive(false);
    }
}
```

</details>

<br>

## **[4] ObjectPoolManager 클래스**

각각의 풀을 생성하고, 풀에서 오브젝트를 꺼내고 집어넣는 역할을 수행한다.

싱글톤으로 구현하는 것이 좋다.

싱글톤 구현부는 생략한다.

<br>

`ObjectPoolManager`의 주요 기능은 세가지이다.

1. `Register` : 키를 등록하고, 해당 키에 대해 풀을 생성한다.
2. `Spawn` : 키를 참조하여, 해당되는 풀에서 오브젝트를 꺼내온다.
3. `Despawn` : 오브젝트를 다시 풀에 집어넣는다.

<br>

<details>
<summary markdown="span"> 
ObjectPoolManager.cs
</summary>

```cs
using System.Collections.Generic;
using UnityEngine;
using System;

using KeyType = System.String;

/// <summary> 
/// 오브젝트 풀 관리 싱글톤
/// </summary>
[DisallowMultipleComponent]
public class ObjectPoolManager : MonoBehaviour
{
    // 인스펙터에서 오브젝트 풀링 대상 정보 추가
    [SerializeField]
    private List<PoolObjectData> _poolObjectDataList = new List<PoolObjectData>(4);
    
    // 복제될 오브젝트의 원본 딕셔너리
    private Dictionary<KeyType, PoolObject> _sampleDict;
    
    // 풀링 정보 딕셔너리
    private Dictionary<KeyType, PoolObjectData> _dataDict;
    
    // 풀 딕셔너리
    private Dictionary<KeyType, Stack<PoolObject>> _poolDict;
    
    private void Start()
    {
        Init();
    }

    private void Init()
    {
        int len = _poolObjectDataList.Count;
        if (len == 0) return;

        // 1. Dictionary 생성
        _sampleDict = new Dictionary<KeyType, PoolObject>(len);
        _dataDict   = new Dictionary<KeyType, PoolObjectData>(len);
        _poolDict   = new Dictionary<KeyType, Stack<PoolObject>>(len);

        // 2. Data로부터 새로운 Pool 오브젝트 정보 생성
        foreach (var data in _poolObjectDataList)
        {
            Register(data);
        }
    }
    
    /// <summary> Pool 데이터로부터 새로운 Pool 오브젝트 정보 등록 </summary>
    private void Register(PoolObjectData data)
    {
        // 중복 키는 등록 불가능
        if (_poolDict.ContainsKey(data.key))
        {
            return;
        }

        // 1. 샘플 게임오브젝트 생성, PoolObject 컴포넌트 존재 확인
        GameObject sample = Instantiate(data.prefab);
        if (!sample.TryGetComponent(out PoolObject po))
        {
            po = sample.AddComponent<PoolObject>();
            po.key = data.key;
        }
        sample.SetActive(false);

        // 2. Pool Dictionary에 풀 생성 + 풀에 미리 오브젝트들 만들어 담아놓기
        Stack<PoolObject> pool = new Stack<PoolObject>(data.maxObjectCount);
        for (int i = 0; i < data.initialObjectCount; i++)
        {
            PoolObject clone = po.Clone();
            pool.Push(clone);
        }

        // 3. 딕셔너리에 추가
        _sampleDict.Add(data.key, po);
        _dataDict.Add(data.key, data);
        _poolDict.Add(data.key, pool);
    }
    
    /// <summary> 풀에서 꺼내오기 </summary>
    public PoolObject Spawn(KeyType key)
    {
        // 키가 존재하지 않는 경우 null 리턴
        if (!_poolDict.TryGetValue(key, out var pool))
        {
            return null;
        }

        PoolObject po;

        // 1. 풀에 재고가 있는 경우 : 꺼내오기
        if (pool.Count > 0)
        {
            po = pool.Pop();
        }
        // 2. 재고가 없는 경우 샘플로부터 복제
        else
        {
            po = _sampleDict[key].Clone();
        }

        po.Activate();

        return po;
    }

    /// <summary> 풀에 집어넣기 </summary>
    public void Despawn(PoolObject po)
    {
        // 키가 존재하지 않는 경우 종료
        if (!_poolDict.TryGetValue(po.key, out var pool))
        {
            return;
        }

        KeyType key = po.key;

        // 1. 풀에 넣을 수 있는 경우 : 풀에 넣기
        if (pool.Count < _dataDict[key].maxObjectCount)
        {
            pool.Push(po);
            po.Deactivate();
        }
        // 2. 풀의 한도가 가득 찬 경우 : 파괴하기
        else
        {
            Destroy(po.gameObject);
        }
    }
}
```

</details>



<br>

# 6. GameObject 기반으로 구현하기
---

`4 - [5-2]`의 방법대로 구현한다.

`Key` 타입과 `PoolObjectData` 클래스는 `5`번의 구현과 같다.

<br>

## **ObjectPoolManager 클래스**

<details>
<summary markdown="span"> 
ObjectPoolManager.cs
</summary>

```cs
using System.Collections.Generic;
using UnityEngine;
using System;

using KeyType = System.String;

/// <summary> 
/// 오브젝트 풀 관리 싱글톤
/// </summary>
[DisallowMultipleComponent]
public class ObjectPoolManager : MonoBehaviour
{
    [SerializeField]
    private List<PoolObjectData> _poolObjectDataList = new List<PoolObjectData>(4);
    
    private Dictionary<KeyType, GameObject> _sampleDict;   // Key - 복제용 오브젝트 원본
    private Dictionary<KeyType, PoolObjectData> _dataDict; // Key - 풀 정보
    private Dictionary<KeyType, Stack<GameObject>> _poolDict;         // Key - 풀
    private Dictionary<GameObject, Stack<GameObject>> _clonePoolDict; // 복제된 게임오브젝트 - 풀
    
    private void Awake()
    {
        Init();
    }
    
    private void Init()
    {
        int len = _poolObjectDataList.Count;
        if (len == 0) return;

        // 1. Dictionary 생성
        _sampleDict    = new Dictionary<KeyType, GameObject>(len);
        _dataDict      = new Dictionary<KeyType, PoolObjectData>(len);
        _poolDict      = new Dictionary<KeyType, Stack<GameObject>>(len);
        _clonePoolDict = new Dictionary<GameObject, Stack<GameObject>>(len * PoolObjectData.INITIAL_COUNT);

        // 2. Data로부터 새로운 Pool 오브젝트 정보 생성
        foreach (var data in _poolObjectDataList)
        {
            RegisterInternal(data);
        }
    }
    
    /// <summary> Pool 데이터로부터 새로운 Pool 오브젝트 정보 등록 </summary>
    private void RegisterInternal(PoolObjectData data)
    {
        // 중복 키는 등록 불가능
        if (_poolDict.ContainsKey(data.key))
        {
            return;
        }

        // 1. 샘플 게임오브젝트 생성, PoolObject 컴포넌트 존재 확인
        GameObject sample = Instantiate(data.prefab);
        sample.name = data.prefab.name;
        sample.SetActive(false);

        // 2. Pool Dictionary에 풀 생성 + 풀에 미리 오브젝트들 만들어 담아놓기
        Stack<GameObject> pool = new Stack<GameObject>(data.maxObjectCount);
        for (int i = 0; i < data.initialObjectCount; i++)
        {
            GameObject clone = Instantiate(data.prefab);
            clone.SetActive(false);
            pool.Push(clone);

            _clonePoolDict.Add(clone, pool); // Clone-Stack 캐싱
        }

        // 3. 딕셔너리에 추가
        _sampleDict.Add(data.key, sample);
        _dataDict.Add(data.key, data);
        _poolDict.Add(data.key, pool);
    }
    
    /// <summary> 샘플 오브젝트 복제하기 </summary>
    private GameObject CloneFromSample(KeyType key)
    {
        if (!_sampleDict.TryGetValue(key, out GameObject sample)) return null;

        return Instantiate(sample);
    }
    
    /// <summary> 풀에서 꺼내오기 </summary>
    public GameObject Spawn(KeyType key)
    {
        // 키가 존재하지 않는 경우 null 리턴
        if (!_poolDict.TryGetValue(key, out var pool))
        {
            return null;
        }

        GameObject go;

        // 1. 풀에 재고가 있는 경우 : 꺼내오기
        if (pool.Count > 0)
        {
            go = pool.Pop();
        }
        // 2. 재고가 없는 경우 샘플로부터 복제
        else
        {
            go = CloneFromSample(key);
            _clonePoolDict.Add(go, pool); // Clone-Stack 캐싱
        }

        go.SetActive(true);
        go.transform.SetParent(null);

        return go;
    }

    /// <summary> 풀에 집어넣기 </summary>
    public void Despawn(GameObject go)
    {
        // 캐싱된 게임오브젝트가 아닌 경우 파괴
        if (!_clonePoolDict.TryGetValue(go, out var pool))
        {
            Destroy(go);
            return;
        }

        // 집어넣기
        go.SetActive(false);
        pool.Push(go);
    }
}
```

</details>

<br>

# 7. 에디터 전용 테스트 기능 구현
---

- `6`에 이어 구현한다.

<br>

위에서 구현한 코드를 그대로 사용할 경우,

![image](https://user-images.githubusercontent.com/42164422/128390737-847b3713-b68c-4075-a485-10c6925f800b.png)

이렇게 하이라키에 오브젝트가 가득 차서 작업이 불편해진다.

따라서 에디터에서는 각각의 풀별로 공통 게임오브젝트로 묶어주고,

풀마다 갖고 있는 오브젝트 개수도 손쉽게 확인할 수 있도록 해준다.

<br>

우선 스크립트의 최상단에 다음과 같이 추가해준다.

```cs
#if UNITY_EDITOR
#define TEST_ON
#endif
```

그리고 다음 메소드를 작성한다.

```cs
[System.Diagnostics.Conditional("TEST_ON")]
private void TestModeOnly(Action action)
{
    action();
}
```

`TestModeOnly()` 메소드의 호출은 전처리기에서 `TEST_ON`을 선언한 경우에만 동작한다.

그런데 `TEST_ON`은 `UNITY_EDITOR` 선언이 유효한 경우에만 선언되므로

빌드 시 무조건 동작하지 않게 된다.

<br>

이제 스크립트에 다음 코드들을 작성해준다.

<details>
<summary markdown="span"> 
.
</summary>

```cs
private Dictionary<KeyType, GameObject> _t_ContainerDict;
private Dictionary<Stack<GameObject>, KeyType> _t_poolKeyDict;

// 컨테이너 이름 변경
[System.Diagnostics.Conditional("TEST_ON")]
private void Test_ChangeContainerName(KeyType key)
{
    if (!_testModeOn) return;
    Stack<GameObject> pool = _poolDict[key];

    int cloneCount = _cloneDict.Values.Where(v => v.pool == pool).Count();
    int inPoolCount = pool.Count;
    int maxCount = _dataDict[key].maxObjectCount;

    _t_ContainerDict[key].name
        = $"Pool <{key}> - [{cloneCount - inPoolCount}] Used, [{inPoolCount}] Available, [{maxCount}] Max";
}

private void Init()
{
    TestModeOnly(() =>
    {
        _t_ContainerDict = new Dictionary<KeyType, GameObject>();
        _t_poolKeyDict = new Dictionary<Stack<GameObject>, KeyType>();
    });

    // Codes...
}

private void RegisterInternal(PoolObjectData data)
{
    // Codes...
    
    TestModeOnly(() =>
    {
        // 샘플을 공통 게임오브젝트의 자식으로 묶기
        string posName = "ObjectPool Samples";
        GameObject parentOfSamples = GameObject.Find(posName);
        if (parentOfSamples == null)
            parentOfSamples = new GameObject(posName);

        sample.transform.SetParent(parentOfSamples.transform);

        // 풀 - 키 딕셔너리에 추가
        _t_poolKeyDict.Add(pool, data.key);

        // 컨테이너 게임오브젝트 생성
        _t_ContainerDict.Add(data.key, new GameObject(""));

        // 컨테이너 자식으로 설정
        foreach (var item in pool)
        {
            item.transform.SetParent(_t_ContainerDict[data.key].transform);
        }
        
        // 컨테이너 이름 변경
        Test_ChangeContainerName(data.key);
    });
}

public GameObject Spawn(KeyType key)
{
    // Codes...

    TestModeOnly(() =>
    {
        // 컨테이너 이름 변경
        Test_ChangeContainerName(key);
    });

    return go;
}

/// <summary> 풀에 집어넣기 </summary>
public void Despawn(GameObject go)
{
    // Codes...
    
    TestModeOnly(() =>
    {
        KeyType key = _t_poolKeyDict[pool];

        // 컨테이너 자식으로 넣기
        go.transform.SetParent(_t_ContainerDict[key].transform);

        // 컨테이너 이름 변경
        Test_ChangeContainerName(key);
    });
}
```

</details>

이제 하이라키에서 다음과 같이 깔끔히 정리되는 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/128391120-dcd7add3-e930-4448-a574-15a58c562f4d.png)

<br>

# 8. 조건적 디버깅 구현
---

`bool`타입 필드의 체크/해제로 활성화/비활성화되는 디버그 콘솔 출력 기능을 구현한다.

```cs
#if UNITY_EDITOR
#define DEBUG_ON
#define TEST_ON
#endif
```

위와 같이 전처리기를 통해 `DEBUG_ON` 선언을 추가해준다.

만약 빌드 이후 디버그 콘솔 확인이 필요할 경우,

`#if UNITY_EDITOR` ~ `#endif` 바깥으로 옮겨준다.

`bool` 타입 필드만 사용해도 활성화/비활성화가 가능한데 굳이 전처리 선언을 해주는 이유는

최종 빌드 시 컴파일 대상에서 완전히 제외시키기 위함이다.

<br>

그리고 다음과 같이 작성한다.

```cs
[SerializeField]
private bool _debugOn = true;

[System.Diagnostics.Conditional("DEBUG_ON")]
private void DebugLog(string msg)
{
    if (!_debugOn) return;
    Debug.Log(msg);
}

[System.Diagnostics.Conditional("DEBUG_ON")]
private void DebugLog(bool condition, string msg)
{
    if (!_debugOn) return;
    if (condition) Debug.Log(msg);
}
```

<br>

기능마다 디버그 출력 여부를 분리해줄 수도 있다.

```cs
[Header("Debug Options")]
[SerializeField] private bool _debugOn = true;
[SerializeField] private bool _debugRegister = true;
[SerializeField] private bool _debugSpawn    = true;
[SerializeField] private bool _debugDespawn  = true;
```


<br>

# 9. 추가 기능 구현
---

## **[1] Register API 제공**

플레이 도중에도 원하는 타이밍에 동적으로 새로운 오브젝트를 풀에 등록할 수 있도록 메소드를 제공한다.

<br>

<details>
<summary markdown="span"> 
.
</summary>

```cs
/// <summary> 키를 등록하고 새로운 풀 생성 </summary>
public void Register(KeyType key, GameObject prefab, 
    int initalCount = PoolObjectData.INITIAL_COUNT, int maxCount = PoolObjectData.MAX_COUNT)
{
    // 중복 키는 등록 불가능
    if (_poolDict.ContainsKey(key))
    {
        DebugLog(_debugRegister, $"{key}가 이미 Pool Queue Dict에 존재합니다.");
        return;
    }

    if (initalCount < 0) initalCount = 0;
    if (maxCount < 10) maxCount = 10;

    PoolObjectData data = new PoolObjectData
    {
        key = key,
        prefab = prefab,
        initialObjectCount = initalCount,
        maxObjectCount = maxCount
    };
    _poolObjectDataList.Add(data);

    RegisterInternal(data);
}
```

</details>

<br>

## **[2] 풀 한도 이상의 오브젝트 점진적 파괴**

각각의 풀마다 정해진 한도(기본값 : 50)를 초과하여 오브젝트가 저장될 경우

초과분 오브젝트를 하나씩 천천히 파괴한다.

코루틴을 이용해 구현하며, 풀 하나당 코루틴을 하나씩 배정한다.

<br>

<details>
<summary markdown="span"> 
.
</summary>

```cs
[SerializeField]
private float _poolCleaningInterval = 0.1f; // 풀 한도 초과 오브젝트 제거 간격

private void RegisterInternal(PoolObjectData data)
{
    DebugLog($"Register : {data.key}");

    // Codes...
    
    // 클리너 코루틴 시작
    StartCoroutine(PoolCleanerRoutine(data.key));
}

/// <summary> 각 풀마다 한도 개수를 초과할 경우, 점진적으로 내부 오브젝트 파괴 </summary>
private IEnumerator PoolCleanerRoutine(KeyType key)
{
    if (!_poolDict.TryGetValue(key, out var pool)) yield break;
    if (!_dataDict.TryGetValue(key, out var data)) yield break;
    WaitForSeconds wfs = new WaitForSeconds(_poolCleaningInterval);

    while (true)
    {
        if (pool.Count > data.maxObjectCount)
        {
            GameObject clone = pool.Pop(); // 풀에서 꺼내기
            _cloneDict.Remove(clone);      // Clone - Pool 딕셔너리에서 제거
            Destroy(clone);                // 게임오브젝트 파괴

            Test_ChangeContainerName(key); // 컨테이너 이름 변경
        }

        yield return wfs;
    }
}
```

</details>

<br>

## **[3] 관계 없는 게임오브젝트에 대한 Despawn 처리**

풀에서 제공되지 않은 오브젝트에 대해 의도치 않게 `Despawn`을 시도하는 경우가 발생할 수도 있다.

엄격하게 대응하려면 여기에 예외를 발생시키고,

관대하게 대응하려면 `Destroy`를 호출해주거나 무시할 수 있다.

인스펙터에서 세 가지 옵션 중 선택하여, 그에 따라 처리하도록 해준다.

<br>

<details>
<summary markdown="span"> 
.
</summary>

```cs
/// <summary> 풀에서 제공되지 않은 오브젝트에 대한 Despawn 처리 </summary>
private enum NonePoolObjectDespawnPolicy
{
    Ignore,
    ThrowException,
    Destroy
}

[SerializeField]
private NonePoolObjectDespawnPolicy _nonePoolObjectDespawnPolicy = NonePoolObjectDespawnPolicy.Destroy;

public void Despawn(GameObject go)
{
    if (go == null) return;
    if (go.activeSelf == false) return;

    // 복제된 게임오브젝트가 아닌 경우 - 정책에 따라 처리
    if (!_cloneDict.TryGetValue(go, out var cloneData))
    {
        switch (_nonePoolObjectDespawnPolicy)
        {
            case NonePoolObjectDespawnPolicy.Ignore:
                DebugLog(_debugDespawn, $"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");
                break;

            case NonePoolObjectDespawnPolicy.ThrowException:
                throw new ArgumentException($"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");

            case NonePoolObjectDespawnPolicy.Destroy:
                DebugLog(_debugDespawn, $"풀에서 제공하지 않은 오브젝트를 파괴합니다 : {go.name}({go.GetInstanceID()})");
                Destroy(go);
                break;
        }

        return;
    }

    DebugLog(_debugDespawn, $"Despawn : {go.name}({go.GetInstanceID()})");
    
    // 집어넣기
    go.SetActive(false);
    pool.Push(go);
}
```

</details>

<br>

## **[4] 지정된 시간 후 Despawn 기능**

`Destroy(obj, time)` 메소드를 통해 오브젝트를 일정 시간 후 파괴하는 기능처럼

지정된 시간이 지나면 풀에 회수되는 기능을 구현한다.

가장 간단한 방법은 각각의 오브젝트마다 코루틴을 사용하는 것이다.

하지만 코루틴의 실행 자체가 가비지를 발생시키고,

오브젝트마다 코루틴을 실행시키는 것은 성능에 좋지 않을 수 있기 때문에 다른 방법을 사용한다.

<br>

### **Task 사용**

여기서 사용할 방법은 `Task`를 활용하는 것이다.

`Despawn`이 예약될 경우 `Task`를 실행시켜 딜레이를 기다린 후 풀에 회수한다.

그런데 풀에 회수하기 위헤 게임오브젝트를 비활성화하는 작업은 `Unity API`에 속하므로

워커 스레드에서 동작하는 `Task`를 통해 실행할 수 없다.

따라서 `Main Thread Dispatcher`의 방식처럼

스레드간 동기화되는 `Queue`를 하나 만들고,

`Task`에서는 예약된 대상 오브젝트를 `Queue`에 넣게 된다.

그리고 `Update()`에서 이 `Queue`를 확인하여,

담겨있는 요소들을 모두 꺼내어 풀에 회수해준다.

<br>

### **Version 관리 기법**

추가적으로 고려해야 할 사항이 있다.

1. 이미 예약된 오브젝트에 예약을 중첩 또는 갱신하는 경우
2. 이미 예약된 오브젝트를 즉시 `Despawn`하려는 경우

유연한 처리를 위해서는 위의 두 경우에 모두 기존 예약을 취소해주는 것이 좋다.

그런데 `Task`를 사용하는 경우, 진행 중인 `Delay`를 취소할 수는 없다.

굳이 이를 취소하려면 일정 주기로 바쁜 대기를 해야 하는데,

성능 저하를 유발할 뿐더러 예약 확인을 위한 스레드 동기화 처리도 필요하다.

대신 `Version`을 적용하면 이에 유연하게 대처할 수 있다.

<br>

방법은 다음과 같다.

- `Despawn` 예약 정보를 클래스로 정의한다.
- `Despawn` 예약 정보에 정수 타입의 `Version`을 필드로 추가한다.
- `Despawn`의 예약을 갱신하거나 취소할 때마다 `Version`을 `1` 증가시킨다.
- `Task.Delay`전후의 `Version`을 비교하여, 일치하는 경우에만 `Despawn`을 수행한다.

<br>

### **구현**

<details>
<summary markdown="span"> 
.
</summary>

```cs
/// <summary> 복제된 오브젝트의 예약 정보 </summary>
private class CloneScheduleInfo
{
    public readonly GameObject clone;
    public readonly Stack<GameObject> pool;
    public bool DespawnScheduled => _despawnScheduled;

    private bool _despawnScheduled;
    private int _scheduleVersion;

    public CloneScheduleInfo(GameObject clone, Stack<GameObject> pool)
    {
        this.clone = clone;
        this.pool = pool;
        this._despawnScheduled = false;
        this._scheduleVersion = 0;
    }

    /// <summary> Despawn 예약하고 버전 반환 </summary>
    public int ScheduleToDespawn()
    {
        _despawnScheduled = true;
        _scheduleVersion++;

        return _scheduleVersion;
    }

    /// <summary> 예약 취소 </summary>
    public void CancelSchedule()
    {
        if (_despawnScheduled == false) return;

        _despawnScheduled = false;
        _scheduleVersion++;
    }

    /// <summary> 예약 유효성 검증 </summary>
    public bool IsScheduleValid(int prevVersion)
    {
        return _despawnScheduled && (prevVersion == _scheduleVersion);
    }
}

// 복제된 게임오브젝트 - 클론 정보
private Dictionary<GameObject, CloneScheduleInfo> _cloneDict;

// 디스폰 스케줄링 동기화 큐
private readonly ConcurrentQueue<CloneScheduleInfo> _despawnScheduleQueue = new ConcurrentQueue<CloneScheduleInfo>();

private void Init()
{
    // Codes..

    _sampleDict = new Dictionary<KeyType, GameObject>(len);
    _dataDict   = new Dictionary<KeyType, PoolObjectData>(len);
    _poolDict   = new Dictionary<KeyType, Stack<GameObject>>(len);
    
    // 추가
    _cloneDict  = new Dictionary<GameObject, CloneScheduleInfo>(len * PoolObjectData.INITIAL_COUNT);

    // Codes..
}

private void RegisterInternal(PoolObjectData data)
{
    // Codes...

    Stack<GameObject> pool = new Stack<GameObject>(data.maxObjectCount);
    for (int i = 0; i < data.initialObjectCount; i++)
    {
        GameObject clone = Instantiate(data.prefab);
        clone.SetActive(false);
        pool.Push(clone);

        // 추가
        _cloneDict.Add(clone, new CloneScheduleInfo(clone, pool));
    }
    
    // Codes...
}

public GameObject Spawn(KeyType key)
{
    // Codes...

    if (pool.Count > 0)
    {
        go = pool.Pop();
        DebugLog(_debugSpawn, $"Spawn : {go.name}({go.GetInstanceID()})");
    }
    else
    {
        go = CloneFromSample(key);
        DebugLog(_debugSpawn, $"Spawn[Create] : {go.name}({go.GetInstanceID()})");
        
        // 추가
        _cloneDict.Add(go, new CloneScheduleInfo(go, pool));
    }

    // Codes...

    return go;
}

/// <summary> Despawn 실제 처리 </summary>
private void DespawnInternal(CloneScheduleInfo data)
{
    // 예약되어 있던 경우, 해제
    data.CancelSchedule();

    // 풀에 집어넣기
    data.clone.SetActive(false);
    data.pool.Push(data.clone);

    TestModeOnly(() =>
    {
        KeyType key = _t_poolKeyDict[data.pool];

        // 컨테이너 자식으로 넣기
        data.clone.transform.SetParent(_t_ContainerDict[key].transform);

        // 컨테이너 이름 변경
        Test_ChangeContainerName(key);
    });
}

/// <summary> 풀에 집어넣기 </summary>
public void Despawn(GameObject go)
{
    if (go == null) return;
    if (go.activeSelf == false) return;

    // 복제된 게임오브젝트가 아닌 경우 - 정책에 따라 처리
    if (!_cloneDict.TryGetValue(go, out var cloneData))
    {
        switch (_nonePoolObjectDespawnPolicy)
        {
            case NonePoolObjectDespawnPolicy.Ignore:
                DebugLog(_debugDespawn, $"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");
                break;

            case NonePoolObjectDespawnPolicy.ThrowException:
                throw new ArgumentException($"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");

            case NonePoolObjectDespawnPolicy.Destroy:
                DebugLog(_debugDespawn, $"풀에서 제공하지 않은 오브젝트를 파괴합니다 : {go.name}({go.GetInstanceID()})");
                Destroy(go);
                break;
        }

        return;
    }

    DespawnInternal(cloneData);

    DebugLog(_debugDespawn && cloneData.DespawnScheduled, $"Despawn 예약 해제 및 즉시 실행 : {go.name}({go.GetInstanceID()})");
    DebugLog(_debugDespawn && !cloneData.DespawnScheduled, $"Despawn : {go.name}({go.GetInstanceID()})");
}

/// <summary> n초 후 풀에 집어넣기 </summary>
public void Despawn(GameObject go, float seconds)
{
    if (go == null) return;
    if (go.activeSelf == false) return;

    int version;

    // 1. 풀에서 제공한 오브젝트가 아닌 경우 - 정책에 따라 처리
    if (_cloneDict.TryGetValue(go, out CloneScheduleInfo data) == false)
    {
        switch (_nonePoolObjectDespawnPolicy)
        {
            case NonePoolObjectDespawnPolicy.Ignore:
                DebugLog(_debugDespawn, $"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");
                break;

            case NonePoolObjectDespawnPolicy.ThrowException:
                throw new ArgumentException($"풀에서 제공된 오브젝트가 아닙니다 : {go.name}");

            case NonePoolObjectDespawnPolicy.Destroy:
                DebugLog(_debugDespawn, $"풀에서 제공하지 않은 오브젝트를 {seconds}초 후 파괴합니다 : {go.name}({go.GetInstanceID()})");
                Destroy(go, seconds);
                break;
        }

        return;
    }
    // 2. 풀에서 제공한 오브젝트가 맞는 경우
    else
    {
        // 0초 이하로 설정한 경우, 즉시 풀에 집어넣기
        if (seconds <= 0f)
        {
            DespawnInternal(data);
            return;
        }

        DebugLog(_debugDespawn && !data.DespawnScheduled, $"{seconds}초 후 Despawn 예약 : {go.name}({go.GetInstanceID()})");
        DebugLog(_debugDespawn && data.DespawnScheduled, $"{seconds}초 후 Despawn 예약[갱신] : {go.name}({go.GetInstanceID()})");

        // 정상 : 예약 설정
        version = data.ScheduleToDespawn();
    }

    // 예약
    Task.Run(async () => 
    {
        int prevVersion = version;

        await Task.Delay((int)(seconds * 1000));
                
        // 예약 정보가 유효한 경우, 큐에 넣기
        if (go != null && data.IsScheduleValid(prevVersion))
        {
            _despawnScheduleQueue.Enqueue(data);
        }
    });
}

/// <summary> Despawn 예약된 오브젝트들 확인하여 처리 </summary>
private void HandleScheduledDespawning()
{
    if (_despawnScheduleQueue.Count == 0) return;

    while (_despawnScheduleQueue.TryDequeue(out CloneScheduleInfo data))
    {
        // 예약이 취소된 경우, 종료
        if (data.DespawnScheduled == false)
            continue;
        // ------------------------------------------

        DespawnInternal(data);

#if DEBUG_ON
        if(_debugOn && data != null && data.clone != null)
            DebugLog(_debugDespawn, $"예약된 Despawn 처리 : {data.clone.name}({data.clone.GetInstanceID()})");
#endif
    }
}

private void Update()
{
    HandleScheduledDespawning();
}
```

</details>

<br>

# 10. 기타 고려사항
---

## **Don't Destroy On Load**

씬이 넘어가면 어차피 풀 내의 모든 게임오브젝트와 샘플 게임오브젝트가 모두 파괴된다.

굳이 `DontDestroyOnLoad`를 사용하겠다면 풀링된 게임오브젝트에 전부 적용해야 하는데

그럴 필요가 전혀 없다.

풀링은 어디까지나 씬 내에서 사용될 오브젝트에 대해 제한된다.

그러므로 각 씬마다 `ObjectPoolManager`를 하나씩 배치하고

풀링 대상 게임오브젝트들을 등록해주고,

`ObjectPoolManager`에는 `DontDestroyOnLoad`를 적용하지 않는 것이 좋다.

혹시나 싱글톤 클래스에는 무조건 `DontDestroyOnLoad`를 적용해야 한다고 생각하고 있었다면, 좀더 유연한 사고를 갖는 것이 좋다.


<br>

# Source Code
---
- <https://github.com/rito15/Unity-Object-Pooling>


<br>

# Future Works
---

- 깔끔한 커스텀 에디터 작성


