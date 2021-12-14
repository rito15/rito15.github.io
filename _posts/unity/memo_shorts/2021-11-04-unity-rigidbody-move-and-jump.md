---
title: 유니티 - 키보드 입력을 통한 리지드바디 이동, 회전, 점프 기본 코드
author: Rito15
date: 2021-11-04 20:30:00 +09:00
categories: [Unity, Unity Memo - Shorts]
tags: [unity, csharp, shorts]
math: true
mermaid: true
---

# Note
---
- 입력은 `Update()`, 물리 처리는 `FixedUpdate()`로 철저히 구분하는 것이 핵심

- 리지드바디를 사용한다면, 트랜스폼을 직접 조작하지 말고 반드시 `FixedUpdate()`에서 리지드바디를 통해서 이동시켜야만 한다.

- 다음과 같은 증상들이 발생한다면 `Update()`에서 리지드바디를 조작하고 있는지, 혹은 트랜스폼을 직접 조작하고 있는지 의심할 필요가 있다.
  - 왠지 모르게 캐릭터가 벽을 너무 잘 뚫고 지나간다.
  - 콜라이더에 자주 끼인다.
  - 지터링(덜덜 떨림)이 빈번하게 발생한다.
  - 점프할 때마다 점프하는 높이가 달라진다.

<br>


# Source Code 1
---

## **기능**
- `WASD` 키 : 리지드바디 이동
- `Space` 키 : 리지드바디 점프

<br>

## **소스 코드**

<details>
<summary markdown="span">
Source Code
</summary>

{% include codeHeader.html %}
```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[RequireComponent(typeof(Rigidbody))]
public class InputAndPhysicsMove : MonoBehaviour
{
    private Rigidbody rb;
    private Vector3 moveDir;
    private bool isMoving = false;
    private bool isJumpRequired = false;

    [SerializeField, Range(0f, 100f)]
    private float moveSpeed = 5f;

    [SerializeField, Range(0f, 100f)]
    private float jumpForce = 5f;

    private void Start()
    {
        if (!TryGetComponent(out rb))
            rb = gameObject.AddComponent<Rigidbody>();
    }

    private void Update()
    {
        // == MOVE ==
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");

        isMoving = (h != 0f || v != 0f);

        if (isMoving)
        {
            moveDir = transform.forward * v + transform.right * h;
            moveDir.Normalize();
        }

        // == JUMP ==
        if (Input.GetKeyDown(KeyCode.Space))
            isJumpRequired = true;
    }

    private void FixedUpdate()
    {
        if (isMoving)
        {
            Vector3 moveOffset = moveDir * (moveSpeed * Time.fixedDeltaTime);
            rb.MovePosition(rb.position + moveOffset);
        }

        if (isJumpRequired)
        {
            rb.AddForce(new Vector3(0f, jumpForce, 0f), ForceMode.VelocityChange);
            isJumpRequired = false;
        }
    }
}
```

</details>

<br>

# Source Code 2
---

## **기능**
- `WASD` 키 : 리지드바디 이동
- `Space` 키 : 리지드바디 점프
- `Alt` 키 : 커서 표시/숨기기
- 커서 숨김 상태에서 마우스 움직임에 의한 리지드바디 좌우 회전

<br>

## **소스 코드**

<details>
<summary markdown="span">
Source Code (1)
</summary>

{% include codeHeader.html %}
```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

using SF = UnityEngine.SerializeField;

[RequireComponent(typeof(Rigidbody))]
public class InputAndPhysicsMove : MonoBehaviour
{
    private Rigidbody rb;
    private Vector3 moveDir;
    private float hRot;

    // 입력 상태
    private bool isCursorLocked = false;
    private bool isMoving       = false;
    private bool isRotating     = false;
    private bool isJumpRequired = false;

    // 키 설정
    [SF] private KeyCode cursorLockKey = KeyCode.LeftAlt;
    [SF] private KeyCode jumpKey       = KeyCode.Space;

    // 계수 설정
    [SF, Range(0f, 100f)] private float moveSpeed   = 10f;
    [SF, Range(0f, 200f)] private float rotateSpeed = 100f;
    [SF, Range(0f, 100f)] private float jumpForce   = 5f;

    private void Start()
    {
        if (!TryGetComponent(out rb))
            rb = gameObject.AddComponent<Rigidbody>();

        rb.freezeRotation = true;  // 다른 강체에 부딪혔을 때 회전하지 않도록 설정한다.
        isCursorLocked    = false; // 마우스 커서 초기 상태 : 커서 표시 & 미잠금

        // FrameRate가 너무 높으면 FixedUpdate에 의한 회전이 부자연스러워진다.
        // 추후, targetFrameRate 설정 코드는 여기서 제거하고 매니저 클래스로 옮기는 것이 좋다.
        Application.targetFrameRate = 60;
    }

    private void Update()
    {
        /**************************************************
         *                  CURSOR LOCK
         **************************************************/
        // NOTE : cursorLockKey는 토글 키로 사용되며, 커서 잠금 및 표시 상태를 전환한다.
        if (Input.GetKeyDown(cursorLockKey))
        {
            isCursorLocked   = !isCursorLocked;
            Cursor.lockState = isCursorLocked ? CursorLockMode.Locked : CursorLockMode.None;
            Cursor.visible   = !isCursorLocked;
        }

        /**************************************************
         *                      MOVE
         **************************************************/
        // NOTE : GetAxis()를 사용할 경우, 정지 시 조금씩 미끄러지며 멈춘다.
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");

        isMoving = (h != 0f || v != 0f);

        if (isMoving)
        {
            moveDir = transform.TransformDirection(new Vector3(h, 0f, v));
            moveDir.Normalize();
        }

        /**************************************************
         *                      ROTATE
         **************************************************/
        // NOTE 1 : "Mouse X"에 대한 GetAxis(), GetAxisRaw()는 차이가 없다.
        // NOTE 2 : 커서 잠금 및 미표시 상태에서만 회전하도록 한다.
        if (isCursorLocked)
        {
            hRot = Input.GetAxis("Mouse X");
            isRotating = (hRot != 0f);
        }
        else
            isRotating = false;

        /**************************************************
         *                      JUMP
         **************************************************/
        if (Input.GetKeyDown(jumpKey))
            isJumpRequired = true;
    }

    private void FixedUpdate()
    {
        if (isMoving)
        {
            Vector3 moveOffset = moveDir * (moveSpeed * Time.fixedDeltaTime);
            rb.MovePosition(rb.position + moveOffset);
        }

        if (isRotating)
        {
            float rotAngle  = hRot * rotateSpeed * Time.fixedDeltaTime;
            rb.rotation = Quaternion.AngleAxis(rotAngle, Vector3.up) * rb.rotation; // 좌우 회전

            // NOTE : 상하 회전은 캐릭터의 리지드바디가 아니라, 카메라의 트랜스폼에 대해 구현한다.
        }

        if (isJumpRequired)
        {
            rb.AddForce(new Vector3(0f, jumpForce, 0f), ForceMode.VelocityChange);
            isJumpRequired = false;
        }
    }
}
```

</details>

<details>
<summary markdown="span">
Source Code (2)
</summary>

{% include codeHeader.html %}
```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

using SF = UnityEngine.SerializeField;

[RequireComponent(typeof(Rigidbody))]
public class InputAndPhysicsMove : MonoBehaviour
{
    private Rigidbody rb;
    private Vector3 moveDir;
    private float hRot;

    // 입력 상태
    private bool isCursorLocked = false;
    private bool isMoving       = false;
    private bool isRotating     = false;
    private bool isJumpRequired = false;

    // 키 설정
    [SF] private KeyCode cursorLockKey = KeyCode.LeftAlt;
    [SF] private KeyCode jumpKey = KeyCode.Space;

    // 계수 설정
    [SF, Range(0f, 100f)] private float moveSpeed   = 10f;
    [SF, Range(0f, 200f)] private float rotateSpeed = 100f;
    [SF, Range(0f, 100f)] private float jumpForce   = 5f;

    private void Start()
    {
        if (!TryGetComponent(out rb))
            rb = gameObject.AddComponent<Rigidbody>();

        rb.freezeRotation = true; // 다른 강체에 부딪혔을 때 회전하지 않도록 설정한다.
        isCursorLocked = false;   // 마우스 커서 초기 상태 : 커서 표시 & 미잠금

        // FrameRate가 너무 높으면 FixedUpdate에 의한 회전이 부자연스러워진다.
        // 추후, targetFrameRate 설정 코드는 여기서 제거하고 매니저 클래스로 옮기는 것이 좋다.
        Application.targetFrameRate = 60;
    }

    private void Update()
    {
        ToggleCursorLock();
        Move();
        Rotate();
        Jump();
    }

    private void ToggleCursorLock()
    {
        // NOTE : cursorLockKey는 토글 키로 사용되며, 커서 잠금 및 표시 상태를 전환한다.
        if (Input.GetKeyDown(cursorLockKey))
        {
            isCursorLocked = !isCursorLocked;
            Cursor.lockState = isCursorLocked ? CursorLockMode.Locked : CursorLockMode.None;
            Cursor.visible = !isCursorLocked;
        }
    }

    private void Move()
    {
        // NOTE : GetAxis()를 사용할 경우, 정지 시 조금씩 미끄러지며 멈춘다.
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");

        isMoving = (h != 0f || v != 0f);

        if (isMoving)
        {
            moveDir = transform.TransformDirection(new Vector3(h, 0f, v));
            moveDir.Normalize();
        }
    }

    private void Rotate()
    {
        // NOTE 1 : "Mouse X"에 대한 GetAxis(), GetAxisRaw()는 차이가 없다.
        // NOTE 2 : 커서 잠금 및 미표시 상태에서만 회전하도록 한다.
        if (isCursorLocked)
        {
            hRot = Input.GetAxis("Mouse X");
            isRotating = (hRot != 0f);
        }
        else
            isRotating = false;
    }

    private void Jump()
    {
        if (Input.GetKeyDown(jumpKey))
            isJumpRequired = true;
    }

    private void FixedUpdate()
    {
        float fixedDeltaTime = Time.fixedDeltaTime;

        if (isMoving)
        {
            Vector3 moveOffset = moveDir * (moveSpeed * fixedDeltaTime);
            rb.MovePosition(rb.position + moveOffset);
        }

        if (isRotating)
        {
            float rotAngle = hRot * rotateSpeed * fixedDeltaTime;
            rb.rotation = Quaternion.AngleAxis(rotAngle, Vector3.up) * rb.rotation; // 좌우 회전
        }

        if (isJumpRequired)
        {
            rb.AddForce(new Vector3(0f, jumpForce, 0f), ForceMode.VelocityChange);
            isJumpRequired = false;
        }
    }
}
```

</details>

<br>

## **Preview**

![2021_1107_InputAndRB](https://user-images.githubusercontent.com/42164422/140635486-978a6bdb-c479-4242-b3c5-44f7060f35b2.gif)

<br>
