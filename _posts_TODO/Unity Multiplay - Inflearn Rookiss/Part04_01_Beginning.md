# 강좌
---
 - <https://www.inflearn.com/course/유니티-mmorpg-개발-part4#curriculum>

<br>

# 게임 서버의 종류
---

## **1. Web Server**
 - Stateless
 - HTTP Server
 - 질의/응답 형태
 - 단발적 통신에 적합
 - 다양한 웹 프레임워크를 이용해 제작
   - `ASP.NET(C#)`
   - `Spring(Java)`
   - `NodeJS(js)`
   - ...

## **2. Game Server**
 - Stateful
 - TCP Server, Binary Server, Stateful Server ..
 - 실시간 데이터 송수신

### **게임 서버 제작 시 고려사항**
 - 최대 동시 접속자
 - 룸의 규모
 - 서버 분할 - 게임 로직/네트워크/DB
 - 쓰레드 개수와 모델
 - 네트워크 모델
 - 반응성
 - 데이터베이스

<br>

# 솔루션 구조
---

![image](https://user-images.githubusercontent.com/42164422/121874048-f7451480-cd41-11eb-9521-c16e828cf5e2.png)

## Project 1 : Server
 - 실제로 구동될 서버

## Project 2 : ServerCore
 - 서버가 사용할 핵심 기능들

## Project 3 : DummyClient
 - 유니티 클라이언트 역할
 - 테스트용

<br>

## 하나의 솔루션에서 여러 개의 프로젝트 실행
 - 솔루션 속성 - 여러 개의 시작 프로젝트
   - 각각 작업 지정

