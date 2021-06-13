---
title: 각종 윈도우 새로고침하기
author: Rito15
date: 2021-05-19 01:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

# 커스텀 에디터 - 인스펙터뷰
---

- `Editor.Repaint()`

```cs
// 해당 CustomEditor 내에서 호출
this.Repaint();
```

<br>

# 커스텀 에디터 윈도우
---

- `EditorWindow.Repaint()`

```cs
this.Repaint();
```

<br>

# 씬뷰
---

인스펙터의 변경사항이 씬뷰에 곧바로 적용되지 않고

씬뷰에 마우스를 올리거나 키보드 입력이 있어야 적용될 경우,

`SceneView.RepaintAll()`을 호출하면 된다.

<br>

커스텀 에디터에서 인스펙터와 씬뷰의 동기화가 필요한 경우

**OnInspectorGUI()** 내에서 호출하면 된다.

<br>


# 프로젝트뷰
---

프로젝트 내의 파일 변경사항이 생겨도

프로젝트뷰에 곧바로 적용되지 않을 수 있다.

이럴 때는 `AssetDatabase.Refresh()`를 호출하면 된다.




