---
title: 유니티 - 반드시 고쳐야 하는, 잘못된 코딩 방식들
author: Rito15
date: 2021-11-16 22:51:00 +09:00
categories: [Unity, Unity Tips]
tags: [unity, csharp]
math: true
mermaid: true
---

# Intro
---

별 생각 없이 흔하게 작성할 수 있지만,

제대로 알고 보면 '절대 이렇게 작성하면 안되겠다'라고 생각할 수 있는 유니티 C# 코딩 방식들에 대해 다룹니다.

편의상 본문에서는 평어로 서술합니다.

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
private void Update()
{
    GameObject managerObject  = GameObject.Find("Game Manager");
    SoundManager soundManager = GameObject.FindObjectOfType<SoundManager>();
    GameManager gameManager   = GameObject.Find("Game Manager").GetComponent<GameManager>();
    
    // ...
}
```

<br>

## **문제점**

**Find**, **GetComponent**가 이름에 들어가는 메소드는 기능 자체가 가볍지 않다.

**Find** 계열 메소드는 게임 내의 모든 오브젝트를 검사하여 해당하는 오브젝트를 찾는다.

당연히 게임오브젝트 수가 많을수록 더 많은 성능을 잡아먹는다.

<br>

**GetComponent** 계열의 메소드는 특정 게임오브젝트 내에서 해당하는 컴포넌트를 찾는다.

**Find**보다는 가벼운 편이지만, 역시나 매 프레임 호출하기에는 썩 가볍지 않다.

이런 메소드를 **Update()**에서 호출하고 있으면 성능상 괜히 손해를 보는 것이다.

<br>

## **개선 방안**

아래처럼 바꾼다.

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

물론 멤버 변수를 따로 만들어야 하는데다가 `Start()` 또는 `Awake()`에 작성해야 하므로 코딩하는 입장에서 굉장히 귀찮고 불편하게 느껴질 수 있겠지만,

항상 기억해야 한다.

<br>

작성하기 쉬운 코드는 때때로 성능을 망친다.

<br>




# 2. 안전하지 않은 연쇄 호출
---

## **예시**

```cs
GameObject.Find("Main Character").GetComponent<Rigidbody>().velocity = Vector3.zero;
```

<br>

## **문제점**

한 문장에 `메소드.메소드.프로퍼티` 꼴로 세 번의 연쇄 호출이 발생한다.

연쇄 호출 자체는 납득할 수 있지만,

문장 내에서 **Null Reference Exception**이 발생할 여지가 많다는 것이 문제가 된다.

<br>

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
    Debug.Log("Main Character GameObject or Rigidbody is Null");
}
```

위의 세 코드들 중에서 하나를 골라 작성해도 되고,

유사한 다른 방식으로 작성해도 된다.

<br>

대신 `try-catch`문을 사용하는 경우에 유의해야 할 점이 있다.

예외가 발생하지 않으면 `try-catch`는 성능을 거의 소모하지 않는다.

하지만 예외가 발생하면 조건문과는 비교가 안될 정도로 많은 성능을 소모한다.

따라서 예외가 자주 발생할 것 같은 코드에 `try-catch`를 쓰는 것은 좋지 않다.

<br>

그리고 `try`문으로 위의 문장을 감싼다고 해도,

막상 **Null Reference Exception**이 발생했을 때

`GameObject.Find()`의 결과가 `null`인지 `GetComponent<>()`의 결과가 `null`인지 한 번에 알 수 없으므로, 확인을 위해 추가적인 작업이 필요하다.

그래서 사실 저렇게 `try`로 감싸기만 하는 코드는 별로 좋은 코드가 아니다.

다시 강조하지만, 프로그래머는 '발생 가능한 모든 예외 상황'에 대응할 필요가 있다.

<br>




<!-- [] : &#91;&#93; -->

# 3. 자주 호출되는 new&#91;&#93;
---

## **예시**

```cs
private void Update()
{
    int childCount = transform.childCount;
    Transform[] children = new Transform[childCount];
    
    for(int i = 0; i < childCount; i++)
        children[i] = transform.GetChild(i);
    
    // ...
}
```

<br>

## **문제점**

`Update()`처럼 매 프레임 호출되는 메소드에서 `new Transform[]`을 통해 배열을 새롭게 할당한다는 것이 문제다.

C#은 클래스 타입 객체를 힙 메모리 영역에 할당하는데, 프로그래머가 원할 때 할당할 수는 있지만 직접 해제할 수는 없다.

더이상 사용되지 않는 객체를 **가비지 컬렉터(Garbage Collector, GC)**가 알아서 제거한다.

<br>

배열도 원소 타입에 상관 없이, 그러니까 `Transform[]`이든 `int[]`이든 상관 없이 모두 클래스 타입 객체이므로 힙에 할당되는데

저렇게 매프레임마다 객체를 차곡차곡 할당하면 결국 힙 메모리에 사용되지 않는 객체가 쌓이게 되고,

가비지 컬렉터가 가끔씩 이를 해제하기 위해 동작한다.

<br>

그래서 정말로 문제되는 것은 바로 가비지 컬렉터의 동작이다.

가비지 컬렉터가 동작하는 동안에는 프로그램 전체가 정지하는데

이 동작이 길어질수록 당연히 정지 시간이 길어지고, 흔히 아는 '렉'이라는 현상으로 나타난다.

심지어 이렇게 발생하는 렉은 발생 타이밍을 예측할 수조차 없다.

따라서 이렇게 매 프레임마다 배열 객체를 생성해서 가비지 컬렉터가 자주 동작하게 하는 것을 지양해야 한다.

<br>

## **개선 방안**

미리 넉넉한 크기의 배열을 생성하거나, `List<>`를 사용하는 방법이 있다.

```cs
/* [1] 넉넉한 크기의 배열 생성 */

private Transform[] children;
private const int MaxChildCount = 20;
private int currentChildCount;

private void Start() // 또는 Awake()
{
    children = new Transform[MaxChildCount];
}

private void Update()
{
    currentChildCount = transform.childCount;
    
    for(int i = 0; i < currentChildCount; i++)
        children[i] = transform.GetChild(i);
}
```

배열의 크기가 고정적이거나, 일정 크기 이하임을 보장할 수 있다면

위와 같이 미리 크기를 정해서 선언하고 사용하면 된다.

하지만 크기를 미리 정할 수 없다면 동적으로 확장해주거나 리스트를 사용해야 한다.

<br>

```cs
/* [2] List<Transform> 사용 */

private List<Transform> childList;

private void Start() // 또는 Awake()
{
    childList = new List<Transform>();
}

private void Update()
{
    childList.Clear(); // 매 프레임마다 리스트 내부 비우기
    
    int childCount = transform.childCount;
    
    for(int i = 0; i < childCount; i++)
        childList.Add(transform.GetChild(i));
}
```

리스트를 사용할 때는 재할당이 필요한 순간마다 `.Clear()` 메소드를 통해 내부를 비워주는 것이 핵심이다.

리스트를 사용한다고 해서 매번 `new List<>()`를 해버리면 기존의 문제와 다를 것이 없다.

<br>

그리고 리스트 내부에 들어갈 요소들의 개수를 미리 대략적으로라도 파악할 수 있다면

```cs
private void Start()
{
    childList = new List<Transform>(20); // 초기 Capacity 설정
}
```

이렇게 `new List<>(capacity)` 형태로 초기 개수를 미리 잡아주는 것이 좋다.

<br>


<!-- () : &#40;&#41; -->

# 4. 자주 호출되는 new()
---

## **예시**

```cs
/* [1] */
private void Update()
{
    List<Transform> childList = new List<Transform>();
    for(int i = 0; i < transform.childCount; i++)
        childList.Add(transform.GetChild(i));
    
    // ...
}
```

```cs
/* [2] */
private IEnumerator CoroutineExample()
{
    while(true)
    {
        // ...
    
        yield return new WaitForSeconds(2f);
    }
}
```

<br>

## **문제점**

`[1]`은 앞서 서술한 배열의 예시처럼 매프레임 `List<>()` 객체를 생성하는 경우에 해당된다.

`[2]`는 무한 반복되는 코루틴에서 2초마다 `WaitForSeconds` 객체를 생성하는 경우다.

공통점은 모두 클래스 타입 객체라는 것이고,

마찬가지로 앞서 설명했듯 가비지 컬렉터의 동작과 렉을 유발할 수 있다.

<br>

구조체 타입은 상관 없다.

예를 들어, 자주 쓰이는 `Vector3` 타입도 구조체이므로 괜찮다.

물론 구조체 내부 크기가 너무 크면 문제가 되지만, 여기서 다루지는 않는다.

<br>

## **개선 방안**

매번 생성하던 객체를, 미리 생성해서 변수에 담아놓고 재사용하는 방식으로 바꾸는 것이 핵심이다.

```cs
/* [1] */
private List<Transform> childList;

private void Start() // 또는 Awake()
{
    childList = new List<Transform>();
}

private void Update()
{
    childList.Clear(); // 매 프레임마다 리스트 내부 비우기
    
    int childCount = transform.childCount;
    
    for(int i = 0; i < childCount; i++)
        childList.Add(transform.GetChild(i));
}
```

리스트는 앞의 예제와 똑같은 코드지만, 강조를 위해 한 번 더 작성한다.

`childList` 변수를 멤버 변수로 만들고

`Start()` 또는 `Awake()`에서 객체를 미리 생성한 뒤,

`Update()` 상단에서 `new List<>()` 대신 `.Clear()`를 통해 내부를 비우며 재사용하면 된다.

<br>

```cs
/* [2] */
private IEnumerator CoroutineExample()
{
    WaitForSeconds wfs = new WaitForSeconds(2f);
    
    while(true)
    {
        // ...
    
        yield return wfs;
    }
}
```

코루틴에서 대기를 위해 사용되는 `WaitFor~` 객체들은 위와 같이 반복문 이전에 미리 객체를 생성하고,

그 객체를 `yield return`을 통해 대기하면 된다.

`WaitForSeconds` 뿐만 아니라 `WaitForSecondsRealtime`, `WaitForFixedUpdate`, `WaitForEndOfFrame` 등의 경우에도 마찬가지다.

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

`[1]`은 게임 오브젝트의 이름이 변경되면 대상을 찾지 못하여 `null`로 초기화된다.

`[2]`는 메소드의 이름이 변경되면 코루틴을 시작하지 못하고, 에러 로그를 출력한다.

`[3]`은 레이어의 이름이 변경되면 `-1` 값으로 초기화된다.

모두 특정 문자열이 변경되면 정상적으로 동작하지 않는다는 공통점이 있다.

따라서 변경에 굉장히 취약하다.

저런 코드를 한두 군데에서 사용하면 일일이 바꿔주면 되니 딱히 상관없을 수 있다.

하지만 수십 군데, 혹은 프로젝트가 너무 커져서 수백 군데에서 사용하게 된다면?

이를 수정하는 데만 오랜 시간이 걸릴 수 있다.

<br>

## **개선 방안**

문자열 상수를 사용하지 않거나, 사용하더라도 한 곳에서 사용하고 다른 곳에서는 공통 변수/상수를 참조하는 방식을 선택해야 한다.

<br>

`[1]`의 경우에는 애초에 `GameObject.Find()` 메소드를 사용하지 않아야 한다.

필자도 지금까지 유니티 개발 몇 년을 해오면서 `GameObject.Find()`를 쓴 적이 없다.

`public` 또는 `[SerializeField] private` 필드로 선언하고 인스펙터에서 끌어다 넣는 방식을 사용하거나,

매니저 클래스의 경우에는 싱글톤 객체로 사용하던지

아니면 차라리 `FindObjectOfType<>`을 통해 타입에 의존하는 방식을 선택해야 한다.

문자열 상수에 의존하는 것은 굉장히 위험한 방법이다.

<br>

`[2]`는 해결 방법이 비교적 간단하다.

```cs
StartCoroutine(nameof(MyCoroutine));
```

문자열 상수 대신 `nameof()`를 사용하면 된다.

`nameof(이름)`을 통해, 변수나 메소드, 클래스 등의 이름을 문자열 상수로 사용할 수 있다.

이렇게 작성하면 추후 메소드 이름이 변경되더라도 곧바로 컴파일 에러를 띄울테고,

비주얼 스튜디오 등에 내장된 식별자 이름 바꾸기 기능(**Ctrl + R + R**)을 통해 바꾸면 `nameof()`에 작성된 이름도 같이 바뀌게 되니 편리하다.

<br>

`[3]`의 경우에는 레이어 관리를 위한 별도의 정적 클래스를 작성하는 것이 좋다.

```cs
public static class Layers
{
    public const int PostProcessLayer = 8;
}
```

이런 식으로 작성하고,

해당 레이어를 참조할 때는 `Layers.PostProcessLayer` 상수를 참조하면 된다.

그리고 레이어 이름이나 값이 변경될 때는 `Layers` 클래스의 내부만 변경해주면 되니 변경에 따른 비용도 아주 적다.

<br>

이렇게 변경에 따른 추가적인 작업을 최소화할 수 있는 방향으로 코딩하는 습관을 들이는 것이 좋다.

솔직히 말하자면, 초보와 중수 이상을 가르는 기준 중 하나라고도 여길 수 있는, 매우 중요한 요소라고 생각한다.

