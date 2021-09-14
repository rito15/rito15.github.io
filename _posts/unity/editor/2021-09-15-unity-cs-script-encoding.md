---
title: 유니티 - 한글 주석 인코딩 깨지는 경우 해결하기
author: Rito15
date: 2021-09-15 02:34:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, csharp, editor]
math: true
mermaid: true
---

# Note
---

## **문제 확인**

![image](https://user-images.githubusercontent.com/42164422/133306986-1db2a71b-6019-43ee-8cfc-c83592ba7721.png)

비주얼 스튜디오에서는 위와 같이 잘 보이던 한글 주석이

![image](https://user-images.githubusercontent.com/42164422/133307057-a9738795-85d6-411e-ba81-e377fd50ee75.png)

유니티 에디터에서 보면 이렇게 깨지는 경우가 있다.

그리고 당장은 스크립팅에 문제가 없더라도,

스크립트 파일을 전송하거나 협업을 하게 될 때 문제가 생길 수 있다.

<br>

## **인코딩**

인코딩을 확인해보면

![image](https://user-images.githubusercontent.com/42164422/133307368-3ba13e06-7e25-4caa-9145-09aec17db8d0.png)

`EUC-KR`의 확장인 코드 페이지 949(`CP949`)임을 알 수 있다.

추후 문제가 발생하지 않도록 하려면 유니코드로 저장할 필요가 있다.

<br>

## **EditorConfig 파일 생성**

![image](https://user-images.githubusercontent.com/42164422/133308369-2cefb93e-7ee5-4bd5-ab10-4b94cde020fb.png)

비주얼 스튜디오의 `솔루션 탐색기`에서 솔루션을 우클릭한 뒤,

`추가` - `새 항목`을 클릭한다.


![image](https://user-images.githubusercontent.com/42164422/133309487-3fddb0b4-cf9d-4549-af6b-439b6cca7ca5.png)

`editorconfig 파일(기본값)` 을 선택하고, 이름은 굳이 바꾸지 말고 `추가` 버튼을 클릭한다.

<br>

## **EditorConfig 파일 편집**

![image](https://user-images.githubusercontent.com/42164422/133310377-ef27bac9-9f1b-45ce-a673-a4c69a55b744.png)

**솔루션 탐색기**에 `Solution Items` 폴더가 추가되고,

그 내부에 `.editorconfig` 파일이 생성된 것을 확인할 수 있다.

여기에 우클릭 - `다른 프로그램으로 열기`를 클릭한다.


![image](https://user-images.githubusercontent.com/42164422/133310562-4c8baeec-908a-43d2-82d7-974daed733b9.png)

`소스 코드(텍스트) 편집기`를 선택하고 `확인` 버튼을 클릭한다.


<br>

```
# .editorconfig에 대해 자세히 알아보려면 다음을 참조하세요. https://aka.ms/editorconfigdocs

# All files
[*]
indent_style = space

# Xml files
[*.xml]
indent_size = 2
```

이제 위와 같은 내용을 볼 수 있는데,

`indent_style = space`가 있는 5번째 줄 하단에 한 줄을 추가하고

`charset = utf-8`이라고 입력한다.

```
# .editorconfig에 대해 자세히 알아보려면 다음을 참조하세요. https://aka.ms/editorconfigdocs

# All files
[*]
indent_style = space
charset=utf-8               # <======= 추가

# Xml files
[*.xml]
indent_size = 2
```

그리고 `Ctrl + S`를 눌러 저장한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/133311473-dfd0ecfc-1b37-4031-a355-2f690cffd19a.png)

이제 저장되는 모든 파일은 `UTF-8`로 인코딩되고,

한글도 더이상 깨지지 않는 것을 확인할 수 있다.

<br>

# VS 버전이나 환경이 다른 경우
---

비주얼 스튜디오 버전이나 환경이 달라서 위와 같이 설정할 수 없는 경우,

우선 해당 유니티 프로젝트의 루트 폴더를 연다.

(`Assets`, `Library`, `.sln` 등의 폴더, 파일이 있는 경로)

해당 경로 내에 텍스트 파일을 하나 생성하고, 다음과 같이 입력한다.

```
[*]
charset=utf-8
```

그리고 파일 이름을 통째로 `.editorconfig`으로 변경한다.

이 때, 확장자도 완전히 변경하여 파일 유형이 `텍스트 문서`가 아니라

`EDITORCONFIG 파일`로 바뀌어야 한다.

확장자는 폴더 상단의 `보기` - `파일 확장명`을 체크하여 표시할 수 있다.

확장명을 변경하면 사용할 수 없게 될 수 있다는 경고 창이 뜨면 예를 클릭한다.

<br>

위와 같이 `.editorconfig` 파일을 만들어 놓으면 알아서 적용된다.

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/visualstudio/ide/create-portable-custom-editor-options?view=vs-2019>
- <https://editorconfig.org/>