---
title: C# Benchmark DotNet
author: Rito15
date: 2021-08-07 16:16:00 +09:00
categories: [C#, C# Memo]
tags: [csharp, benchmark]
math: true
mermaid: true
---

# 설치
---

- 비주얼 스튜디오 - `프로젝트` - `NuGet 패키지 관리` - `Benchmark`를 검색하여 설치

<br>


# 사용법
---

## **[1] 테스트 대상 클래스**

### **네임스페이스**

```cs
using BenchmarkDotNet;
using BenchmarkDotNet.Attributes;
```

<br>


### **클래스 애트리뷰트**

- `[SimpleJob()]`
  - <https://benchmarkdotnet.org/articles/guides/choosing-run-strategy.html>
  - 실행 옵션을 간단히 지정할 수 있다.
  - `launchCount` : 벤치마크 전체 반복 횟수(기본값 : `1`)
  - `warmupCount` : 실제 벤치마크 수행 전, 가상 벤치마크 횟수(기본값 : `10`~`15` 내외)
  - `targetCount` : 벤치마크 내에서 워크로드의 반복 실행 횟수(기본값 : `15`)
  - `invocationCount` : 한 번의 워크로드 내에서 메소드 반복 실행 횟수(너무 작을 경우 신뢰도가 떨어지므로, 천만 단위 이상으로 높이는 것을 권장)

```cs
[SimpleJob(
    launchCount: 3,
    warmupCount: 4,
    targetCount: 5,
    invocationCount: 6
)]
public class MyBenchmark
{
    //...
}
```
<br>


### **필드, 프로퍼티 애트리뷰트**

- `[Params()]`
  - <https://benchmarkdotnet.org/articles/features/parameterization.html>
  - 테스트 진행마다 해당 필드 또는 프로퍼티에 지정된 값을 차례로 넣어 테스트한다.
  - 대상 필드 또는 프로퍼티는 `public`이어야 한다.

```cs
[Params(10)]
public int a;

[Params(100, 200)]
public int B { get; set;}
```

<br>


### **메소드 애트리뷰트**

- `[Benchmark]`
  - <https://benchmarkdotnet.org/articles/features/baselines.html>
  - 테스트를 진행할 메소드를 지정한다.
  - `[Benchmark(Baseline = true)]`로 지정할 경우, 모든 테스트 메소드의 소요 시간 비율을 계산하며, 이 메소드는 기준 값인 `1.00`을 갖는다.

- `[BenchmarkCategory("~~")]`
  - <https://benchmarkdotnet.org/articles/features/baselines.html#sample-introcategorybaseline>
  - 카테고리를 통해 테스트 메소드를 구분하여 실행할 수 있다.
  - 클래스에 `[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]`를 지정해야 한다.
  - 클래스에 `[CategoriesColumn]`를 지정하면 벤치마크 결과 컬럼에 카테고리가 표시된다.

```cs
[GroupBenchmarksBy(BenchmarkLogicalGroupRule.ByCategory)]
[CategoriesColumn]
public class IntroCategoryBaseline
{
    [BenchmarkCategory("Fast"), Benchmark(Baseline = true)]
    public void Time50() => Thread.Sleep(50);

    [BenchmarkCategory("Fast"), Benchmark]
    public void Time100() => Thread.Sleep(100);

    [BenchmarkCategory("Slow"), Benchmark(Baseline = true)]
    public void Time550() => Thread.Sleep(550);

    [BenchmarkCategory("Slow"), Benchmark]
    public void Time600() => Thread.Sleep(600);
}
```

<br>

- `[Arguments()]`
  - <https://benchmarkdotnet.org/articles/features/parameterization.html>
  - 매개변수가 존재하는 메소드일 경우, 매개변수에 맞추어 값을 넣어줄 수 있다.
  - 테스트 진행마다 차례로 인자를 넣어 테스트한다.

```cs
[Arguments(1, 2)]
[Arguments(10, 20)]
public int AddTest(int a, int b) => (a + b);
```

<br>

- `[ArgumentSource(nameof(...))]`
  - <https://benchmarkdotnet.org/articles/features/parameterization.html#sample-introargumentssource>
  - `IEnumerable<object>`를 리턴하는 메소드를 통해 인자 목록을 작성할 수 있다.
  
```cs
// 1. 매개변수 1개인 경우

[Benchmark]
[ArgumentsSource(nameof(TimeSpans))]
public void SingleArgument(TimeSpan time) => Thread.Sleep(time);

public IEnumerable<object> TimeSpans()
{
    yield return TimeSpan.FromMilliseconds(10);
    yield return TimeSpan.FromMilliseconds(100);
}

// 2. 매개변수가 2개인 경우

[Benchmark]
[ArgumentsSource(nameof(Numbers))]
public double ManyArguments(double x, double y) => Math.Pow(x, y);

public IEnumerable<object[]> Numbers()
{
    yield return new object[] { 1.0, 1.0 };
    yield return new object[] { 2.0, 2.0 };
    yield return new object[] { 4.0, 4.0 };
    yield return new object[] { 10.0, 10.0 };
}
```

<br>

- <https://benchmarkdotnet.org/articles/features/setup-and-cleanup.html>

- `[GlobalSetup]`
  - 벤치마크가 시작하기 전에 최초로 한 번 실행된다.

- `[GlobalCleanup]`
  - 벤치마크가 모두 종료되고 실행된다.

- `[IterationSetup]`
  - 각각의 벤치마크가 수행되기 전에 한 번씩 실행된다.

- `[IterationCleanup]`
  - 각각의 벤치마크가 수행된 후 한 번씩 실행된다.

```cs
public class IntroSetupCleanupIteration
{
    private int setupCounter;
    private int cleanupCounter;

    [IterationSetup]
    public void IterationSetup()
        => Console.WriteLine($"// IterationSetup ({++setupCounter})");

    [IterationCleanup]
    public void IterationCleanup()
        => Console.WriteLine($"// IterationCleanup ({++cleanupCounter})");

    [GlobalSetup]
    public void GlobalSetup()
        => Console.WriteLine("// " + "GlobalSetup");

    [GlobalCleanup]
    public void GlobalCleanup()
        => Console.WriteLine("// " + "GlobalCleanup");

    [Benchmark]
    public void Benchmark()
        => Console.WriteLine("// " + "Benchmark");
}
```

<br>


## **[2] 테스트 대상 메소드**

- 테스트 메소드는 public이어야 한다.

- 테스트 메소드는 동적이어야 한다.

- 테스트 메소드에 매개변수가 존재하는 경우, 반드시 `[Arguments()]` 애트리뷰트를 추가하고 매개변수 개수에 맞춰 인자를 넣어줘야 한다.

- 테스트 메소드는 리턴이 존재해도 된다.

- 테스트 메소드에 `[Benchmark]` 애트리뷰트를 추가한다.

```cs
[Benchmark]
public void TestMethod1()
{
    // ...
}

[Benchmark]
[Arguments(10, 12.34f)]
public void TestMethod2(int a, float b)
{
    // ...
}
```

<br>

## **[3] 메인 메소드**

### **네임스페이스**

```cs
using BenchmarkDotNet;
```

## **소스코드**

```cs
static void Main()
{
    BenchmarkRunner.Run<테스트클래스타입>();
}
```

<br>



# 주의사항
---

- `Debug`가 아닌 `Release` 모드에서 진행해야 한다.

- 테스트 대상 클래스도 `public`이어야 한다.


<br>


# 사용 예시
---

## **[1] 테스트 코드**

```cs
using System;
using BenchmarkDotNet;
using BenchmarkDotNet.Attributes;

[SimpleJob(
    launchCount: 3,
    warmupCount: 4,
    targetCount: 5,
    invocationCount:6
)]
public class ByteSerializationBenchmark
{
    public byte[] array;

    [Params(0, 100, 666)]
    public int offset;

    public ushort data;

    [GlobalSetup]
    public void GlobalSetup()
    {
        array = new byte[1024];
        data = 1234;
    }

    [Benchmark(Baseline = true)]
    public void BitConverter_GetBytes()
    {
        byte[] result = BitConverter.GetBytes(data);
        Array.Copy(result, 0, array, offset, result.Length);
    }

    [Benchmark]
    public void BitConverter_TryWriteBytes()
    {
        BitConverter.TryWriteBytes(new Span<byte>(array, offset, sizeof(ushort)), data);
    }
}
```

<br>

## **[2] 메인 메소드**

```cs
using System;
using BenchmarkDotNet.Running;

class CoreMainClass
{
    static void Main(string[] args)
    {
        BenchmarkRunner.Run<ByteSerializationBenchmark>();
    }
}
```

<br>

## **[3] 실행 결과**

![image](https://user-images.githubusercontent.com/42164422/128591780-38e59ac1-fc3f-43e8-b40d-b4df3da9b5f9.png)

<br>

# References
---
- <https://github.com/dotnet/BenchmarkDotNet>
- <https://www.sysnet.pe.kr/2/0/11547>