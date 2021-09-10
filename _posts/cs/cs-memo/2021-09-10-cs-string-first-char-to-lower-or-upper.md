---
title: C# Span 사용하여 문자열의 첫 문자만 대소문자 변경하기
author: Rito15
date: 2021-09-10 17:51:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# 첫 문자만 간단히 대소문자 변경하기
---

`string`의 API만 사용하면 아주 간단히 첫 문자만 대소문자를 변경할 수 있다.

```cs
private static string FirstCharToLower(string str)
{
    return str[0].ToString().ToLower() + str.Substring(1);
}
```

하지만 이렇게 되면 여기서 힙 할당이 너무 많이 발생한다.

`str[0].ToString()`에서 한 번,

`.ToLower()`에서 한 번,

`str.Substring(1)`에서 한 번,

`_ + _`에서 한 번.

총 네 번의 힙 할당이 이루어진다.

<br>

# 힙 할당 최소화하여 변환하기
---

힙 할당을 최소화하려면 역시 `Span`, `ReadOnlySpan`을 사용해야 한다.

`Span`이 없는 옛날 버전은 아쉽게도 불가능하다.

```cs
private static string FirstCharToLower2(string str)
{
    ReadOnlySpan<char> rSpan = str.AsSpan();
    ReadOnlySpan<char> rHeadSpan = rSpan.Slice(0, 1);
    ReadOnlySpan<char> rTailSpan = rSpan.Slice(1);

    Span<char> destSpan = stackalloc char[str.Length];
    Span<char> destTailSpan = destSpan.Slice(1);

    rHeadSpan.ToLowerInvariant(destSpan);
    rTailSpan.CopyTo(destTailSpan);

    return destSpan.ToString();
}
```

방법은 간단하다.

문자열로부터 `.AsSpan()`을 통해 `ReadOnlySpan<char>`을 생성하고,

이를 다시 첫 문자와 나머지 문자열 부분으로 분리한다.

그리고 처리를 완료한 문자열을 받아줄 `Span<char>`을 스택 배열로 생성하고,

대소문자를 변경한 첫 문자와 나머지 문자열을 여기에 조립한다.

마지막으로 `.ToString()`을 호출하여 문자열을 완성하고 리턴하면 끝이다.

이런 방식을 통해 변환 과정 도중 힙 할당 없이 문자열을 변환할 수 있다.

<br>

# 처리 속도 벤치마크
---

![image](https://user-images.githubusercontent.com/42164422/132830690-6ce9029c-db03-4998-934a-5fe307d698d8.png)

언제나 `Span`을 이용한 방식이 20~30% 정도 더 빠른 속도를 보였다.



