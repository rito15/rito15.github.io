---
title: 실수를 스트링으로 변환할 때 포맷 지정하기
author: Rito15
date: 2021-05-16 01:33:00 +09:00
categories: [Memo, Cpp Memo]
tags: [cpp]
math: true
mermaid: true
---

# Headers
---

```cpp
#include <iostream>
#include <sstream>
#include <iomanip>
```

<br>

# Cout Format
---

- 출력하기 전에 `std::cout << std::fixed << std::setprecision()` 호출

```cpp
// 소수 첫째 자리에서 반올림
std::cout << std::fixed << std::setprecision(0);
std::cout << 12.345f << std::endl;
std::cout << 123.456f << std::endl;

// 소수 둘째 자리에서 반올림
std::cout << std::fixed << std::setprecision(1);
std::cout << 12.345f << std::endl;
std::cout << 123.456f << std::endl;
```

<br>

- 결과

```
12
123
12.3
123.5
```

<br>

# String Format
---

- `stringstream` 이용

```cpp
std::stringstream ss;
ss << std::fixed << std::setprecision(2) << 12.345f;

std::string str = ss.str();
std::cout << str << std::endl;
```

<br>

- 함수화

```cpp
std::string toStringFormat(float value, int precision)
{
    std::stringstream ss;
    ss << std::fixed << std::setprecision(precision) << value;
    return ss.str();
}

void main()
{
    std::cout << toStringFormat(1.2345f, 0) << std::endl;
    std::cout << toStringFormat(12.345f, 0) << std::endl;
    std::cout << toStringFormat(123.45f, 0) << std::endl
    std::cout << toStringFormat(1234.5f, 0) << std::endl;
}
```

<br>


# References
---
- <https://stackoverflow.com/questions/29200635/convert-float-to-string-with-precision-number-of-decimal-digits-specified>
