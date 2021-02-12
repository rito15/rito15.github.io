---
title: 1인칭, 3인칭 전환 가능한 캐릭터 제작하기 [작성 중]
author: Rito15
date: 2021-02-12 18:06:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, fps, tps, controller]
math: true
mermaid: true
---

# 목차
---
- 1. 하이라키 구성
- 2. 스크립트 기초 작성
- 3. 1인칭 이동, 회전
- 4. 3인칭 이동, 회전
- 5. 카메라 전환
- 6. 점프
- 7. 애니메이션 적용하기
- 8. 부드러운 애니메이션 적용하기 : 블렌딩, 러프
- 9. 버그 수정
- 10. 카메라 전환 시 시점 방향 공유하기
- 11. 3인칭 카메라 줌 구현하기
- 12. 경사로에서 정확한 이동 구현하기
- 13. 이동 가속/감속 제어하기
- 14. 캐릭터 고개가 상하 회전방향 바라보게 하기

<br>

# 하이라키 구성하기
---

![image](https://user-images.githubusercontent.com/42164422/107759975-66970180-6d6c-11eb-87f7-d712112f6a90.png){:.normal}

위와 같이 하이라키를 구성한다.

따로 지정하지 않는 이상, 모든 게임오브젝트는 Position(0, 0, 0), Rotation(0, 0, 0), Scale(1, 1, 1)로 초깃값을 지정한다.

이동에 사용할 캐릭터의 예시로 유니티짱(UnityChan)을 사용하였다.

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

```cs
public class CharacterCoreController : MonoBehaviour
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

위처럼 1인칭/3인칭 캐릭터 구현에 필요한 기초를 작성한다.

그리고 인스펙터에서 TP Camera, FP Camera를 드래그하여 초기화한다.

<br>

# 1인칭 이동, 회전 구현
---

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

## 추가 : 커서 보이기/안보이기
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

- 게임 뷰

![2012_0213_TPMove](https://user-images.githubusercontent.com/42164422/107802228-69154d80-6da4-11eb-8a14-bed0bdb1d714.gif){:.normal}

- 씬 뷰

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

## 1. 지면으로부터의 거리 검사

캐릭터가 지상에 있는지, 공중에 있는지 여부를 항상 검사해야 한다.

우선 MovementOption 클래스에 다음을 추가한다.

```cs
[Tooltip("지면으로 체크할 레이어 설정")]
public LayerMask groundLayerMask = -1;
```

Raycast 대신 SphereCast를 통해 검사할 것이기 때문에, 반지름 정보가 필요하다.

캡슐 콜라이더를 사용하므로 이를 기반으로 설정한다.

```cs

private float _groundCheckRadius;

private void InitSettings()
{
    // .. codes

    TryGetComponent(out CapsuleCollider cCol);
    _groundCheckRadius = cCol ? cCol.radius : 0.1f;
}

필드로 _groundCheckRadius를 추가하고,

InitSettings() 메소드 내에 위의 내용을 추가로 작성한다.

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

    float distFromGround = cast ? (hit.distance - 1f + _groundCheckRadius) : float.MaxValue;
    State.isGrounded = distFromGround <= _groundCheckRadius + threshold;
}

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

위의 두 메소드를 구현하고, Update에서 호출해준다.


## 구현 결과

![2012_0213_Jump](https://user-images.githubusercontent.com/42164422/107806031-90bae480-6da9-11eb-93a5-89e40a9d954f.gif){:.normal}

<br>

# 애니메이션 적용하기
---



<br>

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

<br>

# Download
---
- 