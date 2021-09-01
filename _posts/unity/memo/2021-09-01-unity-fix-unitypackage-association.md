---
title: 유니티 .unitypackage 확장자 연결 끊어진 경우 해결하기
author: Rito15
date: 2021-09-01 23:33:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Note
---

컴퓨터에 설치된 유니티 에디터 버전 중 하나를 지운 경우,

`.unitypackage` 확장자의 연결이 끊어지는 경우가 종종 있다.

확장자의 연결 프로그램이 단순한 응용 프로그램 실행이라면 상관 없지만,

`.unitypackage` 확장자의 경우 그렇지 않기 때문에 연결프로그램 연결만으로는 해결할 수 없다.

이를 비교적 간단히 해결하기 위한 두 가지 방법이 있다.

아래의 두 가지 방식 중 하나를 선택해서 하면 된다.

<br>



# 1. 명령 프롬프트에서 해결하기
---

우선, 유니티 에디터가 설치된 경로를 알아야 한다.

`C:\Program Files` 경로에 들어가서 `2021.1.16f1`과 같이 유니티 에디터 버전이 쓰여 있는 폴더를 확인한다.

<br>


이제 윈도우 + R 키를 눌러 `cmd`라고 적고, 엔터 키를 누른다.

그러면 명령 프롬프트 창이 뜨는데, 여기서 작업하는 것이 아니라

![image](https://user-images.githubusercontent.com/42164422/131683851-11f71401-bd53-4473-bcdf-9e59ca6c573e.png)

이렇게 작업 표시줄의 명령 프롬프트 아이콘에 우클릭 - [명령 프롬프트]에 다시 우클릭 - [관리자 권한으로 실행]을 눌러서 명령 프롬프트를 관리자 권한으로 실행해준다.

그리고 아래 명령어를 입력한다.

```
ftype unitypackage="C:\Program Files\2019.4.9f1\Editor\Unity.exe" -openfile "%1"
assoc .unitypackage=unitypackage
```

명령어의 `2019.4.9f1`이 쓰여있는 곳에는 위에서 확인한, 자신의 유니티 에디터 버전을 입력해야 한다.

<br>

이제 `.unitypackage` 파일을 실행하고

![image](https://user-images.githubusercontent.com/42164422/131687080-2cd5ef03-6ab8-4dad-ae56-e0fdb913a8b8.png)

이런 창이 뜬다면, `Unity Editor`를 선택하고 그대로 `확인`을 눌러준다.

이런 창이 안뜨고 바로 임포트로 정상적으로 넘어간다면, 어쨌든 잘 해결된 것이다.

<br>



# 2. File Types Man
---

- <https://www.nirsoft.net/utils/file_types_manager.html>

위 링크로 들어가서, 좀 아래 부분에 보면

`Download FileTypesMan`

`Download FileTypesMan for x64`

이런 링크가 있는데, 자신의 운영체제에 맞게 둘 중 하나를 선택해서 다운로드한다.

요즘은 웬만하면 x64일 가능성이 높다.

<br>

그리고 압축을 푼 다음 `FileTypesMan.exe`를 실행한다.

`Edit` - `Find`에서 `.unitypackage`를 찾아간 다음,

![image](https://user-images.githubusercontent.com/42164422/131690243-454545b9-cbce-4de9-bead-3096654ab04a.png)

하단에 존재하는 **Action**(파랗게 선택된 것)을 더블 클릭하고 `Edit Action` 창이 뜨면

`Command-Line:` 부분에

```
"C:\Program Files\2019.4.9f1\Editor\Unity.exe" -openfile "%1"
```

이렇게 작성하고 `Default Action`에 체크한 뒤 `OK`를 눌러준다.

물론 `2019.4.9f1`는 자신의 에디터 버전을 입력해야 한다.

<br>

만약 

![image](https://user-images.githubusercontent.com/42164422/131690757-9d6158e7-ef00-43a7-b179-a0f7b1349637.png)

이렇게 하단에 아무런 **Action**이 존재하지 않는다면,

해당 부분에 우클릭 - `New Action`을 클릭한다.

![image](https://user-images.githubusercontent.com/42164422/131690871-4c813d68-2793-4a71-a71a-0fb287cb82ca.png)

그리고 다음과 같이 

![image](https://user-images.githubusercontent.com/42164422/131691051-2cb91951-d094-4e77-bbe8-dddca0bef4b1.png)

`Action Name`, `Menu Caption`에는 **Open**이라고 적어주고, 

`Command-Line:` 부분에

```
"C:\Program Files\2019.4.9f1\Editor\Unity.exe" -openfile "%1"
```

이렇게 작성하고 `Default Action`에 체크한 뒤 `OK`를 눌러준다.


<br>

# References
---
- <https://docs.microsoft.com/ko-kr/windows-server/administration/windows-commands/ftype>


