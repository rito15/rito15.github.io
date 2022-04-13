---
title: Main Thread Dispatcher
author: Rito15
date: 2021-06-30 04:04:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin, mainthreaddispatcher]
math: true
mermaid: true
---

# 메인 스레드 디스패처?
---

유니티 엔진에서는 메인 스레드가 아닌 다른 스레드에서

게임오브젝트, 트랜스폼 등 유니티 API에 접근할 수 없게 제한되어 있다.

하지만 `메인 스레드 디스패처`를 사용하면 이 문제를 해결할 수 있다.

<br>


## 동작 원리

- `메인 스레드 디스패처`에는 동기화 큐(Queue)가 존재한다.

- 다른 스레드에서 유니티 API 작업이 필요할 경우, `메인 스레드 디스패처`의 큐에 집어 넣는다.

- `메인 스레드 디스패처`는 매 프레임마다 큐에서 작업을 꺼내어 메인 스레드 내에서 수행한다.

- 다른 스레드에서는 위와 같이 `디스패처`를 통해 메인 스레드에 작업을 위임하게 되어, 결과적으로 안전하게 메인스레드 내에서 유니티 API 작업을 처리할 수 있게 된다.

<br>


# 사용 예시
---

```cs
private MainThreadDispatcher mtd;

private void Start()
{
    mtd = MainThreadDispatcher.Instance;
    Task.Run(() => TestBody());
}

private async void TestBody()
{
    int res1 = -1, res2 = -1;

    // 1. 비동기 요청
    mtd.Request(() => res1 = Random.Range(0, 1000));
    Debug.Log(res1);

    // 2. await를 통한 대기 - Action
    await mtd.RequestAsync(() => { res2 = Random.Range(0, 1000); });
    Debug.Log(res2);

    // 3. await를 통한 대기 - Func<int>
    Task<int> resultTask = mtd.RequestAsync(() => Random.Range(0, 1000));
    await resultTask;
    Debug.Log(resultTask.Result);
}
```

<br>

# 소스코드
---
<details>
<summary markdown="span"> 
.
</summary>

- <https://github.com/PimDeWitte/UnityMainThreadDispatcher>의 코드를 조금 더 사용하기 편리하게 살짝 수정

{% include codeHeader.html %}
```cs
/*
    Copyright 2015 Pim de Witte All Rights Reserved.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    https://github.com/PimDeWitte/UnityMainThreadDispatcher
*/

// 날짜 : 2021-06-30 AM 2:56:52

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

using MTD = MainThreadDispatcher;

public class MainThreadDispatcher : MonoBehaviour
{
    /***********************************************************************
    *                               Singleton
    ***********************************************************************/
    #region .

    private static MTD _instance;
    public static MTD Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<MTD>();

                if (_instance == null)
                {
                    GameObject container = new GameObject($"Main Thread Dispatcher");
                    _instance = container.AddComponent<MTD>();
                }
            }

            return _instance;
        }
    }

    private void Awake()
    {
        if (_instance == null)
        {
            _instance = this;
            transform.SetParent(null);
            DontDestroyOnLoad(this);
        }
        else
        {
            if (_instance != this)
            {
                if (GetComponents<Component>().Length <= 2)
                    Destroy(gameObject);
                else
                    Destroy(this);
            }
        }
    }

    #endregion

    private static readonly Queue<Action> _executionQueue = new Queue<Action>();

    private void Update()
    {
        lock (_executionQueue)
        {
            while (_executionQueue.Count > 0)
            {
                _executionQueue.Dequeue().Invoke();
            }
        }
    }

    /// <summary> 메인 스레드에 작업 요청(코루틴) </summary>
    public void Request(IEnumerator coroutine)
    {
        lock (_executionQueue)
        {
            _executionQueue.Enqueue(() =>
            {
                StartCoroutine(coroutine);
            });
        }
    }

    /// <summary> 메인 스레드에 작업 요청(메소드) </summary>
    public void Request(Action action)
    {
        Request(ActionWrapper(action));
    }

    /// <summary> 메인 스레드에 작업 요청 및 대기(await) </summary>
    public Task RequestAsync(Action action)
    {
        var tcs = new TaskCompletionSource<bool>();

        void WrappedAction()
        {
            try
            {
                action();
                tcs.TrySetResult(true);
            }
            catch (Exception ex)
            {
                tcs.TrySetException(ex);
            }
        }

        Request(ActionWrapper(WrappedAction));
        return tcs.Task;
    }

    /// <summary> 메인 스레드에 작업 요청 및 대기(await) + 값 받아오기 </summary>
    public Task<T> RequestAsync<T>(Func<T> action)
    {
        var tcs = new TaskCompletionSource<T>();

        void WrappedAction()
        {
            try
            {
                var result = action();
                tcs.TrySetResult(result);
            }
            catch (Exception ex)
            {
                tcs.TrySetException(ex);
            }
        }

        Request(ActionWrapper(WrappedAction));
        return tcs.Task;
    }

    /// <summary> Action을 코루틴으로 래핑 </summary>
    private IEnumerator ActionWrapper(Action a)
    {
        a();
        yield return null;
    }
}
```

</details>

<br>


# References
---
- <https://github.com/PimDeWitte/UnityMainThreadDispatcher>

