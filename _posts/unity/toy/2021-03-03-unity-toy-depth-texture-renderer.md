---
title: Depth Texture Renderer (Z-Buffer 렌더러)
author: Rito15
date: 2021-03-03 19:08:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---

- 현재 메인 카메라의 뎁스 텍스쳐를 화면에 렌더링한다.

- 각 쉐이더의 ZWrite 여부에 관계 없이 모두 렌더링하는 단점이 있다.

- 렌더 큐 값이 2500(Skybox) 이하인 오브젝트들만 인식한다.

<br>

# How to Use
---

- DepthRenderer.cs 스크립트를 메인 카메라에 넣는다.

- enabled를 체크/해제하여 화면에 렌더 텍스쳐를 보여줄지 여부를 결정할 수 있다.

<br>

# Preview
---

- 원래 화면

![image](https://user-images.githubusercontent.com/42164422/109798735-795f7080-7c5e-11eb-91b1-9e5a49490d5b.png)

- 뎁스 텍스쳐 렌더링

![image](https://user-images.githubusercontent.com/42164422/109798762-80867e80-7c5e-11eb-9594-24b378f2a69e.png)

<br>

# Download
---

- [DepthRenderer.zip](https://github.com/rito15/Images/files/6075674/DepthRenderer.zip)

<br>

# Source Code
---

<details>
<summary markdown="span"> 
RenderDepth.shader
</summary>

```cs
 Shader "Custom/RenderDepth"
 {
     Properties
     {
         _MainTex ("Base (RGB)", 2D) = "white" {}
         _DepthLevel ("Depth Level", Range(1, 3)) = 1
         _DepthMul ("Depth Mul", Range(-1, 1)) = 0
     }
     SubShader
     {
         Pass
         {
             CGPROGRAM
 
             #pragma vertex vert
             #pragma fragment frag
             #include "UnityCG.cginc"
             
             uniform sampler2D _MainTex;
             uniform sampler2D _CameraDepthTexture;
             uniform fixed _DepthLevel;
             uniform fixed _DepthMul;
             uniform half4 _MainTex_TexelSize;
 
             struct input
             {
                 float4 pos : POSITION;
                 half2 uv : TEXCOORD0;
             };
 
             struct output
             {
                 float4 pos : SV_POSITION;
                 half2 uv : TEXCOORD0;
             };
 
 
             output vert(input i)
             {
                 output o;
                 o.pos = UnityObjectToClipPos(i.pos);
                 o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, i.uv);
                 // why do we need this? cause sometimes the image I get is flipped. see: http://docs.unity3d.com/Manual/SL-PlatformDifferences.html
                 #if UNITY_UV_STARTS_AT_TOP
                 if (_MainTex_TexelSize.y < 0)
                         o.uv.y = 1 - o.uv.y;
                 #endif
 
                 return o;
             }
             
             fixed4 frag(output o) : COLOR
             {
                 float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, o.uv));
                 depth = pow(Linear01Depth(depth), _DepthLevel) * _DepthMul;
                 return depth;
             }
             
             ENDCG
         }
     } 
 }
```

</details>

<br>

<details>
<summary markdown="span"> 
DepthRenderer.cs
</summary>

```cs
using UnityEngine;

[ExecuteInEditMode]
public class DepthRenderer : MonoBehaviour
{
    [Range(0f, 3f)]
    public float depthLevel = 1.0f;

    [Range(1f, 50f)]
    public float depthMul = 20.0f;

    private Shader _shader;
    private Shader RdShader
        => _shader != null ? _shader : (_shader = Shader.Find("Custom/RenderDepth"));

    private Material _material;
    private Material RdMaterial
    {
        get
        {
            if (_material == null)
            {
                _material = new Material(RdShader);
                _material.hideFlags = HideFlags.HideAndDontSave;
            }
            return _material;
        }
    }

    private void OnEnable()
    {
        if (RdShader == null || !RdShader.isSupported)
        {
            enabled = false;
            print("Shader " + RdShader.name + " is not supported");
            return;
        }

        Camera.main.depthTextureMode = DepthTextureMode.None;
    }

    private void OnDisable()
    {
        if (_material != null)
            DestroyImmediate(_material);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (RdShader != null)
        {
            RdMaterial.SetFloat("_DepthLevel", depthLevel);
            RdMaterial.SetFloat("_DepthMul", depthMul);
            Graphics.Blit(src, dest, RdMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
```

</details>

<br>

# References
---
- <https://answers.unity.com/questions/877170/render-scene-depth-to-a-texture.html>