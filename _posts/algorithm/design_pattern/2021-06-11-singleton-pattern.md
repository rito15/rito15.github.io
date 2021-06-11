---
title: Singleton Pattern(싱글톤 패턴)
author: Rito15
date: 2021-06-11 17:17:00 +09:00
categories: [Algorithm, Design Pattern]
tags: [algorithm, pattern, csharp]
math: true
mermaid: true
---

# Singleton Pattern
---

## **특징** 
 - 정적 참조로부터 인스턴스 참조를 가져올 수 있다.
 - 특정 클래스에 단 한 개의 객체만 존재하도록 보장할 수 있다.

## **사용처**
 - 프로그램 내에 반드시 하나만 존재해야 하는 클래스

## **고려사항**
 - 싱글톤 객체 생성 타이밍을 고려해야 한다. (정적 or 동적)
 - 기본적으로 스레드 안전하지 않으므로, 추가적인 처리가 필요하다.

<br>

## **싱글톤 인스턴스를 통한 호출(공통)**

```cs
class SingletonTest
{
    public static void Method()
    {
        // 클래스명.Instance.멤버참조
        SingletonClass.Instance.Method();
    }
}
```

<br>

# Source Code
---

## **[1] 정적 생성 싱글톤**

- 객체를 프로그램 로드 시에 미리 생성한다.
- 이 싱글톤을 사용하지 않아도 객체를 생성하므로, 낭비가 될 수 있다.

```cs
public class SingletonClass1
{
    // 정적으로 인스턴스를 생성하여 private으로 숨기기
    private static readonly SingletonClass1 _instance = new SingletonClass1();

    // 프로퍼티만 공개
    public static SingletonClass1 Instance => _instance;

    // 생성자는 외부에서 호출할 수 없도록 private으로 숨기기
    private SingletonClass1() { }

    public void Method()
    {
        Console.WriteLine("Singleton Instance Call");
    }
}
```

<br>

## **[2] 동적 생성 싱글톤**

- 싱글톤 인스턴스를 처음 호출했을 때 객체를 생성한다.
- 생성 비용이 비쌀 경우, 성능 저하를 유발할 수 있다.

```cs
public class SingletonClass2
{
    private static SingletonClass2 _instance;

    // 읽기전용 프로퍼티를 통해 참조 및 동적 생성
    public static SingletonClass2 Instance
    {
        get
        {
            if (_instance == null)
                _instance = new SingletonClass2();
            return _instance;
        }
    }

    // 생성자는 외부에서 호출할 수 없도록 private으로 숨기기
    private SingletonClass2() { }
}
```

<br>

# Thread-safe Singleton
---

## **[1] Double-checked Locking**

- 여러 스레드에서 싱글톤에 동시 접근하여 객체가 다중 생성되지 않도록 방지한다.
- 싱글톤 객체가 null일 때 getter 참조 시, 크리티컬 섹션에 진입하여 다시 null 검사를 수행한 뒤 객체를 생성한다.
- 스레드 안전하지만 객체 생성 순간 크리티컬 섹션으로 인한 성능 저하가 발생할 수 있다.

```cs
public class SingletonClass3
{
    private static SingletonClass3 _instance;

    // 스레드 안전 보장을 위한 lock 객체
    private static readonly object _lock = new object();

    // 읽기전용 프로퍼티를 통해 참조 및 인스턴스 동적 생성
    public static SingletonClass3 Instance
    {
        get
        {
            // 인스턴스가 비어있을 경우
            if (_instance == null)
            {
                // 크리티컬 섹션 진입
                lock (_lock)
                {
                    // 인스턴스 참조 재확인 및 생성
                    if (_instance == null)
                        _instance = new SingletonClass3();
                }
            }

            return _instance;
        }
    }

    // 생성자는 외부에서 호출할 수 없도록 private으로 숨기기
    private SingletonClass3() { }
}
```

<br>

## **[2] Lazy**

- .NET 4.0 이상의 C#에서 사용할 수 있다.
- 객체 생성 시 스레드 안전성을 보장한다.
- `Lazy<T>`는 내부적으로 Double-checked Locking을 사용한다.

```cs
public class SingletonClass4
{
    // Lazy<T> 타입의 인스턴스 사용
    private static Lazy<SingletonClass4> _lazyInstance
        = new Lazy<SingletonClass4>(() => new SingletonClass4());

    // 읽기전용 프로퍼티를 통해 참조 및 동적 생성
    public static SingletonClass4 Instance
    {
        get
        {
            // 단순히 Lazy 인스턴스의 값만 참조
            return _lazyInstance.Value;
        }
    }

    // 생성자는 외부에서 호출할 수 없도록 private으로 숨기기
    private SingletonClass4() { }
}
```

<br>

# Unity Engine
---

- 유니티 엔진의 `MonoBehaviour` 상속 클래스는 `new` 연산자를 통한 직접 생성이 금지되어 있다.
- 따라서 싱글톤 getter 호출 시, 컨테이너로 사용될 게임오브젝트를 생성하고 거기에 컴포넌트를 만들어 넣어주는 방식을 이용한다.


```cs
public class SingletonMonoBehaviour : MonoBehaviour
{
    private static SingletonMonoBehaviour _instance;
    public static SingletonMonoBehaviour Instance
    {
        get
        {
            // 객체 직접 생성 대신 게임오브젝트&컴포넌트 생성
            if (_instance == null)
            {
                // 씬 전체에서 탐색
                _instance = FindObjectOfType<SingletonMonoBehaviour>();

                // 그래도 없는 경우, 새로 생성
                if (_instance == null)
                {
                    GameObject container = new GameObject("Singleton");
                    _instance = container.AddComponent<SingletonMonoBehaviour>();
                }
            }

            return _instance;
        }
    }

    // 동적으로 Instance를 호출하여 생성하지 않고,
    // 씬에 미리 배치해두는 경우 대비
    private void Awake()
    {
        if (_instance == null)
        {
            _instance = this;

            // 선택사항 : Don't Destroy On Load
            transform.SetParent(null);
            DontDestroyOnLoad(this);
        }
        else
        {
            // 인스턴스가 이미 존재하지만 본인이 아닌 경우,
            // 스스로를 파괴
            if (_instance != this)
            {
                if (GetComponents<Component>().Length <= 2)
                    Destroy(gameObject);
                else
                    Destroy(this);
            }
        }
    }
}
```

<br>

## **유니티에서 스레드 안전한 싱글톤?**

유니티의 싱글톤 예제들을 보면 lock, Lazy를 이용한 예제들이 "Modern Singleton"이라면서 소개되는 경우가 많다.

그런데 유니티 엔진에서는 유니티 API에 메인 스레드만 접근 가능하도록 되어 있다.

따라서 애초에 싱글톤 객체가 null이라 새로 생성하려고 할 때 서브 스레드에서 접근한 경우라면 `UnityException`이 발생한다.

그러니까 싱글톤 객체 생성을 스레드 안전하게 만드는게 중요한게 아니고, 더블 체크 로킹이 아니라 더블 체크 스레드 체킹을 해야 하는게 아닌가 하는 생각이 든다.

만약 서브 스레드를 고려해야 한다면, 서브 스레드에서 접근 시 메인 스레드 디스패처를 이용해 메인 스레드에 객체 생성을 위임하는 방식을 선택해야 하지 않을까?

<br>

# Unity Engine - Generic Singleton
---

- 제네릭을 이용해 단순히 상속만 하면 싱글톤으로 만들어주는 편리한 방식을 적용한다.

```cs
// 싱글톤 상속용
public abstract class SingletonMonoBase<T> : MonoBehaviour where T : Component
{
    private static T _instance;
    public static T Instance
    {
        get
        {
            if (_instance == null)
            {
                // 씬 전체에서 탐색
                _instance = FindObjectOfType<T>();

                // 그래도 없는 경우
                if (_instance == null)
                {
                    GameObject container = new GameObject($"Singleton {typeof(T)}");
                    _instance = container.AddComponent<T>();
                }
            }

            return _instance;
        }
    }

    // 동적으로 Instance를 호출하여 생성하지 않고,
    // 씬에 미리 배치해두는 경우 대비
    protected virtual void Awake()
    {
        if (_instance == null)
        {
            _instance = this as T;

            // 선택사항 : Don't Destroy On Load
            transform.SetParent(null);
            DontDestroyOnLoad(this);
        }
        else
        {
            // 인스턴스가 이미 존재하지만 본인이 아닌 경우,
            // 스스로를 파괴
            if (_instance != this)
            {
                if (GetComponents<Component>().Length <= 2)
                    Destroy(gameObject);
                else
                    Destroy(this);
            }
        }

        // 자식 Awake 호출
        Awake2();
    }

    protected virtual void Awake2() { }
}
```

```cs
public class ChildSingleton : SingletonMonoBase<ChildSingleton>
{
    protected override void Awake2()
    {
        // Awake() 대신 Awake2() 재정의하여 사용
    }
}
```


<br>

# References
---
- <https://yoon90.tistory.com/31>
- <https://github.com/UnityCommunity/UnitySingleton/blob/master/Assets/Scripts/Singleton.cs>
- <https://forum.unity.com/threads/get-singleton-pattern-to-work-outside-main-thread.501994/>
