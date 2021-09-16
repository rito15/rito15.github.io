---
title: 유니티 - 스크립트 템플릿(Script Templates)
author: Rito15
date: 2021-01-29 16:55:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, script, templates]
math: true
mermaid: true
---

# 개념
---
- `Project` - 우클릭 - `Create`를 통해 만드는 스크립트 또는 텍스트의 템플릿을 미리 지정하는 기능
- 스크립트 템플릿의 저장 경로 :

```
C:\Program Files\유니티 버전\Editor\Data\Resources\ScriptTemplates
```

- 각각의 유니티 버전마다 따로 저장된다.
- 한가지 팁은, 스크립트 템플릿에 한 글자라도 애초에 한글이 작성되어 있지 않으면 나중에 한글 주석이라도 작성했을 때 인코딩이 깨져버릴 수 있으니 스크립트 템플릿 내에 아주 짧은 한글 주석을 적어 놓는게 좋다는 것

<br>

# 규칙
---
- 각각의 템플릿 파일의 이름 규칙은 다음과 같다.

```
[인덱스]-[템플릿 이름]-[생성 시 파일명.확장자].txt
```

- 예시 :

```
81-C# Script-NewBehaviourScript.cs.txt
```

- 인덱스는 숫자로, 낮을수록 우클릭 메뉴의 상단에 위치한다.
- 템플릿 이름은 우클릭 메뉴에서 보일 이름이다.

<br>

# 템플릿 내용
---
- 예시로 만든 템플릿 :

```
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 날짜 : #DATE#
// 작성자 : Rito

public class #SCRIPTNAME# : MonoBehaviour
{
    
    private void Awake()
    {
        #NOTRIM#
    }
    
    private void Start()
    {
        #NOTRIM#
    }

    private void Update()
    {
        #NOTRIM#
    }
}
```

- 기본 모노비헤이비어 생성 템플릿에 주석 두 줄을 추가했다.
- 추후에 한글 인코딩이 깨지지 않도록 미리 한글 주석을 적어놓았다.
- `#`으로 감싸인 단어들이 보이는데, 이는 파일 생성 시 지정된 이름으로 바뀌게 된다.
- `#SCRIPTNAME#`은 파일 생성 시 입력한 스크립트명으로 바뀐다.
- `#NOTRIM#`은 공백을 의미한다.
- `#DATE#`는 원래 지원하지 않지만, 아래의 `KeywordReplace` 스크립트를 통해 현재 날짜로 바꿔줄 수 있다.

<br>

# KeywordReplace.cs
---
- [KeywordReplace.zip](https://github.com/rito15/Images/files/5892481/KeywordReplace.zip)

- 유니티 프로젝트 경로 내에 포함되기만 하면 동작한다.

- AssetModificationProcessor를 상속하여, 파일이 생성될 때 이 스크립트의 동작을 거쳐갈 수 있게 한다.

- `#DATE#` 키워드를 현재 날짜 및 시각으로 바꿔주는 코드가 작성되어 있으며, 다른 키워드도 추가하여 변경하는 코드를 넣어줄 수 있다.