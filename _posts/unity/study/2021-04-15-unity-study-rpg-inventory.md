---
title: RPG Inventory System(RPG 게임 인벤토리 만들기)
author: Rito15
date: 2021-04-15 22:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 개요
---

- RPG 게임에서 사용할 수 있는 기본적인 인벤토리를 구현한다.

<br>

## **구현할 기능**
- 아이템 추가(습득)
- 아이템 제거(버리기)
- 아이템 사용
- 아이템 이동
- 슬롯 하이라이트
- 아이템 툴팁
- 아이템 버리기 팝업
- 아이템 개수 나누기 팝업
- 인벤토리 빈칸 채우기
- 인벤토리 정렬
- 아이템 필터링

<br>

# 클래스 구성
---

![image](https://user-images.githubusercontent.com/42164422/118279947-abb30700-b506-11eb-8223-62946273a547.png)

## **1. 인벤토리**
 - `Inventory` : 전체 아이템들을 관리하고, 인벤토리 내부의 실질적 동작들을 담당한다.


## **2. 아이템**
 - `Item` : 인벤토리의 각 슬롯에 들어가는 실제 아이템. 각각의 아이템이 개별적으로 갖는 데이터들을 보관한다.
   - `CountableItem` : 수량을 셀 수 있는 아이템
     - `PortionItem` : 소모 아이템(포션)
   - `EquipmentItem` : 장비 아이템
     - `WeaponItem` : 무기 아이템
     - `ArmorItem` : 방어구 아이템


## **3. 아이템 데이터**
 - `ItemData` : 각 아이템이 공통으로 가질 데이터들을 보관하는 클래스. 스크립터블 오브젝트를 상속한다.
   - `CountableItemData` : 수량을 셀 수 있는 아이템
     - `PortionItemData` : 소모 아이템(포션)
   - `EquipmentItemData` : 장비 아이템
     - `WeaponItemData` : 무기 아이템
     - `ArmorItemData` : 방어구 아이템


## **4. UI**
 - `InventoryUI` : 사용자의 UI 조작을 처리하고, Inventory와 상호작용한다.
 - `InventoryPopupUI` : 인벤토리에서 사용되는 확인/취소 창 등 작은 팝업 UI들을 담당한다.
 - `ItemSlotUI` : 인벤토리 내의 각 슬롯 UI
 - `ItemTooltipUI` : 아이템이 존재하는 슬롯에 마우스를 올렸을 때 등장하는 툴팁 UI
 - `MovableHeaderUI` : UI의 상단 헤더 부분의 드래그 앤 드롭 이동 기능을 담당한다.

<br>

# 인벤토리 GUI 제작
---

## **기본 구성**

![image](https://user-images.githubusercontent.com/42164422/115536648-fdd08600-a2d4-11eb-8272-3e7f0ecd5930.png)

![image](https://user-images.githubusercontent.com/42164422/115543343-3b84dd00-a2dc-11eb-85f4-415ab7bbb7fc.png)

Inventory 게임오브젝트에 `InventoryUI` 컴포넌트를 넣는다.

인벤토리 UI는 크게 세 부분으로 나눈다.

<br>

### **1. 헤더 영역**

드래그 앤 드롭으로 인벤토리를 옮길 수 있게 해주는 헤더 UI와 닫기 버튼이 위치한다.

그리고 Header Area 게임오브젝트에는 `MovableHeaderUI` 컴포넌트가 존재한다.


### **2. 버튼 영역**

정렬, 필터 등 다양한 기능 버튼들이 위치하게 된다.


### **3. 아이템 슬롯 영역**

인벤토리의 모든 아이템 슬롯들이 위치한다.

<br>

## **아이템 슬롯 UI 구성**

![image](https://user-images.githubusercontent.com/42164422/115550437-d1bd0100-a2e4-11eb-88f5-5df146ab3534.png)

아이템 슬롯 UI 프리팹은 위와 같이 구성된다.

가장 뒤쪽에 슬롯 이미지, 그리고 안쪽으로 아이콘 이미지가 위치하며

아이템 수량을 표시할 텍스트, 마우스를 슬롯 위에 올렸을 때 표시할 하이라이트 이미지가 존재한다.

하이라이트 이미지는 아이콘 이미지와 동일한 크기로, 반투명한 색상으로 설정하며 미리 비활성화 해둔다.

그리고 [Item Slot] 게임오브젝트에는 `ItemSlotUI` 컴포넌트를 넣어준다.

<br>

# InventoryUI 작성
---

`InventoryUI` 클래스는 인벤토리 UI의 모든 사용자 상호작용과 그래픽 레이캐스트를 담당한다.

그리고 아이템 슬롯 UI들을 리스트로 전부 관리한다.

<br>

## **아이템 슬롯 동적 생성**

환경에 따라 아이템 슬롯의 개수는 8x8일 수도, 6x2일 수도 있고 다양하게 바뀔 수 있다.

그리고 각 슬롯의 크기도 마찬가지로 변할 수 있다.

따라서 아이템 슬롯을 개수만큼, 크기만큼 미리 만들어 놓으면 변화에 대응하기 힘들기 때문에

하나의 슬롯을 동적으로 복제하는 방식으로 작성하였다.

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
[Header("Options")]
[Range(0, 10)]
[SerializeField] private int _horizontalSlotCount = 8;  // 슬롯 가로 개수
[Range(0, 10)]
[SerializeField] private int _verticalSlotCount = 8;      // 슬롯 세로 개수
[SerializeField] private float _slotMargin = 8f;          // 한 슬롯의 상하좌우 여백
[SerializeField] private float _contentAreaPadding = 20f; // 인벤토리 영역의 내부 여백
[Range(32, 64)]
[SerializeField] private float _slotSize = 64f;      // 각 슬롯의 크기

[Header("Connected Objects")]
[SerializeField] private RectTransform _contentAreaRT; // 슬롯들이 위치할 영역
[SerializeField] private GameObject _slotUiPrefab;     // 슬롯의 원본 프리팹

/// <summary> 지정된 개수만큼 슬롯 영역 내에 슬롯들 동적 생성 </summary>
private void InitSlots()
{
    // 슬롯 프리팹 설정
    _slotUiPrefab.TryGetComponent(out RectTransform slotRect);
    slotRect.sizeDelta = new Vector2(_slotSize, _slotSize);

    _slotUiPrefab.TryGetComponent(out ItemSlotUI itemSlot);
    if (itemSlot == null)
        _slotUiPrefab.AddComponent<ItemSlotUI>();

    _slotUiPrefab.SetActive(false);

    // --
    Vector2 beginPos = new Vector2(_contentAreaPadding, -_contentAreaPadding);
    Vector2 curPos = beginPos;

    _slotUIList = new List<ItemSlotUI>(_verticalSlotCount * _horizontalSlotCount);

    // 슬롯들 동적 생성
    for (int j = 0; j < _verticalSlotCount; j++)
    {
        for (int i = 0; i < _horizontalSlotCount; i++)
        {
            int slotIndex = (_horizontalSlotCount * j) + i;

            var slotRT = CloneSlot();
            slotRT.pivot = new Vector2(0f, 1f); // Left Top
            slotRT.anchoredPosition = curPos;
            slotRT.gameObject.SetActive(true);
            slotRT.gameObject.name = $"Item Slot [{slotIndex}]";

            var slotUI = slotRT.GetComponent<ItemSlotUI>();
            slotUI.SetSlotIndex(slotIndex);
            _slotUIList.Add(slotUI);

            // Next X
            curPos.x += (_slotMargin + _slotSize);
        }

        // Next Line
        curPos.x = beginPos.x;
        curPos.y -= (_slotMargin + _slotSize);
    }

    // 슬롯 프리팹 - 프리팹이 아닌 경우 파괴
    if(_slotUiPrefab.scene.rootCount != 0)
        Destroy(_slotUiPrefab);

    // -- Local Method --
    RectTransform CloneSlot()
    {
        GameObject slotGo = Instantiate(_slotUiPrefab);
        RectTransform rt = slotGo.GetComponent<RectTransform>();
        rt.SetParent(_contentAreaRT);

        return rt;
    }
}
```

</details>

<br>

## **슬롯 생성 미리보기**

슬롯을 동적으로 생성하는 것은 좋지만, 슬롯들이 생성됐을 때의 모습을 미리 확인할 수 없다는 단점이 있다.

따라서 에디터 내에서는 슬롯들이 생성될 위치를 미리 확인할 수 있도록 미리보기 기능을 작성하였다.

![2021_0421_InventoryUI Preview](https://user-images.githubusercontent.com/42164422/115549467-a7b70f00-a2e3-11eb-84d6-58c22fac5c59.gif)

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
#if UNITY_EDITOR
[SerializeField] private bool __showPreview = false;

[Range(0.01f, 1f)]
[SerializeField] private float __previewAlpha = 0.1f;

private List<GameObject> __previewSlotGoList = new List<GameObject>();
private int __prevSlotCountPerLine;
private int __prevSlotLineCount;
private float __prevSlotSize;
private float __prevSlotMargin;
private float __prevContentPadding;
private float __prevAlpha;
private bool __prevShow = false;
private bool __prevMouseReversed = false;

private void OnValidate()
{
    if (__prevMouseReversed != _mouseReversed)
    {
        __prevMouseReversed = _mouseReversed;
        InvertMouse(_mouseReversed);

        EditorLog($"Mouse Reversed : {_mouseReversed}");
    }

    if (Application.isPlaying) return;

    if (__showPreview && !__prevShow)
    {
        CreateSlots();
    }
    __prevShow = __showPreview;

    if (Unavailable())
    {
        ClearAll();
        return;
    }
    if (CountChanged())
    {
        ClearAll();
        CreateSlots();
        __prevSlotCountPerLine = _horizontalSlotCount;
        __prevSlotLineCount = _verticalSlotCount;
    }
    if (ValueChanged())
    {
        DrawGrid();
        __prevSlotSize = _slotSize;
        __prevSlotMargin = _slotMargin;
        __prevContentPadding = _contentAreaPadding;
    }
    if (AlphaChanged())
    {
        SetImageAlpha();
        __prevAlpha = __previewAlpha;
    }

    bool Unavailable()
    {
        return !__showPreview ||
                _horizontalSlotCount < 1 ||
                _verticalSlotCount < 1 ||
                _slotSize <= 0f ||
                _contentAreaRT == null ||
                _slotUiPrefab == null;
    }
    bool CountChanged()
    {
        return _horizontalSlotCount != __prevSlotCountPerLine ||
                _verticalSlotCount != __prevSlotLineCount;
    }
    bool ValueChanged()
    {
        return _slotSize != __prevSlotSize ||
                _slotMargin != __prevSlotMargin ||
                _contentAreaPadding != __prevContentPadding;
    }
    bool AlphaChanged()
    {
        return __previewAlpha != __prevAlpha;
    }
    void ClearAll()
    {
        foreach (var go in __previewSlotGoList)
        {
            Destroyer.Destroy(go);
        }
        __previewSlotGoList.Clear();
    }
    void CreateSlots()
    {
        int count = _horizontalSlotCount * _verticalSlotCount;
        __previewSlotGoList.Capacity = count;

        // 슬롯의 피벗은 Left Top으로 고정
        RectTransform slotPrefabRT = _slotUiPrefab.GetComponent<RectTransform>();
        slotPrefabRT.pivot = new Vector2(0f, 1f);

        for (int i = 0; i < count; i++)
        {
            GameObject slotGo = Instantiate(_slotUiPrefab);
            slotGo.transform.SetParent(_contentAreaRT.transform);
            slotGo.SetActive(true);
            slotGo.AddComponent<PreviewItemSlot>();

            slotGo.transform.localScale = Vector3.one; // 버그 해결

            HideGameObject(slotGo);

            __previewSlotGoList.Add(slotGo);
        }

        DrawGrid();
        SetImageAlpha();
    }
    void DrawGrid()
    {
        Vector2 beginPos = new Vector2(_contentAreaPadding, -_contentAreaPadding);
        Vector2 curPos = beginPos;

        // Draw Slots
        int index = 0;
        for (int j = 0; j < _verticalSlotCount; j++)
        {
            for (int i = 0; i < _horizontalSlotCount; i++)
            {
                GameObject slotGo = __previewSlotGoList[index++];
                RectTransform slotRT = slotGo.GetComponent<RectTransform>();

                slotRT.anchoredPosition = curPos;
                slotRT.sizeDelta = new Vector2(_slotSize, _slotSize);
                __previewSlotGoList.Add(slotGo);

                // Next X
                curPos.x += (_slotMargin + _slotSize);
            }

            // Next Line
            curPos.x = beginPos.x;
            curPos.y -= (_slotMargin + _slotSize);
        }
    }
    void HideGameObject(GameObject go)
    {
        go.hideFlags = HideFlags.HideAndDontSave;

        Transform tr = go.transform;
        for (int i = 0; i < tr.childCount; i++)
        {
            tr.GetChild(i).gameObject.hideFlags = HideFlags.HideAndDontSave;
        }
    }
    void SetImageAlpha()
    {
        foreach (var go in __previewSlotGoList)
        {
            var images = go.GetComponentsInChildren<Image>();
            foreach (var img in images)
            {
                img.color = new Color(img.color.r, img.color.g, img.color.b, __previewAlpha);
                var outline = img.GetComponent<Outline>();
                if (outline)
                    outline.effectColor = new Color(outline.effectColor.r, outline.effectColor.g, outline.effectColor.b, __previewAlpha);
            }
        }
    }
}

private class PreviewItemSlot : MonoBehaviour { }

[UnityEditor.InitializeOnLoad]
private static class Destroyer
{
    private static Queue<GameObject> targetQueue = new Queue<GameObject>();

    static Destroyer()
    {
        UnityEditor.EditorApplication.update += () =>
        {
            for (int i = 0; targetQueue.Count > 0 && i < 100000; i++)
            {
                var next = targetQueue.Dequeue();
                DestroyImmediate(next);
            }
        };
    }
    public static void Destroy(GameObject go) => targetQueue.Enqueue(go);
}
#endif
```

</details>

<br>

# 헤더 영역 드래그 앤 드롭 이동 구현
---

![2021_0421_InventoryUI_Move2](https://user-images.githubusercontent.com/42164422/115679424-89a5e900-a38d-11eb-88b9-e873fa68d39d.gif)

<br>

UI의 드래그 앤 드롭을 구현하려면 기본적으로 GraphicRaycaster를 이용해야 한다.

그리고 클릭, 클릭 유지, 클릭을 뗄 경우를 모두 고려하여 작성해야 하는 번거로움이 있다.

유니티에는 이런 번거로움을 단번에 해결해주는 친절한 API가 존재한다.

`UnityEngine.EventSystems` 네임스페이스 내에는 `IPointerDownHandler`, `IDragHandler` 등의 포인터 관련 인터페이스들이 존재하며, 이 인터페이스들을 상속하여 해당하는 메소드들을 구현하면 내부적으로 알맞은 포인터 이벤트를 제공해준다.


<details>
<summary markdown="span">
MovableHeaderUI.cs
</summary>

```cs
public class MovableHeaderUI : MonoBehaviour, IPointerDownHandler, IDragHandler
{
    [SerializeField]
    private Transform _targetTr; // 이동될 UI

    private Vector2 _beginPoint;
    private Vector2 _moveBegin;

    private void Awake()
    {
        // 이동 대상 UI를 지정하지 않은 경우, 자동으로 부모로 초기화
        if(_targetTr == null)
            _targetTr = transform.parent;
    }

    // 드래그 시작 위치 지정
    void IPointerDownHandler.OnPointerDown(PointerEventData eventData)
    {
        _beginPoint = _targetTr.position;
        _moveBegin = eventData.position;
    }

    // 드래그 : 마우스 커서 위치로 이동
    void IDragHandler.OnDrag(PointerEventData eventData)
    {
        _targetTr.position = _beginPoint + (eventData.position - _moveBegin);
    }
}
```

</details>

드래그 앤 드롭은 이를 이용하여 간단히 구현할 수 있다.

마우스 버튼을 누르는 `OnPointerDown` 이벤트가 발생할 때의 트랜스폼 위치와 마우스 위치를 기억하고,

드래그 이벤트가 발생할 때 마우스 위치 변동 거리를 Offset으로 이용하여

시작 위치로부터 Offset만큼 더해주면 된다.

위에서 작성한 스크립트를 [Header Area] 게임오브젝트에 컴포넌트로 넣어준다.

<br>

# 아이템 드래그 앤 드롭 이동 구현
---

![2021_0426_InventoryDrag](https://user-images.githubusercontent.com/42164422/116001990-68195b80-a632-11eb-98a1-12410041247c.gif)

<br>

아이템의 드래그 앤 드롭을 구현하는 다양한 방법들이 있다.

## **[1] 각각의 아이템 아이콘마다 스크립트로 구현하기**

각 슬롯의 자식으로 아이템 아이콘이 있다.

현재 만들고 있는 것처럼 8x8 = 64개의 슬롯일 경우, 64개의 아이콘이 있다.

그러면 새로 아이콘을 위한 스크립트를 작성하고 64개의 아이템에 컴포넌트로 넣어준다.

드래그 앤 드롭은 헤더 이동을 구현할 때처럼 포인터 인터페이스로 구현한다.

<br>

이렇게 구현하게 된다면

- 새로운 스크립트를 작성해야 한다.
- 작성한 스크립트를 슬롯 개수만큼 아이템의 컴포넌트로 모두 넣어줘야 한다.
- 드래그 앤 드롭의 결과를 슬롯에 전달하기 위해 아이템에서는 슬롯의 레퍼런스를 알아야 한다.
- 추후 아이템 제거 또는 비활성화 등 다양한 기능의 구현을 위해 슬롯 또는 인벤토리 역시 아이템의 레퍼런스를 알아야 한다. (상호 참조 문제)
- 내부적으로 동작하는 포인터 이벤트가 아이템 개수만큼의 오버헤드를 발생시킨다.

위처럼 다양한 문제가 발생하므로 비효율적이다.

<br>

## **[2] 각 슬롯 스크립트에서 구현하기**

슬롯을 관리하는 스크립트인 `ItemSlotUI`에서 드래그 앤 드롭도 구현하는 방법이 있다.

아이템 스크립트를 따로 작성하지 않아도 된다는 장점이 있으나,

- 클래스의 역할이 비대해진다.
- 슬롯 개수만큼의 이벤트 오버헤드가 동일하게 발생한다.

위와 같은 문제점이 아직 존재한다.

<br>

## **[3] 인벤토리 UI에서 구현하기**

포인터 인터페이스를 사용하지 않고, `GraphicRaycaster`를 이용하여 `InventoryUI` 스크립트에서 직접 구현하는 방법이다.

포인터의 Down, Drag, Up 이벤트를 직접 구현해야 한다는 번거로움이 있지만

- 슬롯 개수만큼의 오버헤드는 더이상 발생하지 않는다.
- 드래그 앤 드롭 관련 모든 이벤트의 중앙 관리가 가능해진다.

이런 장점들이 있으므로 최선의 선택이라고 할 수 있다.


<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private GraphicRaycaster _gr;
private PointerEventData _ped;
private List<RaycastResult> _rrList;

private ItemSlotUI _beginDragSlot; // 현재 드래그를 시작한 슬롯
private Transform _beginDragIconTransform; // 해당 슬롯의 아이콘 트랜스폼

private Vector3 _beginDragIconPoint;   // 드래그 시작 시 슬롯의 위치
private Vector3 _beginDragCursorPoint; // 드래그 시작 시 커서의 위치
private int _beginDragSlotSiblingIndex;

private void Update()
{
    _ped.position = Input.mousePosition;

    OnPointerDown();
    OnPointerDrag();
    OnPointerUp();
}

private T RaycastAndGetFirstComponent<T>() where T : Component
{
    _rrList.Clear();

    _gr.Raycast(_ped, _rrList);

    if(_rrList.Count == 0)
        return null;

    return _rrList[0].gameObject.GetComponent<T>();
}

private void OnPointerDown()
{
    // Left Click : Begin Drag
    if (Input.GetMouseButtonDown(0))
    {
        _beginDragSlot = RaycastAndGetFirstComponent<ItemSlotUI>();

        // 아이템을 갖고 있는 슬롯만 해당
        if (_beginDragSlot != null && _beginDragSlot.HasItem)
        {
            // 위치 기억, 참조 등록
            _beginDragIconTransform = _beginDragSlot.IconRect.transform;
            _beginDragIconPoint = _beginDragIconTransform.position;
            _beginDragCursorPoint = Input.mousePosition;

            // 맨 위에 보이기
            _beginDragSlotSiblingIndex = _beginDragSlot.transform.GetSiblingIndex();
            _beginDragSlot.transform.SetAsLastSibling();

            // 해당 슬롯의 하이라이트 이미지를 아이콘보다 뒤에 위치시키기
            _beginDragSlot.SetHighlightOnTop(false);
        }
        else
        {
            _beginDragSlot = null;
        }
    }
}
/// <summary> 드래그하는 도중 </summary>
private void OnPointerDrag()
{
    if(_beginDragSlot == null) return;

    if (Input.GetMouseButton(0))
    {
        // 위치 이동
        _beginDragIconTransform.position =
            _beginDragIconPoint + (Input.mousePosition - _beginDragCursorPoint);
    }
}
/// <summary> 클릭을 뗄 경우 </summary>
private void OnPointerUp()
{
    if (Input.GetMouseButtonUp(0))
    {
        // End Drag
        if (_beginDragSlot != null)
        {
            // 위치 복원
            _beginDragIconTransform.position = _beginDragIconPoint;

            // UI 순서 복원
            _beginDragSlot.transform.SetSiblingIndex(_beginDragSlotSiblingIndex);

            // 드래그 완료 처리
            EndDrag();

            // 참조 제거
            _beginDragSlot = null;
            _beginDragIconTransform = null;
        }
    }
}
```

</details>

<br>

# ItemSlotUI 클래스 구현
---

`ItemSlotUI` 클래스는 각 아이템 슬롯의 컴포넌트로 사용된다.

슬롯 클래스가 관리해야 할 데이터들은 다음과 같다.

- 슬롯의 인덱스
- 슬롯의 접근 가능 여부
- 아이템 이미지
- 수량 텍스트
- 하이라이트(마우스 올렸을 때 강조 이미지)

그리고 슬롯에서 발생하는 모든 기능들을 메소드로 구현하면 된다.

예를 들어

- 아이템 이미지 변경/보이기/숨기기
- 수량 텍스트 변경/보이기/숨기기
- 하이라이트 이미지 보이기/숨기기
- 슬롯 접근 가능 여부 변경

등이 있다.

<br>

+

`ItemSlotUI`와 `Item`은 서로를 참조하지 않는다.

`ItemSlotUI`는 `InventoryUI`가 관리하며, `Item`은 `Inventory`가 관리한다.

`ItemSlotUI`와 `Item`의 상태 공유는 `IntentoryUI`, `Inventory`에 의해 간접적으로 이루어진다.

<br>

## **Source Code**

<details>
<summary markdown="span">
Fields
</summary>

```cs
[Tooltip("아이템 아이콘 이미지")]
[SerializeField] private Image _iconImage;

[Tooltip("아이템 개수 텍스트")]
[SerializeField] private Text _amountText;

[Tooltip("슬롯이 포커스될 때 나타나는 하이라이트 이미지")]
[SerializeField] private Image _highlightImage;

[Space]
[Tooltip("하이라이트 이미지 알파 값")]
[SerializeField] private float _highlightAlpha = 0.5f;

[Tooltip("하이라이트 소요 시간")]
[SerializeField] private float _highlightFadeDuration = 0.2f;


/// <summary> 슬롯의 인덱스 </summary>
public int Index { get; private set; }

/// <summary> 슬롯이 아이템을 보유하고 있는지 여부 </summary>
public bool HasItem => _iconImage.sprite != null;

/// <summary> 접근 가능한 슬롯인지 여부 </summary>
public bool IsAccessible => _isAccessibleSlot && _isAccessibleItem;

public RectTransform SlotRect => _slotRect;
public RectTransform IconRect => _iconRect;


private InventoryUI _inventoryUI;

private RectTransform _slotRect;
private RectTransform _iconRect;
private RectTransform _highlightRect;

private GameObject _iconGo;
private GameObject _textGo;
private GameObject _highlightGo;

private Image _slotImage;

// 현재 하이라이트 알파값
private float _currentHLAlpha = 0f;

private bool _isAccessibleSlot = true; // 슬롯 접근가능 여부
private bool _isAccessibleItem = true; // 아이템 접근가능 여부

/// <summary> 비활성화된 슬롯의 색상 </summary>
private static readonly Color InaccessibleSlotColor = new Color(0.2f, 0.2f, 0.2f, 0.5f);
/// <summary> 비활성화된 아이콘 색상 </summary>
private static readonly Color InaccessibleIconColor = new Color(0.5f, 0.5f, 0.5f, 0.5f);
```

</details>

<br>

<details>
<summary markdown="span">
Methods
</summary>

```cs
private void ShowIcon() => _iconGo.SetActive(true);
private void HideIcon() => _iconGo.SetActive(false);

private void ShowText() => _textGo.SetActive(true);
private void HideText() => _textGo.SetActive(false);

public void SetSlotIndex(int index) => Index = index;

/// <summary> 슬롯 자체의 활성화/비활성화 여부 설정 </summary>
public void SetSlotAccessibleState(bool value)
{
    // 중복 처리는 지양
    if (_isAccessibleSlot == value) return;

    if (value)
    {
        _slotImage.color = Color.black;
    }
    else
    {
        _slotImage.color = InaccessibleSlotColor;
        HideIcon();
        HideText();
    }

    _isAccessibleSlot = value;
}

/// <summary> 아이템 활성화/비활성화 여부 설정 </summary>
public void SetItemAccessibleState(bool value)
{
    if(_isAccessibleItem == value) return;

    if (value)
    {
        _iconImage.color = Color.white;
        _amountText.color = Color.white;
    }
    else
    {
        _iconImage.color  = InaccessibleIconColor;
        _amountText.color = InaccessibleIconColor;
    }

    _isAccessibleItem = value;
}

/// <summary> 다른 슬롯과 아이템 아이콘 교환 </summary>
public void SwapOrMoveIcon(ItemSlotUI other)
{
    if (other == null) return;
    if (other == this) return; // 자기 자신과 교환 불가
    if (!this.IsAccessible) return;
    if (!other.IsAccessible) return;

    var temp = _iconImage.sprite;

    // 1. 대상에 아이템이 있는 경우 : 교환
    if (other.HasItem) SetItem(other._iconImage.sprite);

    // 2. 없는 경우 : 이동
    else RemoveItem();

    other.SetItem(temp);
}

/// <summary> 슬롯에 아이템 등록 </summary>
public void SetItem(Sprite itemSprite)
{
    if (itemSprite != null)
    {
        _iconImage.sprite = itemSprite;
        ShowIcon();
    }
    else
    {
        RemoveItem();
    }
}

/// <summary> 슬롯에서 아이템 제거 </summary>
public void RemoveItem()
{
    _iconImage.sprite = null;
    HideIcon();
    HideText();
}

/// <summary> 아이템 이미지 투명도 설정 </summary>
public void SetIconAlpha(float alpha)
{
    _iconImage.color = new Color(
        _iconImage.color.r, _iconImage.color.g, _iconImage.color.b, alpha
    );
}

/// <summary> 아이템 개수 텍스트 설정(amount가 1 이하일 경우 텍스트 미표시) </summary>
public void SetItemAmount(int amount)
{
    if (HasItem && amount > 1)
        ShowText();
    else
        HideText();

    _amountText.text = amount.ToString();
}
```

</details>

<br>

# 아이템과 아이템 데이터
---

아이템에는 각 아이템마다 개별적으로 가질 데이터와 공통으로 가질 데이터가 존재한다.

예를 들어 아이템 이름은 공통 데이터이며, 아이템 수량이나 장비 내구도는 개별 데이터이다.

그런데 공통 데이터도 아이템 객체가 필드로 갖게 되면 아이템 개수에 비례해서 그만큼의 메모리를 낭비하게 되는 셈이므로, 이를 분리할 필요가 있다.

따라서 각각의 아이템을 의미하며 개별 데이터를 관리할 클래스는 `Item`,

공통 데이터를 관리할 클래스는 `ItemData`로 작성한다.

공통 데이터는 스크립터블 오브젝트를 상속하여 미리 애셋 형태로 유니티 내에서 관리할 수 있게 한다.

<br>


<details>
<summary markdown="span">
ItemData.cs
</summary>

```cs
public abstract class ItemData : ScriptableObject
{
    public int ID => _id;
    public string Name => _name;
    public string Tooltip => _tooltip;
    public Sprite IconSprite => _iconSprite;

    [SerializeField] private int      _id;
    [SerializeField] private string   _name;    // 아이템 이름
    [Multiline]
    [SerializeField] private string   _tooltip; // 아이템 설명
    [SerializeField] private Sprite   _iconSprite; // 아이템 아이콘
    [SerializeField] private GameObject _dropItemPrefab; // 바닥에 떨어질 때 생성할 프리팹

    /// <summary> 타입에 맞는 새로운 아이템 생성 </summary>
    public abstract Item CreateItem();
}
```

</details>


<details>
<summary markdown="span">
CountableItemData.cs
</summary>

```cs
/// <summary> 셀 수 있는 아이템 데이터 </summary>
public abstract class CountableItemData : ItemData
{
    public int MaxAmount => _maxAmount;
    [SerializeField] private int _maxAmount = 99;
}
```

</details>


<details>
<summary markdown="span">
PortionItemData.cs
</summary>

```cs
/// <summary> 소비 아이템 정보 </summary>
[CreateAssetMenu(fileName = "Item_Portion_", menuName = "Inventory System/Item Data/Portion", order = 3)]
public class PortionItemData : CountableItemData
{
    /// <summary> 효과량(회복량 등) </summary>
    public float Value => _value;
    [SerializeField] private float _value;
    public override Item CreateItem()
    {
        return new PortionItem(this);
    }
}
```

</details>

<br>

`ItemData` 클래스는 `ScriptableObject` 클래스를 상속하며, 아이템의 공통 데이터들을 저장한다.

그리고 이를 상속받는 하위 클래스들을 작성하고 유니티 내에서 미리 아이템 애셋들을 만들어 관리한다.

![image](https://user-images.githubusercontent.com/42164422/115995280-9d638080-a615-11eb-945c-b13558c15240.png)

![image](https://user-images.githubusercontent.com/42164422/118019293-c7e26700-b393-11eb-93f2-ff640501ab9e.png)

<br>


<details>
<summary markdown="span">
Item.cs
</summary>

```cs
public abstract class Item
{
    public ItemData Data { get; private set; }

    public Item(ItemData data) => Data = data;
}
```

</details>


<details>
<summary markdown="span">
CountableItem.cs
</summary>

```cs
/// <summary> 수량을 셀 수 있는 아이템 </summary>
public abstract class CountableItem : Item
{
    public CountableItemData CountableData { get; private set; }

    /// <summary> 현재 아이템 개수 </summary>
    public int Amount { get; protected set; }

    /// <summary> 하나의 슬롯이 가질 수 있는 최대 개수(기본 99) </summary>
    public int MaxAmount => CountableData.MaxAmount;

    /// <summary> 수량이 가득 찼는지 여부 </summary>
    public bool IsMax => Amount >= CountableData.MaxAmount;

    /// <summary> 개수가 없는지 여부 </summary>
    public bool IsEmpty => Amount <= 0;


    public CountableItem(CountableItemData data, int amount = 1) : base(data)
    {
        CountableData = data;
        SetAmount(amount);
    }

    /// <summary> 개수 지정(범위 제한) </summary>
    public void SetAmount(int amount)
    {
        Amount = Mathf.Clamp(amount, 0, MaxAmount);
    }

    /// <summary> 개수 추가 및 최대치 초과량 반환(초과량 없을 경우 0) </summary>
    public int AddAmountAndGetExcess(int amount)
    {
        int nextAmount = Amount + amount;
        SetAmount(nextAmount);

        return (nextAmount > MaxAmount) ? (nextAmount - MaxAmount) : 0;
    }

    /// <summary> 개수를 나누어 복제 </summary>
    public CountableItem SeperateAndClone(int amount)
    {
        // 수량이 한개 이하일 경우, 복제 불가
        if(Amount <= 1) return null;

        if(amount > Amount - 1)
            amount = Amount - 1;

        Amount -= amount;
        return Clone(amount);
    }

    protected abstract CountableItem Clone(int amount);
}
```

</details>


<details>
<summary markdown="span">
PortionItem.cs
</summary>

```cs
/// <summary> 수량 아이템 - 포션 아이템 </summary>
public class PortionItem : CountableItem, IUsableItem
{
    public PortionItem(PortionItemData data, int amount = 1) : base(data, amount) { }

    public bool Use()
    {
        // 임시 : 개수 하나 감소
        Amount--;

        return true;
    }

    protected override CountableItem Clone(int amount)
    {
        return new PortionItem(CountableData as PortionItemData, amount);
    }
}
```

</details>

<br>

`Item` 클래스는 아이템의 실체라고 할 수 있다.

따라서 필드로 각각의 아이템이 가질 개별 데이터를 작성하고,

메소드로는 아이템의 동작들을 구현한다.

<br>

# Inventory 클래스 구현
---

`Inventory` 클래스는 실질적으로 모든 아이템을 `Item` 배열로 관리하고,

인벤토리 내부의 동작을 담당한다.

인벤토리의 각 슬롯은 아이템 배열의 각 `Item`과 1:1 대응되며,

따라서 빈 슬롯이 존재할 수 있으므로 리스트가 아닌 배열을 사용한다.

<br>

`Inventory` 클래스는 `InventoryUI` 클래스와 상호작용하게 된다.

예를 들어 새로운 아이템이 추가되었을 때 `InventoryUI`를 참조하여 UI를 갱신하고,

UI에서 사용자 이벤트가 발생했을 때 `InventoryUI`는 `Inventory`를 참조하여 `Item` 또는 배열을 갱신한다.

<br>

`Inventory` 클래스가 관리할 데이터(필드)는 다음과 같다.

- `Item` 배열
- `Capacity` : 인벤토리의 아이템 수용 한도

<br>

그리고 `Inventory` 클래스 내에 작성할 동작(메소드)들은

- 아이템 정보 확인
- 아이템 정보 갱신
- 아이템 추가
- 아이템 제거
- 아이템 이동
- 아이템 정렬
- 아이템 사용

등이 있다.

<br>

## **Source Code**

<details>
<summary markdown="span">
Fields
</summary>

```cs
/// <summary> 아이템 수용 한도 </summary>
public int Capacity { get; private set; }

// 초기 수용 한도
[SerializeField, Range(8, 64)]
private int _initalCapacity = 32;

// 최대 수용 한도(아이템 배열 크기)
[SerializeField, Range(8, 64)]
private int _maxCapacity = 64;

[SerializeField]
private InventoryUI _inventoryUI; // 연결된 인벤토리 UI

/// <summary> 아이템 목록 </summary>
[SerializeField]
private Item[] _items;

```

</details>

<br>

<details>
<summary markdown="span">
Methods
</summary>

```cs
private void Awake()
{
    _items = new Item[_maxCapacity];
    Capacity = _initalCapacity;
}

private void Start()
{
    UpdateAccessibleStatesAll();
}

/// <summary> 인덱스가 수용 범위 내에 있는지 검사 </summary>
private bool IsValidIndex(int index)
{
    return index >= 0 && index < Capacity;
}

/// <summary> 앞에서부터 비어있는 슬롯 인덱스 탐색 </summary>
private int FindEmptySlotIndex(int startIndex = 0)
{
    for (int i = startIndex; i < Capacity; i++)
        if (_items[i] == null)
            return i;
    return -1;
}


/// <summary> 모든 슬롯 UI에 접근 가능 여부 업데이트 </summary>
public void UpdateAccessibleStatesAll()
{
    _inventoryUI.SetAccessibleSlotRange(Capacity);
}

/// <summary> 해당 슬롯이 아이템을 갖고 있는지 여부 </summary>
public bool HasItem(int index)
{
    return IsValidIndex(index) && _items[index] != null;
}

/// <summary> 해당 슬롯이 셀 수 있는 아이템인지 여부 </summary>
public bool IsCountableItem(int index)
{
    return HasItem(index) && _items[index] is CountableItem;
}

/// <summary>
/// 해당 슬롯의 현재 아이템 개수 리턴
/// <para/> - 잘못된 인덱스 : -1 리턴
/// <para/> - 빈 슬롯 : 0 리턴
/// <para/> - 셀 수 없는 아이템 : 1 리턴
/// </summary>
public int GetCurrentAmount(int index)
{
    if (!IsValidIndex(index)) return -1;
    if (_items[index] == null) return 0;

    CountableItem ci = _items[index] as CountableItem;
    if (ci == null)
        return 1;

    return ci.Amount;
}

/// <summary> 해당 슬롯의 아이템 정보 리턴 </summary>
public ItemData GetItemData(int index)
{
    if (!IsValidIndex(index)) return null;
    if (_items[index] == null) return null;

    return _items[index].Data;
}

/// <summary> 해당 슬롯의 아이템 이름 리턴 </summary>
public string GetItemName(int index)
{
    if (!IsValidIndex(index)) return "";
    if (_items[index] == null) return "";

    return _items[index].Data.Name;
}
```

</details>

<br>

# 인벤토리 슬롯 업데이트 기능 구현
---

슬롯의 업데이트는 정말 많은 경우에 사용된다.

- 아이템 위치 이동
- 아이템 추가
- 아이템 제거
- 아이템 사용
- ..

따라서 각 기능 수행 후에 개별적으로 서로 다른 정보를 UI에 전달하고 업데이트하는 것보다

`Inventory` 클래스에서 하나의 메소드로 작성하여 사용하는 것이 효율적이고 코드 유지보수에 큰 장점을 가진다.

<br>

## **[1] Pseudo Code**

인벤토리의 아이템에 변화가 생겼을 때, 인벤토리에서 인벤토리 UI에 전달할 정보는

1. 해당 슬롯에 아이템이 존재하는지 여부
2. 아이템 이미지
3. 아이템 수량

이렇게 세 가지가 있다.

<br>

그리고 수량이 있는 아이템의 경우, 수량이 0이라면 아이템을 제거해야 한다.

이를 간단히 의사코드로 표현해보면 다음과 같다.

```
function UpdateSlot(int index)

Item item = items[index]
if (item == null)
    inventoryUI.RemoveItem(index)
else
    inventoryUI.SetImage(index, item.image)
    if (item is CountableItem)
        if(item.amount <= 0)
            inventoryUI.RemoveItem(index)
            items[index] = null
        else
            inventoryUI.SetAmount(index, item.amount)
```

<br>

## **[2] Source Code**

<details>
<summary markdown="span">
Source Code
</summary>

```cs
/// <summary> 해당하는 인덱스의 슬롯 상태 및 UI 갱신 </summary>
public void UpdateSlot(int index)
{
    if (!IsValidIndex(index)) return;

    Item item = _items[index];

    // 1. 아이템이 슬롯에 존재하는 경우
    if (item != null)
    {
        // 아이콘 등록
        _inventoryUI.SetItemIcon(index, item.Data.IconSprite);

        // 1-1. 셀 수 있는 아이템
        if (item is CountableItem ci)
        {
            // 1-1-1. 수량이 0인 경우, 아이템 제거
            if (ci.IsEmpty)
            {
                _items[index] = null;
                RemoveIcon();
                return;
            }
            // 1-1-2. 수량 텍스트 표시
            else
            {
                _inventoryUI.SetItemAmountText(index, ci.Amount);
            }
        }
        // 1-2. 셀 수 없는 아이템인 경우 수량 텍스트 제거
        else
        {
            _inventoryUI.HideItemAmountText(index);
        }
    }
    // 2. 빈 슬롯인 경우 : 아이콘 제거
    else
    {
        RemoveIcon();
    }

    // 로컬 : 아이콘 제거하기
    void RemoveIcon()
    {
        _inventoryUI.RemoveItem(index);
        _inventoryUI.HideItemAmountText(index); // 수량 텍스트 숨기기
    }
}
```

</details>

<br>

# 아이템 위치 이동 및 교환
---

![2021_0508_Inventory_Swap](https://user-images.githubusercontent.com/42164422/117529666-c02d6600-b013-11eb-9f71-7e7988ee92e9.gif)

<br>

아이템의 드래그 앤 드롭 기능은 앞서 구현하였다.

그리고 이를 기반으로 실제 아이템의 이동 또는 아이템끼리의 위치 교환을 구현한다.

<br>

## **[1] 드래그 앤 드롭**

`InventoryUI`에서 드래그 앤 드롭을 통해 드래그 시작 슬롯과 종료 슬롯의 인덱스를 각각 얻을 수 있다.

그리고 얻어낸 두 인덱스를 각각 a, b라고 할 때,

`Inventory`의 메소드에 `Inventory.Swap(a, b)`처럼 전달한다.

<br>

## **[2] Swap(a, b)**

`Inventory`에서는 아이템들을 배열로 관리하므로

`Swap(a, b)`는 배열 인덱스 a, b의 아이템을 서로 교환하는 것으로 간단히 구현할 수 있다.

<br>

## **[3] 수량 합치기**

수량이 있는 동일한 아이템을 드래그 앤 드롭으로 교환하는 경우,

드래그 앤 드롭 시작 아이템으로부터 종료 아이템에 수량을 합치는 기능을 구현한다.

![2021_0508_Inventory_SumAmount](https://user-images.githubusercontent.com/42164422/117532612-574dea00-b023-11eb-8f4d-f46d45ecb8f4.gif)

<br>

## **Source Code**

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private void EndDrag()
{
    ItemSlotUI endDragSlot = RaycastAndGetFirstComponent<ItemSlotUI>();

    if (endDragSlot != null && endDragSlot.IsAccessible)
    {
        TrySwapItems(_beginDragSlot, endDragSlot);
    }
}

/// <summary> 두 슬롯의 아이템 교환 </summary>
private void TrySwapItems(ItemSlotUI from, ItemSlotUI to)
{
    if (from == to)
    {
        return;
    }

    from.SwapOrMoveIcon(to);
    _inventory.Swap(from.Index, to.Index);
}
```

</details>

<details>
<summary markdown="span">
Inventory.cs
</summary>

```cs
public void Swap(int indexA, int indexB)
{
    if (!IsValidIndex(indexA)) return;
    if (!IsValidIndex(indexB)) return;

    Item itemA = _items[indexA];
    Item itemB = _items[indexB];

    // 1. 셀 수 있는 아이템이고, 동일한 아이템일 경우
    //    indexA -> indexB로 개수 합치기
    if (itemA != null && itemB != null &&
        itemA.Data == itemB.Data &&
        itemA is CountableItem ciA && itemB is CountableItem ciB)
    {
        int maxAmount = ciB.MaxAmount;
        int sum = ciA.Amount + ciB.Amount;

        if (sum <= maxAmount)
        {
            ciA.SetAmount(0);
            ciB.SetAmount(sum);
        }
        else
        {
            ciA.SetAmount(sum - maxAmount);
            ciB.SetAmount(maxAmount);
        }
    }
    // 2. 일반적인 경우 : 슬롯 교체
    else
    {
        _items[indexA] = itemB;
        _items[indexB] = itemA;
    }

    // 두 슬롯 정보 갱신
    UpdateSlot(indexA, indexB);
}
```

</details>

<br>

# 아이템 추가하기
---

![2021_0508_Inventory_Add](https://user-images.githubusercontent.com/42164422/117530087-3763f980-b016-11eb-97cd-def732c7e848.gif)

<br>

아이템을 추가하는 기능은 다음과 같이 이루어진다.

1. 외부 객체에 의한 아이템 습득
2. `Inventory`의 Item 배열 내에 습득한 아이템 추가
3. `InventoryUI`에서 해당 슬롯 정보 갱신
4. 해당 `ItemSlotUI` 갱신

그리고 이를 단순한 코드로 표현해보면

```
0. someone.AcquireItem( newItem );
1. inventory.Add( newItem );
2. inventory.UpdateSlot( itemIndex );
3. inventoryUI.UpdateSlot( itemIndex );
4. itemSlotUI.Update( );
```

위처럼 표현해볼 수 있다.

<br>

## **[1] Pseudo Code**

새로운 아이템을 인벤토리 내의 배열에 추가할 때, 두 가지 정보가 필요하다.

해당 아이템의 고유 데이터와, 추가할 아이템의 개수.

그리고 수량이 있는 아이템인지 여부에 따라 나누어 구현해야 한다.

수량이 없는 아이템이라면 배열의 앞에서부터 빈 슬롯을 찾아 차례대로 넣고,

수량이 있는 아이템이라면 이미 존재하는 동일 아이템을 찾아 수량을 합산하고,

최대 수량에 도달한 경우 앞에서부터 빈 슬롯을 찾아 차례대로 넣는다.

그리고 인벤토리가 가득차 모든 아이템을 넣지 못했다면, 해당 수량만큼 메소드에서 리턴해준다.

의사 코드로 표현하면 다음과 같다.

```
function AddItem(ItemData data, int amount) : return int

// 1. 수량이 있는 아이템
if (data is CountableItemData)
    while (amount > 0)
        existedItem = GetExistedCountableItem(data)

        // 1-1. 여유 수량이 있는 동일 아이템이 존재하는 경우
        while (existedItem)
            spareAmount = GetSpareAmount(existedItemIndex)
            existedItem.amount += spareAmount
            amount -= spareAmount
            UpdateSlot(existedItem.index)
            existedItem = GetExistedCountableItem(data)

        // 1-2. 빈 슬롯이 존재하는 경우
        slotIndex = FindEmptySlotIndex()
        while (slotIndex >= 0)
            newItem = data.CreateItem()
            newItem.amount = Min(newItem.maxAmount, amount)
            amount -= newItem.amount
            itemArray[slotIndex] = newItem
            UpdateSlot(slotIndex)
            slotIndex = FindEmptySlotIndex()

// 2. 수량이 없는 아이템
else
    while (slotIndex = FindEmptySlotIndex() >= 0)
        itemArray[slotIndex] = data.CreateItem()
        UpdateSlot(slotIndex)
        amount--

return amount
```

<br>

## **[2] Source Code : Inventory**

<details>
<summary markdown="span">
Inventory.cs
</summary>

```cs
/// <summary> 인벤토리에 아이템 추가
/// <para/> 넣는 데 실패한 잉여 아이템 개수 리턴
/// <para/> 리턴이 0이면 넣는데 모두 성공했다는 의미
/// </summary>
public int Add(ItemData itemData, int amount = 1)
{
    int index;

    // 1. 수량이 있는 아이템
    if (itemData is CountableItemData ciData)
    {
        bool findNextCountable = true;
        index = -1;

        while (amount > 0)
        {
            // 1-1. 이미 해당 아이템이 인벤토리 내에 존재하고, 개수 여유 있는지 검사
            if (findNextCountable)
            {
                index = FindCountableItemSlotIndex(ciData, index + 1);

                // 개수 여유있는 기존재 슬롯이 더이상 없다고 판단될 경우, 빈 슬롯부터 탐색 시작
                if (index == -1)
                {
                    findNextCountable = false;
                }
                // 기존재 슬롯을 찾은 경우, 양 증가시키고 초과량 존재 시 amount에 초기화
                else
                {
                    CountableItem ci = _items[index] as CountableItem;
                    amount = ci.AddAmountAndGetExcess(amount);

                    UpdateSlot(index);
                }
            }
            // 1-2. 빈 슬롯 탐색
            else
            {
                index = FindEmptySlotIndex(index + 1);

                // 빈 슬롯조차 없는 경우 종료
                if (index == -1)
                {
                    break;
                }
                // 빈 슬롯 발견 시, 슬롯에 아이템 추가 및 잉여량 계산
                else
                {
                    // 새로운 아이템 생성
                    CountableItem ci = ciData.CreateItem() as CountableItem;
                    ci.SetAmount(amount);

                    // 슬롯에 추가
                    _items[index] = ci;

                    // 남은 개수 계산
                    amount = (amount > ciData.MaxAmount) ? (amount - ciData.MaxAmount) : 0;

                    UpdateSlot(index);
                }
            }
        }
    }
    // 2. 수량이 없는 아이템
    else
    {
        // 2-1. 1개만 넣는 경우, 간단히 수행
        if (amount == 1)
        {
            index = FindEmptySlotIndex();
            if (index != -1)
            {
                // 아이템을 생성하여 슬롯에 추가
                _items[index] = itemData.CreateItem();
                amount = 0;

                UpdateSlot(index);
            }
        }

        // 2-2. 2개 이상의 수량 없는 아이템을 동시에 추가하는 경우
        index = -1;
        for (; amount > 0; amount--)
        {
            // 아이템 넣은 인덱스의 다음 인덱스부터 슬롯 탐색
            index = FindEmptySlotIndex(index + 1);

            // 다 넣지 못한 경우 루프 종료
            if (index == -1)
            {
                break;
            }

            // 아이템을 생성하여 슬롯에 추가
            _items[index] = itemData.CreateItem();

            UpdateSlot(index);
        }
    }

    return amount;
}
```

</details>


<br>

# 아이템 버리기
---

![2021_0508_Inventory_Remove](https://user-images.githubusercontent.com/42164422/117530089-38952680-b016-11eb-9d5c-3b485c767ae3.gif)

아이템을 버리는 기능은 다음 순서대로 구현한다.

1. 사용자 - 드래그 앤 드롭으로 UI가 아닌 영역에 아이템 끌어다 놓기
2. InventoryUI - Inventory에 해당 인덱스의 아이템 제거 요청
3. Inventory - 아이템 제거(`items[index] = null`)
4. Inventory - UI에 슬롯 업데이트 요청
5. InventoryUI - 슬롯 업데이트
6. ItemSlotUI - 이미지, 텍스트 업데이트

<br>

## **Source Code**

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private void EndDrag()
{
    ItemSlotUI endDragSlot = RaycastAndGetFirstComponent<ItemSlotUI>();

    // 아이템 슬롯끼리 아이콘 교환 또는 이동
    if (endDragSlot != null && endDragSlot.IsAccessible)
    {
        TrySwapItems(_beginDragSlot, endDragSlot);
    }

    // 버리기(커서가 UI 레이캐스트 타겟 위에 있지 않은 경우)
    if (!IsOverUI())
    {
        TryRemoveItem(index);
    }
}

/// <summary> UI 및 인벤토리에서 아이템 제거 </summary>
private void TryRemoveItem(int index)
{
    _inventory.Remove(index);
}

private bool IsOverUI()
    => EventSystem.current.IsPointerOverGameObject();
```

</details>

<details>
<summary markdown="span">
Inventory.cs
</summary>

```cs
/// <summary> 해당 슬롯의 아이템 제거 </summary>
public void Remove(int index)
{
    if (!IsValidIndex(index)) return;

    _items[index] = null;
    UpdateSlot(index);
}
```

</details>

<br>

# 아이템 사용하기
---

아이템에 우클릭 시 아이템을 사용하는 기능을 구현한다.

![2021_0508_Inventory_Use](https://user-images.githubusercontent.com/42164422/117530090-392dbd00-b016-11eb-877f-81a8d62fe612.gif)

<br>

## **[1] 구조 설계**

보통의 RPG 게임에서 인벤토리의 아이템은 우클릭을 통해 사용한다.

그리고 장비, 소비 아이템 등 사용할 수 있는 아이템과 재료 아이템 등 사용할 수 없는 아이템으로 구분된다.

그런데 아이템 사용을 단순히 클래스 상속 구조로 구현하려면 구조 설계에 제약이 생긴다.

예를 들어 장비 아이템(`EquimentItem`)은 수량이 없는 아이템(`Item`)이고, 소비 아이템은 수량이 있는 아이템(`CountableItem`)이다.

CountableItem 클래스는 Item 클래스의 하위 클래스이다.

<br>

따라서 아이템 사용을 상속 관계를 통해 구현하려면

1. `Item`과 `CountableItem`의 공통 부모 클래스로 `UsableItem`을 만든다.<br>
  => 부모-자식관계의 역전이 발생한다.

2. `Item`의 자식클래스로 `UsableItem`, 그리고 `UsableItem`을 다시 `EquimentItem`, `CountableItem`이 상속받는 형태로 만든다.<br>
  => 계층관계가 더 깊어져 관리가 까다로워지고, `UsableItem`이 아닌 `CountableItem`은 구현할 수 없다.

이런 문제들이 발생한다.

<br>

위의 모든 문제를 해결하기 위해, 우선 인터페이스를 준비한다.

```cs
interface IUsableItem
{
    // 아이템 사용 : 성공 여부 리턴
    bool Use();
}
```

그리고 장비 아이템과 소비아이템 등, 사용할 수 있는 아이템들은 `IUsableItem`을 상속하고 메소드를 구현한다.

예시 :

```cs
public class PortionItem : CountableItem, IUsableItem
{
    // 인터페이스 메소드 구현
    public bool Use()
    {
        Amount--;
        return true;
    }
}
```

<br>

## **[2] 시퀀스 설계**

아이템 사용 기능은 아래 순서로 이루어진다.

1. 사용자 - 인벤토리의 슬롯 우클릭
2. InventoryUI - Inventory에 아이템 사용 요청
3. Inventory - `IUsableItem`인지 확인 후, 아이템 사용 및 결과 적용
4. Inventory - UI에 슬롯 업데이트 요청
5. InventoryUI - 슬롯 업데이트
6. ItemSlotUI - 이미지, 텍스트 업데이트

<br>

## **[3] Source Code - Inventory**

```cs
/// <summary> 해당 슬롯의 아이템 사용 </summary>
public void Use(int index)
{
    if (_items[index] == null) return;

    // 사용 가능한 아이템인 경우
    if (_items[index] is IUsableItem uItem)
    {
        // 아이템 사용
        bool succeeded = uItem.Use();

        if (succeeded)
        {
            UpdateSlot(index);
        }
    }
}
```

<br>

# 슬롯 하이라이트
---

인벤토리의 각 슬롯에 마우스를 올릴 때 반투명한 하이라이트가 나타나고, 슬롯에서 마우스를 떼면 사라지는 기능을 구현한다.

![2021_0508_Inventory_Highlight2](https://user-images.githubusercontent.com/42164422/117533106-cfb5aa80-b025-11eb-905b-295fce41c51e.gif)

<br>

## **[1] 하이라키 구성**

![image](https://user-images.githubusercontent.com/42164422/117531450-76497d80-b01d-11eb-882b-a89647d406a9.png)

하이라이트로 사용될 이미지는 반투명한 단색을 적용한다.

그리고 아이콘 이미지의 위에 나타나야 하므로, 하이라키에서 더 아래쪽에 위치시킨다.

<br>

## **[2] ItemSlotUI 클래스**

<details>
<summary markdown="span">
Fields
</summary>

```cs
[Tooltip("슬롯이 포커스될 때 나타나는 하이라이트 이미지")]
[SerializeField] private Image _highlightImage;

[Space]
[Tooltip("하이라이트 이미지 알파 값")]
[SerializeField] private float _highlightAlpha = 0.5f;

[Tooltip("하이라이트 소요 시간")]
[SerializeField] private float _highlightFadeDuration = 0.2f;

// 현재 하이라이트 알파값
private float _currentHLAlpha = 0f;
```

</details>

<br>

위와 같이 필드들을 작성하고, `_highlightImage`에는 하이라키에서 [Highlight Image]를 드래그하여 등록한다.

<br>

<details>
<summary markdown="span">
Methods
</summary>

```cs
/// <summary> 슬롯에 하이라이트 표시/해제 </summary>
public void Highlight(bool show)
{
    if (show)
        StartCoroutine(nameof(HighlightFadeInRoutine));
    else
        StartCoroutine(nameof(HighlightFadeOutRoutine));
}

/// <summary> 하이라이트 알파값 서서히 증가 </summary>
private IEnumerator HighlightFadeInRoutine()
{
    StopCoroutine(nameof(HighlightFadeOutRoutine));
    _highlightGo.SetActive(true);

    float unit = _highlightAlpha / _highlightFadeDuration;

    for (; _currentHLAlpha <= _highlightAlpha; _currentHLAlpha += unit * Time.deltaTime)
    {
        _highlightImage.color = new Color(
            _highlightImage.color.r,
            _highlightImage.color.g,
            _highlightImage.color.b,
            _currentHLAlpha
        );

        yield return null;
    }
}

/// <summary> 하이라이트 알파값 0%까지 서서히 감소 </summary>
private IEnumerator HighlightFadeOutRoutine()
{
    StopCoroutine(nameof(HighlightFadeInRoutine));

    float unit = _highlightAlpha / _highlightFadeDuration;

    for (; _currentHLAlpha >= 0f; _currentHLAlpha -= unit * Time.deltaTime)
    {
        _highlightImage.color = new Color(
            _highlightImage.color.r,
            _highlightImage.color.g,
            _highlightImage.color.b,
            _currentHLAlpha
        );

        yield return null;
    }

    _highlightGo.SetActive(false);
}
```

</details>

<br>

하이라이트 표시/해제는 코루틴을 이용한다.

`FadeIn` 코루틴은 서서히 하이라이트 이미지의 알파값을 증가시키고,

`FadeOut` 코루틴은 서서히 알파값을 감소시킨다.

<br>

## **[3] InventoryUI**

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private ItemSlotUI _pointerOverSlot; // 현재 포인터가 위치한 곳의 슬롯

private void Update()
{
    _ped.position = Input.mousePosition;

    OnPointerEnterAndExit();

    // ...
}

/// <summary> 슬롯에 포인터가 올라가는 경우, 슬롯에서 포인터가 빠져나가는 경우 </summary>
private void OnPointerEnterAndExit()
{
    // 이전 프레임의 슬롯
    var prevSlot = _pointerOverSlot;

    // 현재 프레임의 슬롯
    var curSlot = _pointerOverSlot = RaycastAndGetFirstComponent<ItemSlotUI>();

    if (prevSlot == null)
    {
        // Enter
        if (curSlot != null)
        {
            OnCurrentEnter();
        }
    }
    else
    {
        // Exit
        if (curSlot == null)
        {
            OnPrevExit();
        }

        // Change
        else if (prevSlot != curSlot)
        {
            OnPrevExit();
            OnCurrentEnter();
        }
    }

    // ===================== Local Methods ===============================
    void OnCurrentEnter()
    {
        curSlot.Highlight(true);
    }
    void OnPrevExit()
    {
        prevSlot.Highlight(false);
    }
}
```

</details>

<br>

매 프레임마다 이전 프레임에 마우스가 위치했던 슬롯, 현재 프레임에 마우스가 위치한 슬롯을 확인하여

위와 같이 하이라이트 표시/해제를 구현한다.

<br>

# 아이템 툴팁
---

인벤토리의 각 아이템에 마우스를 올릴 때 아이템 정보를 간략하게 표시하는 툴팁을 구현한다.

![2021_0508_Inventory_Tooltip](https://user-images.githubusercontent.com/42164422/117533171-54a0c400-b026-11eb-80b8-f6788f7461b5.gif)

<br>

## **[1] 툴팁 표시에 필요한 데이터**

1. 아이템 이름(string)
2. 아이템 설명(string)
3. 대상 슬롯 UI 위치, 크기 (Rect)

<br>

## **[2] 시퀀스 설계**

1. 사용자 - 슬롯에 마우스 올리기
2. InventoryUI - 해당 슬롯에 아이템이 존재하는 경우, `Inventory`에 `ItemData` 요청
3. Inventory - `InventoryUI`에 `ItemData` 전달
4. InventoryUI - `ItemTooltipUI`에 `ItemData` 및 해당 슬롯의 `Rect` 전달
5. ItemTooptipUI - 툴팁 위치 설정, 툴팁 보여주기

<br>

## **[3] 하이라키 구성**

![image](https://user-images.githubusercontent.com/42164422/117564868-351e9f80-b0e9-11eb-91d6-ebc798378bd6.png)

![image](https://user-images.githubusercontent.com/42164422/117564883-52ec0480-b0e9-11eb-8fd0-a8e2b47fc13a.png)

[Item Name Text], [Item Tooltip Text]는 `Text` 컴포넌트를 넣어주고

[Line]은 `Image` 컴포넌트로 길쭉하게 구분선을 만들어준다.

그리고 [Item Tooltip]에는 `Image` 컴포넌트로 검은색 반투명 이미지를 만들고,

새로운 스크립트 `ItemTooltipUI`를 만들어서 컴포넌트로 넣어준다.

<br>

## **[4] 구현 - ItemTooltipUI**

### **[4-1] 필드, 초기 설정**

<details>
<summary markdown="span">
ItemTooltipUI.cs - Fields
</summary>

```cs
[SerializeField]
private Text _titleText;   // 아이템 이름 텍스트

[SerializeField]
private Text _contentText; // 아이템 설명 텍스트

private RectTransform _rt;
private CanvasScaler _canvasScaler;
```

</details>

<br>

자식으로 넣은 두 텍스트를 인스펙터에서 각각 드래그하여 할당해준다.

`RectTransform`과 `CanvasScaler`는 툴팁의 위치 조정을 위해 필요하다.

<br>

<details>
<summary markdown="span">
ItemTooltipUI.cs - Methods
</summary>

```cs
private void Awake()
{
    Init();
    Hide();
}

public void Show() => gameObject.SetActive(true);
public void Hide() => gameObject.SetActive(false);

private void Init()
{
    TryGetComponent(out _rt);
    _rt.pivot = new Vector2(0f, 1f); // Left Top
    _canvasScaler = GetComponentInParent<CanvasScaler>();

    DisableAllChildrenRaycastTarget(transform);
}

/// <summary> 모든 자식 UI에 레이캐스트 타겟 해제 </summary>
private void DisableAllChildrenRaycastTarget(Transform tr)
{
    // 본인이 Graphic(UI)를 상속하면 레이캐스트 타겟 해제
    tr.TryGetComponent(out Graphic gr);
    if(gr != null)
        gr.raycastTarget = false;

    // 자식이 없으면 종료
    int childCount = tr.childCount;
    if (childCount == 0) return;

    for (int i = 0; i < childCount; i++)
    {
        DisableAllChildrenRaycastTarget(tr.GetChild(i));
    }
}
```

</details>

<br>

게임 시작 시, 피벗을 Left Top으로 설정해준다.

그리고 위처럼 메소드를 통해 자신과 모든 자식 UI들의 `raycastTarget`을 해제해준다.

하이라키에서 직접 `Image`, `Text` 컴포넌트의 `Raycast Target`을 체크 해제해도 된다.

<br>

### **[4-2] 데이터 설정**

툴팁 표시를 위한 데이터를 전달받고, 설정하는 것은 매우 간단하다.

```cs
/// <summary> 툴팁 UI에 아이템 정보 등록 </summary>
public void SetItemInfo(ItemData data)
{
    _titleText.text = data.Name;
    _contentText.text = data.Tooltip;
}
```

필요한 데이터는 `ItemData`에 모두 있으므로, 참조를 전달받아 위처럼 설정하면 된다.

<br>

## **[4-3] 위치 조정**

툴팁의 위치는 기본적으로 해당 슬롯의 우측 하단에 겹치지 않게 표시할 것이다.

이를 위해서는 슬롯의 위치와 크기가 필요하며,

슬롯의 피벗은 Left-Top으로 설정되어 있으므로

기본적으로 툴팁은 `슬롯의 위치 + Vector2(슬롯 너비, -슬롯 높이)`로 위치를 조정하면 된다.

<br>

그런데 여기서 문제점이 하나 발생한다.

해상도에 따라 UI의 실제 크기가 달라지는데, 이를 스크립트를 통해 직접 얻을 수 없다는 점이다.

따라서 이를 계산하기 위해 `CanvasScaler`의 정보가 필요하다.

![image](https://user-images.githubusercontent.com/42164422/117568320-9ac75780-b0fa-11eb-8358-d35161c3555a.png)

`CanvasScaler`의 UI Scale Mode를 `Scale With Screen Size`로 설정했을 경우,

`Reference Resolution` 값, `Match` 비율과 현재 해상도의 값에 따라 UI의 실제 크기가 달라진다.

<br>

`Match`는 `0` ~ `1` 값을 가지며,

`0`일 때는 기준 해상도와 현재 해상도의 너비 비율에 따라 `RectTransform`의 크기를 계산하고,

`1`일 때는 기준 해상도와 현재 해상도의 높이 비율에 따라 계산한다.

`0` ~ `1` 사이일 때는 너비, 높이 각각의 비율을 합산하여 결과 비율값을 계산한다.

<br>

```cs
CanvasScaler cs;
RectTransform rt;

float wRatio = Screen.width  / cs.referenceResolution.x;
float hRatio = Screen.height / cs.referenceResolution.y;

// 결과 비율값
float ratio =
    wRatio * (1f - cs.matchWidthOrHeight) +
    hRatio * (cs.matchWidthOrHeight);

// 현재 스크린에서 RectTransform의 실제 너비, 높이
float pixelWidth  = rt.rect.width  * ratio;
float pixelHeight = rt.rect.height * ratio;
```

위와 같이 기준 해상도와 현재 해상도에 따른 실제 크기 변화 비율값을 계산하고,

현재 스크린에서 실제 너비와 높이를 계산할 수 있다.

<br>

그리고 인벤토리 슬롯이 화면 우측 또는 하단에 가까이 위치한 경우,

툴팁 UI가 스크린을 벗어나 잘리는 경우도 고려해야 한다.

이를 네 가지 경우로 분리하여 작성한다.

1. 잘리지 않는 경우 - 슬롯 우측 하단에 툴팁 위치하기
2. 우측이 잘리는 경우 - 슬롯 좌측 하단
3. 하단이 잘리는 경우 - 슬롯 우측 상단
4. 우측, 하단 모두 잘리는 경우 - 슬롯 좌측 상단

<br>

<details>
<summary markdown="span">
Source Code
</summary>

```cs
/// <summary> 툴팁의 위치 조정 </summary>
public void SetRectPosition(RectTransform slotRect)
{
    // 캔버스 스케일러에 따른 해상도 대응
    float wRatio = Screen.width / _canvasScaler.referenceResolution.x;
    float hRatio = Screen.height / _canvasScaler.referenceResolution.y;
    float ratio =
        wRatio * (1f - _canvasScaler.matchWidthOrHeight) +
        hRatio * (_canvasScaler.matchWidthOrHeight);

    float slotWidth = slotRect.rect.width * ratio;
    float slotHeight = slotRect.rect.height * ratio;

    // 툴팁 초기 위치(슬롯 우하단) 설정
    _rt.position = slotRect.position + new Vector3(slotWidth, -slotHeight);
    Vector2 pos = _rt.position;

    // 툴팁의 크기
    float width = _rt.rect.width * ratio;
    float height = _rt.rect.height * ratio;

    // 우측, 하단이 잘렸는지 여부
    bool rightTruncated = pos.x + width > Screen.width;
    bool bottomTruncated = pos.y - height < 0f;

    ref bool R = ref rightTruncated;
    ref bool B = ref bottomTruncated;

    // 오른쪽만 잘림 => 슬롯의 Left Bottom 방향으로 표시
    if (R && !B)
    {
        _rt.position = new Vector2(pos.x - width - slotWidth, pos.y);
    }
    // 아래쪽만 잘림 => 슬롯의 Right Top 방향으로 표시
    else if (!R && B)
    {
        _rt.position = new Vector2(pos.x, pos.y + height + slotHeight);
    }
    // 모두 잘림 => 슬롯의 Left Top 방향으로 표시
    else if (R && B)
    {
        _rt.position = new Vector2(pos.x - width - slotWidth, pos.y + height + slotHeight);
    }
    // 잘리지 않음 => 슬롯의 Right Bottom 방향으로 표시
    // Do Nothing
}
```

</details>

<br>

## **[5] 구현 - InventoryUI**

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private void Update()
{
    _ped.position = Input.mousePosition;
    OnPointerEnterAndExit();

    ShowOrHideItemTooltip();

    OnPointerDown();
    OnPointerDrag();
    OnPointerUp();
}

/// <summary> 아이템 정보 툴팁 보여주거나 감추기 </summary>
private void ShowOrHideItemTooltip()
{
    // 마우스가 유효한 아이템 아이콘 위에 올라와 있다면 툴팁 보여주기
    bool isValid =
        _pointerOverSlot != null && _pointerOverSlot.HasItem && _pointerOverSlot.IsAccessible
        && (_pointerOverSlot != _beginDragSlot); // 드래그 시작한 슬롯이면 보여주지 않기

    if (isValid)
    {
        UpdateTooltipUI(_pointerOverSlot);
        _itemTooltip.Show();
    }
    else
        _itemTooltip.Hide();
}

/// <summary> 툴팁 UI의 슬롯 데이터 갱신 </summary>
private void UpdateTooltipUI(ItemSlotUI slot)
{
    // 툴팁 정보 갱신
    _itemTooltip.SetItemInfo(_inventory.GetItemData(slot.Index));

    // 툴팁 위치 조정
    _itemTooltip.SetRectPosition(slot.SlotRect);
}

```

</details>

<br>

인벤토리 UI에서의 구현은 간단하다.

현재 마우스가 위치한 슬롯에 아이템이 존재할 경우 툴팁 정보를 갱신하고 활성화하며,

그렇지 않다면 툴팁을 비활성화하면 된다.

<br>

# 팝업 UI 구현
---

인벤토리 시스템에서 사용할 팝업은 확인/취소(아이템 버리기), 수량 입력(아이템 나누기) 이렇게 2가지가 있으며,

`InventoryPopupUI` 클래스에서 모두 관리하도록 구현한다.

팝업 UI의 동작은 다음과 같다.

1. 사용자 - 인벤토리 UI 상호작용(버리기, 아이템 나누기)
2. `InventoryUI` - 팝업 호출 및 콜백 메소드 전달
3. `InventoryPopupUI` - 알맞은 팝업 띄우기
4. 사용자 - 팝업 UI 상호작용(수량 선택, 확인/취소 버튼 클릭)
5. `InventoryPopupUI` - 전달받은 콜백 메소드 호출 또는 종료(취소)
6. `Inventory` - 결과에 따른 아이템 정보 수정

<br>

## **[1] 하이라키 구성**

![image](https://user-images.githubusercontent.com/42164422/117660992-c456b080-b1d8-11eb-91bc-ea49d02f3c0b.png)

![image](https://user-images.githubusercontent.com/42164422/117661414-4c3cba80-b1d9-11eb-813d-e0ec470946c0.png)

위와 같은 형태로 UI를 구성하고, 팝업이 등장할 위치(인벤토리 중앙)에 미리 각 팝업 UI를 배치시켜 놓는다.

Popup panel에는 인벤토리와 동일한 크기의 반투명 이미지를 준비하고,

`Raycast Target`으로 설정하여 팝업이 띄워진 동안 인벤토리의 슬롯들을 클릭하지 못하게 막는다.

<br>

## **[2] 아이템 버리기 - 확인/취소 팝업**

아이템을 버리려고 시도할 때, 바로 아이템을 제거하지 않고 "정말로 버리시겠습니까?"와 같은 팝업을 띄운다.

<details>
<summary markdown="span">
Fields
</summary>

```cs
[Header("Confirmation Popup")]
[SerializeField] private GameObject _confirmationPopupObject;
[SerializeField] private Text   _confirmationItemNameText;
[SerializeField] private Text   _confirmationText;
[SerializeField] private Button _confirmationOkButton;     // Ok
[SerializeField] private Button _confirmationCancelButton; // Cancel

private event Action OnConfirmationOK; // 확인 버튼 누를 경우 실행할 이벤트
```

</details>

<br>

필드는 각각의 UI 요소, 확인 버튼을 누를 경우 호출될 이벤트로 구성된다.

<br>

<details>
<summary markdown="span">
Methods
</summary>

```cs
private void Awake()
{
    // 1. 확인 버튼 누를 경우 이벤트
    _confirmationOkButton.onClick.AddListener(HidePanel);
    _confirmationOkButton.onClick.AddListener(HideConfirmationPopup);
    _confirmationOkButton.onClick.AddListener(() => OnConfirmationOK?.Invoke());

    // 2. 취소 버튼 누를 경우 이벤트
    _confirmationCancelButton.onClick.AddListener(HidePanel);
    _confirmationCancelButton.onClick.AddListener(HideConfirmationPopup);
}

private void ShowPanel() => gameObject.SetActive(true);
private void HidePanel() => gameObject.SetActive(false);

private void ShowConfirmationPopup(string itemName)
{
    _confirmationItemNameText.text = itemName;
    _confirmationPopupObject.SetActive(true);
}

private void HideConfirmationPopup() => _confirmationPopupObject.SetActive(false);
private void SetConfirmationOKEvent(Action handler) => OnConfirmationOK = handler;

/// <summary> 확인/취소 팝업 띄우기 </summary>
public void OpenConfirmationPopup(Action okCallback, string itemName)
{
    ShowPanel();
    ShowConfirmationPopup(itemName);
    OnConfirmationOK = okCallback;
}
```

</details>

<br>

`InventoryUI`에서 확인/취소 팝업을 호출할 경우, 팝업 패널과 확인/취소 팝업 게임오브젝트를 활성화한다.

그리고 OK 이벤트에 전달받은 콜백 메소드를 등록한다.

팝업이 활성화된 상태에서 OK 버튼을 누르면 콜백 메소드가 등록된 이벤트가 호출되며 팝업이 비활성화되고,

Cancel 버튼을 누르면 아무런 동작을 하지 않고 팝업이 비활성화된다.

<br>

## **[3] 아이템 나누기 - 수량 입력 팝업**

<details>
<summary markdown="span">
Fields
</summary>

```cs
[Header("Amount Input Popup")]
[SerializeField] private GameObject _amountInputPopupObject;
[SerializeField] private Text       _amountInputItemNameText;
[SerializeField] private InputField _amountInputField;
[SerializeField] private Button _amountPlusButton;        // +
[SerializeField] private Button _amountMinusButton;       // -
[SerializeField] private Button _amountInputOkButton;     // Ok
[SerializeField] private Button _amountInputCancelButton; // Cancel

// 확인 버튼 눌렀을 때 동작할 이벤트
private event Action<int> OnAmountInputOK;

// 수량 입력 제한 개수
private int _maxAmount;
```

</details>

<br>

수량 입력 팝업 역시 확인 팝업과 같은 메커니즘으로 동작하지만,

콜백 메소드에 정수 타입 매개변수가 하나 추가된다.

수량 입력을 완료하고 OK 버튼을 누를 때,

사용자가 지정한 수량이 콜백 메소드의 인자로 전달되는 방식이다.

<br>

<details>
<summary markdown="span">
UI Events
</summary>

```cs
private void Awake()
{
    _amountInputOkButton.onClick.AddListener(HidePanel);
    _amountInputOkButton.onClick.AddListener(HideAmountInputPopup);
    _amountInputOkButton.onClick.AddListener(() => OnAmountInputOK?.Invoke(int.Parse(_amountInputField.text)));

    _amountInputCancelButton.onClick.AddListener(HidePanel);
    _amountInputCancelButton.onClick.AddListener(HideAmountInputPopup);

    // [-] 버튼 이벤트
    _amountMinusButton.onClick.AddListener(() =>
    {
        int.TryParse(_amountInputField.text, out int amount);
        if (amount > 1)
        {
            // Shift 누르면 10씩 감소
            int nextAmount = Input.GetKey(KeyCode.LeftShift) ? amount - 10 : amount - 1;
            if(nextAmount < 1)
                nextAmount = 1;
            _amountInputField.text = nextAmount.ToString();
        }
    });

    // [+] 버튼 이벤트
    _amountPlusButton.onClick.AddListener(() =>
    {
        int.TryParse(_amountInputField.text, out int amount);
        if (amount < _maxAmount)
        {
            // Shift 누르면 10씩 증가
            int nextAmount = Input.GetKey(KeyCode.LeftShift) ? amount + 10 : amount + 1;
            if (nextAmount > _maxAmount)
                nextAmount = _maxAmount;
            _amountInputField.text = nextAmount.ToString();
        }
    });

    // 입력 값 범위 제한
    _amountInputField.onValueChanged.AddListener(str =>
    {
        int.TryParse(str, out int amount);
        bool flag = false;

        if (amount < 1)
        {
            flag = true;
            amount = 1;
        }
        else if (amount > _maxAmount)
        {
            flag = true;
            amount = _maxAmount;
        }

        if(flag)
            _amountInputField.text = amount.ToString();
    });
}
```

</details>

<br>

OK, Cancel 버튼 클릭 이벤트는 확인 팝업과 동일하게 추가한다.

그리고 [-], [+] 버튼 이벤트, `InputField` 값 변경 이벤트를 위와 같이 등록한다.

<br>


<details>
<summary markdown="span">
Methods
</summary>

```cs
/// <summary> 수량 입력 팝업 띄우기 </summary>
public void OpenAmountInputPopup(Action<int> okCallback, int currentAmount, string itemName)
{
    _maxAmount = currentAmount - 1;
    _amountInputField.text = "1";

    ShowPanel();
    ShowAmountInputPopup(itemName);
    OnAmountInputOK = okCallback;
}

private void ShowAmountInputPopup(string itemName)
{
    _amountInputItemNameText.text = itemName;
    _amountInputPopupObject.SetActive(true);
}
```

</details>

<br>

팝업 표시 메소드 역시 확인 팝업과 유사하며,

팝업을 띄울 때 현재 아이템 개수를 전달받아 해당 개수 이상으로 선택할 수 없도록 제한한다.

<br>

## **[4] InventoryUI**

드래그 앤 드롭을 구현할 때 작성한 `OnPointerUp()` 메소드 내에서 `EndDrag()` 메소드를 호출하는 부분이 존재한다.

`EndDrag()` 메소드는 드래그 종료 시 동작할 기능을 구현하며

조건에 따라 아이템 교환 또는 이동, 수량 나누기, 버리기 동작으로 이어진다.

<br>

<details>
<summary markdown="span">
InventoryUI.cs
</summary>

```cs
private void EndDrag()
{
    ItemSlotUI endDragSlot = RaycastAndGetFirstComponent<ItemSlotUI>();

    // 아이템 슬롯끼리 아이콘 교환 또는 이동
    if (endDragSlot != null && endDragSlot.IsAccessible)
    {
        // 수량 나누기 조건
        // 1) 마우스 클릭 떼는 순간 좌측 Ctrl 또는 Shift 키 유지
        // 2) begin : 셀 수 있는 아이템 / end : 비어있는 슬롯
        // 3) begin 아이템의 수량 > 1
        bool isSeparatable =
            (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.LeftShift)) &&
            (_inventory.IsCountableItem(_beginDragSlot.Index) && !_inventory.HasItem(endDragSlot.Index));

        // true : 수량 나누기, false : 교환 또는 이동
        bool isSeparation = false;
        int currentAmount = 0;

        // 현재 개수 확인
        if (isSeparatable)
        {
            currentAmount = _inventory.GetCurrentAmount(_beginDragSlot.Index);
            if (currentAmount > 1)
            {
                isSeparation = true;
            }
        }

        // 1. 개수 나누기
        if(isSeparation)
            TrySeparateAmount(_beginDragSlot.Index, endDragSlot.Index, currentAmount);
        // 2. 교환 또는 이동
        else
            TrySwapItems(_beginDragSlot, endDragSlot);

        // 툴팁 갱신
        UpdateTooltipUI(endDragSlot);
        return;
    }

    // 버리기(커서가 UI 레이캐스트 타겟 위에 있지 않은 경우)
    if (!IsOverUI())
    {
        int index = _beginDragSlot.Index;
        string itemName = _inventory.GetItemName(index);
        int amount = _inventory.GetCurrentAmount(index);

        // 셀 수 있는 아이템의 경우, 수량 표시
        if(amount > 1)
            itemName += $" x{amount}";

        // 확인 팝업 띄우고 콜백 위임
        _popup.OpenConfirmationPopup(() => TryRemoveItem(index), itemName);
    }
}

/// <summary> UI 및 인벤토리에서 아이템 제거 </summary>
private void TryRemoveItem(int index)
{
    _inventory.Remove(index);
}

/// <summary> 셀 수 있는 아이템 개수 나누기 </summary>
private void TrySeparateAmount(int indexA, int indexB, int amount)
{
    if (indexA == indexB)
    {
        return;
    }
    string itemName = _inventory.GetItemName(indexA);

    _popup.OpenAmountInputPopup(
        amt => _inventory.SeparateAmount(indexA, indexB, amt),
        amount, itemName
    );
}
```

</details>

<br>

단순히 아이템을 제거하던 부분을 팝업 호출 및 콜백 전달로 바꾸고,

아이템 수량을 나누는 부분 역시 팝업을 호출하고 콜백 메소드를 전달하는 방식으로 구현하며

수량 나누기 기능은 셀 수 있는 아이템을 `Ctrl` 또는 `Shift` 버튼을 누른 채로 드래그했을 때 동작하도록 조건을 지정한다.

<br>

## **[5] Inventory**

<details>
<summary markdown="span">
Inventory.cs
</summary>

```cs
/// <summary> 셀 수 있는 아이템의 수량 나누기(A -> B 슬롯으로) </summary>
public void SeparateAmount(int indexA, int indexB, int amount)
{
    // amount : 나눌 목표 수량

    if(!IsValidIndex(indexA)) return;
    if(!IsValidIndex(indexB)) return;

    Item _itemA = _items[indexA];
    Item _itemB = _items[indexB];

    CountableItem _ciA = _itemA as CountableItem;

    // 조건 : A 슬롯 - 셀 수 있는 아이템 / B 슬롯 - Null
    // 조건에 맞는 경우, 복제하여 슬롯 B에 추가
    if (_ciA != null && _itemB == null)
    {
        _items[indexB] = _ciA.SeperateAndClone(amount);

        UpdateSlot(indexA, indexB);
    }
}
```

</details>

<br>

인벤토리에서 수량을 나누는 기능은 비교적 간단하다.

A 슬롯의 아이템의 수량을 나누어 B 슬롯으로 복제하며,

이때 A 슬롯 아이템의 수량을 얻어내고 `SeperateAndClone(int)` 메소드를 호출하여

사용자가 입력한 개수만큼 수량을 나누어 적용하면 된다.

그리고 두 슬롯의 UI를 갱신한다.

<br>

## **GIF**

- 아이템 버리기 팝업

![2021_0511_Inventory_RemovePopup](https://user-images.githubusercontent.com/42164422/117789477-59ae7f00-b283-11eb-989b-cb095c4b47fc.gif)

<br>

- 아이템 수량 나누기 팝업

![2021_0511_Inventory_SeparatePopup](https://user-images.githubusercontent.com/42164422/117789483-5b784280-b283-11eb-9c99-4c49ee952f0e.gif)

<br>

# 인벤토리 빈 칸 채우기(Trim)
---

![2021_0512_Inventory_Trim](https://user-images.githubusercontent.com/42164422/117974145-327dad80-b368-11eb-8b90-29d409e2209b.gif)

<br>

## **[1] 하이라키 구성**

![image](https://user-images.githubusercontent.com/42164422/117974306-62c54c00-b368-11eb-89da-9815dff3852d.png)

인벤토리 좌측 상단에 `Trim`, `Sort` 버튼을 준비한다.

<br>

## **[2] 배열 빈 칸 채우기 알고리즘**

배열의 빈 칸을 앞에서부터 채우는 아주 간단한 알고리즘이 있다.

기존 배열(A)와 크기가 동일한 빈 배열(B)을 새로 만들고,

A의 처음부터 끝까지 순회하며 null이 아닌 요소를 B 배열의 앞에서부터 차례로 넣으면 된다.

하지만 알고리즘을 실행할 때마다 새로운 배열 공간이 필요하다는 단점이 있다.

<br>

두 번째 알고리즘은 다음과 같다.

```
i 커서와 j 커서가 존재한다.
i 커서 : 가장 앞에 있는 빈칸을 찾는 커서
j 커서 : i 커서 위치에서부터 뒤로 이동하며 빈칸이 아닌 곳을 찾는 커서

i커서가 빈칸을 찾으면 j 커서는 i+1 위치부터 뒤로 이동하며 빈칸이 아닌 곳을 찾는다.
j커서가 아이템을 찾으면 아이템을 i커서 위치로 옮기고, i 커서는 i+1 위치로 이동한다.
j커서가 배열 범위를 벗어나면 종료한다.
```

두 번째 알고리즘을 이용해 인벤토리의 슬롯 빈 칸 채우기 메소드를 구현한다.

<br>

<details>
<summary markdown="span">
Inventory.cs
</summary>

```cs
/// <summary> 업데이트 할 인덱스 목록 </summary>
private HashSet<int> _indexSetForUpdate = new HashSet<int>();

public void TrimAll()
{
    _indexSetForUpdate.Clear();

    int i = -1;
    while (_items[++i] != null) ;
    int j = i;

    while (true)
    {
        while (++j < Capacity && _items[j] == null);

        if (j == Capacity)
            break;

        _indexSetForUpdate.Add(i);
        _indexSetForUpdate.Add(j);

        _items[i] = _items[j];
        _items[j] = null;
        i++;
    }

    foreach (var index in _indexSetForUpdate)
    {
        UpdateSlot(index);
    }
}
```

</details>

<br>

## **[3] InventoryUI**

```cs
[SerializeField] private Button _trimButton;
[SerializeField] private Button _sortButton;

void Awake()
{
    _trimButton.onClick.AddListener(() => _inventory.TrimAll());
    _sortButton.onClick.AddListener(() => _inventory.SortAll());
}
```

버튼 필드에 인스펙터의 버튼을 끌어 등록하고,

`onClick` 이벤트에 위처럼 메소드를 추가한다.

반드시 위와 같이 람다식으로 추가해야 한다.

<br>

# 인벤토리 정렬하기
---

![2021_0512_Inventory_Sort](https://user-images.githubusercontent.com/42164422/117974153-34e00780-b368-11eb-9ad6-4a1eb014531d.gif)

<br>

아이템 정렬은 다음 순서로 이루어진다.

1. 앞에서부터 빈 칸을 채운다(Trim 알고리즘).
2. 아이템이 존재하는 범위 내에서 가중치에 따라 아이템들을 정렬한다.

<br>

## **[1] 정렬 가중치**

아이템을 정렬할 때는 기준값 또는 우선순위가 반드시 필요하다.

이를 위해 미리 아이템의 타입에 따라 가중치 값들을 준비한다.

```cs
/// <summary> 아이템 데이터 타입별 정렬 가중치 </summary>
private readonly static Dictionary<Type, int> _sortWeightDict = new Dictionary<Type, int>
{
    { typeof(PortionItemData), 10000 },
    { typeof(WeaponItemData),  20000 },
    { typeof(ArmorItemData),   30000 },
};
```

현재 아이템의 타입은 세부적으로 소비, 무기, 방어구 아이템으로 나뉘며

각각의 타입에 따라 위와 같이 가중치를 딕셔너리를 통해 정의한다.

<br>

## **[2] Comparer**

정렬에는 `Array.Sort()` 메소드를 이용한다.

각 요소의 비교를 위해서는 `Comparison<T>` 또는 `IComparer<T>`가 필요하며,

따라서 `IComparer<T>` 구현하는 클래스를 작성하여 정렬에 사용한다.

```cs
private class ItemComparer : IComparer<Item>
{
    public int Compare(Item a, Item b)
    {
        return (a.Data.ID + _sortWeightDict[a.Data.GetType()])
             - (b.Data.ID + _sortWeightDict[b.Data.GetType()]);
    }
}
private static readonly ItemComparer _itemComparer = new ItemComparer();
```

`Compare(a,b)` 메소드는 아이템의 정렬 우선순위를 음수, 0, 양수 값으로 반환함으로써 결정한다.

예를들어 `Compare(a,b)`의 결과가 음수이면 정렬 시 a가 b보다 앞에, 양수이면 b가 a보다 앞에 위치한다는 의미이다.

여기에 위에서 정의한 정렬 가중치와 아이템 ID의 합산값을 이용해 정렬 우선순위를 결정하도록 한다.

<br>

## **[3] 메소드 작성**

```cs
/// <summary> 빈 슬롯 없이 채우면서 아이템 종류별로 정렬하기 </summary>
public void SortAll()
{
    // 1. Trim
    int i = -1;
    while (_items[++i] != null) ;
    int j = i;

    while (true)
    {
        while (++j < Capacity && _items[j] == null) ;

        if (j == Capacity)
            break;

        _items[i] = _items[j];
        _items[j] = null;
        i++;
    }

    // 2. Sort
    Array.Sort(_items, 0, i, _itemComparer);

    // 3. Update
    UpdateAllSlot();
}
```

우선 Trim 알고리즘을 통해 아이템 배열의 앞에서부터 빈 칸을 채운다.

그리고 미리 만들어놓은 Comparer 객체를 이용해 배열의 `0` ~ `i - 1` 인덱스 범위를 정렬한 뒤,

모든 슬롯을 업데이트한다.

<br>

# 아이템 필터링
---

![2021_0512_Inventory_Filter](https://user-images.githubusercontent.com/42164422/117974160-36113480-b368-11eb-969f-fcfc05b37669.gif)

아이템의 종류에 따라 슬롯 활성화/비활성화 상태를 변경할 수 있는 필터링 기능을 만든다.

UGUI의 토글, 토글 그룹을 이용해 구현한다.

<br>

## **[1] 하이라키 구성**

![image](https://user-images.githubusercontent.com/42164422/118275314-3c86e400-b501-11eb-80a5-93f9504fec3f.png)

![image](https://user-images.githubusercontent.com/42164422/118275447-62ac8400-b501-11eb-8a5d-af2f2f92dac2.png)

- **Toggle Group**
  - 컴포넌트 : `Toggle Group`

- **Toggle Filter ~ **
  - 컴포넌트 : `Image`
  - 컴포넌트 : `Toggle`
  - `Toggle` 컴포넌트의 하이라키에서 `Group` 프로퍼티에 **Toggle Group**을 드래그하여 넣는다.
  - `Toggle` 컴포넌트의 하이라키에서 `Graphic` 프로퍼티에 자식 **Toggle Mask**를 드래그하여 넣는다.

- **Text**
  - 컴포넌트 : `Text`
  - 각각 `A`, `E`, `P` 텍스트

- **Toggle Mask**
  - 컴포넌트 : `Image`
  - 토글과 크기가 같은 반투명 이미지
  - 해당 토글 버튼의 활성화 상태를 나타낸다.

<br>

## **[2] Inventory**

```cs
[Header("Filter Toggles")]
[SerializeField] private Toggle _toggleFilterAll;
[SerializeField] private Toggle _toggleFilterEquipments;
[SerializeField] private Toggle _toggleFilterPortions;
```

위의 필드들을 작성하고, 인스펙터에서 해당 토글들을 드래그하여 넣어준다.

<br>

```cs
/// <summary> 인벤토리 UI 내 아이템 필터링 옵션 </summary>
private enum FilterOption
{
    All, Equipment, Portion
}
private FilterOption _currentFilterOption = FilterOption.All;

private void Awake()
{
    // ...
    InitToggleEvents();
}

private void InitToggleEvents()
{
    _toggleFilterAll.onValueChanged.AddListener(       flag => UpdateFilter(flag, FilterOption.All));
    _toggleFilterEquipments.onValueChanged.AddListener(flag => UpdateFilter(flag, FilterOption.Equipment));
    _toggleFilterPortions.onValueChanged.AddListener(  flag => UpdateFilter(flag, FilterOption.Portion));

    // Local Method
    void UpdateFilter(bool flag, FilterOption option)
    {
        if (flag)
        {
            _currentFilterOption = option;
            UpdateAllSlotFilters();
        }
    }
}
```

`FilterOption`은 현재 필터 설정 상태를 나타낸다.

게임 시작 시 위와 같이 모든 토글의 `onValueChanged` 이벤트에 핸들러를 추가해준다.

사용자가 각 토글을 클릭하면 해당 토글이 활성화되며, `UpdateAllSlotFilters()` 메소드를 호출한다.

<br>

```cs
/// <summary> 특정 슬롯의 필터 상태 업데이트 </summary>
public void UpdateSlotFilterState(int index, ItemData itemData)
{
    bool isFiltered = true;

    // null인 슬롯은 타입 검사 없이 필터 활성화
    if(itemData != null)
        switch (_currentFilterOption)
        {
            case FilterOption.Equipment:
                isFiltered = (itemData is EquipmentItemData);
                break;

            case FilterOption.Portion:
                isFiltered = (itemData is PortionItemData);
                break;
        }

    _slotUIList[index].SetItemAccessibleState(isFiltered);
}

/// <summary> 모든 슬롯 필터 상태 업데이트 </summary>
public void UpdateAllSlotFilters()
{
    int capacity = _inventory.Capacity;

    for (int i = 0; i < capacity; i++)
    {
        ItemData data = _inventory.GetItemData(i);
        UpdateSlotFilterState(i, data);
    }
}
```

필터 상태가 변할 때, 모든 슬롯에 있는 아이템의 종류를 검사한다.

예를 들어 현재 필터 상태가 `Equipment`일 경우,

슬롯의 아이템 데이터 타입이 `EquipmentItemData`와 같거나 그 자식이면 해당 슬롯은 활성화되고

그 외의, 아이템이 존재하는 모든 슬롯은 비활성화된다.

그리고 아이템이 존재하지 않는 슬롯은 항상 활성화된다.

비활성화된 슬롯은 UI 상호작용의 대상으로 지정되지 않는다.

<br>

# Source Code
---
- [Github Link](https://github.com/rito15/UnityStudy2/tree/master/Rito/2.%20Study/2021_0307_Inventory)

# Download
---
- [2021_0514_Inventory.zip](https://github.com/rito15/Images/files/6479094/2021_0514_Inventory.zip)

