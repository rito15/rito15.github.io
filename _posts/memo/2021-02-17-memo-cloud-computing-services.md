---
title: 클라우드 컴퓨팅 3대 서비스
author: Rito15
date: 2021-02-17 20:40:00 +09:00
categories: [Memo]
tags: [cloud, iaas, paas, saas]
math: true
mermaid: true
---

# IaaS, PaaS, SaaS
---

## 구분
- 기업과 클라우드 서비스 제공자간의 관리 영역 분할 정도에 따라 구분할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108199679-bad12580-7160-11eb-8f6b-7681bbb2d56b.png){:.normal}

![image](https://user-images.githubusercontent.com/42164422/108199675-b9076200-7160-11eb-9bff-58cc51e59a0a.png){:.normal}

## 선택 예시
- IaaS : 인력이 충분하고 자원 및 인프라만 대여하고 싶은 경우
- PaaS : 이미 만들어진 런타임, DB 등의 API를 사용하여 본 개발에만 집중하고 싶은 경우
- SaaS : 특수목적의 소프트웨어들을 바로 사용하고 싶은 경우


<br>

# IaaS(Infrastructure-as-a-Service)
---

## 특징
- 서버 자원, 네트워크, 전력, 스토리지 등의 인프라를 가상화하여 제공한다.

- 사용한 만큼 지불하는 종량제 형식으로 운영된다.

- 보통 운영체제 기반으로 서비스를 제공한다.

<br>
## 장점
- 데이터 센터를 따로 둘 필요가 없다.

- 사용자가 많은 부분을 관리하고 인프라를 자유롭게 활용할 수 있다.

- 대여할 컴퓨팅 자원량을 언제든 탄력적으로 조절할 수 있다.

<br>
## 단점
- 규모가 작아 인력이 부족하거나 인프라 운영 경험이 적은 경우 활용하기 힘들다.

<br>
## 예시
- AWS EC2, S3
- Google Compute Engine (GCE)
- Microsoft Azure
- Digital Ocean

<br>

# PaaS(Platform-as-a-Service)
---

## 특징
- 서버, 네트워크, 스토리지 등의 인프라 뿐만 아니라 런타임(프로그래밍 언어 구동 환경), 미들웨어 등 애플리케이션 실행 및 개발 환경을 제공한다.

- 네트워크의 경우, 오토 스케일링 및 로드밸런싱까지 손쉽게 적용된다.
> - 오토 스케일링(Auto Scaling) : 데이터 통신량에 따라 자동으로 대여하는 가상 서버의 수를 증감하는 기능
> - 로드 밸런싱(Load Balancing) : 데이터 통신 병목을 줄이기 위해 통신 데이터를 여러 가상 서버로 분산 전달하는 기술

<br>
### **미들웨어**
> - 양쪽을 연결하여 데이터를 주고받을 수 있도록 중간 매개 역할을 하는 소프트웨어
> - 양측에서 사용 가능한 API를 제공한다.
> - Hurwitz 분류법에 따라 구분
>   - RPC : 원격 동기/비동기 프로시저 호출
>   - MOM (Message Oriented Middleware) : 비동기적으로 서버와 클라이언트 간의 메시지 송수신 및 보관이 가능한 미들웨어
>   - ORB(Object Request Broker) : OOP 시스템에서 객체와 서비스를 요청, 전송할 수 있도록 지원하는 미들웨어
>   - DB 접속 미들웨어 : 애플리케이션과 DB서버를 연결해주는 미들웨어

<br>
## 장점
- 기본적인 개발 인프라 구축 및 관리를 위한 인력 소모를 크게 줄일 수 있다.

- 사용자가 서비스 외적인 부분에 신경쓸 필요 없이 오로지 애플리케이션 개발과 비즈니스에만 집중할 수 있다.

<br>
## 단점
- IaaS보다 관리상의 자유도가 낮으며, 플랫폼에 종속될 여지가 있다.

- 이미 구현된 형태로 제공되는 기능들을 수정할 수 없다.

- 사용자에게 필요한 기능들이 모두 구현되어 있지 않다면 크게 제약될 수 있다.

- 사용 중인 언어 및 프레임워크와 호환되지 않을 경우, 런타임에 문제가 발생할 수 있다.

<br>
## 예시
- AWS Elastic Beanstalk
- Google App Engine (GAE)
- Windows Azure
- Redhat OpenShift
- Heroku
- Nginx(웹서버)
- MariaDB(데이터베이스)
- Django(웹 프레임워크)

<br>

# SaaS(Software-as-a-Service)
---

## 특징
- 서비스 제공자가 이미 완성해놓은 애플리케이션을 사용자가 이용하는 형태

- 주로 On-Demand(주문형)으로 서비스가 제공된다.

- 소프트웨어를 설치하지 않고 인터넷, 클라우드를 통해 빠르게 실행할 수 있다.

- 이미 완성된 소프트웨어들을 특수 목적으로 제공한다. (클라우드 스토리지 서비스, 웹포토샵 등)

<br>
## 장점
- 필요한 기능이 모두 만들어져 있는 소프트웨어를 곧바로 사용할 수 있다.

- 소프트웨어를 설치하기 위한 물리적 자원이 필요하지 않다.

- 언제 어디서든 접근이 가능하다.

<br>
## 단점
- 이미 완성된 소프트웨어를 사용하기 때문에 커스터마이징이 어렵다.

<br>
## 예시
- Google Apps
- Dropbox
- Salesforce
- WhaTap
- Naver Ndrive

<br>

# References
---
- <https://www.whatap.io/ko/blog/9/>
- <https://azure.microsoft.com/ko-kr/overview/what-is-paas/>
- <https://m.blog.naver.com/PostView.nhn?blogId=shakey7&logNo=221739057486>
- <https://library.gabia.com/contents/infrahosting/9097>
- <https://library.gabia.com/contents/9105>
- <https://library.gabia.com/contents/infrahosting/9123/>
- <https://www.redhat.com/ko/topics/cloud-computing/what-is-iaas>
- <https://www.redhat.com/ko/topics/cloud-computing/what-is-paas>
- <https://www.redhat.com/ko/topics/cloud-computing/what-is-saas>
- <https://m.blog.naver.com/PostView.nhn?blogId=edusns1&logNo=221069285964>