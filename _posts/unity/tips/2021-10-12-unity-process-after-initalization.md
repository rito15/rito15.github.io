---
title: 유니티 - 스크립트의 실행 순서를 보장할 수 없는 경우, 종속적인 작업 처리하기
author: Rito15
date: 2021-10-12 04:00:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp]
math: true
mermaid: true
---

# 요약
---
`A` 클래스가 `B` 클래스에 종속적인 작업을 수행할 때,

`B` 클래스가 초기화 작업을 완료하기 전에 `A` 클래스가 작업을 요청하면 에러가 발생할 수 있다.

예를 들면 서로 다른 클래스의 `Awake()`, `Start()`, `OnEnable()` 호출 순서를 보장할 수 없는 경우를 생각해볼 수 있다.

이런 경우의 해결 방안을 알아본다.

<br>

# 상황 예시
---

## **[1] PlayerManager 클래스**

- `Player` 객체들을 리스트에 담아 관리하며, 리스트에 추가/제거할 수 있는 API를 제공한다.

```cs
class PlayerManager : MonoBehaviour
{
    private List<Player> playerList;

    private void Awake()
    {
        playerList = new List<Player>();
    }

    public void AddPlayer(Player player)
    {
        playerList.Add(player);
        
        /* NOTE : .Contains()를 통한 중복 확인 작업은 생략 */
    }

    public void RemovePlayer(Player player)
    {
        playerList.Remove(player);
    }
}
```

<br>

## **[2] Player 클래스**

- 활성화 시 `PlayerManager`의 리스트에 자신을 반드시 등록한다.
- 비활성화 시 `PlayerManager`의 리스트에서 자신을 제거한다.

```cs
class Player : MonoBehaviour
{
    /* NOTE : manager 객체는 항상 null이 아니라고 가정 */
    [SerializeField] private PlayerManager manager;

    private void OnEnable()
    {
        manager.AddPlayer(this);
    }
    
    private void OnDisable()
    {
        manager.RemovePlayer(this);
    }
}
```

<br>

## **[3] 설명**

위의 예시 코드는 얼핏 문제가 없어 보인다.

하지만 `PlayerManager` 클래스의 `Awake()` 메소드가 `Player` 클래스의 `OnEnable()`보다 반드시 먼저 호출되어야만 정상적으로 동작한다.

만약 호출 순서가 반대일 경우, `PlayerManger`의 `playerList` 필드가 `null`이므로 `NullReferenceException`이 발생할 것이다.

그렇다고 `PlayerManager.AddPlayer(Player)` 메소드를

```cs
public void AddPlayer(Player player)
{
    if(playerList != null)
        playerList.Add(player);
}
```

이런 식으로 바꾸게 되면,

`Awake()` 호출 이전에 `OnEnable()`이 호출된 모든 `Player`들은 무시되므로 바람직하지 않다.

<br>

`[DefaultExecutionOrder]`를 설정하는 방법도 있지만,

다른 스크립트간의 순서에도 영향받고 변경과 확장에 악영향을 끼칠 수 있으므로 이 또한 바람직하지 않다.

<br>

# 해결 방안 1 - Job Queue
---

- `PlayerManager.Awake()`가 호출되기 전의 동작을 모두 Job Queue에 담아 놓고, `Awake()` 메소드에서 큐에 쌓인 작업을 모두 처리한다.
- `Awake()`가 아니라 `Start()` 또는 늦은 초기화의 경우에도 모두 동일하게 사용할 수 있다.

- 처리 완료 후, 큐는 더이상 힙 메모리를 차지할 필요가 없으므로 `null`로 초기화 해준다.

<br>

```cs
class PlayerManager : MonoBehaviour
{
    private List<Player> playerList;
    
    // 초기 작업 완료 후 호출할 작업들 큐
    private Queue<Action> afterInitJobQueue = new Queue<Action>();

    private void Awake()
    {
        playerList = new List<Player>();
        
        // 등록된 작업들을 꺼내서 모두 수행한다.
        while(afterInitJobQueue.Count > 0)
        {
            Action action = afterInitJobQueue.Dequeue();
            action?.Invoke();
        }
        
        // 힙에서 해제한다.
        afterInitJobQueue = null;
    }

    public void AddPlayer(Player player)
    {
        // 아직 초기화되지 않은 경우, 대기열에 등록한다.
        if(playerList == null)
            afterInitJobQueue.Enqueue((() => playerList.Add(player));
        else
            playerList.Add(player);
    }

    public void RemovePlayer(Player player)
    {
        // 아직 초기화되지 않은 경우, 그냥 무시한다.
        if(playerList == null)
            return;
        
        playerList.Remove(player);
    }
}
```

<br>

# 해결 방안 2 - Coroutine
---

- 각각의 작업을 코루틴으로 감싸서 초기화 완료 후 처리되도록 한다.

<br>

```cs
class PlayerManager : MonoBehaviour
{
    private List<Player> playerList;

    private void Awake()
    {
        playerList = new List<Player>();
    }
    
    // 코루틴 래퍼(Wrapper) 메소드
    // predicate 조건이 충족되지 않은 경우, 대기한다.
    private void ProcessLater(Func<bool> predicate, Action job)
    {
        StartCoroutine(ProcessLaterRoutine());

        // Local
        IEnumerator ProcessLaterRoutine()
        {
            yield return new WaitUntil(predicate);
            job?.Invoke();
        }
    }

    public void AddPlayer(Player player)
    {
        // 아직 초기화 되지 않은 경우, 초기화 이후 실행되도록 등록한다.
        if(playerList == null)
            ProcessLater(() => playerList != null, () => playerList.Add(player));
        else
            playerList.Add(player);
    }

    public void RemovePlayer(Player player)
    {
        // 아직 초기화 되지 않은 경우, 그냥 무시한다.
        if(playerList == null)
            return;
        
        playerList.Remove(player);
    }
}
```

<br>

## **장점**
- 별도의 필드를 추가할 필요가 없다.
- 초기화 작업을 마무리하는 부분에서 추가적인 호출 코드를 넣어줄 필요가 없다.
- 초기화 작업뿐만 아니라 다른 조건들에도 유연하게 반응하여 처리할 수 있다.

<br>

## **단점**
- 각각의 작업이 코루틴으로 실행되므로, 작업이 너무 많은 경우 성능상 좋지 않다.

<br>