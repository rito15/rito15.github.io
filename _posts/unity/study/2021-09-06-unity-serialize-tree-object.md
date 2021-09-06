---
title: Unity - 트리 구조 데이터 직렬화하기
author: Rito15
date: 2021-09-06 23:23:00 +09:00
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

위와 같이 자기 타입의 배열 또는 컬렉션을 필드로 갖는 구조를 트리 자료구조라고 한다.

자식 및 하위 노드들을 순회하기 위해 재귀적 호출을 많이 사용한다.

<br>

<!-- --------------------------------------------------------------------------- -->

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

직렬화 가능한 필드는 `SerializedProperty`로 직렬화되며 현재 상태를 저장하고,

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

이렇게 `[System.Serializable]` 애트리뷰트를 사용해야 직렬화 대상이 된다.

<br>

기본적으로 `public` 필드는 자동으로 직렬화되고,

`private`, `protected` 필드는 `[UnityEngine.SerializeField]` 애트리뷰트를 필드 위에 작성하면 직렬화 대상이 된다.

프로퍼티와 읽기 전용 필드, 상수 필드는 직렬화되지 않지만

자동 구현 프로퍼티의 경우 `[field: UnityEngine.SerializeField]`를 붙이면 직렬화된다.

<br>
<!-- --------------------------------------------------------------------------- -->

# 트리 구조의 재귀적 직렬화 문제
---

트리 구조는 자기 타입과 동일한 필드가 존재하기 때문에

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
<!-- --------------------------------------------------------------------------- -->

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
    
    public TreeNode(NodeData data)
    {
        this.children = new List<TreeNode>();
        this.data = data;
    }

    public TreeNode(string name)
    {
        this.children = new List<TreeNode>();
        this.data = new NodeData(name);
    }
    
    public void AddChild(TreeNode child)
    {
        children.Add(child);
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

직렬화 가능한 타입을 정의할 때 아주 간편하게 정의할 수 있다.

```cs
[System.Serializable]
public class SerializableTreeNode
{
    public NodeData data;
    public int childCount;

    public SerializableTreeNode(TreeNode node)
    {
        this.data = node.data;
        this.childCount = node.children.Count;
    }

    public TreeNode Deserialize()
    {
        return new TreeNode(data);
    }
}
```

`childCount` 필드는 역직렬화를 위해 필요하다.

<br>
<!-- --------------------------------------------------------------------------- -->

# 직렬화 및 역직렬화
---

## **직렬화된 데이터 리스트 컨테이너 정의**

`TreeNode`의 하위 트리를 모두 직렬화하여

`SerializableTreeNode[]` 또는 `List<SerializableTreeNode>` 타입으로 저장하고

여기에 대해 바로 직렬화/역직렬화 기능을 작성할 수도 있지만,

이렇게 되면 해당 기능들은 이를 관리하는 외부 클래스에 작성해야 한다.

따라서 재사용성을 위해 이를 감싸는 컨테이너 클래스를 정의한다.

```cs
[System.Serializable]
public class SerializedTree
{
    public List<SerializableTreeNode> nodeList;

    public SerializedTree()
    {
        nodeList = new List<SerializableTreeNode>();
    }
}
```

<br>

## **노드 순회 방식 결정**

직렬화 구현 시 노드를 모두 순회하여 리스트에 담고,

역직렬화 시 리스트로부터 트리를 재구성한다.

이 때 노드 순회 방식을 일치시켜줄 필요가 있으며,

![image](https://user-images.githubusercontent.com/42164422/132195808-13d0394f-a544-468e-b029-5218f101254f.png)

위와 같이 공통적으로 DFS(깊이 우선 탐색) 방식을 사용한다.

<br>

## **직렬화 메소드 작성**

```cs
/* SerializedTree class */

public void SerializeFromTree(TreeNode source)
{
    nodeList.Clear();
    Local_SerializeAll(source);

    // 재귀 : 지정한 노드와 그 하위 노드를 모두 직렬화
    void Local_SerializeAll(TreeNode current)
    {
        // 직렬화용 노드 생성, 리스트에 추가
        nodeList.Add(new SerializableTreeNode(current));

        // 자식 순회
        foreach (var child in current.children)
        {
            Local_SerializeAll(child);
        }
    }
}
```

`TreeNode` 루트 객체를 입력받아 해당 트리를 순회하여

노드를 모두 리스트에 직렬화하는 직렬화 메소드를 작성한다.

노드 하나를 직렬화하고 리스트에 추가하며, 자식이 존재할 경우 순회하는 재귀 메소드를

위와 같이 직렬화 메소드 내에 로컬 메소드로 정의한다.

<br>

## **역직렬화 메소드 작성**

```cs
/* SerializedTree class */

public TreeNode Deserialize()
{
    if (nodeList.Count == 0) return null;

    int index = 0;
    TreeNode root = Local_DeserializeAll();

    return root;

    // 재귀 : 루트로부터 모든 자식들 역직렬화 및 트리 생성
    TreeNode Local_DeserializeAll()
    {
        int currentIndex = index;
        TreeNode current = nodeList[currentIndex].Deserialize();

        index++;

        // 자식이 있을 경우, 자식을 역직렬화해서 자식목록에 추가
        // 그리고 다시 그 자식에서 재귀
        for (int i = 0; i < nodeList[currentIndex].childCount; i++)
        {
            current.AddChild(Local_DeserializeAll());
        }

        return current;
    }
}
```

역직렬화 시, 리스트의 `0`번 인덱스에 위치한 노드를 루트로 가정하고

직렬화 메소드와 마찬가지로 재귀를 위한 로컬 메소드를 정의한다.

로컬 메소드에서는 리스트의 현재 인덱스에 위치한 노드를 역직렬화하여 노드 객체를 생성하고,

`childCount`를 확인하여 자식 개수만큼 순회하며 해당 노드들을 자신의 자식으로 추가한다.

그리고 그 자식 노드에서 재귀를 이어나가며 인덱스를 증가시킨다.

<br>

## **새로운 생성자 작성**

이미 존재하는 트리로부터 곧바로 직렬화된 노드 배열을 생성할 수 있도록, 생성자를 작성한다.

```cs
/* SerializedTree class */

public SerializedTree(TreeNode rootNode) : this()
{
    SerializeFromTree(rootNode);
}
```

<br>

## **데이터 존재 확인 메소드 작성**

내부 리스트가 노드를 갖고 있는지 여부를 확인할 수 있는 간단한 메소드를 작성한다.

```cs
/* SerializedTree class */

public bool HasData()
{
    return nodeList.Count > 0;
}
```

<br>
<!-- --------------------------------------------------------------------------- -->

# 테스트
---

## **출력 메소드 작성**

테스트를 위해, 노드를 모두 순회하면서 내용을 출력하는 메소드를 작성한다.

```cs
public class TreeNode
{
    public NodeData data;
    public List<TreeNode> children;

    // 테스트용 출력 메소드(DFS)
    public void PrintNode()
    {
        Local_PrintNode(this);

        void Local_PrintNode(TreeNode node)
        {
            Debug.Log($"Data : {node.data.name}, ChildCount : {node.children.Count}");

            foreach (var child in node.children)
            {
                Local_PrintNode(child);
            }
        }
    }
}
```

<br>

## **샘플 데이터 생성**

![image](https://user-images.githubusercontent.com/42164422/132195808-13d0394f-a544-468e-b029-5218f101254f.png)

위 그림대로 테스트를 위한 샘플 데이터를 정의한다.

```cs
TreeNode[] nodes = new TreeNode[15];
for (int i = 0; i < nodes.Length; i++)
    nodes[i] = new TreeNode($"{i}");

nodes[0].AddChild(nodes[1]);
nodes[0].AddChild(nodes[5]);
nodes[0].AddChild(nodes[8]);
nodes[1].AddChild(nodes[2]);
nodes[1].AddChild(nodes[3]);
nodes[1].AddChild(nodes[4]);
nodes[5].AddChild(nodes[6]);
nodes[5].AddChild(nodes[7]);
nodes[8].AddChild(nodes[9]);
nodes[8].AddChild(nodes[13]);
nodes[9].AddChild(nodes[10]);
nodes[9].AddChild(nodes[12]);
nodes[10].AddChild(nodes[11]);
nodes[13].AddChild(nodes[14]);

TreeNode root = nodes[0];
```

<br>

## **직렬화 및 역직렬화 테스트**

위의 샘플 트리를 직렬화하여 저장하고, 직렬화된 데이터로부터 다시 역직렬화하여

원본과 정확히 일치하는지 확인한다.

```cs
// 1. 원본 트리 내용 출력
root.PrintNode();

// 2. 직렬화
SerializedTree sBucket = new SerializedTree(root);

// 3. 역직렬화
TreeNode restoredTreeRoot = sBucket.Deserialize();

// 4. 역직렬화된 트리 내용 출력
restoredTreeRoot.PrintNode();
```

테스트 결과, 원본 트리와 복원된 트리 모두 `0` ~ `15`까지의 내용이

순서대로 출력되는 것을 확인할 수 있다.

<br>
<!-- --------------------------------------------------------------------------- -->

# 최종 트리 클래스 작성
---

원본 트리와 직렬화된 트리를 한 번에 보관할 수 있는 클래스를 작성한다.

```cs
[System.Serializable]
public class Tree
{
    public TreeNode root;
    public SerializedTree serializedTree;

    public Tree()
    {
        this.serializedTree = new SerializedTree();
    }

    public Tree(TreeNode rootNode) : this()
    {
        this.root = rootNode;
    }

    /// <summary> 트리 복원 필요 여부 확인 </summary>
    public bool IsRestorationRequired()
    {
        return root == null && serializedTree.HasData();
    }

    /// <summary> 현재 트리의 노드들을 직렬 트리에 저장 </summary>
    public void Save()
    {
        if (root == null) return;
        serializedTree.SerializeFromTree(root);

        Debug.Log("Tree Saved");
    }

    /// <summary> 직렬 트리로부터 트리 복원 </summary>
    public void Restore()
    {
        if (!serializedTree.HasData()) return;
        this.root = serializedTree.Deserialize();

        Debug.Log("Tree Restored");
    }
}
```

<br>

## **고려사항**

플레이모드 진입 시, 직렬화 되지 못한 원본 트리는 `null`이 되므로

반드시 `Awake()` 메소드 내에서 복원해주어야 한다.

```cs
public Tree tree;

private void Awake()
{
    if (tree != null && tree.IsRestorationRequired())
        tree.Restore();
}
```

<br>
<!-- --------------------------------------------------------------------------- -->

# IMGUI 커스텀 에디터 작성
---

## **커스텀 에디터 작성 목적**

- 트리 필드를 접고 펼칠 수 있는 재귀적 구조로 인스펙터에 표시한다.

- 직렬화된 트리는 존재하지만 원본 트리가 값을 잃어버렸을 때(플레이모드 전환 등)<br>
  직렬화된 트리로부터 원본 트리를 자동으로 복원해준다.
  
<br>

## **NodeData 클래스 수정**

커스텀 에디터에서 `Foldout`으로 각 노드를 접고 펼칠 수 있도록,

`Foldout` 상태를 저장하기 위한 필드를 에디터 전용으로 정의한다.

```cs
[System.Serializable]
public class NodeData
{
    public string name;

#if UNITY_EDITOR
    public bool foldout;
#endif

    public NodeData(string name)
    {
        this.name = name;
    }
}
```

<br>

## **커스텀 에디터 작성**

```cs
#if UNITY_EDITOR
[CustomEditor(typeof(Test_TreeSerialization))]
private class CE : UnityEditor.Editor
{
    private Test_TreeSerialization m;

    private void OnEnable()
    {
        m = target as Test_TreeSerialization;
    }

    public override void OnInspectorGUI()
    {
        // 변경사항을 인식하고 저장하기 위해 Undo 등록
        Undo.RecordObject(m, nameof(Test_TreeSerialization));
        
        BuildTree(m.tree);
        DrawTree(m.tree);
    }

    /// <summary> 에디터 작업을 위해 원본 트리 복원 </summary>
    private void BuildTree(Tree tree)
    {
        if (tree == null) return;
        if (Event.current.type != EventType.Layout) return;

        if (tree.IsRestorationRequired())
        {
            tree.Restore();
        }
    }

    /// <summary> 재귀적 Foldout 형태로 트리 그려주기 </summary>
    private void DrawTree(Tree tree)
    {
        if (tree == null) return;
        if (tree.root == null) return;

        Local_DrawTreeNode(tree.root, 0);

        void Local_DrawTreeNode(TreeNode node, int depth)
        {
            EditorGUI.indentLevel = depth;
            node.data.foldout = EditorGUILayout.Foldout(node.data.foldout, node.data.name);

            if (node.data.foldout)
            {
                node.data.name = EditorGUILayout.TextField("Data", node.data.name);
                foreach (var child in node.children)
                {
                    Local_DrawTreeNode(child, depth + 1);
                }
            }
        }
    }
}
#endif
```

<br>

## **Future Works**

- 커스텀 에디터를 통해 트리의 노드를 원하는 위치에 추가하고 제거할 수 있는 기능 구현


<br>
<!-- --------------------------------------------------------------------------- -->

# 구현 결과
---

![image](https://user-images.githubusercontent.com/42164422/132232837-54cd32b5-f621-48e0-b0cf-5e16abc7cff0.png)

위와 같이 재귀적 `Foldout`을 통해 에디터에 표시되며,

플레이모드에 진입하거나 빠져나와도 직렬화된 트리로부터 변경사항이 복원되고 유지된다.

또한, 씬 파일을 확인해보면

```
  tree:
    serializedTree:
      nodeList:
      - data:
          name: 0
          foldout: 1
        childCount: 3
      - data:
          name: 1
          foldout: 0
        childCount: 3
      - data:
          name: 2
          foldout: 0
        childCount: 0

      ...
```

이렇게 정상적으로 저장되는 것을 확인할 수 있다.

<br>
<!-- --------------------------------------------------------------------------- -->

# 전체 소스 코드
---

<details>
<summary markdown="span"> 
...
</summary>

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

/// <summary> 
/// 트리 자료구조 직렬화 예제
/// </summary>
public class Test_TreeSerialization : MonoBehaviour
{
    public Tree tree;

    private void Awake()
    {
        if (tree != null && tree.IsRestorationRequired())
        {
            tree.Restore();
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
            MakeSampleTree();
    }

    private void MakeSampleTree()
    {
        Debug.Log("Sample Tree Generated");

        TreeNode[] nodes = new TreeNode[15];
        for (int i = 0; i < nodes.Length; i++)
            nodes[i] = new TreeNode($"{i}");

        nodes[0].AddChild(nodes[1]);
        nodes[0].AddChild(nodes[5]);
        nodes[0].AddChild(nodes[8]);
        nodes[1].AddChild(nodes[2]);
        nodes[1].AddChild(nodes[3]);
        nodes[1].AddChild(nodes[4]);
        nodes[5].AddChild(nodes[6]);
        nodes[5].AddChild(nodes[7]);
        nodes[8].AddChild(nodes[9]);
        nodes[8].AddChild(nodes[13]);
        nodes[9].AddChild(nodes[10]);
        nodes[9].AddChild(nodes[12]);
        nodes[10].AddChild(nodes[11]);
        nodes[13].AddChild(nodes[14]);

        tree = new Tree(nodes[0]);
        tree.Save();
    }

    /***********************************************************************
    *                           Tree Node Definition
    ***********************************************************************/
    #region .
    public class TreeNode
    {
        public NodeData data;
        public List<TreeNode> children;

        public TreeNode(NodeData data)
        {
            this.children = new List<TreeNode>();
            this.data = data;
        }

        public TreeNode(string name)
        {
            this.children = new List<TreeNode>();
            this.data = new NodeData(name);
        }

        public void AddChild(TreeNode child)
        {
            children.Add(child);
        }

        public void PrintNode()
        {
            int depth = 0;
            const int MAX_DEPTH = 100;

            Local_PrintNode(this);

            void Local_PrintNode(TreeNode node)
            {
                Debug.Log($"Data : {node.data.name}, ChildCount : {node.children.Count}");
                if (++depth > MAX_DEPTH) return;

                foreach (var child in node.children)
                {
                    Local_PrintNode(child);
                }
            }
        }
    }

    #endregion
    /***********************************************************************
    *                           Node Data Definition
    ***********************************************************************/
    #region .
    [System.Serializable]
    public class NodeData
    {
        public string name;

#if UNITY_EDITOR
        public bool foldout;
#endif

        public NodeData(string name)
        {
            this.name = name;
        }
    }

    #endregion
    /***********************************************************************
    *                           Serializable Tree Node Definition
    ***********************************************************************/
    #region .
    [System.Serializable]
    public class SerializableTreeNode
    {
        public NodeData data;
        public int childCount;

        public SerializableTreeNode(TreeNode node)
        {
            this.data = node.data;
            this.childCount = node.children.Count;
        }

        public TreeNode Deserialize()
        {
            return new TreeNode(data);
        }
    }

    [System.Serializable]
    public class SerializedTree
    {
        public List<SerializableTreeNode> nodeList;

        public SerializedTree()
        {
            nodeList = new List<SerializableTreeNode>();
        }

        public SerializedTree(TreeNode rootNode) : this()
        {
            SerializeFromTree(rootNode);
        }

        public bool HasData()
        {
            return nodeList.Count > 0;
        }

        public void SerializeFromTree(TreeNode source)
        {
            nodeList.Clear();
            Local_SerializeAll(source);

            // 재귀 : 지정한 노드와 그 하위 노드를 모두 직렬화
            void Local_SerializeAll(TreeNode current)
            {
                // 직렬화용 노드 생성, 리스트에 추가
                nodeList.Add(new SerializableTreeNode(current));

                // 자식 순회
                foreach (var child in current.children)
                {
                    Local_SerializeAll(child);
                }
            }
        }

        public TreeNode Deserialize()
        {
            if (nodeList.Count == 0) return null;

            int index = 0;
            TreeNode root = Local_DeserializeAll();

            return root;

            // 재귀 : 루트로부터 모든 자식들 역직렬화 및 트리 생성
            TreeNode Local_DeserializeAll()
            {
                //Debug.Log($"Deserialize : {index}");

                int currentIndex = index;
                TreeNode current = nodeList[currentIndex].Deserialize();

                index++;

                // 자식이 있을 경우, 자식을 역직렬화해서 자식목록에 추가
                // 그리고 다시 그 자식에서 재귀
                for (int i = 0; i < nodeList[currentIndex].childCount; i++)
                {
                    current.AddChild(Local_DeserializeAll());
                }

                return current;
            }
        }
    }

    #endregion
    /***********************************************************************
    *                           Tree Definition
    ***********************************************************************/
    #region .

    [System.Serializable]
    public class Tree
    {
        public TreeNode root;
        public SerializedTree serializedTree;

        public Tree()
        {
            this.serializedTree = new SerializedTree();
        }

        public Tree(TreeNode rootNode) : this()
        {
            this.root = rootNode;
        }

        /// <summary> 트리 복원 필요 여부 확인 </summary>
        public bool IsRestorationRequired()
        {
            return root == null && serializedTree.HasData();
        }

        /// <summary> 현재 트리의 노드들을 직렬 트리에 저장 </summary>
        public void Save()
        {
            if (root == null) return;
            serializedTree.SerializeFromTree(root);

            Debug.Log("Tree Saved");
        }

        /// <summary> 직렬 트리로부터 트리 복원 </summary>
        public void Restore()
        {
            if (!serializedTree.HasData()) return;
            this.root = serializedTree.Deserialize();

            Debug.Log("Tree Restored");
        }
    }

    #endregion
    /***********************************************************************
    *                           Custom Editor
    ***********************************************************************/
    #region .
#if UNITY_EDITOR
    [CustomEditor(typeof(Test_TreeSerialization))]
    private class CE : UnityEditor.Editor
    {
        private Test_TreeSerialization m;

        private void OnEnable()
        {
            m = target as Test_TreeSerialization;
        }

        public override void OnInspectorGUI()
        {
            if (GUILayout.Button("Reset Tree"))
            {
                m.tree.root = null;
                m.tree.serializedTree = null;
            }
            if (GUILayout.Button("Generate Sample Tree"))
            {
                GenerateSampleTree();
            }

            BuildTree(m.tree);
            DrawTree(m.tree);
        }

        private void GenerateSampleTree()
        {
            m.MakeSampleTree();
        }

        /// <summary> 에디터 작업을 위해 원본 트리 복원 </summary>
        private void BuildTree(Tree tree)
        {
            if (tree == null) return;
            if (Event.current.type != EventType.Layout) return;

            if (tree.IsRestorationRequired())
            {
                tree.Restore();
                Debug.Log($"Build Tree From Serialized Tree Bucket - {Event.current.type}");
            }
        }

        /// <summary> 재귀적 Foldout 형태로 트리 그려주기 </summary>
        private void DrawTree(Tree tree)
        {
            if (tree == null) return;
            if (tree.root == null) return;

            Local_DrawTreeNode(tree.root, 0);

            void Local_DrawTreeNode(TreeNode node, int depth)
            {
                EditorGUI.indentLevel = depth;
                node.data.foldout = EditorGUILayout.Foldout(node.data.foldout, node.data.name);

                if (node.data.foldout)
                {
                    node.data.name = EditorGUILayout.TextField("Data", node.data.name);
                    foreach (var child in node.children)
                    {
                        Local_DrawTreeNode(child, depth + 1);
                    }
                }
            }
        }
    }
#endif
    #endregion
}
```

</details>

<br>
<!-- --------------------------------------------------------------------------- -->

# References
---
- <https://docs.unity3d.com/kr/530/Manual/script-Serialization.html>

