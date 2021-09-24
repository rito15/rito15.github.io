---
title: 자료구조 - 해시 테이블(Hash Table)
author: Rito15
date: 2021-07-20 17:14:00 +09:00
categories: [Algorithm, Data Structure]
tags: [algorithm, data structure, csharp]
math: true
mermaid: true
---


# 해시 테이블(Hash Table)
---

- 데이터의 삽입, 제거, 탐색이 모두 `O(1)`로 매우 빠르다.

- 내부적으로 정렬되지는 않는다.

- 저장할 데이터의 수보다 더 많은 공간이 필요하다.

<br>



# 구현 원리
---

- `Key`와 `Value`를 함께 저장하는 `Pair` 타입(클래스 또는 구조체)을 준비한다.

- `Pair[]` 타입의 `Bucket`을 생성한다.

- `Key`의 값을 해시 함수에 넣어서 배열의 `Index`를 계산한다.

- `Bucket`의 `Index` 위치에 `Pair`를 삽입, 삭제, 탐색한다.

- `Key`에 대한 해시 계산으로 인덱스를 얻을 수 있기 때문에 데이터 삽입, 삭제, 탐색의 시간복잡도는 모두 `O(1)`이 된다.

- 서로 다른 `Key`에 대해 동일한 `Index`가 발생할 수 있으므로(해시 충돌), 이를 확인하기 위해 반드시 `Bucket`은 `Value[]`가 아니라 `Pair[]` 타입이어야 한다.

<br>



# 참고 - 해시를 이용한 자료구조들
---

## **[1] Set(Hash Set)**

- `Key`만 저장한다.

- 저장할 `Key`를 해시 함수에 집어넣어 `Index`를 계산한다.

- 얻은 `Index` 위치의 배열 공간에 `Key`를 그대로 저장한다.

- 데이터의 중복을 허용하지 않는다. (중복을 허용하고 개수를 기록할 수도 있다.)

- 데이터의 존재 유무, 중복 확인을 목적으로 사용한다.

<br>

## **[2] Hash Table**

- `Key-Value Pair`를 저장한다.

- `Key`는 데이터의 탐색에 이용되고, 실제로 참조되는 데이터는 `Value`이다.

- 데이터를 빠르게 삽입, 삭제, 탐색하기 위해 사용된다.

<br>



# 인덱스 충돌 처리에 따른 구현 방식
---

- 서로 다른 `Key`에 대한 해시 함수의 결과로 동일한 `Index`가 발생하는 것을 인덱스 충돌이라고 한다.

- 인덱스 충돌을 처리하는 방법에 따라 구현 방식을 분류할 수 있다.

<br>


## **[1] Open Addressing 방식**
- 비어 있는 공간의 `Index`를 찾을 때까지 특정한 연산을 통해 `Index`를 새로 계산한다.

### **[1-1] Linear Probing**
- 현재 배열의 인덱스로부터 고정된 크기만큼 이동하며 차례대로 비어있는 공간을 찾아, 그 곳에 데이터를 저장한다.

### **[1-2] Quadratic Probing**
- Linear Probing과 유사하지만, 인덱스를 이동할 때 처음에는 2^0, 다음에는 2^1, 2^2, ...씩 이동하며 빈 공간을 찾는다.

### **[1-3] Double Hashing Probing**
- 해시된 값을 다시 Hash Function에 집어넣어서 또 계산하여 새로운 인덱스를 계산한다.
- Hash Function의 성능에 크게 좌우되며, 다른 Probing 방식에 비해 성능 소모가 크다.

<br>


## **[2] Separate Chaining 방식**
- `Pair`를 **Linked Node** 형태로 구현한다.

- 인덱스 충돌이 발생할 경우, 해당 인덱스의 맨 마지막 노드로 연결한다.

- 배열의 크기를 확장하지 않아도 데이터를 계속해서 넣을 수 있다.

<br>



# Open Addressing 방식으로 구현하기
---

## **구현 언어**

- `C#`

<br>


## **[1] 제네릭 타입**

<details>
<summary markdown="span"> 
.
</summary>

가능한 모든 타입에 대응하기 위해, `Key`와 `Value`를 제네릭 타입으로 사용한다.

따라서 클래스를 다음과 같이 정의한다.

```cs
class HashTable<TKey, TValue> { }
```

</details>

<br>


## **[2] Pair 구조체 정의**

<details>
<summary markdown="span"> 
.
</summary>

`Key`와 `Value`를 하나의 컨테이너로 담아 정의해야 한다.

클래스로 작성할 수도 있지만, GC를 피하기 위해 구조체로 작성한다.

```cs
struct Pair
{
    public TKey key;
    public TValue value;
    public bool isDummy;
}
```

**Open Addressing** 방식에서는 더미 데이터가 필요하다.

타입이 정해져 있으면 절대로 사용되지 않을 값들을 사용해 더미를 정의할 수 있지만,

제네릭이라 불가능하므로 더미 여부를 나타낼 수 있는 `isDummy` 필드를 사용한다.

</details>

<br>


## **[3] 필드 정의**

<details>
<summary markdown="span"> 
.
</summary>

내부 데이터들을 저장할 `Pair[]` 타입의 `Bucket` 필드를 정의한다.

그리고 `Bucket`의 크기를 저장하기 위한 정수 타입의 `Capacity` 필드를 정의한다.

<br>

그 다음으로, `Bucket` 내의 데이터의 개수를 저장하기 위한

정수 타입의 `Count` 필드를 정의한다.

<br>

그리고 **Open Addressing** 방식에서는 더미를 고려해야 한다.

더미는 데이터가 저장되지는 않지만 `Bucket` 내의 공간을 차지하므로

더미의 개수를 항상 관리할 필요가 있다.

따라서 정수 타입의 `DummyCount` 필드를 만든다.

<br>

- 정리

```cs
private Pair[] _bucket;

private int _capacity;
private int _count;
private int _dummyCount;
```

</details>

<br>


## **[4] GetHashIndex() : 해시 계산 메소드**

<details>
<summary markdown="span"> 
.
</summary>

`C#`에는 `Object.GetHashCode()`라는 메소드가 있다.

이를 통해 간편히 해시 값을 얻을 수 있으며,

여기에 추가적으로 간단한 연산을 더해 해시 메소드를 완성한다.

그리고 결과적으로 `Bucket` 내의 인덱스를 얻어야 하므로,

결과값이 `0` ~ `Capacity` 사이에 존재하도록 보장한다.

```cs
private const int HashSeed = 4327;

private int GetHashIndex(TKey key)
{
    int index = ((key.GetHashCode() + HashSeed) * HashSeed) % _capacity;

    // 음수 대처
    if (index < 0)
        index += _capacity;

    return index;
}
```

</details>

<br>


## **[5] GetNextIndex() : 인덱스 충돌 처리 메소드**

<details>
<summary markdown="span"> 
.
</summary>

`Open Addressing` 방식에서는 인덱스 충돌이 발생할 경우

정해진 수식을 통해 다음 인덱스를 얻어와야 한다.

```cs
private int GetNextIndex(int index)
{
    int nextIndex = (index + 1) % _capacity;
    return nextIndex;
}
```

**Linear Probing** 방식을 사용하여 단순히 인덱스에 `1`을 더해준다.

</details>

<br>


## **[6] Search() : 탐색 메소드**

<details>
<summary markdown="span"> 
.
</summary>

탐색 메소드의 입력은 `Key`이며,

출력은

1. 탐색 성공 여부(`true`/`false`)
2. 탐색을 종료한 위치의 `Index`
3. 탐색 성공 시 얻어낸 `Value`

이렇게 3가지이다.

<br>

우선 해시 함수를 통해 `Key`로부터 임의의 `Index`를 계산한다.

그리고 반복문 내부로 진입하여 다음을 반복한다.

1. `Bucket`의 해당 `Index` 위치가 비어있는 경우, 곧바로 종료하며 (`false`, `Index`, `default`)를 리턴한다.

2. 더미 또는 다른 `Key`를 발견한 경우, `GetNextIndex(Index)`를 통해 다음 인덱스로 넘어간다.

3. 동일한 `Key`를 발견한 경우, 곧바로 종료하며 (`true`, `Index`, `Value`)를 리턴한다.

여기서 주의할 점은 더미인데도 키값이 동일한 경우가 있을 수 있다는 것이다.

따라서 **2**는 반드시 **3**보다 먼저 검사해야 한다.

</details>

<br>


## **[7] Expand() : Bucket 확장 메소드**

<details>
<summary markdown="span"> 
.
</summary>

`Bucket` 내에 저장된 데이터가 많아질수록 해시를 통해 얻은 인덱스의 적중률이 점차 떨어지게 된다.

따라서 이는 성능 저하로 이어질 수 있으며, 적절한 타이밍에 `Bucket`을 확장해야 한다.

<br>

그리고 해시 메소드는 `Capacity`에 의존하기 때문에,

기존에 저장했던 데이터들에 대해 각각 다시 해시 계산을 하여 새롭게 저장해야 한다.

<br>

확장을 너무 가끔씩 해주면 해시 적중률이 떨어져 평소의 성능이 저하되고,

확장이 너무 잦으면 불필요한 성능과 메모리 낭비가 생길 수 있으므로

적절히 판단하여 확장해주어야 한다.

여기서는 `Count`와 `DummyCount`의 합이 `Capacity`의 절반 이상에 도달할 때마다 확장해준다.

<br>

확장하는 방법은 간단하다.

기존보다 더 큰 크기의 새로운 `Pair[]` 배열을 만들고,

`Capacity`에 새로운 배열 크기를 넣은 상태에서

`Bucket`에 있던 `Pair`들의 인덱스를 모두 해시를 통해 재계산하여

새로운 배열에 옮긴 뒤

`Bucket`에 새로운 배열을 할당하면 된다.

</details>

<br>


## **[8] Add() : 데이터 추가 메소드**

<details>
<summary markdown="span"> 
.
</summary>

매개변수로는 `Key`, `Value`를 받아 새로운 `Pair`를 만들고,

이를 `Bucket` 내에 저장하는 메소드.

만약 `Bucket`의 확장이 필요한 경우, 데이터를 추가하기 전에 확장한다.

그리고 `Search()` 메소드를 통해 동일한 `Key`의 존재 여부를 검사하고

저장할 `Index`를 가져온다.

<br>

1. 동일한 `Key`가 존재하지 않는 경우 해당 `Index` 위치에 저장하고<br>
   `Count`를 하나 증가시켜주며, `true`를 리턴한다.

2. 동일한 `Key`가 이미 존재하는 경우에는 `false`를 리턴한다.

</details>

<br>


## **[9] Remove() : 데이터 제거 메소드**

<details>
<summary markdown="span"> 
.
</summary>

매개변수로는 `Key`를 받아온다.

`Search()` 메소드를 통해 해당 `Key`가 존재하는지 여부를 검사하고

해당 위치의 `Index`를 가져온다.

<br>

1. `Key`가 존재할 경우 해당 위치에 `Dummy`를 덮어씌우고<br>
   `Count`를 하나 감소, `DummyCount`를 하나 증가시켜준다.<br>
   그리고 `true`를 리턴한다.

2. `Key`가 존재하지 않으면 `false`를 리턴한다.

</details>

<br>


# Separate Chaining 방식으로 구현하기
---

## **Open Addressing 방식과의 차이점**

- `Pair`는 앞뒤 연결이 존재하는 `Node` 형태로 구현해야 한다.

- `Dummy`가 존재하지 않는다.

- 인덱스 충돌로 인한 다음 인덱스 계산이 필요하지 않다.

<br>


## **[1] 제네릭 타입**

<details>
<summary markdown="span"> 
.
</summary>

가능한 모든 타입에 대응하기 위해, `Key`와 `Value`를 제네릭 타입으로 사용한다.

따라서 클래스를 다음과 같이 정의한다.

```cs
class HashTable<TKey, TValue> { }
```

</details>

<br>


## **[2] PairNode 클래스 정의**

<details>
<summary markdown="span"> 
.
</summary>

`Key`와 `Value`를 하나의 컨테이너로 담아 정의한다.

노드 형태로 구현하며, 앞뒤로 연결되는 다른 노드에 대한 참조가 필요하므로 클래스로 작성한다.

```cs
class PairNode
{
    public TKey key;
    public TValue value;

    public PairNode prev;
    public PairNode next;
}
```

</details>

<br>


## **[3] 필드 정의**

<details>
<summary markdown="span"> 
.
</summary>

내부 데이터들을 저장할 `Pair[]` 타입의 `Bucket` 필드를 정의한다.

그리고 `Bucket`의 크기는 정수 타입의 `Capacity` 필드에,

현재 저장된 데이터 개수는 정수 타입의 `Count` 필드에 저장한다.

**Separate Chaining** 방식에서는 더미 노드가 필요하지 않으므로 더미는 고려하지 않아도 된다.

<br>

- 정리

```cs
private PairNode[] _bucket;

private int _capacity;
private int _count;
```

</details>

<br>


## **[4] GetHashIndex() : 해시 계산 메소드**

<details>
<summary markdown="span"> 
.
</summary>

**Open Addressing**과 같은 방식으로

`Object.GetHashCode()`에 간단한 연산을 더해 해시 메소드를 완성한다.

```cs
private const int HashSeed = 4327;

private int GetHashIndex(TKey key)
{
    int index = ((key.GetHashCode() + HashSeed) * HashSeed) % _capacity;

    // 음수 대처
    if (index < 0)
        index += _capacity;

    return index;
}
```

</details>

<br>


## **[5] Search() : 탐색 메소드**

<details>
<summary markdown="span"> 
.
</summary>

탐색 메소드의 입력은 `Key`이며,

출력은

1. 탐색 성공 여부(`true`/`false`)
2. 탐색을 종료한 위치의 `Index`
3. 탐색을 종료한 위치의 `Node` (PairNode)

이렇게 3가지이다.

<br> 

해시 메소드를 통해 `Key`로부터 `Index`를 계산한다.

- `Bucket`의 해당 `Index` 위치가 `null`일 경우, 곧바로 종료하며<br>
  (`false`, `Index`, `null`)을 리턴한다.

<br>

해당 위치의 노드에서 `.next`를 통해 뒤로 순회하며 `Key`가 일치하는 노드를 찾는다.

- 일치하는 `Key`를 찾았을 경우, `Node`에 해당 노드를 넣은 뒤<br>
  (`true`, `Index`, `Node`)를 리턴한다.

- 일치하는 `Key`를 찾지 못했을 경우, `Node`에는 가장 끝에 연결된 노드를 넣고<br>
  (`false`, `Index`, `Node`)를 리턴한다.

</details>

<br> 


## **[6] Expand() : Bucket 확장 메소드**

<details>
<summary markdown="span"> 
.
</summary>

`Bucket` 내에 저장된 데이터가 많아질수록 해시를 통해 얻은 인덱스의 적중률이 점차 떨어지게 된다.

따라서 이는 성능 저하로 이어질 수 있으며, 적절한 타이밍에 `Bucket`을 확장해야 한다.

<br>

여기서는 `Count`가 `Capacity`의 절반 이상이 될 때마다 확장을 수행한다.

<br>

확장하는 방법은 다음과 같다.

새로운 `PairNode[]` 배열을 생성하고, `Capacity`에 해당 배열의 크기를 저장한다.

그리고 기존의 `Bucket`을 순차 탐색하며 `GetHashIndex()` 메소드를 통해

각각의 노드에 대한 인덱스를 새롭게 계산한 뒤,

새로운 `PairNode[]` 배열의 해당 인덱스에 넣어준다.

</details>

<br>


## **[7] Add() : 데이터 추가 메소드**

<details>
<summary markdown="span"> 
.
</summary>

매개변수로는 `Key`, `Value`를 받아 새로운 `PairNode`를 만들고,

이를 `Bucket` 내에 저장하는 메소드.

<br>

`Bucket`의 확장이 필요한지 여부를 우선 확인하여,

필요하다면 데이터를 추가하기 전에 확장한다.

그리고 `Search()` 메소드를 통해 동일한 `Key`의 존재 여부를 검사하고

저장할 `Index`와 `Node` 정보를 가져온다.

<br>

1. `Bucket`의 해당 `Index` 위치가 비어 있는 경우, 새로운 노드를 바로 넣어준다.

2. 일치하는 `Key`는 없지만 해당 위치가 비어 있지 않은 경우,<br>
   해당 `Index`의 노드 끝부분에 새로운 노드를 연결해준다.

3. 일치하는 `Key`가 이미 존재하는 경우에는 실패로 간주한다.

<br>

데이터 추가에 성공했을 때는 `Count`를 `1` 증가시키고 `true`를 리턴하며,

실패했을 때는 `false`를 리턴한다.

</details>

<br>


## **[8] Remove() : 데이터 제거 메소드**

<details>
<summary markdown="span"> 
.
</summary>

매개변수로는 `Key`를 전달받는다.

`Search()` 메소드를 통해 해당 `Key`가 존재하는지 여부를 검사하고

해당 위치의 `Index`를 가져온다.

<br>

`Key`가 존재하지 않을 경우 아무 것도 하지 않고 곧바로 `false`를 리턴한다.

<br>

`Key`가 존재하는 경우에는 해당 노드의 위치에 따라 분기를 나누어 수행해야 한다.

1. 연결된 노드들 중 가장 앞에 위치했을 경우,<br>
   뒤에 연결된 노드가 있다면 해당 노드의 `.prev`에 `null`을 초기화하고 맨 앞으로 당겨온다.

2. 중간에 위치한 경우, 자신의 앞과 뒤의 노드를 서로 연결시켜 준다.

3. 가장 마지막에 위치한 경우, 앞 노드의 `.next`에 `null`을 넣어준다.

제거에 성공한 경우 `Count`를 `1` 감소시킨 뒤 `true`를 리턴한다.

</details>


<br>

# Source Code
---

<details>
<summary markdown="span"> 
1. HashTable - Open Addressing
</summary>

```cs
#if DEBUG
#define DEBUG_ON
#endif

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rito
{
    // 인덱스 충돌 시 다음 인덱스로 건너가는 Open Addressing 방식
    class HashTable_01<TKey, TValue>
    {
        /***********************************************************************
        *                               Class Definition
        ***********************************************************************/
        #region .
        private readonly struct Pair
        {
            public readonly TKey key;
            public readonly TValue value;
            public readonly bool isDummy;

            public static readonly Pair Dummy = new Pair(true);
            public static readonly Pair Default = new Pair(false);

            public Pair(TKey key, TValue value)
            {
                this.key = key;
                this.value = value;
                this.isDummy = false;
            }

            private Pair(bool isDummy)
            {
                this.key = default;
                this.value = default;
                this.isDummy = isDummy;
            }

            public bool IsNull()
            {
                return this == Default;
            }

            public bool IsNullOrDummy()
            {
                return this == Default || this == Dummy;
            }

            public override bool Equals(object obj)
            {
                if (!(obj is Pair))
                    return false;

                return base.Equals(obj);
            }

            public override int GetHashCode()
            {
                return base.GetHashCode();
            }

            public static bool operator ==(Pair a, Pair b)
            {
                return a.Equals(b);
            }
            public static bool operator !=(Pair a, Pair b)
            {
                return !a.Equals(b);
            }

            public override string ToString()
            {
                return $"({key}, {value})";
            }
        }

        #endregion
        /***********************************************************************
        *                               Fields, Properties
        ***********************************************************************/
        #region .
        private Pair[] _bucket;

        private int _capacity;
        private int _count;
        private int _dummyCount;

        /// <summary> 해시 결과에 곱해줄 임의 값 </summary>
        private const int HashSeed = 4327;

        public int Count => _count;

        #endregion
        /***********************************************************************
        *                               Constructor, Indexer
        ***********************************************************************/
        #region .
        public HashTable_01(int capacity)
        {
            if (capacity < 4)
                capacity = 4;

            this._capacity = capacity;
            _count = 0;
            _dummyCount = 0;

            _bucket = new Pair[capacity];
            FillBucketDefault(_bucket);
        }
        public HashTable_01() : this(4) { }

        // Indexer
        public TValue this[TKey key]
        {
            get
            {
                bool found = Search(key, out _, out TValue value);

                if (found) return value;
#if DEBUG_ON
                Console.WriteLine($"Getter - 지정한 키가 존재하지 않습니다 : {key}");
#endif
                //throw new KeyNotFoundException($"지정한 키가 존재하지 않습니다 : {key}");
                return default;
            }
            set
            {
#if DEBUG_ON
                bool found = Search(key, out int index, out TValue oldValue);
#else
                bool found = Search(key, out int index, out _);
#endif

                // 기존에 동일 키가 존재한 경우, 존재하지 않은 경우 모두 친절하게 값 넣어주기
                _bucket[index] = new Pair(key, value);
#if DEBUG_ON
                if (found)
                {
                    Console.WriteLine($"Setter - Set into [{index}] - Key : ({key}), Value Changed : ({oldValue} -> {value})");
                }
                else
                {
                    Console.WriteLine($"Setter - Set into [{index}] - New Pair : ({key}, {value})");
                }
                Console.WriteLine($"Current Count : {_count}\n");
#endif
            }
        }
        #endregion
        /***********************************************************************
        *                               Private Methods - Options
        ***********************************************************************/
        #region .

        /// <summary>
        /// 키값으로부터 해시 값 계산하기
        /// </summary>
        /// <param name="key"></param>
        /// <returns>해시로부터 계산된 인덱스</returns>
        private int GetHashIndex(TKey key)
        {
            int index = ((key.GetHashCode() + HashSeed) * HashSeed) % _capacity;

            // 음수 대처
            if (index < 0)
                index += _capacity;
#if DEBUG_ON
            Console.WriteLine($"Hash Call - Key : {key}, Index : {index}");
#endif

            return index;
        }

        /// <summary> 인덱스 중복이 발생할 경우 다음 인덱스 계산 </summary>
        private int GetNextIndex(int index)
        {
            int nextIndex = (index + 1) % _capacity;
            return nextIndex;
        }

        /// <summary> 확장을 해야 하는지 여부 결정 </summary>
        private bool IsExpansionRequired()
        {
            // 저장된 개수가 배열 크기의 절반 이상인 경우 확장
            if (_dummyCount + _count >= _capacity / 2)
                return true;

            return false;
        }

        /// <summary> Bucket 확장하기 </summary>
        private void ExpandBucket()
        {
            ExpandInternal(this._capacity * 2);
        }

        #endregion
        /***********************************************************************
        *                               Private Methods
        ***********************************************************************/
        #region .

        private void FillBucketDefault(Pair[] bucket)
        {
            for (int i = 0; i < bucket.Length; i++)
                bucket[i] = Pair.Default;
        }

        /// <summary>
        /// 키를 이용해 페어 참조하기<para/>
        /// 키가 이미 존재하는 경우, 해당 인덱스 리턴<para/>
        /// 키가 존재하지 않았던 경우, 새롭게 찾은 빈 인덱스 리턴
        /// </summary>
        /// <param name="key"></param>
        /// <param name="index"></param>
        /// <param name="value"></param>
        /// <returns>
        /// 값을 찾는 데 성공한 경우 <see langword="true"/>,<para/>
        /// 실패한 경우 <see langword="false"/> 리턴
        /// </returns>
        private bool Search(TKey key, out int index, out TValue value)
        {
            index = GetHashIndex(key);
            value = default;
#if DEBUG_ON
            Console.WriteLine($"Search - Key : {key}, Hash Index : {index}");

            int loopCount = 0;
#endif
            while (true)
            {
#if DEBUG_ON
                if (++loopCount > _capacity * 10)
                    throw new Exception($"Infinite Loop {loopCount}");

                if(loopCount > 1)
                    Console.WriteLine($"Search Next Index : {index}");
#endif
                // 1. 해당 키로 저장된 데이터가 없는 경우
                if (_bucket[index].IsNull())
                {
                    value = default;
                    return false;
                }
                // 2. 더미의 온기가 남아있는 경우 : 다음 인덱스로 넘어가기
                else if (_bucket[index].isDummy)
                {
                    // Do Nothing
                    // 키가 기본 값인 경우, 더미와 동일한 키를 가지므로
                    // 반드시 더미 검사를 키 일치 검사보다 우선 수행해야 함
                }
                // 3. 탐색 성공 : 키가 일치하는 경우
                else if (key.Equals(_bucket[index].key))
                {
                    value = _bucket[index].value;
                    return true;
                }
                // 4. 해당 인덱스에 다른 키가 존재하는 경우 :다음 인덱스로 넘어가기

                // Next Index
                index = GetNextIndex(index);
            }
        }

        /// <summary>
        /// key를 이용하여 bucket 내의 다음 빈공간 인덱스 구하기
        /// </summary>
        /// <param name="key"></param>
        /// <returns>이미 키가 존재할 경우, -1 리턴</returns>
        private int FindEmptyBucketSpace(TKey key)
        {
            if (Search(key, out int index, out _))
            {
                return -1;
            }

            return index;
        }

        /// <summary> 내부 배열들을 새로운 크기로 확장하기 </summary>
        private void ExpandInternal(int nextCapacity)
        {
            if (this._capacity >= nextCapacity)
#if DEBUG_ON
                throw new ArgumentException($"{nameof(nextCapacity)}는 {nameof(_capacity)}보다 커야 합니다.");
#else
                return;
#endif

#if DEBUG_ON
            Console.WriteLine("\n===================================================");
            Console.WriteLine($"★ Expand Bucket : {_capacity} -> {nextCapacity}");
            Console.WriteLine("===================================================");
#endif
            Pair[] prevBucket = _bucket;
            _bucket = new Pair[nextCapacity];
            FillBucketDefault(_bucket);

            // 해시 재계산
            _capacity = nextCapacity; // 해시 계산이 capacity 영향을 받으므로, capacity 우선 확장
            ReconstructBucket(prevBucket);
        }

        /// <summary>
        /// 해시 계산해서 bucket에 알맞은 인덱스 찾아 value 저장하기
        /// </summary>
        /// <param name="pair"></param>
        /// <returns>
        /// 저장에 성공 시 <see langword="true"/>,<para/>
        /// 이미 해당 key가 존재할 경우  <see langword="false"/>
        /// </returns>
        private bool SavePair(in Pair pair)
        {
            if (_count >= _capacity)
                return false;

            int index = FindEmptyBucketSpace(pair.key);
            if (index == -1)
                return false;

            _bucket[index] = pair;

#if DEBUG_ON
            if (index != -1)
            {
                Console.WriteLine($"Pair Saved in [{index}] : {pair}\n");
            }
            else
            {
                Console.WriteLine($"Save Failed : {pair}\n");
            }
#endif

            return true;
        }

        /// <summary> 내부 해시 전부 재계산해서 bucket 배열 재구축하기 </summary>
        private void ReconstructBucket(Pair[] sourceBucket)
        {
            for (int i = 0; i < sourceBucket.Length; i++)
            {
                if (sourceBucket[i].IsNullOrDummy()) continue;

                SavePair(sourceBucket[i]);
            }

            // 더미는 모두 제거됨
            _dummyCount = 0;
        }

        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .
        /// <summary>
        /// 새로운 key-value 쌍 추가하기
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <returns>
        /// 값을 추가하는데 성공한 경우 <see langword="true"/><para/>
        /// 이미 동일 키가 존재하는 경우 <see langword="false"/>
        /// </returns>
        public bool Add(TKey key, TValue value)
        {
            // 1. 확장을 해야 하는 경우, 확장
            if (IsExpansionRequired())
                ExpandBucket();

            // 2. Bucket의 적절한 위치 찾아 저장
            bool suceeded = SavePair(new Pair(key, value));

            // 3. 개수 증가
            if (suceeded) _count++;

#if DEBUG_ON
            if (suceeded)
            {
                Console.WriteLine($"Add Suceeded : ({key}, {value})");
            }
            else
            {
                Console.WriteLine($"Add Failed : ({key}, {value})");
            }
            Console.WriteLine($"Current Count : {_count}\n");
#endif

            return suceeded;
        }

        /// <summary>
        /// 기존에 존재하는 key-value 쌍 제거하기
        /// </summary>
        /// <param name="key"></param>
        /// <returns>
        /// 값을 제거하는데 성공한 경우 <see langword="true"/><para/>
        /// 해당 키가 존재하지 않는 경우 <see langword="false"/>
        /// </returns>
        public bool Remove(TKey key)
        {
            bool found = Search(key, out int index,
#if DEBUG_ON
                out TValue value
#else
                out _
#endif
            );

            if (found)
            {
                // 1. 대상 값을 찾으면 해당 공간에 더미 넣어주기
                _bucket[index] = Pair.Dummy;

                // 2. 개수 감소
                _count--;

                // 3. 더미 개수 증가
                _dummyCount++;
            }

#if DEBUG_ON
            if (found)
            {
                Console.WriteLine($"Remove Completed From [{index}] : ({key}, {value})");
            }
            else
            {
                Console.WriteLine($"Remove Failed - Key : {key}");
            }
            Console.WriteLine($"Current Count : {_count}\n");
#endif

            return found;
        }

        /// <summary>
        /// 해당 키가 존재하는지 검사하기
        /// </summary>
        /// <param name="key"></param>
        /// <returns>
        /// 키가 존재하는 경우 <see langword="true"/><para/>
        /// 키가 존재하지 않는 경우 <see langword="false"/>
        /// </returns>
        public bool ContainsKey(TKey key)
        {
            bool found = Search(key, out _, out _);
            return found;
        }

        /// <summary>
        /// 해당 값이 존재하는지 검사하기
        /// </summary>
        /// <param name="value"></param>
        /// <returns>
        /// 값이 존재하는 경우 <see langword="true"/><para/>
        /// 값이 존재하지 않는 경우 <see langword="false"/>
        /// </returns>
        public bool ContainsValue(TValue value)
        {
            Pair foundPair = Array.Find(_bucket, pair =>
            {
                return !pair.IsNullOrDummy() && pair.value.Equals(value);
            });
            return foundPair != default;
        }

        /// <summary> 버킷 전체 출력 </summary>
        //[System.Diagnostics.Conditional("DEBUG_ON")]
        public void PrintAll(bool showNull = false, bool showDummy = false)
        {
            Console.WriteLine("===================== Bucket =====================");
            Console.WriteLine($"== Count : {_count}, Dummy : {_dummyCount}, Capacity : {_capacity}");
            Console.WriteLine("==================================================");
            for (int i = 0; i < _capacity; i++)
            {
                string str;
                if (_bucket[i] == default)
                {
                    if (!showNull) continue;
                    str = "Null";
                }
                else if (_bucket[i] == Pair.Dummy)
                {
                    if (!showDummy) continue;
                    str = "Dummy";
                }
                else
                    str = _bucket[i].ToString();

                Console.WriteLine($"[{i}] {str}");
            }
            Console.WriteLine("==================================================\n");
        }
        #endregion
    }
}
```

</details>

<br>

<details>
<summary markdown="span"> 
2. HashTable - Separate Chaining
</summary>

```cs
#if DEBUG
#define DEBUG_ON
#endif

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rito
{
    // 인덱스 충돌 시 링크를 이어나가는 Separate Chaining 방식
    class HashTable_02<TKey, TValue>
    {
        /***********************************************************************
        *                               Class Definition
        ***********************************************************************/
        #region .
        private class PairNode
        {
            public TKey key;
            public TValue value;

            public PairNode prev;
            public PairNode next;

            // 가장 앞에서부터 몇 번째 노드인지
            public int depth;

            public bool IsHead => prev == null;
            public bool IsTail => next == null;
            public bool HasPrev => prev != null;
            public bool HasNext => next != null;

            public PairNode(TKey key, TValue value)
            {
                this.key = key;
                this.value = value;
                this.prev = null;
                this.next = null;

                this.depth = 1;
            }

            /// <summary> next에 새로운 노드 연결 </summary>
            public void Connect(PairNode nextNode)
            {
                this.next = nextNode;
                nextNode.prev = this;

                nextNode.depth = this.depth + 1;
            }

            /// <summary> 가장 마지막 노드 참조 </summary>
            public PairNode FindTail()
            {
                PairNode current = this;
                while (current.next != null)
                {
                    current = current.next;
                }
                return current;
            }

            /// <summary> 가장 마지막 노드에 새로운 노드 추가 </summary>
            public void AddToTail(PairNode newNode)
            {
                FindTail().Connect(newNode);
            }

            /// <summary> 노드를 꼬리까지 순회하며 키가 일치하는 노드 찾아 리턴하기 </summary>
            public PairNode FindMatch(TKey key)
            {
                PairNode current = this;
                while (current != null)
                {
                    // 키가 일치하는 노드 찾은 경우 리턴
                    if (key.Equals(current.key))
                        return current;

                    current = current.next;
                }

                return null;
            }

            /// <summary> 노드 제거하고 앞뒤를 서로 이어주기 </summary>
            public void RemoveConnections()
            {
                if (prev != null)
                {
                    prev.next = this.next == null ? null : this.next;
                    prev = null;
                }
                if (next != null)
                {
                    next.prev = this.prev == null ? null : this.prev;
                    next = null;
                }
            }

            public override string ToString()
            {
                return $"({key}, {value} /{depth})";
            }
        }
        #endregion
        /***********************************************************************
        *                               Fields
        ***********************************************************************/
        #region .
        private PairNode[] _bucket;
        private int _count;
        private int _capacity;

        private const int MinCapacity = 4;
        private const int HashSeed = 4327; // 임의의 해시 시드 값

        #endregion
        /***********************************************************************
        *                               Constructors, Indexer
        ***********************************************************************/
        #region .
        public HashTable_02(int capacity)
        {
            if (capacity < MinCapacity) capacity = MinCapacity;
            this._capacity = capacity;
            _count = 0;

            _bucket = new PairNode[capacity];
        }
        public HashTable_02() : this(MinCapacity) { }

        public TValue this[TKey key]
        {
            get
            {
                bool found = Search(key, out _, out PairNode target);
                if (found)
                {
#if DEBUG_ON
                    Console.WriteLine($"Indexer - Get : {target}\n");
#endif
                    return target.value;
                }
                else
                {
#if DEBUG_ON
                    Console.WriteLine($"Indexer - Get Failed : {key}\n");
                    return default;
#else
                    throw new KeyNotFoundException($"지정한 키가 존재하지 않습니다 : {key}");
#endif
                }
            }
            set
            {
                bool found = Search(key, out int index, out PairNode target);

                // 키가 일치하는 노드를 찾은 경우, 값 변경
                if (found)
                {
#if DEBUG_ON
                    Console.WriteLine($"Indexer - Set(Value Changed) : ({key}, {target.value} -> {value})");
                    Console.WriteLine($"Current Count : {_count}\n");
#endif
                    target.value = value;
                }
                // 못찾은 경우 새롭게 추가
                else
                {
#if DEBUG_ON
                    Console.WriteLine($"Indexer - Set : {target}");
                    Console.WriteLine($"Current Count : {_count}\n");
#endif
                    PairNode newNode = new PairNode(key, value);

                    if (_bucket[index] == null)
                        _bucket[index] = newNode;
                    else
                        _bucket[index].AddToTail(newNode);

                    _count++;
                }
            }
        }

        #endregion
        /***********************************************************************
        *                               Private Methods - Options
        ***********************************************************************/
        #region .
        /// <summary> Key로부터 인덱스 구하기 </summary>
        private int GetHashIndex(TKey key)
        {
            int index = ((key.GetHashCode() + HashSeed) * HashSeed) % _capacity;

            // 음수 대처
            if (index < 0)
                index += _capacity;
#if DEBUG_ON
            Console.WriteLine($"Hash Call - Key : {key}, Index : {index}");
#endif

            return index;
        }

        /// <summary> 확장이 필요한지 여부 </summary>
        private bool IsExpansionRequired()
        {
            // 현재 노드 개수가 전체 배열 크기의 절반 이상인 경우 확장
            return _count >= _capacity / 2;
        }

        /// <summary> 버킷 확장하기 </summary>
        private void ExpandBucket()
        {
            ExpandInternal(_capacity * 2);
        }

        #endregion
        /***********************************************************************
        *                               Private Methods
        ***********************************************************************/
        #region .

        /// <summary> 
        /// 해당 Key를 갖고 있는 노드 찾기
        /// <para/> - 성공 여부 리턴
        /// <para/> - targetOrTail : 매치 성공 시 해당 노드로 초기화
        /// <para/> - targetOrTail : 매치 실패 시 해당 인덱스의 꼬리로 초기화
        /// </summary>
        private bool Search(TKey key, out int index, out PairNode targetOrTail)
        {
            index = GetHashIndex(key);

            // 1. 해당 인덱스가 빈 공간인 경우
            if (_bucket[index] == null)
            {
                targetOrTail = null;
                return false;
            }
            else
            {
                PairNode current = _bucket[index].FindMatch(key);

                // 2. 매치되는 녀석을 찾음 -> targetOrTail = Target
                if (current != null)
                {
                    targetOrTail = current;
                    return true;
                }
                // 3. 매치되는 녀석이 없음 -> targetOrTail = Tail
                else
                {
                    targetOrTail = _bucket[index].FindTail();
                    return false;
                }
            }
        }

        /// <summary> 지정된 크기로 버킷 확장하기 </summary>
        private void ExpandInternal(int newCapacity)
        {
            if (newCapacity <= _capacity)
                throw new ArgumentException("ExpandBucket(int) : Capacity는 기존보다 크게 지정해야 합니다.");

#if DEBUG_ON
            Console.WriteLine("\n===================================================");
            Console.WriteLine($"★ Expand Bucket : {_capacity} -> {newCapacity}");
            Console.WriteLine("===================================================");
#endif
            this._capacity = newCapacity;
            this._count = 0;

            PairNode[] oldBucket = this._bucket;
            this._bucket = new PairNode[newCapacity];

            // 새로운 버킷에 노드들 이전시키기
            for (int i = 0; i < oldBucket.Length; i++)
            {
                if (oldBucket[i] != null)
                {
                    PairNode cur = oldBucket[i];
                    while (cur != null)
                    {
                        // Next 참조를 미리 캐싱
                        PairNode next = cur.next;

                        // 현재 노드의 연결을 모두 끊기
                        cur.RemoveConnections();

                        // 새로운 버킷에 삽입
                        InsertNode(cur);

                        // 다음 노드로 순회
                        cur = next;
                    }
                }
            }
        }

        /// <summary> 버킷에 새로운 노드 추가하기 </summary>
        private bool InsertNode(PairNode node)
        {
            bool found = Search(node.key, out int index, out PairNode targetOrTail);

            // 키가 일치하는 대상이 없는 경우
            if (!found)
            {
                // 1. 빈 공간 찾은 경우 : 바로 추가
                if (targetOrTail == null)
                {
                    _bucket[index] = node;
                }

                // 2. 인덱스에 이미 손님이 있음 : 꼬리에 추가
                else
                {
                    targetOrTail.Connect(node);
                }

                // 개수 하나 증가
                _count++;

#if DEBUG_ON
                Console.WriteLine($"Add : {node}");
                Console.WriteLine($"Count : {_count}\n");
#endif
                return true;
            }
            // 3. 이미 해당 키가 존재하는 경우 : 실패
            else
            {
#if DEBUG_ON
                Console.WriteLine($"Add Failed - Key : {node.key}");
                Console.WriteLine($"Count : {_count}\n");
#endif
                return false;
            }
        }

        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .
        /// <summary> 해당 키를 포함하고 있는지 여부 검사 </summary>
        public bool ContainsKey(TKey key)
        {
            return Search(key, out _, out _);
        }

        /// <summary> 
        /// 새로운 key-value 추가
        /// <para/> 저장에 성공한 경우 true 리턴
        /// <para/> 이미 키가 존재할 경우 false 리턴
        /// <para/> 확장이 필요한 경우를 검사하여 자동 확장
        /// </summary>
        public bool Add(TKey key, TValue value)
        {
            if (IsExpansionRequired())
                ExpandBucket();

            return InsertNode(new PairNode(key, value));
        }

        /// <summary> 
        /// 대상 key가 존재할 경우, 찾아서 key-value 제거
        /// <para/> 제거 성공 여부 리턴
        /// </summary>
        public bool Remove(TKey key)
        {
            bool found = Search(key, out int index, out PairNode target);
            if (found)
            {
                // 찾은 노드가 Head 노드일 경우
                if (target.IsHead)
                {
                    // Next가 존재하면 Next를 당겨오기
                    if (target.HasNext)
                    {
                        _bucket[index] = target.next;
                    }
                    // Next가 존재하지 않으면 해당 인덱스에 null로 초기화
                    else
                    {
                        _bucket[index] = null;
                    }
                }

                target.RemoveConnections();
                _count--;
#if DEBUG_ON
                Console.WriteLine($"Remove : {target}");
                Console.WriteLine($"Count : {_count}\n");
#endif
                return true;
            }
            else
            {
#if DEBUG_ON
                Console.WriteLine($"Remove Failed - Key : {key}");
                Console.WriteLine($"Count : {_count}\n");
#endif
                return false;
            }
        }

        /// <summary> 버킷 전체 출력 </summary>
        [System.Diagnostics.Conditional("DEBUG_ON")]
        public void PrintAll(bool showNull = false)
        {
            Console.WriteLine("===================== Bucket =====================");
            Console.WriteLine($"== Count : {_count}, Capacity : {_capacity}");
            Console.WriteLine("==================================================");
            for (int i = 0; i < _capacity; i++)
            {
                if (_bucket[i] == null)
                {
                    if(showNull)
                        Console.WriteLine($"[{i}] NULL\n");
                }
                else
                {
                    PairNode cur = _bucket[i];
                    Console.WriteLine($"[{i}] {cur}");
                    cur = cur.next;

                    while (cur != null)
                    {
                        Console.Write("└");
                        for (int d = 1; d < cur.depth; d++)
                            Console.Write("─");

                        Console.WriteLine($"  {cur}");
                        cur = cur.next;
                    }
                    Console.WriteLine();
                }
            }
            Console.WriteLine("==================================================\n");
        }

        #endregion
    }
}
```

</details>

<br>



# References
---
- <https://bcho.tistory.com/1072>
- <https://mangkyu.tistory.com/102>



