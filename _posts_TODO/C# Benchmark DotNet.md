TITLE : C# Benchmark DotNet



# 설치
---

- 비주얼 스튜디오 - `프로젝트` - `NuGet 패키지 관리` - `Benchmark`를 검색하여 설치

<br>


# 사용법
---

## **[1] 테스트 대상 클래스**

### **네임스페이스**

```
using BenchmarkDotNet;
using BenchmarkDotNet.Attributes;
```

<br>


### **클래스 애트리뷰트**

- SimpleJob

- RPlotExporter

<br>


### **필드 애트리뷰트**

- Params

<br>


### **메소드 애트리뷰트**

- GlobalSetup

<br>


## **[2] 테스트 대상 메소드**

- 테스트 메소드는 public이어야 한다.

- 테스트 메소드는 동적이어야 한다.

- 테스트 메소드는 매개변수가 없어야 한다.

- 테스트할 메소드에 `[Benchmark]` 애트리뷰트를 추가한다.



<br>

## **[2] 메인 메소드**

### **네임스페이스**

```
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


<br>


# 사용 예시
---

## **[1] 테스트 코드**



## **[2] 메인 메소드**



## **[3] 실행 결과**


스샷


<br>

# References
---
- <https://github.com/dotnet/BenchmarkDotNet>
- <https://www.sysnet.pe.kr/2/0/11547>