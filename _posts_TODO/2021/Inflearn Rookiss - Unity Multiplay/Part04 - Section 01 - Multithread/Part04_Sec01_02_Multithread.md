# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# OS (Windows)
---

## **커널 모드와 유저 모드**
 - 사용자 애플리케이션이 운영체제 데이터에 접근 및 수정하지 못하도록, 윈도우는 두 가지 프로세서 접근 모드를 사용한다.

## **커널 모드**
 - 모든 시스템 메모리와 CPU 인스트럭션에 접근이 허가된 프로세서의 실행 모드
 - 커널 영역, 유저 영역에 모두 접근 가능

## **유저 모드**
 - 사용자 애플리케이션 실행 모드
 - 유저 영역에만 접근 가능

## **모드 전환**
 - 사용자 애플리케이션에서 시스템 서비스를 호출할 때 유저 모드에서 커널 모드로 전환된다.
 - 유저 모드에서 커널 모드로의 전환은 프로세서를 커널 모드로 전환하게 하는 특별한 프로세서 인스트럭션의 사용을 통해 가능하다.
 - 운영체제는 이 인스트럭션을 통해 시스템 서비스가 요청됐음을 알아채고 스레드가 시스템 함수에 건넨 인자를 검증한 후 내부 함수를 실행한다.
 - 제어를 다시 유저 스레드로 되돌리기 전에 프로세서는 다시 유저 모드로 전환된다.
 - 이 방법을 통해 운영체제는 사용자 프로세스가 운영체제 커널 영역에 접근하지 못하도록 보호한다.
 
<br>

# Windows의 멀티쓰레딩
---

## **스레드 스케줄링**
 - 유저 영역에서 동시에 동작하는 것처럼 보이는 여러 개의 스레드는 실제로 시분할에 의한 잦은 컨텍스트 스위칭을 통해 순차적으로 CPU 자원을 할당받는 것이다.
 - 스레드 스케줄링은 CPU 자원을 여러 스레드에 어떻게 배분할지 결정하는 것으로, 커널 영역에서 담당한다.

## **기아 현상**
 - 상대적으로 스레드의 우선순위가 낮아 CPU 자원을 필요한 만큼 할당 받지 못하는 현상

## **스레드 개수와 성능**
 - 스레드의 컨텍스트 스위칭은 CPU에게 무거운 작업이다.
 - 많은 작업을 처리하기 위해 스레드 개수를 늘릴수록 오히려 성능 저하가 발생할 수 있다.
 - 따라서 가장 이상적인 스레드 개수는 CPU의 물리 코어 개수와 동일한 개수.
 
## **스레드의 메모리**
 - Heap(객체), Data(정적 변수) 영역은 공유
 - Stack 영역은 스레드마다 개별 관리
 - 공유되는 메모리 영역에 접근할 때 수많은 문제 발생

<br>

# C# Thread
---

## **스레드 생성 및 실행**

```cs
class Program
{
    private static void ThreadBody()
    {
        while(true)
        {
            Console.WriteLine("Thread Running");
        }
    }

    static void Main(string[] args)
    {
        Thread t = new Thread(ThreadBody);
        
        // 이름 지정 가능
        t.Name = "스레드 이름";

        // 스레드는 기본 Foreground로 설정된다
        t.IsBackground = true;
        
        // 스레드 시작
        t.Start();
        
        // 부모(메인) -> 자식 스레드 종료 기다리기
        t.Join();

        Console.WriteLine("Main Thread End");
    }
}
```

<br>

## **IsBackground** 속성
 - 스레드는 전경 스레드와 배경 스레드로 구분할 수 있다.
 - `IsBackground` = `true`일 경우 배경 스레드, `false`일 경우 전경스레드.

### **전경 스레드**
 - 기본적으로 생성되는 스레드는 전경 스레드(`IsBackground = false`)
 - 부모 스레드가 종료되어도 이에 영향 받지 않고 실행된다.
 - 프로그램을 닫았는데 프로세스가 남게 하는 원흉
 
### **배경 스레드**
 - 부모 스레드가 종료되면 같이 종료된다.

<br>

# Thread Pool
---

새로운 스레드를 만들어 실행시키는 것은 결국 CPU 입장에서 부담된다.

따라서 잠깐 동안 가벼운 기능을 수행할 스레드가 필요하다면

스레드풀을 이용하면 좋다.

```cs
class Program
{
    private static void ThreadBody(object state)
    {
        for(int i = 0; i < 100; i++)
        {
            Console.WriteLine($"Thread Running - {i}");
        }
    }

    static void Main(string[] args)
    {
        ThreadPool.QueueUserWorkItem(ThreadBody);
        ThreadPool.QueueUserWorkItem(ThreadBody);

        Console.WriteLine("Main Thread");
        
    }
}
```

<br>

## **특징**
 - 스레드바디는 `void Method(object state)` 형태여야 한다.
 - 기본적으로 배경 스레드로 동작한다.
 - 내부적으로 미리 만들어져 있는 스레드를 제공한다.
 
## **장점**
 - 사용 가능한 스레드의 최대 개수를 제한하여, 과도한 스레드 생성으로 인한 부하를 방지할 수 있다.<br>
   (CPU 코어 개수와 스레드 개수가 일치할 때가 가장 이상적)

## **주의사항**
 - 스레드풀은 가급적이면 작고 가벼운 병렬처리에 사용하는 것이 좋다.
 - 스레드풀의 최대 스레드 개수만큼 동시에 스레드가 작업하고 있다면, 추가 작업이 불가능해진다.

<br>

# Task
---

`Thread`와 `ThreadPool`의 장점을 모두 합친 느낌이다.

내부적으로 스레드풀을 이용해 구현되어 있다.

또다른 스레드풀이 아니고, `ThreadPool` 정적 클래스를 내부적으로 이용한다.

예를 들면 다음과 같다.

```cs
static void Main(string[] args)
{
    ThreadPool.SetMinThreads(1, 1);
    ThreadPool.SetMaxThreads(1, 1);

    Task task = new Task(() => {while(true); });
    task.Start(); // 스레드풀에서 스레드 한개 영원히 점거

    ThreadPool.GetAvailableThreads(out var amount, out _);
    Console.WriteLine(amount);
    // -> "0" 출력
    
    Thread.Sleep(1000);
}
```

<br>

대신, `ThreadPool`의 최대 스레드 한도를 넘겨서 실행할 수 있는 기능도 제공한다.

```cs
static void Main(string[] args)
{
    ThreadPool.SetMinThreads(1, 1);
    ThreadPool.SetMaxThreads(1, 1);

    Task task = new Task(() => {while(true); });
    task.Start(); // 스레드풀의 모든 스레드 점거

    Task task2 = new Task(
        () => Console.WriteLine($"Hi"), 
        TaskCreationOptions.LongRunning
    );
    task2.Start();
    
    Thread.Sleep(1000);
}
```

위와 같이 `Task` 객체를 생성할 때

`TaskCreationOptions.LongRunning`처럼 지정할 경우,

스레드풀에 지정된 스레드 개수에 영향을 주거나 받지 않고 개별적으로 스레드가 생성되어 동작한다.

<br>

## **API**

### `Task.Wait()`
 - 부모 스레드가 Task 스레드를 기다린다. (`Thread.Join()` 과 일맥상통)

<br>

# 코드 최적화로 인해 발생하는 문제
---

`Release` 모드로 코드를 컴파일하게 되면,

성능을 위해 내부적으로 다양한 코드 최적화가 이루어진다.

예를 들어

```cs
class Program
{
    private static bool _stop = false;

    private static void ThreadBody()
    {
        Console.WriteLine($"Thread Start - {Thread.CurrentThread.ManagedThreadId}");

        // _stop == true가 되기 전까지 대기
        while (!_stop);

        Console.WriteLine($"Thread End - {Thread.CurrentThread.ManagedThreadId}");
    }

    static void Main(string[] args)
    {
        Task task = new Task(ThreadBody);
        task.Start();

        Thread.Sleep(1000);

        _stop = true;

        Console.WriteLine("종료 요청 및 대기");
        task.Wait();

        Console.WriteLine("종료 성공");
    }
}
```

이런 코드가 있을 때

`Debug` 모드에서는 아무런 문제 없이 종료까지 이어질 수 있지만

`Release` 모드에서는 `ThreadBody`의

```cs
while (!_stop);
```

이 부분이

```cs
// 그저 예시..
if(!_stop)
{
    while(true);
}
```

이런식으로 바뀌어 버린다던가,

프로그래머가 예측하지 못한 방향으로 최적화가 되어

버그를 낼 수 있다.

<br>

이럴 때는

```cs
private volatile static bool _stop = false;
```

이렇게 `volatile` 키워드를 접근제어자 뒤에 넣어주면 된다.

`volatile` 키워드를 명시한 필드는 릴리즈 빌드에서 코드 최적화가 일어나지 않게 되어,

여러 스레드가 같은 필드를 참조하는 경우에 발생하는 예기치 못한 문제를 방지할 수 있다.

하지만 `volatile`은 코드 최적화 방지 뿐만 아니라,

읽고 쓰는 명령에 대해서 무조건 메모리에 직접 읽고 쓰게 하는 등

복잡한 문제가 있으므로 사용을 권장하지 않는다고 한다.

<br>

그러니까 결국 공유 자원에 대해서는 앞으로 비권장 `volatile` 안쓰고 `lock`을 쓰겠다는 의미.

<br>

# 정리
---

- 전경 스레드는 부모 스레드가 죽어도 알아서 돌아간다.
- 배경 스레드는 부모 스레드가 죽으면 함께 죽는다.
- `Thread`는 기본적으로 전경 스레드, `ThreadPool`과 `Task`의 스레드는 기본적으로 배경 스레드로 동작한다.
- 혹시나 `Thread`를 쓸 때, 의도치 않게 전경 스레드로 동작시켜 미아로 남기지 않도록 주의한다.

<br>

- `ThreadPool`은 워커 스레드를 미리 준비해놓고, 큐에 담겨 오는 작업들을 내부적으로 `Thread`를 할당시켜 동작한다.
- `Task`는 `ThreadPool`을 이용한 라이브러리의 일종이다.
- 그러니까 `ThreadPool`, `Task`는 모두 `Thread`의 응용이다.

<br>

- 금방 끝나는 작업에는 `Task`를 이용한다.
- 오래 걸리는 작업에는 `Thread` 또는 `LongRunning`으로 지정된 `Task`를 이용한다.

<br>

# References
---
- <https://wikidocs.net/691>
- <https://jungwoong.tistory.com/40>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/keywords/volatile>