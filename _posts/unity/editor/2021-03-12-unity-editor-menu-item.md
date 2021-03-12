---
title: Menu Item
author: Rito15
date: 2021-03-12 20:10:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp, menuitem]
math: true
mermaid: true
---

# 메뉴 아이템 기본

```cs
private const string MenuItemTitle = "Window/Rito/Menu Item";
private const int MenuItemPriority = 123;

[MenuItem(MenuItemTitle)]
private static void MenuItem1()
{
    // ..
}

[MenuItem(MenuItemTitle, false, MenuItemPriority)]
private static void MenuItem2()
{
    // ..
}
```

<br>

# 활성화/비활성화 설정

```cs
private const string MenuItemTitle = "Window/Rito/Menu Item";

[MenuItem(MenuItemTitle, false)]
private static void MenuItem()
{
    // ..
}

[MenuItem(MenuItemTitle, true)] // true : Validate 메소드, false : 일반 메뉴아이템 메소드
private static bool MenuItem_Validate()
{
    return true; // true, false 여부에 따라 활성화, 비활성화
}
```

<br>

# 체크박스 추가하기


```cs
private const string MenuItemTitle = "Window/Rito/Menu Item";

// 필드로 사용하면 컴파일 시, 플레이모드 진입 시 초기화됨
//private static bool MenuItemChecked = true;

// 메뉴아이템 이름으로 Pref 깔끔하게 사용
private static bool MenuItemChecked
{
    get => EditorPrefs.GetBool(MenuItemTitle, true);
    set => EditorPrefs.SetBool(MenuItemTitle, value);
}

[MenuItem(MenuItemTitle, false)]
private static void MenuItem()
{
    // 체크 상태 변경은 메뉴아이템 메소드에서 수행
    MenuItemChecked = !MenuItemChecked;
}

[MenuItem(MenuItemTitle, true)]
private static bool MenuItem_Validate()
{
    // 체크 상태 갱신은 Validate 메소드에서 수행
    Menu.SetChecked(MenuItemTitle, MenuItemChecked);
    return true;
}

```

<br>

# 컨텍스트 메뉴 아이템 : 컴포넌트 우클릭 메뉴

```cs
[MenuItem ("CONTEXT/Transform/Menu Name")]
private static void RandomRotation (MenuCommand command)
{
    var transform = command.context as Transform;

    Undo.RecordObject (transform, SOME_ACTION);
    transform.rotation = Random.rotation;
}

// 활성화 / 비활성화 여부 결정
[MenuItem ("CONTEXT/Transform/Menu Name", true)]
private static bool RandomRotation_Validate (MenuCommand command)
{
    return true; // true, false 여부에 따라 활성화, 비활성화
}
```

<br>

# References
---
- <https://ijemin.com/blog/unity-editor-extensions-menu-items/>