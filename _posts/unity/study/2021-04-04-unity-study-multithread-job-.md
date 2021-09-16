---
title: 유니티 - 멀티스레딩과 Job의 활용
author: Rito15
date: 2021-04-04 22:00:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, multithread, job]
math: true
mermaid: true
---

# 유니티에서의 멀티스레딩
---
유니티엔진에서는 기본적으로 모든 CPU 연산이 메인 스레드에서 이루어진다.

그렇다고 다중 스레드를 사용할 수 없다는 것은 아니지만

메인 스레드가 아닌 다른 스레드에서 유니티의 메인 로직에 접근할 수 없도록 막혀있다.

다시 말해, 다른 스레드에서는 게임오브젝트, 컴포넌트 등에 접근하면 에러가 발생한다.

예를 들어

```cs
private async void TaskTest()
{
    await Task.Run(() =>
    {
        transform.Translate(1f, 0f, 0f);
    });
}
```

이런 메소드를 실행하면 

![image](https://user-images.githubusercontent.com/42164422/113509789-6a881880-9592-11eb-8f70-c5571c408e43.png)

이런 에러를 만날 수 있다.

<br>

따라서 다른 스레드에서 유니티 메인 로직에 접근해야 한다면 [MainThreadDispatcher](https://github.com/PimDeWitte/UnityMainThreadDispatcher/blob/master/UnityMainThreadDispatcher.cs) 등을 사용하여

```cs
private async void TaskTest()
{
    await Task.Run(() =>
    {
        MainThreadDispatcher.Instance.Enqueue(() => transform.Translate(1f, 0f, 0f));
    });
}
```

이렇게 작성하면 된다.

<br>

# 멀티스레딩의 이유
---

다른 스레드에서 메인 로직에 접근하는 것이 기본적으로 제한되어 있고

저렇게 메인 스레드 디스패처를 사용해야 하는 등 번거로운데,

유니티에서 굳이 멀티스레딩을 해야 하는 이유가 있을까?

당연히 "성능을 위해서"이다.

유니티 메인 로직과 분리할 수 있는 무거운 연산들이 있다면 반드시 다른 스레드로 처리를 넘겨서 연산을 위임하고, 그 결과를 받아오도록 하는 것이 좋다.

기본적으로 100만큼의 모든 처리를 메인 스레드에서 담당하고 있다면,

10, 20 만큼이라도 다른 스레드에서 병렬처리를 해주는 것이 결국 성능에 도움이 된다.

<br>

# 멀티스레딩 구현 방식
---

유니티에서 멀티스레딩은 다음과 같은 방법들로 구현할 수 있다.

1. Thread

2. Task

3. Job System

이 중 Job System은 2018년에 정식으로 유니티 엔진에 도입되었으며,

프로그래머가 안전한 멀티스레딩을 작성하기에 비교적 편리한 형태로 제공한다.

<br>

이 포스팅에서는 Job의 기본적인 사용 방법에 대해 구체적으로 살펴보지는 않고

Job을 사용하기에 좋은 경우, 그리고 Job을 사용하지 않았을 때와 사용했을 때의 비교를 다룬다.

<br>

# 테스트 대상
---

펄린 노이즈를 이용하여 Chunk들로 이루어진 지형 메시를 생성하는 경우를 테스트한다.

메시의 정점과 폴리곤 계산을 다른 스레드로 위임하여 처리할 수 있으므로, 멀티스레딩에 적합하다고 할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/113510597-93121180-9596-11eb-9b0f-fad7d6efff37.png)

<br>

# 테스트 수행
---

## **1. 기본**

```cs
Vector3 curChunkPos = Vector3.zero;

for (int z = 0; z < _chunkCount; z++)
{
    curChunkPos.x = 0f;

    for (int x = 0; x < _chunkCount; x++)
    {
        MeshData meshData = new MeshData();
        CalculateMesh(meshData, curChunkPos);
        GenerateMesh(meshData);

        curChunkPos.x += _width;
    }

    curChunkPos.z += _width;
}
```

다른 스레드로 계산을 넘기지 않고, 메인 스레드에서 모두 계산한다.

![image](https://user-images.githubusercontent.com/42164422/113510958-44fe0d80-9598-11eb-8b95-cd558c6ee509.png)

그 결과, 수행에 총 `1,503.81ms`가 걸렸으며, 메인 스레드만 분주하게 일하고 워커 스레드는 모두 놀고 있었음을 확인하였다.

<br>

## **2. Job(동기)**

```cs
Vector3 curChunkPos = Vector3.zero;

for (int z = 0; z < _chunkCount; z++)
{
    curChunkPos.x = 0f;

    for (int x = 0; x < _chunkCount; x++)
    {
        TerrainJob job = new TerrainJob(
            _resolution, _width, _maxHeight, _noiseScale, curChunkPos
        );

        var handle = job.Schedule();
        handle.Complete(); // 메인 스레드에서 대기

        var result = job.GetResults();
        GenerateMesh(result.verts, result.tris);

        curChunkPos.x += _width;
    }

    curChunkPos.z += _width;
}
```

이번에는 Job을 통해 정점과 폴리곤 계산을 처리하며, Job을 수행하고 그 결과를 메인 스레드에서 대기하도록 한다.

![image](https://user-images.githubusercontent.com/42164422/113511008-8d1d3000-9598-11eb-8a7d-2725cff4770d.png)

총 `756.14ms`가 걸렸으며, 메인 스레드에서 모든 동작을 수행했을 때와 비교해 절반으로 줄어들었음을 알 수 있다.

또한 여러 개의 워커 스레드에서 Job을 나누어 처리했다는 것도 확인할 수 있었다.

<br>

## **3. Job(비동기)**

```cs
private IEnumerator TestJobAsyncRoutine()
{
    Vector3 curChunkPos = Vector3.zero;

    for (int z = 0; z < _chunkCount; z++)
    {
        curChunkPos.x = 0f;

        for (int x = 0; x < _chunkCount; x++)
        {
            TerrainJob job = new TerrainJob(
                _resolution, _width, _maxHeight, _noiseScale, curChunkPos
            );

            var handle = job.Schedule();

            // 잡이 완료되지 않았다면 프레임 넘기기
            while(!handle.IsCompleted)
                yield return null;

            handle.Complete();

            var result = job.GetResults();
            GenerateMesh(result.verts, result.tris);

            curChunkPos.x += _width;
        }

        curChunkPos.z += _width;
    }
}
```

역시 Job으로 연산을 처리하지만, 코루틴을 활용하여 Job의 연산이 이루어지는 동안에는 메인스레드가 이를 대기하지 않고 Job의 연산이 완료될 때마다 그 결과를 받아와 처리하는 방식으로 작성하였다.

![2021_0404_TerrainAsync2](https://user-images.githubusercontent.com/42164422/113509501-eaad7e80-9590-11eb-938d-fa9572b2b8da.gif)

![image](https://user-images.githubusercontent.com/42164422/113511071-f9982f00-9598-11eb-8e1e-db661eab62eb.png)

각 프레임의 수행 시간이 다른 경우에 비해 현저히 짧아졌음을 알 수 있다.

<br>

# 결론
---

Job으로 나누어 처리할 수만 있다면, Job으로 그 연산을 위임하여 수행하는 것이 대부분의 경우 성능상 이득을 얻을 수 있다.

그리고 Job을 이용한 멀티스레딩을 동기적으로 수행할지, 비동기적으로 수행할지 여부를 잘 생각하여 작성하면 된다.

렉을 감안하더라도 한 번에 처리해야만 하는 경우에는 동기적으로,

렉에 굉장히 민감한 경우에는 우선순위를 결정하여 비동기적으로 처리해주면 된다.

<br>

# Source Code
---

<details>
<summary markdown="span"> 
TerrainGenerator.cs
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Unity.Jobs;
using System.Threading.Tasks;
using System.Threading;

// 날짜 : 2021-04-04 PM 7:24:50
// 작성자 : Rito

namespace Rito.JobTest
{
    public class TerrainGenerator : MonoBehaviour
    {
        private enum TestCase
        {
            Basic, JobSync, JobAsync
        }
        [SerializeField] private TestCase _testCase;

        [Space(16)]
        [SerializeField] private int _resolution = 9; // XZ 각각 버텍스 개수
        [SerializeField] private float _width = 10;   // 한 청크의 XZ 크기 
        [SerializeField] private int _chunkCount = 4; // XZ 각각 청크 개수
        [SerializeField] private float _maxHeight = 4f; // 터레인의 최대 높이
        [SerializeField] private float _noiseScale = 10f; // 노이즈 스케일

        [SerializeField] private Material _material;

        private class MeshData
        {
            public List<Vector3> vertList;
            public List<int> trisList;

            public MeshData()
            {
                vertList = new List<Vector3>();
                trisList = new List<int>();
            }
        }

        private async void TaskTest()
        {
            await Task.Run(() =>
            {
                MainThreadDispatcher.Instance.Enqueue(() => transform.Translate(1f, 0f, 0f));

                //transform.Translate(1f, 0f, 0f);
                Debug.Log("Task");
                Debug.Log(Thread.CurrentThread.ManagedThreadId);
            });
        }

        private void Start()
        {
            //TaskTest();
            //return;

            switch (_testCase)
            {
                case TestCase.Basic: TestBasic();
                    break;
                case TestCase.JobSync: TestJobSync();
                    break;
                case TestCase.JobAsync: StartCoroutine(TestJobAsyncRoutine());
                    break;
            }
        }

        /***********************************************************************
        *                               Test Basic
        ***********************************************************************/
        #region .
        private void TestBasic()
        {
            Vector3 curChunkPos = Vector3.zero;

            for (int z = 0; z < _chunkCount; z++)
            {
                curChunkPos.x = 0f;

                for (int x = 0; x < _chunkCount; x++)
                {
                    MeshData meshData = new MeshData();
                    CalculateMesh(meshData, curChunkPos);
                    GenerateMesh(meshData);

                    curChunkPos.x += _width;
                }

                curChunkPos.z += _width;
            }
        }

        private void CalculateMesh(MeshData meshData, in Vector3 startPos)
        {
            float xzUnit = _width / _resolution;

            Vector3 curVertPos = startPos;

            // 1. 버텍스 생성
            for (int z = 0; z < _resolution; z++)
            {
                curVertPos.x = startPos.x;

                for (int x = 0; x < _resolution; x++)
                {
                    curVertPos.y = GetPerlinHeight(curVertPos.x, curVertPos.z, _noiseScale) * _maxHeight;
                    meshData.vertList.Add(curVertPos);

                    curVertPos.x += xzUnit;
                }

                curVertPos.z += xzUnit;
            }

            // 2. 폴리곤 조립
            for (int z = 0; z < _resolution - 1; z++)
            {
                for (int x = 0; x < _resolution - 1; x++)
                {
                    int LB = x + (z * _resolution); // LB Index

                    meshData.trisList.Add(LB);
                    meshData.trisList.Add(LB + _resolution);
                    meshData.trisList.Add(LB + 1);

                    meshData.trisList.Add(LB + 1);
                    meshData.trisList.Add(LB + _resolution);
                    meshData.trisList.Add(LB + _resolution + 1);
                }
            }
        }

        private float GetPerlinHeight(float x, float y, float scale)
        {
            return Mathf.PerlinNoise(x / scale + 0.1f, y / scale + 0.1f);
        }

        private void GenerateMesh(MeshData meshData)
        {
            GameObject go = new GameObject("Terrain");
            var mFilter = go.AddComponent<MeshFilter>();
            var mRender = go.AddComponent<MeshRenderer>();

            Mesh mesh = new Mesh();
            mesh.vertices = meshData.vertList.ToArray();
            mesh.triangles = meshData.trisList.ToArray();
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
            mesh.RecalculateBounds();

            mFilter.mesh = mesh;
            mRender.sharedMaterial = _material;
        }

        #endregion
        /***********************************************************************
        *                               Test Job Sync
        ***********************************************************************/
        #region .
        private void TestJobSync()
        {
            Vector3 curChunkPos = Vector3.zero;

            for (int z = 0; z < _chunkCount; z++)
            {
                curChunkPos.x = 0f;

                for (int x = 0; x < _chunkCount; x++)
                {
                    TerrainJob job = new TerrainJob(
                        _resolution, _width, _maxHeight, _noiseScale, curChunkPos
                    );

                    var handle = job.Schedule();
                    handle.Complete();

                    var result = job.GetResults();

                    GenerateMesh(result.verts, result.tris);

                    curChunkPos.x += _width;
                }

                curChunkPos.z += _width;
            }
        }

        private void GenerateMesh(Vector3[] verts, int[] tris)
        {
            GameObject go = new GameObject("Terrain");
            var mFilter = go.AddComponent<MeshFilter>();
            var mRender = go.AddComponent<MeshRenderer>();

            Mesh mesh = new Mesh();
            mesh.vertices = verts;
            mesh.triangles = tris;
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
            mesh.RecalculateBounds();

            mFilter.mesh = mesh;
            mRender.sharedMaterial = _material;
        }

        #endregion
        /***********************************************************************
        *                               Test Job Async
        ***********************************************************************/
        #region .
        private IEnumerator TestJobAsyncRoutine()
        {
            Vector3 curChunkPos = Vector3.zero;

            for (int z = 0; z < _chunkCount; z++)
            {
                curChunkPos.x = 0f;

                for (int x = 0; x < _chunkCount; x++)
                {
                    TerrainJob job = new TerrainJob(
                        _resolution, _width, _maxHeight, _noiseScale, curChunkPos
                    );

                    var handle = job.Schedule();

                    // 잡이 완료되지 않았다면 프레임 넘기기
                    while(!handle.IsCompleted)
                        yield return null;

                    handle.Complete();

                    var result = job.GetResults();

                    GenerateMesh(result.verts, result.tris);

                    curChunkPos.x += _width;
                }

                curChunkPos.z += _width;
            }
        }

        #endregion
    }
}
```

</details>

<details>
<summary markdown="span"> 
TerrainJob.cs
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Unity.Jobs;
using Unity.Burst;
using Unity.Collections;

// 날짜 : 2021-04-04 PM 8:52:03
// 작성자 : Rito

namespace Rito.JobTest
{
    [BurstCompile]
    public struct TerrainJob : IJob
    {
        public NativeArray<Vector3> verts;
        public NativeArray<int> tris;
        public int resolution;
        public float width, maxHeight, noiseScale;
        public Vector3 startPos;

        public TerrainJob(int resolution, float width, float maxHeight, float noiseScale, Vector3 startPos)
        {
            verts = new NativeArray<Vector3>(resolution * resolution, Allocator.TempJob);
            tris = new NativeArray<int>((resolution - 1) * (resolution - 1) * 6, Allocator.TempJob);
            this.width = width;
            this.resolution = resolution;
            this.maxHeight = maxHeight;
            this.noiseScale = noiseScale;
            this.startPos = startPos;
        }

        public void Execute()
        {
            float xzUnit = width / resolution;

            Vector3 curVertPos = startPos;

            // 1. 버텍스 생성
            int vertIndex = 0;
            for (int z = 0; z < resolution; z++)
            {
                curVertPos.x = startPos.x;

                for (int x = 0; x < resolution; x++)
                {
                    curVertPos.y = GetPerlinHeight(curVertPos.x, curVertPos.z, noiseScale) * maxHeight;
                    verts[vertIndex++] = curVertPos;

                    curVertPos.x += xzUnit;
                }

                curVertPos.z += xzUnit;
            }

            // 2. 폴리곤 조립
            int triIndex = 0;
            for (int z = 0; z < resolution - 1; z++)
            {
                for (int x = 0; x < resolution - 1; x++)
                {
                    int LB = x + (z * resolution); // LB Index

                    tris[triIndex    ] = LB;
                    tris[triIndex + 1] = LB + resolution;
                    tris[triIndex + 2] = LB + 1;

                    tris[triIndex + 3] = LB + 1;
                    tris[triIndex + 4] = LB + resolution;
                    tris[triIndex + 5] = LB + resolution + 1;

                    triIndex += 6;
                }
            }
        }

        public (Vector3[] verts, int[] tris) GetResults()
        {
            var result = (verts.ToArray(), tris.ToArray());
            verts.Dispose();
            tris.Dispose();

            return result;
        }

        private float GetPerlinHeight(float x, float y, float scale)
        {
            return Mathf.PerlinNoise(x / scale + 0.1f, y / scale + 0.1f);
        }
    }
}
```

</details>