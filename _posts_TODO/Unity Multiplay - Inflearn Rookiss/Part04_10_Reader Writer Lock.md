# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# Reader Writer Lock 개념
---

스레드 간에 공유되는 데이터가 있을 때,

항상 모든 스레드가 그 데이터를 읽고 쓰는 것은 아니다.

어떤 스레드는 해당 데이터를 읽기만 하고,

어떤 스레드는 해당 데이터를 쓰기만 하는 구조로 이루어져 있을 수 있다.

그리고 소수의 쓰기 스레드가 상대적으로 적은 횟수로 쓰기를 수행하고,

다수의 읽기 스레드가 상대적으로 빈번하게 읽기를 수행하는 경우가 많다.

<br>

이런 경우에도 일반적인 락을 구현하여 읽기/쓰기를 수행하는 동안에 항상 락을 설정하고 해제한다면

데이터를 단순히 읽기만 하여 값이 변경되지 않는 상황에도 불필요하게 임계 영역을 만들게 되므로

성능상 굉장히 손해라고 할 수 있다.

<br>

**ReaderWriterLock**은 데이터에 쓰기 위해 접근할 때는 락을 설정하고,

데이터를 단순히 읽기만 하는 동안에는 락을 설정하지 않도록 비대칭적인 락을 구현함으로써

위의 경우 성능상 이득을 얻을 수 있도록 한다.

<br>

# ReaderWriterLockSlim 클래스
---

- C#에는 이미 클래스로 사용하기 편리하게 구현되어 있다.

- `ReaderWriterLock`, `ReaderWriterLockSlim` 클래스가 구현되어 있으며, 후자가 최신버전이므로 이를 사용하면 된다.

- `try-finally` 처리가 필요하다.

```cs
private ReaderWriterLockSlim rwLock = new ReaderWriterLockSlim();

private void WriterThreadBody()
{
    try
    {
        rwLock.EnterWriteLock();

        // Do Something Here =========

        // ===========================
    }
    finally
    {
        rwLock.ExitWriteLock();
    }
}

private void ReaderThreadBody()
{
    try
    {
        rwLock.EnterReadLock();

        // Do Something Here =========

        // ===========================
    }
    finally
    {
        rwLock.ExitReadLock();
    }
}
```


<br>

# Reader Writer Lock 설계
---

- ReaderWriterLock을 직접 구현하기 위해, 미리 필요한 구조와 개념을 정리한다.

<br>

## **[1] 정책 설정**

- **재귀적 락 허용 여부**
  - `WriteLock`을 획득한 상태에서 다시 락을 획득할 수 있는지 여부를 결정한다.
  - 허용한다면, 가능한 중첩 횟수도 지정한다.
  
- **스핀락 정책**
  - 기본적으로 락은 스핀락으로 구현한다.
  - 스레드가 스핀락을 획득하기 위해 연속으로 시도하는 최대 횟수를 지정한다.
  - 최대 횟수를 넘어설 경우, `Yield()`를 통해 다른 스레드에게 CPU 점유를 넘긴다.

<br>

## **[2] 플래그 구조 설정**

- 플래그 크기 : `32 bit`

|위치|크기|이름|설명
|---|---|---|---|
|0  |1  |`Unused`       |사용되지 않는 영역|
|1  |15 |`WriteThreadID`|현재 쓰기를 수행 중인 스레드의 ID|
|16 |16 |`ReadCount`    |현재 읽기를 수행 중인 스레드 개수|

<br>

## **[3] 동작 설계**

### **Enter Write Lock**
- 아무도 읽거나 쓰지 않는 경우에만 쓸 수 있다.
- 쓰는 동안에는 `WriteThreadID`에 자신의 스레드 ID를 작성한다.

### **Exit Write Lock**
- 쓰기가 끝나면 `WriteThreadID`를 `0`으로 바꾼다.

### **Enter Read Lock**
- 아무도 쓰기를 수행 중이지 않은 경우, 자유롭게 읽을 수 있다.
- 읽는 동안에는 `ReadCount`를 하나 증가시킨다.
- 현재 쓰기를 수행 중인 스레드가 있을 경우, 대기한다.

### **Exit Read Lock**
- 읽기가 끝나면 `ReadCount`를 하나 감소시킨다.

<br>

# Reader Writer Lock 직접 구현
---

## 정책 공통
- 스핀락 정책 : 5000 번 시도마다 양보

<br>

## [1] 재귀적 락을 허용하지 않는 경우

```cs

```

<br>

## [2] 재귀적 락을 허용하는 경우

```cs

```

<br>

## 보완사항

현재 구현한 방식에서는 `ReadCount`가 `0`보다 큰 동안 쓰기 스레드는 계속 대기하게 된다.

읽기 동작은 상대적으로 오래 걸리지 않으므로 보통은 괜찮을 수 있지만,

만에 하나 읽기가 지속적으로 발생하여 `ReadCount`가 계속 `0`보다 크게 유지되는 경우를 생각해볼 수 있다.

<br>

이런 경우를 대비한다면,

`EnterWriteLock()` 메소드에서 `ReadCount`가 `0`이 될 때까지 계속 대기하는 것보다

`WriteThreadID`가 `0`인 경우, 바로 자신의 스레드 ID를 기록해놓고 대기하다가

`ReadCount`가 `0`이 되면 임계 영역을 만들고 진입하는 방식이 나을 것 같다.

<br>

이렇게 된다면 쓰기 스레드가 `EnterWriteLock()`으로 진입을 시도하는 동안

현재 읽기 중이었던 스레드들은 자연스럽게 읽기를 마치고 나가고,

읽으려고 시도하는 스레드는 `EnterReadLock()`에서 `WriteThreadID`를 확인하여

값이 `0`이 아니므로 대기하게 된다.

따라서 읽기가 무한히 지속되는 동안 계속 쓰지 못하는 상황은 발생하지 않게 된다.