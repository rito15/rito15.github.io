# Rito Custom Editor

- 커스텀 에디터를 편리하고 예쁘게 작성하기 위한 기능들을 제공합니다.

- 30가지 이상의 GUI 요소들을 사용하기 편리하도록 클래스화하였습니다.
- 메소드 체인 방식을 통해 직관적인 스크립팅이 가능합니다.
- 기존의 `EditorGUI`, `EditorGUILayout` 요소들과 함께 사용할 수 있습니다.

- 레이아웃과 색상, 각종 스타일들을 기존보다 훨씬 편리하게 지정할 수 있습니다.
- 미리 만들어진 17가지 색상의 테마를 사용할 수 있습니다.
- 그려낸 GUI 요소들의 영역을 인스펙터에서 시각적으로 확인하고 디버깅할 수 있습니다.

<br>

# How To Import

`[Window]` - `[Package Manager]` - `[+]` - `[Add package from git URL]` - `https://github.com/rito15/Unity-Rito-Custom-Editor.git`

<br>

# 기존 소스코드와 비교

![2021_0610_OldAndNew](https://user-images.githubusercontent.com/42164422/121400566-b4c2b700-c992-11eb-8d7e-1f8178b3a240.gif)

<br>

## [1] 기존 방식으로 작성하기

<details>
<summary markdown="span">
.
</summary>

```cs
public class Demo_Old : MonoBehaviour
{
    public string stringValue = "String Value";
    public bool foldout, toggleButtonPressed;

    public float[] floatArray = { 0.1f, 0.2f, 0.3f, 0.4f };
    public int floatSelected;

    [UnityEditor.CustomEditor(typeof(Demo_Old))]
    private class CE : Editor
    {
        private Demo_Old m;
        private string[] strFloatArray;

        private readonly Color BoxOutlineColor = Color.blue;
        private readonly Color HeaderBoxColor = Color.blue + Color.gray;
        private readonly Color ContentBoxColor = new Color(0f, 0f, 0.15f, 1f);
        private readonly Color HeaderLabelColor = new Color(0f, 0f, 0.1f, 1f);
        private readonly Color FieldBackgroundColor = new Color(1f, 1f, 4f, 1f);
        private readonly Color DropdownBackgroundColor = new Color(0.5f, 0.5f, 2f, 1f);
        private readonly Color ControlBackgroundColor = new Color(0f, 0f, 2f, 1f);

        private void OnEnable()
        {
            m = target as Demo_Old;

            strFloatArray = new string[m.floatArray.Length];
            for (int i = 0; i < m.floatArray.Length; i++)
                strFloatArray[i] = m.floatArray[i].ToString();
        }

        public override void OnInspectorGUI()
        {
            SetStyles();
            DrawControls();
            RestoreStyles();
        }

        private void DrawControls()
        {
            const float PosX = 18f; // Left Margin
            const float BoxPaddingRight = 8f;
            float viewWidth = EditorGUIUtility.currentViewWidth - PosX - 4f;
            float insideBoxWidth = viewWidth - BoxPaddingRight;

            GUILayoutOption boxViewWidthOption = GUILayout.Width(insideBoxWidth);

            // W : Width, H : Height

            const float BoxPaddingLeft = 4f;
            const float Outline = 2f;
            const float BoxX = PosX - BoxPaddingLeft;
            const float OutBoxX = BoxX - Outline;

            const float HeaderBoxH = 20f;
            float contentBoxH = m.foldout ? 64f : 0f;
            float outBoxH = HeaderBoxH + contentBoxH + Outline * (m.foldout ? 3f : 2f);

            float boxW = viewWidth;
            float outBoxW = boxW + Outline * 2f;

            const float OutBoxY = 4f;
            const float HeaderBoxY = 4f + Outline;
            const float ContentBoxY = HeaderBoxY + HeaderBoxH + Outline;

            Rect outBoxRect     = new Rect(OutBoxX, OutBoxY, outBoxW, outBoxH);
            Rect headerBoxRect  = new Rect(BoxX, HeaderBoxY, boxW, HeaderBoxH);
            Rect contentBoxRect = new Rect(BoxX, ContentBoxY, boxW, contentBoxH);
            Rect foldoutRect    = new Rect(headerBoxRect);
            foldoutRect.xMin += 12f;

            // Header Foldout
            m.foldout =
                EditorGUI.Foldout(foldoutRect, m.foldout, "", true);

            // Box
            EditorGUI.DrawRect(outBoxRect, BoxOutlineColor);
            EditorGUI.DrawRect(headerBoxRect, HeaderBoxColor);
            EditorGUI.DrawRect(contentBoxRect, ContentBoxColor);

            EditorGUILayout.Space(1f);
            EditorGUILayout.LabelField("Header Box", headerLabelStyle);

            EditorGUILayout.Space(Outline);

            if (m.foldout)
            {
                GUI.backgroundColor = FieldBackgroundColor;

                // String
                m.stringValue =
                    EditorGUILayout.TextField("String FIeld", m.stringValue, boxViewWidthOption);

                GUI.backgroundColor = DropdownBackgroundColor;

                // Dropdown
                m.floatSelected =
                    EditorGUILayout.Popup("Float Dropdown", m.floatSelected, strFloatArray, boxViewWidthOption);

                GUI.backgroundColor = ControlBackgroundColor;

                // Buttons
                using (new EditorGUILayout.HorizontalScope())
                {
                    const float buttonPart = 0.7f;

                    GUILayout.Button("Button", GUILayout.Width(insideBoxWidth * buttonPart));
                    m.toggleButtonPressed =
                        GUILayout.Toggle(m.toggleButtonPressed, "Toggle Button",
                        "Button", GUILayout.Width(insideBoxWidth * (1f - buttonPart) - 4f));
                }
            }
        }

        private GUIStyle headerLabelStyle;
        private Color oldBackgroundColor;

        private void SetStyles()
        {
            if (headerLabelStyle == null)
            {
                headerLabelStyle = new GUIStyle(GUI.skin.label);
                headerLabelStyle.normal.textColor = HeaderLabelColor;
                headerLabelStyle.fontStyle = FontStyle.Bold;
            }

            oldBackgroundColor = GUI.backgroundColor;
        }

        private void RestoreStyles()
        {
            GUI.backgroundColor = oldBackgroundColor;
        }
    }
}
```

</details>

<br>

## [2] RitoCustomEditor 사용

<details>
<summary markdown="span">
.
</summary>

```cs
public class Demo_New : MonoBehaviour
{
    public string stringValue = "String Value";
    public bool foldout, toggleButtonPressed;

    public float[] floatArray = { 0.1f, 0.2f, 0.3f, 0.4f };
    public int floatSelected;

    [UnityEditor.CustomEditor(typeof(Demo_New))]
    private class CE : RitoEditor
    {
        private Demo_New m;
        private void OnEnable() => m = target as Demo_New;

        private const float XLeft = 0.01f;
        private const float XRight = 0.985f;

        protected override void OnSetup(RitoEditorGUI.Setting setting)
        {
            setting
                .SetLayoutControlWidth(XLeft, XRight);
        }

        protected override void OnDrawInspector()
        {
            FoldoutHeaderBox.Blue
                .SetData("Header Box", m.foldout, 2f, 4f)
                .DrawLayout(3, 2f)
                .GetValue(out m.foldout);

            if (m.foldout)
            {
                StringField.Blue
                    .SetData("String Field", m.stringValue)
                    .DrawLayout().GetValue(out m.stringValue);

                Dropdown<float>.Blue
                    .SetData("Float Dropdown", m.floatArray, m.floatSelected)
                    .DrawLayout().GetValue(out m.floatSelected);

                const float buttonPart = 0.7f;

                Button.Blue
                    .SetData("Button")
                    .Draw(XLeft, buttonPart, 20f);

                ToggleButton.Blue
                    .SetData("Toggle Button", m.toggleButtonPressed)
                    .Draw(buttonPart + 0.01f, XRight, 20f).Layout()
                    .GetValue(out m.toggleButtonPressed);
            }
        }
    }
}
```

</details>

<br>

# 테마 미리보기

<details>
<summary markdown="span">
.
</summary>

 - 미리 만들어진 17가지 색상의 테마가 제공됩니다.
 - `Gray(Default)`, `Black`, `White`, `Red`, `Green`, `Blue`, `Pink`, `Magenta`, `Violet`, `Purple`, `Brown`, `Orange`, `Gold`, `Yellow`, `Lime`, `Mint`, `Cyan`

<br>

![2021_0601_EditorGUISamples](https://user-images.githubusercontent.com/42164422/120315975-e21abf80-c317-11eb-9e42-6c65193ca672.gif)

</details>

<br>

# 사용법

<details>
<summary markdown="span">
.
</summary>

- 네임스페이스 : `Rito.EditorUtilities`

<br>

## [1] 커스텀 에디터 준비

<details>
<summary markdown="span">
.
</summary>

### **[1-1] 커스텀 에디터(인스펙터)**

<details>
<summary markdown="span">
.
</summary>

```cs
public class MyComponent : MonoBehaviour {}
```

위와 같이 `MonoBehaviour`를 상속받는 `MyComponent` 클래스가 있을 때,

이에 대한 커스텀 에디터를 다음과 같이 작성합니다.

```cs
#if UNITY_EDITOR

using UnityEngine;
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

<br>

기존의 커스텀 에디터 작성 방식과 매우 유사합니다.

`CustomEditor` 애트리뷰트를 사용하는 점은 동일하며,

`Editor` 클래스 대신 `RitoEditor` 클래스를 상속받습니다.

<br>

그리고 `OnSetup()` 메소드와 `OnDrawInspector()` 메소드를 위와 같이 작성해야 하며,

`OnSetup()` 메소드에서는 필요한 설정들을,

`OnDrawInspector()` 메소드에서는 기존의 `OnInspectorGUI()` 메소드에서 작성하던 것처럼

에디터 내의 GUI 요소들을 화면에 그리는 코드를 작성합니다.

</details>

<br>

### **[1-2] 커스텀 에디터 윈도우**

<details>
<summary markdown="span">
.
</summary>

커스텀 에디터 윈도우 역시 기존의 작성 방식과 유사합니다.

`EditorWindow` 클래스 대신 `RitoEditorWindow` 클래스를 상속받아 작성합니다.

```cs
#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;
using Rito.EditorUtilities;

public class TestWindow : RitoEditorWindow
{
    [MenuItem("Test/Test")] // 메뉴 등록
    private static void Init()
    {
        // 현재 활성화된 윈도우를 가져오며, 없으면 새로 생성
        TestWindow window = (TestWindow)GetWindow(typeof(TestWindow));
        window.Show();
    }

    protected override void OnSetup(RitoEditorGUI.Setting setting)
    {
        // Settings
    }

    protected override void OnDrawGUI()
    {
        // GUI
    }
}

#endif
```

커스텀 에디터 작성 방식과 마친가지로

`OnSetup()` 메소드를 통해 필요한 설정들을 작성하고,

`OnGUI()` 메소드 대신 `OnDrawGUI()` 메소드에 GUI 코드를 작성합니다.

</details>

</details>

<br>

## [2] 옵션 설정

<details>
<summary markdown="span">
.
</summary>

`OnSetup` 메소드 내에서 다양한 옵션들을 설정할 수 있습니다.

메소드 체인 방식을 통해 메소드 호출을 이어나갈 수 있으며,

설정하지 않은 옵션들은 기본 값으로 적용됩니다.

```cs
protected override void OnSetup(RitoEditorGUI.Setting setting)
{
    setting
        .SetMargins(top: 12f, left: 12f, right: 20f, bottom: 16f)
        .SetLayoutControlHeight(18f, 2f)
        .SetLayoutControlWidth(0.01f, 0.99f, 0f, 0f)
        .SetEditorBackgroundColor(Color.white)
        .SetDefaultColorTheme(EColor.Brown)
        .KeepSameViewWidth()
        .ActivateRectDebugger()
        .ActivateTooltipDebugger()
        .SetDebugRectColor(Color.red)
        .SetDebugTooltipColor(Color.cyan);
}
```

- **SetMargins()**
  - 커스텀 에디터 내부의 상하좌우 여백을 각각 지정할 수 있습니다.

- **SetLayoutControlHeight()**
  - 레이아웃 요소(너비, 높이, 여백(Space)을 직접 지정하지 않아도 자동으로 설정되는 요소)의<br>
    높이(기본값 : 18f), 하단 여백(기본값 : 2f)을 일괄 지정합니다.

- **SetLayoutControlWidth()**
  - 레이아웃 요소들의 가로 비율 및 오프셋을 통해 기본 너비를 지정합니다.

- **SetEditorBackgroundColor()**
  - 커스텀 에디터(해당 컴포넌트 영역)의 배경 색상을 지정합니다.

- **SetDefaultColorTheme()**
  - Label.Default처럼 각 GUI 요소.Default를 참조했을 때 사용할 테마를 지정합니다.
  - 기본 테마는 `Gray`입니다.

- **KeepSameViewWidth()**
  - 에디터 우측의 스크롤바 존재 여부에 관계 없이 항상 같은 전체 너비를 유지합니다.
  - 커스텀 에디터 윈도우는 해당하지 않습니다.

- **ActivateRectDebugger()**
  - Rect Debugger 토글을 커스텀 에디터 상단에 표시합니다.

- **ActivateTooltipDebugger()**
  - Tooltip Debugger 토글을 커스텀 에디터 상단에 표시합니다.

- **SetDebugRectColor()**
  - Rect Debugger로 표시되는 영역의 색상을 지정합니다.

- **SetDebugTooltipColor()**
  - Tooltip Debugger로 표시되는 영역의 색상을 지정합니다.

</details>

<br>

## [3] GUI 클래스와 객체

<details>
<summary markdown="span">
.
</summary>

`FloatField`, `Button` 등 기존 에디터 GUI의 정적 메소드로 사용하던 요소들을 클래스 타입으로 제공합니다.

따라서 해당 클래스들을 이용해 직접 객체를 만들어 사용하거나, 미리 만들어진 정적 객체들을 사용해야 합니다.

<br>

### **[3-1] 클래스 종류**

<details>
<summary markdown="span">
.
</summary>

 - 레이블 : `Label`, `SelectableLabel`, `EditableLabel`
 - 필드 : `IntField`, `LongField`, `FloatField`, `DoubleField`, `BoolField`, `StringField`, `ObjectField<T>`, `ColorField`
 - 벡터 필드 : `Vector2Field`, `Vector3Field`, `Vector4Field`, `Vector2IntField`, `Vector3IntField`
 - 슬라이더 : `IntSlider`, `FloatSlider`, `DoubleSlider`
 - 버튼 : `Button`, `ToggleButton`
 - 박스 : `Box`, `HeaderBox`, `FoldoutHeaderBox`
 - 드롭다운 : `Dropdown<T>`, `EnumDropdown`, `EnumDropdown<T>`
 - 단일 요소 : `Toggle`, `TextArea`, `ColorPicker`, `HelpBox`

</details>

<br>

### **[3-2] 객체 생성하기**

<details>
<summary markdown="span">
.
</summary>

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

</details>

<br>

### **[3-3] 미리 만들어진 객체 참조하기**

<details>
<summary markdown="span">
.
</summary>

총 30가지 이상의 GUI 클래스에는 미리 만들어진 각각 17가지의 객체들이 존재합니다.

해당 객체들의 이름은 다음과 같으며, 서로 다른 테마가 적용되어 있습니다.

- `Gray` `Black`, `White`, `Red`, `Green`, `Blue`, `Pink`, `Magenta`, `Violet`, `Purple`, `Brown`, `Orange`, `Gold`, `Yellow`, `Lime`, `Mint`, `Cyan`

`Default`를 참조할 경우, 17가지 테마 중 현재 기본 테마로 설정된 테마의 객체를 참조합니다.

</details>

</details>

<br>

## [4] 그리기

<details>
<summary markdown="span">
.
</summary>

GUI 요소들의 객체에 메소드 체인 방식을 통해

값과 스타일, 레이아웃 등을 지정하고, 화면에 그려낼 수 있습니다.

<br>

### [4-1] 객체 참조하기(필수)

<details>
<summary markdown="span">
.
</summary>

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

</details>

### [4-2] 스타일 지정하기(선택)

<details>
<summary markdown="span">
.
</summary>

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

</details>

### [4-3] 값 지정하기(필수)

<details>
<summary markdown="span">
.
</summary>

GUI 요소들을 그리기 위해서, 해당 요소에 필요한 값을 지정해야 합니다.

공통적으로 `SetData()` 메소드를 사용하며,

GUI 요소마다 지정할 수 있는 값의 종류가 각각 다릅니다.

```cs
private float floatValue = 2f;

proteced override void OnDrawInspector()
{
    Label.Default
        .SetData("Label Text") // 레이블 텍스트 지정

    FloatField.Gray
        .SetData("Float Field", floatValue) // 레이블 텍스트, float 필드 값 지정

    FloatField.White
        .SetData("Float Field2", floatValue, 0.5f) // widthThreshold = 0.5f 지정
}
```

<br>

좌측에는 레이블, 우측에는 필드로 나뉘는 요소들의 경우

`widthThreshold` 매개변수의 값을 `0.0f` ~ `1.0f` 사이로 설정하여

레이블과 필드 영역의 너비 비율을 결정할 수 있습니다. (기본값 : 0.4f)

![image](https://user-images.githubusercontent.com/42164422/120968902-78316880-c7a4-11eb-9c7e-1c9559a3bf8b.png)

<br>

</details>

### [4-4] 툴팁 설정(선택)

<details>
<summary markdown="span">
.
</summary>

레이블 영역에 마우스를 올려놓으면 잠시 후 반응하여 내용을 표시하는 기본 툴팁과 달리,

GUI의 영역 내에 마우를 올리는 동안 내용을 계속 보여주는 툴팁 기능을 제공합니다.

마찬가지로 메소드 체인을 통해 `.SetTooltip()`을 호출하여 간편히 등록할 수 있으며,

툴팁 영역의 너비 및 높이와 텍스트 색상, 배경 색상을 직접 지정할 수 있습니다.

- 주의사항
  - 반드시 `.Draw()` 이전에 `.SetTooltip()`을 사용해야 합니다.

```cs
Box.White
    .SetData(2f)
    .SetTooltip("BOX");
    // 툴팁 텍스트만 지정
    // 기본 너비 : 100f, 높이 : 20f,
    // 기본 텍스트 색상 : Color.white,
    // 기본 배경 색상 : Color.black (alpha : 0.5)

Label.White
    .SetData("Label")
    .SetTooltip("Label", 60f, 20f);
    // 툴팁 텍스트, 너비, 높이 지정

SelectableLabel.White
    .SetData("Selectable Label")
    .SetTooltip("Label 2", Color.white, Color.black);
    // 툴팁 텍스트, 텍스트 색상, 배경 색상 지정

Button.Black
    .SetData("Button")
    .SetTooltip("Button", Color.black, Color.white, 80f, 20f);
    // 툴팁 텍스트, 텍스트 색상, 배경 색상, 너비, 높이 지정
```

![2021_0602_Tooltips](https://user-images.githubusercontent.com/42164422/120375526-dcdc6580-c355-11eb-9930-58a1a7ed3be1.gif)

<br>

</details>

### [4-5] 그리기(필수)

<details>
<summary markdown="span">
.
</summary>

`.Draw()` 또는 `.DrawLayout()` 메소드를 통해, 지정한 영역에 GUI요소를 그릴 수 있습니다.

GUI 요소를 에디터에 그려내기 위해서는 Rect를 통해 영역을 지정해야 합니다.

하지만 x, y, width, height를 직접 알아내고 지정하는 것은 굉장히 번거로우므로

여기서는 `.Draw()`를 통해 반자동적으로, `.DrawLayout()`을 통해 거의 자동적으로

간편하게 영역을 지정할 수 있는 API를 제공합니다.

<br>

#### **Cursor**

커스텀 에디터에서는 내부적으로 아래 방향(+y)으로 이동하는 커서가 존재합니다.

`.Draw()` 또는 `.DrawLayout()` 메소드를 통해 GUI요소를 그려낼 때

바로 이 커서가 현재 갖고 있는 값을 y 좌표값으로 이용하며,

`Cursor`를 통해 현재 값을 참조할 수 있습니다.

<br>

#### **Draw()**

`.Draw()`를 통해 그리는 경우에는 커서가 자동으로 이동하지 않으며,

따라서 `Space(float)`를 통해 커서를 직접 이동시켜야 합니다.

반면에 `.DrawLayout()`을 통해 그리는 경우에는

레이아웃 요소의 기본 높이(18f) + 기본 하단 여백(2f) 만큼 커서가 자동으로 이동합니다.

<br>

#### **xLeft, xRight**

`.Draw()` 메소드는 좌표 및 여백을 수동적으로 설정합니다.

x 좌표 시작점(좌측)과 끝점(우측)을

각각 `xLeft`, `xRight` 매개변수에 `0.0f` ~ `1.0f` 비율 값으로 지정하여 너비를 결정할 수 있습니다.

예를 들어 에디터의 전체 너비가 `430f`, 좌측 여백이 `10f`, 우측 여백이 `20f`라고 할 때

양측의 여백을 제외한 x 좌표(`10f` ~ `420f`) 내에서 `xLeft`, `xRight` 값에 따른 실제 좌표가 계산됩니다.

예를 들어 `0.0f` 값은 실제 x 좌표 `10f`, `0.5f` 값은 `210f`, `1.0f` 값은 `410f`에 해당합니다.

`xLeft`, `xRight`의 기본값은 각각 `0.0f`, `1.0f`로

에디터의 좌측 여백을 제외한 좌측 끝부터 우측 여백을 제외한 우측 끝까지 너비가 설정됩니다.

<br>

#### **xLeftOffset, xRightOffset**

또한 `xLeftOffset`, `xRightOffset` 매개변수를 통해

지정된 `xLeft`, `xRight` 지점으로부터 비율이 아닌 픽셀값으로 오프셋을 설정하여,

픽셀 단위로 미세하게 보정할 수 있습니다.

예를 들어 에디터의 전체 너비가 `430f`, 좌측 여백이 `10f`, 우측 여백이 `20f`라고 할 때

`xLeft` = 0.0f, `xRight` = 1.0f, `xLeftOffset` = 4.0f, `xRightOffset` = -8.0f 이면

실제 x 좌표의 좌측은 10f + (0.0f * (430f - 10f - 20f)) + 4.0f = `14f`,

x 좌표의 우측은 10f + (1.0f * (430f - 10f - 20f)) - 8.0f = `402f`를 나타냅니다.

<br>

#### **yOffset**

`yOffset` 매개변수는 현재 커서(`CurrentY`) 값에 픽셀 값을 추가적으로 더합니다.

예를 들어 현재 커서가 `120f` 지점에 위치해있을 때 `yOffset = 2f`로 지정할 경우

y좌표 120f + 2f = `122f`에 GUI요소를 그리게 됩니다.

<br>

#### **height**

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

![image](https://user-images.githubusercontent.com/42164422/120970415-5f29b700-c7a6-11eb-9ca5-033fe9220248.png)

<br>

#### **DrawLayout()**

`.DrawLayout()` 메소드는 GUI를 레이아웃 요소로 그려냅니다.

레이아웃 요소는 높이와 하단 여백이 자동으로 지정된다는 특징이 있습니다.

레이아웃 요소의 기본 높이는 `18f`, 하단 여백은 `2f` 값을 가지며,

`setting.SetLayoutControlHeight()`를 통해 값을 바꿀 수 있습니다.

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

![image](https://user-images.githubusercontent.com/42164422/120970758-cf383d00-c7a6-11eb-99b1-21e0b4758488.png)

<br>

</details>

### [4-6] 하단 여백 설정 및 커서 이동(선택)

<details>
<summary markdown="span">
.
</summary>

기존의 커스텀 에디터를 작성할 때 `EditorGUILayout.Space()`를 호출하듯이

매번 개별적으로 `Space()`를 통해 커서를 이동시켜야 한다면,

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

![image](https://user-images.githubusercontent.com/42164422/120970970-145c6f00-c7a7-11eb-9b4b-d1f6a2433017.png)

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

![image](https://user-images.githubusercontent.com/42164422/120971118-3e159600-c7a7-11eb-9e83-32820d0eebf0.png)


<br>

#### **Layout(float)**

`.Layout()` 메소드는 `.Draw()`를 통해 그려낸 요소를 마치 `.DrawLayout()`으로 그려낸 것처럼

(`.Draw()`에 지정된 높이 + 레이아웃 요소의 기본 하단 여백(2f)) 만큼 커서를 이동시킵니다.

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
    .SetData("Label Text 2")
    .Draw(0f, 1f, 18f)
    .Margin(2f);

// 3. 메소드 체인 - Layout()
Label.Default
    .SetData("Label Text 3")
    .Draw(0f, 1f, 18f)
    .Layout();
```

![image](https://user-images.githubusercontent.com/42164422/120971409-8cc33000-c7a7-11eb-8d01-d0474bd6a258.png)

<br>

</details>

### **참고 : 박스 요소 그리기**

<details>
<summary markdown="span">
.
</summary>

- `Box`, `HeaderBox`, `FoldoutHeaderBox`의 `.DrawLayout()`, `.Margin()`, `Layout()` 메소드의 동작은 다른 GUI 요소들과는 조금 다릅니다.

<br>

#### **1) Box**

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

이를 이용해 실제로 작성한다면 다음과 같습니다.

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2);

IntField.Brown
    .SetData("Int Field", 123)
    .DrawLayout();

FloatField.Brown
    .SetData("Float FIeld", 123f)
    .DrawLayout();
```

![image](https://user-images.githubusercontent.com/42164422/120972136-64880100-c7a8-11eb-888d-08260e107e21.png)

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

![image](https://user-images.githubusercontent.com/42164422/120972278-8b463780-c7a8-11eb-8890-3ea8afe2c7a8.png)

<br>

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2, 12f, 4f);
    // 상하 각각 12f 확장, 좌우 4f씩 확장
```

![image](https://user-images.githubusercontent.com/42164422/120972392-aadd6000-c7a8-11eb-8673-33558891a220.png)

<br>

```cs
Box.Brown
    .SetData(2f)
    .DrawLayout(2, 20f, 12f, 8f, 4f);
    // 너비 확장 - 상 : 20f, 하 : 12f, 좌 : 8f, 우 : 4f
```

![image](https://user-images.githubusercontent.com/42164422/120972498-c3e61100-c7a8-11eb-9df7-cdd1e3c097d6.png)

<br>

#### **2) HeaderBox**

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

![image](https://user-images.githubusercontent.com/42164422/120972620-e37d3980-c7a8-11eb-964c-62d081518287.png)

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

#### **3) FoldoutHeaderBox**

`FoldoutHeaderBox`는 생김새가 `HeaderBox`와 동일하지만

헤더 부분을 마우스로 클릭하면 컨텐츠 부분이 접혀 사라지고,

다시 클릭하면 펼쳐져 나타나는 동작을 수행합니다.

```cs
// 펼쳐진 상태를 저장하기 위한 필드
private bool foldout = true;

protected override void OnSetup(RitoEditorGUI.Setting setting)
{
    setting
        .SetLayoutControlWidth(0.01f, 0.985f);
}

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

</details>

### [4-7] 값 참조하기(선택)

<details>
<summary markdown="span">
.
</summary>

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

</details>

### [4-8] 변화 감지하기(선택)

<details>
<summary markdown="span">
.
</summary>

#### **1) GetChangeState(out bool variable)**

기존의 커스텀 에디터에서는 `BeginChangeCheck`, `EndChangeCheck`를 통해 GUI의 변화 여부를 감지할 수 있습니다.

여기서는 더 간편한 방식으로 변화 여부를 감지할 수 있도록 메소드를 제공합니다.

```cs
FloatField.Brown
    .SetData("Float Field", floatVariable)
    .DrawLayout()
    .GetValue(out floatVariable)
    .GetChangeState(out bool isChanged); // 변화 여부 감지

if(isChanged)
    Debug.Log("Changed");
```

`.GetValue(out)`을 통해 값을 가져오는 것처럼,

`.GetChangeState(out bool)` 메소드를 통해 변화 여부를 bool 타입으로 간단히 가져올 수 있습니다.

`Label`, `Box`처럼 항상 변화가 없이 일정한 GUI 요소에 대해서는 동작하지 않습니다.

<br>

#### **2) OnValueChanged(Action&lt;T&gt; action)**

값이 변화할 때 수행할 동작을 등록하는 메소드도 제공합니다.

```cs
FloatField.Brown
    .SetData("Float Field", floatVariable)
    .DrawLayout()
    .GetValue(out floatVariable)
    .OnValueChanged(v => Debug.Log(v)); // 값 변화 시 동작
```

위 코드의 경우, 입력 값이 변화할 때마다 `Debug.Log(입력값)`이 호출되어

콘솔 창에 현재 값을 출력합니다.

<br>

</details>

### [4-9] 정리

```cs
// * 객체 참조 : 직접 생성한 객체 또는 미리 만들어진 테마 객체
FloatField.Brown

    // 선택사항 : 스타일 지정
    .SetLabelColor(Color.red)
    .SetInputFontSize(15)
    .Set~()

    // * 필수사항 : 값 지정
    .SetData("Float Field", floatVariable)

    // 선택사항 : 툴팁 정보 등록
    .SetTooltip("Tooltip Text")

    // * 필수사항 : 그리기
    .Draw(0f, 1f, 18f)
    .DrawLayout()

    // 선택사항 : 여백 지정 및 커서 이동
    .Space(1f)
    .Margin(1f)
    .Layout()

    // * 필요한 경우 : 값 전달받기
    .GetValue(out floatVariable)

    // 선택사항 : 값 변화 감지
    .GetValueChanged(out bool isChanged)
    .OnValueChanged(v => Debug.Log(v))
    ;
```

</details>

</details>

<br>

<br>

# 디버깅

<details>
<summary markdown="span">
.
</summary>

인스펙터에서 직접 GUI 요소들의 영역과 정보를 확인할 수 있는 기능을 제공합니다.

디버깅을 위해서는 `OnSetup()` 메소드 내에서 다음과 같이 옵션을 활성화해야 합니다.

```cs
protected override void OnSetup(RitoEditorGUI.Setting setting)
{
    setting
        .ActivateRectDebugger()            // Rect Debugger 활성화
        .ActivateTooltipDebugger()         // Tooltip Debugger 활성화
        .SetDebugRectColor(Color.red)      // Rect Debugger 색상 설정(선택사항)
        .SetDebugTooltipColor(Color.cyan); // Tooltip Debugger 색상 설정(선택사항)
}
```

<br>

## **[1] Rect Debugger**

<details>
<summary markdown="span">
.
</summary>

`setting.ActivateRectDebugger()` 설정을 통해 활성화할 경우,

아래와 같이 에디터 영역 상단에 토글이 나타납니다.

![image](https://user-images.githubusercontent.com/42164422/120636119-348ae600-c4a8-11eb-939b-5ca4c5da2544.png)

토글에 체크하면 모든 GUI 요소의 영역을 개별적인 Wire Rect 형태로 표시하고,

가장자리의 여백 영역을 반투명한 Rect로 나타냅니다.

![image](https://user-images.githubusercontent.com/42164422/120636402-921f3280-c4a8-11eb-9097-04afde97b7a7.png)

`setting.SetDebugRectColor()` 설정을 통해 색상을 변경할 수 있습니다.

</details>

<br>

## **[2] Tooltip Debugger**

<details>
<summary markdown="span">
.
</summary>

`setting.ActivateTooltipDebugger()` 설정을 통해 활성화할 경우,

마찬가지로 에디터 영역 상단에 토글이 표시됩니다.

![image](https://user-images.githubusercontent.com/42164422/120637026-5b95e780-c4a9-11eb-8fec-835f41777d44.png)

토글에 체크한 상태에서 각 GUI 요소 위에 마우스 커서를 올리게 되면

![image](https://user-images.githubusercontent.com/42164422/120637273-a879be00-c4a9-11eb-8e2a-4fcd1e438b96.png)

해당 요소의 Rect에 대한 정보가 툴팁으로 표시됩니다.

<br>

`xMin`, `xMax`, `yMin`, `yMax`는 각각 Rect의 꼭짓점 좌표를 나타내며,

`Width`, `Height`는 각각 너비와 높이의 픽셀값을 나타냅니다.

괄호 내의 숫자는 여백을 제외한 영역 내에서의 비율 값을 의미합니다.

<br>

위의 예시에서 좌측 여백은 `18px`, 우측 여백은 `8px`, 총 너비는 `400px`이며

따라서 여백을 제외한 가로 영역은 `18px` ~ `392px` 입니다.

`xMin : 18 (0.000)`은 x좌표가 `18px`인 지점이

여백을 제외한 가로 영역 내에서 가장 좌측에 위치해 있다는 것을 의미합니다.

<br>

마찬가지로 상단 여백은 `8px`, 하단 여백은 `10px`, 전체 높이는 `64px`이고

여백을 제외한 세로 영역은 `8px` ~ `54px`이며,

여백을 제외한 총 높이는 `44px`입니다.

<br>

`yMin : 8 (0.000)`은 y좌표가 `8px`인 지점이

여백을 제외한 세로 영역 내에서 가장 상단에 위치해 있다는 것을 의미합니다.

그리고 `yMax : 26 (0.391)`은 `8px ~ 54px` 범위에서 `26px`인 지점이 갖는 비율이

(26 - 8) / (54 - 8) = `0.391`이라는 것을 나타내며,

`Height : 18 (0.391)`은 여백을 제외한 전체 높이 `46px` 내에서 `18px`가 갖는 비율이

18 / 46 = `0.391`이라는 것을 의미합니다.

<br>

![image](https://user-images.githubusercontent.com/42164422/120638939-c3e5c880-c4ab-11eb-96f5-3ad6a20311a5.png)

위와 같이 여백 영역에 커서를 위치할 경우, 해당 여백에 대한 정보를 표시합니다.

</details>

</details>

<br>

<br>

# API

<details>
<summary markdown="span">
.
</summary>

## **RitoEditor**, **RitoEditorWindow**

<details>
<summary markdown="span">
.
</summary>

### **프로퍼티**
  - `float Cursor` : 현재 커서의 위치를 참조합니다.

### **메소드**
- `Space(float height)`
  - 커서를 하단으로 지정한 높이만큼 이동시킵니다.

<br>

</details>

## **GUIElement** 공통

<details>
<summary markdown="span">
.
</summary>

### **메소드**

#### **Clone()**
  - 스타일을 유지한 채로 객체를 복제합니다.

#### **SetTooltip(string text, float width, float height)**
  - 마우스를 올리면 표시할 툴팁 텍스트와 툴팁의 너비, 높이를 지정합니다.
  - 텍스트의 색상은 흰색, 배경 색상은 반투명한 검정색으로 지정됩니다.
  - `.Draw()` 이전에 호출해야 합니다.

#### **SetTooltip(string text, float width, float height, Color textColor, Color backgroundColor)**
  - 텍스트의 색상과 배경 색상까지 직접 지정합니다.

#### **SetTooltip(string text, Color textColor, Color backgroundColor, float width, float height)**
  - 텍스트의 색상과 배경 색상까지 직접 지정합니다.

#### **Draw(float height)**
  - 높이를 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.

#### **Draw(float xLeft, float xRight)**
  - rect의 좌측, 우측 지점 비율을 지정하여 그립니다.
  - 높이는 레이아웃 요소 기본 높이(18f)로 자동 지정됩니다.

#### **Draw(float xLeft, float xRight, float height)**
  - 좌우 비율, 높이를 지정하여 그립니다.

#### **Draw(float xLeft, float xRight, float yOffset, float height, float xLeftOffset, float xRightOffset)**
  - 좌우 비율, y축 시작 좌표, 높이를 지정하여 그립니다.
  - 좌측 및 우측 지점의 위치를 각각 `xLeftOffset`, `xRightOffset`을 통해 픽셀값으로 보정할 수 있습니다.

#### **Space(float height)**
  - 커서를 height만큼 하단으로 이동합니다.

#### **Margin(float height)**
  - 커서를 (GUI 요소의 높이 + height)만큼 하단으로 이동합니다.

#### **Layout()**
  - 커서를 (GUI 요소의 높이 + 레이아웃 요소 기본 여백(2f))만큼 하단으로 이동합니다.

#### **DrawLayout()**
  - 너비, 높이를 자동으로 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.
  - 높이는 레이아웃 요소 기본 높이(18f)로 자동 지정됩니다.
  - 그려진 높이 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

#### **DrawLayout(float xLeft, float xRight)**
  - rect의 좌측, 우측 지점 비율을 지정하여 그립니다.
  - 높이는 레이아웃 요소 기본 높이(18f)로 자동 지정됩니다.
  - 그려진 높이 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

#### **DrawLayout(float xLeft, float xRight, float xLeftOffset, float xRightOffset)**
  - rect의 좌측, 우측 지점 비율을 지정하여 그립니다.
  - 좌측 및 우측 지점의 위치를 각각 `xLeftOffset`, `xRightOffset`을 통해 픽셀값으로 보정할 수 있습니다.
  - 높이는 레이아웃 요소 기본 높이(18f)로 자동 지정됩니다.
  - 그려진 높이 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

#### **Set~()**
  - 특정 필드의 스타일을 지정하는 메소드입니다.
  - 각 메소드의 이름은 `Set`으로 시작하며, 각 스타일의 필드와 동일한 이름으로 이어집니다.
  - 해당 GUI 요소의 필드 개수만큼 존재합니다.

#### **GetValue()**
  - 값이 존재하는 GUI 요소의 경우에만 해당합니다.<br>
    (`Box`, `HeaderBox`, `HelpBox` 제외)
  - 현재 입력 값을 반환합니다.
  - 반환 타입은 각 GUI 요소의 입력 값에 따라 결정됩니다.
  - 값의 입력이 없는 는 항상 false를 반환합니다.

#### **GetValue(out T variable)**
  - 값이 존재하는 GUI 요소의 경우에만 해당합니다.
  - 현재 입력 값을 매개변수 variable에 전달합니다.
  - T 타입은 각 GUI 요소의 입력 값에 따라 결정됩니다.

#### **GetChangeState(out bool variable)**
  - 입력된 값이 여부를 `variable` 변수에 전달합니다.
  - 입력 값이 없는 `Label`, `SelectableLabel`, `Box`, `HeaderBox`, `HelpBox`는 항상 false를 반환합니다.

#### **OnValueChanged(Action&lt;T&gt; action)**
  - 입력된 값이 변화했을 때의 동작을 등록합니다.

<br>

</details>

## **Label**

<details>
<summary markdown="span">
.
</summary>

- 레이블 텍스트를 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120794438-34a3e800-c573-11eb-9d6f-1a276a4fdd1a.png)

```cs
Label.Default
    .SetData("Label")
    .DrawLayout();
```

<br>

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|TextAnchor|textAlignment|텍스트 정렬|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일(굵게, 기울임)|

### **메소드**

- **SetData(string text)**
  - 레이블 텍스트를 지정합니다.

<br>

</details>

## **SelectableLabel**

<details>
<summary markdown="span">
.
</summary>

- 드래그할 수 있는 레이블 텍스트를 표시합니다.

![2021_0604_SelectableLabel](https://user-images.githubusercontent.com/42164422/120794879-bf84e280-c573-11eb-86a3-203ef0d46bbc.gif)

```cs
SelectableLabel.Default
    .SetData("Selectable Label")
    .DrawLayout();
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|TextAnchor|textAlignment|텍스트 정렬|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일(굵게, 기울임)|

### **메소드**

- **SetData(string text)**
  - 레이블 텍스트를 지정합니다.

<br>

</details>

## **EditableLabel**

<details>
<summary markdown="span">
.
</summary>

- 편집할 수 있는 레이블 텍스트를 표시합니다.

![2021_0607_EditableLabel](https://user-images.githubusercontent.com/42164422/120985646-c6e7fe00-c7b6-11eb-95bd-899ba5271a3f.gif)

```cs
//private string editableLabel = "Editable Label";

EditableLabel.Default
    .SetData(editableLabel)
    .DrawLayout()
    .GetValue(out editableLabel);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|TextAnchor|textAlignment|텍스트 정렬|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일(굵게, 기울임)|

### **메소드**

- **SetData(string text)**
  - 레이블 텍스트를 지정합니다.

<br>

</details>

## **IntField**

<details>
<summary markdown="span">
.
</summary>

- int 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120986820-f2b7b380-c7b7-11eb-922a-f1b5ed3effe1.png)

```cs
//private int intValue = 123;

IntField.Default
    .SetData("Int Field", intValue)
    .DrawLayout()
    .GetValue(out intValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, int value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **LongField**

<details>
<summary markdown="span">
.
</summary>

- long 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120986812-f0edf000-c7b7-11eb-85ce-5b24432280e7.png)

```cs
//private long longValue = 123;

LongField.Default
    .SetData("Long Field", longValue)
    .DrawLayout()
    .GetValue(out longValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, long value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **FloatField**

<details>
<summary markdown="span">
.
</summary>

- float 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120986805-ee8b9600-c7b7-11eb-9482-ddc3ea6c01a1.png)

```cs
//private float floatValue = 123f;

FloatField.Default
    .SetData("Float Field", floatValue)
    .DrawLayout()
    .GetValue(out floatValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, float value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **DoubleField**

<details>
<summary markdown="span">
.
</summary>

- double 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120986790-eaf80f00-c7b7-11eb-80ad-44ec653ddf3e.png)

```cs
//private double doubleValue = 123.0;

DoubleField.Default
    .SetData("Double Field", doubleValue)
    .DrawLayout()
    .GetValue(out doubleValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, double value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **StringField**

<details>
<summary markdown="span">
.
</summary>

- string 타입 필드를 레이블과 함께 표시합니다.

![2021_0607_StringField](https://user-images.githubusercontent.com/42164422/120990253-51326100-c7bb-11eb-9b0b-5b1f76bab304.gif)

```cs
//private string stringValue = "abcde";
//private string stringValue2 = "";

StringField.Default
    .SetData("String Field", stringValue)
    .DrawLayout()
    .GetValue(out stringValue);

StringField.Default
    .SetData("String Field", stringValue2, "placeholder")
    .DrawLayout()
    .GetValue(out stringValue2);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, string value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

- **SetData(string label, string value, string placeholder, float widthThreshold)**
  - placeholder : 필드에 값이 존재하지 않을 경우 표시할 텍스트를 지정합니다.

<br>

</details>

## **Vector2Field**

<details>
<summary markdown="span">
.
</summary>

- Vector2 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120994425-6c9f6b00-c7bf-11eb-978f-da9ef36a46ec.png)

```cs
//private Vector2 vector2Value = new Vector2(1f, 2f);

Vector2Field.Default
    .SetData("Vector2 Field", vector2Value)
    .DrawLayout()
    .GetValue(out vector2Value);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Vector2 value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **Vector3Field**

<details>
<summary markdown="span">
.
</summary>

- Vector3 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120994442-71fcb580-c7bf-11eb-92b3-a2a672f08227.png)

```cs
//private Vector3 vector3Value = new Vector3(1f, 2f, 3f);

Vector3Field.Default
    .SetData("Vector3 Field", vector3Value)
    .DrawLayout()
    .GetValue(out vector3Value);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Vector3 value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **Vector4Field**

<details>
<summary markdown="span">
.
</summary>

- Vector4 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120994465-788b2d00-c7bf-11eb-897b-f30feb9d9498.png)

```cs
//private Vector4 vector4Value = new Vector4(1f, 2f, 3f, 4f);

Vector4Field.Default
    .SetData("Vector4 Field", vector4Value)
    .DrawLayout()
    .GetValue(out vector4Value);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Vector4 value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **Vector2IntField**

<details>
<summary markdown="span">
.
</summary>

- Vector2Int 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120994516-8345c200-c7bf-11eb-885b-672b6a35414d.png)

```cs
//private Vector2Int vector2IntValue = new Vector2Int(1, 2);

Vector2IntField.Default
    .SetData("Vector2Int Field", vector2IntValue)
    .DrawLayout()
    .GetValue(out vector2IntValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Vector2Int value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **Vector3IntField**

<details>
<summary markdown="span">
.
</summary>

- Vector3Int 타입 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/120994558-8c369380-c7bf-11eb-964f-a0d4a9ecbf6a.png)

```cs
//private Vector3Int vector3IntValue = new Vector3Int(1, 2, 3);

Vector3IntField.Default
    .SetData("Vector3Int Field", vector3IntValue)
    .DrawLayout()
    .GetValue(out vector3IntValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Vector3Int value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **ObjectField&lt;T&gt;**

<details>
<summary markdown="span">
.
</summary>

- UnityEngine.Object 타입을 상속받는 타입의 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121003793-e1c36e00-c7c8-11eb-9b20-ee27effcbcc0.png)

```cs
//private UnityEngine.Object obj;
//private Material mat;

ObjectField<UnityEngine.Object>.Default
    .SetData("Object Field", obj)
    .DrawLayout()
    .GetValue(out obj);

ObjectField<Material>.Default
    .SetData("Material Field", mat)
    .DrawLayout()
    .GetValue(out mat);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, T value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - T : 제네릭으로 지정한 타입 (UnityEngine.Object을 상속하는 타입)
  - label : 좌측 레이블 텍스트
  - value : 우측의 입력 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 입력 필드의 너비 비율(기본값 : 0.4f)

- **SetData(string label, T value, bool allowSceneObjects, float widthThreshold)**
  - allowSceneObjects : 씬에 존재하는 오브젝트를 필드의 값으로 사용할 수 있는지 여부를 결정합니다. (기본값 : true)

<br>

</details>

## **BoolField**

<details>
<summary markdown="span">
.
</summary>

- 토글(체크박스)을 레이블과 함께 표시합니다.
- 토글을 좌측에 표시할 수 있습니다.

![2021_0607_BoolField](https://user-images.githubusercontent.com/42164422/121017940-d0825d80-c7d8-11eb-913f-cb41bcd45e90.gif)

```cs
//private bool boolValue1, boolValue2;

BoolField.Default
    .SetData("Bool Field", boolValue1)
    .DrawLayout()
    .GetValue(out boolValue1);

BoolField.Default
    .SetData("Bool Field(Left)", boolValue2, true)
    .DrawLayout()
    .GetValue(out boolValue2);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|toggleColor|토글(체크박스) 색상|

### **메소드**

- **SetData(string label, bool value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 토글 체크 여부
  - widthThreshold : 좌측 레이블과 우측 색상 필드의 너비 비율(기본값 : 0.4f)

- **SetData(string label, bool value, bool toggleLeft, float widthThreshold)**
  - toggleLeft : 토글을 좌측에 표시할지 여부

<br>

</details>

## **ColorField**

<details>
<summary markdown="span">
.
</summary>

- Color 타입의 필드를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121004827-1683f500-c7ca-11eb-8e6f-78cb60ab79c5.png)

```cs
//private Color color;

ColorField.Default
    .SetData("Color Field", color)
    .DrawLayout()
    .GetValue(out color);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|colorPickerColor|우측 색상 선택기 색상|

### **메소드**

- **SetData(string label, Color value, float widthThreshold)**
  - 레이블 텍스트와 필드 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 우측의 색상 필드에 지정할 값
  - widthThreshold : 좌측 레이블과 우측 색상 필드의 너비 비율(기본값 : 0.4f)

<br>

</details>

## **IntSlider**

<details>
<summary markdown="span">
.
</summary>

- int 타입 슬라이더를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121005759-1a644700-c7cb-11eb-9f99-a5dea94d3e93.png)

```cs
//private int intValue = 5;

IntSlider.Default
    .SetData("Int Slider", intValue, 0, 10)
    .DrawLayout()
    .GetValue(out intValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|sliderColor|슬라이더 및 입력 필드의 색상|
|Color|inputTextColor|입력 필드 텍스트 색상|

### **메소드**

- **SetData(string label, int value, int minValue, int maxValue, float widthThreshold)**
  - 레이블 텍스트와 필드의 현재값, 최소 및 최댓값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 필드의 현재 값
  - minValue : 슬라이더의 최소 범위값
  - maxValue : 슬라이더의 최대 범위값
  - widthThreshold : 좌측 레이블과 우측 슬라이더 너비 비율(기본값 : 0.4f)

<br>

</details>

## **FloatSlider**

<details>
<summary markdown="span">
.
</summary>

- float 타입 슬라이더를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121006376-ca39b480-c7cb-11eb-897e-f888c9cbea49.png)

```cs
//private float floatValue = 4.25f;

FloatSlider.Default
    .SetData("Float Slider", floatValue, 0, 10)
    .DrawLayout()
    .GetValue(out floatValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|sliderColor|슬라이더 및 입력 필드의 색상|
|Color|inputTextColor|입력 필드 텍스트 색상|

### **메소드**

- **SetData(string label, float value, float minValue, float maxValue, float widthThreshold)**
  - 레이블 텍스트와 필드의 현재값, 최소 및 최댓값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 필드의 현재 값
  - minValue : 슬라이더의 최소 범위값
  - maxValue : 슬라이더의 최대 범위값
  - widthThreshold : 좌측 레이블과 우측 슬라이더 너비 비율(기본값 : 0.4f)

<br>

</details>

## **DoubleSlider**

<details>
<summary markdown="span">
.
</summary>

- double 타입 슬라이더를 레이블과 함께 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121006395-cefe6880-c7cb-11eb-82e9-c35690797ac5.png)

```cs
//private double doubleValue = 6.78;

DoubleSlider.Default
    .SetData("Double Slider", doubleValue, 0, 10)
    .DrawLayout()
    .GetValue(out doubleValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|sliderColor|슬라이더 및 입력 필드의 색상|
|Color|inputTextColor|입력 필드 텍스트 색상|

### **메소드**

- **SetData(string label, double value, double minValue, double maxValue, float widthThreshold)**
  - 레이블 텍스트와 필드의 현재값, 최소 및 최댓값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - value : 필드의 현재 값
  - minValue : 슬라이더의 최소 범위값
  - maxValue : 슬라이더의 최대 범위값
  - widthThreshold : 좌측 레이블과 우측 슬라이더 너비 비율(기본값 : 0.4f)

<br>

</details>

## **Dropdown&lt;T&gt;**

<details>
<summary markdown="span">
.
</summary>

- 원하는 타입의 드롭다운을 레이블과 함께 표시합니다.

![2021_0607_Dropdown2](https://user-images.githubusercontent.com/42164422/121011401-85b11780-c7d1-11eb-8bb1-951ca5399b2b.gif)

```cs
//private float[] floatArray = { 0.1f, 0.2f, 0.3f, 1f, 2f };
//private List<string> stringList = new List<string>(){ "ABC", "BCD", "012" };
//private int selectedIndex1 = 0;
//private int selectedIndex2 = 0;

Dropdown<float>.Default
    .SetData("Float Dropdown", floatArray, selectedIndex1)
    .DrawLayout()
    .GetValue(out selectedIndex1);

Dropdown<string>.Default
    .SetData("String Dropdown", stringList, selectedIndex2)
    .DrawLayout()
    .GetValue(out selectedIndex2);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, T[] options, int selectedIndex, float widthThreshold)**
  - 레이블 텍스트와 목록으로 사용할 배열, 현재 선택된 인덱스를 지정합니다.
  - label : 좌측 레이블 텍스트
  - options : 목록으로 사용할 배열
  - selectedIndex : 현재 선택된 항목의 인덱스
  - widthThreshold : 좌측 레이블과 우측 드롭다운 너비 비율(기본값 : 0.4f)

- **SetData(string label, IList&lt;T&gt; options, int selectedIndex, float widthThreshold)**
  - options : 목록으로 사용할 리스트

- **GetSelectedValue(out T variable)**
  - 현재 선택된 항목의 값을 참조합니다.
  - 참고 : GetValue() 메소드는 현재 선택된 항목의 인덱스를 참조합니다.

<br>

</details>

## **EnumDropdown**

<details>
<summary markdown="span">
.
</summary>

- Enum 타입의 드롭다운을 레이블과 함께 표시합니다.
- 값을 받아올 때, 대상 열거형 타입으로 형변환이 필요합니다.

![2021_0607_EnumDropdown](https://user-images.githubusercontent.com/42164422/121014228-b5155380-c7d4-11eb-9149-a8e14725021b.gif)

```cs
// private Space enumValue;

EnumDropdown.Default
    .SetData("Enum Dropdown", enumValue)
    .DrawLayout()
    .GetValue(out Enum outEnumValue);
enumValue = (Space)outEnumValue;
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, Enum selectedValue, float widthThreshold)**
  - 레이블 텍스트와 Enum 타입의 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - selectedValue : 현재 선택된 값
  - widthThreshold : 좌측 레이블과 우측 드롭다운 너비 비율(기본값 : 0.4f)

<br>

</details>

## **EnumDropdown&lt;T&gt;**

<details>
<summary markdown="span">
.
</summary>

- 제네릭으로 지정한 열거형 타입의 드롭다운을 레이블과 함께 표시합니다.
- 제네릭을 이용하므로, 값을 받아올 때 형변환이 별도로 필요하지 않습니다.

![2021_0607_EnumDropdown](https://user-images.githubusercontent.com/42164422/121014228-b5155380-c7d4-11eb-9149-a8e14725021b.gif)

```cs
// private Space enumValue;

EnumDropdown<Space>.Default
    .SetData("Enum Dropdown", enumValue)
    .DrawLayout()
    .GetValue(out enumValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|labelColor|좌측 레이블 텍스트 색상|
|int|labelFontSize|레이블 폰트 크기|
|FontStyle|labelFontStyle|레이블 폰트 스타일|
|TextAnchor|labelAlignment|레이블 텍스트 정렬|
|Color|inputTextColor|입력 필드 텍스트 색상|
|Color|inputTextFocusedColor|입력 상태의 입력 필드 텍스트 색상|
|Color|inputBackgroundColor|입력 필드의 배경 색상|
|int|inputFontSize|입력 필드 폰트 크기|
|FontStyle|inputFontStyle|입력 필드 폰트 스타일|
|TextAnchor|inputTextAlignment|입력 필드 텍스트 정렬|

### **메소드**

- **SetData(string label, T selectedValue, float widthThreshold)**
  - 레이블 텍스트와 열거형 타입의 값을 지정합니다.
  - label : 좌측 레이블 텍스트
  - selectedValue : 현재 선택된 값
  - widthThreshold : 좌측 레이블과 우측 드롭다운 너비 비율(기본값 : 0.4f)

<br>

</details>

## **TextArea**

<details>
<summary markdown="span">
.
</summary>

- 문자열 입력 필드를 표시합니다.

![2021_0607_Textarea](https://user-images.githubusercontent.com/42164422/121059681-b65a7680-c7fc-11eb-8f59-50397049cfb4.gif)

```cs
//private string stringValue = "";
//private string stringValue2 = "";

TextArea.Default
    .SetData(stringValue)
    .DrawLayout()
    .GetValue(out stringValue);

TextArea.Default
    .SetData(stringValue2, "placeholder")
    .DrawLayout()
    .GetValue(out stringValue2);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|Color|textFocusedColor|입력 상태의 텍스트 색상|
|Color|backgroundColor|배경 색상|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일|
|TextAnchor|textAlignment|텍스트 정렬|

### **메소드**

- **SetData(string value, string placeholder = "")**
  - value : 입력 필드의 텍스트
  - placeholder : 필드에 값이 존재하지 않을 경우 표시할 텍스트 (기본값 : "")

<br>

</details>

## **Toggle**

<details>
<summary markdown="span">
.
</summary>

- 토글(체크박스)을 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121018941-ec3a3380-c7d9-11eb-9417-83fbe25a7004.png)

```cs
//private bool boolValue;

Toggle.Default
    .SetData(boolValue)
    .DrawLayout()
    .GetValue(out boolValue);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|color|토글 색상|

### **메소드**

- **SetData(bool value)**
  - 토글 체크 여부를 지정합니다.

<br>

</details>

## **ColorPicker**

<details>
<summary markdown="span">
.
</summary>

- 색상 선택 필드를 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121061715-2c5fdd00-c7ff-11eb-94ae-6ab8902f021a.png)

```cs
//private Color color = Color.red;

ColorPicker.Default
    .SetData(color)
    .DrawLayout()
    .GetValue(out color);
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|colorPickerColor|색상 선택 필드 배경 색상|

### **메소드**

- **SetData(Color value)**
  - 필드의 색상 값을 지정합니다.

<br>

</details>

## **HelpBox**

<details>
<summary markdown="span">
.
</summary>

- 도움말 상자를 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121062140-b27c2380-c7ff-11eb-8bd1-b4abb53e1942.png)

```cs
HelpBox.Default
    .SetData("Info", MessageType.Info).DrawLayout()
    .SetData("Warning", MessageType.Warning).DrawLayout()
    .SetData("Error", MessageType.Error).DrawLayout();
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|Color|backgroundColor|배경 색상|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일|
|TextAnchor|textAlignment|텍스트 정렬|

### **메소드**

- **SetData(string value, MessageType messageType)**
  - value : 메시지 박스 내의 텍스트
  - messageType : 텍스트 좌측의 아이콘 종류(정보, 경고, 에러)

<br>

</details>

## **Button**

<details>
<summary markdown="span">
.
</summary>

- 클릭할 수 있는 버튼을 표시합니다.

![image](https://user-images.githubusercontent.com/42164422/121062837-890fc780-c800-11eb-8ba6-7f88a6f2146e.png)

```cs
Button.Default
    .SetData("Button")
    .DrawLayout()
    .OnValueChanged(clicked => Debug.Log("Click!"));
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|textColor|텍스트 색상|
|Color|pressedTextColor|버튼을 눌렀을 때 텍스트 색상|
|Color|buttonColor|버튼 색상|
|int|fontSize|폰트 크기|
|FontStyle|fontStyle|폰트 스타일|
|TextAnchor|textAlignment|텍스트 정렬|

### **메소드**

- **SetData(string text)**
  - 버튼 내의 텍스트를 지정합니다.

<br>

</details>

## **ToggleButton**

<details>
<summary markdown="span">
.
</summary>

- 누른 상태를 유지할 수 있는 버튼을 표시합니다.

![2021_0608_ToggleButton](https://user-images.githubusercontent.com/42164422/121066075-78f9e700-c804-11eb-8fa0-8736ce258aef.gif)

```cs
//private bool boolValue = false;

ToggleButton.Default
    .SetData("Toggle Button", boolValue)
    .DrawLayout()
    .GetValue(out boolValue)
    .OnValueChanged(pressed => Debug.Log("Pressed : " + pressed));
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|normalTextColor|누르지 않은 상태의 텍스트 색상|
|Color|notmalButtonColor|누르지 않은 상태의 버튼 색상|
|FontStyle|normalFontStyle|누르지 않은 상태의 텍스트 폰트 스타일|
|Color|pressedTextColor|누른 상태의 텍스트 색상|
|Color|pressedButtonColor|누른 상태의 버튼 색상|
|FontStyle|pressedFontStyle|누른 상태의 텍스트 폰트 스타일|
|int|fontSize|폰트 크기|
|TextAnchor|textAlignment|텍스트 정렬|

### **메소드**

- **SetData(string text, bool pressed)**
  - 버튼 내의 텍스트, 버튼을 눌렀는지 여부를 지정합니다.

<br>

</details>

## **Box**

<details>
<summary markdown="span">
.
</summary>

- 네모난 박스를 그립니다.

![image](https://user-images.githubusercontent.com/42164422/121068495-4dc4c700-c807-11eb-80e5-57ba9d0d0245.png)

```cs
Box.Default
    .SetData(0f)
    .Draw(height: 24f)
    .Space(30f);

Box.Default
    .SetData(2f)
    .DrawLayout(2);

IntField.Default
    .SetData("Int Field", 1)
    .DrawLayout();

Button.Default
    .SetData("Button")
    .DrawLayout();
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|color|박스 내부 색상|
|Color|outlineColor|외곽선 색상|

### **메소드**

- **SetData(float outlineWidth)**
  - 외곽선 두께를 지정합니다.

- **Draw(float height)**
  - 높이를 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.

- **Draw(float xLeft, float xRight)**
  - rect의 좌측, 우측 지점 비율을 지정하여 그립니다.
  - 높이는 레이아웃 요소 기본 높이(18f)로 자동 지정됩니다.

- **Draw(float xLeft, float xRight, float height)**
  - 좌우 비율, 높이를 지정하여 그립니다.

- **Draw(float xLeft, float xRight, float yOffset, float height, float xLeftOffset, float xRightOffset)**
  - 좌우 비율, y축 시작 좌표, 높이를 지정하여 그립니다.
  - 좌측 및 우측 지점의 위치를 각각 `xLeftOffset`, `xRightOffset`을 통해 픽셀값으로 보정할 수 있습니다.

- **DrawLayout(int contentCount)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 너비, 높이를 자동으로 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.
  - 높이는 레이아웃 요소 기본 높이(18f) * contentCount로 자동 지정됩니다.
  - 그려진 높이 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

- **DrawLayout(int contentCount, float bonusHeight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - bonusHeight : 추가 하단 높이
  - contentCount로 자동 계산된 높이에 bonusHeight만큼 하단에 추가로 더해진 높이만큼 그립니다.

- **DrawLayout(int contentCount, float paddingVertical, float paddingHorizontal)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, paddingVertical(픽셀)만큼 상하로 높이를 더하고 paddingHorizontal(픽셀)만큼 좌우로 너비를 더한만큼 그립니다.

- **DrawLayout(int contentCount, float paddingTop, float paddingBottom, float paddingLeft, float paddingRight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, 상하좌우로 각각 더해진 크기만큼 그립니다.

- **Margin(float height)**
  - 다른 GUI 요소들과는 달리, Space() 메소드와 완전히 동일하게 동작합니다.
  - 박스의 Y축 상단 지점으로부터 height 값만큼 하단으로 커서를 이동합니다.

- **Layout()**
  - 다른 GUI 요소들과는 달리, 레이아웃 기본 여백(2f) 만큼만 커서를 하단으로 이동합니다.

<br>

</details>

## **HeaderBox**

<details>
<summary markdown="span">
.
</summary>

- 헤더 영역과 레이블이 존재하는 네모난 박스를 그립니다.

![image](https://user-images.githubusercontent.com/42164422/121070958-4d79fb00-c80a-11eb-8536-1ae6b3811fb8.png)

```cs
HeaderBox.Default
    .SetData("Header Box 1", 0f)
    .Draw(20f, 40f)
    .Space(70f);

HeaderBox.Default
    .SetData("Header Box 2", 2f)
    .DrawLayout(2);

IntField.Default
    .SetData("Int Field", 1)
    .DrawLayout();

Button.Default
    .SetData("Button")
    .DrawLayout();
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|headerTextColor|헤더 텍스트 색상|
|int|headerFontSize|헤더 텍스트 크기|
|FontStyle|headerFontStyle|헤더 텍스트 스타일|
|TextAnchor|headerTextAlignment|헤더 텍스트 정렬|
|Color|headerColor|헤더 영역 박스 색상|
|Color|contentColor|컨텐츠 영역 박스 색상|
|Color|outlineColor|외곽선 색상|

### **메소드**

- **SetData(string headerText, float outlineWidth, float headerTextIndent)**
  - headerText : 헤더 영역의 레이블 텍스트
  - outlineWidth : 외곽선 두께(기본값 : 0f)
  - headerTextIndent : 헤더 레이블의 들여쓰기 너비(기본값 : 2f)

- **Draw(float headerHeight, float contentHeight)**
  - 헤더 영역과 컨텐츠 영역의 높이를 각각 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.

- **Draw(float xLeft, float xRight, float headerHeight, float contentHeight)**
  - rect의 좌측, 우측 지점 비율, 헤더 영역 높이, 컨텐츠 영역 높이를 지정하여 그립니다.

- **Draw(float xLeft, float xRight, float yOffset, float headerHeight, float contentHeight, float xLeftOffset, float xRightOffset)**
  - 좌우 비율, y축 시작 좌표, 헤더 영역 높이, 컨텐츠 영역 높이를 지정하여 그립니다.
  - 좌측 및 우측 지점의 위치를 각각 `xLeftOffset`, `xRightOffset`을 통해 픽셀값으로 보정할 수 있습니다.

- **DrawLayout(int contentCount)**
  - contentCount : 컨텐츠 영역 내부에 포함될 레이아웃 요소의 개수
  - 너비, 높이를 자동으로 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.
  - 헤더 영역 높이는 20f로 지정됩니다.
  - 컨텐츠 영역 높이는 레이아웃 요소 기본 높이(18f) * contentCount로 지정됩니다.
  - 헤더 영역 높이 + 외곽선 두께 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

- **DrawLayout(int contentCount, float bonusContentHeight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - bonusContentHeight : 추가 하단 높이
  - contentCount로 자동 계산된 높이에 bonusHeight만큼 컨텐츠 영역 하단에 추가로 더해진 높이만큼 그립니다.

- **DrawLayout(int contentCount, float paddingVertical, float paddingHorizontal)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, 컨텐츠 영역을 paddingVertical(픽셀)만큼 상하로 높이를 더하고 paddingHorizontal(픽셀)만큼 좌우로 너비를 더한만큼 그립니다.

- **DrawLayout(int contentCount, float paddingTop, float paddingBottom, float paddingLeft, float paddingRight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, 컨텐츠 영역을 상하좌우로 각각 더해진 크기만큼 그립니다.

- **Margin(float height)**
  - 헤더 영역 높이 + 외곽선 두께 + height 값만큼 커서를 이동합니다.

- **Layout()**
  - 헤더 영역 높이 + 외곽선 두께 + 레이아웃 요소 기본 하단 여백(2f)만큼 커서를 이동합니다.

<br>

</details>

## **FoldoutHeaderBox**

<details>
<summary markdown="span">
.
</summary>

- 헤더 부분을 클릭하여 접고 펼칠 수 있는 헤더박스를 그립니다.

![2021_0608_FoldoutHeaderBox](https://user-images.githubusercontent.com/42164422/121147275-b057aa80-c87b-11eb-901b-210a60008a98.gif)

```cs
//private bool foldout1, foldout2;

FoldoutHeaderBox.Default
    .SetData(foldout1, "Foldout Header Box 1", 0f)
    .Draw(20f, 40f)
    .GetValue(out foldout1)
    .Space(!foldout1? 30f : 70f);

FoldoutHeaderBox.Default
    .SetData(foldout2, "Foldout Header Box 2", 2f)
    .DrawLayout(2)
    .GetValue(out foldout2);

if (foldout2)
{
    IntField.Default
        .SetData("Int Field", 1)
        .DrawLayout();

    Button.Default
        .SetData("Button")
        .DrawLayout();
}
```

### **필드**

|타입|이름|설명|
|---|---|---|
|Color|headerTextColor|헤더 텍스트 색상|
|int|headerFontSize|헤더 텍스트 크기|
|FontStyle|headerFontStyle|헤더 텍스트 스타일|
|TextAnchor|headerTextAlignment|헤더 텍스트 정렬|
|Color|headerColor|헤더 영역 박스 색상|
|Color|contentColor|컨텐츠 영역 박스 색상|
|Color|outlineColor|외곽선 색상|

### **메소드**

- **SetData(bool foldout, string headerText, float outlineWidth, float headerTextIndent)**
  - foldout : 현재 박스가 펼쳐졌는지 여부
  - headerText : 헤더 영역의 레이블 텍스트
  - outlineWidth : 외곽선 두께(기본값 : 0f)
  - headerTextIndent : 헤더 레이블의 들여쓰기 너비(기본값 : 2f)

- **Draw(float headerHeight, float contentHeight)**
  - 헤더 영역과 컨텐츠 영역의 높이를 각각 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.

- **Draw(float xLeft, float xRight, float headerHeight, float contentHeight)**
  - rect의 좌측, 우측 지점 비율, 헤더 영역 높이, 컨텐츠 영역 높이를 지정하여 그립니다.

- **Draw(float xLeft, float xRight, float yOffset, float headerHeight, float contentHeight, float xLeftOffset, float xRightOffset)**
  - 좌우 비율, y축 시작 좌표, 헤더 영역 높이, 컨텐츠 영역 높이를 지정하여 그립니다.
  - 좌측 및 우측 지점의 위치를 각각 `xLeftOffset`, `xRightOffset`을 통해 픽셀값으로 보정할 수 있습니다.

- **DrawLayout(int contentCount)**
  - contentCount : 컨텐츠 영역 내부에 포함될 레이아웃 요소의 개수
  - 너비, 높이를 자동으로 지정하여 그립니다.
  - 너비는 여백을 제외한 좌측 끝부터 우측 끝까지 지정됩니다.
  - 헤더 영역 높이는 20f로 지정됩니다.
  - 컨텐츠 영역 높이는 레이아웃 요소 기본 높이(18f) * contentCount로 지정됩니다.
  - 헤더 영역 높이 + 외곽선 두께 + 레이아웃 요소 기본 여백(2f)만큼 커서도 이동합니다.

- **DrawLayout(int contentCount, float bonusContentHeight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - bonusContentHeight : 추가 하단 높이
  - contentCount로 자동 계산된 높이에 bonusHeight만큼 컨텐츠 영역 하단에 추가로 더해진 높이만큼 그립니다.

- **DrawLayout(int contentCount, float paddingVertical, float paddingHorizontal)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, 컨텐츠 영역을 paddingVertical(픽셀)만큼 상하로 높이를 더하고 paddingHorizontal(픽셀)만큼 좌우로 너비를 더한만큼 그립니다.

- **DrawLayout(int contentCount, float paddingTop, float paddingBottom, float paddingLeft, float paddingRight)**
  - contentCount : 박스 내부에 포함될 레이아웃 요소의 개수
  - 자동 계산된 너비와 높이에 더하여, 컨텐츠 영역을 상하좌우로 각각 더해진 크기만큼 그립니다.

- **Margin(float height)**
  - 접힌 상태에서는 헤더 영역 높이만큼 커서를 이동합니다.
  - 펼친 상태에서는 헤더 영역 높이 + 외곽선 두께 + height 값만큼 커서를 이동합니다.

- **Layout()**
  - 접힌 상태에서는 헤더 영역 높이만큼 커서를 이동합니다.
  - 펼친 상태에서는 헤더 영역 높이 + 외곽선 두께 + 레이아웃 요소 기본 하단 여백(2f)만큼 커서를 이동합니다.

</details>

</details>

<br>

# 확장 메소드

<details>
<summary markdown="span">
.
</summary>

보다 편리하게 커스텀 에디터를 작성할 수 있도록,

주로 사용되는 타입마다 확장 메소드를 제공합니다.

<br>

## **특징**
- 모든 확장 메소드의 이름은 `Draw`로 시작합니다.
- 확장 메소드를 통해 그리면 `DrawLayout()`으로 그려집니다.
- 인스펙터에서 값을 변경하기 위해서는 이름이 `Ref`로 끝나는 확장 메소드를 사용하거나,
  `GetValue()` 메소드를 추가로 호출해야 합니다.

<br>

### **예시**

<details>
<summary markdown="span">
.
</summary>

**[1] 그냥 그리는 경우(값 변경 불가)**

```cs
int intValue = 10;

// 1. 상수로 즉시 그리기
10.DrawField("Int Field");

// 2. 변수로 그리기
intValue.DrawField("Int Field");
```

**[2] 값을 변경할 수 있는 경우**

```cs
// 정수형 필드
//private int intValue = 10;

// 1. Ref 메소드 사용
intValue.DrawFieldRef("Int Field");

// 2. GetValue(out) 사용
intValue.DrawField("Int Field").GetValue(out intValue);

// 3. GetValue() 사용
intValue = intValue.DrawField("Int Field").GetValue();
```

<br>

</details>

## **string**

<details>
<summary markdown="span">
.
</summary>

### **DrawLabel()**
 - 해당 문자열을 Label로 그립니다.

```cs
//private string s = "Label";
s.DrawLabel().GetValue(out s);
```

### **DrawSelectableLabel()**
 - 해당 문자열을 SelectableLabel로 그립니다.

```cs
//private string s = "Label";
s.DrawSelectableLabel().GetValue(out s);
```

### **DrawEditableLabel()**
 - 해당 문자열을 EditableLabel로 그립니다.

```cs
//private string s = "Label";
s.DrawEditableLabel().GetValue(out s);
```

### **DrawStringField(string label)**
 - 해당 문자열을 값으로 사용하는 StringField를 그립니다.
 - `label`은 좌측의 레이블 텍스트로 사용됩니다.

```cs
//private string s = "ABCDE";
s.DrawStringField("String Field").GetValue(out s);
```

### **DrawTextArea()**
 - 해당 문자열을 값으로 사용하는 TextArea를 그립니다.

```cs
//private string s = "ABCDE";
s.DrawTextArea().GetValue(out s);
```

### **DrawTextArea(string placeholder)**
 - 해당 문자열을 값으로 사용하는 TextArea를 그립니다.
 - `placeholder`는 문자열이 없을 경우 나타내는 Placeholder로 사용됩니다.

```cs
//private string s = "ABCDE";
s.DrawTextArea("placeholder").GetValue(out s);
```

### **DrawHeaderBox(int contentCount, float outlineWidth = 0f, float headerTextIndent)**
 - 해당 문자열을 헤더 텍스트로 사용하는 HeaderBox를 그립니다.
 - contentCount : 박스 내부에 들어갈 레이아웃 요소 개수
 - outlineWidth : 박스의 외곽선 두께(기본값 : 0f)
 - headerTextIndent : 헤더 텍스트의 들여쓰기 너비(기본값 : 2f)

```cs
string s = "Header Box";
s.DrawHeaderBox(2, 2f);
```

### **FoldoutHeaderBox(ref bool foldout, int contentCount, float outlineWidth = 0f, float headerTextIndent)**
 - 해당 문자열을 헤더 텍스트로 사용하는 FoldoutHeaderBox를 그립니다.
 - foldout : 박스가 펼쳐져 있는지 여부. 반드시 필드 변수를 사용해야 합니다.
 - contentCount : 박스 내부에 들어갈 레이아웃 요소 개수
 - outlineWidth : 박스의 외곽선 두께(기본값 : 0f)
 - headerTextIndent : 헤더 텍스트의 들여쓰기 너비(기본값 : 2f)

```cs
//private bool foldout;

string s = "Header Box";
s.DrawHeaderBox(ref foldout, 2, 2f);
```

### **Button()**
 - 해당 문자열을 텍스트로 사용하는 Button을 그립니다.

```cs
string s = "Button";
s.DrawButton();
```

### **ToggleButton(ref bool pressed)**
 - 해당 문자열을 텍스트로 사용하는 ToggleButton을 그립니다.
 - pressed : 버튼이 눌렸는지 여부. 반드시 필드 변수를 사용해야 합니다.

```cs
//private bool pressed;

string s = "Toggle Button";
s.ToggleButton(ref pressed);
```

<br>

</details>

## **int**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 정수를 필드 값으로 사용하는 IntField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private int i = 0;
i.DrawField("Int Field").GetValue(out i);
```

### **DrawFieldRef(string label)**
 - int 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private int i = 0;
i.DrawFieldRef("Int Field");
```

### **DrawSlider(string label, int min, int max)**
 - 해당 정수를 필드 값으로 사용하는 IntSlider를 그립니다.
 - `label` : 좌측의 레이블 텍스트
 - `min` : 슬라이더 최솟값
 - `max` : 슬라이더 최댓값

```cs
//private int i = 0;
i.DrawSlider("Int Slider", 0, 10).GetValue(out i);
```

### **DrawSliderRef(string label, int min, int max)**
 - 정수형 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private int i = 0;
i.DrawSliderRef("Int Slider", 0, 10);
```

<br>

</details>

## **long**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 정수를 필드 값으로 사용하는 LongField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private long l = 0;
l.DrawField("Long Field").GetValue(out l);
```

### **DrawFieldRef(string label)**
 - long 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private long l = 0;
l.DrawFieldRef("Long Field");
```

<br>

</details>

## **float**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 실수를 필드 값으로 사용하는 FloatField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private float f = 0f;
f.DrawField("Float Field").GetValue(out f);
```

### **DrawFieldRef(string label)**
 - float 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private float f = 0f;
f.DrawFieldRef("Float Field");
```

### **DrawSlider(string label, float min, float max)**
 - 해당 실수를 필드 값으로 사용하는 FloatSlider를 그립니다.
 - `label` : 좌측의 레이블 텍스트
 - `min` : 슬라이더 최솟값
 - `max` : 슬라이더 최댓값

```cs
//private float f = 0f;
f.DrawSlider("Float Slider", 0f, 1f).GetValue(out f);
```

### **DrawSliderRef(string label, float min, float max)**
 - float 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private float f = 0f;
f.DrawSliderRef("Float Slider", 0f, 1f);
```

<br>

</details>

## **double**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 실수를 필드 값으로 사용하는 DoubleField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private double d = 0;
d.DrawField("Double Field").GetValue(out d);
```

### **DrawFieldRef(string label)**
 - double 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private double d = 0;
d.DrawFieldRef("Double Field");
```

### **DrawSlider(string label, double min, double max)**
 - 해당 실수를 필드 값으로 사용하는 DoubleSlider를 그립니다.
 - `label` : 좌측의 레이블 텍스트
 - `min` : 슬라이더 최솟값
 - `max` : 슬라이더 최댓값

```cs
//private double d = 0;
d.DrawSlider("Double Slider", 0, 1).GetValue(out d);
```

### **DrawSliderRef(string label, double min, double max)**
 - double 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private double d = 0;
d.DrawSliderRef("Double Slider", 0, 1);
```

<br>

</details>

## **bool**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 BoolField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private bool b = false;
b.DrawField("Bool Field").GetValue(out b);
```

### **DrawFieldRef(string label)**
 - bool 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private bool b = false;
b.DrawFieldRef("Bool Field");
```

### **DrawToggle()**
 - 해당 값을 필드로 사용하는 Toggle을 그립니다.

```cs
//private bool b = false;
b.DrawToggle().GetValue(out b);
```

### **DrawToggleRef()**
 - bool 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private bool b = false;
b.DrawToggleRef();
```

<br>

</details>

## **Vector2**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 Vector2Field를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Vector2 v2;
v2.DrawField("Vector2 Field").GetValue(out v2);
```

### **DrawFieldRef(string label)**
 - Vector2 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Vector2 v2;
v2.DrawFieldRef("Vector2 Field");
```

<br>

</details>

## **Vector3**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 Vector3Field를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Vector3 v3;
v3.DrawField("Vector3 Field").GetValue(out v3);
```

### **DrawFieldRef(string label)**
 - Vector3 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Vector3 v3;
v3.DrawFieldRef("Vector3 Field");
```

<br>

</details>

## **Vector4**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 Vector4Field를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Vector4 v4;
v4.DrawField("Vector4 Field").GetValue(out v4);
```

### **DrawFieldRef(string label)**
 - Vector4 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Vector4 v4;
v4.DrawFieldRef("Vector4 Field");
```

<br>

</details>

## **Vector2Int**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 Vector2IntField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Vector2Int v2i;
v2i.DrawField("Vector2Int Field").GetValue(out v2i);
```

### **DrawFieldRef(string label)**
 - Vector2Int 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Vector2Int v2i;
v2i.DrawFieldRef("Vector2Int Field");
```

<br>

</details>

## **Vector3Int**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 Vector3IntField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Vector3Int v3i;
v3i.DrawField("Vector3Int Field").GetValue(out v3i);
```

### **DrawFieldRef(string label)**
 - Vector3Int 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Vector3Int v3i;
v3i.DrawFieldRef("Vector3Int Field");
```

<br>

</details>

## **Color**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 ColorField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private Color c;
c.DrawField("Color Field").GetValue(out c);
```

### **DrawFieldRef(string label)**
 - Color 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Color c;
c.DrawFieldRef("Color Field");
```

### **DrawColorPicker()**
 - 해당 값을 필드로 사용하는 ColorPicker를 그립니다.

```cs
//private Color c;
c.DrawColorPicker().GetValue(out c);
```

### **DrawColorPickerRef()**
 - Color 타입 필드를 통해 호출해야 합니다.
 - `GetValue()`를 따로 호출하지 않아도 값의 변경이 적용됩니다.

```cs
//private Color c;
c.DrawColorPickerRef();
```

<br>

</details>

## **UnityEngine.Object 상속 타입**

<details>
<summary markdown="span">
.
</summary>

### **DrawField(string label)**
 - 해당 값을 필드로 사용하는 ObjectField를 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
//private GameObject go;
//private Transform tr;

go.DrawField("Game Object").GetValue(out go);
tr.DrawField("Transform").GetValue(out tr);
```

<br>

</details>

## **enum**

<details>
<summary markdown="span">
.
</summary>

### **DrawDropdown(string label)**
 - 해당 enum 값들을 목록으로 사용하는 EnumDropdown을 그립니다.
 - `label` : 좌측의 레이블 텍스트

```cs
// private enum MyEnum { A, B, C }
// private MyEnum e;

e.DrawDropdown("Enum").GetValue(out e);
```

<br>

</details>

## **배열, 리스트**

<details>
<summary markdown="span">
.
</summary>

### **DrawDropdown(string label, int selectedIndex)**
 - 배열 또는 리스트를 목록으로 사용하는 Dropdown을 그립니다.
 - `label` : 좌측의 레이블 텍스트
 - `selectedIndex` : 현재 선택된 항목의 인덱스

```cs
//private float[] floatArray = { 0.1f, 0.2f, 0.3f };
//private List<string> stringList = new List<string>() { "ABC", "abc", "012" };
//private int fIndex, sIndex;

floatArray.DrawDropdown("Float Array", fIndex).GetValue(out fIndex);
stringList.DrawDropdown("String List", sIndex).GetValue(out sIndex);
```

</details>

</details>

<br>

<br>
