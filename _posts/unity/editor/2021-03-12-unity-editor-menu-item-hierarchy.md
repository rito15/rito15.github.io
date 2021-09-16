---
title: 유니티 - 하이라키 우클릭 메뉴 아이템
author: Rito15
date: 2021-03-12 22:50:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

# 우클릭 MenuItem 메소드 중복 호출 방지하기
---

- 게임오브젝트를 다중 선택하고 우클릭 메뉴를 통해 실행했을 때 생기는 중복 호출 버그 방지

- 다이얼로그를 띄우면 방지 안되니 주의

```cs
private static string _prevMethodCallInfo = "";

/// <summary> 같은 메소드가 이미 실행됐었는지 검사 (중복 메소드 호출 제한용) </summary>
private static bool IsDuplicatedMethodCall([System.Runtime.CompilerServices.CallerMemberName] string memberName = "")
{
    string info = memberName + DateTime.Now.ToString();

    if (_prevMethodCallInfo.Equals(info))
    {
        return true;
    }
    else
    {
        _prevMethodCallInfo = info;
        return false;
    }
}

[MenuItem("GameObject/Rito/Test", priority = -999)]
private static void TestUsage()
{
    if(IsDuplicatedMethodCall()) return;

    // ...
}
```

<br>

# 현재 선택된 트랜스폼들을 필터링에 따라 가져오기
---

```cs
// 선택된 트랜스폼들 중에 루트들만, 프리팹 제외하고 가져오기
Selection.transforms;

/// <summary> 현재 선택된 트랜스폼들 중 계층 관계에 있는 것들은 최상위 부모만 필터링하여 가져오기 </summary>
private static Transform[] SelectedTopLevelTransforms => Selection.GetTransforms(SelectionMode.TopLevel);

/// <summary> 현재 선택된 모든 트랜스폼들을 필터링 없이 그대로 가져오기 </summary>
private static Transform[] SelectedAllTransforms
    => Selection.GetTransforms(SelectionMode.Unfiltered);
```

<br>



