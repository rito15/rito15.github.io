---
title: Debug.Log에 색상 넣기
author: Rito15
date: 2021-04-25 17:10:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Memo
---
- `<color=></color>` 태그를 사용하여 로그 메시지에 색상을 넣을 수 있다.
- `color=` 뒤에는 색상 이름 또는 HTML 색상코드를 입력한다.

<br>

```cs
Debug.Log("Default");
Debug.Log("<color=white>White</color>");
Debug.Log("<color=grey>Grey</color>");
Debug.Log("<color=black>Black</color>");
Debug.Log("<color=red>Red</color>");
Debug.Log("<color=green>Green</color>");
Debug.Log("<color=blue>Blue</color>");
Debug.Log("<color=yellow>Yellow</color>");
Debug.Log("<color=cyan>Cyan</color>");
Debug.Log("<color=brown>Brown</color>");

Debug.Log("<color=#FAD656>Custom 1</color>");
Debug.Log("<color=#00FF22>Custom 2</color>");
```

![image](https://user-images.githubusercontent.com/42164422/115986319-97a47580-a5ea-11eb-9357-bb5f600872a1.png)


<br>

# References
---
- <https://docs.unity3d.com/ScriptReference/Debug.Log.html>