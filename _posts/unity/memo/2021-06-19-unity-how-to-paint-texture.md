---
title: 런타임에 큰 성능 저하 없이 텍스쳐에 그림 그리기
author: Rito15
date: 2021-06-19 17:17:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# 텍스쳐의 특정 픽셀 색상 변경하기
---

텍스쳐의 특정 픽셀 색상을 변경하는건 매우 간단하다.

<br>

[1] 텍스쳐의 Read/Write Enabled를 체크한다.

[2] 대상 마테리얼에서 텍스쳐를 가져온다.

[3] `SetPixel()` 메소드로 원하는 픽셀의 색상을 변경한다.

[4] `Apply()` 메소드로 적용한다.

<br>

하지만 메모리에 적재된 텍스쳐를 저렇게 직접 수정하는건

CPU 입장에서 매우 부담되는 일이므로 성능 저하가 막심하다.

<br>

# 렌더 텍스쳐를 거쳐 색상 변경하기
---

위와 같은 큰 성능 저하 없이 런타임에 텍스쳐 픽셀을 수정하려면,

렌더 텍스쳐를 거쳐야 한다.

<br>

[1] 렌더 텍스쳐를 준비하거나 새로 생성한다.

[2] 대상 마테리얼의 텍스쳐 타입 프로퍼티에 렌더 텍스쳐를 적용한다.

[3] 렌더 텍스쳐의 픽셀 색상을 변경한다.

<br>

이 과정도 간단해 보이지만,

3번의 과정을 좀더 자세히 풀어보면 다음과 같다.

<br>

[3-1] `RenderTexture.active `프로퍼티에 지금 수정하고 싶은 렌더 텍스쳐를 등록한다.

[3-2] `GL.PushMatrix()`를 호출하여 현재의 매트릭스를 저장한다. (복귀 지점 저장)

[3-3] `GL.LoadPixelMatrix()`를 호출하여 수정하고 싶은 렌더 텍스쳐에 알맞은 매트릭스를 세팅한다.

[3-4] `Graphics.DrawTexture()`를 호출하여 렌더 텍스쳐에 원하는 텍스쳐의 색상을 입힌다.

[3-5] `GL.PopMatrix()`를 호출하여 [3-2]에서 저장했던 매트릭스를 복원한다.

[3-6] `RenderTexture.active` 프로퍼티에 `null`을 초기화한다.

<br>

# 예제 소스코드
---

- 메인 텍스쳐를 렌더 텍스쳐로 가져와, 직접 수정하는 예제

<details>
<summary markdown="span"> 
PaintTexture.cs
</summary>

```cs
using UnityEngine;

/*
 * - 그림 그릴 대상 게임오브젝트에 컴포넌트로 넣기
 * 
 */
public class PaintTexture : MonoBehaviour
{
    public int resolution = 512;
    [Range(0.01f, 1f)]
    public float brushSize = 0.1f;
    public Texture2D brushTexture;

    private Texture2D mainTex;
    private MeshRenderer mr;
    private RenderTexture rt;

    private void Awake()
    {
        TryGetComponent(out mr);
        rt = new RenderTexture(resolution, resolution, 32);

        if (mr.material.mainTexture != null)
        {
            mainTex = mr.material.mainTexture as Texture2D;
        }
        // 메인 텍스쳐가 없을 경우, 하얀 텍스쳐를 생성하여 사용
        else
        {
            mainTex = new Texture2D(resolution, resolution);
        }

        // 메인 텍스쳐 -> 렌더 텍스쳐 복제
        Graphics.Blit(mainTex, rt);

        // 렌더 텍스쳐를 메인 텍스쳐에 등록
        mr.material.mainTexture = rt;

        // 브러시 텍스쳐가 없을 경우 임시 생성(red 색상)
        if (brushTexture == null)
        {
            brushTexture = new Texture2D(resolution, resolution);
            for (int i = 0; i < resolution; i++)
                for (int j = 0; j < resolution; j++)
                    brushTexture.SetPixel(i, j, Color.red);
            brushTexture.Apply();
        }
    }

    private void Update()
    {
        // NOTE : 텍스쳐 페인팅의 대상이 될 모든 컴포넌트에서 레이캐스트 검사를 수행하므로 비효율적이다.
        // 실제로 사용하려면 하나의 컴포넌트에서 레이캐스트 수행하도록 구조를 변경해야 한다.

        // 마우스 클릭 지점에 브러시로 그리기
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            bool raycast = Physics.Raycast(ray, out var hit);
            Collider col = hit.collider;

            //Debug.DrawRay(ray.origin, ray.direction * hit.distance, Color.red, 1f);

            // 본인이 레이캐스트에 맞았으면 그리기
            if (raycast && col && col.transform == transform)
            {
                Vector2 pixelUV = hit.lightmapCoord;
                pixelUV *= resolution;
                DrawTexture(pixelUV);
            }
        }
    }

    /// <summary> 렌더 텍스쳐에 브러시 텍스쳐로 그리기 </summary>
    public void DrawTexture(in Vector2 uv)
    {
        RenderTexture.active = rt; // 페인팅을 위해 활성 렌더 텍스쳐 임시 할당
        GL.PushMatrix();                                  // 매트릭스 백업
        GL.LoadPixelMatrix(0, resolution, resolution, 0); // 알맞은 크기로 픽셀 매트릭스 설정

        float brushPixelSize = brushSize * resolution;

        // 렌더 텍스쳐에 브러시 텍스쳐를 이용해 그리기
        Graphics.DrawTexture(
            new Rect(
                uv.x - brushPixelSize * 0.5f,
                (rt.height - uv.y) - brushPixelSize * 0.5f,
                brushPixelSize,
                brushPixelSize
            ),
            brushTexture
        );

        GL.PopMatrix();              // 매트릭스 복구
        RenderTexture.active = null; // 활성 렌더 텍스쳐 해제
    }
}
```

</details>

<br>

