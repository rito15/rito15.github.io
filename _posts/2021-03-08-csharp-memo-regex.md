---
title: Regex (정규표현식)
author: Rito15
date: 2021-03-08 17:42:00 +09:00
categories: [Csharp, Csharp Memo]
tags: [csharp, string, regex]
math: true
mermaid: true
---

# Memo
---

## Using

```cs
using System.Text.RegularExpressions;
```

<br>

## 스트링의 오른쪽에서부터 탐색

```cs
Regex.Match(string, pattern, RegexOptions.RightToLeft)
```

<br>

## 찾은 문자열 주변을 변경 (그룹 사용)

```cs
string strExample = "<12> GameObject [23]  ";
string pattern = @"[\s\[\{\(\<]+" + @"([0-9]+)" + @"[\s\]\}\)\>]+";
string replacement = @"($1)";
string result = Regex.Replace(strExample, pattern, replacement);
```

- 패턴에서 "( ~ )"을 통해 캡쳐 그룹을 지정한다.

- replacement 문자열에서 "$1" 패턴 일치 영역을 어떻게 바꿀지 지정한다.

- "$" 뒤의 숫자는 캡쳐 그룹의 인덱스를 가리킨다. (1부터 시작)

- 위에서는 패턴 일치 영역을 "(1번캡처그룹)" 꼴로 바꾸도록 지정한다.

- 결과 : 

```
"<12> GameObject [23]  " -> "(12)GameObject(23)"
```

<br>

## 찾은 문자열만 변경 (다중 그룹 사용)

```cs
string strExample = "<12> GameObject [23]  ";
string pattern = @"([\s\[\{\(\<]+)" + @"([0-9]+)" + @"([\s\]\}\)\>]+)";
string replacement = @"$1X$3";
string result = Regex.Replace(strExample, pattern, replacement);
```

- 패턴에서 바꾸고 싶은 문자열, 앞부분, 뒷부분을 각각 괄호를 사용하여 그룹으로 묶는다. (3개의 그룹 지정)

- replacement에서 패턴 일치 영역을 바꾸도록 지정할 때, 1번, 3번 그룹은 유지하고 중간의 2번 그룹을 "X"로 바꾸도록 지정한다.

- 결과 : 

```
"<12> GameObject [23]  " -> "<X> GameObject [X]  "
```

<br>

- 주의 : "$1", "$3" 사이에 "2" 처럼 숫자가 들어갈 경우, "$12"로 인식함
- 해결책 : 

```cs
regex.Replace(str, @"$1") + "2" + regex.Match(str).Result(@"$3");
```


<br>

## 찾은 문자열들 중 지정한 개수만 변경하기

```cs
string strExample = "<12> GameObject [23]  ";
string pattern = @"([\s\[\{\(\<]+)" + @"([0-9]+)" + @"([\s\]\}\)\>]+)";
string replacement = @"$1X$3";

Regex regex = new Regex(pattern, RegexOptions.RightToLeft); // 우측에서부터 매치
string result = regex.Replace(strExample, replacement, 1);  // 우측의 1개만 변경
```

- Regex 객체를 생성할 때 패턴 문자열과 Regex 옵션을 지정한다.

- Regex 객체의 Replace() 인스턴스 메소드를 호출하여, 시작 인덱스와 개수를 지정할 수 있다.

- 결과 : 

```
"<12> GameObject [23]  " -> "<12> GameObject [X]  "
```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.text.regularexpressions.match.result?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/base-types/substitutions-in-regular-expressions>
- <https://stackoverflow.com/questions/13836145/regex-get-last-occurrence-of-the-pattern/13852967>
- <https://www.csharpstudy.com/Practical/Prac-regex-2.aspx>