---
title: 유니티 에디터 - 키보드 이벤트 메모
author: Rito15
date: 2021-08-31 15:33:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

```cs
// 현재 누른 키 확인
bool spacePressed = Event.current.keyCode == KeyCode.Space;

// 다른 이벤트(마우스 이벤트 등)와 동시에 입력한 보조 키 확인
bool controlPressed = Event.current.modifiers == EventModifiers.Control;

// LCtrl + 마우스 좌클릭
bool ctrlAndLeftClick = 
    Event.current.modifiers == EventModifiers.Control &&
    Event.current.type == EventType.MouseDown && 
    Event.current.button == 0;
```

