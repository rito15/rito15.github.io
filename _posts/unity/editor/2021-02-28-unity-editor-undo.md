---
title: 유니티 - Undo
author: Rito15
date: 2021-02-28 01:52:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

# Note
---

- 필드의 값 변경, 리스트나 딕셔너리의 구성요소 변경 : `RecordeObject(컴포넌트, "")`

- 커스텀 에디터에서 대상의 필드를 Undo에 등록하려면, 반드시 해당 필드가 직렬화되어야 한다.

<br>

# Memo
---

## 1. 다른 동작에 Undo 등록

```cs
// 이름 변경, 기타 등등 수행하기 직전에 호출
// 주의 : 게임오브젝트의 변경사항은 트랜스폼이 아니라 게임오브젝트를 넣어야 함
Undo.RecordObject(target, "Action");

// 오브젝트 생성 직후에 호출
Undo.RegisterCreatedObjectUndo(targetGameObject, "Create New");
```

<br>

## 2. Undo를 통해 직접 기능 수행

```cs
// 컴포넌트 추가
Undo.AddComponent<ComponentType>(targetGameObject);

// 오브젝트 파괴 및 Undo 등록
Undo.DestroyObjectImmediate(targetGameObject);

// 부모 변경 및 Undo 등록
Undo.SetTransformParent(targetTransform, parentTransform, "Change Parent");
```

## 3. 커스텀 에디터에서 필드 Undo 등록

```cs
// 1. Record Undo
Undo.RecordObject(m, "Change Mesh Name");

// 2. Draw Field
m.meshName = EditorGUILayout.TextField("Mesh Name", m.meshName);
```

<br>

# References
---
- <https://docs.unity3d.com/ScriptReference/Undo.html>
- <https://m.blog.naver.com/hammerimpact/220775012493>
- <https://m.blog.naver.com/hammerimpact/220775389020>