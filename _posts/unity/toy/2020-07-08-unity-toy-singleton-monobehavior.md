---
title: Singleton MonoBehavior (상속용, 복붙용 싱글톤)
author: Rito15
date: 2020-07-08 15:30:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 단순한 상속만으로 모노비헤이비어 클래스를 싱글톤으로 만들어주는 클래스

# How To Use
---
- 클래스명이 Apple일 때 예시로, 다음과 같이 상속받아 사용한다.

```cs
public class Apple : Rito.SingletonMonoBehavior<Apple>
{
    // Awake 메소드는 반드시 이렇게 작성해야 한다.
    protected override void Awake()
    {
        base.Awake();

        // .. 기타 코드
    }
}
```

# Preview
---
- 게임 시작 시 싱글톤 오브젝트의 존재와 게임오브젝트명을 콘솔 로그를 통해 알려준다.
- 싱글톤 컴포넌트가 두 개 이상 존재할 경우 자동으로 파괴하며, 콘솔 로그를 통해 알려준다.

![image](https://user-images.githubusercontent.com/42164422/105669964-9b5d2900-5f23-11eb-89c1-346ff0863840.png)


# Download
---
- [SingletonMonoBehavior.zip](https://github.com/rito15/Images/files/6874412/SingletonMonoBehavior.zip)


# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<details>
<summary markdown="span"> 
.
</summary>

```cs
#if UNITY_EDITOR
#define DEBUG_ON
#define GATHER_INTO_SAME_PARENT // 하나의 공통 부모 게임오브젝트에 모아놓기
#endif

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 작성자 : Rito

// 최초 작성 : 2021-01-25 PM 2:36:18

// 수정 : 2021-07-26 AM 02:35
/* 
 * - 싱글톤 프로퍼티 Getter -> 더블 체크 로킹 제거
 *   - 근거 : 멀티스레딩 환경이면 애초에 Unity API 접근이 예외를 발생시킴
 *   
 * - Scene Breathing 제거
 *   - 근거 : Getter는 최대한 가벼운게 좋음
 */
namespace Rito
{
    [DisallowMultipleComponent]
    public abstract class SingletonMonoBehavior<T> : MonoBehaviour where T : MonoBehaviour
    {
        /***********************************************************************
        *                       Public Static Properties
        ***********************************************************************/
        #region .
        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static T I
        {
            get
            {
                // 객체 참조 확인
                if (_instance == null)
                {
                    _instance = FindObjectOfType<T>();

                    // 인스턴스 가진 오브젝트가 존재하지 않을 경우, 빈 오브젝트를 임의로 생성하여 인스턴스 할당
                    if (_instance == null)
                    {
                        // 게임 오브젝트에 클래스 컴포넌트 추가 후 인스턴스 할당
                        _instance = ContainerObject.GetComponent<T>();
                    }
                }
                return _instance;
            }
        }

        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static T Instance => I;

        /// <summary> 싱글톤 게임오브젝트의 참조 </summary>
        public static GameObject ContainerObject
        {
            get
            {
                if (_containerObject == null)
                    CreateContainerObject();

                return _containerObject;
            }
        }

        #endregion
        /***********************************************************************
        *                       Private Static Variables
        ***********************************************************************/
        #region .

        /// <summary> 싱글톤 인스턴스 </summary>
        private static T _instance;
        private static GameObject _containerObject;

        #endregion
        /***********************************************************************
        *                       Private Static Methods
        ***********************************************************************/
        #region .
        [System.Diagnostics.Conditional("DEBUG_ON")]
        protected static void DebugOnlyLog(string msg)
        {
            Debug.Log(msg);
        }

        /// <summary> 공통 부모 게임오브젝트에 모아주기 </summary>
        [System.Diagnostics.Conditional("GATHER_INTO_SAME_PARENT")]
        protected static void GatherGameObjectIntoSameParent()
        {
            string parentName = "Singleton Objects";

            // 게임오브젝트 "Singleton Objects" 찾기 or 생성
            GameObject parentContainer = GameObject.Find(parentName);
            if (parentContainer == null)
                parentContainer = new GameObject(parentName);

            // 부모 오브젝트에 넣어주기
            _containerObject.transform.SetParent(parentContainer.transform);
        }

        // (정적) 싱글톤 컴포넌트를 담을 게임 오브젝트 생성
        private static void CreateContainerObject()
        {
            // null이 아니면 Do Nothing
            if (_containerObject != null) return;

            // 빈 게임 오브젝트 생성
            _containerObject = new GameObject($"[Singleton] {typeof(T)}");

            // 인스턴스가 없던 경우, 새로 생성
            if (_instance == null)
                _instance = ContainerObject.AddComponent<T>();

            GatherGameObjectIntoSameParent();
        }

        #endregion

        protected virtual void Awake()
        {
            // 싱글톤 인스턴스가 미리 존재하지 않았을 경우, 본인으로 초기화
            if (_instance == null)
            {
                DebugOnlyLog($"싱글톤 생성 : {typeof(T)}, 게임 오브젝트 : {name}");

                // 싱글톤 컴포넌트 초기화
                _instance = this as T;

                // 싱글톤 컴포넌트를 담고 있는 게임오브젝트로 초기화
                _containerObject = gameObject;

                GatherGameObjectIntoSameParent();
            }

            // 싱글톤 인스턴스가 존재하는데, 본인이 아닐 경우, 스스로(컴포넌트)를 파괴
            if (_instance != null && _instance != this)
            {
                DebugOnlyLog($"이미 {typeof(T)} 싱글톤이 존재하므로 오브젝트를 파괴합니다.");

                var components = gameObject.GetComponents<Component>();

                // 만약 게임 오브젝트에 컴포넌트가 자신만 있었다면, 게임 오브젝트도 파괴
                if (components.Length <= 2)
                    Destroy(gameObject);

                // 다른 컴포넌트도 존재하면 자신만 파괴
                else
                    Destroy(this);
            }
        }
    }
}
```

</details>


<br>

# 추가 : 복붙용 코드
---
- `SINGLETON_EXAMPLE`에 `Ctrl + R R`을 통해 이름 변경하여 사용

<details>
<summary markdown="span"> 
[1] 완성형
</summary>

```cs
/***********************************************************************
*                           Singleton Options
***********************************************************************/
#region .
#if UNITY_EDITOR

// 1. DebugLog() 출력 여부
#define DEBUG_ON

// 2. 하나의 공통 부모 게임오브젝트에 모아놓기
#define GATHER_INTO_SAME_PARENT
#endif

// 3. DontDestroyOnLoad 설정
#define DONT_DESTROY_ON_LOAD

#endregion//***********************************************************

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Rito
{
    [DisallowMultipleComponent]
    public class SINGLETON_EXAMPLE : MonoBehaviour
    {
        /***********************************************************************
        *                               Singleton
        ***********************************************************************/
        #region .
        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static SINGLETON_EXAMPLE I
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<SINGLETON_EXAMPLE>();
                    if (_instance == null) _instance = ContainerObject.GetComponent<SINGLETON_EXAMPLE>();
                }
                return _instance;
            }
        }

        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static SINGLETON_EXAMPLE Instance => I;
        private static SINGLETON_EXAMPLE _instance;

        /// <summary> 싱글톤 게임오브젝트의 참조 </summary>
        private static GameObject ContainerObject
        {
            get
            {
                if (_containerObject == null)
                {
                    _containerObject = new GameObject($"[Singleton] {nameof(SINGLETON_EXAMPLE)}");
                    if (_instance == null) _instance = ContainerObject.AddComponent<SINGLETON_EXAMPLE>();
                    GatherGameObjectIntoSameParent();
                }

                return _containerObject;
            }
        }
        private static GameObject _containerObject;

        /***********************************************************************
        *                               Debug
        ***********************************************************************/
        [System.Diagnostics.Conditional("DEBUG_ON")]
        private static void DebugLog(string msg)
        {
            Debug.Log(msg);
        }

        /// <summary> 공통 부모 게임오브젝트에 모아주기 </summary>
        [System.Diagnostics.Conditional("GATHER_INTO_SAME_PARENT")]
        private static void GatherGameObjectIntoSameParent()
        {
#if !DONT_DESTROY_ON_LOAD
            string parentName = "Singleton Objects";

            GameObject parentContainer = GameObject.Find(parentName);
            if (parentContainer == null)
                parentContainer = new GameObject(parentName);

            _containerObject.transform.SetParent(parentContainer.transform);
#endif
        }

        /***********************************************************************
        *                               Private
        ***********************************************************************/
        private void CheckSingleton()
        {
            // 싱글톤 인스턴스가 미리 존재하지 않았을 경우, 본인으로 초기화
            if (_instance == null)
            {
                DebugLog($"싱글톤 생성 : {nameof(SINGLETON_EXAMPLE)}, 게임 오브젝트 : {name}");

                _instance = this;
                _containerObject = gameObject;
                GatherGameObjectIntoSameParent();
            }

            // 싱글톤 인스턴스가 존재하는데, 본인이 아닐 경우, 스스로(컴포넌트)를 파괴
            if (_instance != null && _instance != this)
            {
                DebugLog($"이미 {nameof(SINGLETON_EXAMPLE)} 싱글톤이 존재하므로 오브젝트를 파괴합니다.");

                var components = gameObject.GetComponents<Component>();
                if (components.Length <= 2) Destroy(gameObject);
                else Destroy(this);
            }
#if DONT_DESTROY_ON_LOAD
            if (_instance == this)
            {
                transform.SetParent(null);
                DontDestroyOnLoad(this);
                DebugLog($"Don't Destroy on Load : {nameof(SINGLETON_EXAMPLE)}");
            }
#endif
        }
        #endregion // Singleton

        private void Awake()
        {
            CheckSingleton();
        }
    }
}
```

</details>

<br>

<details>
<summary markdown="span"> 
[2] 조각
</summary>

```cs
/***********************************************************************
*                               Singleton
***********************************************************************/
#region .
/// <summary> 싱글톤 인스턴스 Getter </summary>
public static SINGLETON_EXAMPLE I
{
    get
    {
        if (_instance == null)
        {
            _instance = FindObjectOfType<SINGLETON_EXAMPLE>();
            if (_instance == null) _instance = ContainerObject.GetComponent<SINGLETON_EXAMPLE>();
        }
        return _instance;
    }
}

/// <summary> 싱글톤 인스턴스 Getter </summary>
public static SINGLETON_EXAMPLE Instance => I;
private static SINGLETON_EXAMPLE _instance;

/// <summary> 싱글톤 게임오브젝트의 참조 </summary>
private static GameObject ContainerObject
{
    get
    {
        if (_containerObject == null)
        {
            _containerObject = new GameObject($"[Singleton] {nameof(SINGLETON_EXAMPLE)}");
            if (_instance == null) _instance = ContainerObject.AddComponent<SINGLETON_EXAMPLE>();
        }

        return _containerObject;
    }
}
private static GameObject _containerObject;

// Awake()에서 호출
private void CheckSingleton()
{
    // 싱글톤 인스턴스가 미리 존재하지 않았을 경우, 본인으로 초기화
    if (_instance == null)
    {
#if DEBUG_ON
        Debug.Log($"싱글톤 생성 : {nameof(SINGLETON_EXAMPLE)}, 게임 오브젝트 : {name}");
#endif

        _instance = this;
        _containerObject = gameObject;
    }

    // 싱글톤 인스턴스가 존재하는데, 본인이 아닐 경우, 스스로(컴포넌트)를 파괴
    if (_instance != null && _instance != this)
    {
#if DEBUG_ON
        Debug.Log($"이미 {nameof(SINGLETON_EXAMPLE)} 싱글톤이 존재하므로 오브젝트를 파괴합니다.");
#endif

        var components = gameObject.GetComponents<Component>();
        if (components.Length <= 2) Destroy(gameObject);
        else Destroy(this);
    }
#if DONT_DESTROY_ON_LOAD
    if (_instance == this)
    {
        transform.SetParent(null);
        DontDestroyOnLoad(this);
#if DEBUG_ON
        Debug.Log($"Don't Destroy on Load : {nameof(SINGLETON_EXAMPLE)}");
#endif
    }
#endif
}
#endregion

private void Awake()
{
    CheckSingleton();
}
```

</details>
