---
title: CIL 코드 뜯어보기
author: Rito15
date: 2021-06-15 20:00:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# 1. 소스코드 컴파일
---
- 컴파일을 완료하고 `.exe` 또는 `.dll` 파일을 생성한다.

<br>

# 2. 디스어셈블러 실행
---

```
C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools
```

이런 경로로 들어가서

`ildasm.exe` 파일을 찾아 실행한다.

경로는 버전마다 조금씩 차이가 있다.

<br>

# 3. 대상 어셈블리 열기
---

`파일` - `열기`를 통해 앞서 컴파일 완료한 파일을 열어준다.

![image](https://user-images.githubusercontent.com/42164422/122042340-faf59b80-ce14-11eb-9756-ee4b756177ce.png)

<br>

# 4. CIL 코드 확인
---

3에서 원하는 메소드를 찾아 더블클릭한다.

![image](https://user-images.githubusercontent.com/42164422/122042659-6475aa00-ce15-11eb-86a8-ad1a4a303abc.png)

<br>

# 주의사항
---

- 디스어셈블러에서 특정 어셈블리를 열어둔 상태에서는 해당 어셈블리를 컴파일 할 수 없으므로, 다시 컴파일하고 싶다면 디스어셈블러를 꺼야 한다.

