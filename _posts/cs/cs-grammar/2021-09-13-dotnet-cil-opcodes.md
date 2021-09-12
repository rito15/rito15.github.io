---
title: .NET CIL OP Code Instruction 모음
author: Rito15
date: 2021-09-13 03:55:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# OP Code Instructions
---

|**Instruction** |**Operand**|**설명**|
|---|---|---|
|beq       |        ||
|bgt       |        ||
|br        |        ||
|brtrue    |        ||
|brfalse   |        ||
|bne       |        ||
|beq       |        ||
|ldc.i4    |int32 값 |주어진 정수를 계산 스택(Evaluation Stack)에 넣는다.|
|ldc.i4.0  |        |정수 0을 계산 스택에 넣는다.|
|ldc.i4.m1 |        |정수 -1을 계산 스택에 넣는다.|
|ldloc     |        ||
|stloc     |        ||
|stfld     |        ||
|ldarg     |        ||
|ret       |        |메소드를 종료하고 호출 지점으로 복귀한다.|

<br>

# Instruction - Suffix
---

## **부호 있는 정수**

|**Suffix**|**설명**|
|---   |---|
|      |32비트 정수(int)|
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
|.s ||
|.s ||
|.s ||
|.s ||
|.s ||
|.s ||


## **상수**
|**Suffix**|**설명**|
|---   |---|
|.s ||
|.s ||
|.s ||
|.s ||
|.s ||
|.s ||

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.emit.opcodes.add?view=net-5.0>
- <https://en.wikipedia.org/wiki/List_of_CIL_instructions>