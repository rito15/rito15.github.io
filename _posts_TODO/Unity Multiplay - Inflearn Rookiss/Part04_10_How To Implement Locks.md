# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>


# 동기화 영역에 따른 구분
---

## **1. 유저 모드 동기화**

- 유저 객체(커널에서 제공하지 않는 객체)를 사용한다.

- 대표적으로 크리티컬 섹션(Critical Section), 인터락(Interlocked)이 있다.

- 커널 모드 동기화보다 빠르다.

- 한 스레드가 크리티컬 섹션을 영원히 점유할 경우 라이브 락이 발생한다.

- 동일 프로세스 내에서만 동기화 가능하다.

<br>

## **2. 커널 모드 동기화**

- 커널 객체를 사용한다.

- 대표적으로 뮤텍스(Mutex), 세마포어(Semaphore), 이벤트(Event)가 있다.

- 다른 프로세스에 존재하는 스레드 간 동기화가 가능하다.

- 유저 모드에서 커널 모드로 변경해야 하므로, 유저 모드 동기화에 비해 성능 소모가 크다.

<br>

# 동기화 방법론에 따른 구분
---

## 1. 대기

- 크리티컬 섹션에 진입할 때까지 무한 대기한다.

## 2. 양보

- 크리티컬 섹션에 진입하지 못할 경우, 다른 스레드에 양보한다.

## 3. 이벤트

- 크리티컬 섹션에 진입하기 위해 대기하지 않고, 진입 가능한 타이밍을 커널로부터 통보받는다.

<br>

# 크리티컬 섹션 vs. 스핀 락
---

## **Critical Section**

- 한 번에 하나의 스레드만 접근 가능한 영역을 만든다.

- 하나의 스레드가 이미 영역을 점유한 경우, 진입을 원하는 다른 스레드는 대기한다.

- 락을 기다리며 대기하는 스레드는 블록(Block)되며, CPU 점유를 하지 않게 된다.

- 블록될 때 CPU 자원을 다른 스레드에게 넘기므로 컨텍스트 스위칭으로 인한 오버헤드가 발생한다.

<br>

## **Spin Lock**

- 바쁜 대기(Busy Waiting)가 발생한다.

- 락을 기다리는 동안에도 CPU 점유를 넘기지 않고, 계속 락 상태를 확인한다.

- 락이 길게 유지되는 동안에는 대기하는 스레드가 CPU 자원을 계속 소모하므로 낭비가 발생할 수 있다.

- 컨텍스트 스위칭이 발생하지 않아, 비교적 짧은 동작을 자주 수행해야 한다면 크리티컬 섹션보다 스핀 락을 사용하는 것이 좋다.

<br>

## CS vs. SL

- CS : 컨텍스트 스위칭 오버헤드 발생
- SL : 바쁜 대기로 인한 오버헤드 발생
- 길고 무거운 동작 -> CS
- 짧고 가벼운 동작 -> SL

<br>

# 락 구현 방법 총정리
---

## **1. Interlocked**
 - 특정 변수에 대해 동기화 및 연산을 수행한다.
 - `Interlocked.Increment(ref number)`와 같은 메소드를 사용한다.

<br>

## **2. Monitor**
 - 크리티컬 섹션을 만들고(진입하고), 해제한다.
 - `object` 타입 매개체가 필요하다.
 - `Monitor.Enter(obj)` ~ `Monitor.Exit()`
 - 크리티컬 섹션 내부에서 예외가 발생했을 경우를 위한 `try-finally` 처리가 필요하다.

<br>

## **3. lock 구문**
 - 내부적으로 Monitor 객체를 이용해 크리티컬 섹션을 만든다.
 - `lock(obj) { ~ }`

<br>

## **4. SpinLock**
 - 직접 구현하거나 SpinLock 클래스를 사용한다.
 - 

<br>

## **5. AutoResetEvent**
 - 크리티컬 섹션에 진입하려는 스레드끼리 락을 공유하는 lock 방식처럼 사용할 수 있고,
 - 해당 락에 관련 없는 다른 스레드가 락의 설정/해제를 관리할 수도 있다.
 - `.WaitOne()`을 통해 진입할 경우 `.Reset()`이 내부적으로 자동 호출된다는 특징이 있다.

 - `are = new AutoResetEvent(true)` : 객체를 진입 가능 상태로 생성
 - `are.WaitOne()` : 진입 가능해질 때까지 대기한다.
 - `are.Set()` : 진입 가능하도록 설정한다.
 - `are.Reset()` : 진입 불가능하도록 설정한다.

<br>

## **6. Mutex**
 - 

<br>

## **7. Semaphore**
 - 


<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/standard/threading/overview-of-synchronization-primitives>
- <https://mtding00.tistory.com/47>
- <https://iteenote.tistory.com/118>
- <https://brownbears.tistory.com/45>
- <https://3dmpengines.tistory.com/611>
- <https://rammuking.tistory.com/entry/Lock-종류-및-설명>