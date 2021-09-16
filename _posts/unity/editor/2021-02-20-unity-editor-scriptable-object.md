---
title: 유니티 - Scriptable Object
author: Rito15
date: 2021-02-20 02:02:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, scriptableobject]
math: true
mermaid: true
---

# 형태
---

```cs
[CreateAssetMenu(fileName = "TestSO", menuName = "ScriptableObjects/Test", order = 1)]
public class TestScriptableObject : ScriptableObject
{
    public int value = 0;
}
```

- 상단의 메뉴에서 [Assets] - [Create] - [ScriptableObjects] - [Test] 를 통해 생성 할 수 있게 된다.
- 프로젝트 윈도우에서 우클릭하면 동일한 메뉴를 확인할 수 있다.

<br>

# 특징
---

- 스크립터블 오브젝트를 참조하게 되면 동일한 값의 필드를 각각의 객체에서 중복된 형태로 사용하게 되는 것을 방지할 수 있다.
  - 예시 : 공통으로 사용할 메시지 스트링, 유닛의 최대 체력, 공통 텍스쳐 등  

- 에디터에서는 스크립터블 오브젝트의 값들을 자유롭게 수정할 수 있으며, 수정한 값이 항상 유지된다.

- 빌드 이후에도 값을 수정할 수 있지만, 게임 시작 시 항상 '빌드하는 순간에 저장된 값'으로 초기화된다.