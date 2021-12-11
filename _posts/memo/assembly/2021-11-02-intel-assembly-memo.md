---
title: Intel Assembly 기초 간단 정리
author: Rito15
date: 2021-11-02 03:54:00 +09:00
categories: [Memo, Assembly]
tags: [assembly, masm, memo]
math: true
mermaid: true
---


# 목표
---
- 비주얼 스튜디오에서 디스어셈블러로 어셈블리 코드를 읽었을 때, 대충이라도 흐름과 동작 이해하기

<br>



# 어셈블리 문법 종류
---

- `Intel`, `AT&T` 문법이 있다.

- `eax`, `[eax]` 꼴의 문법은 `Intel`이며,
- `%eax`, `(%eax)` 꼴의 문법은 `AT&T`이다.

- `Intel` 문법을 따르는 대표적인 예시로 **MASM**(Microsoft Macro Assembler), **NASM**(Netwide Assembler) 등이 있다.

<br>



# 알아두기
---

<details>
<summary markdown="span">
...
</summary>

## **어셈블리 연산의 특징**

메모리 주소 간의 연산을 수행할 때,

특정 주소에서 주소로 직접 연산할 수 없고, 반드시 레지스터를 거쳐간다.

예를 들어 메모리 **0x24** 위치의 값을 **0x9A**에 옮기려면

우선 **0x24**에서 `rax`로 옮기고, `rax`에서 **0x9A**로 옮기는 식이다.

<br>

## **어셈블리 명령어와 흐름 제어**

어셈블리 코드 내의 모든 명령어는, 예를 들어

```
mov    rcx,qword ptr [rbp+60h]  
mov    qword ptr [rbp+30h],rcx  
lea    rcx,[rbp+20h]
```

이런 한 줄 한 줄의 명령어는 각자 `1byte` 이상 할당되어 메모리에 저장된다.

```
00007FF80FE20E2A  mov    rcx,qword ptr [rbp+60h]  
00007FF80FE20E2E  mov    qword ptr [rbp+30h],rcx  
00007FF80FE20E32  lea    rcx,[rbp+20h]
```

<br>

그리고 프로그램 카운터 역할을 수행하는 `EIP` 레지스터에

바로 다음에 수행될 명령어의 주소를 저장하고,

순차적 흐름에 따라 현재 명령어의 수행을 마칠 때마다

`EIP`에 저장된 주소를 증가시키게 된다.

<br>

## **WORD**
- **WORD**는 CPU가 한 번에 처리할 수 있는 기본 데이터 처리 단위를 의미한다.

- 32비트 머신에서 **WORD**는 32비트, 64비트 머신에서는 64비트로 정의된다.

- 하드웨어적으로는 CPU의 기본 데이터 처리 단위와 일치하지만, <br>
  소프트웨어에서 **WORD**는 16비트 타입을 의미한다.

<br>

## **숫자 리터럴**
- 어셈블리 코드에 작성되는 숫자의 단위 : `byte`

- **접미어**
  - `h` : 16진수 값
  - `b` : 2진수 값

</details>

<br>



# 기본 문법
---

<details>
<summary markdown="span">
...
</summary>

## **단항 연산(Unary Operation)**

```
<opcode> <operand>
```


## **이항 연산(Binary Operation)**

- **Source** : `operand2` 
- **Destination** : `operand1`

- `operand2`를 `operand1`에 `opcode` 한다.

```
<opcode> <operand1>, <operand2>
```


## **주석(Comment)**

```
;<comment>
```


## **레이블(Label)**

```
<Label> : <opcode> <operand1> <operand2> ;<comment>
```

</details>

<br>



# 자료형
---

<details>
<summary markdown="span">
...
</summary>

## **BYTE**
- `8` bit (1byte)

## **WORD**
- CPU의 기본 처리 단위
- `16` bit (2byte)

## **DWORD**
- Double Word
- `32` bit (4byte)

## **QWORD**
- Quadruple Word
- `64` bit (8byte)

## **부호 있는 자료형**
- SBYTE (8 bit)
- SWORD (16 bit)
- SDWORD (32 bit)
- SQWORD (64 bit)

</details>

<br>



# 대괄호 연산자
---

<details>
<summary markdown="span">
...
</summary>

```
mov eax, ebp
```

위의 명령어는 `ebp` 레지스터에 저장된 값을 `eax` 레지스터에 넣으라는 의미다.

<br>


```
mov eax, dword ptr [ebp]
```

레지스터 또는 숫자를 대괄호가 감싸는 경우가 있는데,

대괄호는 마치 C계열 언어의 포인터 역참조 연산자(`*`)처럼 동작하여

해당 레지스터에 저장된 값을 주솟값으로 하는 메모리 위치의 값을 참조한다.

위 명령어에서 만약 `ebp` 레지스터 내에 `0x48` 값이 있었다면

메모리의 `0x48` 주소에 위치한 값을 `eax`에 넣는 동작을 수행한다.

<br>

여기서 `dword ptr`은 뒤에 나오는 값이 `4byte` 크기의 포인터로 사용된다는 것을 의미한다.

<br>


```
mov eax, dword ptr [ebp+30h]
```

이렇게 대괄호 내에 연산식이 포함된 경우는 연산의 결과값이 가리키는 메모리 위치의 값을 참조하라는 뜻이다.

마찬가지로 `ebp` 레지스터 내에 `0x48` 값이 저장되어 있다면

위의 명령어는 `ebp + 0x30`, 즉 `0x48 + 0x30 = 0x78` 메모리 위치의 값을 `eax`에 넣으라는 의미가 된다.

</details>

<br>



# 레지스터
---

<details>
<summary markdown="span">
...
</summary>

## **레지스터(Register)**
- CPU 내부의 작은 메모리 공간
- 기억 장치 중에서 가장 빠르다.
- CPU와 메모리 사이에서 임시 기억 장치 역할을 수행한다.
- 각 레지스터는 고유의 용도를 가진다.

<br>


## **접두사에 따른 레지스터의 크기**
- 없음 : 16 bit (예 : AX, BX, CX, DX)
- `E` : 32 bit (예 : EAX, EBX, ECX, EDX)
- `R` : 64 bit (예 : RAX, RBX, RCX, RDX)

<br>


## **레지스터의 크기를 결정하는 것**
- 하드웨어적으로는 CPU 아키텍처에 의해 결정된다.
- 소프트웨어적으로는 운영체제와 응용 프로그램의 정책에 의해 결정된다.


<br>

## **레지스터의 구조**

- 예시 : AX(Accumulator Register)

![image](https://user-images.githubusercontent.com/42164422/139488028-38bf13ba-03c6-4899-a7d7-616aa517a135.png)

- **EAX** : 0 ~ 63 bit
- **EAX** : 0 ~ 31 bit
- **AX** : 0 ~ 15 bit
- **AH** : 8 ~ 15 bit
- **AL** : 0 ~ 7 bit

<br>

각각의 레지스터는 위와 같이 호출되는 이름에 따라 정해진 위치와 크기의 영역을 사용한다.

</details>

<br>



# 레지스터 종류
---

<details>
<summary markdown="span">
...
</summary>

- 32비트 기준으로 작성

<br>

## **[1] 범용 레지스터**

<details>
<summary markdown="span">
...
</summary>

### **EAX**
- Accumulator
- 기본 산술(사칙) 연산 레지스터
- 함수의 리턴 값이나 연산 결과가 저장된다.
- 범용적으로 많이 쓰인다.

### **EBX**
- Base Address
- 배열의 주소를 저장한다.

### **ECX**
- Counter
- 반복문에서 반복 횟수를 기록할 때 주로 사용한다.
- `ECX`에 저장된 값은 반복마다 1씩 감소하며, 0이 될 때까지 반복을 이어나간다.

### **EDX**
- Data
- AX의 보조 레지스터
- 연산에 AX의 용량이 부족할 때 확장 용도로 사용된다.
- 주로 부호 확장 명령, 산술 및 논리 연산 보조 역할을 담당한다.

</details>

<br>


## **[2] 인덱스 레지스터**

<details>
<summary markdown="span">
...
</summary>

### **ESI**
- Source Index
- 데이터를 조작/복사할 때 원본 데이터의 주소를 저장한다.

### **EDI**
- Destination Index
- 데이터를 복사할 때 목적지 주소를 저장한다.

</details>

<br>


## **[3] 포인터 레지스터**

<details>
<summary markdown="span">
...
</summary>

### **EBP**
- Base Pointer
- 현재 스택 프레임의 시작 주소를 저장한다.
- 현재 스택 프레임이 유지되는 동안에는 값이 절대 바뀌지 않는다.
- 현재 스택 프레임이 소멸되면 이전 스택 프레임의 시작 주소를 저장한다.

- 스택 세그먼트에 있는 함수의 지역변수, 매개변수를 참조하기 위해 사용된다.
- `SS 레지스터`와 함께 사용된다.

### **ESP**
- Stack Pointer
- 항상 현재 스택의 최상단(TOP) 주소를 저장한다.
- `PUSH`, `POP` 명령에 따라 값이 `4 byte`씩 변하며, 유동적이다.
- 스택은 높은 주소가 Base, 낮은 주소가 Top이며 위에서 아래로 확장된다.

- `EBP`는 스택 프레임 이동 시 값을 직접 넣어주는데 반해, <br>
  `ESP`는 `PUSH`와 `POP`에 의해 간접적으로 변한다.(중요)

- `SS 레지스터`와 함께 사용된다.

### **EIP**
- Instruction Pointer
- 프로그램 카운터(Program Counter) 역할을 수행한다.
- 코드의 실행 흐름을 제어하는 데 사용되는 중요한 레지스터.
- 바로 다음에 수행할 명령의 주소를 저장한다.
- 한 줄씩 흐름이 이동할 때마다 `EIP`에 저장된 값은 계속 바뀐다.

- 참고 : <https://m.blog.naver.com/zxwnstn/221511263055>

### **SFP**
- Stack Frame Pointer
- 함수가 호출되기 전의 스택 프레임 시작 주소를 저장한다.
- `RET` 명령어 호출 시 복귀할 지점을 저장한다고 보면 된다.
- `EBP`는 현재 스택 프레임의 시작 주소를 기억하고,<br>
  `SFP`는 이전 스택 프레임의 `EBP` 값을 기억한다.

</details>

<br>


## **[4] 세그먼트 레지스터**

<details>
<summary markdown="span">
...
</summary>

### **세그먼트(Segment)?**
- 주기억장치(메모리)의 일부에 할당되는 논리적 영역
- 프로그램 시작 시 크기가 정해지는 정적 세그먼트, 런타임에 크기가 변하는 동적 세그먼트로 나눌 수 있다.

<br>

### **세그먼트 종류**
- **Code Segment** (정적)
  - Text Segment라고도 한다.
  - 프로그램의 명령어를 저장한다.
  - 프로그램 시작 시 할당되며, 읽기만 가능하다.
  
  - `CS 레지스터`에 코드 세그먼트의 시작 주소를 저장한다.
  
  <br>
  
- **Data Segment** (정적)
  - 초기화된 전역 변수, 정적 변수, 문자열 리터럴이 저장된다.
  - 프로그램 시작 시 할당되며, 종료 시 해제된다.
  - 런타임에 크기가 변하지 않는다.
  
  - `DS 레지스터`에 데이터 세그먼트의 시작 주소를 저장한다.
  
  <br>
  
- **BSS Segment** (정적)
  - 초기화되지 않은 전역 변수, 정적 변수가 저장된다.
  - 런타임에 크기가 변하지 않는다.
  
  <br>
  
- **Heap Segment** (동적)
  - 런타임에 프로그래머가 직접 할당한 메모리가 저장되는 영역
  - 런타임에 크기가 변할 수 있다.
  - 메모리의 낮은 주소에서 높은 주소 방향으로 저장, 확장된다.
  
  <br>
  
- **Stack Segment** (동적)
  - 런타임에 데이터의 임시 저장을 위해 사용되는 메모리 영역
  - 런타임에 크기가 변할 수 있다.
  - 함수가 실행될 때 할당되고, 함수가 끝날 때 해제된다.
  - 주로 함수 내의 지역변수를 저장한다.
  
  - 메모리의 높은 주소에서 낮은 주소 방향으로 저장, 확장된다.
  - 힙과 스택 영역은 서로 반대 방향의 말단에서 서로를 향해 크기를 확장한다.
  
  - `SS 레지스터`에 스택 세그먼트의 시작 주소를 저장한다.

<br>

### **세그먼트 레지스터?**
  - 세그먼트의 특정 영역에 대한 주소 지정 기능을 제공한다.
  - 쉽게 말해, 프로그램 내의 특정 영역들에 대한 시작 주소를 갖고있는 레지스터들이다.

<br>

### **CS**
- Code Segment
- 코드 세그먼트의 시작 주소를 저장한다.
- 이 주솟값에 명령어 포인터(IP) 레지스터가 갖고 있는 오프셋 값을 더하면 메모리에 저장된, 현재 실행해야 할 명령어의 주솟값이 된다.

### **DS**
- Data Segment
- 데이터 세그먼트의 시작 주소를 저장한다.
- 이 주소에 명령어의 오프셋 값을 더하면 데이터 영역의 특정 주소를 참조할 수 있다.

### **SS**
- Stack Segment
- 스택 세그먼트의 시작 주소를 저장한다.
- SS의 값에 스택 포인터(SP)의 값을 더하면 현재 참조되고 있는 스택의 WORD를 가리킨다.

### **ES**
- Extra Segment
- 스트링 데이터 연산에 보조적으로 사용된다.
- 데이터 수신부의 시작 주소를 포함하며, 목적지 인덱스(DI) 레지스터와 연관된다.

### **FS**
- 사용처가 정해지지 않은 여분의 레지스터
- FS, GS의 이름도 그냥 E 다음 F, G라서 정해진 이름이라고 한다.
- Windows에서는 프로세스의 스레드 정보 블록(TIB)을 가리킬 때 사용된다.
- SEH에 콜백 함수에 대한 포인터를 저장할 때도 사용된다.

### **GS**
- 사용처가 정해지지 않은 여분의 레지스터
- ES처럼 연산의 보조를 위해 사용된다.
- 일반적으로 스레드 로컬 저장소(TLS)에 대한 포인터로 사용된다.

</details>

<br>


## **[5] 플래그 레지스터**

<details>
<summary markdown="span">
...
</summary>

## **EFLAG 레지스터**
- CPU의 동작 제어, 연산 결과 반영에 사용되는 레지스터
- 32비트 레지스터이며, 그 중 오른쪽(하위) 16비트를 플래그 레지스터라고 한다.
- 플래그를 `1`로 설정하는 것을 `SET`라고 한다.
- 플래그를 `0`으로 설정하는 것을 `RESET` 또는 `CLEAR`라고 한다.

![image](https://user-images.githubusercontent.com/42164422/139555360-725ee39a-ee1c-4ce5-a107-f7ae4ef396e9.png)

<br>

### **CF**
- Carry
- 연산 시 올림수가 발생하는 경우 `SET`

### **PF**
- Parity
- 연산 결과에서 1인 비트의 수가 짝수이면 `SET`

### **AF**
- Auxilary
- 특별한 산술 연산에 사용되며, 3번 비트에서 4번 비트로 올림수가 발생하면 `SET`

### **ZF**
- Zero
- 산술 또는 비교 연산의 결과가 0이 아닐 경우 `SET`

### **SF**
- Sign
- 산술 연산의 결과가 음수일 경우 `SET`

### **TF**
- Trap
- 디버그 프로그램에서 사용된다.
- `SET`이 되면 명령어를 하나씩 순차적으로 실행한다.

### **IF**
- Interrupt
- `SET`이 되면 입출력 장치와 같은 외부 인터럽트를 처리해야 함을 나타낸다.

### **DF**
- Direction
- 문자열 처리 방향을 나타낸다.
- `SET` : 정방향(주솟값 감소)
- `CLEAR` : 역방향(주솟값 증가)

### **OF**
- Overflow
- 부호 있는 연산의 결과가 범위를 넘어설 경우 `SET`

</details>


</details> <!-- # 레지스터 종류 -->

<br>



# 명령어
---

<details>
<summary markdown="span">
...
</summary>



## **[0] 미분류**

<details>
<summary markdown="span">
...
</summary>

### **NOP**
- No Operation
- 아무것도 하지 않는다.

</details>

<br>


## **[1] 스택 조작**

<details>
<summary markdown="span">
...
</summary>

### **PUSH**
- 지정한 레지스터에 저장된 값을 스택 상단에 저장한다.
- 스택 포인터(SP) 레지스터의 값이 `4byte` 감소한다.
- 스택은 높은 주소에서부터 낮은 주소로 확장되므로 스택이 커지면 스택의 끝부분(TOP)을 가리키는 `SP` 레지스터의 값이 감소한다.

```
PUSH <operand(register)>
```

<br>

### **POP**
- 스택 상단의 값을 꺼내어 지정한 레지스터에 저장한다.
- 스택 포인터(SP) 레지스터의 값이 `4byte` 증가한다.

```
POP <operand(register)>
```

</details>

<br>


## **[2] 프로시저**

<details>
<summary markdown="span">
...
</summary>

### **JMP**
- Jump
- 지정한 명령어 주소로 제어를 이동한다.
- `EIP`의 값을 해당 주소로 바꿔버리는 것이라고 보면 된다.

```
JMP <이동할 명령어 주소>
```

<br>


### **CALL**
- 되돌아올 주소(현재 `EIP`에 저장된 값)를 스택에 저장한다.
- 프로시저(함수)를 호출하고 제어를 옮긴다.

```
CALL <프로시저의 시작 주소>
```

위 명령어는 아래 명령어와 같다.

```
PUSH eip
JUMP <프로시저의 시작 주소>
```

<br>


### **RET**
- Return
- 스택에 저장되어 있던 주소로 제어를 이동하여 되돌아온다.
- `CALL`로 제어를 이동한 경우, 되돌아오기 위해 사용한다.

```
RET
```

위 명령어는 아래 명령어와 같다.

```
POP eip
```

</details>

<br>


## **[3] 데이터 복사**

<details>
<summary markdown="span">
...
</summary>

### **MOV**
- Move
- src에 저장된 값을 dest로 복사한다.

```
MOV <dest> <src>
```

<br>


### **LEA**
- Load Effective Address
- src의 `주솟값`을 dest(레지스터만 가능)로 복사한다.
- `MOV`로는 두 번에 걸쳐 수행할 동작을 `LEA`로 한 번에 수행할 수 있다.

```
LEA <dest(register)> <src>
```

<br>

```
MOV eax, ebp
ADD eax, 8
```

위 명령어는 아래 명령어와 같은 동작을 수행한다.

```
LEA eax, [ebp+8]
```

`EBP`에 저장된 값에 8을 더하고, 그 값을 `EAX`에 저장한다.

<br>

```
MOV eax, ebp+8
```

이렇게 하면 되지 않을까하는 생각이 들 수도 있는데,

`[]`로 감싸지지 않은 연산식은 허용되지 않는다.

그래서 `LEA`가 필요한 것이다.

<br>

### **MOVZX**
- Move with Zero-Extension
- src에 저장된 값을 dest로 복사한다.
- dest의 크기가 src보다 큰 경우, dest의 남은 비트를 0으로 채운다.

```
MOVZX <dest> <src>
```

<br>

### **MOVSX**
- Move with Sign-Extension
- src에 저장된 값을 dest로 복사한다.
- dest의 크기가 src보다 큰 경우, dest의 남은 비트를 부호 비트로 채운다.

```
MOVSX <dest> <src>
```

<br>

### **MOVS**
- Move String
- `ESI`(Source Index)에 저장된 주소에 위치한 문자열을<br>
  `EDI`(Destination Index)에 저장된 주소에 복사한다.

```
MOVS
```

</details>

<br>


## **[4] 연산**

<details>
<summary markdown="span">
...
</summary>

### **INC**
- Increment
- 대상 레지스터의 값을 1 증가시킨다.

```
INC <operand(register)>
```

<br>

### **DEC**
- Decrement
- 대상 레지스터의 값을 1 감소시킨다.

```
DEC <operand(register)>
```

<br>

### **ADD**
- src, dest에 저장된 값을 서로 더하여 dest에 저장한다.

```
ADD <dest>, <src>
```

<br>

```
; eax에 저장된 값에 0x10을 더한다.
ADD eax, 10h

; 0x7FF80BF4FAD8 메모리 주소에 저장된 값과 eax에 저장된 값을 더하여 eax에 저장한다.
ADD eax, dword ptr [7FF80BF4FAD8h]
```

<br>

### **SUB**
- Subtract
- dest에 저장된 값에 src에 저장된 값을 빼서 dest에 저장한다.

```
SUB <dest>, <src>
```

<br>

### **CMP**
- Compare
- dest와 src의 값을 비교한다.
- 연산 결과로 `ZF`, `SF`, `OF`와 같은 플래그 레지스터의 값이 설정된다.
- 조건부 점프(`JA`, `JB`, `JE`, `JNE`, ...) 명령어가 이어 나오는 경우가 많다.

```
CMP <dest>, <src>
```

<br>

```
; AL(AX 하위 1바이트) 레지스터의 값이 0xE8인지 비교한다.
CMP    al, 0E8h

; RBP, RAX 레지스터에 저장된 값이 서로 같은지 비교한다.
CMP    rbp, rax

; 메모리의 0x7FF80BF4FAD8 주소에 저장된 값이 0인지 비교한다.
CMP    dword ptr [7FF80BF4FAD8h], 0
```

</details>

<br>


## **[5] 인터럽트**

<details>
<summary markdown="span">
...
</summary>

### **INT**
- 소프트웨어 인터럽트를 발생시켜 OS의 서브루틴을 호출한다.
- 피연산자는 상수만 사용할 수 있다.

```
INT <operand>
```

</details>


</details> <!-- # 명령어 -->

<br>



# 스택 프레임
---

<details>
<summary markdown="span">
...
</summary>

## **스택 프레임(Stack Frame)?**
- `EBP`(스택 베이스 포인터) 레지스터를 사용하여 현재 스택 내의 지역 변수, 매개 변수, 복귀 주소에 접근하는 기법 또는 그 영역
- `EBP`에 저장된 주소를 기반으로 오프셋을 더하여 지역 변수에 간편히 접근할 수 있다.
- 함수가 호출될 때마다 해당 함수의 스택 프레임이 생성되고, `EBP`에는 스택 프레임의 시작 주소가 저장된다.

<br>

## **설명**
- `PUSH`, `POP`이 발생할 때마다 `ESP`에 저장된 값은 `4byte`씩 변하며, 항상 스택의 상단을 가리킨다.
- 함수 호출 직후 `EBP`에 `ESP`의 값을 넣어 줌으로써, 마치 스택 상단에서 작은 스택을 생성하는 효과를 얻을 수 있다.
- 이 영역을 스택 프레임이라고 하며, `EBP`는 현재 스택 프레임의 시작 주소를 저장하는 역할을 수행한다.

<br>

## **구조**

```
PUSH ebp        ; 이전 스택 프레임의 시작 주소 백업
MOV  ebp, esp   ; ESP -> EBP : 새로운 스택 프레임 형성

                ; 함수 영역

MOV  esp, ebp   ; EBP   -> ESP : 이전 스택 프레임의 상단(Top) 주솟값 복원
POP  ebp        ; stack -> EBP : 이전 스택 프레임의 시작(Base) 주솟값 복원
RET             ; stack -> EIP : 함수 호출 문장 다음 지점으로 제어 이동
```


</details>


<br>

# References
---

<details>
<summary markdown="span">
...
</summary>

- <https://rootfriend.tistory.com/entry/어셈블러Assembler의-종류>

- <https://sunrinjuntae.tistory.com/24>
- <https://iceb1u3.tistory.com/entry/2장-레지스터와-어셈블리어-정리>
- <https://velog.io/@hidaehyunlee/libasm-어셈블리-프로그램-구조와-x64-레지스터-이해하기>
- <https://sewcode.tistory.com/10>
- <https://velog.io/@kjh3865/movandlea>
- <https://coding-factory.tistory.com/650>
- <https://coding-factory.tistory.com/651>

- <https://wogh8732.tistory.com/215>
- <https://to-paz.tistory.com/99>
- <https://5kyc1ad.tistory.com/32>
- <https://sunrinjuntae.tistory.com/24>
- <https://blog.kimtae.xyz/9>
- <https://adipo.tistory.com/entry/어셈블리어-MASMMicrosoft-Macro-Assembler>

- <https://www.youtube.com/watch?v=yf7yFJHTif8>

</details>