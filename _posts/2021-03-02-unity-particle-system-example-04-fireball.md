---
title: 파티클 시스템 예제 - 04 - Fire Ball
author: Rito15
date: 2021-03-02 03:03:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 목차
---

- [목표](#목표)
- [준비물](#준비물)
- [1. 파티클 시스템 제작](#1-파티클-시스템-제작)
- [2. 서브 이미터 설정](#2-서브-이미터-설정)
- [3. Projectile Shooter 적용](#3-projectile-shooter-적용)
- [4. 결과](#4-결과)

<br>

# Preview
---

![2021_0302_Fireball_Preview01](https://user-images.githubusercontent.com/42164422/109539634-e4952f80-7b04-11eb-88f4-760a6b5af2d7.gif)

![2021_0302_Fireball_Preview02](https://user-images.githubusercontent.com/42164422/109539647-e6f78980-7b04-11eb-8100-a2e508a9f398.gif)

<br>

# 목표
---

- Sub Emitters(서브 이미터) 모듈 이해하기

- 파이어볼 이펙트 만들기

<br>

# 준비물
---

- 글로우 모양의 동그란 텍스쳐와 Additive 마테리얼

![image](https://user-images.githubusercontent.com/42164422/109539093-3be6d000-7b04-11eb-900c-4e20447602cc.png)

<br>

- 파이어볼을 발사할 수 있게 해줄 스크립트

- 아래 소스코드를 다운로드하여 프로젝트 내에 넣어둔다.

- [ProjectileShooter.zip](https://github.com/rito15/Images/files/6063758/ProjectileShooter.zip)

<details>
<summary markdown="span"> 
Source Code
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
        private float _clickInterval = 0.1f; // 클릭 허용 간격

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
                _currentClickInterval = _clickInterval;
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

        private GameObject Spawn()
        {
            GameObject next;

            if (_poolQueue.Count == 0)
                next = Instantiate(_projectilePrefab);
            else
                next = _poolQueue.Dequeue();

            next.SetActive(true);
            next.transform.SetParent(_poolGo.transform);
            return next;
        }

        private void Despawn(GameObject go)
        {
            go.SetActive(false);
            //go.transform.SetParent(_poolGo.transform);
            _poolQueue.Enqueue(go);
        }

        #endregion
    }
}
```

</details>

<br>

# 1. 파티클 시스템 제작
---

## 기본 준비

- 파티클 시스템 게임오브젝트 생성

- 트랜스폼을 Reset하여 Position(0, 0, 0), Rotation(0, 0, 0) 설정

- 마테리얼 적용

<br>

## 메인 모듈

- `Start Lifetime` : 1

- `Start Speed` : 0

- `Start Size` : 10

<br>

## Shape 모듈

- 파티클이 같은 위치에서만 생성되도록, Shape 모듈을 체크 해제한다.

<br>

## Emission 모듈

- `Rate over Time` : 5

<br>

## Color over Lifetime 모듈

- 색상은 주황색으로 시작하여 노란색으로 끝나도록 한다.

- 투명도는 255로 시작하여 0으로 끝나도록 한다.

![image](https://user-images.githubusercontent.com/42164422/109613038-f5c95500-7b73-11eb-9365-7bb026d01f47.png)

<br>

## Size over Lifetime 모듈

- Curve로 설정하고, 크기가 0% ~ 100% ~ 0%로 변화하도록 다음처럼 그래프를 지정한다.

![](https://user-images.githubusercontent.com/42164422/109509302-177afb80-7ae4-11eb-8f6e-37ee31ff545b.gif)

<br>

## 현재 상태

![2021_0302_Fireball_Mid](https://user-images.githubusercontent.com/42164422/109614365-e0edc100-7b75-11eb-89bf-790656599580.gif)

<br>

## Sub Emitter 모듈

- Sub Emitter 모듈이란?
> 파티클에 생성, 파괴, 충돌 등의 이벤트가 발생할 때 생성되는, 본 파티클 시스템에 종속적인 또다른 파티클 시스템을 등록하는 것

- Sub Emitter 모듈에 체크하고, 우측 상단의 [+] 버튼을 눌러 서브 이미터 하나를 추가한다.

- `Inherit` 속성은 Color를 지정한다.

![2021_0302_Fireball_SubEmitter](https://user-images.githubusercontent.com/42164422/109614772-67a29e00-7b76-11eb-8db0-dba61ed194e5.gif)

- 기본적으로 `Birth` 속성이 지정되어 있으므로, 파티클이 생성될 때 서브 이미터 파티클 시스템이 함께 생성된다.

- `Inherit`를 Color로 지정하였으므로, 본 파티클 시스템의 파티클 색상을 서브 이미터가 상속하게 된다.

<br>

# 2. 서브 이미터 설정
---

- Sub Emitter 모듈에서 [+] 버튼을 눌렀을 때 파티클 시스템 게임오브젝트의 자식으로 서브 이미터 파티클 시스템이 생성된다.

![image](https://user-images.githubusercontent.com/42164422/109614804-71c49c80-7b76-11eb-899b-2f3ee83ab64d.png)

- 하이라키에서 파티클 시스템 게임오브젝트의 좌측 화살표를 눌러 확인할 수 있다.

- 서브 이미터 역시 파티클 시스템이기 때문에, 똑같이 모듈을 통해 다양한 속성을 설정할 수 있다.

<br>

## 마테리얼 설정

- 파이어볼 파티클 시스템에 사용한 마테리얼을 서브 이미터에도 드래그하여 똑같이 적용한다.

<br>

## 메인 모듈

- `Start Lifetime` - [Random Between Two Constants] : (0.5, 1)

- `Start Size` - [Random Between Two Constants] : (1, 6)

- `Simulation Space` : World

<br>

## Emission 모듈

- `Rate over Time` : 24

<br>

## Shape 모듈

- `Shape` : Sphere

- `Radius` : 0.3

<br>

## Color over Lifetime 모듈

- 알파 값만 255 ~ 0으로 변화하도록 설정

![image](https://user-images.githubusercontent.com/42164422/109616186-3925c280-7b78-11eb-950e-9ac8c7c84cac.png)

<br>

## Size over Lifetime 모듈

- 100% ~ 0%로 감소하는 그래프 설정 (하단 프리셋 중 3번째 클릭)

![image](https://user-images.githubusercontent.com/42164422/109616470-830ea880-7b78-11eb-9149-2ba1ffba6521.png)

<br>

## 테스트

![2021_0302_Fireball_Move](https://user-images.githubusercontent.com/42164422/109616990-2e1f6200-7b79-11eb-9059-9b982b15f841.gif)

- 씬 뷰에서 기즈모 핸들을 잡고 이동시켜보면 위처럼 서브 이미터가 잔상처럼 남는 효과를 확인할 수 있다.

<br>

# 3. Projectile Shooter 적용
---

- 위의 '준비물' 부분에 있는 `ProjectileShooter.cs` 스크립트가 프로젝트 내에 존재해야 한다.

- 하이라키의 빈 공간을 우클릭하여 `Create Empty`를 눌러 빈 게임오브젝트를 생성한다.

- 빈 게임오브젝트를 F2로 수정하여 이름을 `Projectile Shooter`로 지정한다.

- 생성한 게임오브젝트를 선택하고, 인스펙터에서 `Add Component`를 눌러 `Projectile Shooter`를 추가하거나, 프로젝트 윈도우에서 스크립트를 드래그하여 컴포넌트로 추가한다.

![image](https://user-images.githubusercontent.com/42164422/109617499-cf0e1d00-7b79-11eb-8d82-d916930341f2.png)

<br>

- 하이라키에서 파이어볼 게임오브젝트를 드래그하여 인스펙터의 `Projectile Prefab` 부분에 가져와 등록한다.

![image](https://user-images.githubusercontent.com/42164422/109617699-0f6d9b00-7b7a-11eb-83d3-8b1b2ac8fb1a.png)

- 게임을 시작하여, 게임 씬의 공간을 클릭할 경우 파이어볼이 생성되는 모습을 확인할 수 있다.

- Projectile Shooter의 `Direction` 옵션을 수정하여 발사 방향을 바꿀 수 있다.

<br>

# 4. 결과
---

![2021_0302_Fireball_Preview01](https://user-images.githubusercontent.com/42164422/109539634-e4952f80-7b04-11eb-88f4-760a6b5af2d7.gif)

![2021_0302_Fireball_Preview02](https://user-images.githubusercontent.com/42164422/109539647-e6f78980-7b04-11eb-8100-a2e508a9f398.gif)