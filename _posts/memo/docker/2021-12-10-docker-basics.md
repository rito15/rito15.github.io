---
title: Docker - 3. 도커의 기초와 주요 명령어
author: Rito15
date: 2021-12-10 22:48:00 +09:00
categories: [Memo, Docker]
tags: [docker, memo]
math: true
mermaid: true
---

# Note
---
- 명령어에서 `{}`는 반드시 작성해야 하는 파라미터, `[]`는 작성하지 않아도 되는 선택적 파라미터를 의미한다.

<br>


<!-- ============================================================ -->

# 1. 이미지
---

## **[1] 허브에서 이미지 찾기**

<details>
<summary markdown="span">
...
</summary>

도커 허브(<https://hub.docker.com/>)에서 원하는 이미지를 찾을 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144743132-57d17bc9-2b0f-43a6-a317-6ce5cf6de91b.png){:.normal}

**Containers** 카테고리에서 이미지 탐색할 수 있고,

**official image**는 도커에서 관리하는 공식 이미지라는 것을 의미한다.

각 이미지를 클릭하면 세부 정보를 확인할 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144743293-20824a95-7b40-4dfe-b101-30d511eb4b02.png){:.normal}

세부 정보에서 이미지 다운로드 명령어와 사용법을 확인할 수 있다.

<br>

</details>


<!-- ============================================================ -->

## **[2] 이미지 다운로드**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/pull/>

- 도커 허브에서 이미지를 받아온다.
- 이미 존재하는 경우, 중복하여 받지는 않는다.
- 태그를 지정하여 특정 버전을 받을 수 있다.

```
docker pull [옵션] {이미지 이름}[:태그 | @다이제스트]
```

![image](https://user-images.githubusercontent.com/42164422/144743436-74d34398-7d77-40ed-899b-d0d70ffa1427.png){:.normal}

<br>

</details>


<!-- ============================================================ -->

## **[3] 이미지 목록 표시**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/images/>

- 로컬 저장소에 존재하는 이미지 목록을 표시한다.
- 이미지 이름을 지정할 경우, 해당 이미지만 확인할 수 있다.
- 도커에서 이미지는 리포지토리(Repository)라고도 불린다.

```
docker images [옵션] [이미지 이름:태그]
```

![image](https://user-images.githubusercontent.com/42164422/144745919-a94d35fc-9bb9-4cac-a73d-3d39ffa1fb41.png){:.normal}

<br>

</details>


<!-- ============================================================ -->

## **[4] 이미지 제거**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/rmi/>

- 지정한 이미지를 제거한다.
- 해당 이미지로 만들어진 컨테이너가 존재할 경우, `-f` 옵션을 사용해야 강제로 제거할 수 있다.
- 이미지가 참조되는 상태에서 강제로 제거할 경우, 해당 이미지를 참조하는 컨테이너들은 원본 이미지 연결이 끊겨 실행할 수 없게 된다.
- 이미지로 만들어진 컨테이너가 실행 중인 상태에서 강제로 제거할 경우, 실행 중인 컨테이너는 먹통이 된다.

```
docker rmi [옵션] {이미지 이름} [이미지 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144746049-92f39cb0-e009-40aa-b41d-40fc38e9cf08.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--force`|해당 이미지가 컨테이너에 의해 참조되고 있더라도, 강제로 제거한다.|


</details>
<br>


<!-- ============================================================ -->

# 2. 컨테이너
---

## **[1] 이미지로부터 컨테이너 생성하고 실행하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/run/>
- <https://docs.docker.com/engine/reference/commandline/run/>

- 로컬 저장소에 존재하는 이미지로부터 컨테이너를 생성하고 실행한다.
- 기본적으로 현재 사용 중인 CLI에서 Foreground로 컨테이너를 실행하여, 종료 전까지 다른 명령어를 입력할 수 없게 된다.
- 이름을 지정하지 않으면 임의의 이름이 부여된다.

```
docker run [옵션] {이미지 이름}
```

![image](https://user-images.githubusercontent.com/42164422/144745072-98c2e612-5b49-465b-b3dd-dfe3fc65915d.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`--name {이름}`|컨테이너에 이름을 부여한다.|
|`-d`         |컨테이너를 백그라운드에서 실행한다.|
|`-v {호스트 경로}:{컨테이너 경로}`|호스트와 컨테이너의 파일시스템을 연결한다.|
|`-e {환경변수 이름}={환경변수 값}`|컨테이너의 환경변수를 설정한다.|

<br>

</details>

<!-- ============================================================ -->


## **[2] 실행 중인 컨테이너 목록 확인하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/ps/>

```
docker ps [옵션]
```

![image](https://user-images.githubusercontent.com/42164422/144745098-3e59d2dd-302a-4389-bbcf-46ce963f38c8.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-a`|중지된 컨테이너를 포함하여 모든 컨테이너 목록을 확인한다.|
|`-ㅣ`|가장 최근에 생성된 컨테이너를 표시한다.|

<br>

</details>


<!-- ============================================================ -->

## **[3] 실행 중인 컨테이너 중지하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/stop/>

- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 동시에 중지할 수 있다.
- 이름 대신 컨테이너 ID를 지정할 수도 있다.

```
docker stop [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745163-53a3df57-655c-453c-bec7-d8c172383d9c.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-t {초}`<br>`--time {초}`|지정한 시간(초)만큼 기다린 후 중지한다.|

<br>

</details>


<!-- ============================================================ -->

## **[4] 중지된 컨테이너 실행하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/start/>

- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 동시에 실행할 수 있다.
- 이름 대신 컨테이너 ID를 지정할 수도 있다.

```
docker start [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745312-2f0221dd-d4b1-4cdb-a9cb-06f19e1ed7c9.png){:.normal}

<br>

</details>


<!-- ============================================================ -->

## **[5] 컨테이너 제거하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/rm/>

- 만들어진 컨테이너를 제거한다.
- 실행 중인 컨테이너는 제거할 수 없다.(`-f` 옵션을 사용하면 강제로 제거할 수 있다.)
- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 한 번에 제거할 수 있다.
- 이름 대신 컨테이너 ID를 지정할 수도 있다.

```
docker rm [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745374-d38cca8c-6ce0-496b-aba0-d8ca4532a331.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--force`|실행 중이라면 강제로 종료 후 제거한다.|

<br>

</details>


<!-- ============================================================ -->

## **[6] 컨테이너 로그 확인하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/logs/>

- 대상 컨테이너의 로그를 출력한다.

```
docker logs [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745627-bb4020dc-e546-4901-889d-a654b72eb423.png){:.normal}

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--follow`|컨테이너가 실행 중이라면 현재 CLI에서 지속적으로 로그를 확인한다.|


</details>
<br>



<!-- ============================================================ -->


# 3. 포트포워딩
---

## **[1] 호스트와 컨테이너의 포트**

<details>
<summary markdown="span">
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/144746819-f4a20d37-fbb2-409e-9f60-da8ac61519f0.png){:.normal}

> 출처 : 생활코딩 유튜브 (<https://www.youtube.com/watch?v=SJFO2w5Q2HI>)


- 클라이언트 또는 브라우저에서 웹 서버에 접속할 때는 호스트에서 지정한 포트로 접속한다.
- 그리고 호스트에서는 해당하는 컨테이너의 포트로 연결해준다.

<br>

</details>

<!-- ============================================================ -->

## **[2] 포트 지정하기**

<details>
<summary markdown="span">
...
</summary>

- 컨테이너를 생성할 때(`docker run`) 호스트와 컨테이너가 사용할 포트를 각각 설정해줄 수 있다.
- 컨테이너의 포트는 임의로 지정하는 것이 아니라 이미지에서 정말로 사용하는 포트를 정확히 설정해야 한다.
- 호스트의 포트는 지정한 포트가 현재 사용 중일 경우, 컨테이너를 실행할 수 없다.

```
docker run -p {호스트 포트:컨테이너 포트} {이미지 이름}
```

![image](https://user-images.githubusercontent.com/42164422/144747043-6cd3d77b-b418-4062-9aed-e7a24a863e3c.png){:.normal}

</details>

<br>


<!-- ============================================================ -->


# 4. 컨테이너 내부에서 작업하기
---

## **[1] 컨테이너에 명령 전달하기**

<details>
<summary markdown="span">
...
</summary>

- <https://docs.docker.com/engine/reference/commandline/exec/>

- 현재 실행 중인 컨테이너에 명령어를 전달하여 실행한다.

```
docker exec [옵션] {컨테이너 이름} {명령어} [명령어 인수]
```

![image](https://user-images.githubusercontent.com/42164422/144747701-a1333d40-73e3-4644-bae1-34527358a245.png){:.normal}

<br>

</details>

## **[2] 쉘 실행하여 작업하기**

<details>
<summary markdown="span">
...
</summary>

- 지속적으로 연결을 유지하는 `-it` 옵션과 쉘 실행 명령어를 조합하여, 해당 컨테이너의 파일시스템 내에서 계속 작업할 수 있다.
- `exit` 명령어를 통해 쉘을 종료할 수 있다.

- 리눅스 기초 명령어들
  - `ls` : 현재 디렉토리의 구성을 출력한다.
  - `pwd` : 현재 위치한 디렉토리 경로를 출력한다.

```
docker exec -it {컨테이너 이름} /bin/sh    # 기본 쉘
docker exec -it {컨테이너 이름} /bin/bash  # 배시 쉘
```

![image](https://user-images.githubusercontent.com/42164422/144747902-ec7f8092-1db8-4423-8b14-4a435a70ecc3.png){:.normal}

<br>

</details>

## **[3] 컨테이너 내부 파일 수정하기**

<details>
<summary markdown="span">
...
</summary>

- 도커 허브에서 해당 이미지의 세부 정보 페이지에서 기본 접속 경로를 확인할 수 있다.
- 예를 들어 `httpd` 이미지(아파치 웹 서버)의 경우에는 `/usr/local/apache2/htdocs/`이다.

![image](https://user-images.githubusercontent.com/42164422/144750393-39993ef3-024a-4fa0-87a4-e478adac0ff6.png){:.normal}

<br>

우선, 다음 명령어들을 컨테이너 쉘 내에서 실행하여 `nano` 에디터를 받아준다.

```
apt update
apt install nano
```

![image](https://user-images.githubusercontent.com/42164422/144750681-c68afcb4-c6a1-4406-870b-e19d09b9c19d.png){:.normal}

![image](https://user-images.githubusercontent.com/42164422/144750712-703a51a0-4187-477a-8194-c4e949249fbd.png){:.normal}

<br>

그리고 `/usr/local/apache2/htdocs/` 경로로 들어간 뒤,

![image](https://user-images.githubusercontent.com/42164422/144750740-3bc51106-906b-4c3b-8b85-9c24ce818ce5.png){:.normal}

![image](https://user-images.githubusercontent.com/42164422/144750787-b47dd29e-8cc7-46a4-8881-6782d0c216de.png){:.normal}

이렇게 나노 에디터를 실행하여

<br>

![image](https://user-images.githubusercontent.com/42164422/144750815-73826ca6-47aa-4bdc-9068-6130b67cffa3.png){:.normal}

내용을

![image](https://user-images.githubusercontent.com/42164422/144750849-8d45dabf-abe9-4329-80ef-d20367226571.png){:.normal}

수정해준다.

<br>

그리고 이제 브라우저로 접속해보면 변경된 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144751301-c55580d6-25b0-453d-ab16-890d0c92c98f.png){:.normal}


</details>

<br>

<!-- ============================================================ -->


# 5. 파일시스템 연결하기
---

<details>
<summary markdown="span">
...
</summary>

컨테이너의 파일시스템에 접속하여 내부 파일을 수정할 수 있다.

하지만 이런 방식으로는 한계가 있으며, 다음과 같은 단점들이 있다.

<br>

1. 매번 컨테이너 파일시스템에 접속하여 CLI를 통해 작업해야 한다.
2. 컨테이너가 정지 상태면 작업할 수 없다.
3. 컨테이너가 제거되면 모든 변경사항이 사라진다.

<br>

따라서 이런 문제들을 해결하기 위해, 호스트와 컨테이너의 파일시스템을 연결하여

기존 작업 환경에서 계속 작업하도록 할 수 있다.

<br>

## **[1] 호스트의 환경 구성**

호스트 내의 한 디렉토리에 컨테이너 내의 작업 환경과 일치하도록,

`htdocs` 폴더를 만들고 그 안에 `index.html` 파일을 만든다.

![image](https://user-images.githubusercontent.com/42164422/145363418-6dd1fce9-dde7-4842-8a3a-c54b3c233951.png){:.normal}

<br>

## **[2] 컨테이너 생성 및 파일시스템 연결**

CLI의 현재 경로를 호스트의 해당 디렉토리로 이동한다.

![image](https://user-images.githubusercontent.com/42164422/145363804-fc07aa86-6fc0-4164-ab6d-52dc77317de2.png){:.normal}

<br>

`docker run -v` 옵션을 통해 호스트와 컨테이너의 경로를 입력하여, 파일시스템을 연결할 수 있다.

호스트와 컨테이너의 `htdocs` 디렉토리를 서로 연결해준다.

`-v 호스트 경로:컨테이너 경로` 꼴로 지정할 수 있다.

경로에 공백이나 특수문자가 있는 경우, `-v "host dir:container dir"` 꼴로 큰따옴표로 묶어주면 된다.

{% include codeHeader.html %}
```
docker run --name ws3 -d -p 8000:80 -v "%cd%"/htdocs:/usr/local/apache2/htdocs/ httpd
```

<br>

만약 호스트 파일시스템 내에 해당 디렉토리가 존재하지 않을 경우,

실행과 동시에 해당 경로에 디렉토리가 생성된다.

<br>

브라우저를 통해 `localhost:8000`에 접속해보면 다음과 같이 호스트의 파일이 컨테이너 내에 적용되는 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/145370775-b93a6c33-f039-447f-9c3d-9b272cf6c5f4.png){:.normal}

<br>

`index.html`의 내용을 다음과 같이 수정할 경우,

```html
<html>
    <body>
        T E S T 123
    </body>
</html>
```

![image](https://user-images.githubusercontent.com/42164422/145370917-a82fe6d0-a1e7-42a9-8c0f-857dab4ed2b9.png){:.normal}

이렇게 변경사항이 정상적으로 적용된다.

<br>

마찬가지로 호스트의 `htdocs` 폴더 내에 새로운 파일을 만들거나 파일을 제거해도

해당 변경사항이 컨테이너의 파일시스템 내에 적용된다.

반대로, 컨테이너 내의 파일시스템을 수정하면 그 변경사항이 호스트에 적용된다.

따라서 호스트와 컨테이너는 지정한 경로를 완전히 공유한다고 할 수 있다.

<br>

## **참고 : 경로 관련 기호, 문자열**

### **(1) 리눅스**
- `/` : 최상위 디렉토리
- `~` : 사용자 홈 디렉토리(`/root`)
- `..` : 상위 디렉토리
- `.` : 현재 디렉토리
- `PWD` : 현재 경로 문자열

### **(2) 윈도우**
- `%cd%`: 현재 디렉토리 전체 경로 문자열
- `%userprofile%`: 사용자 디렉토리 전체 경로 문자열


</details>

<br>

<!-- ============================================================ -->


# References
---
- <https://www.youtube.com/playlist?list=PLuHgQVnccGMDeMJsGq2O-55Ymtx0IdKWf>
- <https://seomal.com/map/1/129>
- <https://docs.docker.com/reference/>