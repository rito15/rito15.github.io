# 특징

- 30가지의 GUI 요소들을 클래스화하여 사용하기 편리한 API를 제공합니다.
- 메소드 체인 방식을 통해 직관적인 스크립팅이 가능합니다.
- 그려낸 GUI 요소들의 Rect 영역을 인스펙터에서 확인하고 디버깅할 수 있습니다.
- 기존의 `EditorGUI`, `EditorGUILayout` 요소들과 함께 사용할 수 있습니다.

- 레이아웃과 색상, 각종 스타일들을 기존보다 훨씬 편리하게 지정할 수 있습니다.
- GUI 요소를 미리 객체화하여 원하는 스타일을 지정하고, 언제든 재사용할 수 있습니다.
- 미리 만들어진 17가지 색상의 테마를 사용할 수 있습니다.


<br>

# 주의사항

- EditorGUILayout.Space() 대신 RitoEditorGUI.Space()를 사용해야 합니다.


<br>

# 기존 소스코드와 비교

 ==> 작성중 : Demo_Old, Demo_New


<br>

# 테마 미리보기

 - 미리 만들어진 17가지 색상의 테마가 제공됩니다.
 - Gray(Default), Black, White, Red, Green, Blue, Pink, Magenta, Violet, Purple, Brown, Orange, Gold, Yellow, Lime, Mint, Cyan

![2021_0601_EditorGUISamples](https://user-images.githubusercontent.com/42164422/120315975-e21abf80-c317-11eb-9e42-6c65193ca672.gif)

<br>

# 사용법

## [1] 필수 설정

커스텀 에디터의 `OnInspectorGUI()` 메소드 내부에서

다음과 같이 최상단에 `RitoEditorGUI.Settings.Init()`을,

최하단에는 `RitoEditorGUI.Finalize(this)`를 작성해야 합니다.

```cs
public override void OnInspectorGUI()
{
    RitoEditorGUI.Settings.Init();

    // GUI Codes..

    RitoEditorGUI.Finalize(this);
}
```

<br>

## [2] 추가 설정

`RitoEditorGUI.Settings` 객체를 통해 다양한 기능과 설정을 사용할 수 있습니다.

메소드 체인 방식으로 `RitoEditorGUI.Settings` ~ `.Init()` 사이에 필요한 기능들을 호출합니다.

직접 지정하지 않은 기능은 기본 값으로 적용됩니다.

```cs
RitoEditorGUI.Settings
    .SetMargins(top: 12f, left: 12f, right: 20f, bottom: 16f)
    .SetLayoutControlHeight(18f, 2f)
    .SetLayoutControlXPositions(0.01f, 0.99f, 0f, 0f)
    .SetEditorBackgroundColor(Color.white)
    .ActivateRectDebugger()
    .ActivateTooltipDebugger()
    .SetDebugRectColor(Color.red)
    .SetDebugTooltipColor(Color.blue)
    .Init();
```

- **SetMargins()**
  - 커스텀 에디터 내부의 상하좌우 여백을 각각 지정할 수 있습니다.

- **SetLayoutControlHeight()**
  - 레이아웃 요소(너비, 높이, 여백(Space)을 직접 지정하지 않아도 자동으로 설정되는 요소)의<br>
    높이(기본값 : 18f), 하단 여백(기본값 : 2f)을 일괄 지정합니다.

- **SetEditorBackgroundColor()**
  - 커스텀 에디터(해당 컴포넌트 영역)의 배경 색상을 지정합니다.

- **ActivateRectDebugger()**
  - Rect Debugger 토글을 커스텀 에디터 상단에 표시합니다.

- **ActivateTooltipDebugger()**
  - Tooltip Debugger 토글을 커스텀 에디터 상단에 표시합니다.

- **SetDebugRectColor()**
  - Rect Debugger로 표시되는 영역의 색상을 지정합니다.

- **SetDebugTooltipColor()**
  - Tooltip Debugger로 표시되는 영역의 색상을 지정합니다.

<br>

## [3] GUI 클래스와 객체

`FloatField`, `Button` 등 기존 에디터 GUI의 정적 메소드로 사용하던 요소들을 클래스 타입으로 제공합니다.

따라서 해당 클래스들을 이용해 직접 객체를 만들어 사용하거나, 미리 만들어진 정적 객체들을 사용해야 합니다.

<br>

### **클래스 종류**
 - 레이블 : `Label`, `SelectableLabel`
 - 필드 : `IntField`, `LongField`, `FloatField`, `DoubleField`, `BoolField`, `StringField`, `ObjectField<T>`, `ColorField`
 - 벡터 필드 : `Vector2Field`, `Vector3Field`, `Vector4Field`, `Vector2IntField`, `Vector3IntField`
 - 슬라이더 : `IntSlider`, `FloatSlider`, `DoubleSlider`
 - 버튼 : `Button`, `ToggleButton`
 - 박스 : `Box`, `HeaderBox`, `FoldoutHeaderBox`
 - 드롭다운 : `Dropdown<T>`, `EnumDropdown`, `EnumDropdown<T>`
 - 단일 요소 : `Toggle`, `TextArea`, `ColorPicker`, `HelpBox`

<br>

### **객체 생성하기**

객체를 생성하면서 필드를 초기화하거나,

객체 생성 이후 언제든 필드의 값을 변경하여 스타일을 지정할 수 있습니다.

```cs
// 예시 : 객체 생성하며 필드 초기화하기
private Label boldRedLabel = new Label()
{
    fontStyle = FontStyle.Bold,
    textColor = Color.red,
    textAlignment = TextAnchor.MiddleCenter
};

private FloatField blueFloat = new FloatField()
{
    labelColor = Color.blue,
    inputTextColor = Color.blue,
    inputBackgroundColor = Color.white
};

// 예시 : 이미 만들어진 객체의 필드 값 수정하기
private void OnEnable()
{
    blueFloat.labelColor = Color.blue * 2f;
}
```

<br>

## [4] 그리기

GUI 요소들의 객체에 직관적인 메소드 체인 방식을 통해

값과 스타일, 레이아웃 등을 지정하고, 화면에 그려낼 수 있습니다.

<br>

### 1) 객체 참조하기(필수)

직접 생성한 객체 또는 미리 만들어진 정적 객체들을 참조합니다.

미리 만들어진 객체들은 `GUI클래스명.객체명`을 통해 참조할 수 있습니다.

- 종류 : `Default`, `Gray` `Black`, `White`, `Red`, `Green`, `Blue`, `Pink`, `Magenta`, `Violet`, `Purple`, `Brown`, `Orange`, `Gold`, `Yellow`, `Lime`, `Mint`, `Cyan`


```cs
// 1. 직접 생성한 객체 참조
boldRedLabel.~

// 2. 미리 만들어진 객체 참조
Label.Default.~
FloatField.Red.~
```

<br>

### 2) 스타일 지정하기(선택)

객체를 생성하면서 필드에 스타일을 지정하거나, 직접 필드 값을 수정할 수 있지만

메소드 체인을 이어가는 도중에도 스타일을 지정할 수 있습니다.

한번 지정한 값은 이후 계속 유지되므로 주의해야 합니다.

스타일 지정 메소드의 이름은 모두 `Set~()` 꼴로 이루어져 있습니다.

```cs
boldRedLabel
    .SetTextColor(Color.red * 0.8f) // 글자 색상 지정
    .SetFontSize(14)                // 폰트 크기 지정
```

<br>

### 3) 값 지정하기(필수)

GUI 요소들을 그리기 위해서, 해당 요소에 필요한 값을 지정해야 합니다.

공통적으로 `SetData()` 메소드를 사용하며,

GUI 요소마다 지정할 수 있는 값의 종류가 각각 다릅니다.

좌측에는 레이블, 우측에는 필드로 나뉘는 요소들의 경우

`widthThreshold` 매개변수의 값을 `0.0f` ~ `1.0f` 사이로 설정하여

레이블과 필드 영역의 너비 비율을 결정할 수 있습니다. (기본값 : 0.4f)

```cs
private float floatValue = 2f;

public override void OnInspectorGUI()
{
    //  .. Init

    Label.Default
        .SetData("Label Text") // 레이블 텍스트 지정

    FloatField.Gray
        .SetData("Float Field", floatValue) // 레이블 텍스트, 필드 값 지정

    FloatField.White
        .SetData("Float Field2", floatValue, 0.5f) // widthThreshold = 0.5f 지정

    // ..Finalize
}
```

<br>

### 4) 그리기(필수)

`Draw()` 또는 `DrawLayout()` 메소드를 통해, 지정한 영역에 GUI요소를 그릴 수 있습니다.

GUI 요소를 에디터에 그려내기 위해서는 Rect를 통해 영역을 지정해야 합니다.

하지만 x, y, width, height를 직접 알아내고 지정하는 것은 굉장히 번거로우므로

여기서는 `Draw()`를 통해 반자동적으로, `DrawLayout()`을 통해 거의 자동적으로

간편하게 영역을 지정할 수 있는 API를 제공합니다.

<br>

커스텀 에디터에서는 내부적으로 아래 방향(+y)으로 이동하는 커서가 존재합니다.

`Draw()` 또는 `DrawLayout()` 메소드를 통해 GUI요소를 그려낼 때

바로 이 커서가 현재 갖고 있는 값을 y 좌표값으로 이용하며,

`RitoEditorGUI.CurrentY` 또는 `RitoEditorGUI.Cursor`를 통해 참조할 수 있습니다.

<br>

`Draw()`를 통해 그리는 경우에는 커서가 자동으로 이동하지 않으며,

따라서 `RitoEditorGUI.Space(float)`를 통해 커서를 직접 이동시켜야 합니다.

반면에 `DrawLayout()`을 통해 그리는 경우에는

레이아웃 요소의 기본 높이(18f) + 기본 하단 여백(2f) 만큼 커서가 자동으로 이동합니다.

<br>

`Draw()` 메소드는 좌표 및 여백을 수동적으로 설정합니다.

x 좌표 시작점(좌측)과 끝점(우측)을

각각 `xLeft`, `xRight` 매개변수에 `0.0f` ~ `1.0f` 비율 값으로 지정하여 너비를 결정할 수 있습니다.

예를 들어 에디터의 전체 너비가 `430f`, 좌측 여백이 `10f`, 우측 여백이 `20f`라고 할 때

양측의 여백을 제외한 x 좌표(`10f` ~ `420f`) 내에서 `xLeft`, `xRight` 값에 따른 실제 좌표가 계산됩니다.

예를 들어 `0.0f` 값은 실제 x 좌표 `10f`, `0.5f` 값은 `210f`, `1.0f` 값은 `410f`에 해당합니다.

`xLeft`, `xRight`의 기본값은 각각 `0.0f`, `1.0f`로

에디터의 좌측 여백을 제외한 좌측 끝부터 우측 여백을 제외한 우측 끝까지 너비가 설정됩니다.

<br>

또한 `xLeftOffset`, `xRightOffset` 매개변수를 통해

지정된 `xLeft`, `xRight` 지점으로부터 비율이 아닌 픽셀값으로 오프셋을 설정하여,

픽셀 단위로 미세하게 보정할 수 있습니다.

예를 들어 에디터의 전체 너비가 `430f`, 좌측 여백이 `10f`, 우측 여백이 `20f`라고 할 때

`xLeft` = 0.0f, `xRight` = 1.0f, `xLeftOffset` = 4.0f, `xRightOffset` = -8.0f 이면

실제 x 좌표의 좌측은 10f + (0.0f * (430f - 10f - 20f)) + 4.0f = `14f`,

x 좌표의 우측은 10f + (1.0f * (430f - 10f - 20f)) - 8.0f = `402f`를 나타냅니다.

<br>

`yOffset` 매개변수는 현재 커서(`RitoEditorGUI.CurrentY`) 값에 픽셀 값을 추가적으로 더합니다.

예를 들어 현재 커서가 `120f` 지점에 위치해있을 때 `yOffset = 2f`로 지정할 경우

y좌표 120f + 2f = `122f`에 GUI요소를 그리게 됩니다.

<br>

`height` 매개변수는 GUI요소의 전체 높이를 결정합니다.

예를 들어 현재 커서가 `120f`에 위치하고 `yOffset = 2f`, `height = 20f`일 경우

GUI 요소는 y좌표 `122f`에서부터 `142f`까지 그려집니다.

<br>

- 예시

```cs
Label.Default
    .SetData("Label Text 1")
    .Draw(xLeft: 0f, xRight: 1f, yOffset: 0f, height: 20f,
          xLeftOffset: 0f, xRightOffset: 0f); // 6개의 매개변수 직접 지정

RitoEditorGUI.Space(22f); // 커서를 22f 높이만큼 아래로 이동

Label.Default
    .SetData("Label Text 2")
    .Draw(xLeft: 0f, xRight: 1f, yOffset: 0f, height: 20f);
    // 4개의 매개변수만 지정하고, 나머지 xOffset들은 0f으로 자동 지정

RitoEditorGUI.Space(22f);

Label.Default
    .SetData("Label Text 3")
    .Draw(xLeft: 0f, xRight: 1f, height: 20f);
    // 3개의 매개변수만 지정하고, yOffset은 0f으로 자동 지정

RitoEditorGUI.Space(22f);

Label.Default
    .SetData("Label Text 4")
    .Draw(xLeft: 0f, xRight: 1f);
    // 너비만 직접 지정하고, height는 레이아웃 요소 기본값(18f)으로 자동 지정

RitoEditorGUI.Space(20f);

Label.Default
    .SetData("Label Text 5")
    .Draw(height: 20f);
    // 높이만 직접 지정하고, xLeft = 0.0f, xRight = 1.0f로 자동 지정

RitoEditorGUI.Space(22f);
```

<br>

`DrawLayout()` 메소드는 GUI를 레이아웃 요소로 그려냅니다.

레이아웃 요소는 높이와 하단 여백이 자동적으로 지정된다는 특징이 있습니다.

`RitoEditorGUI.Settings.SetLayoutControlHeight()`을 통해 직접 지정하지 않은 경우,

레이아웃 요소의 기본 높이는 `18f`, 하단 여백은 `2f` 값을 가집니다.

<br>

`.DrawLayout()`을 통해 그릴 경우,

`.Draw(0.0f, 1.0f, 18f)`로 GUI 요소를 그린 뒤 `RitoEditorGUI.Space(20f)`를 호출한 것과 동일한 효과를 나타냅니다.

```cs
Label.Default
    .SetData("Label Text")
    .DrawLayout(xLeft: 0f, xRight: 1f, xLeftOffset: 0f, xRightOffset: 0f);
    // 매개변수 4개 직접 지정
    // 높이 : 18f, 하단 여백 : 2f 자동 지정

Label.Default
    .SetData("Label Text")
    .DrawLayout(xLeft: 0f, xRight: 1f);
    // 매개변수 2개 지정
    // xLeftOffset, xRightOffset 0f로 자동 지정

Label.Default
    .SetData("Label Text")
    .DrawLayout();
    // 매개변수 없이 호출
    //xLeft = 0f, xRight = 1f로 자동 지정
```

<br>

## 5) 하단 여백 설정(선택)

기존의 커스텀 에디터를 작성할 때 `EditorGUILayout.Space()`를 호출하듯이

매번 `RitoEditorGUI.Space()`를 통해 커서를 이동시켜야 한다면

굉장히 불편하고 번거로운 일입니다.

따라서 메소드 체인을 통해 간편히 커서를 이동시키는 기능을 제공합니다.

<br>

### Space(float)

`.Space(float)` 메소드는 `RitoEditorGUI.Space(float)` 메소드와 동일하게

지정한 값만큼 단순히 커서를 이동시킵니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text")
    .Draw(0f, 1f, 18f);

RitoEditorGUI.Space(20f);

// 2. 메소드 체인
Label.Default
    .SetData("Label Text")
    .Draw(0f, 1f, 18f)
    .Space(20f);
```

<br>

### Margin(float)

`.Margin(float)` 메소드는 매개변수로 하단 여백 값을 전달받아

(`Draw()`에 지정된 높이 + 하단 여백 값)만큼 커서를 이동시킵니다.

따라서 `.Margin(0f)`처럼 호출할 경우, GUI요소의 높이만큼 커서가 이동합니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f);

RitoEditorGUI.Space(18f); // 높이만큼만 이동하여 타이트하게 연결

Label.Default
    .SetData("Label Text 2")
    .Draw(0f, 1f, 18f);

RitoEditorGUI.Space(20f);

// 2. 메소드 체인
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f)
    .Margin(0f);

Label.Default
    .SetData("Label Text 2")
    .Draw(0f, 1f, 18f)
    .Margin(2f);

// 3. 메소드 체인 - 하나의 체인으로 두 개의 요소를 연이어 그리기
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f).Margin(0f)
    .SetData("Label Text 2")
    .Draw(0f, 1f, 18f).Margin(2f);
```

<br>

### Layout(float)

`.Layout()` 메소드는 `Draw()`를 통해 그려낸 요소를 마치 `DrawLayout()`으로 그려낸 것처럼

(`Draw()`에 지정된 높이 + 레이아웃 요소의 기본 하단 여백(2f))만큼 커서를 이동시킵니다.

따라서 `Draw(0f, 1f).Layout()` 또는 `Draw(18f).Layout()` 호출은

레이아웃 요소의 기본 값들을 따로 수정하지 않은 경우 `DrawLayout()`과 같은 효과를 나타냅니다.

마찬가지로, 레이아웃 기본 여백을 직접 수정하지 않은 경우 `.Layout()`은 `.Margin(2f)`와 같습니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f);

RitoEditorGUI.Space(20f);

// 2. 메소드 체인 - Margin()
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f)
    .Margin(2f);

// 3. 메소드 체인 - Layout()
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f)
    .Layout();
```

<br>

### **박스 요소 그리기**

- `Box`, `HeaderBox`, `FoldoutHeaderBox`의 `.DrawLayout()`, `.Margin()`, `Layout()` 메소드의 동작은 다른 GUI 요소들과는 조금 다릅니다.


TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO
TODO



<br>

## 6) 툴팁 설정

레이블 영역에 마우스를 올려놓으면 잠시 후 반응하여 내용을 표시하는 기본 툴팁과 달리,

GUI의 영역 내에 마우를 올리는 동안 내용을 계속 보여주는 툴팁 기능을 제공합니다.

마찬가지로 메소드 체인을 통해 아주 간편하게 등록할 수 있으며,

툴팁 영역의 너비 및 높이와 텍스트 색상, 배경 색상을 직접 지정할 수 있습니다.

```cs
Box.White
    .SetData(2f)
    .DrawLayout(3)
    .SetTooltip("BOX");
    // 툴팁 텍스트만 지정
    // 기본 너비 : 100f, 높이 : 20f,
    // 기본 텍스트 색상 : Color.white,
    // 기본 배경 색상 : Color.black (alpha : 0.5)

Label.White
    .SetData("Label")
    .DrawLayout(0f, 0.3f)
    .SetTooltip("Label", 60f, 20f);
    // 툴팁 텍스트, 너비, 높이 지정

SelectableLabel.White
    .SetData("Selectable Label")
    .DrawLayout(0f, 0.3f)
    .SetTooltip("Label 2", Color.white, Color.black);
    // 툴팁 텍스트, 텍스트 색상, 배경 색상 지정

Button.Black
    .SetData("Button")
    .DrawLayout()
    .SetTooltip("Button", Color.black, Color.white, 80f, 20f);
    // 툴팁 텍스트, 텍스트 색상, 배경 색상, 너비, 높이 지정
```

![2021_0602_Tooltips](https://user-images.githubusercontent.com/42164422/120375526-dcdc6580-c355-11eb-9930-58a1a7ed3be1.gif)

<br>

## 7) 정리


<br>

# 디버깅



<br>

# API

## **RitoEditorGUI**

## **Label**
