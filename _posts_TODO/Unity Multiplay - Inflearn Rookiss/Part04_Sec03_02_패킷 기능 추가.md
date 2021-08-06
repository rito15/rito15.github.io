TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 주요 내용
---

- 패킷의 내용을 `SendBuffer`에 작성하는 부분을 패킷 클래스 내로 집어넣는다.

- `size` 필드는 아예 프로퍼티로 빼서, 각 패킷 클래스마다 고유의 길이를 리턴해주는 것이 좋을 것 같다.

- `ArraySegment<byte>`를 `Packet`으로 다시 변환하는 과정에서 세그먼트의 길이가 `Packet`에 필요한 전체 길이와 다르면 예외를 콜해줘야 한다.








# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







