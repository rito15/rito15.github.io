---
title: Voxel System
author: Rito15
date: 2021-03-26 20:40:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 목차

- [개요](#개요)
- [1. 청크 구현](#1-청크-구현)
- [](#)

<br>

# 개요
---

유니티엔진에서 마인크래프트와 같은 복셀 시스템을 구현한다.

모든 맵과 사물은 큐브 형태를 띠고 있으며, 생성하거나 파괴할 수 있다.

각각의 큐브를 개별 오브젝트로 렌더링할 경우 부하가 굉장히 크기 때문에,

일정 영역의 큐브들을 모아 하나의 청크(Chunk)이자 하나의 메시로 관리하는 것이 핵심이다.

<br>

# 1. 청크 구현
---

## **큐브의 정점 데이터 정의**

- 복셀 시스템에서 사용하기 위해, 육면체 내에서 각 정점들의 인덱스 순서와 상대 위치를 미리 약속된 값으로 정의한다.

![image](https://user-images.githubusercontent.com/42164422/112629589-da522100-8e77-11eb-92ec-d8fbc9b0da8e.png)

<br>

## **LUT(LookUp Table)**

- 육면체의 정점, 삼각형, UV를 손쉽게 참조하기 위한 LUT를 정의한다.

<details>
<summary markdown="span"> 
VoxelData.cs
</summary>

```cs
public static class VoxelData
{
    /***********************************************************************
    *                               Lookup Tables
    ***********************************************************************/
    #region .

    /* 
            7 ──── 6    
          / │       / │
        3 ──── 2   │
        │  │     │  │
        │  4───│─5  
        │/        │/
        0 ──── 1
    */
    /// <summary> 큐브의 8개 버텍스의 상대 위치 </summary>
    public static readonly Vector3[] voxelVerts = new Vector3[8]
    {
        // Front
        new Vector3(0.0f, 0.0f, 0.0f), // LB
        new Vector3(1.0f, 0.0f, 0.0f), // RB
        new Vector3(1.0f, 1.0f, 0.0f), // RT
        new Vector3(0.0f, 1.0f, 0.0f), // LT

        // Back
        new Vector3(0.0f, 0.0f, 1.0f), // LB
        new Vector3(1.0f, 0.0f, 1.0f), // RB
        new Vector3(1.0f, 1.0f, 1.0f), // RT
        new Vector3(0.0f, 1.0f, 1.0f), // LT
    };

    // 한 면을 이루는 삼각형은 2개
    // 버텍스 인덱스는 시계방향으로 배치(전면으로 그려지도록)
    // 각 면의 버텍스 순서는 해당 면을 기준으로 LB-LT-RB, RB-LT-RT
    /*
        LB-LT-RB   RB-LT-RT

        1          1 ㅡ 2
        | ＼         ＼ |
        0 ㅡ 2          0
    */
    /// <summary> 큐브의 각 면을 이루는 삼각형들의 버텍스 인덱스 데이터 </summary>
    public static readonly int[,] voxelTris = new int[6, 6]
    {
        {0, 3, 1, 1, 3, 2 }, // Back Face   (-Z)
        {5, 6, 4, 4, 6, 7 }, // Front Face  (+Z)
        {3, 7, 2, 2, 7, 6 }, // Top Face    (+Y)
        {1, 5, 0, 0, 5, 4 }, // Bottom Face (-Y)
        {4, 7, 0, 0, 7, 3 }, // Left Face   (-X)
        {1, 2, 5, 5, 2, 6 }, // RIght Face  (+X)
    };

    /// <summary> voxelTris의 버텍스 인덱스 순서에 따라 정의된 UV 좌표 데이터 </summary>
    public static readonly Vector2[] voxelUvs = new Vector2[6]
    {
        new Vector2(0.0f, 0.0f), // LB
        new Vector2(0.0f, 1.0f), // LT
        new Vector2(1.0f, 0.0f), // RB

        new Vector2(1.0f, 0.0f), // RB
        new Vector2(0.0f, 1.0f), // LT
        new Vector2(1.0f, 1.0f), // RT
    };

    #endregion
}
```

</details>

<br>

## **청크**

- 일단 한 개의 정육면체로 이루어진 기본적인 청크를 정의한다.

- 6방향의 면을 모두 그려낸다.

- LUT를 활용하여 메시의 정점, 삼각형, UV 데이터를 반복문을 통해 효율적으로 정의할 수 있다.

<details>
<summary markdown="span"> 
Chunk.cs
</summary>

```cs
public class Chunk : MonoBehaviour
{
    public MeshRenderer meshRenderer;
    public MeshFilter meshFilter;

    private void Start()
    {
        int vertexIndex = 0;
        List<Vector3> vertices = new List<Vector3>();
        List<int> triangles = new List<int>();
        List<Vector2> uvs = new List<Vector2>();

        // 6방향의 면 그리기
        for (int p = 0; p < 6; p++)
        {
            // 각 면의 삼각형 2개 그리기
            for (int i = 0; i < 6; i++)
            {
                int triangleIndex = VoxelData.voxelTris[p, i];

                vertices.Add(VoxelData.voxelVerts[triangleIndex]);
                triangles.Add(vertexIndex);
                uvs.Add(VoxelData.voxelUvs[i]);

                vertexIndex++;
            }
        }

        // 메시에 데이터들 초기화
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            uv = uvs.ToArray()
        };

        mesh.RecalculateNormals(); // 필수

        meshFilter.mesh = mesh;
    }
}
```

</details>

<br>

## **복셀 시스템의 텍스쳐**

- `Max Size`는 적당히 작게 설정한다. (강좌에서는 32)
- `Wrap Mode`는 Clamp로, UV를 벗어나는 경우 반복되지 않게 한다.
- `Filter Mode`는 Point로 설정하여 텍셀이 부드럽게 보간되지 않게 한다.

<br>

## 현재 상태

![image](https://user-images.githubusercontent.com/42164422/112628321-197f7280-8e76-11eb-9b6e-cdf298d67561.png)

<br>

# 2. 
---






<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

<br>

# References
---
- <https://www.youtube.com/playlist?list=PLVsTSlfj0qsWEJ-5eMtXsYp03Y9yF1dEn>

