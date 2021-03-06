---
title: UI 드래그 앤 드롭으로 옮기기
author: Rito15
date: 2021-02-01 03:00:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, ui, memo, drag, drop]
math: true
mermaid: true
---

## 기능
- UI의 헤더(윗부분)를 따로 구성했을 때, 헤더를 드래그 했을 때만 옮기기

## 사용법
- 헤더 UI는 UI의 자식으로 구성한다.
- PopupUIHeader 스크립트를 헤더 UI의 컴포넌트로 넣어준다.

```cs
/// <summary> 헤더 드래그 앤 드롭에 의한 UI 이동 구현 </summary>
public class PopupUIHeader : MonoBehaviour,
    IPointerDownHandler, IBeginDragHandler, IDragHandler
{
    private RectTransform _parentRect;

    private Vector2 _rectBegin;
    private Vector2 _moveBegin;
    private Vector2 _moveOffset;

    private void Awake()
    {
        _parentRect = transform.parent.GetComponent<RectTransform>();
    }

    void IBeginDragHandler.OnBeginDrag(PointerEventData eventData)
    {
        _rectBegin = _parentRect.anchoredPosition;
        _moveBegin = eventData.position;
    }

    void IDragHandler.OnDrag(PointerEventData eventData)
    {
        _moveOffset = eventData.position - _moveBegin;
        _parentRect.anchoredPosition = _rectBegin + _moveOffset;
    }
}
```