---
title: 유니티 IMGUI 이벤트, 그리고 Getting control n's position... 예외 처리
author: Rito15
date: 2021-09-05 18:00:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, imgui]
math: true
mermaid: true
---

# IMGUI 이벤트
---

유니티 IMGUI에서 `OnGUI()` 메소드가 호출되는 이벤트 타이밍은

기본적으로 `Layout`과 `Repaint`가 있다.

`Layout`은 GUI 레이아웃 컨트롤을 생성하는 단계이고,

`Repaint`은 GUI 컨트롤들을 화면에 그려내는 단계이다.

별도의 상호작용이나 간섭이 없다면 `Layout`과 `Repaint`가 반복된다.

`Event.current`를 통해 현재 IMGUI 환경에서의 이벤트 객체를 참조할 수 있고,

`Event.current.type`을 통해 현재 처리되는 이벤트의 종류를 알 수 있다.

<br>

사용자 상호작용이 발생할 경우, 사용자 상호작용에 따라

마우스를 눌렀으면 `Layout` - `MouseDown` 순서로 이벤트가 발생하여

`MouseDown` 이벤트에서 사용자의 마우스 입력 이벤트를 처리한다.

키보드를 눌렀으면 마찬가지로 `Layout` - `KeyDown`,

버튼을 눌렀으면 `Layout` - `Used` 순서로 이벤트가 발생한다.

다른 이벤트들도 모두 마찬가지다.

<br>

# 고정 레이아웃 컨트롤과 자동 레이아웃 컨트롤
---

IMGUI의 컨트롤은 크게 **고정 레이아웃 컨트롤**, **자동 레이아웃 컨트롤**로 나뉜다.

**고정 레이아웃 컨트롤**은 `GUI`, `EditorGUI` 클래스를 통해 그려지며

그려질 컨트롤의 위치가 고정적인 위치에 결정된다.

**자동 레이아웃 컨트롤**은 `GUILayout`, `EditorGUILayout` 클래스를 통해 그려지며

그려질 컨트롤의 위치가 내부적으로 알아서 계산되어 결정된다.

<br>

# 레이아웃 엔트리와 커서
---

**자동 레이아웃 컨트롤**들은 하나의 엔트리(리스트) 내에 저장된다.

그리고 이 엔트리를 순회하는 정수형 커서가 존재한다.

(`UnityEngine.GUILayoutGroup.entries`, `UnityEngine.GUILayoutGroup.m_Cursor`)

`Layout` 이벤트에서는 이 컨트롤들을 엔트리에 차례로 저장하고,

`Repaint` 이벤트에서는 커서를 이동시켜서 저장된 컨트롤들을 순회하면서 화면에 그려낸다.

<br>

사용자 상호작용 혹은 명령 처리 등의 다른 이벤트가 발생하는 경우에도 마찬가지이다.

마우스 클릭 이벤트가 발생할 경우 `Layout` 이후에 `MouseDown` 이벤트가 발생하여 마우스 이벤트를 처리하고,

키보드 이벤트가 발생할 경우 `Layout` 이후에 `KeyDown` 이벤트가 발생한다.

`Layout` 이벤트에서 엔트리를 확정하고,

이어지는 다른 이벤트에서 커서를 이동시켜 컨트롤들을 확인하거나 변경 사항을 처리한다.

<br>

# 예외가 발생하는 경우
---

```
Getting control [cursor]'s position in a group with only [entry count] controls
when doing [eventType] Aborting
```

간혹 위와 같은 예외가 발생하는 경우가 있다.

발생 원인은 보통 두 가지 경우이다.

1. `OnGUI()` 메소드 내부에서, 그려야 할 자동 레이아웃 컨트롤의 개수가 변경된 경우

2. 다른 스레드가 자동 레이아웃 컨트롤 개수를 간접적으로 변경시킨 경우

<br>

그리고 근본적인 원인은 다음과 같다.

- `Layout` 이벤트 도중에 레이아웃 엔트리에 변경이 생긴 경우

<br>

그러니까, `Layout` 이벤트에서 고정된 레이아웃 엔트리를 확보해야 하는데

이 이벤트 동안 갑자기 의도치 않은 레이아웃 엔트리 변동이 생겨서

이어지는 이벤트에서 레이아웃 엔트리의 불일치를 확인하고 예외를 발생시키는 것이다.

<br>

자동 레이아웃 컨트롤이 아닌 `GUI`, `EditorGUI`에 의한 고정 레이아웃 컨트롤은

위의 문제가 발생하지 않는다.

<br>

# 예외 해결 방법
---

해결의 핵심은 다음과 같다.

- 레이아웃 엔트리의 변경이 발생할 수 있는 경우, `Layout` 이벤트를 피해서 변경을 적용한다.

<br>

## **[1] 싱글 스레드 환경**

```cs
if(GUILayout.Button("Add New Element to List"))
{
    someList.Add(...);
}
```

이렇게 버튼을 이용해 사용자 상호작용을 통해 레이아웃 엔트리를 변경하는 경우는 상관 없다.

사용자 상호작용이 있는 경우, `Layout`이 아닌 다른 이벤트에 의해 처리되기 때문이다.

버튼 클릭 이벤트는 `Used` 이벤트를 통해 처리된다.

<br>

```
if(condition)
    DrawSomeLayout();
else
    DontDraw();
```

이렇게 사용자 상호작용이 아닌 조건에 따라 레이아웃 엔트리가 변경될 여지가 있다면,

`Layout` 이벤트 동안에는 조건이 변경되지 않도록 해야 한다.

<br>

시간의 진행에 따라 레이아웃 엔트리가 변경되는 예시를 하나 살펴보자.

```cs
private int progress = 0;

private void OnGUI()
{
    if((progress % 3) < 1)
    {
        GUILayout.Button("깜빡깜빡");
    }
    
    progress++; // 레이아웃 엔트리 변경의 근본적인 원인
    
    Repaint();
}
```

사용자 상호작용이 아닌, `OnGUI()`에서의 변경에 의해 레이아웃 엔트리가 변경될 여지가 있다.

따라서 `Layout` 이벤트 내에서 엔트리가 변경될 수 있으므로,

```
ArgumentException: Getting control 0's position in a group
with only 0 controls when doing repaint Aborting
```

이런 예외가 반갑게 맞아준다.

<br>

이를 해결하는 것은 간단하다.

```cs
private int progress = 0;

private void OnGUI()
{
    if((progress % 3) < 1)
    {
        GUILayout.Button("깜빡깜빡");
    }
    
    // Layout 이벤트에서는 변경이 발생하지 않도록 제한
    if (Event.current.type != EventType.Layout)
        progress++;
        
    Repaint();
}
```

위와 같이 레이아웃 엔트리 변경의 근본적인 원인이 되는 부분에서

`Layout` 이벤트를 피해서 변경이 발생하도록 해주면 된다.

<br>

## **[2] 멀티 스레드 환경**

무거운 작업이나 읽기/쓰기 처리의 경우 워커 스레드로 넘겨 처리하고,

결과를 받아오게 되는 경우가 있다.

이런 경우에도 `Layout` 이벤트를 피해서 결과를 적용시켜야 하는데,

메인 스레드 디스패처 같은 방식으로 동기화 큐를 이용하면 좋다.

```cs
private bool isProcessingJob;

private void OnGUI()
{
    if(GUILayout.Button("Do"))
        Task.Run(() => DoWorkerThreadJob());
    
    if(isProcessingJob)
    {
        /*
            자동 레이아웃 컨트롤 : 처리 중 GUI
        */
    }
    else
    {
        /*
            자동 레이아웃 컨트롤 : 처리 결과 GUI
        */
    }
}

private void DoWorkerThreadJob()
{
    isProcessingJob = true;
    
    /* 작업 처리 */
    
    isProcessingJob = false;
}
```

간단히 위와 같은 형태가 있다고 할 때,

저대로 사용하면 어김없이 예외를 확인할 수 있다.

운좋게 `Layout` 이벤트를 피했으면 예외가 발생하지 않을 것이고,

`Layout` 이벤트에 변경이 적용되면 예외가 발생한다.

<br>

```cs
private bool isProcessingJob;
private readonly ConcurrentQueue<Action> guiSyncQueue
    = new ConcurrentQueue<Action>();

private void OnGUI()
{
    if(GUILayout.Button("Do"))
    {
        isProcessingJob = true; // Used 이벤트에서 변경 발생
        Task.Run(() => DoWorkerThreadJob());
    }
    
    if(isProcessingJob)
    {
        /*
            자동 레이아웃 컨트롤 : 처리 중 GUI
        */
    }
    else
    {
        /*
            자동 레이아웃 컨트롤 : 처리 결과 GUI
        */
    }
    
    // Layout 이벤트를 피해서, 위임 받은 변경사항 적용 처리
    if (Event.current.type != EventType.Layout/* && !guiSyncQueue.IsEmpty*/)
    {
        // Note : TryDequeue()는 내부적으로 IsEmpty를 먼저 참조한다.
        // 그러니 IsEmpty 이후 TryDequeue() 검사를 하면 창조적으로 손해를 보는 셈이다.
        
        if(guiSyncQueue.TryDequeue(out Action action))
        {
            action();
            Repaint();
        }
    }
}

private void DoWorkerThreadJob()
{
    /* 작업 처리 */
    
    // 변경사항 적용 위임
    guiSyncQueue.Enqueue(() => 
    {
        isProcessingJob = false;
    );
}
```

위와 같이 워커 스레드 작업은 처리와 변경 적용을 나누고,

스레드가 시작될 때 처리는 곧바로 진행하되

레이아웃 엔트리의 변경을 야기할 수 있는 변경 사항 적용 부분은

`Action`으로 래핑하여 큐에 넣어준다.

그리고 `OnGUI()`에서는 `Layout` 이벤트를 피해서 큐를 확인하고,

큐의 내용을 꺼내어 처리해주면 된다.

위와 같이 한 번에 하나씩 꺼내어 처리할 수도 있고,

변경사항 적용이 곧바로 이루어져야 하는 경우에는 큐의 모든 내용을 꺼내어 처리하도록 한다.

<br>

# 부록 : 커서와 엔트리 개수 확인하기
---

<details>
<summary markdown="span"> 
...
</summary>

```cs
// OnGUI() 내에서 호출
private static void CheckCursorAndLayoutEntry(int index)
{
    Type GetTypeFromDomain(string typeName)
    {
        return AppDomain.CurrentDomain.GetAssemblies()
                .SelectMany(ass => ass.GetTypes())
                .Where(t => t.Name == typeName)
                .FirstOrDefault();
    }

    Type tLayoutCache = GetTypeFromDomain("LayoutCache");
    Type tGUILayoutGroup = GetTypeFromDomain("GUILayoutGroup");

    FieldInfo fiCurrent = typeof(GUILayoutUtility).GetField("current", BindingFlags.NonPublic | BindingFlags.Static);
    object current = fiCurrent.GetValue(null);

    FieldInfo fiTopLevel = tLayoutCache.GetField("topLevel", BindingFlags.NonPublic | BindingFlags.Instance);
    object topLevel = fiTopLevel.GetValue(current);

    FieldInfo fiM_Cursor = tGUILayoutGroup.GetField("m_Cursor", BindingFlags.NonPublic | BindingFlags.Instance);
    object m_Cursor = fiM_Cursor.GetValue(topLevel);

    FieldInfo fiEntries = tGUILayoutGroup.GetField("entries", BindingFlags.Public | BindingFlags.Instance);
    object entries = fiEntries.GetValue(topLevel);

    Type tGUILayoutEntryList = entries.GetType();
    PropertyInfo piCount = tGUILayoutEntryList.GetProperty("Count", BindingFlags.Public | BindingFlags.Instance);
    object entriesCount = piCount.GetValue(entries);

    Debug.Log($"[{index}][{Event.current.type}] m_Cursor : {m_Cursor}, entries.Count : {entriesCount}");
}
```

</details>

<br>

# Future Works
---

- 본문의 해결책과는 반대로, 변경 사항이 `Layout` 이벤트 타이밍에 적용되어야만 예외가 해결되는 상황을 발견하여, 추후 정확히 원인을 파악하면 내용 추가 또는 수정

<br>

# References
---
- <https://docs.unity3d.com/kr/current/Manual/gui-Basics.html>
- <https://docs.unity3d.com/kr/current/Manual/gui-Layout.html>
- <https://blog.unity.com/technology/going-deep-with-imgui-and-editor-customization>