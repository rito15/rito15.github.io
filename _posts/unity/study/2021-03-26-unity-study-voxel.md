---
title: Voxel System(유니티에서 마인크래프트 구현하기)
author: Rito15
date: 2021-03-26 20:40:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 목차

- [목표](#목표)
- [1. 복셀 기본](#1-복셀-기본)
- [2. 청크와 맵 데이터](#2-청크와-맵-데이터)
- [3. 텍스쳐 입히기](#3-텍스쳐-입히기)
- [4. 월드에서 청크 생성 및 관리하기](#4-월드에서-청크-생성-및-관리하기)
- [5. 지형 만들기](#5-지형-만들기)
- [6. 캐릭터 컨트롤러 만들기](#6-캐릭터-컨트롤러-만들기)
- [](#)

<br>

# 목표
---

- [유튜브 강좌](https://www.youtube.com/playlist?list=PLVsTSlfj0qsWEJ-5eMtXsYp03Y9yF1dEn)를 따라가며 구현한다.

<br>

유니티엔진에서 마인크래프트와 같은 복셀 시스템을 구현한다.

모든 맵과 사물은 큐브 형태를 띠고 있으며, 생성하거나 파괴할 수 있다.

각각의 큐브를 개별 오브젝트로 렌더링할 경우 부하가 굉장히 크기 때문에,

일정 영역의 큐브들을 모아 하나의 청크(Chunk)이자 하나의 메시로 관리하는 것이 핵심이다.

<br>

# 1. 복셀 기본
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

## **현재 상태**

![image](https://user-images.githubusercontent.com/42164422/112628321-197f7280-8e76-11eb-9b6e-cdf298d67561.png)

<br>

# 2. 청크와 맵 데이터
---

## **정점 데이터 절약하기**

사각형을 그리려면 2개의 삼각형을 그려야 한다.

![image](https://user-images.githubusercontent.com/42164422/112721251-413e0b80-8f46-11eb-8fed-fad137b971e0.png)

첫 번째 삼각형은 3개의 정점으로 [LB - LT - RB], 두 번째 삼각형은 [RB - LT - RT]로 이루어져 있다.

따라서 `voxelTris` LUT를 만들 때 큐브의 6개의 면마다 각각 6개의 정점 인덱스로 총 36개의 정점 데이터를 이용했고,

메시의 `vertices` 배열에도 동일하게 버텍스를 추가했다.

<br>

그런데 사각형에는 실제로 네 개의 정점이 존재하므로 이렇게 하면 큐브의 면마다 정점 두 개만큼의 데이터가 낭비되는 셈이다.

따라서 LUT에는 정점 6개가 아니라 4개씩만 정의하고, 메시의 `vertices` 배열에도 면마다 4개의 정점만 추가한다.

그리고 `uvs` 배열에도 마찬가지로 면마다 4개의 정점을 추가한다.

대신에 `triangles` 배열에 `vertices`의 인덱스를 추가할 때 순차적으로 (i ~ i + 6)의 인덱스를 참조하는 것이 아니라, 알맞은 정점 인덱스를 찾아 추가하면 된다.

<br>

```cs
// [1] VoxelData.cs

// LUT - tris data (vertex indices)
public static readonly int[,] voxelTris = new int[6, 4]
{
    {0, 3, 1, 2 }, // Back Face   (-Z)
    {5, 6, 4, 7 }, // Front Face  (+Z)
    {3, 7, 2, 6 }, // Top Face    (+Y)
    {1, 5, 0, 4 }, // Bottom Face (-Y)
    {4, 7, 0, 3 }, // Left Face   (-X)
    {1, 2, 5, 6 }, // RIght Face  (+X)
};

// LUT - uv data
public static readonly Vector2[] voxelUvs = new Vector2[4]
{
    new Vector2(0.0f, 0.0f), // LB
    new Vector2(0.0f, 1.0f), // LT
    new Vector2(1.0f, 0.0f), // RB
    new Vector2(1.0f, 1.0f), // RT
};


// [2] Chunk.cs

// 1. Vertex, UV 4개 추가
for (int i = 0; i <= 3; i++)
{
    vertices.Add(VoxelData.voxelVerts[VoxelData.voxelTris[p, i]] + pos);
    uvs.Add(VoxelData.voxelUvs[i]);
}

// 2. Triangle의 버텍스 인덱스 6개 추가
triangles.Add(vertexIndex);
triangles.Add(vertexIndex + 1);
triangles.Add(vertexIndex + 2);

triangles.Add(vertexIndex + 2);
triangles.Add(vertexIndex + 1);
triangles.Add(vertexIndex + 3);

vertexIndex += 4;
```

<br>

## **복셀 맵 구성**

큐브 하나의 크기는 1 x 1 x 1로 정의한다고 할 때,

전체 복셀 맵은 간단히 [x, y, z] 좌표에 큐브가 존재하는지(is solid) 여부로 결정할 수 있다.

따라서 bool 타입의 3차원 배열로 맵을 정의할 수 있다.

<br>

우선 VoxelData 클래스에서 Chunk의 width(x, z 크기), height(y 크기)를 정의한다.

```cs
// VoxelData.cs

public static readonly int ChunkWidth = 5;
public static readonly int ChunkHeight = 5;
```

그리고 이를 복셀 맵 배열의 크기로 사용한다.

```cs
// Chunk.cs

private bool [,,] voxelMap = 
  new bool[VoxelData.ChunkWidth, VoxelData.ChunkHeight, VoxelData.ChunkWidth];
```

<br>

이제 voxelMap[x, y, z] == true인 좌표마다 크기가 1인 큐브 메시를 만들면 된다.

```cs
// Chunk.cs

private void CreateMeshData()
{
    for (int y = 0; y < VoxelData.ChunkHeight; y++)
    {
        for (int x = 0; x < VoxelData.ChunkWidth; x++)
        {
            for (int z = 0; z < VoxelData.ChunkWidth; z++)
            {
                AddVoxelDataToChunk(new Vector3(x, y, z));
            }
        }
    }
}

private void AddVoxelDataToChunk(Vector3 pos)
{
    // 6방향의 면 그리기
    // p : -Z, +Z, +Y, -Y, -X, +X 순서로 이루어진, 큐브의 각 면에 대한 인덱스
    for (int p = 0; p < 6; p++)
    {
        if (!voxelMap[(int)pos.x, (int)pos.y, (int)pos.z])
            continue;

        // 각 면(삼각형 2개) 그리기

        // 1. Vertex, UV 4개 추가
        for (int i = 0; i <= 3; i++)
        {
            vertices.Add(VoxelData.voxelVerts[VoxelData.voxelTris[p, i]] + pos);
            uvs.Add(VoxelData.voxelUvs[i]);
        }

        // 2. Triangle의 버텍스 인덱스 6개 추가
        triangles.Add(vertexIndex);
        triangles.Add(vertexIndex + 1);
        triangles.Add(vertexIndex + 2);

        triangles.Add(vertexIndex + 2);
        triangles.Add(vertexIndex + 1);
        triangles.Add(vertexIndex + 3);

        vertexIndex += 4;
    }
}
```

그런데 현재 상태로 그냥 메시를 만들면 외부에서 보이지 않는 청크 내부에도 폴리곤이 만들어진다.

이렇게 하면 청크를 만드는 의미가 없으므로, 외부에 드러난 면만 폴리곤이 만들어지도록 해주어야 한다.

<br>

## **청크의 바깥 면만 그려주기**

큐브가 존재하는 부분(solid)은 voxelMap[x, y, z]의 true/false 여부로 판정할 수 있게 되었지만,

각 면이 바깥 면인지 여부는 아직 알 수 없다.

따라서 이를 판정할 수 있도록 해주어야 한다.

<br>

우선, 새로운 LUT를 만들어준다.

```cs
// VoxelData.cs

public static readonly Vector3[] faceChecks = new Vector3[6]
{
    new Vector3( 0.0f,  0.0f, -1.0f), // Back Face   (-Z)
    new Vector3( 0.0f,  0.0f, +1.0f), // Front Face  (+Z)
    new Vector3( 0.0f, +1.0f,  0.0f), // Top Face    (+Y)
    new Vector3( 0.0f, -1.0f,  0.0f), // Bottom Face (-Y)
    new Vector3(-1.0f,  0.0f,  0.0f), // Left Face   (-X)
    new Vector3(+1.0f,  0.0f,  0.0f), // RIght Face  (+X)
};
```

voxelTris(큐브의 6개 면마다 각각 정점 인덱스 순서) 배열의 면 순서와 동일하게,

faceChecks 배열을 정의한다.

그리고 특정 좌표가 solid인지 확인하는 메소드를 작성한다.

```cs
// Chunk.cs

private bool CheckVoxel(Vector3 pos)
{
    int x = Mathf.FloorToInt(pos.x);
    int y = Mathf.FloorToInt(pos.y);
    int z = Mathf.FloorToInt(pos.z);

    // 맵 범위를 벗어나는 경우
    if(x < 0 || x > VoxelData.ChunkWidth - 1 || 
       y < 0 || y > VoxelData.ChunkHeight - 1 ||
       z < 0 || z > VoxelData.ChunkWidth - 1)
        return false;

    return voxelMap[x, y, z];
}
```

<br>

이제 faceChecks 배열과 CheckVoxel() 메소드를 이용하여 청크의 바깥 면만 그려지도록 AddVoxelDataToChunk() 메소드를 수정한다.

원리는 간단하다.

큐브가 그려질 좌표에서 6개의 면마다 faceCheck를 통해 해당 면이 바라보는 방향으로 1칸 이동한 지점이 solid(true)이면 해당 면은 청크의 내부를 바라보고 있다는 의미이므로 그리지 않고,

false일 경우 청크의 외부를 바라보고 있다는 것이므로, 다시 말해 청크의 바깥 면이라는 것을 의미하기 때문에 해당 면은 그려주면 된다.

```cs
// Chunk.cs

private void AddVoxelDataToChunk(Vector3 pos)
{
    // 6방향의 면 그리기
    // p : -Z, +Z, +Y, -Y, -X, +X 순서로 이루어진, 큐브의 각 면에 대한 인덱스
    for (int p = 0; p < 6; p++)
    {
        // Face Check(면이 바라보는 방향으로 +1 이동하여 확인)를 했을 때 
        // Solid가 아닌 경우에만 큐브의 면이 그려지도록 하기
        // => 청크의 외곽 부분만 면이 그려지고, 내부에는 면이 그려지지 않도록
        if (CheckVoxel(pos) && !CheckVoxel(pos + VoxelData.faceChecks[p]))
        {
            // 각 면(삼각형 2개) 그리기

            // 1. Vertex, UV 4개 추가
            for (int i = 0; i <= 3; i++)
            {
                vertices.Add(VoxelData.voxelVerts[VoxelData.voxelTris[p, i]] + pos);
                uvs.Add(VoxelData.voxelUvs[i]);
            }

            // 2. Triangle의 버텍스 인덱스 6개 추가
            triangles.Add(vertexIndex);
            triangles.Add(vertexIndex + 1);
            triangles.Add(vertexIndex + 2);

            triangles.Add(vertexIndex + 2);
            triangles.Add(vertexIndex + 1);
            triangles.Add(vertexIndex + 3);

            vertexIndex += 4;
        }
    }
}
```

<br>

## **현재 상태**

- [1] 5 x 5 x 5 맵의 모든 부분이 true(solid)인 경우

![image](https://user-images.githubusercontent.com/42164422/112720764-d4297680-8f43-11eb-8746-c174c7186a0f.png)

- [2] voxelMap[x, y, z] = (x >= y && z >= y)

![image](https://user-images.githubusercontent.com/42164422/112720809-0044f780-8f44-11eb-8fb2-672e3367d2c0.png)

<br>

# 3. 텍스쳐 입히기
---

## **블록 타입 정의**

현재 bool타입의 `voxelMap`으로는 해당 좌표에 블록이 존재하는지 여부만 판단할 수 있다.

하지만 텍스쳐를 입히기 위해서는 블록의 타입을 구체적으로 정의할 필요가 있다.

우선 `BlockType` 클래스를 작성한다.

```cs
[Serializable]
public class BlockType
{
    public string blockName;
    public bool isSolid;
}
```

그리고 각 블록타입들에 대한 정보를 배열로 가지고 있도록 하기 위한 `World` 컴포넌트 클래스를 작성한다.

```cs
public class World : MonoBehaviour
{
    public Material material;
    public BlockType[] blockTypes;
}
```

하이라키에서 `World` 게임오브젝트를 만들고 여기에 컴포넌트로 추가한 다음, 배열의 0번 인덱스에 `Default` 블록 타입을 만들어준다.

![image](https://user-images.githubusercontent.com/42164422/112747437-6b4c0800-8ff0-11eb-9e02-9b1636d778e6.png)

<br>

이제 `Chunk` 클래스의 내용을 수정한다.

```cs
// bool -> byte 타입 배열로 변경
private byte [,,] voxelMap = 
  new byte[VoxelData.ChunkWidth, VoxelData.ChunkHeight, VoxelData.ChunkWidth];

// World 컴포넌트 참조(Start() 내부에서 FindObjectOfType<World>())
private World world;


private bool CheckVoxel(Vector3 pos)
{
    // ...

    // voxelMap[]의 값은 blockTypes[]의 인덱스로 사용하여,
    // 참조한 블록 타입에서 isSolid 값을 읽어온다.
    return world.blockTypes[voxelMap[x, y, z]].isSolid;
}

```

<br>

## **텍스쳐 아틀라스 사용하기**

서로 다른 텍스쳐를 통째로 준비하고, 각 블록마다 다르게 입혀주려면

마테리얼을 분리하거나, 커스텀 쉐이더를 작성하여 필요한 텍스쳐 프로퍼티를 모두 만들어주어야 하는데

이는 모두 비효율적이므로

여러 장의 텍스쳐가 동일한 크기로 포함되어 있는 텍스쳐 아틀라스를 사용한다.

<https://www.kenney.nl/> 에서 무료 복셀 텍스쳐 아틀라스를 다운받아 사용하였다.

<br>

예를 들어

![image](https://user-images.githubusercontent.com/42164422/112750486-d226ec80-9003-11eb-93bb-cc52c4e64544.png)

이런 텍스쳐 아틀라스를 준비했을 때,

가로 세로 9x10 크기로 총 90개의 텍스쳐가 아틀라스 내에 들어갈 수 있다.

그리고 다른 크기의 아틀라스를 사용할 것을 대비하여, 월드 내에서 사용할 텍스쳐 아틀라스의 크기를 변수값으로 정의한다.

```cs
// VoxelData.cs

// 텍스쳐 아틀라스의 가로, 세로 텍스쳐 개수
public static readonly int TextureAtlasWidth = 9;
public static readonly int TextureAtlasHeight = 10;

// 텍스쳐 아틀라스 내에서 각 행, 열마다 텍스쳐가 갖는 크기 비율
public static float NormalizedTextureAtlasWidth
    => 1f / TextureAtlasWidth;
public static float NormalizedTextureAtlasHeight
    => 1f / TextureAtlasHeight;
```

<br>

이제 텍스쳐 아틀라스 내의 각 텍스쳐를 참조할 인덱스(텍스쳐ID)를 미리 정의해야 한다.

유니티에서의 UV 좌표는 좌하단이 (0,0)이므로 좌하단의 텍스쳐를 인덱스 0으로 사용할 수도 있고,

여기서는 강좌를 따라 좌상단의 텍스쳐를 인덱스 0으로 정의하여 사용할 것이다.

![spritesheet_tiles_reference](https://user-images.githubusercontent.com/42164422/112750573-511c2500-9004-11eb-8a5b-3bc334c03bf9.png)

그리고 텍스쳐의 인덱스를 통해 아틀라스 내의 해당 텍스쳐가 갖는 uv 좌표를 얻어오는 메소드를 작성한다.

```cs
// Chunk.cs

/// <summary> 텍스쳐 아틀라스 내에서 해당하는 ID의 텍스쳐가 위치한 UV를 uvs 리스트에 추가 </summary>
private void AddTextureUV(int textureID)
{
    // 아틀라스 내의 텍스쳐 가로, 세로 개수
    (int w, int h) = (VoxelData.TextureAtlasWidth, VoxelData.TextureAtlasHeight);

    int x = textureID % w;
    int y = h - (textureID / w) - 1;

    AddTextureUV(x, y);
}

// (x, y) : (0, 0) 기준은 좌하단
/// <summary> 텍스쳐 아틀라스 내에서 (x, y) 위치의 텍스쳐 UV를 uvs 리스트에 추가 </summary>
private void AddTextureUV(int x, int y)
{
    if (x < 0 || y < 0 || x >= VoxelData.TextureAtlasWidth || y >= VoxelData.TextureAtlasHeight)
        throw new IndexOutOfRangeException($"텍스쳐 아틀라스의 범위를 벗어났습니다 : [x = {x}, y = {y}]");

    float nw = VoxelData.NormalizedTextureAtlasWidth;
    float nh = VoxelData.NormalizedTextureAtlasHeight;

    float uvX = x * nw;
    float uvY = y * nh;

    // 해당 텍스쳐의 uv를 LB-LT-RB-RT 순서로 추가
    uvs.Add(new Vector2(uvX, uvY));
    uvs.Add(new Vector2(uvX, uvY + nh));
    uvs.Add(new Vector2(uvX + nw, uvY));
    uvs.Add(new Vector2(uvX + nw, uvY + nh));
}
```

그리고 AddVoxelDataToChunk() 메소드에서 UV를 추가하던 부분을 변경한다.

```cs
// Chunk.cs - AddVoxelDataToChunk()

// 기존
for (int i = 0; i <= 3; i++)
{
    uvs.Add(VoxelData.voxelUvs[i]);
}

// 변경
AddTextureUV(43); // 텍스쳐 ID
```

새로운 마테리얼을 생성하여, `Unlit/Texture` 쉐이더를 지정하고 텍스쳐 아틀라스를 넣어준다.

그리고 이 마테리얼을 Chunk에 적용해준다.

![image](https://user-images.githubusercontent.com/42164422/112750699-16ff5300-9005-11eb-894d-c90793553b3e.png)

결과 :

![image](https://user-images.githubusercontent.com/42164422/112750714-2bdbe680-9005-11eb-88de-f3d63a3c761c.png)

<br>

## **블록의 면마다 텍스쳐 ID 지정하기**

하나의 블록이라도 윗면, 옆면, 아랫면에 따라 텍스쳐가 다르게 입혀져야 한다.

따라서 `BlockType` 클래스를 수정한다.

```cs
// VoxelData class
public const int BackFace   = 0;
public const int FrontFace  = 1;
public const int TopFace    = 2;
public const int BottomFace = 3;
public const int LeftFace   = 4;
public const int RightFace  = 5;


// BlockType class
public string blockName;
public bool isSolid;

[Header("Texture IDs")]
public int topFaceTextureID;
public int frontFaceTextureID;
public int backFaceTextureID;
public int leftFaceTextureID;
public int rightFaceTextureID;
public int bottomFaceTextureID;

// Order : Back, Front, Top, Bottom, Left, Right
/// <summary> Face Index(0~5)에 해당하는 텍스쳐 ID 리턴 </summary>
public int GetTextureID(int faceIndex)
{
    switch (faceIndex)
    {
        case VoxelData.TopFace:    return topFaceTextureID;
        case VoxelData.FrontFace:  return frontFaceTextureID;
        case VoxelData.BackFace:   return backFaceTextureID;
        case VoxelData.LeftFace:   return leftFaceTextureID;
        case VoxelData.RightFace:  return rightFaceTextureID;
        case VoxelData.BottomFace: return bottomFaceTextureID;

        default:
            throw new IndexOutOfRangeException($"Face Index must be in 0 ~ 5, but input : {faceIndex}");
    }
}
```

<br>

그리고 `Chunk` 클래스에 다음 메소드를 추가하고,

```cs
/// <summary> voxelMap으로부터 특정 위치에 해당하는 블록 ID 가져오기 </summary>
private byte GetBlockID(in Vector3 pos)
{
    return voxelMap[(int)pos.x, (int)pos.y, (int)pos.z];
}
```

`AddVoxelDataToChunk()` 메소드를 수정한다.

```cs
private void AddVoxelDataToChunk(in Vector3 pos)
{
    // 6방향의 면 그리기
    // face : -Z, +Z, +Y, -Y, -X, +X 순서로 이루어진, 큐브의 각 면에 대한 인덱스
    for (int face = 0; face < 6; face++)
    {
        // Face Check(면이 바라보는 방향으로 +1 이동하여 확인)를 했을 때 
        // Solid가 아닌 경우에만 큐브의 면이 그려지도록 하기
        // => 청크의 외곽 부분만 면이 그려지고, 내부에는 면이 그려지지 않도록

        // 각 면(삼각형 2개) 그리기
        if (CheckVoxel(pos) && !CheckVoxel(pos + VoxelData.faceChecks[face]))
        {
            byte blockID = GetBlockID(pos);

            // 1. Vertex 4개 추가
            for (int i = 0; i <= 3; i++)
            {
                vertices.Add(VoxelData.voxelVerts[VoxelData.voxelTris[face, i]] + pos);
            }

            // 2. 텍스쳐에 해당하는 UV 추가
            AddTextureUV(world.blockTypes[blockID].GetTextureID(face));

            // 3. Triangle의 버텍스 인덱스 6개 추가
            triangles.Add(vertexIndex);
            triangles.Add(vertexIndex + 1);
            triangles.Add(vertexIndex + 2);

            triangles.Add(vertexIndex + 2);
            triangles.Add(vertexIndex + 1);
            triangles.Add(vertexIndex + 3);

            vertexIndex += 4;
        }
    }
}
```

<br>

World 컴포넌트의 인스펙터에서 블록 타입마다 알맞은 텍스쳐 인덱스들을 넣어준다.

![image](https://user-images.githubusercontent.com/42164422/112751783-b246f700-900a-11eb-8c82-cec2ed0476ca.png)

결과 :

![image](https://user-images.githubusercontent.com/42164422/112751392-c1c54080-9008-11eb-8c6b-7aeaaca51739.png)

<br>

각 텍스쳐 아틀라스 내에서 각 텍스쳐의 uv를 참조할 때 인접한 텍스쳐를 살짝 참조하여 위처럼 보기 좋지 않은 경계선들이 생길 수 있다.

이를 방지하기 위해, `AddTextureUV()` 메소드에서 각 uv의 offset을 연산하여 참조할 수 있도록 수정한다.

```cs
private void AddTextureUV(int x, int y)
{
    // 텍스쳐 내에서 의도치 않게 들어가는 부분 잘라내기
    const float uvXBeginOffset = 0.005f;
    const float uvXEndOffset   = 0.005f;
    const float uvYBeginOffset = 0.01f;
    const float uvYEndOffset   = 0.01f;

    if (x < 0 || y < 0 || x >= VoxelData.TextureAtlasWidth || y >= VoxelData.TextureAtlasHeight)
        throw new IndexOutOfRangeException($"텍스쳐 아틀라스의 범위를 벗어났습니다 : [x = {x}, y = {y}]");

    float nw = VoxelData.NormalizedTextureAtlasWidth;
    float nh = VoxelData.NormalizedTextureAtlasHeight;

    float uvX = x * nw;
    float uvY = y * nh;

    // 해당 텍스쳐의 uv를 LB-LT-RB-RT 순서로 추가
    uvs.Add(new Vector2(uvX + uvXBeginOffset, uvY + uvYBeginOffset));
    uvs.Add(new Vector2(uvX + uvXBeginOffset, uvY + nh - uvYEndOffset));
    uvs.Add(new Vector2(uvX + nw - uvXEndOffset, uvY + uvYBeginOffset));
    uvs.Add(new Vector2(uvX + nw - uvXEndOffset, uvY + nh - uvYEndOffset));
}
```

결과 :

![image](https://user-images.githubusercontent.com/42164422/112751949-89733180-900b-11eb-9977-2074340123b3.png)

<br>

그리고 블록 구성과 `PopulateVoxelMap()` 메소드를 적절히 수정하면 다음과 같은 결과를 얻을 수 있다.

![image](https://user-images.githubusercontent.com/42164422/112752006-c808ec00-900b-11eb-86b8-03d699487325.png)

<br>

## **밉맵 생성하지 않게 하기**

씬뷰에서 카메라를 이리저리 움직여보면

![image](https://user-images.githubusercontent.com/42164422/112752033-ef5fb900-900b-11eb-8975-97a6bbc7e81f.png)

간혹 이렇게 흉하게 깨져보이는 경우를 볼 수 있다.

이런 경우에는 텍스쳐 인스펙터에서 `Advanced` - `Generate Mip Maps`를 체크 해제하여 밉맵을 생성하지 않게 하면 된다.

<br>

# 4. 월드에서 청크 생성 및 관리하기
---

## **Chunk 클래스 수정**

Chunk 클래스가 MonoBehaviour를 상속받지 않도록 변경한다.

그리고 Start() 메소드에서 수행하던 동작들을 생성자로 옮긴다.

```cs
// Chunk class

private GameObject chunkObject; // 청크가 생성될 대상 게임오브젝트
private MeshRenderer meshRenderer;
private MeshFilter meshFilter;

// 생성자
public Chunk(World world)
{
    this.world = world;

    chunkObject = new GameObject();
    meshRenderer = chunkObject.AddComponent<MeshRenderer>();
    meshFilter = chunkObject.AddComponent<MeshFilter>();

    meshRenderer.material = this.world.material;
    chunkObject.transform.SetParent(world.transform);

    PopulateVoxelMap();
    CreateMeshData();
    CreateMesh();
}
```

<br>

그리고 Chunk가 상대좌표를 갖도록 ChunkCoord 클래스를 작성한다.

```cs
public class ChunkCoord
{
    public int x;
    public int z;

    public ChunkCoord(int x, int z)
    {
        this.x = x;
        this.z = z;
    }
}
```

ChunkCoord 클래스는 Chunk 내에서 필드로 사용되도록 하고, Chunk의 생성자를 수정한다.

```cs
// Chunk class

public ChunkCoord coord;

public Chunk(ChunkCoord coord, World world)
{
    this.coord = coord;
    this.world = world;

    chunkObject = new GameObject();
    meshRenderer = chunkObject.AddComponent<MeshRenderer>();
    meshFilter = chunkObject.AddComponent<MeshFilter>();

    meshRenderer.material = world.material;
    chunkObject.transform.SetParent(world.transform);
    chunkObject.transform.position = 
        new Vector3(coord.x * VoxelData.ChunkWidth, 0f, coord.z * VoxelData.ChunkWidth);
    chunkObject.name = $"Chunk [{coord.x}, {coord.z}]";

    PopulateVoxelMap();
    CreateMeshData();
    CreateMesh();
}
```

<br>

이제 World 클래스에서 Chunk들을 생성하여 관리할 수 있다.

```cs
public class World : MonoBehaviour
{
    public Material material;
    public BlockType[] blockTypes;

    private void Start()
    {
        Chunk chunk0 = new Chunk(new ChunkCoord(0, 0), this);
        Chunk chunk1 = new Chunk(new ChunkCoord(1, 0), this);
    }
}
```

<br>

## **World 클래스 수정**

Chunk에서 국지적으로 수행하던 기능을 World에서 담당하도록 수정한다.

```cs
// World class

// 월드 내의 모든 청크
private Chunk[,] chunks = new Chunk[VoxelData.WorldSizeInChunks, VoxelData.WorldSizeInChunks];

private void Start()
{
    GenerateWorld();
}

private void GenerateWorld()
{
    for (int x = 0; x < VoxelData.WorldSizeInChunks; x++)
    {
        for (int z = 0; z < VoxelData.WorldSizeInChunks; z++)
        {
            CreateNewChunk(x, z);
        }
    }
}

private void CreateNewChunk(int x, int z)
{
    chunks[x, z] = new Chunk(new ChunkCoord(x, z), this);
}

// 해당 위치의 블록 타입을 결정
public byte GetBlockType(in Vector3 pos)
{
    if(pos.y >= VoxelData.ChunkHeight - 1)
        return Grass; // 1
    else
        return Ground; // 2
}
```

그리고 Chunk 클래스의 `PopulateVoxelMap()` 메소드를 수정한다.

```cs
private void PopulateVoxelMap()
{
    for (int y = 0; y < VoxelData.ChunkHeight; y++)
    {
        for (int x = 0; x < VoxelData.ChunkWidth; x++)
        {
            for (int z = 0; z < VoxelData.ChunkWidth; z++)
            {
                voxelMap[x, y, z] = world.GetBlockType(new Vector3(x, y, z));
            }
        }
    }
}
```

그런데 생성된 청크들의 내부를 들여다보면

![image](https://user-images.githubusercontent.com/42164422/112816743-ac115300-90bc-11eb-96a6-f5a6acec235c.png)

이렇게 각각의 청크가 독립된 큐브 형태의 메시를 지니기 때문에, 결국 바깥에서 보이지 않는 부분도 그려지게 되는, 초기의 문제가 동일하게 발생하는 것을 확인할 수 있다.

<br>

해결을 위해 우선 World 클래스 내에 메소드들을 작성 및 수정한다.

```cs
// World class

/// <summary> 해당 위치의 복셀이 월드 내에 있는지 검사 </summary>
private bool IsBlockInWorld(in Vector3 worldPos)
{
    return
        worldPos.x >= 0 && worldPos.x < VoxelData.WorldSizeInVoxels &&
        worldPos.z >= 0 && worldPos.z < VoxelData.WorldSizeInVoxels &&
        worldPos.y >= 0 && worldPos.y < VoxelData.ChunkHeight;
}

/// <summary> 해당 위치의 블록 타입 검사</summary>
public byte GetBlockType(in Vector3 worldPos)
{
    if(!IsBlockInWorld(worldPos))
        return Air;

    if(worldPos.y >= VoxelData.ChunkHeight - 1)
        return Grass;
    else
        return Ground;
}

/// <summary> 해당 위치의 블록이 단단한지 검사</summary>
public bool IsBlockSolid(in Vector3 worldPos)
{
    return blockTypes[GetBlockType(worldPos)].isSolid;
}
```

그리고 청크 내부의 Solid 여부만 검사하던 Chunk.IsSolid() 메소드를 수정한다.

```
// Chunk class

private bool IsSolid(in Vector3 pos)
{
    return world.IsBlockSolid(pos + WorldPos);
}
```

![image](https://user-images.githubusercontent.com/42164422/112828193-5ba0f200-90ca-11eb-931a-cafbd439ca41.png)

이제 청크가 아니라 월드 단위로 내부와 외부를 판단하여 바깥 폴리곤만 그리게 된다.

<br>

## **시야 범위 내에서만 청크 생성**

현재로서는 월드 내의 모든 청크가 생성되고, 렌더링된다.

하지만 성능을 위해서는 지정된 플레이어 주변의 일정 영역 내에 존재하는 청크들만 생성되도록 해야 한다.

VoxelData 클래스에 새로운 필드를 추가하고, 기존의 필드값 하나를 수정한다.

```cs
// VoxelData class

public static readonly int WorldSizeInChunks = 100; // 5 -> 100

// 시야 범위(청크 개수)
public static readonly int ViewDistanceInChunks = 5;
```

'시야'라는 것은 특정 대상을 중심으로 고려되어야 한다.

따라서 World 클래스에 다음 내용을 추가한다.

```cs
// World class

public Transform player;
public Vector3 spawnPosition;

/// <summary> 해당 청크 좌표가 월드 XZ 범위 내에 있는지 검사 </summary>
private bool IsChunkPosInWorld(int x, int z)
{
    return x >= 0 && x < VoxelData.WorldSizeInChunks &&
           z >= 0 && z < VoxelData.WorldSizeInChunks;
}

/// <summary> 월드 위치의 청크 좌표 리턴 </summary>
private ChunkCoord GetChunkCoordFromWorldPos(in Vector3 worldPos)
{
    int x = (int)(worldPos.x / VoxelData.ChunkWidth);
    int z = (int)(worldPos.z / VoxelData.ChunkWidth);
    return new ChunkCoord(x, z);
}

private void InitPositions()
{
    spawnPosition = new Vector3(
        VoxelData.WorldSizeInVoxels * 0.5f,
        VoxelData.ChunkHeight,
        VoxelData.WorldSizeInVoxels * 0.5f
    );
    player.position = spawnPosition;
}

private void GenerateWorld()
{
    int center = VoxelData.WorldSizeInChunks / 2;
    int viewMin = center - VoxelData.ViewDistanceInChunks;
    int viewMax = center + VoxelData.ViewDistanceInChunks;

    for (int x = viewMin; x < viewMax; x++)
    {
        for (int z = viewMin; z < viewMax; z++)
        {
            CreateNewChunk(x, z);
        }
    }
}

/// <summary> 시야범위 내의 청크 생성 </summary>
private void UpdateChunksInViewRange()
{
    ChunkCoord coord = GetChunkCoordFromWorldPos(player.position);
    int viewDist = VoxelData.ViewDistanceInChunks;
    (int x, int z) viewMin = (coord.x - viewDist, coord.z - viewDist);
    (int x, int z) viewMax = (coord.x + viewDist, coord.z + viewDist);

    for (int x = viewMin.x; x < viewMax.x; x++)
    {
        for (int z = viewMin.z; z < viewMax.z; z++)
        {
            // 청크 좌표가 월드 범위 내에 있는지 검사
            if (IsChunkPosInWorld(x, z) == false)
                continue;

            // 시야 범위 내에 청크가 생성되지 않은 영역이 있을 경우, 새로 생성
            if (chunks[x, z] == null)
                CreateNewChunk(x, z);
        }
    }
}

private void Start()
{
    InitPositions();
    GenerateWorld();
}

private void Update()
{
    UpdateChunksInViewRange();
}
```

이제 플레이어가 이동했을 때 시야 범위가 닿는 곳에 청크가 존재하지 않으면 새롭게 생성한다.

![2021_0329_VoxelSystem_1](https://user-images.githubusercontent.com/42164422/112835539-606aa380-90d4-11eb-9d42-24251335693a.gif)

<br>

## **시야 범위 내에서만 청크 유지**

플레이어의 시야 범위를 벗어나는 범위의 청크는 파괴하거나 비활성화할 필요가 있다.

생성/파괴는 비싼 작업이므로, 오브젝트 풀링하듯 시야 범위를 벗어나는 청크들은 비활성화하고, 시야 범위 내에 들어온 청크들만 실시간으로 활성화하도록 한다.

우선 두 개의 리스트를 만든다.

```cs
// World class

// 이전 프레임에 활성화 되었던 청크 목록
private List<Chunk> prevActiveChunkList = new List<Chunk>();

// 현재 프레임에 활성화된 청크 목록
private List<Chunk> currentActiveChunkList = new List<Chunk>();
```

그리고 UpdateChunksInViewRange() 메소드를 수정한다.

```cs
/// <summary> 시야범위 내의 청크들만 유지 </summary>
private void UpdateChunksInViewRange()
{
    ChunkCoord coord = GetChunkCoordFromWorldPos(player.position);
    int viewDist = VoxelData.ViewDistanceInChunks;
    (int x, int z) viewMin = (coord.x - viewDist, coord.z - viewDist);
    (int x, int z) viewMax = (coord.x + viewDist, coord.z + viewDist);

    // 활성 목록 : 현재 -> 이전으로 이동
    prevActiveChunkList = currentActiveChunkList;
    currentActiveChunkList = new List<Chunk>();

    for (int x = viewMin.x; x < viewMax.x; x++)
    {
        for (int z = viewMin.z; z < viewMax.z; z++)
        {
            // 청크 좌표가 월드 범위 내에 있는지 검사
            if (IsChunkPosInWorld(x, z) == false)
                continue;

            Chunk currentChunk = chunks[x, z];

            // 시야 범위 내에 청크가 생성되지 않은 영역이 있을 경우, 새로 생성
            if (chunks[x, z] == null)
            {
                CreateNewChunk(x, z);
                currentChunk = chunks[x, z]; // 참조 갱신
            }
            // 비활성화 되어있던 경우에는 활성화
            else if(chunks[x, z].IsActive == false)
            {
                chunks[x, z].IsActive = true;
            }

            // 현재 활성 목록에 추가
            currentActiveChunkList.Add(currentChunk);

            // 이전 활성 목록에서 제거
            if (prevActiveChunkList.Contains(currentChunk))
                prevActiveChunkList.Remove(currentChunk);
        }
    }

    // 차집합으로 남은 청크들 비활성화
    foreach (var chunk in prevActiveChunkList)
    {
        chunk.IsActive = false;
    }
}
```

이전 프레임에 활성화되었던 청크들이 현재 프레임에는 활성화되지 않은 경우,

해당 청크들을 비활성화 해주기만 하면 된다.

![2021_0329_VoxelSystem_2](https://user-images.githubusercontent.com/42164422/112843745-e3442c00-90dd-11eb-9a2e-d1fd99e09a94.gif)

그러면 이렇게 시야 범위 내에서만 청크들을 활성화 상태로 유지할 수 있다.

<br>

## 최적화

현재 Update()에서 매 프레임마다 시야 범위를 갱신해주고 있는데,

이를 두 가지 방법으로 최적화 해줄 수 있다.

1. 플레이어가 다른 청크로 이동했을 때만 갱신한다.

2. Update()가 아니라 코루틴에서 더 긴 주기마다 갱신한다.

여기서는 일단 1번 방식만 이용하도록 한다.

```cs
// World.cs

// 플레이어의 이전 프레임 위치
private ChunkCoord prevPlayerCoord;

// 플레이어의 현재 프레임 위치
private ChunkCoord currentPlayerCoord;


private void Start()
{
    InitPositions();
    //GenerateWorld(); // 필요 X (UpdateChunksInViewRange()에서 수행)
}

private void Update()
{
    currentPlayerCoord = GetChunkCoordFromWorldPos(player.position);

    // 플레이어가 청크 위치를 이동한 경우, 시야 범위 갱신
    if(!prevPlayerCoord.Equals(currentPlayerCoord))
        UpdateChunksInViewRange();

    prevPlayerCoord = currentPlayerCoord;
}


// 수정
private void InitPositions()
{
    spawnPosition = new Vector3(
        VoxelData.WorldSizeInVoxels * 0.5f,
        VoxelData.ChunkHeight,
        VoxelData.WorldSizeInVoxels * 0.5f
    );
    player.position = spawnPosition;

    prevPlayerCoord = new ChunkCoord(-1, -1);
    currentPlayerCoord = GetChunkCoordFromWorldPos(player.position);
}
```

<br>

# 5. 지형 만들기
---

## **펄린 노이즈**

랜덤랜덤한 지형을 만들기 위해서 펄린 노이즈를 이용한다.

펄린 노이즈를 계산할 정적 클래스를 작성한다.

```cs
// Noise.cs

public static class Noise
{
    public static float Get2DPerlin(in Vector2 position, float offset, float scale)
    {
        // 각자 0.1을 더해주는 이유 : 버그가 있어서
        return Mathf.PerlinNoise 
        (
            (position.x + 0.1f) / VoxelData.ChunkWidth * scale + offset,
            (position.y + 0.1f) / VoxelData.ChunkWidth * scale + offset
        );
    }
}
```

그리고 `World` 클래스에서 이를 이용해 표면을 2가지 블록으로 그려본다.

```cs
// World class

[Space]
public int seed;

private void Start()
{
    Random.InitState(seed);

    InitPositions();
}

/// <summary> 해당 위치의 블록 타입 검사</summary>
public byte GetBlockType(in Vector3 worldPos)
{
    // 월드 범위 밖이면 공기
    if(!IsBlockInWorld(worldPos))
        return Air;
    
    // 높이 0까지는 기반암
    if(worldPos.y < 1)
        return Bedrock;

    // 맨 위 표면
    if (worldPos.y >= VoxelData.ChunkHeight - 1)
    {
        float noise = Noise.Get2DPerlin(new Vector2(worldPos.x, worldPos.z), 0f, 0.1f);

        if(noise < 0.5f)
            return Grass;
        else
            return Sand;
    }
    // 표면 ~ 기반암 사이 : 돌멩이
    else
        return Stone;
}
```

![2021_0331_Voxel_Noise](https://user-images.githubusercontent.com/42164422/113118519-831ec880-924a-11eb-88d8-75d498118900.gif)

<br>

## **3D 지형 그리기**

펄린 노이즈로 얻어낸 값을 높이로 사용하여

청크에서 y축 높이가 펄린 노이즈 값과 일치하는 좌표에는 표면을 그리고,

더 높은 경우에는 비워놓고(Air),

더 낮은 경우에는 지반을 그리는 형태로 수정한다.

```cs
// World class

public byte GetBlockType(in Vector3 worldPos)
{
    // NOTE : 모든 값은 0보다 크거나 같기 때문에 Mathf.FloorToInt() 할 필요 없음

    int yPos = (int)worldPos.y;

    /* -----------------------------------------------
                        Immutable Pass
    ----------------------------------------------- */
    // 월드 밖 : 공기
    if (!IsBlockInWorld(worldPos))
        return Air;
            
    // 높이 0은 기반암
    if(yPos == 0)
        return Bedrock;

    /* -----------------------------------------------
                    Basic Terrain Pass
    ----------------------------------------------- */
    // noise : 0.0 ~ 1.0
    float noise = Noise.Get2DPerlin(new Vector2(worldPos.x, worldPos.z), 500f, 0.25f);
    float terrainHeight = (int)(VoxelData.ChunkHeight * noise);

    // terrainHeight : 0 ~ VoxelData.ChunkHeight(15)

    // 지면
    if (yPos == terrainHeight)
    {
        return Grass;
    }
    // 땅속
    else if (yPos < terrainHeight)
    {
        return Stone;
    }
    else
    {
        return Air;
    }
}
```

![2021_0331_Voxel_Noise2](https://user-images.githubusercontent.com/42164422/113122024-33da9700-924e-11eb-800e-e0abd1c580ca.gif)

<br>

## **Biome 정의**

지정한 환경 데이터에 따라 지형 분포를 다르게 할 수 있도록, Biome을 정의하고 이를 World 클래스에서 사용하도록 한다.

Biome은 생태계 정도로 해석하면 될 것 같다.

```cs
/// <summary> 지형 분포 데이터 </summary>
[CreateAssetMenu(fileName = "BiomeData", menuName = "Voxel System/Biome Attribute")]
public class BiomeData : ScriptableObject
{
    public string biomeName;

    // 이 값 이하의 높이는 모두 solid
    public int solidGroundHeight;

    // solidGroundHeight로부터 증가할 수 있는 최대 높이값
    public int terrainHeightRange;

    public float terrainScale;

    /*
        예시

        solidGroundHeight  = 40;
        terrainHeightRange = 30;

        => 지형의 최소 높이 : 40, 지형의 최대 높이(고지) : 70
    */
}


// VoxelData class

// 청크 내의 X, Z 성분 복셀 개수
public static readonly int ChunkWidth = 16;

// 청크 내의 Y 성분 복셀 개수
public static readonly int ChunkHeight = 128;

/// <summary> 월드의 각 X, Z 성분 청크 개수 </summary>
public static readonly int WorldSizeInChunks = 10;


// World class

public BiomeData biome;

public byte GetBlockType(in Vector3 worldPos)
{
    int yPos = (int)worldPos.y;

    /* -----------------------------------------------
                        Immutable Pass
    ----------------------------------------------- */
    // 월드 밖 : 공기
    if (!IsBlockInWorld(worldPos))
        return Air;
            
    // 높이 0은 기반암
    if(yPos == 0)
        return Bedrock;

    /* -----------------------------------------------
                    Basic Terrain Pass
    ----------------------------------------------- */
    // noise : 0.0 ~ 1.0
    float noise = Noise.Get2DPerlin(new Vector2(worldPos.x, worldPos.z), 0f, biome.terrainScale);

    // 지형 높이 : solidGroundHeight ~ (solidGroundHeight + terrainHeightRange)
    float terrainHeight = (int)(biome.terrainHeightRange * noise) + biome.solidGroundHeight;


    // 공기
    if (yPos > terrainHeight)
    {
        return Air;
    }

    // 지면
    if (yPos == terrainHeight)
    {
        return Grass;
    }
    // 얕은 땅속
    else if (terrainHeight - 4 < yPos && yPos < terrainHeight)
    {
        return Dirt;
    }
    // 깊은 땅속
    else
    {
        return Stone;
    }
}
```

![image](https://user-images.githubusercontent.com/42164422/113137733-e2d39e80-925f-11eb-87f5-3033910e5de6.png)

biome은 기본 값으로 SolidGroundHeight, terrainHeightRange는 42, terrainScale은 0.25로 지정한 상태.

<br>

## **3D 펄린 노이즈**

이제 3D 펄린 노이즈를 구현하고, 이를 이용한다.

3D 노이즈를 이용하면 동굴 등 훨씬 다양한 지형들을 그려낼 수 있다.

```cs
// Noise class

// Return : isSolid
public static bool Get3DPerlin(in Vector3 position, float offset, float scale, float threshold)
{
    // https://www.youtube.com/watch?v=Aga0TBJkchM&ab_channel=Carlpilot

    float x = (position.x + offset + 0.1f) * scale;
    float y = (position.y + offset + 0.1f) * scale;
    float z = (position.z + offset + 0.1f) * scale;

    float AB = Mathf.PerlinNoise(x, y);
    float BC = Mathf.PerlinNoise(y, z);
    float CA = Mathf.PerlinNoise(z, x);

    float BA = Mathf.PerlinNoise(y, x);
    float CB = Mathf.PerlinNoise(z, y);
    float AC = Mathf.PerlinNoise(x, z);

    return (AB + BC + CA + BA + CB + AC) / 6f > threshold;
}
```

그리고 BiomeData에 Lode 배열을 추가한다.

이 배열의 데이터들은 광맥 또는 동굴을 의미하여,

TerrainPass에서 그린 지형을 2차적으로 3D 노이즈를 통해 얻은 값으로 수정하고

지형의 사이사이에 광맥 또는 동굴 지형을 추가해줄 수 있다.


```cs
// BiomeData class

public class BiomeData : ScriptableObject
{
    // ...

    public Lode[] lodes;
}

/// <summary> 광맥 </summary>
[System.Serializable]
public class Lode
{
    public string loadName;
    public byte blockID;
    public int minHeight;
    public int maxHeight;
    public float scale;
    public float threshold;
    public float noiseOffset;
}


// World class

public byte GetBlockType(in Vector3 worldPos)
{
    int yPos = (int)worldPos.y;
    byte blockType = Air;

    /* --------------------------------------------- *
     *                Immutable Pass                 *
     * --------------------------------------------- */
    // 월드 밖 : 공기
    if (!IsBlockInWorld(worldPos))
        return Air;
            
    // 높이 0은 기반암
    if(yPos == 0)
        return Bedrock;

    /* --------------------------------------------- *
     *              Basic Terrain Pass               *
     * --------------------------------------------- */
    // noise : 0.0 ~ 1.0
    float noise = Noise.Get2DPerlin(new Vector2(worldPos.x, worldPos.z), 0f, biome.terrainScale);

    // 지형 높이 : solidGroundHeight ~ (solidGroundHeight + terrainHeightRange)
    float terrainHeight = (int)(biome.terrainHeightRange * noise) + biome.solidGroundHeight;


    // 공기
    if (yPos > terrainHeight)
    {
        return Air;
    }

    // 지면
    if (yPos == terrainHeight)
    {
        blockType = Grass;
    }
    // 얕은 땅속
    else if (terrainHeight - 4 < yPos && yPos < terrainHeight)
    {
        blockType = Dirt;
    }
    // 깊은 땅속
    else
    {
        blockType = Stone;
    }

    /* --------------------------------------------- *
     *              Second Terrain Pass              *
     * --------------------------------------------- */

    if (blockType == Stone)
    {
        foreach (var lode in biome.lodes)
        {
            if (lode.minHeight < yPos && yPos < lode.maxHeight)
            {
                if (Noise.Get3DPerlin(worldPos, lode.noiseOffset, lode.scale, lode.threshold))
                {
                    blockType = lode.blockID;
                }
            }
        }
    }

    return blockType;
}
```

![image](https://user-images.githubusercontent.com/42164422/113143261-e61e5880-9266-11eb-88ec-cbe28377aae3.png)

![image](https://user-images.githubusercontent.com/42164422/113143213-dc94f080-9266-11eb-995d-741fde80bf9d.png)

<br>

# 6. 캐릭터 컨트롤러 만들기
---

만약 모든 청크에 Mesh Collider를 사용한다면, 메시가 수정될 때마다 다시 전체를 계산해서 그려져야 하므로 굉장히 비싼 연산이 될 것이다.

따라서 유니티의 물리 엔진을 사용하지 않고, 복셀 월드 내에서만 사용될 수 있는 물리 계산을 직접 하여 캐릭터 컨트롤러를 구현할 것이다.

<br>

## **초기 세팅**

(0, 0, 0)에 위치한 게임오브젝트를 만들고 이름을 [Player]로 변경한다.

그리고 카메라 게임오브젝트를 [Player]의 자식으로 넣고 위치를 (0, 1.8, 0)으로 변경한다.

[World] 게임오브젝트에 있는 `World` 컴포넌트의 `Player` 필드에 [Player]를 넣어준다.

새로운 스크립트를 생성하고 이름을 `Player`로 지정한다.

<br>

## **Player 클래스 작성**

간단히 키보드에 의한 이동, 마우스에 의한 회전을 할 수 있으며 중력이 적용되는 플레이어 클래스를 작성한다.

```cs
public class Player : MonoBehaviour
{
    /***********************************************************************
    *                               Inspector Fields
    ***********************************************************************/
    #region .
    [SerializeField] World world;

    [Range(1f, 10f)]
    [SerializeField] private float walkSpeed = 5f;

    [Range(-20, -9.8f)]
    [SerializeField] private float gravity = -9.8f;

    #endregion
    /***********************************************************************
    *                               Private Reference Fields
    ***********************************************************************/
    #region .
    private Transform camTr;

    #endregion
    /***********************************************************************
    *                               Private Fields
    ***********************************************************************/
    #region .
    private float h;
    private float v;
    private float mouseX;
    private float mouseY;
    private float deltaTime;

    private Vector3 velocity;

    #endregion
    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Awake()
    {
        Init();
    }

    private void Update()
    {
        deltaTime = Time.deltaTime;
        GetPlayerInputs();
        CalculateVelocity();
        MoveAndRotate();
    }

    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .
    private void Init()
    {
        var cam = GetComponentInChildren<Camera>();
        camTr = cam.transform;
    }

    private void GetPlayerInputs()
    {
        h = Input.GetAxisRaw("Horizontal");
        v = Input.GetAxisRaw("Vertical");
        mouseX = Input.GetAxis("Mouse X");
        mouseY = Input.GetAxis("Mouse Y");
    }

    private void CalculateVelocity()
    {
        velocity = ((transform.forward * v) + (transform.right * h)) * deltaTime * walkSpeed;
        velocity += Vector3.up * CalculateDownSpeedAndSetGroundState(gravity * deltaTime); // 중력 적용
    }

    private void MoveAndRotate()
    {
        // Rotate
        transform.Rotate(Vector3.up * mouseX);
        camTr.Rotate(Vector3.right * -mouseY);

        // Move
        transform.Translate(velocity, Space.World);
    }

    #endregion
}
```

이 상태에서는 이동 및 회전을 할 수 있지만 바닥을 인식할 수 없어 무한정 아래로 떨어지게 된다.

<br>

## **바닥 인식하기(-Y방향 충돌 구현)**

다음 필드들을 추가한다.

```cs
private float playerWidth = 0.3f;       // 플레이어의 XZ 반지름
private float boundsTolerance = 0.3f;
private float verticalMomentum = 0f;

private bool isGrounded = false;
private bool isJumping = false;
private bool isRunning = false;
private bool jumpRequested = false;
```

그리고 바닥을 인식하도록 메소드를 작성한다.

```cs
/// <summary> -Y 방향의 속력을 계산하고 isGrounded 초기화 </summary>
private float CalculateDownSpeedAndSetGroundState(float yVelocity)
{
    // playerWidth * 2를 변의 길이로 하는 XZ 평면 정사각형의 네 꼭짓점에서 하단으로 grounded 체크
    // gounded 체크가 플레이어 회전의 영향을 받지 않도록, transform 로컬벡터가 아니라 월드벡터 기준으로 검사
    // 즉, 플레이어가 회전해도 큐브 모양의 콜라이더가 회전하지 않는 효과

    Vector3 pos = transform.position;

    isGrounded = 
        world.IsBlockSolid(new Vector3(pos.x - playerWidth, pos.y + yVelocity, pos.z - playerWidth)) ||
        world.IsBlockSolid(new Vector3(pos.x + playerWidth, pos.y + yVelocity, pos.z - playerWidth)) ||
        world.IsBlockSolid(new Vector3(pos.x + playerWidth, pos.y + yVelocity, pos.z + playerWidth)) ||
        world.IsBlockSolid(new Vector3(pos.x - playerWidth, pos.y + yVelocity, pos.z + playerWidth));

    return isGrounded ? 0 : yVelocity;
}

private void CalculateVelocity()
{
    velocity = ((transform.forward * v) + (transform.right * h)) * deltaTime * walkSpeed;
    velocity += Vector3.up * CalculateDownSpeedAndSetGroundState(gravity * deltaTime); // 중력 적용, 바닥 인식
}
```

원리는 간단하다.

![image](https://user-images.githubusercontent.com/42164422/113419545-9f656580-9402-11eb-8be0-97b42b68dc87.png)

이렇게 캐릭터의 콜라이더 하단 사각형의 각 꼭짓점에서 이번 프레임에 이동할 Y축 거리를 각각 우선 이동하여, 해당 위치 중 하나라도 Solid이면 Y축 이동속도를 0으로 만드는 것이다.

<br>

## **XZ평면 충돌 구현**

콜라이더의 XZ 평면 사각형이 캐릭터를 따라 항상 회전하도록 구현하려면 선분 교차 알고리즘을 이용해야 하며,

벽에 닿은 상태에서 캐릭터가 회전하면 콜라이더가 지형과 겹쳐버리기 때문에 2차적인 처리가 필요해진다.

따라서 다른 대안으로는 콜라이더를 원형으로 구현하거나 회전하지 않는 사각형으로 구현하는 방법이 있다.

이미 -Y 충돌 구현에서 회전하지 않는 사각형으로 콜라이더의 바닥면을 구현했기 때문에, XZ평면 충돌 역시 회전하지 않는 사각형으로 구현한다.

그리고 충돌 검사 중 가장 단순하고 저렴하다는 장점이 있다.



TODO : 튜토리얼 06 - 44:36 ==> position + a 로 바로 더해서 검사하는 점, +y(0), +y(1) 밖에 검사 안한다는 점 수정해야 함 ..... 너무 단순하고 허점 많은 검사..



검사하려는 XZ 4방향으로 예를 들어 +X 방향이면 ZY 평면의 네 꼭지점에서 +X 방향으로 전진시켜, 교차할 수 있는 최대 4개(Z는 0.6 길이이므로 최대 2개 교차 * Y는 1.999 길이로  최대 2개 교차(하단 시작점 좌표가 .0이므로))의 큐브 Solid 상태 검사하여 4개 중 하나라도 Solid이면 X방향 속도 0으로 만들기



TODO : 콜라이더 육면체 기즈모로 표시



<br>



<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

<br>

# References
---
- <https://www.youtube.com/playlist?list=PLVsTSlfj0qsWEJ-5eMtXsYp03Y9yF1dEn>

