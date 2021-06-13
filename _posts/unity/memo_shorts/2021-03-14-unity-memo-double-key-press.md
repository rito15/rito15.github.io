---
title: 키보드 연속 입력 유지 상태 감지하기
author: Rito15
date: 2021-03-14 23:23:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, input, shorts]
math: true
mermaid: true
---

# 활용
---

- 달리기 구현(WW, AA, SS, DD)


# Source Code
---

```cs
/// <summary> 키보드 연속 입력 유지 상태 감지 </summary>
private class KeyForDoublePressDetection
{
    public KeyCode Key { get; private set; }

    /// <summary> 한 번 눌러서 유지한 상태 </summary>
    public bool SinglePressed { get; private set; }

    /// <summary> 두 번 눌러서 유지한 상태 </summary>
    public bool DoublePressed { get; private set; }

    private bool  doublePressDetected;
    private float doublePressThreshold;
    private float lastKeyDownTime;

    public KeyForDoublePressDetection(KeyCode key, float threshold = 0.3f)
    {
        this.Key = key;
        SinglePressed = false;
        DoublePressed = false;
        doublePressDetected = false;
        doublePressThreshold = threshold;
        lastKeyDownTime = 0f;
    }

    public void ChangeKey(KeyCode key)
    {
        this.Key = key;
    }
    public void ChangeThreshold(float seconds)
    {
        doublePressThreshold = seconds > 0f ? seconds : 0f;
    }

    /// <summary> MonoBehaviour.Update()에서 호출 : 키 정보 업데이트 </summary>
    public void UpdateCheck()
    {
        if (Input.GetKeyDown(Key))
        {
            doublePressDetected =
                (Time.time - lastKeyDownTime < doublePressThreshold);

            lastKeyDownTime = Time.time;
        }

        if (Input.GetKey(Key))
        {
            if (doublePressDetected)
                DoublePressed = true;
            else
                SinglePressed = true;
        }
        else
        {
            doublePressDetected = false;
            DoublePressed = false;
            SinglePressed = false;
        }
    }

    /// <summary> MonoBehaviour.Update()에서 호출 : 키 입력에 따른 동작 </summary>
    public void UpdateAction(Action singlePressAction, Action doublePressAction)
    {
        if(SinglePressed) singlePressAction?.Invoke();
        if(DoublePressed) doublePressAction?.Invoke();
    }
}

private KeyForDoublePressDetection[] keys;

private void Start()
{
    keys = new[]
    {
        new KeyForDoublePressDetection(KeyCode.W),
        new KeyForDoublePressDetection(KeyCode.A),
        new KeyForDoublePressDetection(KeyCode.S),
        new KeyForDoublePressDetection(KeyCode.D),
    };
}

private void Update()
{
    for (int i = 0; i < keys.Length; i++)
    {
        keys[i].UpdateCheck();
    }

    keys[0].UpdateAction(() => Debug.Log("W"), () => Debug.Log("WW"));
    keys[1].UpdateAction(() => Debug.Log("A"), () => Debug.Log("AA"));
    keys[2].UpdateAction(() => Debug.Log("S"), () => Debug.Log("SS"));
    keys[3].UpdateAction(() => Debug.Log("D"), () => Debug.Log("DD"));
}
```
