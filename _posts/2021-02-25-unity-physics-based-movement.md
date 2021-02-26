---
title: 물리 기반 캐릭터 이동 구현하기
author: Rito15
date: 2021-02-25 04:11:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, physics, movement]
math: true
mermaid: true
---

# 서론
---

유니티에서 캐릭터 이동을 구현하기 위한 방법들은 다양하다.

- Transform
- Rigidbody
- Character Controller
- NavMeshAgent
- ...

트랜스폼, 내비메시 에이전트를 통해 이동을 구현하면 물리 상호작용을 할 수 없고,

캐릭터 컨트롤러를 통해 구현하면 이미 구현되어 있는 기능들로 인해 물리 제어를 완전히 커스텀하게 할 수 없다.

따라서 리지드바디를 이용해 이동을 구현하려 한다.


그리고 리지드바디를 이용해 물리 기반 이동을 구현하는 방법은 두 가지로 나눌 수 있다.

첫째는 Rigidbody.MovePosition()을 이용하는 것, 두 번째는 Rigidbody.velocity를 직접 조절하는 것이다.

이 포스트에서는 velocity를 제어하여 리지드바디 기반 이동을 구현한다.

<br>

# 이동 스크립트 분리
---

키보드 입력을 통한 이동 및 회전 벡터 초기화, 캐릭터 회전은 모두 앞선 포스트에서 작성한 CharacterMainController를 사용하며,

이 포스트에서는 월드 이동 벡터를 전달받아 이동만 담당하는 스크립트를 분리하여 작성한다.

그리고 이동 스크립트를 다양하게 작성해도 동일하게 메인 컨트롤러에서 사용할 수 있도록 인터페이스로 묶는다.

<br>

<details>
<summary markdown="span"> 
IMovement3D.cs
</summary>

```cs
public interface IMovement3D
{
    /// <summary> 현재 이동 중인지 여부 </summary>
    bool IsMoving();
    /// <summary> 지면에 닿아 있는지 여부 </summary>
    bool IsGrounded();
    /// <summary> 지면으로부터의 거리 </summary>
    float GetDistanceFromGround();

    /// <summary> 월드 이동벡터 초기화(이동 명령) </summary>
    void SetMovement(in Vector3 worldMoveDirection, bool isRunning);
    /// <summary> 점프 명령 - 점프 성공 여부 리턴 </summary>
    bool SetJump();
    /// <summary> 이동 중지 </summary>
    void StopMoving();

    /// <summary> 밀쳐내기 </summary>
    void KnockBack(in Vector3 force, float time);
}
```

</details>

<br>

# 요구사항
---

## 상태 검사
  - 현재 캐릭터가 지면을 딛고 있는지 항상 검사해야 한다.
  - 캐릭터가 이동하는 방향에 장애물이 있는지 검사해야 한다.
  - 경사면의 각도를 항상 검사해야 한다.

## 이동
  - 지상에서 캐릭터는 항상 경사면을 따라 이동한다.
  - 공중에서 캐릭터는 월드 XZ 평면 방향으로 이동한다.

## 중력
  - 캐릭터는 지상에 있을 때 중력의 영향을 받지 않는다. (경사면을 따라 미끄러지지 않는다.)
  - 캐릭터는 공중에 있을 때 중력의 영향을 받는다.

## 이동 제한
  - 제한 경사각 이상의 각도를 가진 경사면에는 이동할 수 없어야 한다.
  - 제한 경사각 이상의 각도를 가진 경사면에 위치할 경우, 중력을 적용하여 미끄러지게 한다.

## 점프
  - 다중 점프를 할 수 있어야 한다.
  - 첫 점프는 지상에 있을때만 가능하다.

<br>

# 필드, 프로퍼티 정의
---

스크립트 내에서 사용할 필드, 프로퍼티를 정의한다.

<details>
<summary markdown="span"> 
Data Class Definitions
</summary>

```cs
[Serializable]
public class Components
{
    [HideInInspector] public CapsuleCollider capsule;
    [HideInInspector] public Rigidbody rBody;
}
[Serializable]
public class CheckOption
{
    [Tooltip("지면으로 체크할 레이어 설정")]
    public LayerMask groundLayerMask = -1;

    [Range(0.01f, 0.5f), Tooltip("전방 감지 거리")]
    public float forwardCheckDistance = 0.1f;

    [Range(0.1f, 10.0f), Tooltip("지면 감지 거리")]
    public float groundCheckDistance = 2.0f;

    [Range(0.0f, 0.1f), Tooltip("지면 인식 허용 거리")]
    public float groundCheckThreshold = 0.01f;
}
[Serializable]
public class MovementOption
{
    [Range(1f, 10f), Tooltip("이동속도")]
    public float speed = 5f;

    [Range(1f, 3f), Tooltip("달리기 이동속도 증가 계수")]
    public float runningCoef = 1.5f;

    [Range(1f, 10f), Tooltip("점프 강도")]
    public float jumpForce = 4.2f;

    [Range(0.0f, 2.0f), Tooltip("점프 쿨타임")]
    public float jumpCooldown = 0.6f;

    [Range(0, 3), Tooltip("점프 허용 횟수")]
    public int maxJumpCount = 1;

    [Range(1f, 70f), Tooltip("등반 가능한 경사각")]
    public float maxSlopeAngle = 50f;

    [Range(0f, 4f), Tooltip("경사로 이동속도 변화율(가속/감속)")]
    public float slopeAccel = 1f;

    [Range(-9.81f, 0f), Tooltip("중력")]
    public float gravity = -9.81f;
}
[Serializable]
public class CurrentState
{
    public bool isMoving;
    public bool isRunning;
    public bool isGrounded;
    public bool isOnSteepSlope;   // 등반 불가능한 경사로에 올라와 있음
    public bool isJumpTriggered;
    public bool isJumping;
    public bool isForwardBlocked; // 전방에 장애물 존재
    public bool isOutOfControl;   // 제어 불가 상태
}
[Serializable]
public class CurrentValue
{
    public Vector3 worldMoveDir;
    public Vector3 groundNormal;
    public Vector3 groundCross;
    public Vector3 horizontalVelocity;

    [Space]
    public float jumpCooldown;
    public int   jumpCount;
    public float outOfControllDuration;

    [Space]
    public float groundDistance;
    public float groundSlopeAngle;         // 현재 바닥의 경사각
    public float groundVerticalSlopeAngle; // 수직으로 재측정한 경사각
    public float forwardSlopeAngle; // 캐릭터가 바라보는 방향의 경사각
    public float slopeAccel;        // 경사로 인한 가속/감속 비율

    [Space]
    public float gravity; // 직접 제어하는 중력값
}
```

</details>

<br>

<details>
<summary markdown="span"> 
Variables, Properties
</summary>

```cs
SerializeField] private Components       _components = new Components();
[SerializeField] private CheckOption   _checkOptions = new CheckOption();
[SerializeField] private MovementOption _moveOptions = new MovementOption();
[SerializeField] private CurrentState _currentStates = new CurrentState();
[SerializeField] private CurrentValue _currentValues = new CurrentValue();

private Components     Com     => _components;
private CheckOption    COption => _checkOptions;
private MovementOption MOption => _moveOptions;
private CurrentState   State   => _currentStates;
private CurrentValue   Current => _currentValues;


private float _capsuleRadiusDiff;
private float _fixedDeltaTime;

private float _castRadius; // Sphere, Capsule 레이캐스트 반지름

private Vector3 CapsuleTopCenterPoint 
    => new Vector3(transform.position.x, transform.position.y + Com.capsule.height - Com.capsule.radius, transform.position.z);

private Vector3 CapsuleBottomCenterPoint 
    => new Vector3(transform.position.x, transform.position.y + Com.capsule.radius, transform.position.z);
```

</details>

<br>

# 상태 검사
---

물리적 상태를 검사하기 위한 방법으로 우선 레이캐스트를 생각해볼 수 있다.

흔히 사용하는 방법으로, 캐릭터 중심 좌표에서 수직 하향 레이캐스트를 하여 바닥까지의 거리를 검사할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/109267741-68bd8d80-784d-11eb-9781-fef83cc0d671.png)

하지만 위와 같이 캐릭터가 지형에 걸쳐있는 경우, 부정확한 결과를 얻게 된다.

<br>

그렇다면 캐릭터의 네 모퉁이에서 각각 레이캐스트를 하여 결과를 OR 연산으로 사용하면 어떨까?

![image](https://user-images.githubusercontent.com/42164422/109268112-f7caa580-784d-11eb-93fe-6baa3aa092e8.png)

평지, 큐브, 균일한 경사면에서는 나쁘지 않은 결과를 얻을 수 있지만

언덕, 산간 지형, 불규칙한 지형에서는 이마저도 정확한 결과를 얻는다는 보장이 없다.

<br>

다음으로 생각해볼 수 있는 것들은 OnCollision~, ~Cast, Rigidbody.SweepTest가 있다.

OnCollision류의 이벤트 메소드는 항상 모든 방위를 검사하는 데다가, Enter, Exit을 모두 다루어줘야 하고, FixedDeltaTime 주기 밖에서 변화가 발생하여 이벤트를 감지하지 못할 가능성이 존재하며, Stay는 오버헤드가 크다.

SweepTest는 콜라이더에 맞닿아있는 경우 감지할 수 없으며, 이를 보완하기 위해서는 캐릭터의 콜라이더 크기보다 조금 더 작은 또다른 콜라이더와 그에 부착할 리지드바디가 필요한데, 캐릭터에 두 개의 리지드바디와 콜라이더를 사용하는 것은 성능의 낭비라고 할 수 있다(실제로 해보았다).

<br>

결국 최종적인 선택은 ~Cast (Sphere, Capsule, Box, ...) 이다.

캐릭터에는 캡슐 콜라이더를 사용할 것이므로 지면 감지에는 SphereCast, 전방 장애물 감지에는 CapsuleCast를 사용한다.

<br>

## **[1] 전방 장애물 검사**

전방을 검사하는 코드는 비교적 간단하다.

캐릭터의 캡슐 콜라이더와 같은, 혹은 좀더 작은 크기(같은 크기로 검사하면 전방 180도를 모두 감지하게 되므로)의 캡슐 캐스트를 현재 이동 방향으로 검사한다.

캐스트 거리는 인스펙터를 통해 조정하며, 보통 0.1 정도로 사용한다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private void CheckForward()
{
    bool cast =
        Physics.CapsuleCast(CapsuleBottomCenterPoint, CapsuleTopCenterPoint, _castRadius, Current.worldMoveDir + Vector3.down * 0.1f,
            out var hit, COption.forwardCheckDistance, -1, QueryTriggerInteraction.Ignore);

    State.isForwardBlocked = false;
    if (cast)
    {
        float forwardObstacleAngle = Vector3.Angle(hit.normal, Vector3.up);
        State.isForwardBlocked = forwardObstacleAngle >= MOption.maxSlopeAngle;
    }
}
```

</details>

<br>

## **[2] 지면 검사**

하단방향 지면 검사를 통해 다음의 정보들을 얻어낸다.

- 캐릭터와 지면 사이의 거리(높이)

- 캐릭터가 현재 지면에 위치해 있는지 여부

- 지면의 경사각(기울기)

- 캐릭터가 이동할 방향을 기준으로 하는 경사각
  - 캐릭터가 이동할 방향의 실제 경사각을 구한다.

- 현재 캐릭터가 오를 수 없는 경사면에 위치해 있는지 여부
  - 이 정보를 이용해 추후 이동 구현시 오를 수 없는 경사면에 있을 경우 미끄러지게 한다.

- 경사면의 회전축 벡터
  - 캐릭터가 경사면을 따라 이동할 수 있도록, 월드 이동 벡터를 회전시키기 위한 기준이 된다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private void CheckGround()
{
    Current.groundDistance = float.MaxValue;
    Current.groundNormal = Vector3.up;
    Current.groundSlopeAngle = 0f;
    Current.forwardSlopeAngle = 0f;

    bool cast =
        Physics.SphereCast(CapsuleBottomCenterPoint, _castRadius, Vector3.down, out var hit, COption.groundCheckDistance, COption.groundLayerMask, QueryTriggerInteraction.Ignore);

    State.isGrounded = false;

    if (cast)
    {
        // 지면 노멀벡터 초기화
        Current.groundNormal = hit.normal;

        // 현재 위치한 지면의 경사각 구하기(캐릭터 이동방향 고려)
        Current.groundSlopeAngle = Vector3.Angle(Current.groundNormal, Vector3.up);
        Current.forwardSlopeAngle = Vector3.Angle(Current.groundNormal, Current.worldMoveDir) - 90f;

        State.isOnSteepSlope = Current.groundSlopeAngle >= MOption.maxSlopeAngle;

        Current.groundDistance = Mathf.Max(hit.distance - _capsuleRadiusDiff - COption.groundCheckThreshold, -10f);

        State.isGrounded =
            (Current.groundDistance <= 0.0001f) && !State.isOnSteepSlope;
    }

    // 월드 이동벡터 회전축
    Current.groundCross = Vector3.Cross(Current.groundNormal, Vector3.up);
}
```

</details>

<br>

# 중력
---

## **중력이 작용하는 경우**

- 캐릭터가 공중에 떠있는 경우

- 캐릭터가 오를수 없는 경사면에 위치한 경우

<br>

## **중력이 작용하지 않는 경우**

- 캐릭터가 지면에 위치한 경우

<br>

## **중력의 직접 제어**

리지드바디의 useGravity를 사용할 경우, 중력은 내부적으로 velocity 값의 변화를 통해 적용된다.

Rigidbody.Move()를 사용하면 그저 useGravity를 사용하고 중력을 신경쓰지 않아도 된다.

그리고 수평 속도만을 조정한다면 Rigidbody.velocity.y는 그대로 두고 x, z 값만 조정할 수도 있다.

그런데 지금은 Rigidbody.Move()가 아니라 velocity를 직접 조정하는데다가, 경사면에서 수평 벡터를 회전시켜 결국 y 속도에도 영향을 주어야 한다.

따라서 useGravity를 false로 두고 직접 중력 값을 제어하여 사용한다.

```cs
if (State.isGrounded)
{
    Current.gravity = 0f;
}
else
{
    Current.gravity += _fixedDeltaTime * MOption.gravity;
}
```

<br>

# 이동 구현하기
---

## **[1] XZ 이동 벡터 초기화**

기본적인 XZ 평면 방향 이동 벡터는 위처럼 이동 방향 전방이 막히지 않은 경우 월드 이동 방향 벡터에 이동속도를 곱해주는 방식으로 초기화한다.

```cs
if (State.isForwardBlocked) 
{
    Current.horizontalVelocity = Vector3.zero;
}
else
{
    float speed = !State.isMoving  ? 0f :
                    !State.isRunning ? MOption.speed :
                                        MOption.speed * MOption.runningCoef;

    Current.horizontalVelocity = Current.worldMoveDir * speed;
}
```

<br>

## **[2] 경사면에서 벡터의 회전**

지면 검사 메소드에서 얻어냈던 경사면 회전축 벡터(groundCross)를 이용하여, XZ 평면의 이동벡터를 경사면에 평행하도록 회전시킨다.

그리고 그 전에, 캐릭터가 향하는 방향의 경사각(forwardSlopeAngle)을 이용하여 경사에 의한 가속/감속을 적용한다.

```cs
if (State.isGrounded && State.isMoving && !State.isForwardBlocked)
{
    // 경사로 인한 가속/감속
    if (MOption.slopeAccel > 0f)
    {
        bool isPlus = Current.forwardSlopeAngle >= 0f;
        float absFsAngle = isPlus ? Current.forwardSlopeAngle : -Current.forwardSlopeAngle;
        float accel = MOption.slopeAccel * absFsAngle * 0.01111f + 1f;
        Current.slopeAccel = !isPlus ? accel : 1.0f / accel;

        Current.horizontalVelocity *= Current.slopeAccel;
    }

    // 벡터 회전 (경사로)
    Current.horizontalVelocity =
        Quaternion.AngleAxis(-Current.groundSlopeAngle, Current.groundCross) * Current.horizontalVelocity;
}
```

<br>

## **[3] 점프**

점프는 현재 적용된 중력 값을 점프력 값으로 초기화하는 방식을 통해 간단히 구현할 수 있다.

```cs
if (State.isJumpTriggered && Current.jumpCooldown <= 0f)
{
    Current.gravity = MOption.jumpForce;
}
```

<br>

# 최종 이동 벡터 계산
---

구현 순서대로 작성한다.

<br>

## **[1] 점프**

점프는 다중 점프와 쿨타임을 고려하여 작성한다.

```cs
if (State.isJumpTriggered)
{
    Current.gravity = MOption.jumpForce;

    // 점프 쿨타임, 트리거 초기화
    Current.jumpCooldown = MOption.jumpCooldown;
    State.isJumpTriggered = false;
    State.isJumping = true;

    Current.jumpCount++;
}
```

- 점프는 현재 gravity 값에 양수의 점프력 값을 초기화하여 구현한다.

- 메인 컨트롤러로부터 점프 명령을 받으면 isJumpTriggered 값이 true로 초기화되며, 위 코드에서 이를 감지하여 점프를 하게 된다.

- 점프 쿨타임은 0보다 클 경우 Update 또는 FixedUpdate에서 값을 항상 감소시킨다.

<br>

## **[2] XZ 평면 이동**

XZ 이동속도 계산의 경우, 여러가지 조건을 고려할 수 있다.

조건을 아예 설정하지 않은 경우, 벽으로 이동하며 점프했을 때 점프가 되지 않거나 매달려버리는 경우가 발생한다.

![2021_0226_Move3](https://user-images.githubusercontent.com/42164422/109301358-2f9c1200-787b-11eb-90a8-5e5903faed35.gif)

<br>

```cs
if(State.isForwardBlocked)
```

기존의 조건대로 전방이 막혀있으면 아예 전방 이동이 불가능하게 할 수도 있지만, 벽에 살짝만 닿아도 캐릭터가 정지하는 등 조작감에 있어서 불편함을 느낄 수 있다.

![2021_0226_Move1](https://user-images.githubusercontent.com/42164422/109300785-5443ba00-787a-11eb-8c7f-f9ed978562d0.gif)

<br>

```cs
if (State.isForwardBlocked && !State.isGrounded || State.isJumping && State.isGrounded) 
```

따라서 위처럼 조건을 지정하여 지상에서는 자유롭게 이동하도록 하고, 공중에서만 전방이 막힌 경우 속도를 0으로 초기화하여 벽에 매달리는 현상을 방지한다.

그리고 ```State.isJumping && State.isGrounded``` 조건은 점프하는 순간에 벽에 매달려 점프하지 못하는 현상을 방지해준다.

![2021_0226_Move2](https://user-images.githubusercontent.com/42164422/109301044-b00e4300-787a-11eb-8522-88c55b9c7257.gif)

<br>

## **[3] XZ 벡터 회전**

```cs
if (State.isGrounded && State.isMoving && !State.isForwardBlocked)
```

이렇게 지면에 붙어있을 때만 XZ 벡터를 회전시키면 캐릭터가 경사면을 내려올 때 경사면을 타고 내려오지 않고 허공으로 뛰어내리는 현상이 발생한다.

![2021_0226_Move4](https://user-images.githubusercontent.com/42164422/109301582-83a6f680-787b-11eb-8809-7fcc14907a10.gif)

<br>

따라서

```cs
if( (State.isGrounded || Current.groundDistance < COption.groundCheckDistance && !State.isJumping) &&
    (State.isMoving && !State.isForwardBlocked) )
```

이렇게, 점프를 하지 않은 상태에서 지면에 가까이 위치한 경우도 경사면에 따라 벡터를 회전시키도록 설정한다.

![2021_0226_Move5](https://user-images.githubusercontent.com/42164422/109303016-7d197e80-787d-11eb-89e2-f5ae18138ff8.gif)

<br>

## 결과

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private void CalculateMovements()
{
    // 1. 점프
    if (State.isJumpTriggered)
    {
        Current.gravity = MOption.jumpForce;

        // 점프 쿨타임, 트리거 초기화
        Current.jumpCooldown = MOption.jumpCooldown;
        State.isJumpTriggered = false;
        State.isJumping = true;

        Current.jumpCount++;
    }

    // 2. XZ 이동속도 계산
    // 공중에서 전방이 막힌 경우 제한 (지상에서는 벽에 붙어서 이동할 수 있도록 허용)
    if (State.isForwardBlocked && !State.isGrounded || State.isJumping && State.isGrounded) 
    {
        Current.horizontalVelocity = Vector3.zero;
    }
    else // 이동 가능한 경우 : 지상 or 전방이 막히지 않음
    {
        float speed = !State.isMoving  ? 0f :
                      !State.isRunning ? MOption.speed :
                                         MOption.speed * MOption.runningCoef;

        Current.horizontalVelocity = Current.worldMoveDir * speed;
    }

    // 3. XZ 벡터 회전
    // 지상이거나 지면에 가까운 높이
    if (State.isGrounded || Current.groundDistance < COption.groundCheckDistance && !State.isJumping)
    {
        if (State.isMoving && !State.isForwardBlocked)
        {
            // 경사로 인한 가속/감속
            if (MOption.slopeAccel > 0f)
            {
                bool isPlus = Current.forwardSlopeAngle >= 0f;
                float absFsAngle = isPlus ? Current.forwardSlopeAngle : -Current.forwardSlopeAngle;
                float accel = MOption.slopeAccel * absFsAngle * 0.01111f + 1f;
                Current.slopeAccel = !isPlus ? accel : 1.0f / accel;

                Current.horizontalVelocity *= Current.slopeAccel;
            }

            // 벡터 회전 (경사로)
            Current.horizontalVelocity =
                Quaternion.AngleAxis(-Current.groundSlopeAngle, Current.groundCross) * Current.horizontalVelocity;
        }
    }
}
```

</details>

<br>

## 리지드바디에 속도 적용

```cs
Com.rBody.velocity = Current.horizontalVelocity + Vector3.up * (Current.gravity);
```

XZ 이동속도를 계산한 벡터와 중력 벡터를 더하여 리지드바디에 적용하면 된다.

경사면에서 XZ 벡터가 회전하므로, y값이 0이 아니라는 점에 유의해야 한다.

<br>

# 물리 상호작용
---

리지드바디의 velocity를 직접 수정하게 되면 외부의 힘을 전달받아도 이를 덮어씌우기 때문에 사실상 자연스러운 물리적 상호작용을 기대하기 힘들다.

따라서 몇 가지 방법이 있는데,

<br>

첫 번째는 외부 힘을 받아 속도에 합산하는 로직을 직접 작성하여 메소드로 제공하는 것이다.

그런데 이 방법은 유니티 물리엔진 내부 구현의 일부를 다시 직접 하는 것이나 다름없기 때문에 애초에 속도를 직접 수정하지 않는 방식을 선택하는 것이 좋다.

<br>

두 번째는 일시적으로 직접적인 제어가 불가능한 상태를 만드는 것이다.

외부에서 강제적인 힘의 개입이 필요할 때, 리지드바디의 속도 수정을 중단하고 자연스럽게 물리엔진의 계산대로 동작하도록 한다.

넉백의 구현을 예로 들 수 있다.

넉백 순간에 일시적으로 제어가 불가능한 상태를 만들고 힘을 가한 뒤, 일정 시간 후에 제어를 되찾는 방식으로 구현할 수 있다.

<br>

# Source Code
---

<details>
<summary markdown="span"> 
PhysicsBasedMovement.cs
</summary>

```cs
public class PhysicsBasedMovement : MonoBehaviour, IMovement3D
{
    /***********************************************************************
    *                               Definitions
    ***********************************************************************/
    #region .
    [Serializable]
    public class Components
    {
        [HideInInspector] public CapsuleCollider capsule;
        [HideInInspector] public Rigidbody rBody;
    }
    [Serializable]
    public class CheckOption
    {
        [Tooltip("지면으로 체크할 레이어 설정")]
        public LayerMask groundLayerMask = -1;

        [Range(0.01f, 0.5f), Tooltip("전방 감지 거리")]
        public float forwardCheckDistance = 0.1f;

        [Range(0.1f, 10.0f), Tooltip("지면 감지 거리")]
        public float groundCheckDistance = 2.0f;

        [Range(0.0f, 0.1f), Tooltip("지면 인식 허용 거리")]
        public float groundCheckThreshold = 0.01f;
    }
    [Serializable]
    public class MovementOption
    {
        [Range(1f, 10f), Tooltip("이동속도")]
        public float speed = 5f;

        [Range(1f, 3f), Tooltip("달리기 이동속도 증가 계수")]
        public float runningCoef = 1.5f;

        [Range(1f, 10f), Tooltip("점프 강도")]
        public float jumpForce = 4.2f;

        [Range(0.0f, 2.0f), Tooltip("점프 쿨타임")]
        public float jumpCooldown = 0.6f;

        [Range(0, 3), Tooltip("점프 허용 횟수")]
        public int maxJumpCount = 1;

        [Range(1f, 70f), Tooltip("등반 가능한 경사각")]
        public float maxSlopeAngle = 50f;

        [Range(0f, 4f), Tooltip("경사로 이동속도 변화율(가속/감속)")]
        public float slopeAccel = 1f;

        [Range(-9.81f, 0f), Tooltip("중력")]
        public float gravity = -9.81f;
    }
    [Serializable]
    public class CurrentState
    {
        public bool isMoving;
        public bool isRunning;
        public bool isGrounded;
        public bool isOnSteepSlope;   // 등반 불가능한 경사로에 올라와 있음
        public bool isJumpTriggered;
        public bool isJumping;
        public bool isForwardBlocked; // 전방에 장애물 존재
        public bool isOutOfControl;   // 제어 불가 상태
    }
    [Serializable]
    public class CurrentValue
    {
        public Vector3 worldMoveDir;
        public Vector3 groundNormal;
        public Vector3 groundCross;
        public Vector3 horizontalVelocity;

        [Space]
        public float jumpCooldown;
        public int   jumpCount;
        public float outOfControllDuration;

        [Space]
        public float groundDistance;
        public float groundSlopeAngle;         // 현재 바닥의 경사각
        public float groundVerticalSlopeAngle; // 수직으로 재측정한 경사각
        public float forwardSlopeAngle; // 캐릭터가 바라보는 방향의 경사각
        public float slopeAccel;        // 경사로 인한 가속/감속 비율

        [Space]
        public float gravity;
    }

    #endregion
    /***********************************************************************
    *                               Variables
    ***********************************************************************/
    #region .

    [SerializeField] private Components _components = new Components();
    [SerializeField] private CheckOption _checkOptions = new CheckOption();
    [SerializeField] private MovementOption _moveOptions = new MovementOption();
    [SerializeField] private CurrentState _currentStates = new CurrentState();
    [SerializeField] private CurrentValue _currentValues = new CurrentValue();

    private Components Com => _components;
    private CheckOption COption => _checkOptions;
    private MovementOption MOption => _moveOptions;
    private CurrentState State => _currentStates;
    private CurrentValue Current => _currentValues;


    private float _capsuleRadiusDiff;
    private float _fixedDeltaTime;

    private float _castRadius; // Sphere, Capsule 레이캐스트 반지름
    private Vector3 CapsuleTopCenterPoint 
        => new Vector3(transform.position.x, transform.position.y + Com.capsule.height - Com.capsule.radius, transform.position.z);
    private Vector3 CapsuleBottomCenterPoint 
        => new Vector3(transform.position.x, transform.position.y + Com.capsule.radius, transform.position.z);

    #endregion
    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Start()
    {
        InitComponents();
    }

    private void FixedUpdate()
    {
        _fixedDeltaTime = Time.fixedDeltaTime;

        CheckGround();
        CheckForward();

        UpdatePhysics();
        UpdateValues();

        CalculateMovements();
        ApplyMovementsToRigidbody();
    }

    #endregion
    /***********************************************************************
    *                               Init Methods
    ***********************************************************************/
    #region .
    private void InitComponents()
    {
        TryGetComponent(out Com.rBody);
        TryGetComponent(out Com.capsule);

        // 회전은 트랜스폼을 통해 직접 제어할 것이기 때문에 리지드바디 회전은 제한
        Com.rBody.constraints = RigidbodyConstraints.FreezeRotation;
        Com.rBody.interpolation = RigidbodyInterpolation.Interpolate;
        Com.rBody.useGravity = false; // 중력 직접 제어

        _castRadius = Com.capsule.radius * 0.9f;
        _capsuleRadiusDiff = Com.capsule.radius - _castRadius + 0.05f;
    }

    #endregion
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .

    bool IMovement3D.IsMoving() => State.isMoving;
    bool IMovement3D.IsGrounded() => State.isGrounded;
    float IMovement3D.GetDistanceFromGround() => Current.groundDistance;

    void IMovement3D.SetMovement(in Vector3 worldMoveDir, bool isRunning)
    {
        Current.worldMoveDir = worldMoveDir;
        State.isMoving = worldMoveDir.sqrMagnitude > 0.01f;
        State.isRunning = isRunning;
    }
    bool IMovement3D.SetJump()
    {
        // 첫 점프는 지면 위에서만 가능
        if (!State.isGrounded && Current.jumpCount == 0) return false;

        if (Current.jumpCooldown > 0f) return false;
        if (Current.jumpCount >= MOption.maxJumpCount) return false;

        // 접근 불가능 경사로에서 점프 불가능
        if (State.isOnSteepSlope) return false;

        State.isJumpTriggered = true;
        return true;
    }

    void IMovement3D.StopMoving()
    {
        Current.worldMoveDir = Vector3.zero;
        State.isMoving = false;
        State.isRunning = false;
    }

    void IMovement3D.KnockBack(in Vector3 force, float time)
    {
        SetOutOfControl(time);
        Com.rBody.AddForce(force, ForceMode.Impulse);
    }

    public void SetOutOfControl(float time)
    {
        Current.outOfControllDuration = time;
        ResetJump();
    }

    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .

    private void ResetJump()
    {
        Current.jumpCooldown = 0f;
        Current.jumpCount = 0;
        State.isJumping = false;
        State.isJumpTriggered = false;
    }

    /// <summary> 하단 지면 검사 </summary>
    private void CheckGround()
    {
        Current.groundDistance = float.MaxValue;
        Current.groundNormal = Vector3.up;
        Current.groundSlopeAngle = 0f;
        Current.forwardSlopeAngle = 0f;

        bool cast =
            Physics.SphereCast(CapsuleBottomCenterPoint, _castRadius, Vector3.down, out var hit, COption.groundCheckDistance, COption.groundLayerMask, QueryTriggerInteraction.Ignore);

        State.isGrounded = false;

        if (cast)
        {
            // 지면 노멀벡터 초기화
            Current.groundNormal = hit.normal;

            // 현재 위치한 지면의 경사각 구하기(캐릭터 이동방향 고려)
            Current.groundSlopeAngle = Vector3.Angle(Current.groundNormal, Vector3.up);
            Current.forwardSlopeAngle = Vector3.Angle(Current.groundNormal, Current.worldMoveDir) - 90f;

            State.isOnSteepSlope = Current.groundSlopeAngle >= MOption.maxSlopeAngle;

            Current.groundDistance = Mathf.Max(hit.distance - _capsuleRadiusDiff - COption.groundCheckThreshold, 0f);

            State.isGrounded =
                (Current.groundDistance <= 0.0001f) && !State.isOnSteepSlope;

            GzUpdateValue(ref _gzGroundTouch, hit.point);
        }

        // 월드 이동벡터 회전축
        Current.groundCross = Vector3.Cross(Current.groundNormal, Vector3.up);
    }

    /// <summary> 전방 장애물 검사 : 레이어 관계 없이 trigger가 아닌 모든 장애물 검사 </summary>
    private void CheckForward()
    {
        bool cast =
            Physics.CapsuleCast(CapsuleBottomCenterPoint, CapsuleTopCenterPoint, _castRadius, Current.worldMoveDir + Vector3.down * 0.1f,
                out var hit, COption.forwardCheckDistance, -1, QueryTriggerInteraction.Ignore);

        State.isForwardBlocked = false;
        if (cast)
        {
            float forwardObstacleAngle = Vector3.Angle(hit.normal, Vector3.up);
            State.isForwardBlocked = forwardObstacleAngle >= MOption.maxSlopeAngle;

            GzUpdateValue(ref _gzForwardTouch, hit.point);
        }
    }

    private void UpdatePhysics()
    {
        // Custom Gravity, Jumping State
        if (State.isGrounded)
        {
            Current.gravity = 0f;

            Current.jumpCount = 0;
            State.isJumping = false;
        }
        else
        {
            Current.gravity += _fixedDeltaTime * MOption.gravity;
        }
    }

    private void UpdateValues()
    {
        // Calculate Jump Cooldown
        if (Current.jumpCooldown > 0f)
            Current.jumpCooldown -= _fixedDeltaTime;

        // Out Of Control
        State.isOutOfControl = Current.outOfControllDuration > 0f;

        if (State.isOutOfControl)
        {
            Current.outOfControllDuration -= _fixedDeltaTime;
            Current.worldMoveDir = Vector3.zero;
        }
    }

    private void CalculateMovements()
    {
        if (State.isOutOfControl)
        {
            Current.horizontalVelocity = Vector3.zero;
            return;
        }

        // 1. 점프
        if (State.isJumpTriggered && Current.jumpCooldown <= 0f)
        {
            DebugMark(1);

            Current.gravity = MOption.jumpForce;

            // 점프 쿨타임, 트리거 초기화
            Current.jumpCooldown = MOption.jumpCooldown;
            State.isJumpTriggered = false;
            State.isJumping = true;

            Current.jumpCount++;
        }

        // 2. XZ 이동속도 계산
        // 공중에서 전방이 막힌 경우 제한 (지상에서는 벽에 붙어서 이동할 수 있도록 허용)
        if (State.isForwardBlocked && !State.isGrounded || State.isJumping && State.isGrounded) 
        {
            DebugMark(2);

            Current.horizontalVelocity = Vector3.zero;
        }
        else // 이동 가능한 경우 : 지상 or 전방이 막히지 않음
        {
            DebugMark(3);

            float speed = !State.isMoving  ? 0f :
                          !State.isRunning ? MOption.speed :
                                             MOption.speed * MOption.runningCoef;

            Current.horizontalVelocity = Current.worldMoveDir * speed;
        }

        // 3. XZ 벡터 회전
        // 지상이거나 지면에 가까운 높이
        if (State.isGrounded || Current.groundDistance < COption.groundCheckDistance && !State.isJumping)
        {
            if (State.isMoving && !State.isForwardBlocked)
            {
                DebugMark(4);

                // 경사로 인한 가속/감속
                if (MOption.slopeAccel > 0f)
                {
                    bool isPlus = Current.forwardSlopeAngle >= 0f;
                    float absFsAngle = isPlus ? Current.forwardSlopeAngle : -Current.forwardSlopeAngle;
                    float accel = MOption.slopeAccel * absFsAngle * 0.01111f + 1f;
                    Current.slopeAccel = !isPlus ? accel : 1.0f / accel;

                    Current.horizontalVelocity *= Current.slopeAccel;
                }

                // 벡터 회전 (경사로)
                Current.horizontalVelocity =
                    Quaternion.AngleAxis(-Current.groundSlopeAngle, Current.groundCross) * Current.horizontalVelocity;
            }
        }

        GzUpdateValue(ref _gzRotatedWorldMoveDir, Current.horizontalVelocity * 0.2f);
    }

    /// <summary> 리지드바디 최종 속도 적용 </summary>
    private void ApplyMovementsToRigidbody()
    {
        if (State.isOutOfControl)
        {
            Com.rBody.velocity = new Vector3(Com.rBody.velocity.x, Current.gravity, Com.rBody.velocity.z);
            return;
        }

        Com.rBody.velocity = Current.horizontalVelocity + Vector3.up * (Current.gravity);
    }

    #endregion
    /***********************************************************************
    *                               Debugs
    ***********************************************************************/
    #region .

    public bool _debugOn;
    public int _debugIndex;

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    private void DebugMark(int index)
    {
        if(!_debugOn) return;
        Debug.Log("MARK - " + index);
        _debugIndex = index;
    }

    #endregion
    /***********************************************************************
    *                               Gizmos, GUI
    ***********************************************************************/
    #region .

    private Vector3 _gzGroundTouch;
    private Vector3 _gzForwardTouch;
    private Vector3 _gzRotatedWorldMoveDir;

    [Header("Gizmos Option")]
    public bool _showGizmos = true;

    [SerializeField, Range(0.01f, 2f)]
    private float _gizmoRadius = 0.05f;

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    private void OnDrawGizmos()
    {
        if (Application.isPlaying == false) return;
        if (!_showGizmos) return;

        Gizmos.color = Color.red;
        Gizmos.DrawSphere(_gzGroundTouch, _gizmoRadius);

        if (State.isForwardBlocked)
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawSphere(_gzForwardTouch, _gizmoRadius);
        }

        Gizmos.color = Color.blue;
        Gizmos.DrawLine(_gzGroundTouch - Current.groundCross, _gzGroundTouch + Current.groundCross);

        Gizmos.color = Color.black;
        Gizmos.DrawLine(transform.position, transform.position + _gzRotatedWorldMoveDir);

        Gizmos.color = new Color(0.5f, 1.0f, 0.8f, 0.8f);
        Gizmos.DrawWireSphere(CapsuleTopCenterPoint, _castRadius);
        Gizmos.DrawWireSphere(CapsuleBottomCenterPoint, _castRadius);
    }

    [System.Diagnostics.Conditional("UNITY_EDITOR")]
    private void GzUpdateValue<T>(ref T variable, in T value)
    {
        variable = value;
    }



    [SerializeField, Space]
    private bool _showGUI = true;
    [SerializeField]
    private int _guiTextSize = 28;

    private float _prevForwardSlopeAngle;

    private void OnGUI()
    {
        if(!_showGUI) return;

        GUIStyle labelStyle = GUI.skin.label;
        labelStyle.normal.textColor = Color.yellow;
        labelStyle.fontSize = Math.Max(_guiTextSize, 20);

        _prevForwardSlopeAngle = Current.forwardSlopeAngle == -90f ? _prevForwardSlopeAngle : Current.forwardSlopeAngle;

        var oldColor = GUI.color;
        GUI.color = new Color(0f, 0f, 0f, 0.5f);
        GUI.Box(new Rect(40, 40, 420, 260), "");
        GUI.color = oldColor;

        GUILayout.BeginArea(new Rect(50, 50, 1000, 500));
        GUILayout.Label($"Ground Height : {Mathf.Min(Current.groundDistance, 99.99f): 00.00}", labelStyle);
        GUILayout.Label($"Slope Angle(Ground)  : {Current.groundSlopeAngle: 00.00}", labelStyle);
        GUILayout.Label($"Slope Angle(Forward) : {_prevForwardSlopeAngle: 00.00}", labelStyle);
        GUILayout.Label($"Allowed Slope Angle : {MOption.maxSlopeAngle: 00.00}", labelStyle);
        GUILayout.Label($"Current Slope Accel : {Current.slopeAccel: 00.00}", labelStyle);
        GUILayout.Label($"Current Speed Mag  : {Current.horizontalVelocity.magnitude: 00.00}", labelStyle);
        GUILayout.EndArea();

        float sWidth = Screen.width;
        float sHeight = Screen.height;

        GUIStyle RTLabelStyle = GUI.skin.label;
        RTLabelStyle.fontSize = 20;
        RTLabelStyle.normal.textColor = Color.green;

        oldColor = GUI.color;
        GUI.color = new Color(1f, 1f, 1f, 0.5f);
        GUI.Box(new Rect(sWidth - 355f, 5f, 340f, 100f), "");
        GUI.color = oldColor;

        float yPos = 10f;
        GUI.Label(new Rect(sWidth - 350f, yPos, 150f, 30f), $"Speed : {MOption.speed: 00.00}", RTLabelStyle);
        MOption.speed = GUI.HorizontalSlider(new Rect(sWidth - 200f, yPos+10f, 180f, 20f), MOption.speed, 1f, 10f);

        yPos += 20f;
        GUI.Label(new Rect(sWidth - 350f, yPos, 150f, 30f), $"Jump : {MOption.jumpForce: 00.00}", RTLabelStyle);
        MOption.jumpForce = GUI.HorizontalSlider(new Rect(sWidth - 200f, yPos+ 10f, 180f, 20f), MOption.jumpForce, 1f, 10f);

        yPos += 20f;
        GUI.Label(new Rect(sWidth - 350f, yPos, 150f, 30f), $"Jump Count : {MOption.maxJumpCount: 0}", RTLabelStyle);
        MOption.maxJumpCount = (int)GUI.HorizontalSlider(new Rect(sWidth - 200f, yPos+ 10f, 180f, 20f), MOption.maxJumpCount, 1f, 3f);

        yPos += 20f;
        GUI.Label(new Rect(sWidth - 350f, yPos, 150f, 30f), $"Max Slope : {MOption.maxSlopeAngle: 00}", RTLabelStyle);
        MOption.maxSlopeAngle = (int)GUI.HorizontalSlider(new Rect(sWidth - 200f, yPos+ 10f, 180f, 20f), MOption.maxSlopeAngle, 1f, 75f);

        labelStyle.fontSize = Math.Max(_guiTextSize, 20);
    }

    #endregion
}
```

</details>

<br>

# 구현 결과
---

## [1] 3인칭 뷰

![2021_0226_PBM1](https://user-images.githubusercontent.com/42164422/109312876-e653be80-788a-11eb-90b6-f2f815b129f0.gif)

![2021_0226_PBM2](https://user-images.githubusercontent.com/42164422/109312918-f370ad80-788a-11eb-87bb-d4b9c7b0050c.gif)

![2021_0226_PBM3](https://user-images.githubusercontent.com/42164422/109312947-fe2b4280-788a-11eb-8be4-964f8bc1f42f.gif)

![2021_0226_PBM4](https://user-images.githubusercontent.com/42164422/109312957-008d9c80-788b-11eb-9ef1-963026727302.gif)

![2021_0226_PBM5](https://user-images.githubusercontent.com/42164422/109312963-02576000-788b-11eb-8348-cfcd8757a778.gif)

![2021_0226_PBM6](https://user-images.githubusercontent.com/42164422/109312969-04212380-788b-11eb-92bf-22f72f1ce251.gif)

<br>

## [2] 1인칭 뷰

![2021_0226_PBM_FP_1](https://user-images.githubusercontent.com/42164422/109314538-d4731b00-788c-11eb-8815-3f5f47ac8d03.gif)

![2021_0226_PBM_FP_2](https://user-images.githubusercontent.com/42164422/109314546-d6d57500-788c-11eb-895e-31797cfa4a91.gif)

![2021_0226_PBM_FP_3](https://user-images.githubusercontent.com/42164422/109314552-d937cf00-788c-11eb-9015-678b25cdba6e.gif)
