---
title: 유니티 - 팝업 UI 관리 시스템 구현하기
author: Rito15
date: 2021-01-31 20:23:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, ui, stack]
math: true
mermaid: true
---

# 게임의 UI
---
- 온라인 PC게임을 예로 들었을 때, 다양한 형태의 UI들이 존재한다.
- 화면 예시 : Smilegate RPG 'LostARK'

## 1. 전체화면 UI
  - 크기가 화면 전체에 해당하는 UI
  - 예 : 상점, 캐시 샵

![Screenshot_210131_210227](https://user-images.githubusercontent.com/42164422/106383242-395f6080-6408-11eb-9e7e-2667a6ef85bf.jpg)

## 2. 고정형 UI
  - 고정된 위치에 항상 존재하는 UI
  - 예 : 하단 바, 퀵슬롯, 미니맵, 채팅창

![image](https://user-images.githubusercontent.com/42164422/106383370-d28e7700-6408-11eb-8c0f-26fc538cbf64.png)

## 3. 추적형 UI
  - 게임 내 요소들(캐릭터, 몬스터, 건물 등)의 위치를 실시간으로 추적하여 따라다니는 UI
  - 예 : 체력 바, 이름, 말풍선

![image](https://user-images.githubusercontent.com/42164422/106383331-a246d880-6408-11eb-9c9b-919bbc8394da.png)

## 4. 안내형 UI
  - 화면 한켠에 잠시 나타났다가 사라지는 형태의 UI
  - 게임의 진행사항, 공지사항 등을 안내하는 용도로 주로 사용된다.

![image](https://user-images.githubusercontent.com/42164422/106383348-b8549900-6408-11eb-807f-8b02ad7d2d7e.png)

## 5. 팝업형 UI
  - 자유롭게 열고, 닫고, 움직일 수 있는 UI
  - 예 : 캐릭터 정보, 인벤토리, 스킬, 퀘스트 목록

![image](https://user-images.githubusercontent.com/42164422/106383290-77f51b00-6408-11eb-9040-c7905a2b7b66.png)

<br>

# 팝업형 UI
---
- 위에 소개한 UI들 중, 팝업형 UI를 관리하기 위한 방법으로 스택을 생각할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106383438-4c266500-6409-11eb-910a-0f920f463360.png)

![image](https://user-images.githubusercontent.com/42164422/106383444-56486380-6409-11eb-9b99-421a310ee6c0.png)

- 위의 경우들이라면 스택을 통해서 충분히 구현할 수 있으나, 아래와 같은 경우도 존재할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106383565-29488080-640a-11eb-8b6d-8fa9ffc20ca9.png)

- 스택의 중간이나 하단에 위치한 UI를 선택하여, 해당 UI가 스택의 상단에 올라오고 다른 UI보다 앞쪽으로 보이게 되는 경우

- 해당 UI의 단축키를 누르거나 닫기 버튼을 눌러 스택의 중간이나 하단에 위치한 UI를 스택에서 제거하고 닫는 경우

- 이렇게 되면 스택으로는 위의 동작들을 구현할 수 없다.

- 대체 방안으로 가변 배열(C#에서는 List)을 생각해볼 수 있으나, 중간에서 요소를 변경할 경우의 효율이 좋지 않다.

- 따라서 링크드리스트(Linked List)가 가장 적합하다고 생각하여, 링크드리스트를 통한 팝업형 UI 관리 시스템을 구현해보고자 한다.

<br>

# 구현
---
## 1. 팝업형 UI의 구성

![image](https://user-images.githubusercontent.com/42164422/106384032-56962e00-640c-11eb-9a30-75d20ab180dd.png)

- 팝업형 UI는 크게 3가지 요소로 구분될 수 있다.
  - 헤더 : 해당 UI의 타이틀을 작성하며, 드래그 앤 드롭을 통해 UI를 옮길 수 있다.
  - 닫기 버튼 : 누를 경우 해당 UI를 닫는다.
  - 내용 : 해당 UI를 구성하는 내용물이 위치한다.

<br>

## 2. UI 생성

![image](https://user-images.githubusercontent.com/42164422/106468186-f1f8d300-64e0-11eb-9ded-80bf40ab8c9a.png)

- 이렇게 하이어라키를 구성하고,

![2021_0131_Inventory](https://user-images.githubusercontent.com/42164422/106384941-e8a03580-6410-11eb-9e6f-16dcfb47651c.gif)

- 다양한 크기에 유연하게 대응할 수 있도록 피벗과 앵커를 지정한다.

<br>

## 3. Popup UI Header 스크립트 작성

- 팝업 UI의 헤더 부분을 드래그 앤 드롭으로 옮길 수 있도록 스크립트를 작성하고, Header Bar 게임오브젝트에 컴포넌트로 넣어준다.

```cs
using UnityEngine;
using UnityEngine.EventSystems;

public class PopupUIHeader : MonoBehaviour, IBeginDragHandler, IDragHandler
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

<br>

## 4. Popup UI 스크립트 작성

- 팝업 UI를 마우스로 클릭할 때 이벤트를 발생시킬 수 있도록 스크립트를 작성하고, Popup UI 게임오브젝트에 컴포넌트로 넣어준다.

```cs
using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class PopupUI : MonoBehaviour, IPointerDownHandler
{
    public Button _closeButton;
    public event Action OnFocus;

    void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
    {
        OnFocus();
    }
}
```

<br>

## 5. Popup UI Manager 스크립트 작성

- Popup UI Container 또는 빈 게임오브젝트에 컴포넌트로 넣어주며, 싱글톤으로 작성하는 것이 좋다.

- 링크드리스트를 통해 현재 활성화된 팝업들을 관리한다.
- 각 팝업이 열릴 때는 링크드리스트의 가장 앞에 삽입하며, 닫힐 때는 링크드리스트에서 제거한다.
- ESC 키를 누를 경우 링크드리스트의 첫 번째 팝업을 닫는다..
- 각 팝업에 지정된 단축키를 누를 경우 해당 팝업 열거나 닫는다.
- 각 팝업을 마우스로 클릭할 경우 링크드리스트의 가장 앞에 오도록 한다.
- 팝업의 상태가 변경될 때마다 전체 팝업들의 정렬 순서를 링크드리스트의 순서대로 변경시킨다.

```cs
using System.Collections.Generic;
using UnityEngine;

public class PopupUIManager : MonoBehaviour
{
    /***********************************************************************
    *                               Public Fields
    ***********************************************************************/
    public PopupUI _inventoryPopup;
    public PopupUI _skillPopup;
    public PopupUI _characterInfoPopup;

    [Space]
    public KeyCode _escapeKey    = KeyCode.Escape;
    public KeyCode _inventoryKey = KeyCode.I;
    public KeyCode _skillKey     = KeyCode.K;
    public KeyCode _charInfoKey  = KeyCode.C;

    /***********************************************************************
    *                               Private Fields
    ***********************************************************************/
    /// <summary> 실시간 팝업 관리 링크드 리스트 </summary>
    private LinkedList<PopupUI> _activePopupLList;

    /// <summary> 전체 팝업 목록 </summary>
    private List<PopupUI> _allPopupList;

    /***********************************************************************
    *                               Unity Callbacks
    ***********************************************************************/
    private void Awake()
    {
        _activePopupLList = new LinkedList<PopupUI>();
        Init();
        InitCloseAll();
    }

    private void Update()
    {
        // ESC 누를 경우 링크드리스트의 First 닫기
        if (Input.GetKeyDown(_escapeKey))
        {
            if (_activePopupLList.Count > 0)
            {
                ClosePopup(_activePopupLList.First.Value);
            }
        }

        // 단축키 조작
        ToggleKeyDownAction(_inventoryKey, _inventoryPopup);
        ToggleKeyDownAction(_skillKey,     _skillPopup);
        ToggleKeyDownAction(_charInfoKey,  _characterInfoPopup);
    }

    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    private void Init()
    {
        // 1. 리스트 초기화
        _allPopupList = new List<PopupUI>()
        {
            _inventoryPopup, _skillPopup, _characterInfoPopup
        };

        // 2. 모든 팝업에 이벤트 등록
        foreach (var popup in _allPopupList)
        {
            // 헤더 포커스 이벤트
            popup.OnFocus += () =>
            {
                _activePopupLList.Remove(popup);
                _activePopupLList.AddFirst(popup);
                RefreshAllPopupDepth();
            };

            // 닫기 버튼 이벤트
            popup._closeButton.onClick.AddListener(() => ClosePopup(popup));
        }
    }

    /// <summary> 시작 시 모든 팝업 닫기 </summary>
    private void InitCloseAll()
    {
        foreach (var popup in _allPopupList)
        {
            ClosePopup(popup);
        }
    }

    /// <summary> 단축키 입력에 따라 팝업 열거나 닫기 </summary>
    private void ToggleKeyDownAction(in KeyCode key, PopupUI popup)
    {
        if (Input.GetKeyDown(key))
            ToggleOpenClosePopup(popup);
    }

    /// <summary> 팝업의 상태(opened/closed)에 따라 열거나 닫기 </summary>
    private void ToggleOpenClosePopup(PopupUI popup)
    {
        if (!popup.gameObject.activeSelf) OpenPopup(popup);
        else ClosePopup(popup);
    }

    /// <summary> 팝업을 열고 링크드리스트의 상단에 추가 </summary>
    private void OpenPopup(PopupUI popup)
    {
        _activePopupLList.AddFirst(popup);
        popup.gameObject.SetActive(true);
        RefreshAllPopupDepth();
    }

    /// <summary> 팝업을 닫고 링크드리스트에서 제거 </summary>
    private void ClosePopup(PopupUI popup)
    {
        _activePopupLList.Remove(popup);
        popup.gameObject.SetActive(false);
        RefreshAllPopupDepth();
    }

    /// <summary> 링크드리스트 내 모든 팝업의 자식 순서 재배치 </summary>
    private void RefreshAllPopupDepth()
    {
        foreach (var popup in _activePopupLList)
        {
            popup.transform.SetAsFirstSibling();
        }
    }
}
```

<br>

# 구현 결과
---

![2021_0201_Popup_UI_1](https://user-images.githubusercontent.com/42164422/106473067-b234ea00-64e6-11eb-9c93-23b5c296734a.gif)

- 헤더 드래그 앤 드롭 이동
- 팝업 클릭하여 선택 시 최상단에 표시

![2021_0201_Popup_UI_2](https://user-images.githubusercontent.com/42164422/106473072-b4974400-64e6-11eb-9662-0df2140246d8.gif)

- ESC 키를 누를 경우 현재 선택된 팝업부터 닫기
- 각각의 팝업 단축키를 통해 팝업 열고 닫기

<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

<br>

# Download
---
- [Popup_UI_Management.zip](https://github.com/rito15/Images/files/5904613/Popup_UI_Management.zip)