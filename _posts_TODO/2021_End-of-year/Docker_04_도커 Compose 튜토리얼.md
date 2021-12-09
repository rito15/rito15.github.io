TITLE : 도커 Compose 튜토리얼
CATEGORY : MEMO/Docker


# Network 명령어
---

## **[1] 네트워크 목록 표시**

```
docker network ls
```

<br>

## **[2] 새로운 네트워크 생성**

```
docker network create {이름}
```

<br>

## **[3] 기존 네트워크 제거**

```
docker network rm {이름}
```

<br>



# Docker-compose 명령어
---

## **설명**

작업 환경을 구성하기 위해 매번 컨테이너 생성, 환경 설정, 디펜던시 설정 등을 커맨드라인을 통해 직접 입력하게 되면 굉장히 번거로운 일이 아닐 수 없다.

따라서 `docker-compose.yml` 파일에 이런 내용들을 미리 작성해놓고,

`docker-compose` 명령어들을 통해 아주 간단히 실행하도록 자동화할 수 있다.

<br>

그리고 명령어를 통해 직접 컨테이너들을 생성하면서

컨테이너들을 하나의 네트워크로 묶어, 서로 통신하도록 구성하려면

`docker network` 명령어를 통해 미리 네트워크를 만든 다음에

각 컨테이너를 생성할 때 각각의 컨테이너와 네트워크를 바인딩 해주어야 한다.

<br>

그런데 `docker-compose`를 사용하게 되면 이런 작업이 전혀 필요 없다.

`docker-compose`를 통해 생성하는 컨테이너들은 자동으로 하나의 네트워크로 묶이게 된다.

<br>

## **명령어 특징**

- 모든 `docker-compose` 명령어는 해당 경로 내에 존재하는 `docker-compose.yml` 파일의 내용을 기반으로 동작한다.

<br>

## **[1] 생성 및 실행**

- 해당 경로 내에 존재하는 `docker-compose.yml` 파일을 해석하여 컨테이너들을 생성하고 설정을 적용한다.
- 이미 생성이 완료되었다면 생성 과정 없이 바로 실행한다.
- `-d` 파라미터를 입력하면 실행 후 기존 작업을 이어나갈 수 있고, 입력하지 않으면 로그를 동기적으로 확인한다.

```
docker-compose up
```


<br>

## **[2] 제거**
- 실행되었던 컨테이너들을 종료하고 제거한다.

```
docker-compose down
```

<br>

## **[3] 실행**
- `docker-compose`에 등록된 컨테이너들을 실행한다.
- 컨테이너들이 생성되어 있지 않다면 `up` 명령어를 먼저 수행해야 한다.

```
docker-compose start
```

<br>

## **[4] 종료**
- 실행되었던 컨테이너들을 종료한다.

```
docker-compose stop
```

<br>

## **[5] 재시작**
- 실행되었던 컨테이너들을 종료하고 재시작한다.

```
docker-compose restart
```

<br>

## **[6] 목록 확인**
- 컨테이너들의 목록과 상태를 확인한다.

```
docker-compose ps
```

<br>



# docker-compose.yml 파일 구성
---

## **구성**

```
version: "{스키마 버전}"

services:
  {컨테이너1 이름}:
  
    depends_on: 
      - {먼저 생성되어야 할 컨테이너 이름}
      
    image: {이미지 이름}
    
    ports:
      - {호스트 포트:컨테이너 포트}
    
    volumes:
      - {호스트 파일 시스템 경로}
      
    restart: {no|always|on-failure}
    
    environment:
      {컨테이너 환경 변수 구성}
    
    build: {Dockerfile 경로}
    
    command: {실행할 명령어}
```

<br>

## **옵션 설명**

- `version` : 문서의 스키마 버전을 지정한다.
  - <https://docs.docker.com/compose/compose-file/>

- `services` : 생성할 컨테이너들의 목록을 작성한다.

- `depends_on` : 컨테이너 간의 종속 관계를 설정할 때 사용한다. 지정한 컨테이너가 만들어진 후에 자신의 컨테이너를 만들게 된다.

- `image` : 컨테이너를 만들 베이스 이미지 이름을 지정한다.

- `ports` : 호스트와 컨테이너를 연결할 포트를 지정한다.

- `volumes` : 호스트와 컨테이너 간에 공유할 파일시스템 경로를 지정한다.

- `restart` : 재시작 옵션을 지정한다.

- `environment` : 컨테이너에 등록할 환경 변수를 `{환경 변수 이름}:{값}` 꼴로 지정한다.

- `build` 
  - 이미지를 빌드할 경로를 작성한다.
  - `build: . `과 같이 작성할 경우, `docker-compose`실행 시 해당 경로에 이미지를 빌드하여 생성 후 이 이미지를 베이스 이미지로 사용하게 된다.
  - 하위 옵션을 통해 Dockerfile의 경로를 직접 지정할 경우, 해당 Dockerfile을 통해 이미지를 빌드한다.

- `command` : 컨테이너를 생성하고 실행할 명령어를 작성한다.

<br>

## **예시**

<details>
<summary markdown="span">
...
</summary>

```yaml
version: "3.7"

services:
  db:
    image: mysql:5.7
    volumes:
      - ./db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress_user
      MYSQL_PASSWORD: 123456
  
  app:
    depends_on: 
      - db
    image: wordpress:latest
    volumes:
      - ./app_data:/var/www/html
    ports:
      - "8080:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress_user
      WORDPRESS_DB_PASSWORD: 123456 
```

</details>

<br>



# 예제 실습
---
- [Youtube Link](https://www.youtube.com/watch?v=EK6iYRCIjYs)

<br>

## **명령어 목록**

- [Commands in Gist](https://gist.github.com/egoing/b62aa16573dd5c7c5da51fd429a5faa2)

<details>
<summary markdown="span">
...
</summary>

위 링크의 명령어는 윈도우 커맨드라인에서 사용하려면 다음과 같이 바꿔주어야 한다.

```
docker network create wordpress_net
```

```
docker run --name "db" -v "%cd%/db_data:/var/lib/mysql" -e "MYSQL_ROOT_PASSWORD=123456" -e "MYSQL_DATABASE=wordpress" -e "MYSQL_USER=wordpress_user" -e "MYSQL_PASSWORD=123456" --network wordpress_net mysql:5.7
```

```
docker run --name app -v "%cd%/app_data:/var/www/html" -e "WORDPRESS_DB_HOST=db" -e "WORDPRESS_DB_USER=wordpress_user" -e "WORDPRESS_DB_NAME=wordpress" -e "WORDPRESS_DB_PASSWORD=123456" -e "WORDPRESS_DEBUG=1" -p 8080:80 --network wordpress_net wordpress:latest
```

</details>

<br>



# References
---
- <https://www.youtube.com/watch?v=EK6iYRCIjYs>
- <https://docs.docker.com/compose/>
- <https://docs.microsoft.com/ko-kr/visualstudio/docker/tutorials/use-docker-compose>
- <https://nirsa.tistory.com/79>
- <https://nirsa.tistory.com/80>
- <https://nirsa.tistory.com/81>