TITLE : 패킷 생성 자동화

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

- XML 데이터 이용해서 MaxSize 배열도 생성

<br>


# 패킷 자동화 구현 이전 변경사항
---

강의의 내용과는 좀 다르게, 나는 `Packet` 클래스에서 정적 메소드 `CreateFromByteSegment()` 메소드를 통해

`ArraySegment<byte> buffer` 매개변수를 받아 이를 분석하고, 해당하는 패킷을 만들어 리턴하도록 구현했다.

이를 변경하여 자동화에 적합하도록

`ArraySegment<byte>`를 해석하여 패킷을 생성하는 부분은 각자의 클래스에

`bool Read(ArraySegment<byte> buffer)`처럼 작성하도록 변경해야 할 것 같다.

기존 방식처럼 정적 메소드를 통해 생성하는 방식은 언제나 가비지를 생성하기 때문에

강의의 방식인 "객체 생성 후 버퍼 읽어들여 필드 초기화"가 나을 것 같다.

이렇게 하면 이미 만들어진 객체를 이용해 재사용할 수 있다는 이점도 있다.

그리고 `Size` 같은 프로퍼티 또한 없애는 것이 좋을 것 같다.

`Size`는 패킷과 버퍼의 변환 간에 필요할 뿐, 패킷 클래스가 이를 보관할 필요도 없다.

지금 `Size` 프로퍼티는 생성자로부터 초기화되며 `Write()` 메소드에서 사용되는데,

없애버리고 그냥 매번 `Write()`에서 계산하도록 하는 것이 좋을 듯하다.

마지막으로 리스트를 필드로 갖는 패킷은 내부 구조체를 선언하고

재귀적으로 `Read/Write`를 수행하도록 변경해야 한다.

마지막으로 생성자에 대한 고민이 있는데,

굳이 패킷별로 거창한 옵션을 주는 것보다

기본 생성자 하나, 모든 필드에 대한 매개변수를 받아 전부 초기화하는 생성자 하나씩 작성하면 될 것 같다.

<br>

## **정리 : 자동화를 위한 변경**
- 각 패킷 클래스마다 생성자는 기본 생성자와 전부 초기화 생성자 두 개만 작성
- `Size` 프로퍼티 제거
- `Packet` 클래스의 `CreateFromByteSegment()` 메소드 제거 및 각 패킷 클래스에 `Read()` 메소드 작성
- 리스트 필드가 존재하는 경우, 내부 구조체 선언 및 재귀 구조로 변경







# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







