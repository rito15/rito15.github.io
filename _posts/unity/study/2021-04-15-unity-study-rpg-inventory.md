---
title: RPG Inventory System(RPG 게임용 인벤토리 제작하기)
author: Rito15
date: 2021-04-15 22:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 개요
---

- RPG 게임에서 사용할 수 있는 기본적인 인벤토리를 제작한다.

<br>

# 클래스 구조 설계
---

![image](https://user-images.githubusercontent.com/42164422/115534030-52263680-a2d2-11eb-8c23-4a139d5f878f.png)

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

![2021_0421_InventoryUI_Move2](https://user-images.githubusercontent.com/42164422/115679424-89a5e900-a38d-11eb-88b9-e873fa68d39d.gif)

<br>

# 아이템 드래그 앤 드롭 이동 구현
---

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

![2021_0426_InventoryDrag](https://user-images.githubusercontent.com/42164422/116001990-68195b80-a632-11eb-98a1-12410041247c.gif)

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


`ItemData` 클래스는 `ScriptableObject` 클래스를 상속하며, 아이템의 공통 데이터들을 저장한다.

그리고 이를 상속받는 하위 클래스들을 작성하고 유니티 내에서 미리 애셋을 만들어 관리한다.

![image](https://user-images.githubusercontent.com/42164422/115995280-9d638080-a615-11eb-945c-b13558c15240.png)

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

# 아이템 위치 이동 및 교환
---

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

# 아이템 추가하기
---


<br>

# 아이템 버리기
---


<br>

# 아이템 사용하기
---


<br>

# 슬롯 하이라이트
---


<br>


# 아이템 나누기
---


<br>

# 인벤토리 빈 칸 채우기(Trim)
---


<br>

# 인벤토리 정렬하기
---


<br>

# 아이템 필터링
---


<br>

# Source Code
---
- [Github Link](https://github.com/rito15/UnityStudy2/tree/master/Rito/2.%20Study/2021_0307_Inventory)


# Download
---
- 

