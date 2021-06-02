# 특징

- 인스펙터의 커스텀 에디터를 편리하게 작성하기 위한 기능들을 제공합니다.

- 30가지의 GUI 요소들을 사용하기 편리하도록 클래스화하였습니다.
- GUI 요소를 미리 객체로 생성하여 원하는 스타일을 지정하고, 언제든 재사용할 수 있습니다.
- 메소드 체인 방식을 통해 직관적인 스크립팅이 가능합니다.
- 기존의 `EditorGUI`, `EditorGUILayout` 요소들과 함께 사용할 수 있습니다.

- 레이아웃과 색상, 각종 스타일들을 기존보다 훨씬 편리하게 지정할 수 있습니다.
- 미리 만들어진 17가지 색상의 테마를 사용할 수 있습니다.
- 그려낸 GUI 요소들의 영역을 인스펙터에서 시각적으로 확인하고 디버깅할 수 있습니다.


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

## [1] 커스텀 에디터 준비

```cs
public class MyComponent : MonoBehaviour {}
```

위와 같이 `MonoBehaviour`를 상속받는 `MyComponent` 클래스가 있을 때,

이에 대한 커스텀 에디터를 다음과 같이 작성합니다.

```cs
#if UNITY_EDITOR

using UnityEditor;
using Rito.EditorUtilities;

[CustomEditor(typeof(MyComponent))]
public class MyComponentEditor : RitoEditor
{
    protected override void OnSetup(RitoEditorGUI.Setting setting)
    {
        // Settings
    }

    protected override void OnDrawInspector()
    {
        // Inspector GUI
    }
}

#endif
```

기존의 커스텀 에디터 작성 방식과 매우 유사합니다.

`CustomEditor` 애트리뷰트를 사용하는 점은 동일하며,

`Editor` 클래스 대신 `RitoEditor` 클래스를 상속받습니다.

그리고 `OnSetup()` 메소드와 `OnDrawInspector()` 메소드를 위와 같이 작성해야 하며,

`OnSetup()` 메소드에서는 필요한 설정들을,

`OnDrawInspector()` 메소드에서는 기존의 `OnInspectorGUI()` 메소드에서 작성하던 것처럼

에디터 내의 GUI 요소들을 화면에 그리는 코드를 작성합니다.

<br>

## [2] 옵션 설정

`OnSetup` 메소드 내에서 다양한 옵션들을 설정할 수 있습니다.

메소드 체인 방식을 통해 메소드 호출을 이어나갈 수 있으며,

설정하지 않은 옵션들은 기본 값으로 적용됩니다.

```cs
protected override void OnSetup(RitoEditorGUI.Setting setting)
{
    setting
        .SetMargins(top: 12f, left: 12f, right: 20f, bottom: 16f)
        .SetLayoutControlHeight(18f, 2f)
        .SetLayoutControlXPositions(0.01f, 0.99f, 0f, 0f)
        .SetEditorBackgroundColor(Color.white)
        .KeepSameViewWidth()
        .ActivateRectDebugger()
        .ActivateTooltipDebugger()
        .SetDebugRectColor(Color.red)
        .SetDebugTooltipColor(Color.blue);
}
```

- **SetMargins()**
  - 커스텀 에디터 내부의 상하좌우 여백을 각각 지정할 수 있습니다.

- **SetLayoutControlHeight()**
  - 레이아웃 요소(너비, 높이, 여백(Space)을 직접 지정하지 않아도 자동으로 설정되는 요소)의<br>
    높이(기본값 : 18f), 하단 여백(기본값 : 2f)을 일괄 지정합니다.

- **SetLayoutControlXPositions()**
  - 레이아웃 요소들의 기본 가로 너비 비율 및 오프셋을 지정합니다.

- **SetEditorBackgroundColor()**
  - 커스텀 에디터(해당 컴포넌트 영역)의 배경 색상을 지정합니다.

- **KeepSameViewWidth()**
  - 에디터 우측의 스크롤바 존재 여부 관계 없이 항상 같은 전체 너비를 유지합니다.

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

### **[3-1] 클래스 종류**
 - 레이블 : `Label`, `SelectableLabel`
 - 필드 : `IntField`, `LongField`, `FloatField`, `DoubleField`, `BoolField`, `StringField`, `ObjectField<T>`, `ColorField`
 - 벡터 필드 : `Vector2Field`, `Vector3Field`, `Vector4Field`, `Vector2IntField`, `Vector3IntField`
 - 슬라이더 : `IntSlider`, `FloatSlider`, `DoubleSlider`
 - 버튼 : `Button`, `ToggleButton`
 - 박스 : `Box`, `HeaderBox`, `FoldoutHeaderBox`
 - 드롭다운 : `Dropdown<T>`, `EnumDropdown`, `EnumDropdown<T>`
 - 단일 요소 : `Toggle`, `TextArea`, `ColorPicker`, `HelpBox`

<br>

### **[3-2] 객체 생성하기**

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

### **[3-3] 미리 만들어진 객체 참조하기**

총 30가지 GUI 클래스에는 미리 만들어진 각각 18가지의 객체들이 존재합니다.

해당 객체들의 이름은 다음과 같으며, 서로 다른 테마가 적용되어 있습니다.

- `Default`, `Gray` `Black`, `White`, `Red`, `Green`, `Blue`, `Pink`, `Magenta`, `Violet`, `Purple`, `Brown`, `Orange`, `Gold`, `Yellow`, `Lime`, `Mint`, `Cyan`


<br>

## [4] 그리기

GUI 요소들의 객체에 직관적인 메소드 체인 방식을 통해

값과 스타일, 레이아웃 등을 지정하고, 화면에 그려낼 수 있습니다.

<br>

### [4-1] 객체 참조하기(필수)

직접 생성한 객체 또는 미리 만들어진 정적 객체들을 참조합니다.

```cs
private Label boldRedLabel = new Label()
{
    fontStyle = FontStyle.Bold,
    textColor = Color.red,
    textAlignment = TextAnchor.MiddleCenter
};

protected override void OnDrawInspector()
{
    // 1. 직접 생성한 객체 참조
    boldRedLabel.~

    // 2. 미리 만들어진 객체 참조
    Label.Default.~
    FloatField.Red.~
}
```

<br>

### [4-2] 스타일 지정하기(선택)

객체를 생성하면서 필드에 스타일을 지정하거나, 직접 필드 값을 수정할 수 있지만

메소드 체인을 이어가는 도중에도 스타일을 지정할 수 있습니다.

한번 지정한 값은 이후 계속 유지되므로 주의해야 합니다.

스타일 지정 메소드의 이름은 모두 `Set~()` 꼴로 이루어져 있습니다.

```cs
boldRedLabel
    .SetTextColor(Color.red * 0.8f) // 글자 색상 지정
    .SetFontSize(14)                // 폰트 크기 지정
```

만약 지정한 스타일이 일회성으로 적용되기를 원한다면, `.Clone()` 메소드를 이용합니다.

`.Clone()` 메소드는 GUI 객체의 스타일을 그대로 복제한 새로운 인스턴스를 생성합니다.

```cs
boldRedLabel
    .Clone()
    .SetTextColor(Color.red * 0.8f)
    .SetFontSize(14)
```

<br>

### [4-3] 값 지정하기(필수)

GUI 요소들을 그리기 위해서, 해당 요소에 필요한 값을 지정해야 합니다.

공통적으로 `SetData()` 메소드를 사용하며,

GUI 요소마다 지정할 수 있는 값의 종류가 각각 다릅니다.

좌측에는 레이블, 우측에는 필드로 나뉘는 요소들의 경우

`widthThreshold` 매개변수의 값을 `0.0f` ~ `1.0f` 사이로 설정하여

레이블과 필드 영역의 너비 비율을 결정할 수 있습니다. (기본값 : 0.4f)

```cs
private float floatValue = 2f;

proteced override void OnDrawInspector()
{
    Label.Default
        .SetData("Label Text") // 레이블 텍스트 지정

    FloatField.Gray
        .SetData("Float Field", floatValue) // 레이블 텍스트, 필드 값 지정

    FloatField.White
        .SetData("Float Field2", floatValue, 0.5f) // widthThreshold = 0.5f 지정
}
```

<br>

### [4-4] 그리기(필수)

`.Draw()` 또는 `.DrawLayout()` 메소드를 통해, 지정한 영역에 GUI요소를 그릴 수 있습니다.

GUI 요소를 에디터에 그려내기 위해서는 Rect를 통해 영역을 지정해야 합니다.

하지만 x, y, width, height를 직접 알아내고 지정하는 것은 굉장히 번거로우므로

여기서는 `.Draw()`를 통해 반자동적으로, `.DrawLayout()`을 통해 거의 자동적으로

간편하게 영역을 지정할 수 있는 API를 제공합니다.

<br>

커스텀 에디터에서는 내부적으로 아래 방향(+y)으로 이동하는 커서가 존재합니다.

`.Draw()` 또는 `.DrawLayout()` 메소드를 통해 GUI요소를 그려낼 때

바로 이 커서가 현재 갖고 있는 값을 y 좌표값으로 이용하며,

`Cursor`를 통해 현재 값을 참조할 수 있습니다.

<br>

`.Draw()`를 통해 그리는 경우에는 커서가 자동으로 이동하지 않으며,

따라서 `Space(float)`를 통해 커서를 직접 이동시켜야 합니다.

반면에 `.DrawLayout()`을 통해 그리는 경우에는

레이아웃 요소의 기본 높이(18f) + 기본 하단 여백(2f) 만큼 커서가 자동으로 이동합니다.

<br>

`.Draw()` 메소드는 좌표 및 여백을 수동적으로 설정합니다.

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

`yOffset` 매개변수는 현재 커서(`CurrentY`) 값에 픽셀 값을 추가적으로 더합니다.

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

Space(22f); // 커서를 22f 높이만큼 아래로 이동

Label.Default
    .SetData("Label Text 2")
    .Draw(xLeft: 0f, xRight: 1f, yOffset: 0f, height: 20f);
    // 4개의 매개변수만 지정하고, 나머지 xOffset들은 0f으로 자동 지정

Space(22f);

Label.Default
    .SetData("Label Text 3")
    .Draw(xLeft: 0f, xRight: 1f, height: 20f);
    // 3개의 매개변수만 지정하고, yOffset은 0f으로 자동 지정

Space(22f);

Label.Default
    .SetData("Label Text 4")
    .Draw(xLeft: 0f, xRight: 1f);
    // 너비만 직접 지정하고, height는 레이아웃 요소 기본값(18f)으로 자동 지정

Space(20f);

Label.Default
    .SetData("Label Text 5")
    .Draw(height: 20f);
    // 높이만 직접 지정하고, xLeft = 0.0f, xRight = 1.0f로 자동 지정

Space(22f);
```

<br>

`.DrawLayout()` 메소드는 GUI를 레이아웃 요소로 그려냅니다.

레이아웃 요소는 높이와 하단 여백이 자동적으로 지정된다는 특징이 있습니다.

`setting.SetLayoutControlHeight()`을 통해 직접 지정하지 않은 경우,

레이아웃 요소의 기본 높이는 `18f`, 하단 여백은 `2f` 값을 가집니다.

<br>

`.DrawLayout()`을 통해 그릴 경우,

`.Draw(0.0f, 1.0f, 18f)`로 GUI 요소를 그린 뒤 `Space(20f)`를 호출한 것과 동일한 효과를 나타냅니다.

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

### [4-5] 하단 여백 설정(선택)

기존의 커스텀 에디터를 작성할 때 `EditorGUILayout.Space()`를 호출하듯이

매번 개별적으로 `Space()`를 통해 커서를 이동시켜야 한다면

굉장히 불편하고 번거로울 것입니다.

따라서 메소드 체인을 통해 간편히 커서를 이동시키는 기능을 제공합니다.

<br>

#### **Space(float)**

`.Space(float)` 메소드는 `Space(float)` 메소드와 동일하게

지정한 값만큼 단순히 커서를 이동시킵니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text")
    .Draw(0f, 1f, 18f);

Space(20f);

// 2. 메소드 체인
Label.Default
    .SetData("Label Text")
    .Draw(0f, 1f, 18f)
    .Space(20f);
```

<br>

#### **Margin(float)**

`.Margin(float)` 메소드는 매개변수로 하단 여백 값을 전달받아

(`.Draw()`에 지정된 높이 + 하단 여백 값)만큼 커서를 이동시킵니다.

따라서 `.Margin(0f)`처럼 호출할 경우, GUI요소의 높이만큼 커서가 이동합니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f);

Space(18f); // 높이만큼만 이동하여 타이트하게 연결

Label.Default
    .SetData("Label Text 2")
    .Draw(0f, 1f, 18f);

Space(20f);

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

#### **Layout(float)**

`.Layout()` 메소드는 `.Draw()`를 통해 그려낸 요소를 마치 `.DrawLayout()`으로 그려낸 것처럼

(`.Draw()`에 지정된 높이 + 레이아웃 요소의 기본 하단 여백(2f))만큼 커서를 이동시킵니다.

따라서 `.Draw(0f, 1f).Layout()` 또는 `.Draw(18f).Layout()` 호출은

레이아웃 요소의 기본 값들을 따로 수정하지 않은 경우 `.DrawLayout()`과 같은 효과를 나타냅니다.

마찬가지로, 레이아웃 기본 여백을 직접 수정하지 않은 경우 `.Layout()`은 `.Margin(2f)`와 같습니다.

```cs
// 1. 기존 방식
Label.Default
    .SetData("Label Text 1")
    .Draw(0f, 1f, 18f);

Space(20f);

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

#### **박스 요소 그리기**

- `Box`, `HeaderBox`, `FoldoutHeaderBox`의 `.DrawLayout()`, `.Margin()`, `Layout()` 메소드의 동작은 다른 GUI 요소들과는 조금 다릅니다.

<br>

**1) Box**

```cs
Box.Brown
    .SetData(2f) // 외곽선 두께 : 2f
    .Draw(0f, 1f, 0f, 42f, -2f, 2f)
    .Space(2f);

IntField.Brown
    .SetData("Int Field", 123)
    .DrawLayout();

FloatField.Brown
    .SetData("Float Field", 123f)
    .DrawLayout();
```

![image](https://user-images.githubusercontent.com/42164422/120447221-565f6c80-c3c5-11eb-81b0-62a3e1a1d908.png)

`Box.Draw()`, `.Space()` 메소드의 사용 방법은 다른 요소들과 같습니다.

하지만 `.Margin()`, `.Layout()` 메소드는 다르게 동작합니다.

다른 요소들처럼 박스도 마찬가지로,

예를 들어 `.Margin(0f)` 메소드를 호출했을 때 박스의 높이만큼 커서를 이동시킨다면

![image](https://user-images.githubusercontent.com/42164422/120448875-f10c7b00-c3c6-11eb-8341-63e6813a7557.png)

위와 같은 상황이 발생할 것입니다.

따라서 Box의 `.Margin(float)`은 `.Space(float)`와 동일하게 동작하여,

박스 상단 부분과 박스 내의 첫 요소 상단 부분 사이의 여백을 생성합니다.

`.Layout()` 역시 레이아웃 요소 기본 여백인 `2f`만큼 커서를 이동시키게 되어

`.Space(2f)` 그리고 `.Margin(2f)`와 동일한 동작을 수행합니다.

<br>

이를 기반으로, `Box.DrawLayout(int)` 메소드는 훨씬 편리한 기능을 제공합니다.

레이아웃 요소의 높이는 기본적으로 `18f`, 여백은 `2f`로 모두 동일합니다.

`Box.DrawLayout(int)` 메소드는 이런 레이아웃 요소들을 그려낼 때

편리하게 감쌀 수 있도록 작성되어,

단순히 박스 내부의 레이아웃 요소 개수만 입력하면

간편하게 요소들을 감싸는 박스를 그려줍니다.

```cs
Box.Brown
    .SetData(2f)
    .Draw(0f, 1f, 0f, 42f)
    .Space(2f);

// 위와 동일한 기능
Box.Brown
    .SetData(2f)
    .DrawLayout(2); // 박스 내부의 레이아웃 요소 : 2개
```

<br>

또한, 단순히 추가적인 하단 높이가 필요한 경우,

좌우 또는 상하 확장이 필요한 경우를 위해 추가적인 API를 제공합니다.

<br>

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2, 20f);
    // 하단 높이 20f 추가
```

![image](https://user-images.githubusercontent.com/42164422/120449165-2a92b580-c3ca-11eb-8658-217ee3d4f789.png)

<br>

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2, 12f, 4f);
    // 상하 각각 12f 확장, 좌우 4f씩 확장
```

![image](https://user-images.githubusercontent.com/42164422/120449353-4eee9200-c3ca-11eb-96de-f6c7a674ee4e.png)

<br>

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2, 20f, 12f, 8f, 4f);
    // 너비 확장 - 상 : 20f, 하 : 12f, 좌 : 8f, 우 : 4f
```

![image](https://user-images.githubusercontent.com/42164422/120449671-9ecd5900-c3ca-11eb-8e44-fb5d3ad58782.png)

<br>

**2) HeaderBox**

HeaderBox는 Box의 상단부에 헤더 부분이 존재하는 형태의 GUI를 그립니다.

`.Draw()` 메소드의 사용 방식은 동일하나,

`height` 매개변수가 `headerHeight`와 `contentHeight`로 분리되어 있다는 차이점이 있습니다.

```cs
HeaderBox.Brown
    .SetData("Header Box", 2f) // 외곽선 두께 2f
    .Draw(0f, 1f, 20f, 42f) // 헤더 부분 높이 20f, 내용 부분 높이 42f
    .Space(24f); // 헤더 20f + 외곽선 두께 2f + 내용 상단 여백 2f

IntField.Brown
    .SetData("Int Field", 123)
    .DrawLayout();

FloatField.Brown
    .SetData("Float Field", 123f)
    .DrawLayout();
```

![image](https://user-images.githubusercontent.com/42164422/120450484-71cd7600-c3cb-11eb-849c-4bbe701383bc.png)

외곽선 두께를 설정할 경우, 헤더와 내용 사이에도 동일한 두께의 구분선이 포함되므로

위와 같이 수동적으로 여백을 설정할 때 외곽선 두께를 고려해야 합니다.

<br>

HeaderBox의 `.Margin(float)`, `.Layout()` 메소드는

헤더 부분의 높이와 구분선의 두께를 미리 고려한 상태로 여백을 계산합니다.

```cs
HeaderBox.Brown
    .SetData("Header Box", 2f)
    .Draw(0f, 1f, 20f, 42f)
    .Space(24f);

HeaderBox.Brown
    .SetData("Header Box", 2f)
    .Draw(0f, 1f, 20f, 42f)
    .Margin(2f);
    // 헤더 부분 높이 20f + 외곽선 두께 2f 내부적으로 포함

HeaderBox.Brown
    .SetData("Header Box", 2f)
    .Draw(0f, 1f, 20f, 42f)
    .Layoout();
    // 헤더 부분 높이 20f + 외곽선 두께 2f + 레이아웃 요소 기본 여백 2f
```

위의 세 문장은 동일한 기능을 수행합니다.

<br>

`HeaderBox.DrawLayout(int)` 메소드 역시 Box와 마찬가지로

박스 내에 포함될 레이아웃 요소의 개수만 입력하면 내부적으로 여백을 자동으로 계산합니다.

```cs
// Draw() 사용
HeaderBox.Brown
    .SetData("Header Box", 2f)
    .Draw(0f, 1f, 20f, 42f)
    .Layoout();

// DrawLayout() 사용 : 위와 동일한 기능
HeaderBox.Brown
    .SetData("Header Box", 2f)
    .DrawLayout(2); // 컨텐츠 영역에 포함될 레이아웃 요소 개수 : 2개
```

<br>

또한, Box처럼 상하좌우 너비를 더해주는 기능도 동일하게 존재합니다.

```cs
HeaderBox.Brown
    .SetData("Header Box", 2f)
    .DrawLayout(2, 20f);
    // 컨텐츠 영역 하단 높이 20f 추가

HeaderBox.Brown
    .SetData("Header Box", 2f)
    .DrawLayout(2, 12f, 4f);
    // 컨텐츠 영역 상하 각각 12f 확장, 좌우 4f씩 확장

HeaderBox.Brown
    .SetData("Header Box", 2f)
    .DrawLayout(2, 20f, 12f, 8f, 4f);
    // 컨텐츠 영역 상, 하, 좌, 우 각각 20f, 12f, 8f, 4f 확장
```

<br>

**3) FoldoutHeaderBox**

`FoldoutHeaderBox`는 생김새가 `HeaderBox`와 동일하지만

헤더 부분을 마우스로 클릭하면 컨텐츠 부분이 접혀 사라지고,

다시 클릭하면 펼쳐져 나타나는 기능을 수행합니다.

```cs
// 펼쳐진 상태를 저장하기 위한 필드
private bool foldout = true;

protected override void OnDrawInspector()
{
    FoldoutHeaderBox.Brown
        .SetData("Foldout Header Box", foldout, 2f) // foldout 필드를 매개변수로 전달
        .DrawLayout(2)
        .GetValue(out foldout); // 펼치기, 접기 동작의 결과를 다시 foldout 필드에 저장

    // 펼쳐졌을 때만 그릴 내용들
    if (foldout)
    {
        IntField.Brown
            .SetData("Int Field", 123)
            .DrawLayout();

        FloatField.Brown
            .SetData("Float Field", 123f)
            .DrawLayout();
    }
}
```

![2021_0602_FoldoutHeaderBox](https://user-images.githubusercontent.com/42164422/120455664-ebfff980-c3cf-11eb-80a7-a20201ae0bde.gif)

<br>

`FoldoutHeaderBox`는 기본적으로 위와 같이 작성하여 사용합니다.

펼쳐진 상태를 저장하기 위해 `bool` 타입 필드가 필요하며,

값이 `true`이면 펼쳐진 상태, `false`이면 접힌 상태를 의미합니다.

`.SetData()` 메소드의 `foldout` 매개변수로 이 필드를 반드시 전달해야 하며,

마우스 클릭으로 인한 펼치기, 접기 동작의 결과를

`GetValue()` 메소드를 통해 필드에 전달받을 수 있습니다.

그리고 조건문을 이용하여 박스가 펼쳐져 있는 동안에만 그릴 요소들을

위와 같이 작성합니다.

<br>

### [4-6] 툴팁 설정(선택)

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

### [4-7] 값 참조하기(선택)

기존의 에디터 스크립팅에서는 `IntField`, `FloatField`처럼 값을 입력하는 요소의 경우에

메소드의 리턴값을 변수에 다시 전달받는 방식을 사용합니다.

```cs
// 매개변수에 floatVariable을 전달하면서, 다시 리턴 받기
floatVariable = EditorGUILayout.FloatField("Float Field", floatVariable);
```

<br>

여기서도 역시 동일한 방식을 사용하여 리턴값을 전달받을 수 있습니다.

```cs
floatVariable =
    FloatField.Brown
        .SetData("Float FIeld", floatVariable)
        .DrawLayout()
        .GetValue();
```

`.SetData()`로 값을 지정하고 `.Draw()` 또는 `.DrawLayout()`으로 그린 다음,

`.GetValue()`를 통해 해당하는 결과값을 리턴받습니다.

<br>

하지만 위 방식은 들여쓰기가 이중으로 발생하므로 가독성이 썩 좋지 않다는 단점이 있습니다.

따라서 한가지 방식을 더 제공합니다.

```cs
FloatField.Brown
    .SetData("Float FIeld", floatVariable)
    .DrawLayout()
    .GetValue(out floatVariable);
```

`.GetValue(out)` 메소드는 리턴 값을 `out` 매개변수를 통해 전달합니다.

이를 통해 가독성을 좀더 향상시킬 수 있습니다.

<br>

### [4-8] 정리

```cs
FloatField.Brown

    // 선택사항 : 스타일 지정
    .SetLabelColor(Color.red)
    .SetInputFontSize(15)

    // 필수사항 : 값 지정
    .SetData("Float FIeld", floatVariable)

    // 필수사항 : 그리기
    .Draw(0f, 1f, 18f)
    .DrawLayout()

    // 선택사항 : 여백 지정 및 커서 이동
    .Space(1f)
    .Margin(1f)
    .Layout()

    // 선택사항 : 툴팁 정보 등록
    .SetTooltip("Tooltip Text")

    // 필요한 경우 : 값 전달받기
    .GetValue(out floatVariable);
```

<br>

# 디버깅

인스펙터에서 직접 GUI 요소들의 영역과 정보를 확인할 수 있는 기능을 제공합니다.


<br>

# API

