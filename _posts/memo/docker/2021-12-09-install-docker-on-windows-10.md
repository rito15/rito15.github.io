---
title: Docker - 2. Windows 10 환경에서 도커 설치하기
author: Rito15
date: 2021-12-09 19:43:00 +09:00
categories: [Memo, Docker]
tags: [docker, memo]
math: true
mermaid: true
---

# 가상화(Virtualization) 지원 확인
---

<details>
<summary markdown="span">
...
</summary>

작업 관리자 - 성능 탭에서 `가상화 : 사용`이라고 표시되어 있어야 도커를 사용할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144571065-ce83d90f-e9ab-4f4b-a601-389fec462d23.png)

위와 같이 표시되지 않을 경우, BIOS 설정에서 가상화 옵션을 확인하여 켜주어야 한다.

</details>

<br>


# 윈도우 에디션에 따른 차이
---

<details>
<summary markdown="span">
...
</summary>

Windows Home을 사용할 경우, WSL2를 설치하여 도커 엔진을 구동할 수 있다.

Windows Pro를 사용할 경우, WSL2 또는 Hyper-V 기반으로 도커 엔진을 구동할 수 있다.

Hyper-V를 사용할 수 있더라도 WSL2가 권장된다고 하니, WSL2를 설치하는 것을 추천한다.

</details>

<br>


# WSL2
---

<details>
<summary markdown="span">
...
</summary>

## **Links**
- <https://docs.microsoft.com/ko-kr/windows/wsl/about>
- <https://docs.microsoft.com/ko-kr/windows/wsl/compare-versions>
- <https://docs.microsoft.com/ko-kr/windows/wsl/install>
- <https://docs.microsoft.com/ko-kr/windows/wsl/install-manual>
- <https://www.yalco.kr/_01_install_wsl/>

<br>


## **WSL이란?**

WSL은 Windows Subsystem for Linux의 약자다.

윈도우에서 가상의 리눅스 환경을 구축하여 윈도우 위에서 리눅스를 실행할 수 있게 해준다.

WSL2는 WSL의 두 번째 버전이며, WSL1과 기능 상 차이가 존재한다.

WSL2를 사용해야 도커 엔진을 구동할 수 있다.

<br>


## **윈도우 빌드 버전 확인**

`Windows + R` - `winver`를 실행하여 현재 빌드 버전을 확인할 수 있다.

x64 시스템은 `버전 1903` 이상, `빌드 18362` 이상,

ARM64 시스템은 `버전 2004` 이상, `빌드 19041` 이상이어야 WSL2를 사용할 수 있다.

<br>


## **WSL 설치**

`Windows + X` 키를 눌러 `Windows Power Shell`을 관리자 권한으로 실행한다.

그리고 파워셀에서 다음 명령어를 실행한다.

{% include codeHeader.html %}
```
wsl --install
```

<br>


## **WSL 설정**

이미 설정되어 있는지 확인하려면,

`Windows + R` - `OptionalFeatures`를 실행하여

- Linux용 Windows 하위 시스템
- 가상 머신 플랫폼

이 두 가지가 체크되어 있는지 확인하면 된다.

안되어 있다면, 체크한다.

<br>

번거로운 작업 없이 Power Shell을 통해 간단히 설정하려면, 다음 두 명령어를 입력한다.

{% include codeHeader.html %}
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

{% include codeHeader.html %}
```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

그리고 컴퓨터를 재부팅한다.

<br>


## **WSL2 버전 설정**

파워셀에서 다음 명령어를 실행한다.

{% include codeHeader.html %}
```
wsl --set-default-version 2
```

위 명령어를 실행했을 때 `잘못된 명령줄 옵션입니다`라고 나오는 경우,

윈도우 빌드 버전이 요구치보다 낮을 가능성이 있다.

따라서 윈도우 업데이트를 진행해야 한다.

</details>

<br>


# 도커 설치
---
<details>
<summary markdown="span">
...
</summary>


- <https://www.docker.com/get-started>

위 링크에서 `Download for Windows`를 클릭하여 설치한다.

<br>

설치 파일을 실행하면

![image](https://user-images.githubusercontent.com/42164422/144572553-00a65ef7-12ed-47f2-85b2-ef0cf6b2f139.png)

WSL2가 설치되지 않은 환경의 Windows Pro 에디션의 경우, 위와 같은 모습을 볼 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144591860-486ed4d3-ec79-436f-83d7-a183faf27646.png)

WSL2가 설치된 Windows Home, Pro 환경에서는 이런 모습을 볼 수 있다.

<br>

Hyper-V를 사용할 수 있더라도 WSL2를 사용하는 것이 권장된다고 한다.

어쨌든 각각 첫 번째 체크박스에 체크한 채로 설치를 진행한다.

![image](https://user-images.githubusercontent.com/42164422/144592467-ccfe7877-8aee-43b5-a916-13ee262561d3.png)

<br>

![image](https://user-images.githubusercontent.com/42164422/144592688-2e8dc930-752b-48ad-96f8-59a5e11fe9f7.png)

설치하다 보면 도커가 갑자기 윈도우에서 로그아웃하라는 요구를 한다.

요구를 들어주면 된다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144593004-e7ae5833-8774-44e8-baca-af1eb751f222.png)

그리고 다시 윈도우에 로그인하면 시스템 트레이에 위와 같이 귀여운 고래 아이콘이 생기는데,

더블 클릭하여 실행해준다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144593127-8b386186-8aa1-4d0e-95e9-573306d29e72.png)

이번엔 약관에 동의해달라고 한다.

`I accept the terms`에 체크하고 `Accept`를 눌러 진행한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144593254-d7783e2a-0444-4d7d-a54e-806958b48e32.png)

이렇게 WSL2 설치가 완벽하지 않다로 경고 창을 띄우는 경우가 있는데,

문구에 보이는 <https://aka.ms/wsl2kernel>을 클릭하여 링크로 들어간다.

그리고 일단 경고 창은 닫지 말고 남겨둔다.

![image](https://user-images.githubusercontent.com/42164422/144593471-538ddc9b-21d3-40b3-9ede-9334f1e5f8d5.png)

페이지에서 [x64 머신용 최신 WSL2 Linux 커널 업데이트 패키지](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi) 라고 적혀 있는 곳을 클릭하고, 다운로드된 설치 파일(wsl_update_x64.msi)을 실행한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144593737-dd7005f0-d804-4a95-876b-ca1749ea2ebc.png)

![image](https://user-images.githubusercontent.com/42164422/144593872-b1ab0ce7-03c5-4cf4-8212-fc95f100f4ec.png)

이렇게 설치가 끝났으면

![image](https://user-images.githubusercontent.com/42164422/144593910-91edca3b-d276-41e9-85da-89cbb059e99c.png)

다시 이 창으로 돌아와서 `Restart`를 클릭한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144593992-c4f8471e-9105-4bb0-8beb-dd45155e9808.png)

그럼 이제 위와 같이 고래가 구동을 시작한다.

</details>

<br>


# 튜토리얼
---
<details>
<summary markdown="span">
...
</summary>


![image](https://user-images.githubusercontent.com/42164422/144594134-2495bfe2-e63c-447a-bd46-0b5347d9dd7e.png)

설치가 끝나면 이렇게 튜토리얼을 제안한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144594271-7699e5d4-d9f3-4658-9873-198dc96796d8.png)

튜토리얼은 Clone - Build - Run - Share 4가지 챕터로 구성되어 있고,

아주 간단히 도커의 기본적인 사용법을 익혀볼 수 있다.

명령어도 직접 작성하지 않고 중앙의 하늘색 버튼을 클릭하여 실행할 수 있다.

<br>

튜토리얼을 최소 3단계까지 완료하여 컨테이너를 실행했으면

웹 브라우저에서 <http://localhost/>로 접속하여 

![image](https://user-images.githubusercontent.com/42164422/144595726-254031ff-fc1a-4cb2-b52a-a3abcbba60d3.png)

이런 페이지가 정상적으로 표시되는 것을 확인할 수 있다.

<br>

실행된 컨테이너를 종료하려면

우선 `docker ps`명령어를 통해 현재 실행된 컨테이너 목록을 확인한다.

그리고 컨테이너 ID(`CONTAINER ID`)를 확인한 뒤,

`docker stop {컨테이너 ID}` 명령어를 통해 종료할 수 있다.

</details>

<br>

# 추가: 가상화 설정 체크리스트
---

<details>
<summary markdown="span">
...
</summary>

## **[1] 메인보드 설정**
- CPU Configuration - 가상화 Enabled

## **[2] Windows 기능 활성화**

> `Windows + R` - `OptionalFeatures`

- Hyper-V
- Linux용 Windows 하위시스템
- 가상 머신 플랫폼
- Windows 하이퍼바이저 플랫폼

## **[3] 그래도 에러나는 경우**

- 관리자 권한으로 PowerShell 실행 후 다음 명령어 실행
- 참고 : <https://www.lainyzine.com/ko/article/how-to-disable-hyper-v-in-windows-10/>
- 재부팅

```ps
bcdedit /set hypervisorlaunchtype auto    # 가상화 켜기
```

## **참고:PS**

```ps
bcdedit /enum | findstr "hypervisor"      # off: 가상화 꺼짐 / auto: 켜짐(자동)

bcdedit /set hypervisorlaunchtype off     # 가상화 끄기(앱플레이어 등 사용하는 경우)
```

</details>

<br>


# References
---
- <https://docs.docker.com/desktop/windows/install/>
- <https://www.lainyzine.com/ko/article/a-complete-guide-to-how-to-install-docker-desktop-on-windows-10/>
- <https://iforint.tistory.com/158>
- <https://lazymolt.tistory.com/71>
- <https://forgiveall.tistory.com/607>