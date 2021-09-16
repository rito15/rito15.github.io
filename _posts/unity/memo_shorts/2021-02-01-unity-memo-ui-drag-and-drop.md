---
title: 유니티 - UI 헤더 드래그 앤 드롭으로 옮기기
author: Rito15
date: 2021-02-01 03:00:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, ui, memo, drag, drop, shorts]
math: true
mermaid: true
---

## 기능
- UI의 헤더(윗부분)를 따로 구성했을 때, 헤더를 드래그 했을 때만 옮기기

## 사용법
- 헤더 UI는 UI의 자식으로 구성한다.
- PopupUIHeader 스크립트를 헤더 UI의 컴포넌트로 넣어준다.
- 이동 대상 UI를 인스펙터에서 `Target UI`에 넣는다. (지정하지 않는 경우, 부모로 자동 초기화)

```cs
using UnityEngine;
using UnityEngine.EventSystems;

/// <summary> 헤더 드래그 앤 드롭에 의한 UI 이동 </summary>
public class MovableUI : MonoBehaviour, IPointerDownHandler, IDragHandler
{
    [SerializeField]
    private Transform _targetTr; // 이동될 UI

    private Vector2 _startingPoint;
    private Vector2 _moveBegin;
    private Vector2 _moveOffset;

    private void Awake()
    {
        // 이동 대상 UI를 지정하지 않은 경우, 자동으로 부모로 초기화
        if (_targetTr == null)
            _targetTr = transform.parent;
    }

    // 드래그 시작 위치 지정
    void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
    {
        _startingPoint = _targetTr.position;
        _moveBegin = eventData.position;
    }

    // 드래그 : 마우스 커서 위치로 이동
    void IDragHandler.OnDrag(PointerEventData eventData)
    {
        _moveOffset = eventData.position - _moveBegin;
        _targetTr.position = _startingPoint + _moveOffset;
    }
}
```