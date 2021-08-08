---
title: C# ArraySegment&lt;T&gt;, Span&lt;T&gt;, Memory&lt;T&gt;
author: Rito15
date: 2021-08-08 20:00:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, array]
math: true
mermaid: true
---

# Array
---

- <https://docs.microsoft.com/ko-kr/dotnet/csharp/programming-guide/arrays/single-dimensional-arrays>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.array?view=net-5.0>

<br>

## **특징**
- 고정된 크기의 일차원 배열을 만든다.
- 배열은 관리되는 힙 메모리에 저장된다.

<br>

# ArraySegment&lt;T&gt;
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.arraysegment-1?view=net-5.0>
- <https://jacking75.github.io/csharp_ArraySegment/>

<br>

## **특징**
- 힙에 새로운 배열을 할당하지 않고, 이미 존재하는 배열의 일부를 참조할 수 있다.
- 
- 인덱서를 통해 순회 참조할 수 있다.
- `foreach`를 통해 순회 참조할 수 있다.
- 세그먼트의 인덱서를 통해 내용을 변경할 경우, 참조 배열의 해당 위치의 값이 변경된다.

<br>

## **생성**

```cs
int[] array = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

// 배열 전체 참조
ArraySegment<int> seg1 = new ArraySegment<int>(array);

// 인덱스 5부터 7까지 3칸 참조
ArraySegment<int> seg2 = new ArraySegment<int>(array, 5, 3);
```

<br>

## **프로퍼티**

- `.Array` : 참조 중인 배열(읽기 전용)
- `.Offset` : 참조하는 배열의 시작 인덱스
- `.Count` : 참조하는 배열 영역의 길이

<br>

## **메소드**

- `Slice(int index)`
  - 세그먼트의 특정 인덱스부터 끝까지 잘라내어 새로운 세그먼트를 생성한다.

- `Slice(int index, int count)
  - 세그먼트의 특정 인덱스부터 지정 길이만큼 잘라내어 새로운 세그먼트를 생성한다.

<br>

- `CopyTo(T[] dest)`
  - 세그먼트의 내용을 대상 배열의 첫 인덱스 위치부터 세그먼트 길이만큼 복제한다.
  
- `CopyTo(T[] dest, int destIndex)`
  - 세그먼트의 내용을 대상 배열의 지정 인덱스 위치부터 세그먼트 길이만큼 복제한다.

- `CopyTo(ArraySegment<T> dest)`
  - 세그먼트의 내용을 대상 세그먼트에 복제한다.
  - 세그먼트의 길이는 반드시 `dest` 세그먼트의 길이보다 작거나 같아야 한다.

<br>

- `ToArray()`
  - 세그먼트의 내용을 모두 복제하여 새로운 배열을 생성한다.


<br>

# Span&lt;T&gt;
---

- <https://docs.microsoft.com/ko-kr/dotnet/api/system.span-1?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/operators/stackalloc>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.runtime.interopservices.memorymarshal?view=net-5.0>
- <https://jacking75.github.io/NET_Span_5_Reasons_to_Use/>
- <https://m.blog.naver.com/oidoman/221677509349>

<br>

## **특징**

- 스택에 할당되는 `readonly ref` 구조체
- 클래스 또는 구조체의 필드로 선언될 수 없다.
- `ArraySegment<T>`에 비해 성능이 좋다.
- 관리되는 힙, 관리되지 않는 힙, 스택의 배열을 모두 참조할 수 있다.

- `unsafe`로만 가능했던 기능들을 `Span<T>`을 통해 안전하게 구현할 수 있다.
- 관리되는 힙 할당을 거쳐야만 했던 기능들을 `Span<T>`을 통해 힙 할당 없이 구현할 수 있다.
- `MemoryMarshal`의 지원을 통해 다양한 기능을 사용할 수 있다.
- 인덱서를 통해 `Span`이 참조하고 있는 배열의 해당 위치의 값을 직접 수정할 수 있다.

<br>

## **생성**

- 힙의 배열 일부를 참조

```cs
int[] array = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

// 배열 전체에 대한 참조
Span<int> span1 = new Span<int>(array);

// 배열의 인덱스 5 ~ 7 참조
Span<int> span2 = new Span<int>(array, 5, 3);
```

- 스택 배열 직접 생성

```cs
// 스택 메모리에 배열을 생성한다.
// 관리되지 않는 타입(값 타입)의 배열만 생성할 수 있다.
Span<int> iSpan1 = stackalloc int[10];
Span<int> iSpan2 = stackalloc int[] { 0, 1, 2, 3, 4, 5 };
```

<br>

## **프로퍼티**

- `IsEmpty` : 빈 `Span`인지 여부
- `Length` : `Span`이 가리키는 영역의 인덱스 길이

<br>

## **메소드**

- `Clear()`
  - `Span`이 참조하는 배열 영역의 값을 모두 `default`로 초기화한다.

- `Fill(T value)`
  - `Span`이 참조하는 배열 영역을 모두 지정한 값으로 초기화한다.

<br>

- `Slice(int start)`
  - `Span`이 참조하던 영역의 인덱스 중 `start`부터 끝까지 참조하는 새로운 `Span`을 생성하여 리턴한다.

- `Slice(int start, int length)`
  - `Span`이 참조하던 영역의 인덱스 중 `start`부터 `length` 길이만큼 참조하는 새로운 `Span`을 생성하여 리턴한다.

<br>

- `CopyTo(Span<T> dest)`
  - `Span`이 참조하던 영역의 내용을 `dest`가 참조하는 실제 영역에 복제한다.
  - `Span`의 길이는 `dest`보다 작거나 같아야 한다.

- `TryCopyTo(Span<T> dest)`
  - `CopyTo()`와 같지만, 복제에 실패할 경우 예외를 발생시키지 않고 `false`를 리턴한다.

<br>

- `ToArray()`
  - `Span`이 참조하는 영역을 복제하여 새로운 배열을 생성한다.

<br>

## **확장 메소드**

- `Reverse()`
  - `Span`이 참조하는 영역의 내용을 뒤집는다.

- `Contains(T value)`
  - 해당 `Span` 내에 `value`가 포함되어 있는지 여부를 `bool` 타입으로 리턴한다.

- `IndexOf(T value)`
  - 해당 `Span` 내에서 `value`가 존재하는 인덱스를 리턴한다.
  - 존재하지 않으면 `-1`을 리턴한다.

- `IndexOf(ReadOnlySpan<T> sub)`
  - 해당 `Span` 내에서 `sub` 영역과 일치하는 첫 인덱스를 리턴한다.
  - 일치하는 영역이 없으면 `-1`을 리턴한다.
  - 예시 : `.IndexOf(stackalloc int[] { 1, 2 })`

- `IndexOfAny(T a, T b)`
  - 해당 `Span` 내에서 `a`, `b` 중 하나라도 같은 값이 존재하는 첫 인덱스를 리턴한다.
  - 앞에서부터 찾은, 가장 빠른 인덱스를 리턴한다.

- `IndexOfAny(T a, T b, T c)`
- `IndexOfAny(ReadOnlySpan<T> values)`
  - 해당 `Span`에서 지정한 값들 중 하나라도 일치하는 값이 존재하는 첫 인덱스를 리턴한다.

- `LastIndexOf()` : `IndexOf()`를 뒤에서부터 검사한다.
- `LastIndexOfAny()` : `IndexOfAny()`를 뒤에서부터 검사한다.

<br>

# ReadOnlySpan&lt;T&gt;
---

- <https://docs.microsoft.com/ko-kr/dotnet/api/system.readonlyspan-1?view=net-5.0>

<br>

## **특징**

- 스택에 할당되는 `readonly ref` 구조체
- 클래스 또는 구조체의 필드로 선언될 수 없다.
- `ReadOnlySpan`의 인덱서는 `readonly`이므로 값을 읽을 수만 있고 변경할 수는 없다.
- 문자열과 같은 불변의 데이터 타입과 함께 동작하기에 용이하다.

<br>

## **프로퍼티, 메소드**

- `.Clear()`, `.Fill()`과 같이 내부를 변경하는 메소드는 존재하지 않는다.
- 대부분 `Span<T>`와 API가 같다.

<br>

# Memory&lt;T&gt;
---




<br>

# ReadOnlyMemory&lt;T&gt;
---




<br>

# 활용
---

## **[1]배열의 내용 복제하기**

```cs
Array.Copy(from, offset, to, offset, length);
```

위 방식보다

```cs
new ReadOnlySpan<byte>(from, offset, length).CopyTo(new Span<byte>(to, offset, length));
```

이 방식이 훨씬 빠르다.

복제할 길이가 길수록 격차는 더 커진다.

![image](https://user-images.githubusercontent.com/42164422/128627834-eae835d3-e738-481c-9b97-591265d35fb6.png)

<br>

## **[2]관리되지 않는 타입들을 `byte[]`로 변환하기**

```cs
byte[] buffer = new buffer[1024];
float data = 1234f;
int offset = 120;

// (1)
ReadOnlySpan<byte> bSpan = MemoryMarshal.AsBytes(stackalloc[] { data });
bSpan.CopyTo(new Span<byte>(buffer, offset, bSpan.Length));

// (2)
ReadOnlySpan<float> fSpan = MemoryMarshal.CreateReadOnlySpan(ref data, 1);
ReadOnlySpan<byte> bSpan = MemoryMarshal.Cast<float, byte>(fSpan);
bSpan.CopyTo(new Span<byte>(buffer, offset, sizeof(float)));
```

- 값 타입들을 크기에 맞게 `ReadOnlySpan<byte>`로 변환하고, 목표 `byte[]` 배열에 복사한다.
- 벤치마크 결과 `(1)`보다 `(2)`의 방식이 `20%` ~ `30%` 더 빨랐다.

<br>

## **[3] `byte[]`로부터 알맞은 타입으로 값 읽어들이기**

- 공통 환경

```cs
byte[] buffer = new byte[1024];
int offset = 123;
float data = 123.456f;
float destValue;

// buffer의 offset 인덱스부터 4칸에 123.456 값 집어넣기
MemoryMarshal.AsBytes(stackalloc[] { data }).CopyTo(new Span<byte>(buffer, offset, 4));
```

<br>

- `BitConverter` 사용

```cs
// (1)
destValue = BitConverter.ToSingle(buffer, offset);

// (2)
destValue = BitConverter.ToSingle(new ReadOnlySpan<byte>(buffer, offset, 4));
```

<br>

- `MemoryMarshal` 사용

```cs
// (3)
ReadOnlySpan<float> fSpan = 
    MemoryMarshal.Cast<byte, float>(new ReadOnlySpan<byte>(buffer, offset, 4));
destValue = fSpan[0];

// (4)
destValue = MemoryMarshal.Read<float>(new ReadOnlySpan<byte>(buffer, offset, 4));
```

<br>

- 위의 4가지 벤치마크 결과

![image](https://user-images.githubusercontent.com/42164422/128634614-3d46ce8e-5d6c-4573-af82-d40200c5a93b.png)

<br>

- **결론**
  - `BitConverter`보다 `MemoryMarshal`이 훨씬 빠르다.
  - `BitConverter`의 두 방식은 큰 차이는 없으나 `(1)`이 조금 더 빠르다.
  - `MemoryMarshal`의 두 방식은 속도 차이가 없다.

<br>


## **[4] 부분 문자열 만들기**

```cs
string str = "abcde01234";
string subStr = str.Substring(2, 4);
```

위와 같이 `.Substring()`을 통해 문자열을 자르면

해당 길이만큼 새롭게 힙에 할당된 문자열이 생성된다.

<br>

```cs
ReadOnlySpan<char> charSpan = str.AsSpan(2, 4);
```

이렇게 `ReadOnlySpan<char>`로 받으면

할당 없이 부분 문자열을 받을 수 있다.

<br>

```cs
// byte[] buffer;
// int offset;

int strLen =
    Encoding.UTF8.GetBytes(
        charSpan,
        new Span<byte>(buffer, offset, charSpan.Length * 4)
    );
```

심지어 이렇게 `ReadOnlySpan<char>`를 그대로 인코딩하여 `byte[]` 배열에 옮겨줄 수도 있고

<br>

```cs
Span<char> charSpan2 = stackalloc char[strLen];

Encoding.UTF8.GetChars(
    new ReadOnlySpan<byte>(buffer, offset, strLen),
    charSpan2
);
```

문자열이 인코딩된 `ReadOnlySpan<byte>`를 다시 디코딩하여

`Span<char>`에 옮겨줄 수도 있다.

그리고 역시 이 모든 과정에서 힙 메모리 할당량은 `0`이다.


<br>


## **[5] 문자열 자르기(Split)**

```cs
string str = "12,345,6789";
string[] strArr = str.Split(',');
```

특정 문자를 기준으로 문자열을 나눈다.

위의 경우 크기가 3인 스트링 배열이 생성되며,

무자비하게 힙 할당이 생긴다.

참고로 이 경우에 할당되는 힙 메모리 크기는 `144 바이트`이다.

<br>

```cs

```




TODO 


https://www.meziantou.net/split-a-string-into-lines-without-allocation.htm

"string".Split(char seperator) 로 분리 가능하게 만들기







<br>

## **[6] 문자열 자르고 파싱하기**

```cs
string str = "12|34";

```