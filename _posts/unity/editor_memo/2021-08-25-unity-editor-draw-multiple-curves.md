---
title: 유니티 에디터 GUI - 여러 개의 커브를 겹쳐 그리기
author: Rito15
date: 2021-08-25 03:00:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

`EditorGUI.CurveField()`를 통해 `AnimationCurve`를 에디터에 그릴 수 있다.

그런데 일반적인 방법으로는 하나의 커브 필드에 하나의 커브만 그려진다.

커브 필드에는 불투명한 배경 색상이 존재하기 때문이다.

- (`0.337f, 0.337f, 0.337f, 1f`)

![image](https://user-images.githubusercontent.com/42164422/130670590-951e34c7-e4a5-402c-a78e-87fa61552441.png)

<br>

따라서 이를 해결하기 위해서는, 리플렉션을 이용한 편법을 사용해야 한다.

```cs
private static FieldInfo fiCurveBGColor;
private static Color defaultCurveBGColor;

private void DrawSomeCurveField()
{
    // 리플렉션을 통해 배경 색상 필드 정보 참조
    if (fiCurveBGColor == null)
    {
        fiCurveBGColor = typeof(EditorGUI).GetField("kCurveBGColor", BindingFlags.Static | BindingFlags.NonPublic);
        defaultCurveBGColor = (Color)fiCurveBGColor.GetValue(null);
    }

    // 커브 필드의 배경 색상을 투명하게 설정
    fiCurveBGColor.SetValue(null, Color.clear);

    // curveRect : 여러 개의 커브를 겹쳐 그릴 위치의 Rect
    // 예시 : Rect curveRect = GUILayoutUtility.GetRect(1f, 80f);
    Rect curveRect = ....;


    // 불투명한 커브 배경 한 번 그려주기
    EditorGUI.DrawRect(curveRect, defaultCurveBGColor);


    /**************************************************/
    /*           여러 개의 커브 그리기                */
    /**************************************************/


    // 커브 배경 색상 필드에 기존 값 복원
    fiCurveBGColor.SetValue(null, defaultCurveBGColor);
}
```

위와 같이 리플렉션을 통해 커브 필드의 배경 색상으로 적용되는 `EditorGUI.kCurveBGColor` 필드 정보를 가져온다.

그리고 여러 개의 커브 필드를 그리기 전에 잠깐 배경 색상을 투명하게 바꾸고,

커브 필드를 겹쳐 그린 다음 다시 배경 색상을 복원해주면 된다.

![image](https://user-images.githubusercontent.com/42164422/130672171-bbfddb47-28a9-4f53-9d37-d7b35f783ad9.png)

<br>

그리고  `CurveField(... Rect ranges)`로 들어가는 `ranges` 매개변수를 통해 커브들의 표현 범위를 통일시켜줄 수 있다.

- `x` : 커브의 좌측 끝에 표시할 시작 시간(기본값 : `0`)
- `y` : 커브의 하단 끝에 표시할 시작 값
- `width` : 커브의 x축을 통해 표시할 전체 시간 길이
- `height` : 커브의 y축을 통해 표시할 전체 값 범위

<br>

## **TIP**

- `ranges` 매개변수의 기본 값은 `new Rect()` 또는 `default`

- 여러 개의 커브를 겹쳐 그릴 경우, 그래프의 일부가 가려져 안보일 수 있다.<br>
  이럴 때는 상하 또는 좌우로 `1px`씩 위치를 엇갈리게 그려주면 된다.

<br>

- 커브를 위의 그림과 같이 직선으로 구성하려면 다음과 같이 설정해주면 된다.

```cs
// AnimationUtility -> UnityEditor.AnimationUtility
// curve -> AnimationCurve 타입 변수

for (int i = 0; i < graph.length; i++)
{
    AnimationUtility.SetKeyLeftTangentMode( curve, i, AnimationUtility.TangentMode.Linear);
    AnimationUtility.SetKeyRightTangentMode(curve, i, AnimationUtility.TangentMode.Linear);
}
```

