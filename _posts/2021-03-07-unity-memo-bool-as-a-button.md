---
title: bool 타입 필드를 인스펙터에서 버튼처럼 사용하기
author: Rito15
date: 2021-03-07 01:33:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, button]
math: true
mermaid: true
---

# 인스펙터의 버튼
---

컴포넌트의 인스펙터에서 버튼을 사용하고 싶을 때가 있다.

예를 들면 플레이 모드로 진입하지 않고 에디터 모드에서 메소드를 바로 호출 하고 싶을 때.

그리고 실제로 커스텀 에디터를 이용해 버튼을 만들 수도 있다.

<br>

하지만 잠깐 테스트용으로 쓰려는데 스크립트 하나 더 만들고, 커스텀 에디터 선언하고, ...

심지어 에디터 GUI좀 쓰려면 EditorGUI, EditorUtility, EditorGUILayout, GUIUtility, GUILayout, ... 뭐가 이렇게 다양하고 헷갈리게 만들어 놨는지,

어쨌든 커스텀 에디터 만들어서 if(GUILayout.Button()){} 으로 버튼 하나 달아서 사용할 수 있다.

그러니까, 가끔씩 이게 참 번거롭다.

<br>

# bool 필드를 버튼처럼 사용하기
---

유니티 모노비헤이비어의 이벤트 함수 69개 중에, `OnValidate()`라는 녀석이 있다.

스크립트가 컴포넌트로 들어가거나 클래스 내의 변수의 값이 수정될 때 호출된다.

이걸 이용해서 마치 버튼처럼 사용할 수 있다.

버튼을 눌러 사용하듯이, 간단히 눌러 사용하기 위한 변수로는 bool 타입이 적합하니 이 두 가지를 이용하여

```cs
public bool _flag;

private void OnValidate()
{
    if (_flag)
    {
        Method();
        _flag = false;
    }
}

private void Method()
{
    Debug.Log("Method");
}
```

이런 식으로 작성한다.

인스펙터에서 _flag 필드를 체크하여 값을 true로 바꿨을 때 `OnValidate()`가 호출되고,

다시 값을 false로 바꿔 놓으며 `Method()`를 호출한다.

![2021_0307_BoolAsButton](https://user-images.githubusercontent.com/42164422/110214320-627f7f00-7ee7-11eb-838c-305c440a6ac7.gif)

그러면 위처럼 에디터 모드에서도 _flag 필드를 클릭했을 때 메소드를 곧바로 호출할 수 있다.

<br>

![2021_0307_BoolAsButton2](https://user-images.githubusercontent.com/42164422/110214323-64e1d900-7ee7-11eb-8cc1-ca87cb773053.gif)

이렇게 에디터 모드에서 다른 필드의 값을 수정할 수도 있고, 그 값이 플레이모드에 진입해도 유지된다.

굳이 이렇게 사용할 일은 딱히 없을 듯하지만, 유의해야 할 것 같다.

<br>

# References
---
- <https://docs.unity3d.com/kr/530/ScriptReference/MonoBehaviour.OnValidate.html>