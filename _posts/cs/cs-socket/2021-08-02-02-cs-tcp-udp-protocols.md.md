---
title: TCP, UDP 프로토콜
author: Rito15
date: 2021-08-02 00:02:00 +09:00
categories: [C#, C# Socket]
tags: [csharp, thread]
math: true
mermaid: true
---

# TCP, UDP 프로토콜
---

- **OSI 7 Layer** 중 4번째, **TCP/IP 4 Layer** 중 3번째인 `Transport` 계층의 통신을 위한 프로토콜

- IP 주소와 포트 번호를 통해 대상을 식별한다.

<br>

# TCP(Transmission Control Protocol)
---

## **개념**
- 데이터를 메시지 형태로 전송하기 위해 IP와 함께 사용하는 프로토콜
- 일반적으로 TCP와 IP를 함께 사용한다.
- IP가 데이터의 전송을 처리한다면, TCP는 패킷의 추적과 관리를 담당한다.

<br>

## **특징**
- 연결형 서비스로 가상 회선 방식을 제공한다.
- 높은 신뢰성을 보장한다.
- 전송 순서가 보장된다.
- 데이터가 손실될 경우, 재전송을 요청한다.
- UDP에 비해서는 속도가 느리다.
- 혼잡 제어, 흐름 제어를 지원한다.
- 데이터의 경계를 구분하지 않는다.

- 두 말단을 바이트 스트림으로 연결하여 데이터를 전송한다.
- 연결이 끊기면 다시 연결되기 전까지 통신할 수 없다는 단점이 있다.

- 전이중(Full Duplex), 점대점(Point to Point) 방식

<br>

## **TCP 소켓의 특징**
- 서버 소켓은 연결만을 담당한다.
- 서버와 클라이언트 소켓은 1대1로 연결된다. (스트림 말단끼리의 연결)

<br>

# UDP(User Datagram Protocol)
---

## **개념**
- 데이터를 데이터그램 단위로 처리하는 프로토콜

<br>

## **특징**
- 비연결형 서비스로 데이터그램 방식을 제공한다.
- 정보를 주고 받는 방식이 아니라, 단순히 전송만 수행한다.
- 신뢰성이 낮다.
- 전송 순서가 보장되지 않는다.
- 데이터가 손실될 경우, 그러려니 한다.
- TCP에 비해 속도가 빠르다.
- 데이터의 경계를 구분한다.

<br>

## **UDP 소켓의 특징**
- 연결이 존재하지 않으므로, 서버와 클라이언트 소켓의 구분이 없다.
- 소켓 대신 IP를 기반으로 데이터를 전송한다.

<br>

# TCP vs. UDP
---

## **TCP**
- 데이터의 손실이 치명적인 경우, 데이터 전송의 신뢰성이 보장되어야 하는 경우 사용한다.
- 예시 : 채팅 서비스

<br>

## **UDP**
- 데이터의 손실이 치명적이지 않은 경우, 간단한 데이터를 빠르게 전송해야 하는 경우 사용한다.
- 예시 : 실시간 스트리밍 서비스

<br>

# 게임 서버 프로토콜 선택
---

- 그저 단순히 TCP 또는 UDP를 사용하는 경우는 거의 없다.
- UDP나 RUDP를 기반으로 추가적인 기능들을 구현하여 사용하는 경우가 많다.

<br>

# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://mangkyu.tistory.com/15>
- <https://velog.io/@hidaehyunlee/TCP-와-UDP-의-차이>
- <https://www.stevenjlee.net/2020/06/29/이해하기-tcp-와-udp-tcp-vs-udp/>
- <https://ohgyun.com/431>
- <https://run-it.tistory.com/20>






