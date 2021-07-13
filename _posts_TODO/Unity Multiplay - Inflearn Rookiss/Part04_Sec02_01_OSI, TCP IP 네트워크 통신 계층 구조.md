TITLE : OSI 7 Layer, TCP/IP 4 Layer

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# Note
---

![image](https://user-images.githubusercontent.com/42164422/125401703-76d00d00-e3ee-11eb-8c47-913b113b2856.png)

<br>

# OSI 7 Layer
---

## **[7] Application**

## **[6] Presentation**

## **[5] Session**

## **[4] Transport**

## **[3] Network**

## **[2] Data Link**

## **[1] Physical**

<br>

# TCP/IP 4 Layer
---

## **[4] Application**
- OSI 7 Layer의 **Application(7)**, **Presentation(6)**, **Session(5)** 계층에 해당한다.
- 사용자에게 응용 프로그램의 서비스를 위한 표준 인터페이스를 제공한다.
- 인터넷 브라우저, 텔넷, 네트워크 서비스 등이 이 계층에 속한다.

- **데이터 단위** : `Data`, `Message`
- **프로토콜** : `HTTP`, `Telnet`, `SSH`, `FTP`, `SMTP`, `POP3`, `DNS`

<br>

## **[3] Transport**
- OSI 7 Layer의 **Transport(4)** 계층에 해당한다.
- 통신 프로세스 간의 연결 제어와 데이터 송수신을 담당한다.
- 프로세스가 사용하는 포트 번호를 논리적 주소로 사용한다.

- **데이터 단위** : `Segment`
- **프로토콜** : `TCP`, `UDP`, `RTP`, `RTCP`

<br>


## **[2] Internet**
- OSI 7 Layer의 **Network(3)** 계층에 해당한다.
- 호스트 간의 라우팅을 담당한다.
- 단말을 구분하기 위해 논리적 주소인 IP를 할당한다.

- **데이터 단위** : `Packet`
- **프로토콜** : `IP`, `ARP`, `ICMP`, `RARP`, `OSPF`

<br>


## **[1] Network Interface**
- OSI 7 Layer의 **Data Link(2)**, **Physical(1)** 계층에 해당한다.
- IP주소와 같은 논리 주소 대신, MAC과 같은 물리 주소를 참조하여 데이터를 전송한다.
- 에러 검출과 패킷의 프레임화를 담당한다.

- **데이터 단위** : `Frame`
- **프로토콜** : `Ethernet`, `Token Ring`, `PPP`

<br>







# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>
- <https://shlee0882.tistory.com/110>
- <https://ehclub.co.kr/1470>
- <https://snyung.com/content/2020-08-31--네트워크-기초-OSI-7-계층과-TCP-IP-계층>
- <https://reakwon.tistory.com/68>






