---
title: Texture Painter(텍스쳐에 그림 그리기)
author: Rito15
date: 2021-06-19 04:32:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Summary
---
- 실시간으로 마우스 클릭, 드래그를 통해 게임 오브젝트의 텍스쳐에 그림 그리기


<br>

# How To Use
---

## **그림 그려질 대상 게임오브젝트**

- 알맞은 콜라이더를 넣는다.

- `Rito/PaintTexture` 쉐이더로 생성한 마테리얼을 적용한다.

- `TexturePaintTarget` 컴포넌트를 추가는다.

<br>

## **브러시**

- 씬에 빈 게임오브젝트를 생성하고 `TexturePaintBrush` 컴포넌트를 추가는다.

- `Brush Size`로 브러시의 크기를 조절할 수 있다.

- `Brush Texture`로 브러시의 모양으로 사용할 텍스쳐를 등록할 수 있다.<br>
  등록하지 않은 경우, 기본 브러시로 자동 초기화된다.

- `Brush Color`로 브러시의 색상을 지정할 수 있다.

<br>

## **그림 그리기**

- 마우스 드래그를 통해 대상 게임오브젝트에 그림을 그린다.

<br>


# Preview
---

![2021_0619_TexturePainter_1](https://user-images.githubusercontent.com/42164422/122612204-b3456d00-d0bd-11eb-9cf0-93e639a07017.gif)

![2021_0619_TexturePainter_2](https://user-images.githubusercontent.com/42164422/122612208-b4769a00-d0bd-11eb-8ef7-c60ecb2c573c.gif)

<br>

# Download
---
- [Texture_Painter.zip](https://github.com/rito15/Images/files/6679186/2021_0619_Texture_Painter.zip)

<br>

# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<br>

<details>
<summary markdown="span"> 
TexturePaintBrush.cs
</summary>

```cs
using UnityEngine;

// 날짜 : 2021-06-18 AM 2:30:31
// 작성자 : Rito

/// <summary> 마우스 드래그로 텍스쳐에 그림 그리기 </summary>
[DisallowMultipleComponent]
public class TexturePaintBrush : MonoBehaviour
{
    /***********************************************************************
    *                               Public Fields
    ***********************************************************************/
    #region .

    [Range(0.01f, 1f)] public float brushSize = 0.1f;
    public Texture2D brushTexture;
    public Color brushColor = Color.white;

    #endregion
    /***********************************************************************
    *                               Private Fields
    ***********************************************************************/
    #region .

    private TexturePaintTarget paintTarget;
    private Collider prevCollider;

    private Texture2D CopiedBrushTexture; // 실시간으로 색상 칠하는데 사용되는 브러시 텍스쳐 카피본
    private Vector2 sameUvPoint; // 직전 프레임에 마우스가 위치한 대상 UV 지점 (동일 위치에 중첩해서 그리는 현상 방지)

    #endregion

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Awake()
    {
        // 등록한 브러시 텍스쳐가 없을 경우, 원 모양의 텍스쳐 생성
        if (brushTexture == null)
        {
            CreateDefaultBrushTexture();
        }

        CopyBrushTexture();
    }

    private void Update()
    {
        UpdateBrushColorOnEditor();

        if (Input.GetMouseButton(0) == false) return;

        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out var hit)) // delete previous and uncomment for mouse painting
        {
            Collider currentCollider = hit.collider;
            if (currentCollider != null)
            {
                // 대상 참조 갱신
                if (prevCollider == null || prevCollider != currentCollider)
                {
                    prevCollider = currentCollider;
                    currentCollider.TryGetComponent(out paintTarget);
                }

                // 동일한 지점에는 중첩하여 다시 그리지 않음
                if (sameUvPoint != hit.lightmapCoord)
                {
                    sameUvPoint = hit.lightmapCoord;
                    Vector2 pixelUV = hit.lightmapCoord;
                    pixelUV.x *= paintTarget.resolution;
                    pixelUV.y *= paintTarget.resolution;
                    paintTarget.DrawTexture(pixelUV.x, pixelUV.y, brushSize, CopiedBrushTexture);
                }
            }
        }
    }
    #endregion
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 브러시 색상 변경 </summary>
    public void SetBrushColor(in Color color)
    {
        brushColor = color;
        CopyBrushTexture();
    }

    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .

    /// <summary> 기본 형태(원)의 브러시 텍스쳐 생성 </summary>
    private void CreateDefaultBrushTexture()
    {
        int res = 512;
        float hRes = res * 0.5f;
        float sqrSize = hRes * hRes;

        brushTexture = new Texture2D(res, res);
        brushTexture.filterMode = FilterMode.Point;
        brushTexture.alphaIsTransparency = true;

        for (int y = 0; y < res; y++)
        {
            for (int x = 0; x < res; x++)
            {
                // Sqaure Length From Center
                float sqrLen = (hRes - x) * (hRes - x) + (hRes - y) * (hRes - y);
                float alpha = Mathf.Max(sqrSize - sqrLen, 0f) / sqrSize;

                //brushTexture.SetPixel(x, y, (sqrLen < sqrSize ? brushColor : Color.clear));
                brushTexture.SetPixel(x, y, new Color(1f, 1f, 1f, alpha));
            }
        }

        brushTexture.Apply();
    }

    /// <summary> 원본 브러시 텍스쳐 -> 실제 브러시 텍스쳐(색상 적용) 복제 </summary>
    private void CopyBrushTexture()
    {
        if (brushTexture == null) return;

        // 기존의 카피 텍스쳐는 메모리 해제
        DestroyImmediate(CopiedBrushTexture);

        // 새롭게 할당
        {
            CopiedBrushTexture = new Texture2D(brushTexture.width, brushTexture.height);
            CopiedBrushTexture.filterMode = FilterMode.Point;
            CopiedBrushTexture.alphaIsTransparency = true;
        }

        int height = brushTexture.height;
        int width = brushTexture.width;

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                Color c = brushColor;
                c.a *= brushTexture.GetPixel(x, y).a;

                CopiedBrushTexture.SetPixel(x, y, c);
            }
        }

        CopiedBrushTexture.Apply();

        Debug.Log("Copy Brush Texture");
    }

    #endregion
    /***********************************************************************
    *                               Editor Only
    ***********************************************************************/
    #region .
#if UNITY_EDITOR
    // 색상 변경 감지하여 브러시 텍스쳐 다시 복제
    private Color prevBrushColor;
    private float brushTextureUpdateCounter = 0f;
    private const float BrushTextureUpdateCounterInitValue = 0.7f;
    private void OnValidate()
    {
        if (Application.isPlaying && prevBrushColor != brushColor)
        {
            brushTextureUpdateCounter = BrushTextureUpdateCounterInitValue;
            prevBrushColor = brushColor;
        }
    }
#endif
    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    private void UpdateBrushColorOnEditor()
    {
        if (brushTextureUpdateCounter > 0f && 
            brushTextureUpdateCounter <= BrushTextureUpdateCounterInitValue)
        {
            brushTextureUpdateCounter -= Time.deltaTime;
        }

        if(brushTextureUpdateCounter < 0f)
        {
            CopyBrushTexture();
            brushTextureUpdateCounter = 9999f;
        }
    }
    #endregion
}
```

</details>

<details>
<summary markdown="span"> 
TexturePaintTarget.cs
</summary>

```cs
using UnityEngine;

// 날짜 : 2021-06-19 AM 3:00:38
// 작성자 : Rito

/*
 * [NOTE]
 * 
 * - Rito/PaintTexture 마테리얼 사용
 * 
 */

/// <summary> 
/// 그림 그려질 대상
/// </summary>
[DisallowMultipleComponent]
public class TexturePaintTarget : MonoBehaviour
{
    /***********************************************************************
    *                               Static Fields
    ***********************************************************************/
    #region .
    private static Texture2D ClearTex
    {
        get
        {
            if (_clearTex == null)
            {
                _clearTex = new Texture2D(1, 1);
                _clearTex.SetPixel(0, 0, Color.clear);
                _clearTex.Apply();
            }
            return _clearTex;
        }
    }
    private MaterialPropertyBlock TextureBlock
    {
        get
        {
            if (_textureBlock == null)
            {
                _textureBlock = new MaterialPropertyBlock();
            }
            return _textureBlock;
        }
    }

    private static Texture2D _clearTex;
    private MaterialPropertyBlock _textureBlock;

    private static readonly string PaintTexPropertyName = "_PaintTex";

    #endregion
    /***********************************************************************
    *                               Private Fields
    ***********************************************************************/
    #region .
    private MeshRenderer _mr;

    #endregion
    /***********************************************************************
    *                               Public Fields
    ***********************************************************************/
    #region .
    public int resolution = 512;
    public RenderTexture renderTexture = null;

    #endregion
    /***********************************************************************
    *                               Unity Magics
    ***********************************************************************/
    #region .
    private void Awake()
    {
        Init();
        InitRenderTexture();
    }

    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .

    private void Init()
    {
        TryGetComponent(out _mr);
    }

    /// <summary> 렌더 텍스쳐 초기화 </summary>
    private void InitRenderTexture()
    {
        renderTexture = new RenderTexture(resolution, resolution, 32);
        Graphics.Blit(ClearTex, renderTexture);

        // 마테리얼 프로퍼티 블록 이용하여 배칭 유지하고
        // 마테리얼의 프로퍼티에 렌더 텍스쳐 넣어주기
        TextureBlock.SetTexture(PaintTexPropertyName, renderTexture);
        _mr.SetPropertyBlock(TextureBlock);
    }

    #endregion
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 렌더 텍스쳐에 브러시 텍스쳐로 그리기 </summary>
    public void DrawTexture(float posX, float posY, float brushSize, Texture2D brushTexture)
    {
        RenderTexture.active = renderTexture; // 페인팅을 위해 활성 렌더 텍스쳐 임시 할당
        GL.PushMatrix();                      // 매트릭스 저장
        GL.LoadPixelMatrix(0, resolution, resolution, 0); // 알맞은 크기로 픽셀 매트릭스 설정

        float brushPixelSize = brushSize * resolution;

        // 렌더 텍스쳐에 브러시 텍스쳐를 이용해 그리기
        Graphics.DrawTexture(
            new Rect(
                posX - brushPixelSize * 0.5f,
                (renderTexture.height - posY) - brushPixelSize * 0.5f,
                brushPixelSize,
                brushPixelSize
            ),
            brushTexture
        );

        GL.PopMatrix();              // 매트릭스 복구
        RenderTexture.active = null; // 활성 렌더 텍스쳐 해제
    }
    #endregion
}
```

</details>

<details>
<summary markdown="span"> 
PaintTexture.shader
</summary>

```cs
Shader "Rito/PaintTexture"
{
    Properties
    {
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _PaintTex ("Painted Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        sampler2D _PaintTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)

            //UNITY_DEFINE_INSTANCED_PROP(sampler2D, _PaintTex)

        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //sampler2D paintTex = UNITY_ACCESS_INSTANCED_PROP(Props, _PaintTex);

            fixed4 main = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 painted = tex2D (_PaintTex, IN.uv_MainTex);

            o.Emission = lerp(main.rgb, painted.rgb, painted.a);

            o.Alpha = main.a * painted.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
```

</details>


<br>

# References
---
- <https://www.patreon.com/posts/rendertexture-15961186>