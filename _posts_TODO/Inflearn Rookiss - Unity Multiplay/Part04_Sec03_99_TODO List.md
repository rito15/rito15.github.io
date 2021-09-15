TITLE : Part04가 끝나고 마무리할 처리들

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>



# Todo List
---

## 클라이언트가 패킷 Size를 속이는 것 방지하기

- 일차원 배열에 패킷 ID별로 MaxSize를 저장한 Lookup Table 생성

- PacketSession.OnReceived()에서 Size 뿐만 아니라 ID까지 확인

- Size가 MaxSize를 넘을 경우 패킷을 폐기하고 즉시 수신 버퍼 초기화

<br>


## 모든 예외 처리

- 릴리즈 모드에서는 처리되지 않은 예외가 없도록 모두 핸들링

- 가능한 모든 상황에 대처하여 부드럽게 진행되어야 한다.






# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







