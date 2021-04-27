---
title: Radial Menu 만들기
author: Rito15
date: 2021-04-26 18:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 목표
---
- 극좌표계를 이용하여 원형 분포 형태의 메뉴 UI 만들기

<br>

# Preview
---

![2021_0426_RadialMenu](https://user-images.githubusercontent.com/42164422/116089489-e4b54400-a6dd-11eb-957d-70b832b55b01.gif)

<br>

# 직교 좌표계
---

- Cartesian Coordinate System

유니티2D에서 사용하는 좌표계는 x, y 축으로 이루어진 직교 좌표계이다.

데카르트 좌표계라고도 하며, x, y 값을 통해 좌표를 표현한다.

![image](https://user-images.githubusercontent.com/42164422/116059429-c9394180-a6bb-11eb-92cf-078e95b9f5d4.png)


<br>

# 극좌표계
---

- Polar Coordinate System

직교 좌표계와는 달리, 거리(radius)와 각도(angle)를 통해 특정 좌표를 표현한다.

이 때 거리는 중심으로부터의 거리, 각도는 직교 좌표계의 +X 축으로부터의 각도를 의미한다.

좌표가 중심을 기준으로 반시계방향으로 이동할수록 각도가 커진다.

![image](https://user-images.githubusercontent.com/42164422/116060989-50d38000-a6bd-11eb-9bf0-ef1759dbe317.png)

![image](https://user-images.githubusercontent.com/42164422/116075534-06a6ca80-a6ce-11eb-9676-84f1d3de4723.png)

<br>

## 극좌표계가 필요한 이유

Radial Menu를 만들기 위해서는 각각의 이미지가 중심을 기준으로 동일한 거리만큼 떨어져 원형으로 위치해야 한다.

이를 직교 좌표계로 표현하기에는 복잡하고 번거롭지만, 극좌표계를 이용하면 단순히 각도만 변경하여 손쉽게 표현할 수 있다.

<br>

# 시계 극좌표계
---

시계 극좌표계라는 이름은 임의로 명명하였으며,

+X축이 0도 기준이고 반시계 방향으로 갈수록 각도가 커지는 기본 극좌표계와 달리

+Y축이 0도 기준이며 시계 방향으로 각도가 커지는 좌표계이다.

각도가 `t`라고 했을 때, `t' = 90 - t` 계산을 통해 기본 극좌표계의 좌표와 서로 변환될 수 있다.

![image](https://user-images.githubusercontent.com/42164422/116073405-53d56d00-a6cb-11eb-8f2c-4cecfcc44440.png)

<br>

# 좌표계 변환
---

동일한 점의 좌표를 직교 좌표계로 `D(x, y)`, 극좌표계로 `P(r, t)`, 시계 극좌표계로 `C(r, t)`라고 하자.

직교 좌표계, 극좌표계 및 시계 극좌표계의 좌표는 삼각함수를 이용해 서로 변환될 수 있다.

![image](https://user-images.githubusercontent.com/42164422/116075896-7a48d780-a6ce-11eb-9f65-1a374b915209.png)

<br>

## **직교 좌표계 -> 극좌표계**

피타고라스의 정리와 삼각함수를 이용해 손쉽게 좌표를 변환할 수 있다.

$$ r^2 = x^2 + y^2 $$ 이므로 $$ r = \sqrt{x^2 + y^2} $$ 이며,

$$ tan(t) = \frac{y}{x} $$ 이므로, $$ t = atan(\frac{y}{x}) $$ 이다.

따라서 $$ P(r, t) = D(\sqrt{x^2 + y^2}, atan(\frac{y}{x})) $$ 이다.

<br>

## **극좌표계 -> 시계 극좌표계**

두 극좌표계의 좌표는 단순히 $$ t' = 90 - t $$ 계산을 이용해

빠르게 변환할 수 있다.

따라서 $$ C(r, t) = P(r, 90 - t) $$ 이다.

<br>

## **직교 좌표계 -> 시계 극좌표계**

위의 두 변환식을 정리하면

$$ C(r, t) = D(\sqrt{x^2 + y^2}, 90 - atan(\frac{y}{x})) $$ 이다.

<br>

# 구조체 작성
---

위의 이론을 활용하여 시계 극좌표를 구조체로 작성한다.

<br>

<details>
<summary markdown="span"> 
ClockwisePolarCoord.cs
</summary>

```cs
[Serializable]
public struct ClockwisePolarCoord
{
    /***********************************************************************
    *                           Fields, Properties
    ***********************************************************************/
    #region .
    /// <summary> 반지름 </summary>
    public float Radius { get; set; }
    /// <summary> 0 ~ 360 각도 </summary>
    public float Angle
    {
        get => _angle;
        set => _angle = ClampAngle(value);
    }
    private float _angle;

    #endregion
    /***********************************************************************
    *                           Constructor
    ***********************************************************************/
    #region .
    public ClockwisePolarCoord(float radius, float angle)
    {
        Radius = radius;
        _angle = ClampAngle(angle);
    }

    #endregion
    /***********************************************************************
    *                           Private Static
    ***********************************************************************/
    #region .
    /// <summary> 0 ~ 360 범위 내의 각도 값 리턴 </summary>
    private static float ClampAngle(float angle)
    {
        angle %= 360f;
        if (angle < 0f)
            angle += 360f;
        return angle;
    }

    /// <summary> +x축 기준 반시계 각도 <-> +y축 기준 시계 각도 서로 변환 </summary>
    private static float CovertAngle(float angle)
        => 90f - angle;

    /// <summary> Degree(0 ~ 360)로 Sin 계산 </summary>
    private static float Sin(float angle)
        => Mathf.Sin(angle * Mathf.Deg2Rad);

    /// <summary> Degree(0 ~ 360)로 Cos 계산 </summary>
    private static float Cos(float angle)
        => Mathf.Cos(angle * Mathf.Deg2Rad);

    #endregion
    /***********************************************************************
    *                           Public Static
    ***********************************************************************/
    #region .
    public static ClockwisePolarCoord Zero => new ClockwisePolarCoord(0f, 0f);
    public static ClockwisePolarCoord North => new ClockwisePolarCoord(1f, 0f);
    public static ClockwisePolarCoord East => new ClockwisePolarCoord(1f, 90f);
    public static ClockwisePolarCoord South => new ClockwisePolarCoord(1f, 180f);
    public static ClockwisePolarCoord West => new ClockwisePolarCoord(1f, 270f);

    public static ClockwisePolarCoord FromVector2(in Vector2 vec)
    {
        if (vec == Vector2.zero)
            return Zero;

        float radius = vec.magnitude;
        float angle = Mathf.Atan2(vec.y, vec.x) * Mathf.Rad2Deg;

        return new ClockwisePolarCoord(radius, CovertAngle(angle));
    }

    public static bool operator ==(ClockwisePolarCoord a, ClockwisePolarCoord b)
    {
        return Mathf.Approximately(a.Angle, b.Angle) &&
                Mathf.Approximately(a.Radius, b.Radius);
    }

    public static bool operator !=(ClockwisePolarCoord a, ClockwisePolarCoord b)
    {
        return !(Mathf.Approximately(a.Angle, b.Angle) &&
                Mathf.Approximately(a.Radius, b.Radius));
    }

    #endregion
    /***********************************************************************
    *                               Public
    ***********************************************************************/
    #region .
    public ClockwisePolarCoord Normalized => new ClockwisePolarCoord(1f, Angle);

    public Vector2 ToVector2()
    {
        if (Radius == 0f && Angle == 0f)
            return Vector2.zero;

        float angle = CovertAngle(Angle);
        return new Vector2(Radius * Cos(angle), Radius * Sin(angle));
    }

    public override string ToString()
        => $"({Radius}, {Angle})";

    public override bool Equals(object obj)
    {
        if(obj == null) return false;

        if (obj is ClockwisePolarCoord other)
        {
            return this == other;
        }
        else
            return false;
    }

    public override int GetHashCode()
    {
        return base.GetHashCode();
    }

    #endregion
}
```

</details>


<br>

# Radial Menu 하이라키 구성
---

![image](https://user-images.githubusercontent.com/42164422/116083138-3e664000-a6d7-11eb-8eea-6ace0200bbcc.png)

## **Canvas**
 - `Canvas` 컴포넌트

## **Radial Menu Panel**
 - `RadialMenu` 컴포넌트(추후 작성)

## **Piece**
 - `Image` 컴포넌트 : 원 모양의 스프라이트 사용
 - 각 방향으로 복제될 이미지의 원본 게임오브젝트

## **Arrow Holder**
 - Arrow의 부모 게임오브젝트

## **Arrow**
 - `Image` 컴포넌트 : 화살표 모양의 스프라이트 사용
 - RectTransform의 `Pos Y` 값을 미리 조정한다. (예 : 100)

<br>

# RadialMenu 스크립트 작성
---

## **Radial Menu 동작 순서**

- 특정 키를 눌러 RadialMenu가 나타나게 한다.
- 각각의 조각 이미지들이 원형으로 퍼진 형태로 등장한다.
- 키를 누른 상태에서 마우스를 움직여 조각들 중 하나를 선택한다.
- 키를 떼면 선택된 조각의 인덱스를 받아오며, RadialMenu가 사라진다.

![2021_0426_RadialMenu](https://user-images.githubusercontent.com/42164422/116089489-e4b54400-a6dd-11eb-957d-70b832b55b01.gif)

<br>

## **필드**

```cs
[Header("Options")]
[Range(2, 16)]
[SerializeField] private int _pieceCount = 8; // 조각 개수

[Range(0.2f, 1f)]
[SerializeField] private float _appearanceDuration = .3f; // 등장에 걸리는 시간
[SerializeField] private float _pieceDist = 180f; // 중앙으로부터 각 조각의 거리

[Range(0.01f, 0.5f)]
[SerializeField] private float _centerDistThreshold = 0.1f; // 중앙에서부터의 마우스 거리 기준

[Header("Objects")]
[SerializeField] private GameObject _pieceSample; // 복제될 조각 게임오브젝트
[SerializeField] private RectTransform _arrow;    // 화살표 이미지의 부모 트랜스폼

// 복제된 조각들
private Image[] _pieceImages;
private RectTransform[] _pieceRects;
private Vector2[] _pieceDirections; // 각 조각이 위치할 방향의 벡터

private float _arrowRotationZ;

[SerializeField, Header("Debug")]
private int _selectedIndex = -1;

private static readonly Color SelectedPieceColor    = new Color(1f, 1f, 1f, 1f);
private static readonly Color NotSelectedPieceColor = new Color(1f, 1f, 1f, 0.3f);
```


<br>

## **메소드**

```cs
private void Awake()
{
    InitPieceImages();
    InitPieceDirections();
    HideGameObject();
}

/// <summary> 조각 샘플 복제하여 조각들 생성 </summary>
private void InitPieceImages()
{
    _pieceSample.SetActive(true);

    _pieceImages = new Image[_pieceCount];
    _pieceRects = new RectTransform[_pieceCount];

    for (int i = 0; i < _pieceCount; i++)
    {
        // 조각 복제
        var clone = Instantiate(_pieceSample, transform);
        clone.name = $"Piece {i}";

        // Image, RectTransform 가져와 배열에 초기화
        _pieceImages[i] = clone.GetComponent<Image>();
        _pieceRects[i] = _pieceImages[i].rectTransform;
    }

    _pieceSample.SetActive(false);
}

/// <summary> 시계 극좌표계를 이용해 각 조각들의 방향벡터 계산 </summary>
private void InitPieceDirections()
{
    _pieceDirections = new Vector2[_pieceCount];

    float angle = 360f / _pieceCount;

    for (int i = 0; i < _pieceCount; i++)
    {
        _pieceDirections[i] = new ClockwisePolarCoord(1f, angle * i).ToVector2();
    }
}

private void ShowGameObject()
{
    gameObject.SetActive(true);
}

private void HideGameObject()
{
    gameObject.SetActive(false);
}

/// <summary> 모든 조각의 색상 변경 </summary>
private void ResetAllPieceColors()
{
    for (int i = 0; i < _pieceCount; i++)
    {
        _pieceImages[i].color = NotSelectedPieceColor;
    }
}

/// <summary> 현재 선택된 조각의 색상 변경 </summary>
private void SetSelectedPieceColors()
{
    ResetAllPieceColors();
    if(_selectedIndex >= 0)
        _pieceImages[_selectedIndex].color = SelectedPieceColor;
}

/// <summary> 화살표 이미지의 회전 설정 </summary>
private void SetArrowRotation(bool show)
{
    _arrow.gameObject.SetActive(show);

    if (show)
    {
        _arrow.eulerAngles = Vector3.forward * _arrowRotationZ;
    }
}

/// <summary> 등장 </summary>
public void Show()
{
    ShowGameObject();
    ResetAllPieceColors();
    SetArrowRotation(false);
    _selectedIndex = -1;

    StartCoroutine(nameof(MainRoutine));
}

/// <summary> 사라지면서 인덱스 리턴 </summary>
public int Hide()
{
    StopCoroutine(nameof(MainRoutine));
    HideGameObject();

    return _selectedIndex;
}

/// <summary> 각각 피스 이미지(스프라이트) 등록 </summary>
public void SetPieceImageSprites(Sprite[] sprites)
{
    int i = 0;
    int len = sprites.Length;
    for (; i < _pieceCount && i < len; i++)
    {
        if (sprites[i] != null)
        {
            _pieceImages[i].sprite = sprites[i];
        }
    }
}
```

게임 시작 시, `InitPieceImages()` 메소드를 통해 미리 준비한 Piece 게임오브젝트를 목표한 조각의 개수만큼 복제한다.

그리고 복제된 게임오브젝트들로부터 `Image`, `RectTransform` 컴포넌트를 가져와 각각 `_pieceImages`, `_pieceRects` 배열에 담아놓는다.

추후 각 조각들의 색상 및 위치 변경에 사용된다.

<br>

`InitPieceDirections()` 메소드에서는 각 조각들이 위치할 방향의 방향벡터들을 계산하여 배열에 초기화한다.

이때, 미리 만들어놓은 `ClockwisePolarCoord` 구조체를 활용한다.

예를 들어 조각의 개수가 2개일 경우 각각 0도(상단), 180도(하단)에 해당하는 방향벡터를 갖고,

3개일 경우에는 0도부터 시작하여 120도 간격으로,

8개일 경우에는 0도부터 시작하여 360 / 8 = 45도 간격으로 분포한다.

여기서 모든 방향벡터의 크기는 1이며, 

벡터의 크기(radius)와 각도(angle)를 이용해 `ClockwisePolarCoord` 구조체를 생성하고 `.ToVector2()` 메소드를 통해 직교좌표계의 방향벡터로 간단히 변환할 수 있다.


<br>

## **코루틴**

```cs
private IEnumerator MainRoutine()
{
    float t = 0;
    int prevSelectedIndex = -1;

    // 1. 등장
    while (t < _appearanceDuration)
    {
        // 중앙으로부터의 거리 계산
        float dist = t * _pieceDist / _appearanceDuration;

        // 각 조각들을 중앙에서부터 서서히 이동
        for (int i = 0; i < _pieceCount; i++)
        {
            _pieceRects[i].anchoredPosition = _pieceDirections[i] * dist;
        }

        t += Time.deltaTime;
        yield return null;
    }

    // 2. 유지
    while (true)
    {
        bool showArrow = false;

        // 마우스의 스크린 내 좌표(0.0 ~ 1.0 범위)
        var mViewportPos = Camera.main.ScreenToViewportPoint(Input.mousePosition);

        // 스크린의 중앙을 (0, 0)으로 하는 마우스 좌표(-0.5 ~ 0.5 범위)
        var mPos = new Vector2(mViewportPos.x - 0.5f, mViewportPos.y - 0.5f);

        // 중앙에서 마우스까지의 거리
        var mDist = new Vector2(mPos.x * Screen.width / Screen.height, mPos.y).magnitude;

        // 마우스가 중앙에 가까이 위치하면 조각 선택 해제
        if (mDist < _centerDistThreshold)
        {
            _selectedIndex = -1;
        }
        else
        {
            // 마우스 위치의 직교 좌표를 시계 극좌표로 변환
            ClockwisePolarCoord mousePC = ClockwisePolarCoord.FromVector2(mPos);

            // Arrow 회전 설정
            _arrowRotationZ = -mousePC.Angle;
            showArrow = true;

            // 각도로부터 배열 인덱스 계산
            float fIndex = (mousePC.Angle / 360f) * _pieceCount;
            _selectedIndex = Mathf.RoundToInt(fIndex) % _pieceCount;
        }

        // 선택된 조각 색상 변경
        if(prevSelectedIndex != _selectedIndex)
            SetSelectedPieceColors();

        // 화살표 회전
        SetArrowRotation(showArrow);

        yield return null;

        prevSelectedIndex = _selectedIndex;
    }
}
```

<br>

코루틴 내부는 총 두 부분으로 나뉜다.

첫 번째는 메뉴가 나타날 때 애니메이션을 표현하는 부분이다.

인스펙터를 통해 지정한 `_appearanceDuration` 시간(초) 만큼 지속되며,

지속 시간 동안 매 프레임마다 화면 중앙으로부터 각 조각들까지의 거리를 계산하여

조각들을 점차 중심으로부터 멀리 이동시킨다.

<br>

두 번째는 등장 애니메이션이 종료되고 메뉴가 유지되는 부분이다.

역시 `yield return null;`을 통해 매 프레임 검사하며,

우선 마우스의 스크린 내 좌표를 (-0.5, -0.5) ~ (0.5, 0.5) 범위로 얻어낸다.

마우스가 스크린 중앙에 위치할 경우 좌표는 (0, 0)이다.

그리고 이 좌표를 시계 극좌표로 변환하면 마우스가 위치한 곳의 각도를 간단히 얻어낼 수 있다.

이 각도를 이용해 Arrow 이미지의 회전을 결정하고, 0 ~ `_pieceCount - 1` 사이에서 알맞은 조각 인덱스 값을 계산한다.

그리고 계산된 인덱스를 `_selectedIndex`에 초기화한다.

마우스의 위치에 따라 상단에서부터 시계방향으로 조각의 인덱스가 결정된다.


<br>

# 동작 테스트
---

## **Radial Menu 인스펙터 설정**

![image](https://user-images.githubusercontent.com/42164422/116211584-eedb4f00-a77e-11eb-9a07-62944e68345c.png)

- `Piece Count` : 생성될 조각의 개수
- `Appearance Duration` : 등장 애니메이션 지속 시간(초)
- `Piece Dist` : 중심으로부터 각 조각까지의 거리
- `Center Dist Threshold` : 중심으로부터 조각들을 인식하지 않을 범위

- `Piece Sample` : 복제될 조각 게임오브젝트
- `Arrow` : 화살표 이미지의 부모 게임오브젝트

- `Selected Index` : 현재 선택된 조각의 인덱스

<br>

## **테스트 스크립트 작성**

```cs
public class Test_RadialMenu : MonoBehaviour
{
    public RadialMenu radialMenu;
    public KeyCode key = KeyCode.G;

    private void Update()
    {
        if (Input.GetKeyDown(key))
        {
            radialMenu.Show();
        }
        else if (Input.GetKeyUp(key))
        {
            int selected = radialMenu.Hide();
            Debug.Log($"Selected : {selected}");
        }
    }
}
```

테스트를 위한 스크립트는 위와 같이 간단히 작성할 수 있다.

`RadialMenu`의 참조와 테스트를 위한 키값이 필요하며

해당 키를 눌렀을 때 메뉴가 등장하고, 키를 유지하는 동안 마우스를 움직이며 각각의 조각들을 선택할 수 있다.

그리고 키를 뗐을 때 메뉴가 사라지며, 마지막으로 선택된 조각의 인덱스가 콘솔 창의 로그를 통해 기록된다.

<br>

# 상태 분리
---

Radial Menu는 Show(나타나기) - Keep(유지) - Hide(사라지기) 이렇게 세 가지 상태로 구분할 수 있다.

위에서는 Show - Update를 하나의 코루틴 내에서 작성하고 Hide는 단순히 비활성화로 구현했지만,

각각의 상태를 분리하고 스크립트 애니메이션을 구현하면 원하는대로 다양한 효과들을 독립적으로 만들고 적용할 수 있다.

여기에 상태 패턴, 그 중에서도 FSM(Finite State Machine, 유한 상태 머신)을 이용한다.

<br>



<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>


# Download
---
- [Radial Menu_v1.zip](https://github.com/rito15/Images/files/6382713/2021_0426_Radial.Menu_v1.zip)


# References
---
- 

