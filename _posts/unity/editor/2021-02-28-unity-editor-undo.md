---
title: Undo
author: Rito15
date: 2021-02-28 01:52:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

```cs
/* 1. 다른 동작과 연계 */

// 이름 변경, 기타 등등 수행하기 직전에 호출
// 주의 : 게임오브젝트의 변경사항은 트랜스폼이 아니라 게임오브젝트를 넣어야 함
Undo.RecordObject(target, "Action");

// 오브젝트 생성 이후에 호출
Undo.RegisterCreatedObjectUndo(targetGameObject, "Create New");


/* 2. Undo를 통해 직접 수행 */

// 컴포넌트 추가
Undo.AddComponent<ComponentType>(targetGameObject);

// 오브젝트 파괴 및 Undo 등록
Undo.DestroyObjectImmediate(targetGameObject);

// 부모 변경 및 Undo 등록
Undo.SetTransformParent(targetTransform, parentTransform, "Change Parent");
```

- 필드의 값 변경, 리스트나 딕셔너리의 구성요소 변경 : `RecordeObject(컴포넌트, "")`


<br>

# References
---
- <https://docs.unity3d.com/ScriptReference/Undo.html>