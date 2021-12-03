TITLE : 도커란?
CATEGORY : MEMO/Docker

# 도커(Docker)란?
---

컨테이너(Container) 기반의 오픈소스 가상화 플랫폼.

운영체제(OS)가 아닌 컨테이너 단위로 실행 환경의 가상화를 제공한다.

이를 통해 프로그램을 컨테이너로 추상화하여 배포 및 관리를 단순하고 효율적으로 할 수 있게 한다.

<br>


# 1. 도커의 장점
---
- 애플리케이션이 실제로 구동되는 환경을 가상화하여 개발 환경과 분리할 수 있다.
- 즉, 누구는 윈도우에서, 누구는 리눅스 또는 맥에서 개발해도 애플리케이션은 리눅스에서 빌드하고 구동시킬 수 있다.

- 하나의 컴퓨터 내에서 프로젝트마다 독립된 개발 환경을 구성할 수도 있다.
- 개발 환경을 새롭게 구축할 때 번거로운 프로세스 없이 간단히 구축할 수 있다.

<br>


# 2. 도커의 가상 환경
---
![image](https://user-images.githubusercontent.com/42164422/144606491-bb90a8bb-1259-4a70-936c-eb0ffa45dd68.png)

- 가상 컴퓨팅은 OS 위에서 또다른 OS를 구동하여 물리적 자원을 분할하여 사용하기 때문에 성능에 한계가 생긴다.
- 하지만 도커는 OS를 새롭게 구동하지 않고, 도커 엔진 위에서 각각의 컨테이너를 통해 실행 환경만 독립, 분할하므로 단일 개발 환경과 비슷한 성능을 보여준다.

<br>


# 3. 레이어(Layer)
---

![image](https://user-images.githubusercontent.com/42164422/144609265-6bf6f03b-c454-4074-9a85-87fd7887d4cb.png)

- 프로그램을 구성하는 파일/폴더들로 이루어진 모듈의 단위.
- 읽기 전용(Read Only), 불변성(Immutable)의 특징을 지닌다.
- 고유 ID를 갖고 있다.

- 한마디로, 레이어란 파일 및 폴더들의 집합이다.

<br>


# 4. 이미지(Image)
---

![image](https://user-images.githubusercontent.com/42164422/144609406-a58cd213-6b83-46ef-89fb-6282c36f2dd4.png)

- 프로그램을 실행하기 위한 파일들을 각각 원하는 설정, 원하는 버전으로 구성하여 이미지라는 형태로 저장한다.
- 하나의 이미지는 여러 개의 레이어로 구성되어 있다.

- 동일한 프로그램이라도 레이어를 추가하거나 제거하여 서로 다른 버전을 가진 이미지로 구성할 수 있다.
- 서로 다른 이미지가 동일 레이어를 사용한다면, 중복해서 저장하지 않고 해당 레이어를 공유하는 방식을 이용한다. <br>
  (공유 파일 시스템, Union File System)

- `Dockerfile` 파일에 고유 문법을 통해 이미지 생성 과정을 정의할 수 있다.

- 한마디로, 이미지는 실행 가능한 프로그램 단위이자, 레이어들의 집합이다.

<br>


# 5. 컨테이너(Container)
---

![image](https://user-images.githubusercontent.com/42164422/144609630-794a2d9b-d0b7-4f0b-99b1-274cd3984356.png)

- 컨테이너는 이미지가 독립 환경에서 실행된 프로세스를 의미한다.
- 이미지에 읽기/쓰기 가능한 컨테이너 레이어(Container Layer)를 추가한 형태다.
- 컨테이너에서의 변경사항은 컨테이너 레이어에 저장된다.

- `docker run` 명령어를 통해 이미지에서 컨테이너를 생성할 수 있다.
- 하나의 프로젝트에서 여러 개의 컨테이너를 동시에 관리하고, 병렬적으로 구동할 수도 있다.

- 한마디로, 컨테이너는 이미지가 실행되어 프로세스로 적재된 상태를 의미한다.

<br>


# References
---
- <https://www.youtube.com/watch?v=tPjpcsgxgWc>
- <https://www.youtube.com/watch?v=chnCcGCTyBg>

- <https://subicura.com/2017/01/19/docker-guide-for-beginners-1.html>
- <https://hoon93.tistory.com/48>
- <https://kimjingo.tistory.com/62>
- <https://eqfwcev123.github.io/2020/01/30/도커/docker-image-layer/>
- <https://www.44bits.io/ko/post/how-docker-image-work>