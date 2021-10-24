---
title: 유니티 - 트랜스폼과 방향벡터의 회전
author: Rito15
date: 2021-03-19 17:08:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, rotation]
math: true
mermaid: true
---

# Memo
---

## **유니티엔진에서의 회전**

- 각 축에 회전이 적용되는 순서는 Y축 -> X축 -> Z축

<br>

## **오일러 회전 값을 변경하여 회전시킬 때**

트랜스폼 오일러 회전 벡터의 X, Y, Z 값 중 회전시키려는 축을 제외하고 모두 0이라면

(예 : X축으로 회전시키려는데 (34f, 0f, 0f)인 상태)

해당 축의 오일러 값만 변경시키면 다른 축에 영향을 받지 않고 정상적으로 회전할 수 있다.

<br>

정확히는, 유니티엔진의 회전 순서에 따라

Z축 회전일 경우 X, Y 오일러 값에 상관 없이 회전이 가능하고

X축 회전일 경우 Z 값이 0이 아니면 영향을 받고,

Y축 회전일 경우 X, Z값이 0이 아니면 영향을 받는다.

<br>

회전시키려는 축 외의 다른 값이 0이 아닌 상태라면

(예 : X축으로 회전시키려는데 (1f, 2f, 3f)인 상태)

쿼터니언을 통해 회전을 적용해야 한다.

<br>


# 회전 시 주의사항
---

위에서 설명했듯, 오일러 X Y Z축 중 하나의 축에만 회전이 적용된 상태에서

해당 축의 오일러 회전값을 변경하면 정상적으로 회전되기는 한다.

하지만 다른 축에도 회전이 적용되어 있다면 정확히 회전할 수 없다.

따라서 회전을 적용할 때는 오일러 회전을 변경시키지 말고,

쿼터니언 연산을 통해 회전시키도록 습관을 들이는 것이 좋다.

<br>

## **[1] X축 회전 : 잘못된 예시**

```cs
private void Update()
{
    Vector3 eRot = transform.eulerAngles;
    eRot.x += Time.deltaTime * 100f;
    transform.eulerAngles = eRot;
}
```

<br>

## **[2] X축 회전 : 정상**

```cs
private void Update()
{
    transform.rotation *= Quaternion.Euler(Time.deltaTime * 100f, 0f, 0f);
}
```


<br>

# 1. 트랜스폼을 자신의 축으로 회전
---

- 트랜스폼의 자신의 축으로 회전시키기
- 예) eulerAngle의 값이 (1, 0, 0)인 경우 : 자신의 X축을 기준으로 1도 회전

- 회전의 적용 순서(Y-X-Z) 때문에, X 및 Y 축 회전 시 다른 축의 오일러 회전 값도 변경될 수 있다.

```cs
transform.Rotate(eulerAngle, Space.Self);

// Space.Self일 때의 Rotate() 내부 구현
transform.localRotation *= Quaternion.Euler(eulerAngle);
```

<br>

# 2. 트랜스폼을 월드 축으로 회전
---

- 트랜스폼을 월드 축으로 회전시키기

```cs
transform.Rotate(eulerAngle, Space.World);

// 내부 구현(1, 2 모두 결과는 동일)
// [1]
Quaternion rot = transform.rotation;
transform.rotation *= 
    Quaternion.Inverse(rot) * Quaternion.Euler(eulerAngle) * rot;

// [2]
transform.rotation = 
    Quaternion.Euler(eulerAngle) * rot;
```

<br>

# 3. 트랜스폼을 타겟 중심으로 회전
---

## **Note**
- `Update()` 내에서 호출

<br>

## **[1] 현재 타겟과의 관계에 따라 회전하기**

![2021_1022_Rotate0](https://user-images.githubusercontent.com/42164422/138448967-c1ca56a8-16a7-4661-86aa-b9fc88682dbf.gif)

{% include codeHeader.html %}
```cs
// axis  : 회전축 벡터
// speed : 회전 속도
private void RotateAround0(in Vector3 axis, float speed)
{
    float t = speed * Time.deltaTime;
    transform.RotateAround(target.position, axis, t);
}
```

<details>
<summary markdown="span"> 
호출 예제
</summary>

```cs
public float rotateSpeed = 50f;
public Vector3 axis = new Vector3(0f, 1f, 0f);

private void Update()
{
    RotateAround0(axis, rotateSpeed);
}
```

</details>

<br>


## **[2] 타겟과 거리 관계를 유지한 채로 회전하기**

![2021_1022_Rotate1](https://user-images.githubusercontent.com/42164422/138448980-ef989aec-4ac7-4054-ae62-9d1ffa66fcc0.gif)

{% include codeHeader.html %}
```cs
// axis  : 회전축 벡터
// diff  : (타겟의 위치 - 자신의 위치) 벡터
// speed : 회전 속도
// t     : 현재 회전값을 기억할 변수
private void RotateAround1(in Vector3 axis, in Vector3 diff, float speed, ref float t)
{
    t += speed * Time.deltaTime;

    Vector3 offset = Quaternion.AngleAxis(t, axis) * diff;
    transform.position = target.position + offset;
}
```

<details>
<summary markdown="span"> 
호출 예제
</summary>

```cs
public float rotateSpeed = 50f;
public Vector3 axis = new Vector3(0f, 1f, 0f);
public Vector3 diff = new Vector3(4f, 0f, 0f);
private float t = 0;

private void Update()
{
    RotateAround1(axis, diff, rotateSpeed, ref t);
}
```

</details>

<br>


## **[3] 타겟과의 거리를 유지하고, 타겟을 바라보며 회전하기**

![2021_1022_Rotate2](https://user-images.githubusercontent.com/42164422/138448990-f3a0f1ae-2441-4353-8352-d476cb17ce3f.gif)

{% include codeHeader.html %}
```cs
// axis  : 회전축 벡터
// diff  : (타겟의 위치 - 자신의 위치) 벡터
// speed : 회전 속도
// t     : 현재 회전값을 기억할 변수
private void RotateAround2(in Vector3 axis, in Vector3 diff, float speed, ref float t)
{
    t += speed * Time.deltaTime;

    Vector3 offset = Quaternion.AngleAxis(t, Vector3.up) * diff;
    transform.position = target.position + offset;

    Quaternion rot = Quaternion.LookRotation(-offset, axis);
    transform.rotation = rot;
}
```

<details>
<summary markdown="span"> 
호출 예제
</summary>

```cs
public float rotateSpeed = 50f;
public Vector3 axis = new Vector3(0f, 1f, 0f);
public Vector3 diff = new Vector3(4f, 0f, 0f);
private float t = 0;

private void Update()
{
    RotateAround2(axis, diff, rotateSpeed, ref t);
}
```

</details>


<br>

# 4. 방향 벡터를 월드 축으로 회전
---

```cs
Vector3 dirVec = new Vector3(1f, 0f, 0f);  // 회전시킬 방향 벡터
Vector3 rotVec = new Vector3(0f, 45f, 0f); // Y축 45도 회전

Vector3 rotatedDirVec = Quaternion.Euler(rotVec) * dirVec;
```

<br>

# 5. 방향 벡터를 특정 축으로 회전
---

```cs
Vector3 dirVec = new Vector3(1f, 0f, 0f);              // 회전시킬 방향 벡터
Vector3 axisVec = new Vector3(-1f, 1f, 0f).normalized; // 회전 기준축 벡터

// axisVec을 축으로 하여 dirVec을 45도 회전
Vector3 rotatedDirVec = Quaternion.AngleAxis(45f, axisVec) * dirVec;
```

<br>

# 6. 대상 지점 천천히 바라보기
---

## [1] XYZ 모두 회전

```cs
private void LookAtSlowly(Transform target, float speed = 1f)
{
    if (target == null) return;

    Vector3 dir = target.position - transform.position;
    var nextRot = Quaternion.LookRotation(dir);

    transform.rotation = Quaternion.Slerp(transform.rotation, nextRot, Time.deltaTime * speed);
}
```

![2021_0528_LookRotation](https://user-images.githubusercontent.com/42164422/119984789-c30cec80-bffc-11eb-8df4-b9667752677f.gif)

<br>

## [2] X만 회전

```cs
private void LookAtSlowlyX(Transform target, float speed = 1f)
{
    if (target == null) return;

    Vector3 dir = target.position - transform.position;
    dir.x = 0f; // 방향 벡터 X 성분 제거

    var nextRot = Quaternion.LookRotation(dir);
    transform.rotation = Quaternion.Slerp(transform.rotation, nextRot, Time.deltaTime * speed);
}
```

![2021_0528_LookRotation2](https://user-images.githubusercontent.com/42164422/119984795-c43e1980-bffc-11eb-95a5-2ad748f2a3e8.gif)

<br>

# 7. 마우스 입력에 따른 상하좌우 회전 예제
---

```cs
[SerializeField, Range(0f, 100f)]
private float hRotationSpeed = 50f;  // 좌우 회전 속도

[SerializeField, Range(0f, 100f)]
private float vRotationSpeed = 100f; // 상하 회전 속도

private void Update()
{
    float t = Time.deltaTime;

    // 마우스 움직임 감지
    float h =  Input.GetAxisRaw("Mouse X") * hRotationSpeed * t;
    float v = -Input.GetAxisRaw("Mouse Y") * vRotationSpeed * t;

    // 회전 변위 생성
    Quaternion hRot = Quaternion.AngleAxis(h, Vector3.up);
    Quaternion vRot = Quaternion.AngleAxis(v, Vector3.right);

    // [1] 좌우 회전 : 월드 Y축 기준
    transform.rotation = hRot * transform.rotation;

    // [2] 상하 회전 : 로컬 X축 기준
    transform.rotation *= vRot;
}
```

<br>

<!--

- 추가 : 상하 회전 각도 제한

```cs

```

-->