---
title: 커스텀 에디터(인스펙터)의 스크롤바를 고려한 너비 구하기
author: Rito15
date: 2021-06-13 23:33:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

# Note
---

커스텀 에디터에서 `EditorGUIUtility.currentViewWidth`를 통해 현재 에디터의 너비를 구할 수 있지만,

![image](https://user-images.githubusercontent.com/42164422/121812395-9ca8ab80-cca2-11eb-91e8-1c9f00c26e33.png)

위처럼 컴포넌트 창이 상하로 길어져 우측에 스크롤바가 생기는 경우

스크롤바가 컨트롤들을 가림에도 불구하고, `currentViewWidth`는 스크롤바를 포함한 너비를 알려주며

스크롤바를 제외한 너비를 구하는 API가 제공되지 않는다.

심지어 스크롤바의 존재 여부조차 스크립트를 통해서는 알 수 없다.

따라서 편법을 통해 구해야 한다.

<br>

# How to
---

**Layout API**들을 통해 만들어진 Rect는 항상 에디터창의 우측 스크롤바의 너비를 제외한 영역에 만들어지므로,

이렇게 참조한 Rect의 너비는 스크롤바의 존재유무에 따라 유동적으로 변하게 된다.

<br>

`GUILayoutUtility.GetLastRect()` 메소드는 레이아웃 요소로 마지막에 그려진 Rect를 리턴한다.

`EditorGUILayout.Space()` 메소드는 단순히 상하 커서만 이동시키는 것처럼 보이지만,

내부적으로는 커서를 이동한 만큼의 영역에 Rect를 하나 생성하며

따라서 `GetLastRect()`를 통해 이 영역을 참조할 수도 있다.

<br>

이를 이용하여,

`Space(0f)`로 높이가 0f인 Rect를 내부적으로 생성하고

`GetLastRect()`를 통해 이 Rect의 너비를 참조하면

스크롤바를 고려한 너비와 스크롤바 존재 유무를 계산할 수 있다.

<br>

```cs
private class CE : UnityEditor.Editor
{
    /// <summary> 스크롤바 포함, 전체 뷰 너비 </summary>
    private float CurrentViewWidth { get; set; }

    /// <summary> 스크롤바 제외한 전체 뷰 너비 </summary>
    private float FlexibleViewWidth { get; set; }

    /// <summary> 스크롤바 존재 유무 </summary>
    private bool IsScrollBarExisted { get; set; }

    private void CalculateViewWidth()
    {
        EditorGUILayout.Space(0f);
        FlexibleViewWidth  = GUILayoutUtility.GetLastRect().width + 23f;
        CurrentViewWidth   = EditorGUIUtility.currentViewWidth;
        IsScrollBarExisted = (CurrentViewWidth != FlexibleViewWidth);
    }

    public override void OnInspectorGUI()
    {
        CalculateViewWidth();

        // GUI Codes..
    }
}
```

<br>
