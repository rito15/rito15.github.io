---
title:  .NET 환경의 컴파일 - CLR, CIL, JIT, AOT
author: Rito15
date: 2021-06-06 04:43:00 +09:00
categories: [C#, C# Memo]
tags: [dotnet, clr, cil, jit, aot]
math: true
mermaid: true
---

# 닷넷 환경의 컴파일 과정
---

예전의 `C, C++`의 경우 개별 환경이 프로그램의 실행 시간에 영향을 미치는 문제가 있었다.

하지만 `Java`가 나오면서 컴파일된 바이트코드는 윈도우, 리눅스, 그 어떤 실행환경이든 `JVM`만 실행 가능하다면 실행할 수 있다는 장점을 통해 인기를 끌었고,

마이크로소프트는 이를 이용해 기존 문제를 해결할 수 있도록 `.NET` 환경에 가상 머신을 만들어서

`.NET` 환경의 언어로 개발된 `IL`(Intermediate Language, 중간 언어) 코드들은 `.NET Framework`가 설치된 어떠한 환경에서도 실행할 수 있도록 하였다.

`CLR`(Common Language Runtime, 공통 언어 런타임)은 이 가상머신의 구성요소 중 하나이며,

`CIL`(Common Intermidiate Language, 공통 중간 언어) 코드는 `.NET` 환경의 언어로 작성된 소스 코드를 컴파일했을 때 만들어지는 바이트코드를 의미하며, **어셈블리 코드**의 일종이다.

![image](https://user-images.githubusercontent.com/42164422/120899289-ecb3bc80-c669-11eb-8133-f17ed8d32673.png)

`.NET` 환경에서 개발할 때, 소스코드를 컴파일하게 되면 **컴파일 타임**에 해당 언어의 컴파일러에 의해 우선 바이트코드인 `CIL Code`를 생성한다.

그리고 `CLR`은 **런타임에** `JIT`(Just-In-Time) 또는 `AOT`(Ahead-Of-Time) 컴파일 방식을 이용하여 `CIL Code`를 OS가 이해할 수 있는 `Native Code` 로 변환하게 된다.

<br>

# JIT 컴파일
---

> `JIT` : Just-In-Time

<br>

그렇다면 `JIT` 컴파일이란 무엇일까?

우선, C언어로 작성된 프로그램은 다른 언어에 비해 빠르다고 알려져 있다.

왜냐하면 C언어는 소스코드 컴파일을 통해 곧바로 정적인 네이티브 코드(.exe, .dll)를 생성하기 때문이다.

반면에 Java, C#과 같은 언어들은 컴파일러가 생성한 `IL` 코드를 생성하여 갖고 있다가

프로그램을 실행시키면 런타임에 가상머신을 통해 동적으로 네이티브 코드를 생성하게 되는데,

이 때 가상머신에 의한 런타임 컴파일 방식을 `JIT` 컴파일이라고 한다.

<br>

`JIT` 컴파일이란 런타임에 `IL` 코드를 네이티브 코드로 바꾸는 컴파일 과정을 의미한다.

프로그램이 처음 로드될 때 가상머신은 `IL` 코드를 실행 환경에 알맞는 네이티브 코드로 컴파일한다.

그리고 다음 실행 시에는 `JIT` 과정 없이 해당 네이티브 코드를 실행하게 된다.

C#에서 성능 테스트를 위해 코드를 반복 수행할 때

첫 수행이 아주 느리고, 다음 수행부터 비슷하게 빠른 현상을 발견할 수 있는데, 이것은 바로 `JIT` 컴파일 때문이다.

<br>

`JIT` 컴파일 방식 덕분에, 개발자는 프로그램의 실행 환경을 고려하지 않고 개발할 수 있다는 장점이 있다.

하지만 `JIT` 컴파일 방식은 메모리를 많이 사용하고 속도도 떨어진다는 단점이 있다.

<br>

# AOT 컴파일
---

> `AOT` : Ahead-Of-Time

<br>

`JIT` 컴파일 방식의 느린 속도를 해결하기 위해 만들어진 컴파일 방식.

**컴파일 타임**에 중간 코드를 실행 환경에 적합한 `Native Code`로 컴파일을 모두 완료한다.

`CIL Code`를  C++ 컴파일러를 통해 `.NET Native` 이진코드로 변환하게 된다.

`.NET Native`는 C++와 유사하지만, C++처럼 Unmanaged는 아니다.

C++는 `CRT.dll`(C 런타임)을 사용하는 데 비해,

`.NET Native`는 `MRT.dll`(최소 CLR 런타임)을 사용하며 여기에 GC 코드가 포함되어 있다.

<br>

# 개념 정리
---

## **Native Code는 `.exe`, `.dll`을 의미하나요?**

- Yes. 

그런데 `CIL Code`도 `.exe`, `.dll` 내부에 포함되어 있다.

그러니까 어쨌든 `.exe`, `.dll`은 다 바이너리인데,

애초에 특정 실행 환경에 맞게 딱 정적으로 만들어진 바이너리를 `Native Code`라고 부르고,

`.NET` 환경에서 `CLR` 가상머신이 런타임에 `JIT` 컴파일을 통해 입맛대로 맛보고 즐길 수 있도록 만들어진 바이너리 내부에 있는 프로그램 코드 부분을 `CIL Code`라고 한다.

<br>

## **그래서 `.exe`, `.dll`이 뭐라구요?**

한마디로 정리하면 바이너리 파일(`Binary File`).

특정 실행 환경에 맞게 정적으로 만들어진 바이너리이면 `Native Code`,

`.NET` 환경에서 `JIT` 컴파일이 가능하도록 만들어진 바이너리이면 그냥 뭐.. 

`.NET Binary Code`라고 불러야 할 것 같다.

그리고 그 내부에는 다양한 데이터들을 담고 있으며, `CIL Code`도 포함되어 있다.

후술하겠지만, 결국 `.NET Binary Code`란 `Module`을 의미한다.

<br>

## **어셈블리? 어셈블리어? 어셈블러? 바이너리?**

이것도 용어가 참 헷갈리는데, 정리해보면

<br>

**어셈블리어(Assembly Language)**
 - 기계어와 고급 언어 사이의 수준을 가지며, 기계어와 일대일 대응이 되는 저급 언어
 - opcode + operand로 이루어져 있다.
 
**어셈블리(Assembly)**
 - 또는 어셈블리 코드. 어셈블리어로 작성된 코드를 의미한다.
 
**어셈블러(Assembler)**
 - 어셈블리 코드를 기계어 코드로 번역하는 도구
 
**디스어셈블러(Disassembler)**
 - 기계어 코드를 어셈블리 코드로 번역하는 도구
 
**바이너리(Binary)**
 - 또는 바이너리 코드. 기계어로 작성된 코드를 의미한다.

<br>

## **CIL Code는 '어셈블리'라고 부르던데요?**
 - `.NET`에서의 어셈블리는 단순히 어셈블리어로 작성된 어셈블리 코드를 의미하지 않는다.
 - `.NET`의 어셈블리는 **"버전 관리되고 배포 되는 프로그램의 단위"**를 의미한다.
 - 어쨌든 결국 `.NET`의 어셈블리는 `.exe`, `.dll` 또는 이들의 집합을 의미하며, 단일 파일이 하나의 어셈블리일 수도 있고, 여러 개의 파일이 모여 하나의 어셈블리를 이룰 수도 있다.
 - 그러니까 `.NET`에서 `Assembly`라고 부르는 녀석은 '`Binary File`의 집합'인 셈이다.
 
<br>

## **.NET Assembly 구조**

![image](https://user-images.githubusercontent.com/42164422/120902627-55a43000-c67c-11eb-947f-8268f9c64c52.png)

**.NET Assembly**
 - 1개 이상의 `Module`로 구성된다.
 - 모듈 중 하나는 반드시 다른 모듈 목록을 관리하는 `Manifest` 데이터를 담고 있어야 한다.
 
**Module**
 - 컴파일 완료된 `.dll`, `.exe` 바이너리 파일을 의미한다.
 - 어셈블리가 단일 모듈로 이루어진 경우, 바이너리 파일이 어셈블리라고 할 수 있다.
 - `Manifest`를 담고 있는 경우 `Primary Module`(주모듈), 아닌 경우 `Secondary Module`(부모듈)이라고 한다.

**Manifest**
 - 연결된 다른 모듈들의 정보를 갖는 메타데이터.
 - 어셈블리 내의 모든 모듈의 참조를 담고 있다.
 
**Type Metadata**
 - 어셈블리 내에서 사용되는 모든 타입에 대한 구체적인 정보를 담고 있다.
 - 이 요소 덕분에 리플렉션이 가능하다.

**CIL Code**
 - 각 언어의 소스 코드가 중간 언어 코드를 거쳐 기계어로 컴파일된 실제 프로그램 내용물.

<br>

## **결국 `CIL`의 정체는?**

- `.NET` 고유의 객체 지향 어셈블리 언어.

- `.NET` 환경에서 인간이 이해할 수 있는 가장 낮은 수준의 프로그래밍 언어.

<br>

`CIL` 코드 예시 :

```
// Hello World Program
.assembly Hello {}
.assembly extern mscorlib {}
.method static void Main()
{
    .entrypoint
    .maxstack 1
    ldstr "Hello, world!"
    call void [mscorlib]System.Console::WriteLine(string)
    ret
}
```

<br>

**그럼 `CIL`로 만들어진 파일의 확장자는?**
 - `.il`

<br>

- `Ilasm.exe`(IL 어셈블러)를 통해 `.il` -> `.dll` or `.exe` 생성

- `Ildasm.exe`(IL 디스어셈블러)를 통해 `.dll` or `.exe` -> `.il` 생성

<br>

## **그러니까 도대체 .NET 환경의 가상머신은 누구인가요?**

`CLR`이 가상머신인가 하니 이건 가상 머신의 일부 구성요소라고 하고,

`.NET`이 가상머신 역할을 하는거에요! 라고 모호하게 설명하기도 하고,

아니 `.NET Framework` 자체가 가상머신이라니까요? 이러기도 하고,

가상머신이란 녀석은 도대체 누구인가..

**결국 `CLR`이 맞다.**

<br>

## **그럼 .NET Framework의 정체는 무엇인가요?**

= `FCL`(Framework Class Library) + `CLR`

`FCL`은 `.NET Framework`를 대상으로 하는 모든 언어가 사용할 수 있는 공용 클래스 라이브러리,

`CLR`은 공통 언어 런타임 클래스이며, 보안, 메모리 관리, `JIT` 컴파일을 수행하는 가상 머신이다.

<br>

## **C언어가 (상대적으로) 빠른 이유**
- 컴파일을 완료하면 정적인(특정 환경에서 실행 가능한) 네이티브 코드를 생성한다.
- 이를 실행하면 `JIT` 컴파일 과정 거칠 것 없이 바로 실행되므로 빠르다.

<br>

## **Java와 C#이 (상대적으로) 느린 이유**
- 컴파일을 완료하면 `IL`(중간 언어) 코드인 `.class`, `CIL` 코드를 생성하고, 이를 바이너리에 포함시킨다.
- 각각 `JVM`과 `CLR`이 런타임에 `JIT` 컴파일을 통해 `Native Code`를 생성하는 과정을 거쳐야 하므로 느리다.

<br>

# 컴파일 과정 간략 정리
---

> (c) : Compile Time<br>
> (r) : Runtime

- `Source Code` -> **컴파일**(c) -> `CIL Code` -> **JIT 컴파일**(r) -> `Native Code`

- `Source Code` -> **컴파일**(c) -> `CIL Code` -> **AOT 컴파일**(c) -> `.NET Native Code`


<br>

# References
---
- <https://docs.microsoft.com/ko-kr/windows/uwp/dotnet-native/net-native-and-compilation>
- <https://guslabview.tistory.com/185>
- <https://hijuworld.tistory.com/9>
- <https://plas.tistory.com/44>
- <https://kyulingcompany.wordpress.com/2014/05/05/어셈블리assembly/>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/assembly/>
- <https://janghyeonjun.github.io/language/dot-net/>
- <https://blog.shovelman.dev/634>
- <https://ko.wikipedia.org/wiki/공통_중간_언어>
- <https://devblogs.microsoft.com/dotnet/announcing-net-native-preview/>
- <https://jacking.tistory.com/1207>
- <https://docs.microsoft.com/ko-kr/windows/uwp/dotnet-native/>

