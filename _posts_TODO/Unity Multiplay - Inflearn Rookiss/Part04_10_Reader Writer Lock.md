# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# Reader Writer Lock 개념
---



<br>

# ReaderWriterLockSlim 클래스
---

- C#에는 이미 클래스로 사용하기 편리하게 구현되어 있다.

- `ReaderWriterLock`, `ReaderWriterLockSlim` 클래스가 구현되어 있으며, 후자가 최신버전이므로 이를 사용하면 된다.

```cs
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

# Reader Writer Lock 직접 구현하기
---

## [1] 정책 설정


## [2] 플래그 구조 설정


## [3] 클래스 정의




<br>


