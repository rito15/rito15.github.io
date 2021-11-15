FILE : unity-wrong-source-codes-for-beginners

TITLE : 유니티 - 초심자가 자주 실수하는 잘못된 스크립트 작성법들

CATEGORY : Unity Tips


# Summary
---

별 생각 없이 흔하게 작성할 수 있지만,

제대로 알고 보면 '이렇게 작성해도 괜찮은 걸까?'라고 생각할 수 있는 유니티 C# 코드들에 대해 다룹니다.

편의상 본문에서는 평어체로 서술합니다.

<br>



# Note
---

- 본문에서의 **'자주'**는 `Update()`, `FixedUpdate()`, 코루틴 내부의 `while(true)` 문 등에서 자주 호출되는 경우를 의미한다.

- 예를 들어 `Update()`는 매 프레임마다 한 번씩 호출되므로, 자주 호출된다고 할 수 있다.

<br>




# 1. 자주 호출되는 Find(), GetComponent()
---

## **예시**

```cs
GameObject managerObject  = GameObject.Find("Game Manager");
SoundManager soundManager = GameObject.FindObjectOfType<SoundManager>();
GameManager gameManager   = GameObject.Find("Game Manager").GetComponent<GameManager>();
```

<br>

## **문제점**

**Find**, **GetComponent**가 이름에 들어가는 메소드는 기능 자체가 가볍지 않다.

**Find**류의 메소드는 게임 내의 모든 오브젝트를 검사하여 해당하는 오브젝트를 찾는다.

당연히 게임오브젝트 수가 많을수록 더 많은 성능을 잡아먹는다.

**GetComponent**류의 메소드는 특정 게임오브젝트 내에서 해당하는 컴포넌트를 찾는다.

**Find**보다는 가벼운 편이지만, 역시나 매 프레임 호출하기에는 부담된다.

이런 메소드를 **Update()**에서 호출하고 있으면 성능상 굉장히 손해를 보는 것이다.

<br>

## **개선 방안**

```cs
private void Update()
{
    GameObject managerObject  = GameObject.Find("Game Manager");
    SoundManager soundManager = GameObject.FindObjectOfType<SoundManager>();
    GameManager gameManager   = GameObject.Find("Game Manager").GetComponent<GameManager>();
    
    // ...
}
```

위의 코드가 있다면, 아래처럼 바꾼다.

```cs
private GameObject   managerObject;
private SoundManager soundManager;
private GameManager  gameManager;

private void Start()
{
    managerObject = GameObject.Find("Game Manager");
    soundManager  = GameObject.FindObjectOfType<SoundManager>();
    gameManager   = managerObject.GetComponent<GameManager>();
}

private void Update()
{
    // ...
}
```

어차피 게임 내에서 계속 변하지 않고 동일하게 참조되는 객체라면,

위와 같이 `Start()` 또는 `Awake()` 메소드에서 멤버 변수에 딱 한 번만 받아오고

`Update()`에서는 이 객체들을 매번 받아오지 말고,

미리 받아온 객체를 사용하는 방식을 선택해야 한다.

<br>

물론 멤버 변수를 따로 만들어야 하는데다가 `Start()` 또는 `Awake()`에 작성해야 하므로

코딩하는 입장에서 굉장히 귀찮고 불편하게 느껴질 수 있겠지만,

항상 기억해야 한다.

코딩의 편의성은 때때로 성능을 망친다.

<br>




# 2. Cascading Find(), GetComponent()
---

## **예시**

```cs
GameObject.Find("Main Character").GetComponent<Rigidbody>().velocity = Vector3.zero;
```

<br>

## **문제점**

위와 같이 한 문장을 쭉 연결하게 되면

한 문장에서 Null Reference Exception이 발생할 여지가 많다.

`GameObject.Find("Main Character")`의 결과가 `null`이면

`null.GetComponent~`꼴이므로 예외가 발생하고,

`GetComponent<Rigidbody>()`의 결과가 `null`이면

`null.velocity = ~` 꼴이므로 예외가 발생한다.

<br>

'null이 발생하지 않는 상태를 만들고 위와 같이 작성하면 되지 않나?'

이렇게 생각할 수도 있겠지만

언제나 코드는 안전하게, 가능한 모든 상황에 대비하여 작성해야 한다.

특정 상황에서만 잘 작동하는 코드란, 아슬아슬하게 쌓아놓은 돌탑과도 같다.

조금만 상황이 달라져도 무너져버릴 수 있다.

<br>

그럼 예외의 발생이 왜 문제가 되는가?

```cs
// 예외 발생 가능 문장

// 정상 코드들
```

한 메소드 내에서 위와 같이 문장이 구성되어 있다면

예외가 발생할 경우, 이어지는 모든 문장이 실행되지 않는다.

단 하나의 문장 때문에 이어지는 모든 기능이 먹통이 될 수 있는 것이다.

따라서 배포되는 코드에는 발생 가능성 있는 모든 예외를 안전하게 처리해야 한다.

<br>

## **개선 방안**

조건문을 통해 `null` 검사를 하거나, `try-catch`문을 쓰는 방법이 있다.

```cs
/* [1] */
GameObject mainCharacter = GameObject.Find("Main Character");

if (mainCharacter != null)
{
    Rigidbody rBody = GetComponent<Rigidbody>();

    if (rBody != null)
        rBody.velocity = Vector3.zero;
}
```

```cs
/* [2] */
GameObject mainCharacter = GameObject.Find("Main Character");

if (mainCharacter != null)
{
    if (mainCharacter.TryGetComponent(out Rigidbody rBody))
    {
        rBody.velocity = Vector3.zero;
    }
}
```

```cs
/* [3] */
try
{
    GameObject.Find("Main Character").GetComponent<Rigidbody>().velocity = Vector3.zero;
}
catch (NullReferenceException)
{
    Debug.Log("Main Character or Rigidbody is Null");
}
```

위의 세 코드들 중에서 하나를 골라 작성해도 되고,

유사한 다른 방식으로 작성해도 된다.

대신 `try-catch`문을 사용하는 경우에 유의해야 할 점이 있다.

예외가 발생하지 않으면 `try-catch`는 성능을 거의 소모하지 않는다.

하지만 예외가 발생하면 조건문과는 비교가 안될 정도로 많은 성능을 소모한다.

따라서 예외가 자주 발생할 것 같은 코드에 `try-catch`를 쓰는 것은 좋지 않다.

<br>




<!-- [] : &#91;&#93; -->

# 3. 자주 호출되는 new&#91;&#93;
---

## **예시**

```cs

```

<br>

## **문제점**



<br>

## **개선 방안**



<br>


<!-- () : &#40;&#41; -->

# 4. 자주 호출되는 new()
---

## **예시**

```cs

```

<br>

## **문제점**



<br>

## **개선 방안**

클래스 타입이면 구조체로 바꿔라

<br>




# 5. 문자열 상수에 대한 의존
---

## **예시**

```cs
// [1] 게임오브젝트에 설정된 이름 문자열로 찾기
GameObject managerObject = GameObject.Find("Game Manager");

// [2] 메소드 이름 문자열로 코루틴 시작
StartCoroutine("MyCoroutine");

// [3] 레이어 이름 문자열로 레이어 번호 찾기
int postProcessingLayer = LayerMask.NameToLayer("Post Processing");
```

<br>

## **문제점**

