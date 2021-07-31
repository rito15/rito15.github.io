# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# Race Condition
---

```cs
class Program
{
    private const int Count = 10000;
    private static int number = 0;

    private static void ThreadBody1()
    {
        for (int i = 0; i < Count; i++)
            number++;
    }
        
    private static void ThreadBody2()
    {
        for (int i = 0; i < Count; i++)
            number--;
    }

    static void Main(string[] args)
    {
        Task t1 = new Task(ThreadBody1);
        Task t2 = new Task(ThreadBody2);

        t1.Start();
        t2.Start();

        Task.WaitAll(t1, t2);

        Console.WriteLine(number);
    }
}
```

- 실행 결과 : `0`

<br>

`Count = 500000`로 바꿨을 때,

결과는 `222835`, `495324`, ... 등등

예측할 수 없는 값들이 나온다.

심지어 `number`를 `volatile`로 선언해도 마찬가지.

<br>

## **이유**?
 - **Race Condition(경쟁 상태)**

## **Race Condition**이란?
 - 두 개 이상의 프로세스가 공유 자원을 병행적으로(concurrently) 읽거나 쓸 때, 데이터에 대한 접근 순서에 따라 실행 결과가 달라지는 것

<br>

## **Atomic(원자성)**
 - 더이상 쪼개질 수 없는 성질
 - 중단되지 않는 연산의 성질을 의미한다.
 - 하나로 이루어져, 여럿으로 나뉠 수 없는 연산에 대해 atomic하다고 표현한다.
 - 경쟁 상태를 피하려면, 공유 자원에 대한 처리에 대해 원자성을 확보해야 한다.
 - 원자적이면 스레드 안전(Thread-safe)하다.

<br>

### **Atomic 예시**
 - 재화를 소모하고 아이템을 구매하는 일련의 트랜잭션에 대해, 원자성이 보장되지 않는다면 재화만 소모되고 아이템은 구매하지 못하는 참사가 발생할 수 있다.
 
 - 컨테이너의 아이템을 다른 컨테이너로 이동할 때 (기존 컨테이너에서 제거 + 새로운 컨테이너에 생성)이 원자적으로 이루어져야 하는데, 그렇지 않다면 아이템이 증발해버리거나 혹은 반대로 무한 복제가 되는 일이 발생할 수 있다.
   

<br>

# **Interlocked**
---

- 정수형 연산에 대해 원자성을 보장해준다.

- 성능은 당연히 저하된다.

<br>

위의 예제 코드에서 `number++`를 `Interlocked.Increment(ref number)`로,

`number--`를 `Interlocked.Decrement(ref number)`로 바꿔주면

의도대로 동작하게 된다.

<br>

## **Interlocked 연산 결과값 참조**

```cs
Interlocked.Increment(ref number):
int result = number;
```

위 코드에서 `result`의 값은 정확히 `number + 1` 연산의 결과값을 가져올까?

싱글 스레드 환경에서는 보장되지만,

멀티 스레드 환경에서는 이를 장담할 수 없다.

두 문장 사이에서 다른 스레드가 `number`의 값을 슬쩍 변경했으면

두 번째 문장에서 `number`의 값을 참조했을 때 의도와 다른 값을 얻게 된다.

<br>

따라서 `Interlocked`의 메소드들은 리턴값을 제공하는데,

```cs
int result = Interlocked.Increment(ref number);
```

이렇게 리턴값을 받아오면

이 값은 `Increment()` 연산의 결과값을 참조한다는 것을 보장할 수 있다.


<br>

# 정리
---

- 멀티 스레드 환경에서 공유 변수에 대한 연산과 참조는 원자성(atomic)을 보장해야 한다.
- 간단한 정수 연산의 경우, `Interlocked` 클래스를 이용하면 원자성을 보장할 수 있다.

<br>

# References
---
- <https://iredays.tistory.com/125>