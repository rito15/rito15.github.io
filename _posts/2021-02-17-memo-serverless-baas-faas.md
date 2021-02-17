---
title: Serverless, BaaS, FaaS
author: Rito15
date: 2021-02-17 20:40:00 +09:00
categories: [Memo]
tags: [cloud,serverless,baas,faas]
math: true
mermaid: true
---

# 애플리케이션 개발 패러다임 변화
---

![image](https://user-images.githubusercontent.com/42164422/108201665-7dba6280-7163-11eb-99e8-81866cd9f055.png){:.normal}

## 모놀리스(Monolith)
 - 소프트웨어의 모든 구성요소가 한 프로젝트에 통합된 형태
 - 중앙 집중적 구조
 - 변경이 발생할 경우 전체 애플리케이션을 재배포, 재시작해야 한다.
 - 부분의 장애가 전체 서비스의 장애로 이어지는 경우가 발생한다.
 - 서비스가 커지면 커질수록 전체 시스템 구조 파악이 어려워진다.

## 마이크로 서비스(Micro Service Architecture, MSA)
 - 모놀리스의 단점을 보완하기 위한 구조
 - 애플리케이션을 서비스들의 결합으로 구성한다.
 - 각 서비스는 크기가 작을 뿐, 하나의 모놀리스와 유사한 구조를 가진다.
 - 각 서비스는 독립적으로 배포가 가능해야 한다.
 - 각 서비스는 다른 서비스에 대한 의존성이 최소화 되어야 한다.

 - 확장성, 시스템 장애 관리, 배포에 있어서 장점을 가진다.
 - 서비스 간 API 호출이 필요하므로 통신 비용 및 성능상 손해가 발생하며, 트랜잭션의 복잡도가 증가한다.

## 서버리스(Serverless)
 - 클라우드 제공자로부터 완성된 서비스들을 제공받아 사용하는 형태
 - 서버와 인프라를 직접 구축할 필요 없이 완성된 API를 통해 사용할 수 있다.
 - 개발자는 필요한 함수만 만들어 준비하고, 필요할 때 호출하면 된다.

<br>

# Serverless
---

- ## Serverless = FaaS + BaaS

<br>

## 특징
- 클라우드 컴퓨팅 3대 모델과는 달리, 클라우드 제공자가 클라우드 인프라 및 애플리케이션 스케일링을 모두 관리한다.

- 특정 작업을 수행하기 위해서 서버 설정 대신, BaaS와 FaaS에 의존하여 작업을 처리한다.

- BaaS를 통해 제3자의 네트워크, 데이터베이스 등의 API를 사용할 수 있다.
- FaaS를 통해 서버 로직을 개발자가 직접 구현할 수 있다.

- OS, 파일 시스템 관리, 보안 패치, 부하 분산, 용량 관리, 스케일링, 로깅, 모니터링 등의 기능을 모두 서비스로 제공받을 수 있다.

- 기존의 Severless는 보통 Stateless의 특징을 갖고 있었으나, Stateful Serverless도 점점 등장하는 추세이다.

- 관계형 데이터베이스는 확장성과 성능 문제가 발생할 수 있기 때문에 NoSQL 데이터베이스가 적합하다.

<br>
## 장점
- 서버, DB, 통신 등의 인프라를 따로 구축할 필요 없이 이미 만들어진 서비스를 API를 통해 사용함으로써 애플리케이션 기능 개발 자체에 집중할 수 있다.

<br>
## 단점
- 자체 서버를 사용하지 않고 BaaS를 통해 완성된 형태의 API를 제공받아 사용하므로, 시스템의 커스터마이징이 제한된다.

- Stateless일 경우, Cold Start의 특징을 가지며 최초 호출 시 응답 지연이 발생할 수 있다.

<br>

# BaaS : Backend-as-a-Service
---

## 특징
- 서비스 제공자로부터 미리 만들어진 백엔드 API를 제공받아 사용하는 형태

- 데이터 저장 및 로드, 사용자 인증, 메시징, 소셜 서비스 등의 백엔드 기능을 완성된 API로 사용할 수 있다.

- API 사용량 및 서버 사용 시간에 따라 비용을 지불한다.

- 게임 백엔드 서비스는 GBaaS (또는 클라우드 게임서버엔진), 모바일은 MBaaS라고 부른다.

<br>

## 예시
- Google Firebase

## GBaaS 예시
- Gamesparks
- Playfab
- Photon Cloud

<br>

# Faas : Function-as-a-Service
---

## 특징
- 서버리스 컴퓨팅을 '구현'하는 방식

- 서버에서 수행될 기능들을 개발자가 직접 코드로 작성하여 등록한다.

- 실행 가능한 코드(함수)를 미리 등록해놓았다가 특정 이벤트(트리거)가 발생하면 알아서 호출 및 종료되도록 한다.

- PaaS는 전체 애플리케이션을 배포하여 서버에서 애플리케이션이 항상 실행되지만, FaaS는 애플리케이션을 더 작게 쪼갠 함수를 배포하며 작업을 마치거나 일정 시간이 지나면 종료된다는 차이점이 있다.

- 호출한 함수의 횟수와 실행 시간에 따라 비용을 지불한다.

<br>
## 예시
- AWS Lambda
- Google Cloud Functions
- Microsoft Azure Functions (오픈소스)
- OpenFaaS (오픈소스)
- Naver Cloud Functions


<br>

# References
---
- <https://m.blog.naver.com/imays/221046712895>
- <https://m.blog.naver.com/PostView.nhn?blogId=shakey7&logNo=221739057486>
- <https://www.redhat.com/ko/topics/cloud-native-apps/what-is-serverless>
- <https://www.redhat.com/ko/topics/cloud-native-apps/what-is-faas>
- <http://www.comworld.co.kr/news/articleView.html?idxno=49816>
- <https://velog.io/@tedigom/MSA-제대로-이해하기-1-MSA의-기본-개념-3sk28yrv0e>
- <https://velopert.com/3543>

## GBaaS
- <https://blog.ifunfactory.com/2016/07/05/게임-서버-구축-방법-비교-gbaas-vs-설치형-게임-서버-엔진/>
- <https://m.blog.naver.com/imays/221059867376>
- <http://1st.gamecodi.com/board/zboard.php?id=GAMECODI_Talkdev&no=4749>