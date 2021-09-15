TITLE : 패킷 생성 자동화

# 강좌
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>

<br>

# 주요 내용
---

- XML에 패킷의 구조를 미리 정의한다.

- 정의된 패킷 구조를 바탕으로, 원클릭 실행을 통해 패킷 클래스들이 자동으로 생성되도록 PacketGenerator를 구현한다.

<br>

# 새 프로젝트 생성
---

솔루션 내에 `PacketGenerator`라는 이름으로 프로젝트를 새롭게 생성한다.

<br>

# XMl 작성
---

`PacketGenerator` 프로젝트 내에 `PDL.xml` 파일을 생성한다.

```xml
<?xml version="1.0" encoding="utf-8" ?>

<!-- Packet Data List -->
<PDL>
    <packet name="EchoPacket"/>
    
    <packet name="NumberPacket">
        <int name="number"/>
    </packet>
    
    <packet name="StringPacket">
        <string name="str"/>
    </packet>
    
    <packet name="Vector3Packet">
        <float name="x"/>
        <float name="y"/>
        <float name="z"/>
    </packet>
    
    <packet name="Vector3ListPacket">
        <list name="Vector3">
            <float name="x"/>
            <float name="y"/>
            <float name="z"/>
        </list>
    </packet>
</PDL>
```

<br>

# XML 해석 프로그램 작성
---

## **초기 작성**

`PacketGenerator` 프로젝트의 메인 메소드에 작성한다.

```cs
private static readonly string XmlPath = "PDL.xml";
private static readonly int MaxUpperDirectoryDepth = 3;

static void Main(string[] args)
{
    // 1. 상위 폴더로 올라가며 xml 파일 확인
    string path = XmlPath;
    for (int i = 0; i < MaxUpperDirectoryDepth; i++)
    {
        if (File.Exists(path))
        {
            break;
        }

        path = $"../{path}";
    }

    // 2. XML Reader 설정
    XmlReaderSettings settings = new XmlReaderSettings()
    {
        IgnoreComments = true,
        IgnoreWhitespace = true,
    };

    // 3. XML 읽기
    using (XmlReader xr = XmlReader.Create(path, settings))
    {
        xr.MoveToContent();

        while (xr.Read())
        {
            Console.WriteLine(xr.Name);
        }
    }
}
```

그대로 실행하면 `.exe` 파일은 `bin/debug/netcoreapp3.1/...exe` 이런 경로에 생성되므로,

최대 3개의 상위 경로를 올라가며 `PDL.xml` 파일을 확인할 수 있도록 한다.

<br>

## **XML 해석**




<br>

# MEMO
---

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










# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







