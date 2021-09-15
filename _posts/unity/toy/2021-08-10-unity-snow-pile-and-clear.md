---
title: Snow Pile &amp; Clear (Plane에 눈 쌓기, 지우기)
author: Rito15
date: 2021-08-10 23:23:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp]
math: true
mermaid: true
---

# Summary
---
- 파티클이 닿는 지점에 눈 쌓기

- 쌓인 눈 지우기

<br>



# Preview
---

## **[1] 쌓기**

![2021_0810_SnowPile_01](https://user-images.githubusercontent.com/42164422/128891274-52c3c543-1d62-4263-a26a-70c085b6929e.gif)
![2021_0810_SnowPile_03](https://user-images.githubusercontent.com/42164422/128891281-519d714f-d95c-48e3-8481-e8f81f879db2.gif)

<br>

## **[2] 지우기**

![2021_0810_SnowPile_05](https://user-images.githubusercontent.com/42164422/128891294-78414cd0-a2e6-40e2-86ab-2361e654e14f.gif)
![2021_0810_SnowPile_06](https://user-images.githubusercontent.com/42164422/128891299-752ab00c-bc36-4f3b-a877-621205046f3c.gif)

<br>



# Details
---

## **[1] Ground 쉐이더**

- 메인 텍스쳐의 색상을 그대로 최종 색상으로 출력한다.

- 메인 텍스쳐의 `rgb` 값 중 하나를 `Height Map`으로 사용하여, 버텍스 `Y` 위치값에 더해준다.

- 마테리얼을 생성하여 `Plane`에 적용한다.

<br>



## **[2] 렌더 텍스쳐**

- 게임 시작 시 렌더 텍스쳐를 하나 생성한다.

- `Ground` 마테리얼의 메인 텍스쳐에 렌더 텍스쳐를 넣어준다.

<br>



## **[3] 브러시 텍스쳐**

- 마치 `Default Particle System`과 같은 흑백의 동그란 모양 텍스쳐를 준비하거나, 수식을 통해 생성한다.

- 이 텍스쳐의 알파값은 렌더 텍스쳐에 색칠할 때 `Opacity`로 사용된다.

- 동일한 모양의 텍스쳐를 각각 하얀색, 검정색으로 하나씩 준비한다.

- 하얀색 텍스쳐는 눈을 쌓을 때, 검정색 텍스쳐는 눈을 지울 때 사용된다.

<br>



## **[4] 눈 쌓기**

- 파티클 시스템을 이용해 `Plane`에 충돌을 발생시킨다.

- 충돌 지점으로부터 `Plane`의 `UV` 좌표를 계산한다.

- 렌더 텍스쳐의 해당 `UV` 좌표에 하얀색 브러시 텍스쳐로 픽셀을 칠해준다.

<br>



## **[5] 눈 지우기**

- 매 프레임마다 눈을 지울 게임오브젝트의 위치를 기반으로 `Plane`의 `UV` 좌표를 계산한다.

- 렌더 텍스쳐의 해당 `UV` 좌표에 검정색 브러시 텍스쳐로 픽셀을 칠해준다.

<br>


# Download
---
- [2021_0916_Snow Pile and Clear.zip](https://github.com/rito15/Images/files/7172380/2021_0916_Snow.Pile.and.Clear.zip)

<br>


# Source Code
---

<details>
<summary markdown="span"> 
GroundSnowPainter.cs
</summary>

```cs
using UnityEngine;

// 날짜 : 2021-08-10 PM 8:47:57
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 렌더 텍스쳐를 이용해 땅에 눈 쌓기
    /// </summary>
    public class GroundSnowPainter : MonoBehaviour
    {
        [SerializeField]
        private Material targetMaterial; // 렌더 텍스쳐를 메인 텍스쳐로 적용할 대상 마테리얼

        [SerializeField, Range(0.01f, 1f)]
        private float brushSize = 0.1f;

        [SerializeField, Range(0.01f, 1f)]
        private float pileBrushIntensity = 0.1f;

        [SerializeField, Range(0.01f, 1f)]
        private float eraserBrushIntensity = 0.1f;

        [SerializeField] // 인스펙터 확인용
        private RenderTexture snowRenderTexture; // 브러시로 그려질 대상 렌더 텍스쳐

        private Texture2D whiteBrushTexture; // Painter
        private Texture2D blackBrushTexture; // Eraser

        private const int Resolution = 1024;

        private void Awake()
        {
            snowRenderTexture = new RenderTexture(Resolution, Resolution, 0);
            snowRenderTexture.filterMode = FilterMode.Point;
            snowRenderTexture.Create();

            targetMaterial.mainTexture = snowRenderTexture;

            whiteBrushTexture = CreateBrushTexture(Color.white, pileBrushIntensity);
            blackBrushTexture = CreateBrushTexture(Color.black, eraserBrushIntensity);
        }

        private void OnDestroy()
        {
            if(snowRenderTexture) Destroy(snowRenderTexture);
            if(whiteBrushTexture) Destroy(whiteBrushTexture);
            if(blackBrushTexture) Destroy(blackBrushTexture);
        }

        private Texture2D CreateBrushTexture(Color color, float intensity)
        {
            int res = Resolution / 2;
            float hRes = res * 0.5f;
            float sqrSize = hRes * hRes;

            Texture2D texture = new Texture2D(res, res);
            texture.filterMode = FilterMode.Bilinear;

            for (int y = 0; y < res; y++)
            {
                for (int x = 0; x < res; x++)
                {
                    // Sqaure Length From Center
                    float sqrLen = (hRes - x) * (hRes - x) + (hRes - y) * (hRes - y);
                    float alpha = Mathf.Max(sqrSize - sqrLen, 0f) / sqrSize;

                    // Soft
                    alpha = Mathf.Pow(alpha, 2f);

                    color.a = alpha * intensity;
                    texture.SetPixel(x, y, color);
                }
            }

            texture.Apply();
            return texture;
        }

        /// <summary> 렌더 텍스쳐에 브러시 텍스쳐로 그리기 </summary>
        private void PaintBrush(Texture2D brush, Vector2 uv, float size)
        {
            RenderTexture.active = snowRenderTexture;         // 페인팅을 위해 활성 렌더 텍스쳐 임시 할당
            GL.PushMatrix();                                  // 매트릭스 백업
            GL.LoadPixelMatrix(0, Resolution, Resolution, 0); // 알맞은 크기로 픽셀 매트릭스 설정

            float brushPixelSize = brushSize * Resolution * size;
            uv.x *= Resolution;
            uv.y *= Resolution;

            // 렌더 텍스쳐에 브러시 텍스쳐를 이용해 그리기
            Graphics.DrawTexture(
                new Rect(
                    uv.x - brushPixelSize * 0.5f,
                    (snowRenderTexture.height - uv.y) - brushPixelSize * 0.5f,
                    brushPixelSize,
                    brushPixelSize
                ),
                brush
            );

            GL.PopMatrix();              // 매트릭스 복구
            RenderTexture.active = null; // 활성 렌더 텍스쳐 해제
        }

        /// <summary> 눈 쌓기 </summary>
        public void PileSnow(Vector3 contactPoint)
        {
            float snowSize = UnityEngine.Random.Range(0.5f, 2.0f);
            Paint(contactPoint, snowSize, true);
        }

        /// <summary> 눈 지우기 </summary>
        public void ClearSnow(Vector3 contactPoint, float size)
        {
            Paint(contactPoint, size, false);
        }

        /// <summary> 눈 쌓기 or 지우기 </summary>
        private void Paint(in Vector3 contactPoint, float size = 1f, bool pileOrClear = true)
        {
            // 눈이 부딪힌 3D 좌표로부터 2D UV 좌표 계산
            // Plane은 scale 1당 좌표 10이므로 10으로 나누기
            Vector3 normalizedVec3 = (contactPoint - transform.position) / 10f;
            normalizedVec3.x /= transform.lossyScale.x;
            normalizedVec3.z /= transform.lossyScale.z;

            Vector2 uv = new Vector2(normalizedVec3.x + 0.5f, normalizedVec3.z + 0.5f);

            // UV 범위 바깥이면 배제
            if (uv.x < 0f || uv.y < 0f || uv.x > 1f || uv.y > 1f)
                return;

            uv = Vector2.one - uv; // 좌표 반전

            // 1. 쌓기
            if (pileOrClear)
            {
                PaintBrush(whiteBrushTexture, uv, size);
            }
            // 2. 지우기
            else
            {
                PaintBrush(blackBrushTexture, uv, size);
            }
        }
    }
}
```

</details>

<details>
<summary markdown="span"> 
FallingSnow.cs
</summary>

```cs
using System.Collections.Generic;
using UnityEngine;

// 날짜 : 2021-08-10 PM 9:37:17
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 파티클 - 바닥에 눈 쌓기
    /// </summary>
    public class FallingSnow : MonoBehaviour
    {
        private ParticleSystem ps;
        private List<ParticleCollisionEvent> colEventList;

        private GameObject cachedTargetGO;
        private GroundSnowPainter snowPainter;

        private void Awake()
        {
            ps = GetComponent<ParticleSystem>();
            colEventList = new List<ParticleCollisionEvent>(100);
        }

        private void OnParticleCollision(GameObject other)
        {
            if (other != cachedTargetGO)
            {
                cachedTargetGO = other;
                snowPainter = other.GetComponent<GroundSnowPainter>();
            }

            if (snowPainter == null || snowPainter.isActiveAndEnabled == false)
                return;

            int numColEvents = ps.GetCollisionEvents(other, colEventList);

            for (int i = 0; i < numColEvents; i++)
            {
                snowPainter.PileSnow(colEventList[i].intersection);
            }
        }
    }
}
```

</details>

<details>
<summary markdown="span"> 
SnowEraser.cs
</summary>

```cs
using UnityEngine;

// 날짜 : 2021-08-10 PM 10:54:47
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 쌓인 눈 지우기
    /// </summary>
    public class SnowEraser : MonoBehaviour
    {
        public GroundSnowPainter groundSnow;
        public float sizeMultiplier = 1f;
        public bool eraseOn = true;

        [Space, Range(1f, 10f)]
        public float moveSpeed = 5f;

        [SerializeField]
        private float currentSpeed;

        private float acceleration = 1f;
        private const float AccelMin = 1f;
        private const float AccelMax = 5f;

        private void Update()
        {
            Accelerate();
            Move();
            Erase();
        }

        /// <summary> 눈 지우기 </summary>
        private void Erase()
        {
            if (!eraseOn || groundSnow == null || groundSnow.isActiveAndEnabled == false) return;
            groundSnow.ClearSnow(transform.position, sizeMultiplier * transform.lossyScale.x);
        }

        /// <summary> LShift 가속 </summary>
        private void Accelerate()
        {
            if (Input.GetKey(KeyCode.LeftShift)) acceleration += Time.deltaTime;
            else acceleration -= Time.deltaTime;

            acceleration = Mathf.Clamp(acceleration, AccelMin, AccelMax);
        }

        /// <summary> WASD 이동 </summary>
        private void Move()
        {
            float h = Input.GetAxisRaw("Horizontal");
            float v = Input.GetAxisRaw("Vertical");

            Vector3 moveVec = new Vector3(h, 0f, v).normalized * moveSpeed * acceleration;
            transform.Translate(moveVec * Time.deltaTime, Space.Self);

            currentSpeed = moveVec.sqrMagnitude;
            currentSpeed = (int)(currentSpeed * 100f) * 0.01f;
        }
    }
}
```

</details>


<br>
