TITLE : Send Buffer

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 개념
---

`Receive Buffer`는 쪼개져 전달될 수 있는 패킷을 버퍼에 임시 보관하고 원하는 길이를 읽어낼 수 있도록 하는 역할을 수행하며, 세션마다 하나씩 존재한다.

`Send Buffer`는 전송할 패킷을 완성하기 위한 임시 버퍼로 사용되며, 역시 세션마다 하나씩 존재할 수 있다.

그런데 세션은 서버-클라이언트 연결 당 하나씩 존재한다.

따라서 내부에서 `Send Buffer`를 이용해 패킷을 조립하게 될 경우

동일한 패킷을 클라이언트의 수만큼 중복 생성해야 하는 문제가 발생한다.

이를 방지하기 위해서는 `Send Buffer`를 세션 외부에서 미리 조립해서 완성하고,

완성된 패킷을 세션으로 가져와 전송하는 방식을 택해야 한다.

<br>

# Send Buffer 클래스
---














# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







