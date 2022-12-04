---
title: 유니티 - 매 프레임 처리 성능 테스트 - Update() vs 코루틴
author: Rito15
date: 2021-11-01 15:02:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 실험 목적
---

- 매 프레임 호출되는 `Update()` 메소드, 코루틴의 성능 비교

<br>


# 실험 조건
---

- 운영체제 : Windows 10
- 유니티 에디터 버전 : `2020.3.17f1`
- 실행 환경 : 유니티 에디터, Windows Standalone Build(Mono, IL2CPP)

<br>

# 실험 대상
---

## **[1] Update()**

- 각 컴포넌트마다 `Update()` 작성

<details>
<summary markdown="span">
UpdateEveryFrame.cs
</summary>

```cs
public class UpdateEveryFrame : MonoBehaviour
{
    private void Update() { }
}
```

</details>

<br>

## **[2] CustomUpdate()**

- 한 컴포넌트의 `Update()`에서 다른 컴포넌트들의 `CustomUpdate()` 호출

<details>
<summary markdown="span">
CustomUpdateCaller.cs
</summary>

```cs
public class CustomUpdateCaller : MonoBehaviour
{
    private static CustomUpdateCaller singleton;
    private List<CustomUpdateCallee> list = new List<CustomUpdateCallee>(100000);

    public static void AddElement(CustomUpdateCallee element)
    {
        singleton.list.Add(element);
    }

    private void Awake()
    {
        singleton = this;
    }

    private void Update()
    {
        foreach (var item in list)
        {
            item.CustomUpdate();
        }
    }
}
```

</details>

<details>
<summary markdown="span">
CustomUpdateCallee.cs
</summary>

```cs
public class CustomUpdateCallee : MonoBehaviour
{
    private void OnEnable()
    {
        CustomUpdateCaller.AddElement(this);
    }
    public void CustomUpdate() { }
}
```

</details>

<br>

## **[3] Coroutine - null**

- 무한 반복문 내에서 `yield return null`을 통해 매프레임 코루틴 검사

<details>
<summary markdown="span">
CoroutineEveryFrame.cs
</summary>

```cs
public class CoroutineEveryFrame : MonoBehaviour
{
    private void Start()
    {
        StartCoroutine(CoRoutine());
    }

    private IEnumerator CoRoutine()
    {
        while (true)
        {
            yield return null;
        }
    }
}
```

</details>

<br>

## **[4] Coroutine - WaitForEndOfFrame**

- 무한 반복문 내에서 `yield return new WaitForEndOfFrame()`을 통해 매프레임 코루틴 검사

<details>
<summary markdown="span">
CoroutineEveryFrame.cs
</summary>

```cs
public class CoroutineEveryFrame : MonoBehaviour
{
    private void Start()
    {
        StartCoroutine(CoRoutine());
    }

    private IEnumerator CoRoutine()
    {
        while (true)
        {
            yield return new WaitForEndOfFrame();
        }
    }
}
```

</details>

<br>

# 실험 통제 컴포넌트
---

<details>
<summary markdown="span">
UpdateCoroutineManager.cs
</summary>

```cs
public class UpdateCoroutineManager : MonoBehaviour
{
    private enum TestMode { Update, CustomUpdate, CoroutineNull, CoroutineEndOfFrame }

    [SerializeField] private int testCount = 100000;
    [SerializeField] private TestMode mode = TestMode.Update;

    [SerializeField] private int startFrame = 250;
    [SerializeField] private int frameCount = 100;

    private void Awake()
    {
        switch (mode)
        {
            case TestMode.Update:
                CreateUnits<Test_UpdateEveryFrame>();
                break;

            case TestMode.CustomUpdate:
                GameObject go = new GameObject("GO");
                go.AddComponent<Test_CustomUpdateCaller>();
                CreateUnits<Test_CustomUpdateCallee>();
                break;

            case TestMode.CoroutineNull:
                CreateUnits<Test_CoroutineEveryFrame>();
                break;

            case TestMode.CoroutineEndOfFrame:
                CreateUnits<Test_CoroutineEndOfFrame>();
                break;
        }

        void CreateUnits<T>() where T : MonoBehaviour
        {
            for (int i = 0; i < testCount; i++)
            {
                GameObject go = new GameObject("GO");
                go.hideFlags = HideFlags.HideInHierarchy;
                go.AddComponent<T>();
            }
        }
    }

    private float timeBegin;

    private void Update()
    {
        if (Time.frameCount == startFrame)
        {
            Log($"Start : {Time.frameCount}");
            timeBegin = Time.realtimeSinceStartup;
        }
        else if (Time.frameCount == (startFrame + frameCount))
        {
            float elapsedMS = (Time.realtimeSinceStartup - timeBegin) * 1000f / frameCount;
            Log($"Average(ms) : {elapsedMS:F2}");

#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPaused = true;
#endif
        }
    }

    private void Log(string log)
    {
        logString = log;
    }

    private string logString = "";
    private GUIStyle style;

    private void OnGUI()
    {
        if (style == null)
        {
            style = new GUIStyle(GUI.skin.box);
            style.fontSize = 48;
            style.alignment = TextAnchor.MiddleCenter;
        }

        Rect r = new Rect();
        r.x = Screen.width * 0.1f;
        r.y = Screen.height * 0.1f;
        r.width = Screen.width * 0.8f;
        r.height = Screen.height * 0.2f;

        GUI.Box(r, logString, style);
    }
}
```

</details>

<br>

# 실험 방법
---

1. `UpdateCoroutineManager` 컴포넌트에서 테스트 개수, 테스트 모드, 측정 시작 및 소요 프레임을 설정한다.
2. 유니티 에디터, Windows Mono 빌드, IL2CPP 빌드 환경에서 측정 결과를 확인한다.

<br>

# 실험 결과 - 1. 유니티 에디터
---

<details>
<summary markdown="span">
...
</summary>

## **[1] Update**

![image](https://user-images.githubusercontent.com/42164422/139634836-fd4ed0b0-d9ae-4904-9bde-b98925d36251.png)

## **[2] Custom Update**

![image](https://user-images.githubusercontent.com/42164422/139635042-bc5bf95e-14a7-4ba7-a0a3-67ef73d57ec9.png)

## **[3] Coroutine - null**

![image](https://user-images.githubusercontent.com/42164422/139635126-7d854795-5514-43d5-9056-5d5d4c0b18f1.png)

## **[4] Coroutine - WaitForEndOfFrame**

![image](https://user-images.githubusercontent.com/42164422/139635227-5dbef612-c0f1-4087-beea-6e5383655eb9.png)

</details>

<br>

# 실험 결과 - 2. Standalone Build(Mono)
---

<details>
<summary markdown="span">
...
</summary>

## **[1] Update**

![image](https://user-images.githubusercontent.com/42164422/139637209-0245bcfe-0ac2-4e72-8063-e2bfd2d59ee3.png)

## **[2] Custom Update**

![image](https://user-images.githubusercontent.com/42164422/139637340-5006407f-3e57-4fd0-af6c-4138674552f1.png)

## **[3] Coroutine - null**

![image](https://user-images.githubusercontent.com/42164422/139635645-b7a1130e-10b9-4d93-b7d7-e24eca46d50e.png)

## **[4] Coroutine - WaitForEndOfFrame**

![image](https://user-images.githubusercontent.com/42164422/139635804-1ea288c5-1e4f-42af-bccb-47fd7b38dcc7.png)

</details>

<br>

# 실험 결과 - 3. Standalone Build(IL2CPP)
---

<details>
<summary markdown="span">
...
</summary>

## **[1] Update**

![image](https://user-images.githubusercontent.com/42164422/139636178-fe8d33f9-db84-4632-8afa-f20e8ce5a0af.png)

## **[2] Custom Update**

![image](https://user-images.githubusercontent.com/42164422/139636270-7dc2ca7f-2840-4d00-bcdf-5049f29af5db.png)

## **[3] Coroutine - null**

![image](https://user-images.githubusercontent.com/42164422/139636576-6a5a2581-1ded-47fb-9c4b-2e85d948108e.png)

## **[4] Coroutine - WaitForEndOfFrame**

![image](https://user-images.githubusercontent.com/42164422/139636841-0aff421c-a29f-4a88-b8be-19182b246dd8.png)

</details>

<br>

# 실험 결과 정리
---

|환경|대상|프레임당 평균 소요 시간(ms)|
|---|---|:---:|
|Unity Editor|Update()                     |67.89|
|Unity Editor|Custom Update                |33.99|
|Unity Editor|Coroutine - null             |134.09|
|Unity Editor|Coroutine - WaitForEndOfFrame|168.63|
|Mono Build  |Update()                     |19.83|
|Mono Build  |Custom Update                |17.15|
|Mono Build  |Coroutine - null             |68.48|
|Mono Build  |Coroutine - WaitForEndOfFrame|80.99|
|IL2CPP Build|Update()                     |17.34|
|IL2CPP Build|Custom Update                |17.17|
|IL2CPP Build|Coroutine - null             |61.12|
|IL2CPP Build|Coroutine - WaitForEndOfFrame|88.01|

<br>

매 프레임 한 번씩 호출되는 경우,

어떤 플랫폼에서든 항상 `Update()`가 코루틴보다 성능이 좋다.

<br>

## **사족**

간혹 위 실험 결과를 오해하는 경우가 있는데,

`Update()`를 통해 매 프레임 호출 vs 코루틴으로 0.1초마다 호출

이와 같은 경우에 대해 위 실험 결과를 대입해서는 안된다.

'동일하게 매 프레임마다 한 번씩 호출하는 경우'에 대해서만 단순히 참고할 수 있는 정도로 이해하면 된다.

<br>

그러니까, 어차피 매 프레임마다 호출하는데다가 관리상 문제도 없는 경우,

 굳이 `Update()`를 통해 호출하던 것을 코루틴으로 바꿀 필요는 없다는 의미.

<br>

오히려 `Update()`로 매프레임 호출하던 것을

코루틴의 `yield return WaitForSeconds(float)` 등으로 바꾸어 최적화를 이루었다면,

올바른 방향이니까 이 실험 결과를 보고 오해하지 않았으면 한다.


