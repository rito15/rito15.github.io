---
title: 게임 뷰를 강제로 업데이트하기
author: Rito15
date: 2021-06-30 21:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---
- 플레이 모드에 진입하지 않고 게임 뷰에서 쉐이더 애니메이션을 확인하고 싶을 때 사용한다.

- 아무 게임오브젝트나 붙잡고 `Dirty`로 만들어주면 게임 뷰가 업데이트 된다.

```cs
EditorUtility.SetDirty(GameObject.FindObjectOfType<Transform>());
```

<br>

- 다음과 같은 `Repaint` 메소드들은 통하지 않는다.

```cs
EditorWindow focused = EditorWindow.focusedWindow;
focused.Repaint();
UnityEditorInternal.InternalEditorUtility.RepaintAllViews();
SceneView.RepaintAll();
if (GUI.changed) EditorUtility.SetDirty(focused);
HandleUtility.Repaint(); // ERROR
```
