---
title: 유니티 에디터 - 게임 뷰 객체 찾기
author: Rito15
date: 2021-11-05 02:10:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---
- 흔히 게임 뷰라고 알려져 있는 에디터 윈도우는 `UnityEditor.PlayModeView` 타입이다.
- 리플렉션을 통해 접근할 수 있다.

<br>

# Source Code
---

{% include codeHeader.html %}
```cs
private static Type GameViewType
{
    get
    {
        if (gameViewType == null)
        {
            gameViewType =
                AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(ass => ass.GetTypes())
                .Where(t => t.Namespace == "UnityEditor" && t.Name == "PlayModeView")
                .FirstOrDefault();

            if (gameViewType == null)
            {
                throw new Exception("UnityEditor.PlayModeView does NOT exist in current version.");
            }
        }
        return gameViewType;
    }
}
private static Type gameViewType;


/// <summary> 열려 있는 게임 뷰 하나 찾아서 반환 </summary>
private static EditorWindow GameView
{
    get
    {
        if (_gameView != null)
            return _gameView;

        UnityEngine.Object[] gameViews = Resources.FindObjectsOfTypeAll(GameViewType);
        if (gameViews.Length > 0)
        {
            _gameView = gameViews[0] as EditorWindow;
            return _gameView;
        }

        return null;
    }
}
private static EditorWindow _gameView;


/// <summary> 현재 포커스된 게임 뷰 반환 </summary>
private static EditorWindow ActiveGameView
{
    get
    {
        if (_activeGameView != null && _activeGameView.hasFocus)
            return _activeGameView;
        
        UnityEngine.Object[] gameViews = Resources.FindObjectsOfTypeAll(GameViewType);
        for (int i = 0; i < gameViews.Length; i++)
        {
            EditorWindow current = gameViews[i] as EditorWindow;
            if (current != null && current.hasFocus)
            {
                _activeGameView = current;
                return _activeGameView;
            }
        }

        return null;
    }
}
private static EditorWindow _activeGameView;
```

<br>

# References
---
- <https://github.com/Unity-Technologies/UnityCsReference/blob/master/Editor/Mono/PlayModeView/PlayModeView.cs>