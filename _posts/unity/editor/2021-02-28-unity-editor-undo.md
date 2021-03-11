---
title: 유니티 에디터 - Undo
author: Rito15
date: 2021-02-28 01:52:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

```cs
// 이름 변경, 기타 등등 수행하기 직전에 호출
// 주의 : 게임오브젝트의 변경사항은 트랜스폼이 아니라 게임오브젝트를 넣어야 함
Undo.RecordObject(target, "Action");

// 오브젝트 생성 이후에 호출
Undo.RegisterCreatedObjectUndo(target, "Create New");

// 오브젝트 파괴 및 Undo 등록
Undo.DestroyObjectImmediate(selected.gameObject);

// 부모 변경 및 Undo 등록
Undo.SetTransformParent(transform, parent, "Change Parent");
```

- 필드의 값 변경, 리스트나 딕셔너리의 구성요소 변경 : `RecordeObject(컴포넌트, "")`