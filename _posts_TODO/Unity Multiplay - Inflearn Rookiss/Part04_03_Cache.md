# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# 캐시 이론
---

## **CPU 구성**
 - CPU 코어(제어 장치, 연산 장치, 레지스터)
 - L2 캐시
 - 버스 인터페이스 : CPU, 메모리, 각종 I/O 장치 간의 데이터 전송 통로
 - ...

## **CPU 코어 구성**

### **산술 논리 장치(Arithmetic Logical Unit, ALU)**
 - 산술(add, sub, mul, div), 논리(and, or, not), 비트 연산 수행

### **상태 레지스터(Status Registe,: SREG)**
 - ALU가 가장 최근에 실행한 연산 명령의 결과와 상태를 저장

### **범용 레지스터(General Purpos Register)**
 - 프로그램 수행 중, 중간 연산 결과 또는 데이터를 일시적으로 저장

### **스택 포인터 레지스터(Stack Pointer Register)**
 - 서브루틴 호출 또는 인터럽트 발생 시 다시 돌아올 복귀 주소 저장

### **L1 캐시(L1 Cache Memory)**
 - CPU가 가장 빠르게 접근할 수 있는 캐시
 - CPU와 메인 메모리의 속도차로 인해 발생하는 병목 현상 완화

<br>

## **캐시의 존재 이유**

CPU의 처리 속도는 컴퓨터 하드웨어 중 가장 빠르다.(GPU 제외..)

하드디스크가 가장 느리고,

메인 메모리는 더 빠르지만 그래도 CPU보다 느리다

CPU는 항상 메인 메모리와 데이터를 주고 받아야 하는데,

CPU 입장에서는 메인 메모리가 답답하게 느리다.

따라서 이를 개선하기 위해

CPU에 보다 가까운 위치에 작은 기억 장치를 만든 것이

바로 캐시 메모리(Cache Memory)이다.

<br>

CPU에 가장 가까운 것이 L1 캐시(코어 내부에 존재),

그다음은 L2 캐시(CPU 내부에 존재),

그다음은 L3 캐시(메인보드에 존재), ....

이렇게 구성되어 있으며,

역할은 간단하다.

자주 사용되는 데이터를 임시로 저장하여 CPU가 아주 빠르게 접근할 수 있도록 하는 것.

<br>

## **자주 사용되는 데이터?**

자주 사용되는 데이터라는 것은 어떻게 판별할까?

두 가지 조건으로 판별한다.

<br>

### **1. 시간 지역성(Temporal Locality)**
 - 방금 참조한 데이터를 또 참조할 가능성이 높다.

### **2. 공간 지역성(Spacial Locality)**
 - 방금 참조한 데이터의 근처에 있을 수록 금방 참조할 가능성이 높다.

이렇게 두 가지 조건에 부합하는 데이터들을 캐시 메모리에 저장하게 된다.

<br>

## **캐시 히트(Cache Hit)**
 - CPU가 참조하려는 데이터가 캐시 메모리 내에 존재하는 것

## **캐시 미스(Cache Miss)**
 - CPU가 참조하려는 데이터가 캐시 메모리 내에 존재하지 않는 것

## **캐시 적중률(Cache Hit Ratio)**
 - 캐시 히트 수/전체 참조 횟수

<br>

# 캐시 메모리의 성능
---

캐시 히트 여부에 따라 성능이 얼마나 차이날까?

코드를 통해 직접 테스트해본다.

```cs
class Program
{
    static void Main(string[] args)
    {
        int[,] arr = new int[10000, 10000];

        //[1]
        {
            long begin = DateTime.Now.Ticks;
            for (int y = 0; y < 10000; y++)
                for (int x = 0; x < 10000; x++)
                    arr[y, x] = 1;
            long end = DateTime.Now.Ticks;
            Console.WriteLine($"[y, x] - {end - begin}");
        }
        
        //[2]
        {
            long begin = DateTime.Now.Ticks;
            for (int y = 0; y < 10000; y++)
                for (int x = 0; x < 10000; x++)
                    arr[x, y] = 1;
            long end = DateTime.Now.Ticks;
            Console.WriteLine($"[x, y] - {end - begin}");
        }
    }
}
```

동일한 크기의 이차원 배열을 순회한다.

`[1]`에서는 `[y, x]`꼴로 `x`가 1차원 부분을 1칸씩 순회하며,

`[2]`에서는 `[x, y]`꼴로 `x`가 2차원 부분을 1칸씩 순회한다.

<br>

결과는 다음과 같다.

```
// 첫 번째 실행
[y, x] - 2249984
[x, y] - 7679990

// 두 번째 실행
[y, x] - 2697532
[x, y] - 8670011
```

수학적으로 보면 둘다 이차원 배열을 차례대로 순회하지만,

실제로는 성능 면에서 굉장히 차이가 남을 알 수 있다.

그 이유는 역시 캐시 메모리에 있다.

<br>

`[a, b]`꼴의 이차원 배열이 있다면,

메모리는 `[a, 0]`, `[a, 1]`, `[a, 2]`, ...

이렇게 인접해 있다.

따라서 `[1]`에서는 한 칸씩 인접한 메모리를 순회하므로

공간적 지역성에 따른 캐시 히트로 캐시 적중률이 매우 높고,

`[2]`에서는 10000 칸씩 떨어진 메모리를 순회하므로

전부 캐시 미스가 발생하여 캐시 적중률이 바닥인 것이다.

<br>

# 캐시 일관성 문제(Cache Coherence)
---

두 개의 스레드가 각각의 코어에서 작동한다고 가정한다.

하나의 스레드가 특정 데이터의 값을 변경해서 자신의 캐시에 올려놓았을 때,

아직 메인 메모리에는 변경이 적용되지 않은 상황이다.

이때 다른 스레드가 동일 데이터에 접근할 경우,

이 스레드는 아직 변경되지 않은 값을 참조하는 문제가 발생할 수 있다.

이를 캐시 일관성 문제라고 한다.

<br>

# 정리
---

- 메모리 상의 인접한 데이터를 연속적으로 참조하면 캐시 히트를 통해 성능상 이득을 얻을 수 있다.
- 그러므로 반복문처럼 인접 메모리 연속 참조가 가능한 경우, 신경써주면 좋다.

<br>

# References
---
- <https://12bme.tistory.com/402>
- <https://coding-factory.tistory.com/351>
- <https://hadaney.tistory.com/24>
- <https://m.blog.naver.com/rmflqhd/140166168124>
- <https://velog.io/@ckstn0777/컴퓨터구조-컴퓨터-구조와-기능-CPU>