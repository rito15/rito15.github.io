TITLE : 도커의 기초와 주요 명령어들
CATEGORY : MEMO/Docker

# Note
---
- 명령어에서 `{}`는 반드시 작성해야 하는 파라미터, `[]`는 작성하지 않아도 되는 선택적 파라미터를 의미한다.

<br>


<!-- ============================================================ -->

# 1. 이미지
---

## **[1] 허브에서 이미지 찾기**

도커 허브(<https://hub.docker.com/>)에서 원하는 이미지를 찾을 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144743132-57d17bc9-2b0f-43a6-a317-6ce5cf6de91b.png)

**Containers** 카테고리에서 이미지 탐색할 수 있고,

**official image**는 도커에서 관리하는 공식 이미지라는 것을 의미한다.

각 이미지를 클릭하면 세부 정보를 확인할 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/144743293-20824a95-7b40-4dfe-b101-30d511eb4b02.png)

세부 정보에서 이미지 다운로드 명령어와 사용법을 확인할 수 있다.

<br>


<!-- ============================================================ -->

## **[2] 이미지 다운로드**
- <https://docs.docker.com/engine/reference/commandline/pull/>

- 도커 허브에서 이미지를 받아온다.
- 이미 존재하는 경우, 중복하여 받지는 않는다.
- 태그를 지정하여 특정 버전을 받을 수 있다.

```
docker pull [옵션] {이미지 이름}[:태그 | @다이제스트]
```

![image](https://user-images.githubusercontent.com/42164422/144743436-74d34398-7d77-40ed-899b-d0d70ffa1427.png)

<br>


<!-- ============================================================ -->

## **[3] 이미지 목록 표시**
- <https://docs.docker.com/engine/reference/commandline/images/>

- 로컬 저장소에 존재하는 이미지 목록을 표시한다.
- 이미지 이름을 지정할 경우, 해당 이미지만 확인할 수 있다.
- 도커에서 이미지는 리포지토리(Repository)라고 불린다.

```
docker images [옵션] [이미지 이름:태그]
```

![image](https://user-images.githubusercontent.com/42164422/144745919-a94d35fc-9bb9-4cac-a73d-3d39ffa1fb41.png)

<br>


<!-- ============================================================ -->

## **[4] 이미지 제거**
- <https://docs.docker.com/engine/reference/commandline/rmi/>

- 지정한 이미지를 제거한다.
- 해당 이미지로 만들어진 컨테이너가 존재할 경우, `-f` 옵션을 사용해야 강제로 제거할 수 있다.
- 이미지가 참조되는 상태에서 강제로 제거할 경우, 해당 이미지를 참조하는 컨테이너들은 원본 이미지 연결이 끊겨 실행할 수 없게 된다.
- 이미지로 만들어진 컨테이너가 실행 중인 상태에서 강제로 제거할 경우, 실행 중인 컨테이너는 먹통이 된다.

```
docker rmi [옵션] {이미지 이름} [이미지 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144746049-92f39cb0-e009-40aa-b41d-40fc38e9cf08.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--force`|해당 이미지가 컨테이너에 의해 참조되고 있더라도, 강제로 제거한다.|

<br>


<!-- ============================================================ -->

# 2. 컨테이너
---

## **[1] 이미지로부터 컨테이너 생성하고 실행하기**
- <https://docs.docker.com/engine/reference/run/>
- <https://docs.docker.com/engine/reference/commandline/run/>

- 로컬 저장소에 존재하는 이미지로부터 컨테이너를 생성하고 실행한다.
- 기본적으로 현재 사용 중인 CLI에서 Foreground로 컨테이너를 실행하여, 종료 전까지 다른 명령어를 입력할 수 없게 된다.
- 이름을 지정하지 않으면 임의의 이름이 부여된다.

```
docker run [옵션] {이미지 이름}
```

![image](https://user-images.githubusercontent.com/42164422/144745072-98c2e612-5b49-465b-b3dd-dfe3fc65915d.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-d`         |컨테이너를 백그라운드에서 실행한다.|
|`--name {이름}`|컨테이너에 이름을 부여한다.|

<br>

<!-- ============================================================ -->


## **[2] 실행 중인 컨테이너 목록 확인하기**
- <https://docs.docker.com/engine/reference/commandline/ps/>

```
docker ps [옵션]
```

![image](https://user-images.githubusercontent.com/42164422/144745098-3e59d2dd-302a-4389-bbcf-46ce963f38c8.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-a`|중지된 컨테이너를 포함하여 모든 컨테이너 목록을 확인한다.|
|`-ㅣ`|가장 최근에 생성된 컨테이너를 표시한다.|

<br>


<!-- ============================================================ -->

## **[3] 실행 중인 컨테이너 중지하기**
- <https://docs.docker.com/engine/reference/commandline/stop/>

- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 동시에 중지할 수 있다.

```
docker stop [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745163-53a3df57-655c-453c-bec7-d8c172383d9c.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-t {초}`<br>`--time {초}`|지정한 시간(초)만큼 기다린 후 중지한다.|

<br>


<!-- ============================================================ -->

## **[4] 중지된 컨테이너 실행하기**
- <https://docs.docker.com/engine/reference/commandline/start/>

- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 동시에 실행할 수 있다.

```
docker start [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745312-2f0221dd-d4b1-4cdb-a9cb-06f19e1ed7c9.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|||

<br>


<!-- ============================================================ -->

## **[5] 컨테이너 제거하기**
- <https://docs.docker.com/engine/reference/commandline/rm/>

- 만들어진 컨테이너를 제거한다.
- 실행 중인 컨테이너는 제거할 수 없다.
- 여러 개의 컨테이너 이름을 공백으로 구분하여 적으면 한 번에 제거할 수 있다.

```
docker rm [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745374-d38cca8c-6ce0-496b-aba0-d8ca4532a331.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--force`|실행 중이라면 강제로 종료 후 제거한다.|

<br>


<!-- ============================================================ -->

## **[6] 컨테이너 로그 확인하기**
- <https://docs.docker.com/engine/reference/commandline/logs/>

- 대상 컨테이너의 로그를 출력한다.

```
docker logs [옵션] {컨테이너 이름} [컨테이너 이름들]
```

![image](https://user-images.githubusercontent.com/42164422/144745627-bb4020dc-e546-4901-889d-a654b72eb423.png)

<br>

### **주요 옵션**

|옵션|설명|
|---|---|
|`-f`<br>`--follow`|컨테이너가 실행 중이라면 현재 CLI에서 지속적으로 로그를 확인한다.|

<br>



<!-- ============================================================ -->


# 3. 포트포워딩
---

## **[1] 호스트와 컨테이너의 포트**

![image](https://user-images.githubusercontent.com/42164422/144746819-f4a20d37-fbb2-409e-9f60-da8ac61519f0.png)

> 출처 : 생활코딩 유튜브 (<https://www.youtube.com/watch?v=SJFO2w5Q2HI>)


- 클라이언트 또는 브라우저에서 웹 서버에 접속할 때는 호스트에서 지정한 포트로 접속한다.
- 그리고 호스트에서는 해당하는 컨테이너의 포트로 연결해준다.


<br>

<!-- ============================================================ -->

## **[2] 포트 지정하기**
- 컨테이너를 생성할 때(`docker run`) 호스트와 컨테이너가 사용할 포트를 각각 설정해줄 수 있다.
- 컨테이너의 포트는 임의로 지정하는 것이 아니라 이미지에서 정말로 사용하는 포트를 정확히 설정해야 한다.
- 호스트의 포트는 지정한 포트가 현재 사용 중일 경우, 컨테이너를 실행할 수 없다.

```
docker run -p {호스트 포트:컨테이너 포트} {이미지 이름}
```

![image](https://user-images.githubusercontent.com/42164422/144747043-6cd3d77b-b418-4062-9aed-e7a24a863e3c.png)


<!-- ============================================================ -->


# 4. 컨테이너 내부에서 작업하기
---

## **[1] 컨테이너에 명령 전달하기**
- <https://docs.docker.com/engine/reference/commandline/exec/>

- 현재 실행 중인 컨테이너에 명령어를 전달하여 실행한다.

```
docker exec [옵션] {컨테이너 이름} {명령어} [명령어 인수]
```

![image](https://user-images.githubusercontent.com/42164422/144747701-a1333d40-73e3-4644-bae1-34527358a245.png)

<br>

## **[2] 쉘 실행하여 작업하기**
- 지속적으로 연결을 유지하는 `-it` 옵션과 쉘 실행 명령어를 조합하여, 해당 컨테이너의 파일 시스템 내에서 계속 작업할 수 있다.
- `exit` 명령어를 통해 쉘을 종료할 수 있다.

- 리눅스 기초 명령어들
  - `ls` : 현재 디렉토리의 구성을 출력한다.
  - `pwd` : 현재 위치한 디렉토리 경로를 출력한다.

```
docker exec -it {컨테이너 이름} /bin/sh    # 기본 쉘
docker exec -it {컨테이너 이름} /bin/bash  # 배시 쉘
```

![image](https://user-images.githubusercontent.com/42164422/144747902-ec7f8092-1db8-4423-8b14-4a435a70ecc3.png)

<br>

## **[3] 컨테이너 내부 파일 수정하기**
- 도커 허브에서 해당 이미지의 세부 정보 페이지에서 기본 접속 경로를 확인할 수 있다.
- 예를 들어 `httpd` 이미지(아파치 웹 서버)의 경우에는 `/usr/local/apache2/htdocs/`이다.

![image](https://user-images.githubusercontent.com/42164422/144750393-39993ef3-024a-4fa0-87a4-e478adac0ff6.png)

<br>

우선, 다음 명령어들을 컨테이너 쉘 내에서 실행하여 `nano` 에디터를 받아준다.

```
apt update
apt install nano
```

![image](https://user-images.githubusercontent.com/42164422/144750681-c68afcb4-c6a1-4406-870b-e19d09b9c19d.png)

![image](https://user-images.githubusercontent.com/42164422/144750712-703a51a0-4187-477a-8194-c4e949249fbd.png)

<br>

그리고 `/usr/local/apache2/htdocs/` 경로로 들어간 뒤,

![image](https://user-images.githubusercontent.com/42164422/144750740-3bc51106-906b-4c3b-8b85-9c24ce818ce5.png)

![image](https://user-images.githubusercontent.com/42164422/144750787-b47dd29e-8cc7-46a4-8881-6782d0c216de.png)

이렇게 나노 에디터로

![image](https://user-images.githubusercontent.com/42164422/144750815-73826ca6-47aa-4bdc-9068-6130b67cffa3.png)

내용을

![image](https://user-images.githubusercontent.com/42164422/144750849-8d45dabf-abe9-4329-80ef-d20367226571.png)

수정해준다.

<br>

그리고 이제 브라우저로 접속해보면 변경된 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/144751301-c55580d6-25b0-453d-ab16-890d0c92c98f.png)

<!-- ============================================================ -->


# 5. 파일 시스템 연결하기
---

호스트와 컨테이너의 파일 시스템을 연결하여, 기존 작업 환경에서 계속 작업할 수 있게 한다.


https://www.youtube.com/watch?v=AmSKD4p-jhw&list=PLuHgQVnccGMDeMJsGq2O-55Ymtx0IdKWf&index=7




작 성 중




<!-- ============================================================ -->


# References
---
- <https://www.youtube.com/playlist?list=PLuHgQVnccGMDeMJsGq2O-55Ymtx0IdKWf>
- <https://seomal.com/map/1/129>
- <https://docs.docker.com/reference/>