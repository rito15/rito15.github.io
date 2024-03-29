---
title: .NET CIL 명령어 모음
author: Rito15
date: 2021-09-14 03:55:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp, dotnet, cil, opcode, instruction]
math: true
mermaid: true
---

# Instructions
---

## **Stack**
- 스택 : 계산 스택(Evaluation Stack)
- "스택의 값"을 언급하는 경우는 스택의 값을 꺼내어(Pop) 사용한다는 의미이다.
- "스택의 두 값"을 언급하는 경우는 스택에서 두 값을 꺼내어 사용한다는 의미이다.
- "스택의 두 값 A B"를 언급하는 경우, A는 스택에 먼저 넣었던 값이고 B는 그 다음에 넣은 값(Top)이다.

- `ld`로 시작하는 명령어는 **Load**를 의미하며, 대상의 값을 스택에 넣는다.
- `ldFOO.0` 명령어는 `FOO` 목록의 `0`번 인덱스에 있는 값을 스택에 넣는다.

- `st`로 시작하는 명령어는 **Store**를 의미하며, 스택의 값을 꺼내 다른 곳에 저장한다.
- `stFOO.0` 명령어는 스택에서 값을 꺼내 `FOO` 목록의 `0`번 인덱스에 저장한다.

<br>

## **Memory**
- 지역변수(Local Variable)들은 하나의 목록 내에 저장된다.
- `~loc`은 지역변수 목록을 의미하며, 각각의 지역변수들은 인덱스와 값을 갖는다.
- `~loc.0`은 지역변수 목록 0번 인덱스 위치를 의미한다.

- 매개변수(Argument)들은 하나의 목록 내에 저장된다.
- `~arg`는 매개변수 목록을 의미하며, 각각의 매개변수들은 인덱스와 값을 갖는다.

- 필드(Field)는 각각 이름으로 참조된다.
- `~fld`는 필드를 의미하며, Operand로 필드 이름이 등장한다.
- `~sfld`는 정적 필드

<br>

## **Instruction Table**

|**Instruction** |**Operand**|**설명**|
|---|---|---|
|add       |          |스택의 두 값을 더하고 결과를 스택에 넣는다(push).|
|and       |          |스택의 두 값을 Bitwise AND 연산하고 결과를 스택에 넣는다.|
|beq       |목표 주소    |스택의 두 값이 같으면 목표 주소로 이동한다.|
|bge       |목표 주소    |스택의 두 값을 꺼내고, A >= B 이면 목표 주소로 이동한다.|
|bgt       |목표 주소    |스택의 두 값을 꺼내고, A >  B 이면 목표 주소로 이동한다.|
|ble       |목표 주소    |스택의 두 값을 꺼내고, A <= B 이면 목표 주소로 이동한다.|
|blt       |목표 주소    |스택의 두 값을 꺼내고, A <  B 이면 목표 주소로 이동한다.|
|bne       |목표 주소    |스택의 두 값을 꺼내고, A != B 이면 목표 주소로 이동한다.|
|box       |타입 이름    |스택의 값을 꺼내어 object 타입으로 박싱한 뒤 다시 스택에 넣는다.|
|br        |메모리 주소   |즉시 대상 위치로 제어를 이동한다.|
|br.s      |IL위치      |즉시 대상 IL 위치로 제어를 이동한다.|
|brtrue    |메모리 주소   |스택의 값이 0이 아니면 제어를 이동한다.<br>brinst는 brtrue의 또다른 표현이다.(not null)|
|brfalse   |메모리 주소   |스택의 값이 0이면 제어를 이동한다.<br>brnull, brzero는 brfalse의 또다른 표현이다.|
|call      |메소드 이름   |지정한 이름의 메소드를 호출한다.<br> 매개변수가 있을 경우, 개수만큼 스택에서 꺼내어 사용한다.<br> (스택에 먼저 들어간 순서대로 매개변수에 차례로 할당)|
|ceq       |          |스택의 두 값을 꺼내고, 같으면 1, 다르면 0을 스택에 넣는다.|
|cgt       |          |스택의 두 값을 꺼내고, A > B 이면 1, 아니면 0을 스택에 넣는다.|
|clt       |          |스택의 두 값을 꺼내고, A < B 이면 1, 아니면 0을 스택에 넣는다.|
|callvirt  |메소드 이름   |런타임에 바인딩된 메소드를 호출하고 반환값을 스택에 넣는다.|
|constrained.|        |지정된 타입에서 가상 메소드가 호출되도록 제한한다.<br> **callvirt**와 함께 사용된다.|
|conv.i    |          |스택의 값을 native int 타입으로 변환한다.|
|div       |          |스택의 두 값을 꺼내어 A / B 의 결과를 스택에 넣는다.|
|dup       |          |스택 상단의 값을 유지한 채로, 새로 복제하여 스택에 넣는다.|
|ldarg     |인덱스      |지정한 인덱스의 매개변수 값을 스택에 넣는다.|
|ldarg.0   |          |첫 번째(0번 인덱스) 매개변수의 값을 스택에 넣는다.|
|ldarga    |인덱스      |지정한 인덱스의 매개변수의 주솟값을 스택에 넣는다.|
|ldc.i4    |int32 값   |주어진 정수를 스택에 넣는다.|
|ldc.i4.0  |          |정수 0을 스택에 넣는다.|
|ldc.i4.m1 |          |정수 -1을 스택에 넣는다.|
|ldelem    |타입 이름    |스택에서 두 값을 꺼낸다.(A : 배열, B : 인덱스)<br>A[B] 값을 스택에 넣는다.|
|ldelem.i  |          |스택의 두 값 A(배열), B(인덱스)을 꺼내어,<br> A[B] 값을 native int 타입으로 스택에 넣는다.|
|ldloc     |인덱스      |지정한 인덱스에 있는 지역 변수를 스택에 넣는다. |
|ldloc.0   |          |인덱스 0에 있는 지역 변수를 스택에 넣는다. |
|ldobj     |타입 이름    |스택의 상단의 주솟값을 꺼내고, 해당 주소가 가리키는 위치의 객체를 스택에 넣는다.|
|ldfld     |필드 이름    |Load Field : 스택에 해당 필드의 값을 넣는다.|
|ldflda    |필드 이름    |Load Field Address : 스택에 해당 필드의 주솟값을 넣는다.|
|ldlen     |          |스택에 있는 배열 참조를 꺼내고, 길이를 계산한 뒤 그 결과(길이)를 스택에 넣는다.|
|ldloc.0   |          |스택에서 값을 꺼내어 지역변수 0번 위치에 저장한다.|
|ldnull    |          |스택에 null을 넣는다.|
|ldstr     |문자열 상수   |스택에 지정한 문자열 상수를 넣는다.|
|localloc  |          |스택의 값을 크기로 하는 로컬 배열을 생성하여 그 주소를 스택에 넣는다.|
|mul       |          |스택의 두 값을 곱하고 결과를 스택에 넣는다.|
|neg       |          |스택의 값을 꺼내어 부호를 반전시키고 다시 스택에 넣는다.|
|newarr    |타입 이름    |스택의 값을 꺼내어 그 값을 크기로 사용하고,<br> 대상 타입으로 배열을 생성하여 스택에 넣는다.|
|newobj    |생성자 이름   |스택에는 생성자의 매개변수로 들어갈 값들이 차례로 입력된 상태.<br>생성자의 필요 매개변수만큼 스택에서 꺼내어 생성자를 호출한다.<br>생성된 객체를 스택에 넣는다.|
|nop       |          |아무 것도 하지 않는다.(No OPeration)|
|not       |          |스택의 값을 꺼내어 Bitwise Not 연산 후 다시 스택에 넣느다.|
|or        |          |스택의 두 값을 꺼내어 Bitwise OR 연산 후 다시 스택에 넣는다.|
|pop       |          |스택 상단의 값을 제거한다.|
|rem       |          |스택의 두 값을 꺼내어 A % B 연산 후 다시 스택에 넣는다.|
|ret       |          |메소드를 종료하고 호출 지점으로 복귀한다.<br> 리턴 값이 있다면 스택에 넣으면 호출자의 스택으로 이동된다.|
|stelem    |          |스택에서 우선 세 개의 값을 꺼낸다.<br> A는 배열, B는 인덱스, C는 값이다.<br> A[B]에 C 값을 저장한다.|
|stind.i   |          |스택의 두 값을 꺼낸다(A는 주솟값, B는 값).<br> 메모리의 A 주소 위치에 B 값을 저장한다.|
|starg     |인덱스      |스택의 값을 꺼내어 지정한 인덱스의 매개변수에 저장한다.|
|stloc     |인덱스      |스택의 값을 꺼내어 지정한 인덱스의 지역변수에 저장한다.|
|stloc.0   |          |스택의 값을 꺼내어 지역변수 0번에 저장한다.|
|stfld     |필드 이름    |스택의 값을 꺼내어 지정한 필드에 저장한다.|
|stsfld    |정적 필드 이름 |스택의 값을 꺼내어 지정한 정적 필드에 저장한다.|
|sub       |          |스택의 두 값을 꺼내어 A - B의 결과를 스택에 넣는다.|
|switch    |          |switch-case의 점프 테이블을 생성한다.|
|unbox     |타입 이름    |스택의 값을 꺼내어 지정한 타입으로 언박싱 후, 스택에 넣는다.<br>이 때, 지정한 타입은 Value Type이어야 한다.|
|unbox.any |타입 이름    |스택의 값을 꺼내어 지정한 타입으로 언박싱 후, 스택에 넣는다.|
|xor       |          |스택의 두 값을 Bitwise XOR 연산 후 다시 스택에 넣는다.|

<br>

# Instruction - Suffix
---

## **부호 있는 정수**

|**Suffix**|**설명**|
|---   |---|
|.s    | 8비트 정수(byte)|
|.i1   | 8비트 정수(sbyte)|
|.i2   |16비트 정수(short)|
|.i4   |32비트 정수(int)|
|.i8   |64비트 정수(long)|


## **부호 없는 정수**

|**Suffix**|**설명**|
|---   |---|
|.un   |부호 없는 32비트 정수(uint)|
|.un.s |부호 없는  8비트 정수(byte)|
|.u1   |부호 없는  8비트 정수(byte)|
|.u2   |부호 없는 16비트 정수(ushort)|
|.u4   |부호 없는 32비트 정수(uint)|
|.u8   |부호 없는 64비트 정수(ulong)|


## **실수**

|**Suffix**|**설명**|
|---   |---|
|.r  |32비트 실수(float)|
|.r4 |32비트 실수(float)|
|.r8 |64비트 실수(double)|


## **상수**

|**Suffix**|**설명**|
|---   |---|
|.0 |32비트 정수형 상수 0|
|.1 |32비트 정수형 상수 1|
|.m1 |32비트 정수형 상수 -1|
|.M1 |32비트 정수형 상수 -1|


## **기타**

|**Suffix**|**설명**|
|---   |---|
|.s   |축약 형태(Short Form)|
|.ovf |오버플로우가 발생하는지 검사한다.|
|.ref |오브젝트 참조|

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.emit.opcodes.add?view=net-5.0>
- <https://en.wikipedia.org/wiki/List_of_CIL_instructions>
- <https://www.codeproject.com/Articles/362076/Understanding-Common-Intermediate-Language-CIL>