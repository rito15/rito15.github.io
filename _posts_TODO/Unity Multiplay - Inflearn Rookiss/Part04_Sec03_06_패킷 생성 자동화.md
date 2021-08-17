TITLE : 

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>



# MEMO
---

- .NET Core Console : PacketGenerator 프로젝트 생성
  - PDL.xml 파일 생성 (Packet Data List)

- PacketFormat 클래스 정의
  - 생성될 소스코드를 @"" 내에 문자열로 싹 넣어두기
  - 문자열 내에 가변적으로 들어갈 부분은 "{0}" 꼴의 포맷 문자열 작성
  - packetFormat : 전체 클래스 문자열
  - memberFormat : @"public {0} {1};" 꼴
  - .. 등등

- PacketGenerator.Program.cs 파일에서 XML 파싱
  - System.Xml.XmlReader 클래스 사용
  - .Read()로 XML을 순회
  - 순회하면서 만난 값들을 활용해 PacketFormat의 각 필드의 포맷팅으로 문자열 생성

  - 구조체 리스트를 사용하는 경우 패킷 클래스 내에서 중첩 정의로 구조체를 생성한다? 왜?
  - 그럼 단순히 프리미티브 타입 리스트는? 그리고 배열은? ????
  - 여기는 좀더 생각해봐야 할듯








# 주요 내용
---

- 










# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







