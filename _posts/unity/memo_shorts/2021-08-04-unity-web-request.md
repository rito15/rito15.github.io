---
title: Unity Async Web Request
author: Rito15
date: 2021-08-04 15:45:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Note
---

- `UnityWebRequest`는 `AsyncOperation` 클래스를 상속받는다.

- 그러니까 코루틴에서 `yield return`으로 기다릴 수 있다.

- 웹페이지를 받아올 경우, 페이지 소스의 `<head>` 부분에서 인코딩을 꼭 확인해야 한다.

<br>

# Source Code
---

```cs
// using UnityEngine.Networking;

IEnumerator WebReqRoutine()
{
    UnityWebRequest www = UnityWebRequest.Get("https://rito15.github.io/posts/unity-memo-compilation/");
    yield return www.SendWebRequest();

    if (www.isNetworkError || www.isHttpError)
    {
        Debug.Log(www.error);
    }
    else
    {
        byte[] data = www.downloadHandler.data;

        // UTF-8 인코딩
        string utf8Str = Encoding.UTF8.GetString(data);
        string utf8Str2 = www.downloadHandler.text;

        // KSC5601 인코딩 (네이버 카페)
        string kscStr = Encoding.GetEncoding("ksc_5601").GetString(data);
    }
}
```


