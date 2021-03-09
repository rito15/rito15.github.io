---
title: C++ Smart Debugging
author: Rito15
date: 2021-02-04 16:56:00 +09:00
categories: [Memo, C++ Memo]
tags: [cpp]
math: true
mermaid: true
---

# Note
---
C++에는 미리 정의된 동적 매크로가 있다.

## `__FILE__`
  - 해당 위치의 소스파일 경로를 문자열로 가져온다.

## `__LINE__`
  - 해당 위치의 줄 번호를 정수로 가져온다.

<br>
그리고 매크로의 매개변수를 무조건 스트링으로 변환하여 가져올 수 있는 방법이 존재한다.

## `#define MACRO(x) #x`
  - x에 위치한 코드를 문자열로 변환하여 가져온다.

<br>

이를 이용하면 해당 소스코드와 실행 위치 정보를 간단히 출력할 수 있다.

```cpp
#include <iostream>
using namespace std;

#define ShowCodeInfo(x) cout << "Code : " << #x << endl\
	<< "Line : " << __FILE__ << " : " << __LINE__ << endl << endl;

void main()
{
	int a;

	ShowCodeInfo(cout << test);
}
```

![image](https://user-images.githubusercontent.com/42164422/106862724-da049780-670a-11eb-9920-a60a667bb282.png)

그리고 이를 디버깅에 활용할 수 있다.

<br>

# Smart Debugging
---

```cpp
#include <iostream>
using namespace std;

#define ShowCodeInfo(x) cout << "Code : " << #x << endl\
	<< "Line : " << __FILE__ << " : " << __LINE__ << endl << endl;

#define Assert(x, value) x; \
if(x != value) {        \
    cout << "Assert : [" << #x << "] must be [" << value << "], but [" << x << "]" << endl;\
    ShowCodeInfo(x);    \
    __debugbreak();     \
}

void main()
{
    int a = 1;
    int b = 2;

    Assert(a + b, 3);
    Assert(a + b, 4);
}
```

- `Assert(code, value);` 형태로 사용한다.
- 해당 코드의 결괏값이 value와 동일하면 정상적으로 실행된다.
- 해당 코드의 결괏값이 value와 다를 경우, 중단점을 트리거하고 코드의 정보와 현재값, 의도한 값, 소스 코드 정보와 해당 라인까지 모두 출력해준다.

![image](https://user-images.githubusercontent.com/42164422/106864296-015c6400-670d-11eb-969a-6657d1c48c4d.png)

