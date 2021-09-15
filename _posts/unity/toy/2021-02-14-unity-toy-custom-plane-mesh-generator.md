---
title: Custom Plane Mesh Generator
author: Rito15
date: 2021-02-14 03:06:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, mesh, plane]
math: true
mermaid: true
---

# Note
---
- Plane을 원하는 너비, 해상도로 만들 수 있게 해주는 컴포넌트


# Preview
---

![image](https://user-images.githubusercontent.com/42164422/107857676-2f5f4800-6e73-11eb-8854-472405b55477.png){:.normal}

![image](https://user-images.githubusercontent.com/42164422/107857680-35552900-6e73-11eb-90de-da7e9f408840.png){:.normal}


# How to Use
---
1. 빈 게임오브젝트를 생성한다.
2. PlaneMeshGenerator 컴포넌트를 추가한다.
3. 옵션을 설정하고 마테리얼을 인스펙터의 Material에 넣는다.
4. Generate 버튼을 누른다.


# Download
---
- [PlaneMeshGenerator.zip](https://github.com/rito15/Images/files/5983471/PlaneMeshGenerator.zip)


# Source Code
---

<details>
<summary markdown="span"> 
PlaneMeshGenerator.cs
</summary>

```cs
using UnityEngine;

namespace Rito
{
    public class PlaneMeshGenerator : MonoBehaviour
    {
        [Range(2, 256)] public int _resolution = 24;
        [Range(1, 100)] public float _widthX = 10f;
        [Range(1, 100)] public float _widthZ = 10f;
        public Material _material;
        public bool _generateOnPlay = false;

        private Mesh _mesh;
        private MeshFilter _mFilter;
        private MeshRenderer _mRenderer;

        private Vector3[] verts;
        private int[] tris;
        private Vector2[] uvs;

        private void Start()
        {
            if (!_generateOnPlay) return;
            Generate();
        }

        public void Generate()
        {
            Init();
            CreateMeshInfo();
            ApplyMesh();
        }

        private void Init()
        {
            TryGetComponent(out _mFilter);
            TryGetComponent(out _mRenderer);

            if (!_mFilter) _mFilter = gameObject.AddComponent<MeshFilter>();
            if (!_mRenderer) _mRenderer = gameObject.AddComponent<MeshRenderer>();

            _mesh = new Mesh();
            _mFilter.mesh = _mesh;
            if (_material) _mRenderer.material = _material;
        }

        private void CreateMeshInfo()
        {
            int resolutionZ = (int)(_resolution * _widthZ / _widthX);

            Vector3 widthV3 = new Vector3(_widthX, 0f, _widthZ); // width를 3D로 변환
            Vector3 startPoint = -widthV3 * 0.5f;                // 첫 버텍스의 위치
            Vector2 gridUnit = new Vector2(_widthX / _resolution, _widthZ / resolutionZ); // 그리드 하나의 너비

            Vector2Int vCount = new Vector2Int(_resolution + 1, resolutionZ + 1); // 각각 가로, 세로 버텍스 개수
            int vertsCount = vCount.x * vCount.y;
            int trisCount = _resolution * resolutionZ * 6;

            verts = new Vector3[vertsCount];
            tris = new int[trisCount];
            uvs = new Vector2[vertsCount];

            // 1. 버텍스, UV 초기화
            for (int j = 0; j < vCount.y; j++)
            {
                for (int i = 0; i < vCount.x; i++)
                {
                    int index = i + j * vCount.x;
                    verts[index] =
                        startPoint + new Vector3(gridUnit.x * i, 0f, gridUnit.y * j);

                    uvs[index] = new Vector2((float)i / (vCount.x - 1), (float)j / (vCount.y - 1));
                }
            }

            // 2. 폴리곤 초기화
            int tIndex = 0;
            for (int j = 0; j < vCount.y - 1; j++)
            {
                for (int i = 0; i < vCount.x - 1; i++)
                {
                    int vIndex = i + j * vCount.x;

                    tris[tIndex + 0] = vIndex;
                    tris[tIndex + 1] = vIndex + vCount.x;
                    tris[tIndex + 2] = vIndex + 1;

                    tris[tIndex + 3] = vIndex + vCount.x;
                    tris[tIndex + 4] = vIndex + vCount.x + 1;
                    tris[tIndex + 5] = vIndex + 1;

                    tIndex += 6;
                }
            }
        }

        private void ApplyMesh()
        {
            _mesh.vertices = verts;
            _mesh.triangles = tris;
            _mesh.uv = uvs;
            _mesh.RecalculateNormals();
        }
    }
}
```

</details>

<br>

