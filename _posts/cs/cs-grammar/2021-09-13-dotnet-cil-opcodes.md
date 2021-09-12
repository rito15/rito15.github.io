---
title: .NET CIL OP Code Instruction 모음
author: Rito15
date: 2021-09-13 03:55:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Instructions
---

## **Note**

- 스택 : 계산 스택(Evaluation Stack)

<br>

## **Instruction Table**

|**Instruction** |**Operand**|**설명**|
|---|---|---|
|add       |        |스택에서 두 개의 값을 꺼내어(pop) 더하고 결과를 스택에 넣는다(push).|
|and       |        |스택에서 두 개의 값을 꺼내어(pop) Bitwise AND 연산하고 결과를 스택에 넣는다(push).|
|beq       |목표 주소  |스택의 두 값이 같으면 목표 주소로 이동한다.|
|bge       |목표 주소  |스택의 두 값이 같으면 목표 주소로 이동한다.|
|bgt       |        ||
|ble       |        ||
|blt       |        ||
|bne       |        ||
|box       |        ||
|br        |        ||
|brtrue    |        ||
|brfalse   |        ||
|brzero    |        ||
|brinst    |        ||
|brnull    |        ||
|call      |        ||
|calli     |        ||
|ceq       |        ||
|cgt       |        ||
|clt       |        ||
|callvirt  |메소드 이름 |런타임에 바인딩된 메소드를 호출하고 반환값을 스택에 넣는다.|
|constrained.|      |지정된 타입에서 가상 메소드가 호출되도록 제한한다.<br> **callvirt**와 함께 사용된다.|
|conv.i    |        ||
|div       |        ||
|ldarg     |        ||
|ldarg.0   |        ||
|ldarga    |        ||
|ldc.i4    |int32 값 |주어진 정수를 스택에 넣는다.|
|ldc.i4.0  |        |정수 0을 스택에 넣는다.|
|ldc.i4.m1 |        |정수 -1을 스택에 넣는다.|
|ldelem    |        ||
|ldelem.i  |        ||
|ldloc     |        ||
|ldfld     |필드 이름  |Load Field : 스택에 해당 필드의 값을 넣는다.|
|ldflda    |필드 이름  |Load Field Address : 스택에 해당 필드의 주솟값을 넣는다.|
|ldloc.0   |        ||
|mul       |        ||
|neg       |        ||
|nop       |        |아무 것도 하지 않는다.(No OPeration)|
|not       |        ||
|op        |        ||
|pop       |        ||
|rem       |        ||
|ret       |        |메소드를 종료하고 반환 값이 있을 경우 스택에 넣으며, 호출 지점으로 복귀한다.|
|stelem    |        ||
|stelem.i  |        ||
|stind     |        ||
|stind.i   |        ||
|stloc     |        ||
|stloc.0   |        ||
|stfld     |필드 이름  |스택에 저장된 값을 꺼내어 지정한 필드에 초기화한다.|
|stsfld    |        ||
|sub       |        ||
|switch    |        |switch-case의 점프 테이블을 생성한다.|
|unbox     |        ||
|xor       |        ||

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
|.ovf |오버플로우가 발생하는지 검사한다.|
|.ref |오브젝트 참조|

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.emit.opcodes.add?view=net-5.0>
- <https://en.wikipedia.org/wiki/List_of_CIL_instructions>