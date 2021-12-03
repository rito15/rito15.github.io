TITLE : 윈도우 환경에서 도커 설치하기
CATEGORY : MEMO/Docker


# Note
---
- Windows 10 기준

<br>


# 가상화(Virtualization) 지원 확인
---

작업 관리자 - 성능 탭에서 `가상화 : 사용`이라고 표시되어 있어야 도커를 사용할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144571065-ce83d90f-e9ab-4f4b-a601-389fec462d23.png)

위와 같이 표시되지 않을 경우, BIOS 설정에서 가상화 옵션을 확인하여 켜주어야 한다.

<br>


# 윈도우 에디션에 따른 차이
---

Windows Home을 사용할 경우, WSL2를 설치하여 도커 엔진을 구동할 수 있다.

Windows Pro를 사용할 경우, WSL2 또는 Hyper-V 기반으로 도커 엔진을 구동할 수 있다.

<br>


# WSL2
---

<details>
<summary markdown="span">
Links
</summary>

- <https://docs.microsoft.com/ko-kr/windows/wsl/about>
- <https://docs.microsoft.com/ko-kr/windows/wsl/compare-versions>
- <https://docs.microsoft.com/ko-kr/windows/wsl/install>
- <https://docs.microsoft.com/ko-kr/windows/wsl/install-manual>
- <https://www.yalco.kr/_01_install_wsl/>

</details>

<br>


WSL은 Windows Subsystem for Linux의 약자다.

윈도우에서 가상의 리눅스 환경을 구축하여,

윈도우 위에서 리눅스를 실행할 수 있게 해준다.

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

안되어 있으면 체크하면 된다.

<br>

Power Shell을 통해 간단히 설정하려면 다음 두 명령어를 입력한다.

```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

그리고 컴퓨터를 재부팅한다.

<br>


## **WSL2 버전 설정**

파워셀에서 다음 명령어를 실행한다.

```
wsl --set-default-version 2
```

<br>


# 도커 설치
---
- <https://www.docker.com/get-started>

위 링크에서 `Download for Windows`를 클릭하여 설치한다.



<br>

# References
---
- <https://docs.docker.com/desktop/windows/install/>
- <https://www.lainyzine.com/ko/article/a-complete-guide-to-how-to-install-docker-desktop-on-windows-10/>
- <https://iforint.tistory.com/158>
- <https://lazymolt.tistory.com/71>
- <https://forgiveall.tistory.com/607>