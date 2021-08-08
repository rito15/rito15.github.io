---
title: C# unsafe와 fixed 구문
author: Rito15
date: 2021-05-10 14:14:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# safe(안전한 코드)
---

- C#에서 일반적인 코드는 **"확인할 수 있는 안전한 코드"**이다.

- .NET에서 코드가 안전한지 확인할 수 있음을 의미한다.

- 메모리를 직접 할당하지 않고, 관리형 개체를 만든다.

<br>

# unsafe
---
- `unsafe` 컨텍스트 내에서는 **'확인할 수 없는 안전하지 않은 코드'**를 작성할 수 있다.

- 안전하지 않은 코드란, 위험한 것이 아니라 CLR에서 안전을 확인할 수 없다는 것을 의미한다.

## 허용되는 것들
  - 포인터 사용
  - 메모리 블록 할당 및 해제
  - 함수 포인터를 사용하여 메소드 호출

## unsafe가 필요한 경우
  - 포인터가 필요한 네이티브 함수를 호출하는 경우
  - 메모리 직접 접근이 필요한 경우

<br>

# fixed
---

C#에서 **"관리되는 힙(Managed Heap)"**에 할당되는 변수의 주소는 언제든 재배치될 수 있다.

따라서 보통의 경우에는 포인터를 사용하여 이 변수의 주소를 참조할 수 없다.

=> string 타입, 배열 타입 등

<br>

그런데 `fixed` 구문을 사용하여 포인터를 할당할 경우, 해당 변수의 주소를 고정시킬 수 있다.

`fixed` 구문은 `unsafe` 영역 내에서 사용할 수 있다.

<br>

# int, float 변수의 주소 확인
---

```cs
int a = 1, b = 1;
float c = 1f;

unsafe
{
    int* pa, pb;
    float* pc;

    pa = &a;
    pb = &b;
    pc = &c;

    IntPtr ipa, ipb, ipc;
    ipa = new IntPtr(pa);
    ipb = new IntPtr(pb);
    ipc = new IntPtr(pc);

    Console.WriteLine($"{a} -> {(int)ipa:X}");
    Console.WriteLine($"{b} -> {(int)ipb:X}");
    Console.WriteLine($"{c} -> {(int)ipc:X}");
}
```

![image](https://user-images.githubusercontent.com/42164422/117620691-af175d00-b1ab-11eb-902d-a9612f7bace4.png)

<br>

포인터의 주솟값을 얻으려면 `IntPtr` 구조체를 위와 같이 사용해야 한다.

그리고 `IntPtr` 타입을 16진수 포맷으로 출력하려면 정수로 형변환하여야 한다.

<br>

# 스트링과 배열의 주소 확인
---

```cs
string s1 = "AA";
string s2 = "AA";

int[] Arr = { 1, 2, 3 };

unsafe
{
    fixed (char* ps1 = s1, ps2 = s2)
    fixed (int* pArr = Arr)
    fixed (int* pArr2 = &Arr[0])
    {
        IntPtr ips1, ips2, ipArr, ipArr2;
        ips1 = new IntPtr(ps1);
        ips2 = new IntPtr(ps2);
        ipArr = new IntPtr(pArr);
        ipArr2 = new IntPtr(pArr2);

        Console.WriteLine($"{s1} -> 0x{(int)ips1:X}");
        Console.WriteLine($"{s2} -> 0x{(int)ips1:X}");
        Console.WriteLine("{1, 2, 3} -> " + $"0x{(int)ipArr:X}");
        Console.WriteLine("{1, 2, 3} -> " + $"0x{(int)ipArr2:X}");
    }
}
```

![image](https://user-images.githubusercontent.com/42164422/117620087-11239280-b1ab-11eb-9b1c-eb3944ca14fc.png)

<br>

## NOTE

값이 `"AA"`로 같은 두 스트링 변수 `s1`, `s2`의 주소값이 같은 것을 확인할 수 있다.

이는 스트링 타입의 특징으로, 컴파일 타임에 모든 문자열 상수에 대한 메모리를 할당하여

동일한 문자열은 동일한 메모리 주소에 할당되는 것이다.

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/unsafe-code>