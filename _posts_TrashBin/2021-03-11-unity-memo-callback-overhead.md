---
title: 유니티 - 메소드 호출과 메소드, 람다식 콜백 호출의 오버헤드
author: Rito15
date: 2021-03-11 18:11:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# 테스트 대상
---

## [1] 문장(계산식)

```cs
private static void TestInline()
{
    for (int i = 0; i < count; i++)
    {
        _ = Math.Round(2.3f) * Math.Sin(2.5f);
        _ = Math.Floor(4.4f) * Math.Log10(6.34f);
        _ = Math.Acos(5.5f) * Math.Tan(34.4f);
    }
}
```

## [2] 동일한 문장들을 각각 메소드화하여 호출

```cs
private static void MethodA()
{
    _ = Math.Round(2.3f) * Math.Sin(2.5f);
}
private static void MethodB()
{
    _ = Math.Floor(4.4f) * Math.Log10(6.34f);
}
private static void MethodC()
{
    _ = Math.Acos(5.5f) * Math.Tan(34.4f);
}

private static void TestMethodCall()
{
    for (int i = 0; i < count; i++)
    {
        MethodA();
        MethodB();
        MethodC();
    }
}
```

## [3] 메소드를 Action 파라미터로 전달하여 호출

```cs
private static void ActionCall(System.Action action)
{
    action();
}

private static void TestMethodCallback()
{
    for (int i = 0; i < count; i++)
    {
        ActionCall(MethodA);
        ActionCall(MethodB);
        ActionCall(MethodC);
    }
}
```

## [4] 람다식을 Action 파라미터로 전달하여 호출

```cs
private static void TestLambdaCallback()
{
    for (int i = 0; i < count; i++)
    {
        ActionCall(() => _ = Math.Round(2.3f) * Math.Sin(2.5f));
        ActionCall(() => _ = Math.Floor(4.4f) * Math.Log10(6.34f));
        ActionCall(() => _ = Math.Acos(5.5f) * Math.Tan(34.4f));
    }
}
```

## [5] 메소드를 호출하는 람다식을 Action 파라미터로 전달하여 호출

```cs
private static void TestLambdaMethodCallback()
{
    for (int i = 0; i < count; i++)
    {
        ActionCall(() => MethodA());
        ActionCall(() => MethodB());
        ActionCall(() => MethodC());
    }
}
```

<br>

# C#에서의 테스트
---

## 반복 횟수 : 500,000

![image](https://user-images.githubusercontent.com/42164422/110766312-5ead7d00-8298-11eb-994a-17b1b285d51b.png)

## 반복 횟수 : 1,000,000

![image](https://user-images.githubusercontent.com/42164422/110766248-4d647080-8298-11eb-8c36-cbe8e9013799.png)

## 반복 횟수 : 5,000,000

![image](https://user-images.githubusercontent.com/42164422/110766090-2ad25780-8298-11eb-9433-bff6ac215252.png)

<br>

## 결과

```
[성능 순위]

1. 문장, 메소드 호출
2. 람다식을 콜백으로 전달
3. 메소드를 직접 콜백으로 전달
```

- 유의미한 차이는 없다.

<br>

# 유니티에서의 테스트
---

## 반복 횟수 : 50,000

![image](https://user-images.githubusercontent.com/42164422/110767166-4b4ee180-8299-11eb-891b-b23a7a5ccc08.png)

## 반복 횟수 : 100,000

![image](https://user-images.githubusercontent.com/42164422/110767265-67528300-8299-11eb-98b6-d20ec302fb9a.png)

## 반복 횟수 : 500,000

![image](https://user-images.githubusercontent.com/42164422/110767319-79ccbc80-8299-11eb-9eb1-a0631c5dc63d.png)

## 반복 횟수 : 1,000,000

![image](https://user-images.githubusercontent.com/42164422/110767419-97018b00-8299-11eb-8520-9f5ba8b9fd9b.png)

## 반복 횟수 : 5,000,000

![image](https://user-images.githubusercontent.com/42164422/110767549-b8627700-8299-11eb-8177-a0b7a6ececc5.png)

<br>

## 결과

```
[성능 순위]

1. 문장, 메소드 호출
2. 람다식에 순수한 문장만 콜백으로 전달
3. 메소드를 직접 콜백으로 전달
```

- 유니티 엔진에서는 독특하게, 메소드를 직접 콜백으로 넘긴 경우가 압도적으로 느렸다.

<br>

# 결론
---

- 일반적으로 C#에서는 메소드 호출, 콜백 전달에 있어서 고민할 필요가 없다.

- 유니티 엔진에서 콜백으로 전달해야 한다면, 최대한 람다식을 활용하는 것이 좋다.
