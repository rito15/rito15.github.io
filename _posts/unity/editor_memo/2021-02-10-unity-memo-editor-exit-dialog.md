---
title: 유니티 에디터 종료 확인 다이얼로그 만들기
author: Rito15
date: 2021-02-10 13:50:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, dialog, csharp]
math: true
mermaid: true
---

# Memo
---

기본적으로 유니티 에디터를 종료할 때는 확인창이 뜨지 않고 바로 종료된다.

만약 실수로 닫기 버튼을 눌러버린다면 그대로 종료되어 버린다.

그런데 유니티 에디터는 에디터의 종료도 이벤트로 구분하여, 메소드를 추가할 수 있도록 구현해놓았기 때문에

이를 이용해 에디터의 종료를 시도할 경우 확인창을 띄우도록 할 수 있다.

<br>

```cs
[InitializeOnLoad]
public class EditorExitDialog
{
    static EditorExitDialog()
    {
        EditorApplication.wantsToQuit += 
            () => EditorUtility.DisplayDialog("Unity Editor", "Are you sure to quit ?", "Yes", "No");
    }
}
```

이렇게 간단한 소스코드를 작성하여 유니티 프로젝트 내에 위치시키면 된다.

정적 생성자 `static EditorExitDialog()`는 원래 게임이 시작될 때 한 번 실행된다.

그런데 `[InitializeOnLoad]`를 붙임으로써, 게임이 시작되지 않아도 컴파일 되는 순간에 실행된다.

따라서 에디터에서 위와 같이 특정 이벤트에 원하는 메소드를 등록할 수 있다.

<br>

그리고 에디터에 종료 신호를 보내는 순간에 `EditorApplication.wantsToQuit` 이벤트가 호출되는데,

`EditorUtility.DisplayDialog` 메소드는 확인/취소 버튼이 존재하는 다이얼로그를 띄우고 확인 버튼을 눌렀을 때는 true, 취소 버튼을 누르면 false를 리턴하게 되므로

확인 버튼을 누르면 에디터가 종료되며, 취소 버튼을 누르면 에디터 종료를 취소하게 된다.

![image](https://user-images.githubusercontent.com/42164422/107467206-ea07f580-6ba8-11eb-9716-f6e7401ad10e.png)

<br>

# Download
---
- [EditorExitDialog.zip](https://github.com/rito15/Images/files/5955948/EditorExitDialog.zip)