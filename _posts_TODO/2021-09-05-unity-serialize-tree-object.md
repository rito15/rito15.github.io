---
title: Unity - 트리 구조 데이터 직렬화하기
author: Rito15
date: 2021-09-05 20:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 트리(Tree) 자료구조
---

```cs
class TreeNode
{
    public TreeNode[] children;
}
```

위와 같이 자기 타입의 배열을 필드로 갖는 구조를 트리 자료구조라고 한다.

자식 및 하위 노드들을 순회하기 위해 재귀적 호출을 많이 사용한다.

<br>
<!- --------------------------------------------------------------------------- ->

# 직렬화(Serialization)
---

데이터를 저장 또는 통신하기 위한 목적으로 변형하는 것을 의미한다.

직렬화 결과의 형태로는 대표적으로 `JSON`, `XML`, `byte[]`, `string` 등이 있다.

그리고 유니티 엔진에서는 `SerializedObject`가 있다.

단어 의미 그대로 직렬화된 오브젝트라는 뜻이다.

<br>

`MonoBahaviour` 내의 `public`, 혹은 직렬화 가능한 필드는

인스펙트에 그냥 그대로 보이는 것이 아니라,

`MonoBehaviour` 객체는 `SerializedObject`로 직렬화 되고

직렬화 가능한 필드는 `SerializedObject`의 프로퍼티에 현재 상태를 저장하고,

그 상태의 값이 인스펙터에 표시되는 것이다.

그리고 그 뿐만 아니라 직렬화된 값은 그대로 저장되어

유니티 에디터를 종료하고 다시 시작하거나 플레이모드에 진입, 해제해도

저장된 값이 그대로 유지된다.

<br>

만약 각각의 필드가 기본 타입이 아닌 클래스 혹은 구조체 타입이라면

해당 타입의 필드, 그리고 필드의 필드... 이렇게 재귀적으로 모두 확인하면서 직렬화된다.

사용자 정의 타입의 경우

```cs
[System.Serializable]
public class MyClass {}
```

이렇게 `[Serializable]` 애트리뷰트를 사용해야 직렬화 대상이 된다.

<br>

기본적으로 `public` 필드는 자동으로 직렬화되고,

프로퍼티와 읽기 전용 필드, 상수 필드는 직렬화되지 않는다.

`private`, `protected` 필드는 `[UnityEngine.SerializeField]` 애트리뷰트를 필드 위에 작성하면 직렬화 대상이 된다.

<br>
<!- --------------------------------------------------------------------------- ->

# 트리 구조의 재귀적 직렬화 문제
---

트리 구조는 자기 자신의 타입이 배열 형태의 필드로 존재하기 때문에

직렬화를 위해 필드를 확인하고, 다시 해당 필드 타입의 필드를 확인하고 ...

이렇게 재귀적으로 이어나갈 경우 무한히 재귀가 이어지게 된다.

따라서 트리 구조 그대로의 직렬화는 불가능하며,

```cs
[System.Serializable]
class TreeNode
{
    public TreeNode[] children;
}

public TreeNode treeRoot;
```

인스펙터에 표시하기 위해 위와 같이 작성하기만 해도

```
Serialization depth limit 10 exceeded at 'TreeNode.children'.
There may be an object composition cycle in one or more of your serialized classes.

Serialization hierarchy:
11: TreeNode.children
10: TreeNode.children
9: TreeNode.children
8: TreeNode.children
7: TreeNode.children
6: TreeNode.children
5: TreeNode.children
4: TreeNode.children
3: TreeNode.children
2: TreeNode.children
1: TreeNode.children
0: treeRoot
```

이런 경고를 확인할 수 있다.

각 노드마다 자식을 하나씩 생성해서 하이라키에서 확인해보면

![image](https://user-images.githubusercontent.com/42164422/132127025-a74b7f4c-8159-4191-8b70-8b009a3309aa.png)

이렇게 깊이 10까지만 나타나고, 그 이후로는 보이지 않는다.

만약 범용 트리 구조를 만들려고 한다면 절대 이대로는 사용할 수 없다.

<br>

# 직렬화 전용 타입 정의
---

위에서 살펴본 재귀적 직렬화 문제 때문에,

트리와 같은 재귀적 구조는 직렬화가 필요할 경우

직렬화를 위한 타입을 따로 정의해야 한다.

<br>

## **트리 노드 클래스 정의**

```cs
public class TreeNode
{
    public string name;
    public List<TreeNode> children;
}
```

위와 같이 각 노드마다 간단히 이름만 저장하는 트리 노드 클래스를 정의한다.

하지만 범용성을 위해, 여러 개의 필드가 있는 경우를 가정하여

내부 데이터를 하나의 데이터 클래스로 묶어준다.

```cs
public class TreeNode
{
    public NodeData data;
    public List<TreeNode> children;

    public TreeNode(string name)
    {
        this.children = new List<TreeNode>();
        this.data = new NodeData(name);
    }
}

[System.Serializable]
public class NodeData
{
    public string name;

    public NodeData(string name)
    {
        this.name = name;
    }
}
```

<br>

## **직렬화 가능한 타입 정의**

노드 내부의 데이터를 `NodeData`로 묶었기 때문에

직렬화 가능한 타입을 정의할 때, 아주 간편하게 정의할 수 있다.

```cs

```

<br>

<!- --------------------------------------------------------------------------- ->

# 개념
---
- 

<br>



<!- --------------------------------------------------------------------------- ->

# References
---
- <https://docs.unity3d.com/kr/530/Manual/script-Serialization.html>

