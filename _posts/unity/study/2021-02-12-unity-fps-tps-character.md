---
title: 1인칭, 3인칭 전환 가능한 캐릭터 제작하기
author: Rito15
date: 2021-02-12 18:06:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, fps, tps, controller]
math: true
mermaid: true
---

# 목차
---
- [1. 하이라키 구성](#하이라키-구성하기)
- [2. 스크립트 기초](#스크립트-기초-작성)
- [3. 1인칭 이동, 회전](#1인칭-이동-회전-구현)
- [4. 3인칭 이동, 회전](#3인칭-이동-회전-구현)
- [5. 카메라 전환](#카메라-전환-기능-구현)
- [6. 점프](#점프-구현)
- [7. 애니메이션 적용](#애니메이션-적용하기)
- [8. 애니메이션 블렌딩](#애니메이션-블렌딩)
- [9. 카메라 전환 시 시점 방향 유지하기](#카메라-전환-시-시점-방향-유지하기)
- [10. 3인칭 카메라 줌 구현](#3인칭-카메라-줌-구현하기)
- [11. 점프 버그 수정](#점프-버그-수정하기)
- [12. 이동 스크립트 분리하기](#이동-스크립트-분리하기)
- [13. 소스 코드](#source-code)

<br>

# 하이라키 구성하기
---

![image](https://user-images.githubusercontent.com/42164422/107759975-66970180-6d6c-11eb-87f7-d712112f6a90.png){:.normal}

위와 같이 캐릭터의 하이라키를 구성한다.

따로 지정하지 않는 이상,

모든 게임오브젝트는 Position(0, 0, 0), Rotation(0, 0, 0), Scale(1, 1, 1)로 초깃값을 지정한다.

이동에 사용할 캐릭터의 예시로 유니티짱(UnityChan) 모델을 사용하였다.

## Character Root
- 실제로 이동할 게임오브젝트
- 1인칭, 3인칭 이동 담당
- Capsule Collider 컴포넌트 : 캐릭터의 규격에 맞추어 콜라이더 영역을 조절한다.
- Rigidbody 컴포넌트 : 캐릭터의 이동을 물리 기반으로 구현할 것이므로 리지드바디를 사용한다. 트랜스폼을 직접 이용하거나 캐릭터 컨트롤러, 혹은 외부 클래스를 사용할 경우 필요하지 않다.

## TP Camera Rig
- 빈 게임오브젝트
- 3인칭 상하, 좌우 회전 담당
- Position(0, 1, 0), Rotation(45, 0, 0) 설정

## TP Camera
- 3인칭 카메라
- Camera 컴포넌트 존재
- Position(0, 0, -4) 설정

## FP Root
- 빈 게임오브젝트
- 1인칭 좌우 회전 담당

## FP Camera Rig
- 빈 게임오브젝트
- 1인칭 상하 회전 담당
- Position의 Y값은 눈높이에 오도록 높이고, Z 값은 0.1~0.2 정도로 설정

## FP Camera
- 1인칭 카메라
- Camera 컴포넌트 존재

## unitychan
- 캐릭터 모델을 위치시킨다.
- Animator 컴포넌트 존재 (Apply Root Motion 체크 해제)

<br>

# 스크립트 기초 작성
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public class CharacterMainController : MonoBehaviour
{
    /***********************************************************************
    *                               Definitions
    ***********************************************************************/
    #region .
    public enum CameraType { FpCamera, TpCamera };

    [Serializable]
    public class Components
    {
        public Camera tpCamera;
        public Camera fpCamera;

        [HideInInspector] public Transform tpRig;
        [HideInInspector] public Transform fpRoot;
        [HideInInspector] public Transform fpRig;

        [HideInInspector] public GameObject tpCamObject;
        [HideInInspector] public GameObject fpCamObject;

        [HideInInspector] public Rigidbody rBody;
        [HideInInspector] public Animator anim;
    }
    [Serializable]
    public class KeyOption
    {
        public KeyCode moveForward  = KeyCode.W;
        public KeyCode moveBackward = KeyCode.S;
        public KeyCode moveLeft     = KeyCode.A;
        public KeyCode moveRight    = KeyCode.D;
        public KeyCode run  = KeyCode.LeftShift;
        public KeyCode jump = KeyCode.Space;
        public KeyCode switchCamera = KeyCode.Tab;
        public KeyCode showCursor = KeyCode.LeftAlt;
    }
    [Serializable]
    public class MovementOption
    {
        [Range(1f, 10f), Tooltip("이동속도")]
        public float speed = 3f;
        [Range(1f, 3f), Tooltip("달리기 이동속도 증가 계수")]
        public float runningCoef = 1.5f;
        [Range(1f, 10f), Tooltip("점프 강도")]
        public float jumpForce = 5.5f;
    }
    [Serializable]
    public class CameraOption
    {
        [Tooltip("게임 시작 시 카메라")]
        public CameraType initialCamera;
        [Range(1f, 10f), Tooltip("카메라 상하좌우 회전 속도")]
        public float rotationSpeed = 2f;
        [Range(-90f, 0f), Tooltip("올려다보기 제한 각도")]
        public float lookUpDegree = -60f;
        [Range(0f, 75f), Tooltip("내려다보기 제한 각도")]
        public float lookDownDegree = 75f;
    }
    [Serializable]
    public class AnimatorOption
    {
        public string paramMoveX = "Move X";
        public string paramMoveY = "Move Y";
        public string paramMoveZ = "Move Z";
    }
    [Serializable]
    public class CharacterState
    {
        public bool isCurrentFp;
        public bool isMoving;
        public bool isRunning;
        public bool isGrounded;
    }

    #endregion
    /***********************************************************************
    *                               Fields, Properties
    ***********************************************************************/
    #region .
    public Components Com => _components;
    public KeyOption Key => _keyOption;
    public MovementOption MoveOption => _movementOption;
    public CameraOption   CamOption  => _cameraOption;
    public AnimatorOption AnimOption => _animatorOption;
    public CharacterState State => _state;

    [SerializeField] private Components _components = new Components();
    [Space]
    [SerializeField] private KeyOption _keyOption = new KeyOption();
    [Space]
    [SerializeField] private MovementOption _movementOption = new MovementOption();
    [Space]
    [SerializeField] private CameraOption   _cameraOption   = new CameraOption();
    [Space]
    [SerializeField] private AnimatorOption _animatorOption = new AnimatorOption();
    [Space]
    [SerializeField] private CharacterState _state = new CharacterState();

    private Vector3 _moveDir;
    private Vector3 _worldMove;
    private Vector2 _rotation;

    #endregion

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Awake()
    {
        InitComponents();
        InitSettings();
    }

    #endregion
    /***********************************************************************
    *                               Init Methods
    ***********************************************************************/
    #region .
    private void InitComponents()
    {
        LogNotInitializedComponentError(Com.tpCamera, "TP Camera");
        LogNotInitializedComponentError(Com.fpCamera, "FP Camera");
        TryGetComponent(out Com.rBody);
        Com.anim = GetComponentInChildren<Animator>();

        Com.tpCamObject = Com.tpCamera.gameObject;
        Com.tpRig = Com.tpCamera.transform.parent;
        Com.fpCamObject = Com.fpCamera.gameObject;
        Com.fpRig = Com.fpCamera.transform.parent;
        Com.fpRoot = Com.fpRig.parent;
    }

    private void InitSettings()
    {
        // Rigidbody
        if (Com.rBody)
        {
            // 회전은 트랜스폼을 통해 직접 제어할 것이기 때문에 리지드바디 회전은 제한
            Com.rBody.constraints = RigidbodyConstraints.FreezeRotation;
        }

        // Camera
        var allCams = FindObjectsOfType<Camera>();
        foreach (var cam in allCams)
        {
            cam.gameObject.SetActive(false);
        }
        // 설정한 카메라 하나만 활성화
        State.isCurrentFp = (CamOption.initialCamera == CameraType.FpCamera);
        Com.fpCamObject.SetActive(State.isCurrentFp);
        Com.tpCamObject.SetActive(!State.isCurrentFp);
    }

    #endregion
    /***********************************************************************
    *                               Checker Methods
    ***********************************************************************/
    #region .
    private void LogNotInitializedComponentError<T>(T component, string componentName) where T : Component
    {
        if(component == null)
            Debug.LogError($"{componentName} 컴포넌트를 인스펙터에 넣어주세요");
    }

    #endregion
    /***********************************************************************
    *                               Methods
    ***********************************************************************/
    #region .

    #endregion
}
```

</details>

위처럼 1인칭/3인칭 캐릭터 구현에 필요한 기초를 작성한다.

그리고 인스펙터에서 TP Camera, FP Camera를 드래그하여 초기화한다.

<br>

# 1인칭 이동, 회전 구현
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
/// <summary> 키보드 입력을 통해 필드 초기화 </summary>
private void SetValuesByKeyInput()
{
    float h = 0f, v = 0f;

    if (Input.GetKey(Key.moveForward)) v += 1.0f;
    if (Input.GetKey(Key.moveBackward)) v -= 1.0f;
    if (Input.GetKey(Key.moveLeft)) h -= 1.0f;
    if (Input.GetKey(Key.moveRight)) h += 1.0f;

    Vector3 moveInput = new Vector3(h, 0f, v).normalized;
    _moveDir = Vector3.Lerp(_moveDir, moveInput, MoveOption.acceleration); // 가속, 감속
    _rotation = new Vector2(Input.GetAxisRaw("Mouse X"), -Input.GetAxisRaw("Mouse Y"));

    State.isMoving = _moveDir.sqrMagnitude > 0.01f;
    State.isRunning = Input.GetKey(Key.run);
}

/// <summary> 1인칭 회전 </summary>
private void Rotate()
{
    float deltaCoef = Time.deltaTime * 50f;

    // 상하 : FP Rig 회전
    float xRotPrev = Com.fpRig.localEulerAngles.x;
    float xRotNext = xRotPrev + _rotation.y
        * CamOption.rotationSpeed * deltaCoef;

    if (xRotNext > 180f)
        xRotNext -= 360f;

    // 좌우 : FP Root 회전
    float yRotPrev = Com.fpRoot.localEulerAngles.y;
    float yRotNext =
        yRotPrev + _rotation.x
        * CamOption.rotationSpeed * deltaCoef;

    // 상하 회전 가능 여부
    bool xRotatable =
        CamOption.lookUpDegree < xRotNext &&
        CamOption.lookDownDegree > xRotNext;

    // FP Rig 상하 회전 적용
    Com.fpRig.localEulerAngles = Vector3.right * (xRotatable ? xRotNext : xRotPrev);

    // FP Root 좌우 회전 적용
    Com.fpRoot.localEulerAngles = Vector3.up * yRotNext;
}

private void Move()
{
    // 이동하지 않는 경우, 미끄럼 방지
    if (State.isMoving == false)
    {
        Com.rBody.velocity = new Vector3(0f, Com.rBody.velocity.y, 0f);
        return;
    }

    // 실제 이동 벡터 계산
    _worldMove = Com.fpRoot.TransformDirection(_moveDir);
    _worldMove *= (MoveOption.speed) * (State.isRunning ? MoveOption.runningCoef : 1f);

    // Y축 속도는 유지하면서 XZ평면 이동
    Com.rBody.velocity = new Vector3(_worldMove.x, Com.rBody.velocity.y, _worldMove.z);
}

private void Update()
{
    SetValuesByKeyInput();
    Rotate();
    Move();
}
```

</details>

## 키보드 입력 처리
- SetValuesByKeyInput() 메소드
- 지정한 이동 키(기본 WASD)를 누를 경우 이동 방향 벡터(_moveDir)를 정규화된 값으로 초기화한다.
- 마우스를 이동할 경우 수평, 수직 이동 입력값을 _rotation 벡터의 x, y에 각각 초기화한다.
- 이동, 달리기 입력을 통해 isMoving, isRunning 상태를 초기화한다.

## 회전
- Rotate() 메소드
- 상하 회전은 캐릭터 모델에 영향을 주지 않기 위해 FP Rig 트랜스폼의 로컬 회전 X값을 조정한다.
- 그런데 트랜스폼의 Rotation 값은 0보다 낮아질 경우 자동적으로 360이 더해진다.
- 상하 회전 제한각도를 계산할 때 올바르게 계산될 수 있도록 해당 경우에는 다시 360을 빼준다.

- 좌우 회전은 FP Root 트랜스폼의 로컬 회전 Y값을 조정한다.
- 캐릭터 루트를 직접 회전시킨다면 3인칭 카메라에 영향을 주기 때문에 이렇게 분리하여 회전시킨다.

## 이동
- Move() 메소드
- 실제 캐릭터의 이동 방향은 FP Root 트랜스폼 기준으로 공간변환하여 결정한다.
- 필드를 통해 지정한 이동속도와 현재 달리기 키 입력 여부에 따른 달리기 계수를 이용해 최종 이동속도를 결정한다.
- 속도는 리지드바디 AddForce() 대신 velocity 값을 직접 조정하는 방식을 사용하여, 속도를 정확한 값으로 제어한다.

## 추가 : 커서 보이기/숨기기
- 커서를 보이거나 보이지 않게 하는 토글 기능을 키보드를 통해 동작할 수 있도록 한다.

```cs
private void ShowCursorToggle()
{
    if (Input.GetKeyDown(Key.showCursor))
        State.isCursorActive = !State.isCursorActive;

    ShowCursor(State.isCursorActive);
}

private void ShowCursor(bool value)
{
    Cursor.visible = value;
    Cursor.lockState = value ? CursorLockMode.None : CursorLockMode.Locked;
}

private void Update()
{
    ShowCursorToggle();

    // .. codes
}
```

## 구현 결과

- 게임 뷰

![2012_0213_FPMove](https://user-images.githubusercontent.com/42164422/107796758-8eeb2400-6d9d-11eb-84a2-eccd2043d3b6.gif){:.normal}

- 씬 뷰

![2012_0213_FPMove2](https://user-images.githubusercontent.com/42164422/107796777-93174180-6d9d-11eb-8cf9-5a66d28a67aa.gif){:.normal}

<br>

# 3인칭 이동, 회전 구현
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private void Rotate()
{
    if (State.isCurrentFp)
    {
        if(!State.isCursorActive)
            RotateFP();
    }
    else
    {
        if (!State.isCursorActive)
            RotateTP();
        RotateFPRoot();
    }
}

/// <summary> 1인칭 회전 </summary>
private void RotateFP()
{
    float deltaCoef = Time.deltaTime * 50f;

    // 상하 : FP Rig 회전
    float xRotPrev = Com.fpRig.localEulerAngles.x;
    float xRotNext = xRotPrev + _rotation.y
        * CamOption.rotationSpeed * deltaCoef;

    if (xRotNext > 180f)
        xRotNext -= 360f;

    // 좌우 : FP Root 회전
    float yRotPrev = Com.fpRoot.localEulerAngles.y;
    float yRotNext =
        yRotPrev + _rotation.x
        * CamOption.rotationSpeed * deltaCoef;

    // 상하 회전 가능 여부
    bool xRotatable =
        CamOption.lookUpDegree < xRotNext &&
        CamOption.lookDownDegree > xRotNext;

    // FP Rig 상하 회전 적용
    Com.fpRig.localEulerAngles = Vector3.right * (xRotatable ? xRotNext : xRotPrev);

    // FP Root 좌우 회전 적용
    Com.fpRoot.localEulerAngles = Vector3.up * yRotNext;
}

/// <summary> 3인칭 회전 </summary>
private void RotateTP()
{
    float deltaCoef = Time.deltaTime * 50f;

    // 상하 : TP Rig 회전
    float xRotPrev = Com.tpRig.localEulerAngles.x;
    float xRotNext = xRotPrev + _rotation.y
        * CamOption.rotationSpeed * deltaCoef;

    if (xRotNext > 180f)
        xRotNext -= 360f;

    // 좌우 : TP Rig 회전
    float yRotPrev = Com.tpRig.localEulerAngles.y;
    float yRotNext =
        yRotPrev + _rotation.x
        * CamOption.rotationSpeed * deltaCoef;

    // 상하 회전 가능 여부
    bool xRotatable =
        CamOption.lookUpDegree < xRotNext &&
        CamOption.lookDownDegree > xRotNext;

    Vector3 nextRot = new Vector3
    (
        xRotatable ? xRotNext : xRotPrev,
        yRotNext,
        0f
    );

    // TP Rig 회전 적용
    Com.tpRig.localEulerAngles = nextRot;
}

/// <summary> 3인칭일 경우 FP Root 회전 </summary>
private void RotateFPRoot()
{
    if (State.isMoving == false) return;

    Vector3 dir = Com.tpRig.TransformDirection(_moveDir);
    float currentY = Com.fpRoot.localEulerAngles.y;
    float nextY = Quaternion.LookRotation(dir, Vector3.up).eulerAngles.y;

    if (nextY - currentY > 180f) nextY -= 360f;
    else if (currentY - nextY > 180f) nextY += 360f;

    Com.fpRoot.eulerAngles = Vector3.up * Mathf.Lerp(currentY, nextY, 0.1f);
}

private void Move()
{
    // 이동하지 않는 경우, 미끄럼 방지
    if (State.isMoving == false)
    {
        Com.rBody.velocity = new Vector3(0f, Com.rBody.velocity.y, 0f);
        return;
    }

    // 실제 이동 벡터 계산
    // 1인칭
    if (State.isCurrentFp)
    {
        _worldMove = Com.fpRoot.TransformDirection(_moveDir);
    }
    // 3인칭
    else
    {
        _worldMove = Com.tpRig.TransformDirection(_moveDir);
    }

    _worldMove *= (MoveOption.speed) * (State.isRunning ? MoveOption.runningCoef : 1f);

    // Y축 속도는 유지하면서 XZ평면 이동
    Com.rBody.velocity = new Vector3(_worldMove.x, Com.rBody.velocity.y, _worldMove.z);
}

private void Update()
{
    ShowCursorToggle();
    SetValuesByKeyInput();
    Rotate();
    Move();
}
```

</details>

- 게임 시작 전, 인스펙터의 Camera Option - Initial Camera를 [Fp Camera]로 지정한다.
- 회전, 이동 코드를 위처럼 수정한다.

## 회전
- 1인칭 회전은 기존 구현을 그대로 사용한다.
- 3인칭 회전은 1인칭 회전과 비슷하지만 약간 다르게, TP Rig 게임오브젝트가 상하, 좌우 회전을 모두 담당한다.
- 게임 내에서 커서가 보일 경우에는 회전하지 않도록 한다.
- 그리고 3인칭 시점에서는 이동할 때 FP Root가 이동방향을 바라보도록 RotateFPRoot() 메소드를 구현한다.

## 이동
- _worldMove 벡터는 1인칭, 3인칭 뷰에 따라 각각 fpRoot, tpRig 트랜스폼을 기준으로 월드 벡터를 계산하여 실제 이동 방향 벡터로 사용한다.

## 구현 결과

![2012_0213_TPMove2](https://user-images.githubusercontent.com/42164422/107802244-6c103e00-6da4-11eb-92ae-8b2404683ab2.gif){:.normal}

<br>

# 카메라 전환 기능 구현
---

```cs
private void CameraViewToggle()
{
    if (Input.GetKeyDown(Key.switchCamera))
    {
        State.isCurrentFp = !State.isCurrentFp;
        Com.fpCamObject.SetActive(State.isCurrentFp);
        Com.tpCamObject.SetActive(!State.isCurrentFp);
    }
}

private void Update()
{
    ShowCursorToggle();
    CameraViewToggle();
    SetValuesByKeyInput();
    Rotate();
    Move();
}
```

- 카메라 전환 키(기본 Tab)를 눌러 1인칭과 3인칭 카메라를 전환할 수 있도록 위처럼 작성한다.

<br>

# 점프 구현
---

캐릭터가 지상에 있는지, 공중에 있는지 여부를 항상 검사해야 한다.

MovementOption 클래스에 다음을 추가한다.

```cs
[Tooltip("지면으로 체크할 레이어 설정")]
public LayerMask groundLayerMask = -1;
```

Raycast 대신 SphereCast를 통해 검사할 것이기 때문에, 반지름 정보가 필요하다.

캡슐 콜라이더를 사용하므로 이를 이용한다.

필드로 float _groundCheckRadius를 추가하고,

InitSettings() 메소드 하단에 아래처럼 추가로 작성한다.

```cs
private float _groundCheckRadius;

private void InitSettings()
{
    // .. codes

    TryGetComponent(out CapsuleCollider cCol);
    _groundCheckRadius = cCol ? cCol.radius : 0.1f;
}
```

그리고 지면으로부터의 거리를 검사하여 저장하기 위한

float _distFromGround 필드를 추가하고, 아래의 메소드를 작성한다.

```cs
/// <summary> 땅으로부터의 거리 체크 </summary>
private void CheckDistanceFromGround()
{
    Vector3 ro = transform.position + Vector3.up;
    Vector3 rd = Vector3.down;
    Ray ray = new Ray(ro, rd);

    const float rayDist = 500f;
    const float threshold = 0.01f;

    bool cast =
        Physics.SphereCast(ray, _groundCheckRadius, out var hit, rayDist, MoveOption.groundLayerMask);

    _distFromGround = cast ? (hit.distance - 1f + _groundCheckRadius) : float.MaxValue;
    State.isGrounded = _distFromGround <= _groundCheckRadius + threshold;
}
```

이제 캐릭터가 지면에 닿아있을 때만 점프하도록 Jump() 메소드를 작성하고,

Update()에서 호출하도록 한다.

```cs
private void Jump()
{
    if (!State.isGrounded) return;

    if (Input.GetKeyDown(Key.jump))
    {
        Com.rBody.AddForce(Vector3.up * MoveOption.jumpForce, ForceMode.VelocityChange);
    }
}

private void Update()
{
    ShowCursorToggle();
    CameraViewToggle();
    SetValuesByKeyInput();
    CheckDistanceFromGround();

    Rotate();
    Move();
    Jump();
}
```

## 구현 결과

![2012_0213_Jump](https://user-images.githubusercontent.com/42164422/107806031-90bae480-6da9-11eb-93a5-89e40a9d954f.gif){:.normal}

<br>

# 애니메이션 적용하기
---

각각의 행동에 맞는 애니메이션을 재생하기 위해 애니메이터 컨트롤러를 만들고, 애니메이션 클립을 통해 애니메이션 상태들을 만들어 서로 연결한다.

![image](https://user-images.githubusercontent.com/42164422/108347546-faad1100-7223-11eb-963b-5c4fbb11417f.png){:.normal}

그러면 보통 이런 형태가 된다.

하지만 이동 애니메이션이 이동 방향에 따라 MoveForward, MoveLeft, MoveRight, MoveBackward 이렇게 나뉘어 있다면

![image](https://user-images.githubusercontent.com/42164422/108347908-76a75900-7224-11eb-91e6-31e8b2a25a79.png){:.normal}

이렇게 마법진을 만들 수 있다.

이런 트랜지션 지옥을 피하기 위해서는 애니메이션 블렌딩을 이용해야 한다.

<br>

# 애니메이션 블렌딩
---

## 애니메이션 파라미터 정의

애니메이션 블렌딩을 하기 전에, 애니메이터 내에서 사용할 파라미터들을 정의한다.

![image](https://user-images.githubusercontent.com/42164422/108348386-1369f680-7225-11eb-9db9-08f884d12649.png){:.normal}

|이름|타입|설명|
|---|---|---|
|Move X|Float|로컬 X축 방향 이동 속도|
|Move Z|Float|로컬 Z축 방향 이동 속도|
|Dist Y|Float|캐릭터와 지면 사이의 Y축 거리|
|Grounded|Bool|캐릭터가 땅과 닿아 있는지 여부|
|Jump|Trigger|점프 명령|

그리고 스크립트에서 해당 파라미터 이름들을 변수로 지정할 수 있도록 이를 관리하는 클래스를 만든다.

```cs
public class AnimatorOption
{
    public string paramMoveX = "Move X";
    public string paramMoveZ = "Move Z";
    public string paramDistY = "Dist Y";
    public string paramGrounded = "Grounded";
    public string paramJump = "Jump";
}

public AnimatorOption AnimOption => _animatorOption;

[Space]
[SerializeField] private AnimatorOption _animatorOption = new AnimatorOption();
```

애니메이션 파라미터들을 전달하기 위한 메소드를 작성한다.

```cs
// Lerp를 위한 변수들
private float _moveX;
private float _moveZ;

private void UpdateAnimationParams()
{
    float x, z;

    if (State.isCurrentFp)
    {
        x = _moveDir.x;
        z = _moveDir.z;

        if (State.isRunning)
        {
            x *= 2f;
            z *= 2f;
        }
    }
    else
    {
        x = 0f;
        z = _moveDir.sqrMagnitude > 0f ? 1f : 0f;

        if (State.isRunning)
        {
            z *= 2f;
        }
    }

    // 보간
    const float LerpSpeed = 0.05f;
    _moveX = Mathf.Lerp(_moveX, x, LerpSpeed);
    _moveZ = Mathf.Lerp(_moveZ, z, LerpSpeed);

    Com.anim.SetFloat(AnimOption.paramMoveX, _moveX);
    Com.anim.SetFloat(AnimOption.paramMoveZ, _moveZ);
    Com.anim.SetFloat(AnimOption.paramDistY, _distFromGround);
    Com.anim.SetBool(AnimOption.paramGrounded, State.isGrounded);
}
```

1인칭에서는 전후좌우 모두 이동하지만, 3인칭에서는 어차피 이동방향으로 항상 바라보므로 전방 이동 애니메이션만 적용하면 된다.

따라서 3인칭의 경우 Move Z에 이동 시 1, 정지 시 0을 전달하면 된다.

애니메이션은 각 파라미터에 의존하여 실행되므로, 0과 1만 전달하면 뚝뚝 끊기므로 Move X, Z는 Lerp 계산을 통해 부드럽게 보간하여 전달한다.

그리고 Update() 맨 아래에서 위의 메소드를 호출한다.

<br>

## IDLE_MOVE 블렌드 트리 생성

애니메이터 컨트롤러에서 Create State - From New Blend Tree 를 통해 새로운 블렌드 트리를 만든다.

그리고 Idle 1개, Walk 4개(Front, Back, Left, Right), Run 4개 총 9개의 애니메이션을 준비한다.

각각의 Back 애니메이션이 존재하지 않을 경우, Front를 역재생하는 방식으로 사용할 수 있다.

2D Freeform Directional을 선택하여 아래처럼 블렌드 트리를 완성한다.

![image](https://user-images.githubusercontent.com/42164422/108351624-1ebf2100-7229-11eb-986f-30b744171ffe.png){:.normal}

- 실행 결과

![2021_0218_SmoothMove](https://user-images.githubusercontent.com/42164422/108353850-f4229780-722b-11eb-8788-85bf521225fc.gif){:.normal}

<br>

## 점프 애니메이션

정지 및 이동 애니메이션을 완성했으므로, 이제 점프 애니메이션도 적용해야 한다.

점프 애니메이션을 위한 고려사항들은 다음과 같다.

> - 점프할 때 [정지 -> 점프] 까지 부드럽게 연결되는 애니메이션이 재생되어야 한다.
> - 점프 이후, 착지하기 전까지 [최고점의 점프 애니메이션]이 반복 재생되어야 한다.
> - 착지할 때 [점프 -> 정지] 까지 부드럽게 연결되는 애니메이션이 재생되어야 한다.

그리고 이에 적용할 수 있는 애니메이션 파라미터들은 다음과 같다.

> - 점프하는 순간에 활성화시킬 Jump 트리거
> - 캐릭터와 지면 사이의 높이값 Dist Y (Float)
> - 캐릭터의 Y축 위치 상태를 나타내는 Grounded (Bool)


위의 요소들을 고려하여 애니메이션들을 준비한다.

- ### 1. Jump_Up

![2021_0218_Anim_Jump1](https://user-images.githubusercontent.com/42164422/108356998-3352e780-7230-11eb-9bb4-2d776b133e11.gif){:.normal}

- ### 2. Jump_Up_Loop

![2021_0218_Anim_Jump2](https://user-images.githubusercontent.com/42164422/108357003-351cab00-7230-11eb-978d-edd54f02a217.gif){:.normal}

- ### 3. Jump_Down

![2021_0218_Anim_Jump3](https://user-images.githubusercontent.com/42164422/108357005-35b54180-7230-11eb-800f-8d55dfb9aa46.gif){:.normal}

<br>

## JUMP_DOWN 블렌드 트리 생성

Jump_Up 애니메이션은 그대로 하나의 상태로 애니메이터에 넣는다.

Jump_Loop와 Jump_Down은 블렌드 트리로 묶고 1D로 설정, 파라미터는 Dist Y로 지정한다.

![image](https://user-images.githubusercontent.com/42164422/108358253-d7895e00-7231-11eb-973f-6c23502fb28c.png){:.normal}

<br>

## 트랜지션 설정

![image](https://user-images.githubusercontent.com/42164422/108544038-38e02880-7329-11eb-95e4-f267ab65603f.png){:.normal}

|트랜지션|조건|Has Exit Time|
|---|---|---|
|IDLE_MOVE->JUMP_UP|Jump(Trigger)|false|
|JUMP_UP->JUMP_DOWN|없음|true|
|JUMP_DOWN->JUMP_UP|Jump(Trigger)|false|
|JUMP_DOWN->IDLE_MOVE|Grounded == true|false|

<br>

## 실행 결과

- 평지에서의 점프

![2021_0218_JumpTest1](https://user-images.githubusercontent.com/42164422/108359420-5337da80-7233-11eb-8a85-5e51f97fb987.gif){:.normal}

- 고지에서 점프 후 하강

![2021_0218_JumpTest2](https://user-images.githubusercontent.com/42164422/108359426-55019e00-7233-11eb-8278-ea0b1533fbf9.gif){:.normal}

의도대로 동작하며, 부드럽게 이어진다.

<br>

# 카메라 전환 시 시점 방향 유지하기
---

탭 키를 눌러 1인칭, 3인칭 카메라를 서로 전환할 경우

![2021_0218_ChangeCamView](https://user-images.githubusercontent.com/42164422/108360636-cbeb6680-7234-11eb-99d6-74b9600178c5.gif){:.normal}

이렇게 각각의 카메라가 원래 향하고 있던 방향으로 돌아가서 보이게 된다.

카메라를 전환할 때 이전의 카메라가 보고 있던 방향을 전환 후 카메라가 바라볼 수 있게 하려고 한다.

```cs
private void CameraViewToggle()
{
    if (Input.GetKeyDown(Key.switchCamera))
    {
        State.isCurrentFp = !State.isCurrentFp;
        Com.fpCamObject.SetActive(State.isCurrentFp);
        Com.tpCamObject.SetActive(!State.isCurrentFp);

        // TP -> FP
        if (State.isCurrentFp)
        {
            Vector3 tpEulerAngle = Com.tpRig.localEulerAngles;
            Com.fpRig.localEulerAngles = Vector3.right * tpEulerAngle.x;
            Com.fpRoot.localEulerAngles = Vector3.up * tpEulerAngle.y;
        }
        // FP -> TP
        else
        {
            Vector3 newRot = default;
            newRot.x = Com.fpRig.localEulerAngles.x;
            newRot.y = Com.fpRoot.localEulerAngles.y;
            Com.tpRig.localEulerAngles = newRot;
        }
    }
}
```

CameraViewToggle() 메소드를 위와 같이 수정한다.

1인칭 시점에서는 fpRig 트랜스폼이 x 회전을, fpRoot 트랜스폼이 y 회전을 담당하고

3인칭 시점에서는 tpRig 트랜스폼이 x, y 회전을 모두 담당하므로

위처럼 나누어 전달한다.

## 실행 결과

![2021_0218_CamRotation](https://user-images.githubusercontent.com/42164422/108367406-c98d0a80-723c-11eb-877e-013a9df970a8.gif){:.normal}

카메라 전환 시 이전 카메라의 회전을 유지하는 것을 확인할 수 있다.

<br>

# 3인칭 카메라 줌 구현하기
---

3인칭 카메라 모드일 때만, 휠 입력을 받아서 카메라 줌 기능을 구현하려고 한다.

3인칭 카메라를 카메라가 바라보는 방향(transform.foward)으로 이동시키면 줌 인, 반대 방향으로 이동시키면 줌 아웃을 구현할 수 있다.

CameraOption 클래스에 다음처럼 필드를 작성한다.

```cs
[Range(0f, 3.5f), Space, Tooltip("줌 확대 최대 거리")]
public float zoomInDistance = 3f;

[Range(0f, 5f), Tooltip("줌 축소 최대 거리")]
public float zoomOutDistance = 3f;

[Range(1f, 20f), Tooltip("줌 속도")]
public float zoomSpeed = 10f;
```

그리고 스크립트 내에 필드를 더 추가한다.

```cs
/// <summary> TP 카메라 ~ Rig 초기 거리 </summary>
private float _tpCamZoomInitialDistance;

/// <summary> TP 카메라 휠 입력 값 </summary>
private float _tpCameraWheelInput = 0;
```

게임 시작 시 _tpCamZoomInitialDistance 필드에 TP Camera, TP Rig 사이의 거리를 측정하고 게임 내에서 해당 값을 기준으로 줌인/줌아웃 기능을 사용하게 된다.

InitSettings() 메소드 블록 내 최하단에 다음과 같이 작성하여 초기 줌 거리를 측정한다.

```cs
_tpCamZoomInitialDistance = Vector3.Distance(Com.tpRig.position, Com.tpCamera.transform.position);
```

그리고 SetValuesByKeyInput() 메소드 하단에도 마찬가지로 다음 한줄을 추가하여 휠 입력값을 받아오도록 한다.

```cs
_tpCameraWheelInput = Input.GetAxisRaw("Mouse ScrollWheel");
```

마지막으로 새로운 메소드를 작성하고, Update() 블록 내부 하단에서 호출해준다.

```cs
private void TpCameraZoom()
{
    if (State.isCurrentFp) return;         // TP 카메라만 가능
    if (_tpCameraWheelInput == 0f) return; // 휠 입력 있어야 가능

    Transform tpCamTr = Com.tpCamera.transform;
    Transform tpCamRig = Com.tpRig;

    float zoom = Time.deltaTime * CamOption.zoomSpeed;
    float currentCamToRigDist = Vector3.Distance(tpCamTr.position, tpCamRig.position);
    Vector3 move = Vector3.forward * zoom;

    // Zoom In
    if (_tpCameraWheelInput > 0.01f)
    {
        if (_tpCamZoomInitialDistance - currentCamToRigDist < CamOption.zoomInDistance)
        {
            tpCamTr.Translate(move, Space.Self);
        }
    }
    // Zoom Out
    else if (_tpCameraWheelInput < -0.01f)
    {

        if (currentCamToRigDist - _tpCamZoomInitialDistance < CamOption.zoomOutDistance)
        {
            tpCamTr.Translate(-move, Space.Self);
        }
    }
}
```
<br>

## 추가 : 부드러운 줌 구현하기

Lerp를 이용하여 부드러운 줌을 구현할 수 있다.

우선 CameraOption 클래스에 다음 필드를 추가한다.

```cs
[Range(0.01f, 0.5f), Tooltip("줌 가속")]
public float zoomAccel = 0.1f;
```

zoomAccel 값이 작을수록 줌이 부드럽게 연결되고, 더 오래 지속된다. 반대로 이 값이 클수록 줌이 더 빨라진다.

그리고 SetValuesByKeyInput() 메소드 하단의 줌 입력받는 문장을

```cs
_tpCameraWheelInput = Input.GetAxisRaw("Mouse ScrollWheel");
_currentWheel = Mathf.Lerp(_currentWheel, _tpCameraWheelInput, CamOption.zoomAccel);
```

이렇게 수정하고,

TpCameraZoom() 메소드를

```cs
private void TpCameraZoom()
{
    if (State.isCurrentFp) return;                // TP 카메라만 가능
    if (Mathf.Abs(_currentWheel) < 0.01f) return; // 휠 입력 있어야 가능

    Transform tpCamTr = Com.tpCamera.transform;
    Transform tpCamRig = Com.tpRig;

    float zoom = Time.deltaTime * CamOption.zoomSpeed;
    float currentCamToRigDist = Vector3.Distance(tpCamTr.position, tpCamRig.position);
    Vector3 move = Vector3.forward * zoom * _currentWheel * 10f;

    // Zoom In
    if (_currentWheel > 0.01f)
    {
        if (_tpCamZoomInitialDistance - currentCamToRigDist < CamOption.zoomInDistance)
        {
            tpCamTr.Translate(move, Space.Self);
        }
    }
    // Zoom Out
    else if (_currentWheel < -0.01f)
    {

        if (currentCamToRigDist - _tpCamZoomInitialDistance < CamOption.zoomOutDistance)
        {
            tpCamTr.Translate(move, Space.Self);
        }
    }
}
```

이렇게 수정해준다.

<br>
## 실행 결과

![2021_0220_FpTpZoom](https://user-images.githubusercontent.com/42164422/108523951-de879d80-7311-11eb-8d61-3cdee92dc206.gif){:.normal}

<br>

# 점프 버그 수정하기
---

## (깨알팁) Time.deltaTime 캐싱하기

이 스크립트에서는 Time.deltaTime을 여러 번 사용하므로, 매 Update마다 필드에 저장하여 공통으로 사용하도록 한다.

성능 상 이득을 얻을 수 있다.

```cs
private float _deltaTime;

private void Update()
{
    _deltaTime = Time.deltaTime;

    // ...
}
```

<br>

## 다중 점프 버그

![2021_0220_InfiniteJump](https://user-images.githubusercontent.com/42164422/108530888-691fcb00-7319-11eb-9c52-62675be3bba4.gif){:.normal}

지형을 이용하면 순간적으로 점프 입력키를 빠르게 연타하여 한 번에 많이 점프할 수 있다.

이를 고치기 위해서는 점프에 짧은 쿨타임을 부여하면 된다.



MovementOption 클래스 내에 점프 쿨타임을 지정할 필드를 만들어준다.

```cs
[Range(0.0f, 2.0f), Tooltip("점프 쿨타임")]
public float jumpCooldown = 1.0f;
```

그리고 현재 스크립트에 점프 쿨타임 지속시간을 기억할 필드를 추가한다.

```cs
private float _currentJumpCooldown;
```

Jump() 메소드를 다음처럼 수정한다.

```cs
private void Jump()
{
    if (!State.isGrounded) return;
    if (_currentJumpCooldown > 0f) return; // 점프 쿨타임

    if (Input.GetKeyDown(Key.jump))
    {
        Debug.Log("JUMP");

        // 하강 중 점프 시 속도가 합산되지 않도록 속도 초기화
        Com.rBody.velocity = Vector3.zero;

        Com.rBody.AddForce(Vector3.up * MoveOption.jumpForce, ForceMode.VelocityChange);

        // 애니메이션 점프 트리거
        Com.anim.SetTrigger(AnimOption.paramJump);

        // 쿨타임 초기화
        _currentJumpCooldown = MoveOption.jumpCooldown;
    }
}
```

점프 쿨타임에 걸려 있으면 점프가 불가능하도록 해주었고,

점프할 때 다시 쿨타임이 시작되록 하였다.

그리고 하강 중 점프할 때 점프가 제대로 되지 않는 버그도 추가로 수정해주었다.

이제 실시간으로 쿨타임을 계산해줄 메소드를 만들고, Update()에서 호출하도록 한다.

```cs
private void UpdateCurrentValues()
{
    if(_currentJumpCooldown > 0f)
        _currentJumpCooldown -= _deltaTime;
}

private void Update()
{
    // ...

    UpdateCurrentValues();
}
```

## 결과

![2021_0220_JumpFix](https://user-images.githubusercontent.com/42164422/108545079-ab9dd380-732a-11eb-8ab3-14177988221d.gif){:.normal}

이제 올바르게 점프할 수 있다.

<br>

# 이동 스크립트 분리하기
---

이동 기능은 Transform, Rigidbody, Character Controller, ... 등등 여러가지 방법으로 다양하게 구현할 수 있으며, 간단하게 구현할 수도, 아주 복잡하고 섬세하게 구현할 수도 있다.

이를 대비하여 이동 기능을 완전히 분리하여 다른 스크립트에 작성하고, 해당 스크립트(컴포넌트)에는 이동 명령 시 월드 이동 벡터, 점프 시 점프 여부만 간단히 전달하도록 캐릭터 메인 컨트롤러 스크립트를 수정한다.

그리고 월드 이동 벡터는 Y 값은 0으로 두고 XZ 값만 전달해야 하는데, 현재로서는 3인칭의 경우 상하 및 좌우 회전이 통합되어 있으므로 정확한 값을 전달할 수 없다.

따라서 하이라키 구조를 변경하고 회전 기능도 수정하였으며, 다음 포스팅에서 물리 기반 이동을 구현한다.

<br>

# Source Code
---

<details>
<summary markdown="span"> 
CharacterMainController.cs
</summary>

```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 날짜 : 2021-02-12 PM 7:45:19
// 작성자 : Rito

namespace Rito.CharacterControl
{
    public class CharacterMainController : MonoBehaviour
    {
        /*

            [하이라키 구조]

            Character Root [ CharacterMainController, Movement3D, Rigidbody, Capsule Collider ]
              ㄴTP Root    [ Pos(0,   1,   0) , Rot(0,  0, 0) ]
                ㄴTP Rig   [ Pos(0,   0,   0) , Rot(0, 45, 0) ]
                  ㄴTP Cam [ Pos(0,   0,  -4) , Rot(0,  0, 0), Camera Component ]
              ㄴWalker     [ Pos(0,   1,   0) , Rot(0,  0, 0) ]
                ㄴFP Rig   [ Pos(0, 1.3, 0.2) , Rot(0,  0, 0) ]
                  ㄴFP Cam [ Pos(0, 1.3, 0.2) , Rot(0,  0, 0), Camera Component ]
                ㄴModel Root

        */

        /***********************************************************************
        *                               Definitions
        ***********************************************************************/
        #region .
        public enum CameraType { FpCamera, TpCamera };

        [Serializable]
        public class Components
        {
            public Camera tpCamera;
            public Camera fpCamera;

            [HideInInspector] public Transform tpRoot;
            [HideInInspector] public Transform tpRig;
            [HideInInspector] public Transform walker;
            [HideInInspector] public Transform fpRig;

            [HideInInspector] public GameObject tpCamObject;
            [HideInInspector] public GameObject fpCamObject;

            [HideInInspector] public Animator anim;
            [HideInInspector] public IMovement3D movement3D;
        }
        [Serializable]
        public class KeyOption
        {
            public KeyCode moveForward  = KeyCode.W;
            public KeyCode moveBackward = KeyCode.S;
            public KeyCode moveLeft     = KeyCode.A;
            public KeyCode moveRight    = KeyCode.D;
            public KeyCode run  = KeyCode.LeftShift;
            public KeyCode jump = KeyCode.Space;
            public KeyCode switchCamera = KeyCode.Tab;
            public KeyCode showCursor = KeyCode.LeftAlt;
        }
        [Serializable]
        public class CameraOption
        {
            [Tooltip("게임 시작 시 카메라")]
            public CameraType initialCamera;

            [Range(1f, 10f), Tooltip("카메라 상하좌우 회전 속도")]
            public float rotationSpeed = 2f;

            [Range(-90f, 0f), Tooltip("올려다보기 제한 각도")]
            public float lookUpDegree = -60f;

            [Range(0f, 75f), Tooltip("내려다보기 제한 각도")]
            public float lookDownDegree = 75f;

            [Range(0f, 3.5f), Space, Tooltip("줌 확대 최대 거리")]
            public float zoomInDistance = 3f;

            [Range(0f, 5f), Tooltip("줌 축소 최대 거리")]
            public float zoomOutDistance = 3f;

            [Range(1f, 30f), Tooltip("줌 속도")]
            public float zoomSpeed = 20f;

            [Range(0.01f, 0.5f), Tooltip("줌 가속")]
            public float zoomAccel = 0.1f;
        }
        [Serializable]
        public class AnimatorOption
        {
            public string paramMoveX = "Move X";
            public string paramMoveZ = "Move Z";
            public string paramDistY = "Dist Y";
            public string paramGrounded = "Grounded";
            public string paramJump = "Jump";
        }
        [Serializable]
        public class CharacterState
        {
            public bool isCurrentFp;
            public bool isMoving;
            public bool isRunning;
            public bool isGrounded;
            public bool isCursorActive;
        }

        #endregion
        /***********************************************************************
        *                               Fields, Properties
        ***********************************************************************/
        #region .
        public Components Com => _components;
        public KeyOption Key => _keyOption;
        public CameraOption   CamOption  => _cameraOption;
        public AnimatorOption AnimOption => _animatorOption;
        public CharacterState State => _state;

        [SerializeField] private Components _components = new Components();
        [Space, SerializeField] private KeyOption _keyOption = new KeyOption();
        [Space, SerializeField] private CameraOption   _cameraOption   = new CameraOption();
        [Space, SerializeField] private AnimatorOption _animatorOption = new AnimatorOption();
        [Space, SerializeField] private CharacterState _state = new CharacterState();

        /// <summary> Time.deltaTime 항상 저장 </summary>
        private float _deltaTime;

        /// <summary> 마우스 움직임을 통해 얻는 회전 값 </summary>
        private Vector2 _rotation;


        [SerializeField]
        private float _distFromGround;

        // Animation Params
        private float _moveX;
        private float _moveZ;


        /// <summary> TP 카메라 ~ Rig 초기 거리 </summary>
        private float _tpCamZoomInitialDistance;

        /// <summary> TP 카메라 휠 입력 값 </summary>
        private float _tpCameraWheelInput = 0;

        /// <summary> 선형보간된 현재 휠 입력 값 </summary>
        private float _currentWheel;



        // Current Movement Variables

        /// <summary> 키보드 WASD 입력으로 얻는 로컬 이동 벡터 </summary>
        [SerializeField]
        private Vector3 _moveDir;

        /// <summary> 월드 이동 벡터 </summary>
        [SerializeField]
        private Vector3 _worldMoveDir;

        #endregion

        /***********************************************************************
        *                               Unity Events
        ***********************************************************************/
        #region .
        private void Start()
        {
            InitComponents();
            InitSettings();
        }

        private void Update()
        {
            _deltaTime = Time.deltaTime;

            // 1. Check, Key Input
            ShowCursorToggle();
            CameraViewToggle();
            SetValuesByKeyInput();

            // 2. Behaviors, Camera Actions
            Rotate();
            TpCameraZoom();

            // 3. Updates
            CheckGroundDistance();
            UpdateAnimationParams();
        }

        #endregion
        /***********************************************************************
        *                               Init Methods
        ***********************************************************************/
        #region .
        private void InitComponents()
        {
            LogNotInitializedComponentError(Com.tpCamera, "TP Camera");
            LogNotInitializedComponentError(Com.fpCamera, "FP Camera");
            
            Com.anim = GetComponentInChildren<Animator>();

            Com.tpCamObject = Com.tpCamera.gameObject;
            Com.tpRig = Com.tpCamera.transform.parent;
            Com.tpRoot = Com.tpRig.parent;

            Com.fpCamObject = Com.fpCamera.gameObject;
            Com.fpRig = Com.fpCamera.transform.parent;
            Com.walker = Com.fpRig.parent;

            TryGetComponent(out Com.movement3D);
            //if(Com.movement3D == null)
            //    Com.movement3D = gameObject.AddComponent<PhysicsBasedMovement>();
                //Com.pbMove = gameObject.AddComponent<Test.PBMove2>();
        }

        private void InitSettings()
        {
            // 모든 카메라 게임오브젝트 비활성화
            var allCams = FindObjectsOfType<Camera>();
            foreach (var cam in allCams)
            {
                cam.gameObject.SetActive(false);
            }

            // 설정한 카메라 하나만 활성화
            State.isCurrentFp = (CamOption.initialCamera == CameraType.FpCamera);
            Com.fpCamObject.SetActive(State.isCurrentFp);
            Com.tpCamObject.SetActive(!State.isCurrentFp);

            // Zoom
            _tpCamZoomInitialDistance = Vector3.Distance(Com.tpRig.position, Com.tpCamera.transform.position);
        }
        
        #endregion
        /***********************************************************************
        *                               Check Methods
        ***********************************************************************/
        #region .
        private void LogNotInitializedComponentError<T>(T component, string componentName) where T : Component
        {
            if(component == null)
                Debug.LogError($"{componentName} 컴포넌트를 인스펙터에 넣어주세요");
        }

        #endregion
        /***********************************************************************
        *                               Methods
        ***********************************************************************/
        #region .
        /// <summary> 키보드 입력을 통해 필드 초기화 </summary>
        private void SetValuesByKeyInput()
        {
            float h = 0f, v = 0f;

            if (Input.GetKey(Key.moveForward)) v += 1.0f;
            if (Input.GetKey(Key.moveBackward)) v -= 1.0f;
            if (Input.GetKey(Key.moveLeft)) h -= 1.0f;
            if (Input.GetKey(Key.moveRight)) h += 1.0f;

            // Move, Rotate
            SendMoveInfo(h, v);
            _rotation = new Vector2(Input.GetAxisRaw("Mouse X"), -Input.GetAxisRaw("Mouse Y"));

            State.isMoving = h != 0 || v != 0;
            State.isRunning = Input.GetKey(Key.run);

            // Jump
            if (Input.GetKeyDown(Key.jump))
            {
                Jump();
            }

            // Wheel
            _tpCameraWheelInput = Input.GetAxisRaw("Mouse ScrollWheel");
            _currentWheel = Mathf.Lerp(_currentWheel, _tpCameraWheelInput, CamOption.zoomAccel);
        }

        private void Rotate()
        {
            Transform root, rig;

            // 1인칭
            if (State.isCurrentFp)
            {
                root = Com.walker;
                rig = Com.fpRig;
            }
            // 3인칭
            else
            {
                root = Com.tpRoot;
                rig = Com.tpRig;
                RotateWalker(); // 3인칭일 경우 Walker를 이동방향으로 회전
            }
            
            if(State.isCursorActive) return;

            // 회전 ==========================================================
            float deltaCoef = _deltaTime * 50f;

            // 상하 : Rig 회전
            float xRotPrev = rig.localEulerAngles.x;
            float xRotNext = xRotPrev + _rotation.y
                * CamOption.rotationSpeed * deltaCoef;

            if (xRotNext > 180f)
                xRotNext -= 360f;

            // 좌우 : Root 회전
            float yRotPrev = root.localEulerAngles.y;
            float yRotNext =
                yRotPrev + _rotation.x
                * CamOption.rotationSpeed * deltaCoef;

            // 상하 회전 가능 여부
            bool xRotatable =
                CamOption.lookUpDegree < xRotNext &&
                CamOption.lookDownDegree > xRotNext;

            // Rig 상하 회전 적용
            rig.localEulerAngles = Vector3.right * (xRotatable ? xRotNext : xRotPrev);

            // Root 좌우 회전 적용
            root.localEulerAngles = Vector3.up * yRotNext;
        }

        /// <summary> 3인칭일 경우 Walker 회전 </summary>
        private void RotateWalker()
        {
            if(State.isMoving == false) return;

            Vector3 dir = Com.tpRig.TransformDirection(_moveDir);
            float currentY = Com.walker.localEulerAngles.y;
            float nextY = Quaternion.LookRotation(dir, Vector3.up).eulerAngles.y;

            if (nextY - currentY > 180f) nextY -= 360f;
            else if (currentY - nextY > 180f) nextY += 360f;

            Com.walker.eulerAngles = Vector3.up * Mathf.Lerp(currentY, nextY, 0.1f);
        }

        private void ShowCursorToggle()
        {
            if (Input.GetKeyDown(Key.showCursor))
                State.isCursorActive = !State.isCursorActive;

            ShowCursor(State.isCursorActive);
        }

        private void ShowCursor(bool value)
        {
            Cursor.visible = value;
            Cursor.lockState = value ? CursorLockMode.None : CursorLockMode.Locked;
        }

        private void CameraViewToggle()
        {
            if (Input.GetKeyDown(Key.switchCamera))
            {
                State.isCurrentFp = !State.isCurrentFp;
                Com.fpCamObject.SetActive(State.isCurrentFp);
                Com.tpCamObject.SetActive(!State.isCurrentFp);

                // TP -> FP
                if (State.isCurrentFp)
                {
                    Com.walker.localEulerAngles = Vector3.up * Com.tpRoot.localEulerAngles.y;
                    Com.fpRig.localEulerAngles = Vector3.right * Com.tpRig.localEulerAngles.x;
                }
                // FP -> TP
                else
                {
                    Com.tpRoot.localEulerAngles = Vector3.up * Com.walker.localEulerAngles.y;
                    Com.tpRig.localEulerAngles = Vector3.right * Com.fpRig.localEulerAngles.x;
                }
            }
        }

        private void TpCameraZoom()
        {
            if (State.isCurrentFp) return;                // TP 카메라만 가능
            if (Mathf.Abs(_currentWheel) < 0.01f) return; // 휠 입력 있어야 가능

            Transform tpCamTr = Com.tpCamera.transform;
            Transform tpCamRig = Com.tpRig;

            float zoom = _deltaTime * CamOption.zoomSpeed;
            float currentCamToRigDist = Vector3.Distance(tpCamTr.position, tpCamRig.position);
            Vector3 move = Vector3.forward * zoom * _currentWheel * 10f;

            // Zoom In
            if (_currentWheel > 0.01f)
            {
                if (_tpCamZoomInitialDistance - currentCamToRigDist < CamOption.zoomInDistance)
                {
                    tpCamTr.Translate(move, Space.Self);
                }
            }
            // Zoom Out
            else if (_currentWheel < -0.01f)
            {

                if (currentCamToRigDist - _tpCamZoomInitialDistance < CamOption.zoomOutDistance)
                {
                    tpCamTr.Translate(move, Space.Self);
                }
            }
        }

        private void UpdateAnimationParams()
        {
            float x, z;

            if (State.isCurrentFp)
            {
                x = _moveDir.x;
                z = _moveDir.z;

                if (State.isRunning)
                {
                    x *= 2f;
                    z *= 2f;
                }
            }
            else
            {
                x = 0f;
                z = _moveDir.sqrMagnitude > 0f ? 1f : 0f;

                if (State.isRunning)
                {
                    z *= 2f;
                }
            }

            // 보간
            const float LerpSpeed = 0.05f;
            _moveX = Mathf.Lerp(_moveX, x, LerpSpeed);
            _moveZ = Mathf.Lerp(_moveZ, z, LerpSpeed);

            Com.anim.SetFloat(AnimOption.paramMoveX, _moveX);
            Com.anim.SetFloat(AnimOption.paramMoveZ, _moveZ);
            Com.anim.SetFloat(AnimOption.paramDistY, _distFromGround);
            Com.anim.SetBool(AnimOption.paramGrounded, State.isGrounded);
        }

        #endregion
        /***********************************************************************
        *                               Movement Methods
        ***********************************************************************/
        #region .
        /// <summary> 땅으로부터의 거리 체크 - 애니메이터 전달용 </summary>
        private void CheckGroundDistance()
        {
            _distFromGround = Com.movement3D.GetDistanceFromGround();
            State.isGrounded = Com.movement3D.IsGrounded();
        }

        private void SendMoveInfo(float horizontal, float vertical)
        {
            _moveDir = new Vector3(horizontal, 0f, vertical).normalized;

            if (State.isCurrentFp)
            {
                _worldMoveDir = Com.walker.TransformDirection(_moveDir);
            }
            else
            {
                _worldMoveDir = Com.tpRoot.TransformDirection(_moveDir);
            }

            Com.movement3D.SetMovement(_worldMoveDir, State.isRunning);
        }

        private void Jump()
        {
            bool jumpSucceeded = Com.movement3D.SetJump();

            if (jumpSucceeded)
            {
                // 애니메이션 점프 트리거
                Com.anim.SetTrigger(AnimOption.paramJump);

                Debug.Log("JUMP");
            }
        }
        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .
        public void KnockBack(in Vector3 force, float time)
        {
            Com.movement3D.KnockBack(force, time);
        }

        #endregion
    }
}
```

</details>