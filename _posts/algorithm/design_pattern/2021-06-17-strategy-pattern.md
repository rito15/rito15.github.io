---
title: Strategy Pattern(전략 패턴)
author: Rito15
date: 2021-06-17 21:12:00 +09:00
categories: [Algorithm, Design Pattern]
tags: [algorithm, pattern, csharp]
math: true
mermaid: true
---

# Strategy Pattern(전략 패턴)
---

## **설명**

- 행동 패턴(Behaviour Pattern)의 일종

- 알고리즘을 클래스화하여, **실행 중에** 알고리즘(전략)을 통째로 교체하며 사용한다. (핵심)

- `if-else` 또는 `switch-case` 구문을 통해 어떤 기준에 따라 분기로 작성하던 기능을 각각 클래스화시킨다.

- 베이스 클래스를 각각 상속받는 전략 클래스들과 이를 교체하며 사용하는 클래스로 이루어진다.

- 각 전략 클래스는 베이스 클래스를 통해 **통일된 행동**을 기반으로 구현해야 한다. (중요)

- 필요에 따라 각 전략 클래스를 싱글톤화하여 재사용할 수 있다.


- 전략 클래스 내부에서 컨텍스트의 상태 전이 구문을 추가하면 상태 패턴(State Pattern)이 된다.

<br>

## **클래스 다이어그램**

![image](https://user-images.githubusercontent.com/42164422/122397891-55792e00-cfb4-11eb-9bf8-4d3b67519147.png)

<br>

## **장점**

- 컨텍스트의 변경 없이 기존의 전략을 수정하거나 새로운 전략을 추가할 수 있다.<br>
  (개방 폐쇄 원칙(OCP) 실현)

- 알고리즘 추가에 따른 컨텍스트 클래스의 규모 증가를 방지할 수 있다.

- 동일한 전략을 사용하는 다른 컨텍스트에 재사용할 수 있다.

<br>

## **단점**

- 관리해야 하는 전략 클래스와 객체의 수가 늘어난다.

- 컨텍스트와 전략 클래스 간의 추가적인 통신 오버헤드가 발생할 수 있다.

<br>

## **활용(유니티)**

- 캐릭터의 공격을 구현할 때, 공격 알고리즘을 클래스화

- 캐릭터가 처한 환경 조건에 따른 이동 알고리즘을 클래스화

- 캐릭터가 사용할 스킬을 클래스화

<br>

# 예제(유니티)
---

- 캐릭터와 적의 거리에 따른 캐릭터의 공격을 구현한다.

- 공격 가능 거리 이내에서 적과 너무 가까우면 잡기 공격, 적당히 가까우면 펀치 공격, 멀리 있으면 돌진 공격을 수행한다.

<br>

## **[1] 기존 코드**

![image](https://user-images.githubusercontent.com/42164422/122581212-c6dade80-d091-11eb-83c9-b23da6253208.png)

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
/// <summary> 플레이어 캐릭터(컨텍스트 역할) </summary>
public class PlayerCharacter : MonoBehaviour
{
    private const float GrapplingDistance = 1f;
    private const float PunchDistance = 3f;
    private const float DashDistance = 10f;

    // 현재 타겟으로 설정된 적
    private Enemy targetEnemy;

    private void Update()
    {
        if (targetEnemy == null)
        {
            FindEnemy();
        }
        else
        {
            // 적으로부터의 거리 계산
            float distanceFromEnemy = GetDistanceFromEnemy();

            // 거리에 따른 공격 전략 선택
            if (distanceFromEnemy <= GrapplingDistance)
            {
                GrapplingAttack();
            }
            else if (distanceFromEnemy <= PunchDistance)
            {
                PunchAttack();
            }
            else if (distanceFromEnemy <= DashDistance)
            {
                DashAttack();
            }
        }
    }

    public void FindEnemy()
    {
        // 적을 찾아 targetEnemy 필드에 초기화
    }

    // 적으로부터의 거리 계산
    public float GetDistanceFromEnemy()
    {
        return Vector3.Distance(targetEnemy.transform.position, transform.position);
    }

    public void GrapplingAttack()
    {
        Debug.Log("잡기 공격");
    }

    public void PunchAttack()
    {
        Debug.Log("펀치 공격");
    }

    public void DashAttack()
    {
        Debug.Log("돌진 공격");
    }
}
```

```cs
/// <summary> 적 </summary>
public class Enemy : MonoBehaviour { }
```

</details>

<br>


## **[2] 전략 패턴 적용**

- 싱글톤 패턴, 널 오브젝트 패턴도 함께 적용

![image](https://user-images.githubusercontent.com/42164422/122584441-533ad080-d095-11eb-9041-6b6940301fb3.png)

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
/// <summary> 플레이어 캐릭터(컨텍스트 역할) </summary>
public class PlayerCharacter : MonoBehaviour
{
    private const float GrapplingDistance = 1f;
    private const float PunchDistance = 3f;
    private const float DashDistance = 10f;

    // 현재 타겟으로 설정된 적
    private Enemy targetEnemy;

    // 현재 공격 전략
    private IAttackStrategy attackStrategy;

    private void Update()
    {
        if (targetEnemy == null)
        {
            FindEnemy();
        }
        else
        {
            // 적으로부터의 거리 계산
            float distanceFromEnemy = GetDistanceFromEnemy();

            // 거리에 따른 공격 전략 선택
            if (distanceFromEnemy <= GrapplingDistance)
            {
                attackStrategy = GrapplingAttack.instance;
            }
            else if (distanceFromEnemy <= PunchDistance)
            {
                attackStrategy = PunchAttack.instance;
            }
            else if (distanceFromEnemy <= DashDistance)
            {
                attackStrategy = DashAttack.instance;
            }
            else
            {
                attackStrategy = StopAttack.instance;
            }

            // 현재 전략을 통해 적 공격
            attackStrategy.Attack(targetEnemy);
        }
    }

    public void FindEnemy()
    {
        // 적을 찾아 targetEnemy 필드에 초기화
    }

    // 적으로부터의 거리 계산
    public float GetDistanceFromEnemy()
    {
        return Vector3.Distance(targetEnemy.transform.position, transform.position);
    }
}
```

```cs
/// <summary> 적 </summary>
public class Enemy : MonoBehaviour { }
```

```cs
/// <summary> 공격 전략 인터페이스 </summary>
public interface IAttackStrategy
{
    void Attack(Enemy target);
}

/// <summary> 공격 전략 베이스 클래스 </summary>
public abstract class AttackStrategy<T> : IAttackStrategy where T :  AttackStrategy<T>, new()
{
    // 각 하위 클래스마다 생성될 싱글톤 인스턴스
    public static readonly T instance = new T();
    public abstract void Attack(Enemy target);
}

/// <summary> 초근접 - 잡기 공격 </summary>
public class GrapplingAttack : AttackStrategy<GrapplingAttack>
{
    public override void Attack(Enemy target)
    {
        Debug.Log("잡기 공격");
    }
}

/// <summary> 근접 - 펀치 공격 </summary>
public class PunchAttack : AttackStrategy<PunchAttack>
{
    public override void Attack(Enemy target)
    {
        Debug.Log("펀치 공격");
    }
}

/// <summary> 비근접 - 돌진 공격 </summary>
public class DashAttack : AttackStrategy<DashAttack>
{
    public override void Attack(Enemy target)
    {
        Debug.Log("돌진 공격");
    }
}

/// <summary> 공격하지 않음 - Null 패턴의 활용 </summary>
public class StopAttack : AttackStrategy<StopAttack>
{
    public override void Attack(Enemy target)
    {
        Debug.Log("공격 중지");
    }
}
```

</details>


<br>

# References
---

- <https://ko.wikipedia.org/wiki/전략_패턴>
- <https://im-yeobi.io/posts/design-pattern/strategy-pattern/>
- <https://ansohxxn.github.io/design%20pattern/chapter3/>