TITLE : Send Buffer

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 개념
---

`Receive Buffer`는 쪼개져 전달될 수 있는 패킷을 버퍼에 임시 보관하고 원하는 길이를 읽어낼 수 있도록 하는 역할을 수행하며, 세션마다 하나씩 존재한다.

`Send Buffer`는 전송할 패킷을 완성하기 위한 임시 버퍼로 사용되며, 역시 세션마다 하나씩 존재할 수도 있다.

그런데 세션은 서버-클라이언트 연결 당 하나씩 존재한다.

따라서 내부에서 `Send Buffer`를 이용해 패킷을 조립하게 될 경우

동일한 패킷을 클라이언트의 수만큼 중복 생성해야 하는 문제가 발생한다.

이를 방지하기 위해서는 `Send Buffer`를 세션마다 하나씩 사용하는 대신

세션 외부에서 미리 조립해서 완성하고,

완성된 `Send Buffer`을 세션으로 가져와 전송하는 방식을 택해야 한다.

<br>

`Send Buffer` 역시 `Receive Buffer`와 마찬가지로, 커서 방식을 사용한다.

하지만 `Receive Buffer`가 `Read`, `Write` 두 개의 커서를 사용하는 데 반해 단 하나의 커서만을 사용하며,

`Send Buffer` 내부의 배열은 전송 시 소켓에 의해 참조되기 때문에

재사용될 경우 아직 참조 되고 있는 배열의 내용을 바꿀 위험이 있다.

따라서 `Receive Buffer`와 달리 재사용되지 않고 패킷의 완성을 위한 일회성 버퍼로 사용된다.

<br>

# Send Buffer 클래스
---














# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







