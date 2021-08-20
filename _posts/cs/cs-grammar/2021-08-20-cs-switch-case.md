---
title: C# Switch-Case의 특징
author: Rito15
date: 2021-08-20 16:49:00 +09:00
categories: [C#, C# Grammar]
tags: [csharp]
math: true
mermaid: true
---

# Switch-Case 문
---

- 대상 변수에 대해, 고정된 값들을 `case`에 지정하여 동등 비교를 수행할 수 있다.

- `case`가 일정 개수 미만일 경우, `if-else`와 동일한 방식으로 각 `case`를 순차적으로 확인하며 분기한다고 한다.

- `case`가 일정 개수 이상일 경우, 메모리에 `Jump Table`을 생성하여 해당 `case`로 직접 건너뛴다고 한다.


<br>

# 생성되는 CIL 코드 확인하기
---

## [1] 소스 코드

<details>
<summary markdown="span"> 
.
</summary>

```cs
private void IfElse()
{
    int value = 2;

    if (value == 0) result = 0;
    else if (value == 1) result = 10;
    else if (value == 2) result = 20;
    else if (value == 3) result = 30;
    else if (value == 4) result = 40;
    else if (value == 5) result = 50;
    else result = 0;
}

private void SwitchCase1()
{
    int value = 2;

    switch (value)
    {
        default:
        case 0: result = 0; break;
    }
}

private void SwitchCase2()
{
    int value = 2;

    switch (value)
    {
        default:
        case 0: result = 0; break;
        case 1: result = 10; break;
    }
}

private void SwitchCase3_1()
{
    int value = 2;

    switch (value)
    {
        case 0: result = 0; break;
        case 1: result = 10; break;
        case 2: result = 20; break;
    }
}

private void SwitchCase3_2()
{
    int value = 2;

    switch (value)
    {
        default:
        case 0: result = 0; break;
        case 1: result = 10; break;
        case 2: result = 20; break;
    }
}

private void SwitchCase5()
{
    int value = 2;

    switch (value)
    {
        default:
        case 0: result = 0; break;
        case 1: result = 10; break;
        case 2: result = 20; break;
        case 3: result = 30; break;
        case 4: result = 40; break;
    }
}
```

</details>

<br>

## [2] CIL

<details>
<summary markdown="span"> 
.
</summary>

```
.method private hidebysig instance void  IfElse() cil managed
{
  // 코드 크기       86 (0x56)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  brtrue.s   IL_000d
  IL_0005:  ldarg.0
  IL_0006:  ldc.i4.0
  IL_0007:  stfld      int32 result
  IL_000c:  ret
  IL_000d:  ldloc.0
  IL_000e:  ldc.i4.1
  IL_000f:  bne.un.s   IL_001a
  IL_0011:  ldarg.0
  IL_0012:  ldc.i4.s   10
  IL_0014:  stfld      int32 result
  IL_0019:  ret
  IL_001a:  ldloc.0
  IL_001b:  ldc.i4.2
  IL_001c:  bne.un.s   IL_0027
  IL_001e:  ldarg.0
  IL_001f:  ldc.i4.s   20
  IL_0021:  stfld      int32 result
  IL_0026:  ret
  IL_0027:  ldloc.0
  IL_0028:  ldc.i4.3
  IL_0029:  bne.un.s   IL_0034
  IL_002b:  ldarg.0
  IL_002c:  ldc.i4.s   30
  IL_002e:  stfld      int32 result
  IL_0033:  ret
  IL_0034:  ldloc.0
  IL_0035:  ldc.i4.4
  IL_0036:  bne.un.s   IL_0041
  IL_0038:  ldarg.0
  IL_0039:  ldc.i4.s   40
  IL_003b:  stfld      int32 result
  IL_0040:  ret
  IL_0041:  ldloc.0
  IL_0042:  ldc.i4.5
  IL_0043:  bne.un.s   IL_004e
  IL_0045:  ldarg.0
  IL_0046:  ldc.i4.s   50
  IL_0048:  stfld      int32 result
  IL_004d:  ret
  IL_004e:  ldarg.0
  IL_004f:  ldc.i4.0
  IL_0050:  stfld      int32 result
  IL_0055:  ret
} // end of method IfElse
```

```
.method private hidebysig instance void  SwitchCase1() cil managed
{
  // 코드 크기       10 (0xa)
  .maxstack  8
  IL_0000:  ldc.i4.2
  IL_0001:  pop
  IL_0002:  ldarg.0
  IL_0003:  ldc.i4.0
  IL_0004:  stfld      int32 result
  IL_0009:  ret
} // end of method SwitchCase1
```

```
.method private hidebysig instance void  SwitchCase2() cil managed
{
  // 코드 크기       26 (0x1a)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  brfalse.s  IL_0009
  IL_0005:  ldloc.0
  IL_0006:  ldc.i4.1
  IL_0007:  beq.s      IL_0011
  IL_0009:  ldarg.0
  IL_000a:  ldc.i4.0
  IL_000b:  stfld      int32 result
  IL_0010:  ret
  IL_0011:  ldarg.0
  IL_0012:  ldc.i4.s   10
  IL_0014:  stfld      int32 result
  IL_0019:  ret
} // end of method SwitchCase2
```

```
.method private hidebysig instance void  SwitchCase3_1() cil managed
{
  // 코드 크기       47 (0x2f)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  switch     ( 
                        IL_0015,
                        IL_001d,
                        IL_0026)
  IL_0014:  ret
  IL_0015:  ldarg.0
  IL_0016:  ldc.i4.0
  IL_0017:  stfld      int32 result
  IL_001c:  ret
  IL_001d:  ldarg.0
  IL_001e:  ldc.i4.s   10
  IL_0020:  stfld      int32 result
  IL_0025:  ret
  IL_0026:  ldarg.0
  IL_0027:  ldc.i4.s   20
  IL_0029:  stfld      int32 result
  IL_002e:  ret
} // end of method SwitchCase3_1
```

```
.method private hidebysig instance void  SwitchCase3_2() cil managed
{
  // 코드 크기       46 (0x2e)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  switch     ( 
                        IL_0014,
                        IL_001c,
                        IL_0025)
  IL_0014:  ldarg.0
  IL_0015:  ldc.i4.0
  IL_0016:  stfld      int32 result
  IL_001b:  ret
  IL_001c:  ldarg.0
  IL_001d:  ldc.i4.s   10
  IL_001f:  stfld      int32 result
  IL_0024:  ret
  IL_0025:  ldarg.0
  IL_0026:  ldc.i4.s   20
  IL_0028:  stfld      int32 result
  IL_002d:  ret
} // end of method SwitchCase3_2
```

```
.method private hidebysig instance void  SwitchCase5() cil managed
{
  // 코드 크기       72 (0x48)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  switch     ( 
                        IL_001c,
                        IL_0024,
                        IL_002d,
                        IL_0036,
                        IL_003f)
  IL_001c:  ldarg.0
  IL_001d:  ldc.i4.0
  IL_001e:  stfld      int32 result
  IL_0023:  ret
  IL_0024:  ldarg.0
  IL_0025:  ldc.i4.s   10
  IL_0027:  stfld      int32 result
  IL_002c:  ret
  IL_002d:  ldarg.0
  IL_002e:  ldc.i4.s   20
  IL_0030:  stfld      int32 result
  IL_0035:  ret
  IL_0036:  ldarg.0
  IL_0037:  ldc.i4.s   30
  IL_0039:  stfld      int32 result
  IL_003e:  ret
  IL_003f:  ldarg.0
  IL_0040:  ldc.i4.s   40
  IL_0042:  stfld      int32 result
  IL_0047:  ret
} // end of method SwitchCase5
```

</details>

<br>


## [3] 결론

- `default`를 포함하여, `case`의 개수가 3개 이상일 경우 점프 테이블을 생성한다.

- 3개 미만일 경우에는 순차적으로 각 `case`를 확인한다.

<br>



# 벤치마크 : If-Else와의 성능 비교
---

## 소스코드

<details>
<summary markdown="span"> 
.
</summary>

```cs
// int result; (field)

[Benchmark(Baseline = true)]
public void Switch_Case()
{
    int value = 9;

    switch (value)
    {
        default:
        case 0: result = 0; break; 

        case 1: result = 10; break; 
        case 2: result = 20; break; 
        case 3: result = 30; break; 
        case 4: result = 40; break; 
        case 5: result = 50; break; 
        case 6: result = 60; break; 
        case 7: result = 70; break; 
        case 8: result = 80; break; 
        case 9: result = 90; break; 
    }
}

[Benchmark]
public void If_Else()
{
    int value = 9;

    if (value == 0) result = 0;
    else if (value == 1) result = 10;
    else if (value == 2) result = 20;
    else if (value == 3) result = 30;
    else if (value == 4) result = 40;
    else if (value == 5) result = 50;
    else if (value == 6) result = 60;
    else if (value == 7) result = 70;
    else if (value == 8) result = 80;
    else if (value == 9) result = 90;
    else result = 0;
}
```

</details>

<br>

## 결과

![image](https://user-images.githubusercontent.com/42164422/130206868-71930c48-fca5-4996-84da-38a3506b1acd.png)

<br>



## 결론

- `switch-case`는 `case`가 3개 이상일 경우 점프 테이블을 생성하여, 메모리를 더 소비하고 `if-else`보다 더 좋은 성능으로 실행된다.

<br>



# 추가 - 각 case의 값 차이가 큰 경우
---

<http://egloos.zum.com/himskim/v/476148>

위 글에 따르면, 연속적인 값의 `case`의 경우 `Address Table`(Jump Table)을 생성하지만

일정 크기(255) 이상으로 차이가 나는 경우에는 `if-else`로 비교한다고 한다.

따라서 이를 확인해본다.

<br>

## 소스 & CIL 코드 [1]

<details>
<summary markdown="span"> 
.
</summary>

```cs
int value = 2;

switch (value)
{
    default:
    case 0: result = 0; break;
    case 1: result = 10; break;
    case 2: result = 20; break;
    case 4: result = 30; break;
    case 5: result = 40; break;
    case 6: result = 50; break;
}
```

```cs
  // 코드 크기       89 (0x59)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4.2
  IL_0001:  stloc.0
  IL_0002:  ldloc.0
  IL_0003:  switch     ( 
                        IL_0024,
                        IL_002c,
                        IL_0035,
                        IL_0024,
                        IL_003e,
                        IL_0047,
                        IL_0050)
  IL_0024:  ldarg.0
  IL_0025:  ldc.i4.0
  IL_0026:  stfld      int32 result
  IL_002b:  ret
  IL_002c:  ldarg.0
  IL_002d:  ldc.i4.s   10
  IL_002f:  stfld      int32 result
  IL_0034:  ret
  IL_0035:  ldarg.0
  IL_0036:  ldc.i4.s   20
  IL_0038:  stfld      int32 result
  IL_003d:  ret
  IL_003e:  ldarg.0
  IL_003f:  ldc.i4.s   30
  IL_0041:  stfld      int32 result
  IL_0046:  ret
  IL_0047:  ldarg.0
  IL_0048:  ldc.i4.s   40
  IL_004a:  stfld      int32 result
  IL_004f:  ret
  IL_0050:  ldarg.0
  IL_0051:  ldc.i4.s   50
  IL_0053:  stfld      int32 result
  IL_0058:  ret
```

</details>

- `case`가 1 칸 떨어진 경우(0~2, 4~6)에는 점프 테이블이 생성된다.

<br>



## 소스 & CIL 코드 [2]

<details>
<summary markdown="span"> 
.
</summary>

```cs
int value = 2;

switch (value)
{
    default:
    case 0: result = 0; break;
    case 1: result = 10; break;
    case 2: result = 20; break;
    case 7: result = 30; break;
    case 8: result = 40; break;
    case 9: result = 50; break;
}
```

```
// 위아래 생략

  IL_0003:  switch     ( 
                        IL_0030,
                        IL_0038,
                        IL_0041,
                        IL_0030,
                        IL_0030,
                        IL_0030,
                        IL_0030,
                        IL_004a,
                        IL_0053,
                        IL_005c)
```

</details>

- `case 2`, `case 7`사이의 `3~6` 값은 `IL_0030`, 즉 `default`로 이어지도록 자동으로 채워지며 점프 테이블을 `case 0 ~ case 9`까지 생성하는 것을 확인할 수 있다.

<br>



## 소스 & CIL 코드 [3]

<details>
<summary markdown="span"> 
.
</summary>

```cs
int value = 2;

switch (value)
{
    default:
    case 0: result = 0; break;
    case 1: result = 10; break;
    case 2: result = 20; break;
    case 9: result = 30; break;
    case 10: result = 40; break;
    case 11: result = 50; break;
}
```

```
  IL_0003:  switch     ( 
                        IL_0029,
                        IL_0031,
                        IL_003a)
  IL_0014:  ldloc.0
  IL_0015:  ldc.i4.s   9
  IL_0017:  sub
  IL_0018:  switch     ( 
                        IL_0043,
                        IL_004c,
                        IL_0055)
```

</details>

- `case 0, 1, 2`와 `case 9, 10, 11`은 `if-else`로 분리된 것을 확인할 수 있다.

- `0, 1, 2, 8, 9, 10`의 경우를 확인했을 때는 모두 점프 테이블이 생성되었다.

- 따라서 정수는 `case` 값 사이의 간격이 `7` 이상일 경우 점프 테이블이 생성되지 않는다는 결론을 내릴 수 있다.

<br>



## 벤치마크

- 점프 테이블이 생성되지 않는 경우 `if-else`와의 성능을 비교한다.

<br>

## 소스 코드

<details>
<summary markdown="span"> 
.
</summary>

```cs
[Benchmark(Baseline = true)]
public void Switch_Case()
{
    int value = 9000;

    switch (value)
    {
        default:
        case 0: result = 0; break; 

        case 1000: result = 10; break; 
        case 2000: result = 20; break; 
        case 3000: result = 30; break; 
        case 4000: result = 40; break; 
        case 5000: result = 50; break; 
        case 6000: result = 60; break; 
        case 7000: result = 70; break; 
        case 8000: result = 80; break; 
        case 9000: result = 90; break; 
    }
}

[Benchmark]
public void If_Else()
{
    int value = 9000;

    if (value == 0) result = 0;
    else if (value == 1000) result = 10;
    else if (value == 2000) result = 20;
    else if (value == 3000) result = 30;
    else if (value == 4000) result = 40;
    else if (value == 5000) result = 50;
    else if (value == 6000) result = 60;
    else if (value == 7000) result = 70;
    else if (value == 8000) result = 80;
    else if (value == 9000) result = 90;
    else result = 0;
}
```

</details>

<br>

## 벤치마크 결과

![image](https://user-images.githubusercontent.com/42164422/130214371-3d247e8b-ceda-4f35-8f9c-366088cea025.png)

- 점프 테이블을 생성하지 않더라도 `switch-case`가 `if-else`보다 빠르다.


<br>

## 벤치마크 코드의 CIL 확인

<details>
<summary markdown="span"> 
.
</summary>

```
// Switch-Case

  // 코드 크기       200 (0xc8)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4     0x2328
  IL_0005:  stloc.0

  IL_0006:  ldloc.0
  IL_0007:  ldc.i4     0xfa0
  IL_000c:  bgt.s      IL_003d

  IL_000e:  ldloc.0
  IL_000f:  ldc.i4     0x3e8
  IL_0014:  bgt.s      IL_0023

  IL_0016:  ldloc.0
  IL_0017:  brfalse.s  IL_006f

  IL_0019:  ldloc.0
  IL_001a:  ldc.i4     0x3e8
  IL_001f:  beq.s      IL_0077
  IL_0021:  br.s       IL_006f

  IL_0023:  ldloc.0
  IL_0024:  ldc.i4     0x7d0
  IL_0029:  beq.s      IL_0080

// ...

  IL_006f:  ldarg.0
  IL_0070:  ldc.i4.0
  IL_0071:  stfld      int32 result
  IL_0076:  ret

  IL_0077:  ldarg.0
  IL_0078:  ldc.i4.s   10
  IL_007a:  stfld      int32 result
  IL_007f:  ret

  IL_0080:  ldarg.0
  IL_0081:  ldc.i4.s   20
  IL_0083:  stfld      int32 result
  IL_0088:  ret

// ...

```

```
// If-Else

  // 코드 크기       178 (0xb2)
  .maxstack  2
  .locals init (int32 V_0)
  IL_0000:  ldc.i4     0x2328
  IL_0005:  stloc.0
  IL_0006:  ldloc.0
  IL_0007:  brtrue.s   IL_0011
  IL_0009:  ldarg.0
  IL_000a:  ldc.i4.0
  IL_000b:  stfld      int32 result
  IL_0010:  ret
  IL_0011:  ldloc.0
  IL_0012:  ldc.i4     0x3e8
  IL_0017:  bne.un.s   IL_0022
  IL_0019:  ldarg.0
  IL_001a:  ldc.i4.s   10
  IL_001c:  stfld      int32 result
  IL_0021:  ret
  IL_0022:  ldloc.0
  IL_0023:  ldc.i4     0x7d0
  IL_0028:  bne.un.s   IL_0033
  IL_002a:  ldarg.0
  IL_002b:  ldc.i4.s   20
  IL_002d:  stfld      int32 result
  IL_0032:  ret

// ...
```

</details>

- `Switch-Case`와 `If-Else`는 생성되는 CIL 코드가 다르다는 것을 알 수 있다.

- 추후 자세히 해석 예정.

- CIL OpCode 참고 : <https://docs.microsoft.com/ko-kr/dotnet/api/system.reflection.emit.opcodes?view=net-5.0#fields>

<br>



# 추가 - 실수 타입
---

<details>
<summary markdown="span"> 
.
</summary>

```cs
float value = 2;

switch (value)
{
    default:
    case 0f: result = 0; break;
    case 1f: result = 10; break;
    case 2f: result = 20; break;
    case 0.1f: result = 30; break;
    case 0.2f: result = 40; break;
    case 0.3f: result = 50; break;
    case 0.001f: result = 60; break;
    case 0.002f: result = 70; break;
    case 0.003f: result = 80; break;
}
```

```
  // 코드 크기       188 (0xbc)
  .maxstack  2
  .locals init (float32 V_0)
  IL_0000:  ldc.r4     2.
  IL_0005:  stloc.0
  IL_0006:  ldloc.0
  IL_0007:  ldc.r4     3.e-03
  IL_000c:  bgt.un.s   IL_003a
  IL_000e:  ldloc.0
  IL_000f:  ldc.r4     1.e-03
  IL_0014:  bgt.un.s   IL_0028
  IL_0016:  ldloc.0
  IL_0017:  ldc.r4     0.0
  IL_001c:  beq.s      IL_006c
  IL_001e:  ldloc.0
  IL_001f:  ldc.r4     1.e-03
  IL_0024:  beq.s      IL_00a1
  IL_0026:  br.s       IL_006c
  IL_0028:  ldloc.0
  IL_0029:  ldc.r4     2.0000001e-03
  IL_002e:  beq.s      IL_00aa
  IL_0030:  ldloc.0
  IL_0031:  ldc.r4     3.e-03
  IL_0036:  beq.s      IL_00b3
  IL_0038:  br.s       IL_006c
  IL_003a:  ldloc.0
  IL_003b:  ldc.r4     0.2
  IL_0040:  bgt.un.s   IL_0054
  IL_0042:  ldloc.0
  IL_0043:  ldc.r4     0.1
  IL_0048:  beq.s      IL_0086
  IL_004a:  ldloc.0
  IL_004b:  ldc.r4     0.2
  IL_0050:  beq.s      IL_008f
  IL_0052:  br.s       IL_006c
  IL_0054:  ldloc.0
  IL_0055:  ldc.r4     0.30000001
  IL_005a:  beq.s      IL_0098
  IL_005c:  ldloc.0
  IL_005d:  ldc.r4     1.
  IL_0062:  beq.s      IL_0074
  IL_0064:  ldloc.0
  IL_0065:  ldc.r4     2.
  IL_006a:  beq.s      IL_007d
  IL_006c:  ldarg.0

// ...
```

</details>

- 실수 타입은 점프 테이블이 생성되지 않는다.


<br>



# 최종 결론
---

- `switch-case`를 사용할 수 있는 경우(지정 값 비교), 언제나 `switch-case`는 `if-else`보다 빠르다.

- 정수 타입만 점프 테이블이 생성될 수 있다.

- `case`의 값이 `7` 이하로 `3개` 이상 연속되는 경우, 점프 테이블이 생성된다.

- 점프 테이블이 생성되는 경우, 더 빠르다.

- 점프 테이블이 생성되지 않더라도, `if-else`의 동등 비교와 `switch-case` 구문으로 생성되는 CIL 코드는 다르다.


<br>

# References
---
- <https://blog.naver.com/PostView.nhn?blogId=tutorials_korea&logNo=221589317912>
- <http://egloos.zum.com/himskim/v/476148>


