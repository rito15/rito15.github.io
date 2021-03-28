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
- [1. 복셀 기본](#1-복셀-기본)
- [2. 청크와 맵 데이터](#2-청크와-맵-데이터)
- [3. 텍스쳐 입히기](#3-텍스쳐-입히기)
- [](#)

<br>

# 개요
---

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

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

<br>

# References
---
- <https://www.youtube.com/playlist?list=PLVsTSlfj0qsWEJ-5eMtXsYp03Y9yF1dEn>

