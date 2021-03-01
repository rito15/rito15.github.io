---
title: Projectile Shooter
author: Rito15
date: 2021-03-02 03:28:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 마우스 클릭 시 등록된 게임오브젝트를 생성하여, 지정된 방향으로 발사하는 스크립트

- 생성된 게임오브젝트는 카메라의 시선에 수직인 평면 방향으로 이동하며, 수명이 다하면 제거된다.

- 오브젝트 풀링이 적용된다.

<br>

# How To Use
---
- 빈 게임오브젝트를 생성하고, ParticleShooter를 컴포넌트로 넣는다.

- 발사할 대상 게임오브젝트를 `Particle Prefab` 필드에 넣는다.

- `Direction`으로 발사할 방향을 지정할 수 있다.

- `Life Time`으로 대상 게임오브젝트의 수명을 지정할 수 있다.

- `Speed`로 대상 게임오브젝트의 이동속도를 지정할 수 있다.

- `Distance From Camera`로 카메라로부터의 거리를 지정할 수 있다.

- `Min Click Interval`로 클릭 허용 최소 간격을 지정할 수 있다.

<br>

# Preview
---

![image](https://user-images.githubusercontent.com/42164422/109544716-3ccf3000-7b0b-11eb-84c1-9a064cc37f67.png)

![2021_0302_Fireball_Preview01](https://user-images.githubusercontent.com/42164422/109539634-e4952f80-7b04-11eb-88f4-760a6b5af2d7.gif)

![2021_0302_Fireball_Preview02](https://user-images.githubusercontent.com/42164422/109539647-e6f78980-7b04-11eb-8100-a2e508a9f398.gif)

<br>

# Download
---

- [ProjectileShooter.zip](https://github.com/rito15/Images/files/6063833/ProjectileShooter.zip)

<br>

# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<details>
<summary markdown="span"> 
.
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Random = UnityEngine.Random;

// 2021. 03. 02. 03:02
// 작성자 : Rito

namespace Rito
{
    public class ProjectileShooter : MonoBehaviour
    {
        public enum Direction
        {
            Left, Right, Up, Down, Random
        }

        /***********************************************************************
        *                               Public Fields
        ***********************************************************************/
        #region .
        public Direction _direction = Direction.Random;

        public GameObject _projectilePrefab;
        [Range(1f, 10f)] public float _lifeTime = 5f;
        [Range(1f, 20f)] public float _speed = 10f;
        [Range(1f, 20f)] public float _distanceFromCamera = 10f;

        [Range(0.01f, 1f)]
        public float _minClickInterval = 0.1f; // 클릭 허용 최소 간격

        #endregion
        /***********************************************************************
        *                               Private Fields
        ***********************************************************************/
        #region .
        private float _currentClickInterval = 0f;

        #endregion
        /***********************************************************************
        *                               Unity Events
        ***********************************************************************/
        #region .
        private void Start()
        {
            _poolGo = new GameObject("Projectile Pool");
        }
        private void OnEnable()
        {
            if (_projectilePrefab == null)
            {
                Debug.LogError("ProjectileShooter : 투사체 오브젝트를 등록해주세요");
                return;
            }

            _projectilePrefab.SetActive(false);
        }

        private void Update()
        {
            if (_projectilePrefab == null) return;
            if (_currentClickInterval > 0f)
            {
                _currentClickInterval -= Time.deltaTime;
                return;
            }

            if (Input.GetMouseButton(0) || Input.GetMouseButton(1))
            {
                StartCoroutine(ShootRoutine());
                _currentClickInterval = _minClickInterval;
            }
        }

        #endregion
        /***********************************************************************
        *                               Coroutine
        ***********************************************************************/
        #region .
        private IEnumerator ShootRoutine()
        {
            Vector3 moveDir;
            Vector3 worldMove;
            float lifeTime = _lifeTime;

            // 이동 방향 결정
            switch (_direction)
            {
                case Direction.Left: moveDir = Vector3.left; break;
                case Direction.Right: moveDir = Vector3.right; break;
                case Direction.Up: moveDir = Vector3.up; break;
                case Direction.Down: moveDir = Vector3.down; break;
                case Direction.Random:
                default:
                    moveDir = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0f).normalized;
                    break;
            }

            worldMove = Camera.main.transform.TransformDirection(moveDir) * _speed;

            // 투사체 스폰
            GameObject psInstance = Spawn();
            Transform psTransform = psInstance.transform;

            // 투사체 위치 지정
            Vector3 mousePos = Input.mousePosition;
            mousePos.z = _distanceFromCamera;
            psTransform.position = Camera.main.ScreenToWorldPoint(mousePos);

            float t = 0f;
            while (t < lifeTime)
            {
                psTransform.Translate(worldMove * Time.deltaTime, Space.World);

                t += Time.deltaTime;
                yield return null;
            }

            Despawn(psInstance);
        }

        #endregion
        /***********************************************************************
        *                               Pooling
        ***********************************************************************/
        #region .
        private Queue<GameObject> _poolQueue = new Queue<GameObject>();
        private GameObject _poolGo;
        private int _maxCount = 0;

        private GameObject Spawn()
        {
            GameObject next;

            if (_poolQueue.Count == 0)
            {
                next = Instantiate(_projectilePrefab);
                _maxCount++;
            }
            else
            {
                next = _poolQueue.Dequeue();
            }

            UpdatePoolGoName();

            next.SetActive(true);
            next.transform.SetParent(_poolGo.transform);
            return next;
        }

        private void Despawn(GameObject go)
        {
            go.SetActive(false);
            //go.transform.SetParent(_poolGo.transform);
            _poolQueue.Enqueue(go);
            UpdatePoolGoName();
        }

        private void UpdatePoolGoName()
        {
            _poolGo.name = $"Projectile Pool [{_poolQueue.Count} / {_maxCount}]";
        }

        #endregion
    }
}
```

</details>

