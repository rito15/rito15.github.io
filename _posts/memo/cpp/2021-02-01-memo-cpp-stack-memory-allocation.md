---
title: C++ 스택 메모리 동적 할당
author: Rito15
date: 2021-02-01 18:45:00 +09:00
categories: [Memo, C++ Memo]
tags: [cpp]
math: true
mermaid: true
---

# Memo
---
- ## _alloca
  - 스택에 메모리를 동적으로 할당해준다.
  - 함수의 리턴으로 전달하면 안된다.
  - 블록이 종료되면 자동으로 할당 해제된다.
  - 공간 할당 불가능한 경우 Stack Overflow 에러가 발생할 수 있으니 주의
  - 예외가 발생한 경우 구조적 예외처리(SEH)로 받아야 함

|---|---|
|size_t `size`|할당할 배열 크기(길이 * sizeof(타입))|
|`return` void*|할당된 배열의 주소(타입 캐스팅 필요)|

```cpp
int length = 10;

// 원했던 것 : char message[length]
// 하지만 배열의 크기는 상수로 지정해야 하기 때문에 아래처럼 사용
char* message = (char*)_alloca(length * sizeof(char));
```

<br>

# 참고 : _Malloca
---
- ## _Malloca
  - _alloca()의 보안 기능 강화 버전
  - size가 _ALLOCA_S_THRESHOLD(1024)보다 큰 경우, 스택이 아니라 힙에 할당됨
  - 디버그 모드에서는 항상 힙에 할당
  - _alloca()와 달리, _freea()를 사용해 메모리를 해제해야 함

|---|---|
|size_t `size`|할당할 배열 크기(길이 * sizeof(타입))|
|`return` void*|할당된 배열의 주소(타입 캐스팅 필요)|

```cpp
int length = 10;
char* message = (char*)_Malloca(length * sizeof(char));
_freea(message);
```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/cpp/c-runtime-library/reference/alloca?view=msvc-160>
- <https://docs.microsoft.com/ko-kr/cpp/c-runtime-library/reference/malloca?view=msvc-160>
- <https://docs.microsoft.com/ko-kr/cpp/cpp/structured-exception-handling-c-cpp?view=msvc-160>
