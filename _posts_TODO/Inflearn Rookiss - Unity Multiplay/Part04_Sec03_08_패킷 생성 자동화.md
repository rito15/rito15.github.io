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

```cs
/* 메인 메소드 */

// 3. XML 해석
using (XmlReader xr = XmlReader.Create(path, settings))
{
    xr.MoveToContent();

    while (xr.Read())
    {
        if (xr.Depth == 1 && xr.IsStartElement())
            ParsePacket(xr);
    }
}
```

```cs
// "packet" 태그 해석
private static void ParsePacket(XmlReader xr)
{
    string packetName = xr["name"];

    Console.WriteLine($"\n[{xr.Depth}] Packet : {packetName}");

    while (xr.Read() && xr.Depth == 2)
    {
        ParseField(xr);
    }
}

// packet 내의 필드 해석
private static void ParseField(XmlReader xr)
{
    string fieldType = xr.Name.ToLower();
    string fieldName = xr["name"];

    Console.WriteLine($"  [{xr.Depth}] Field : {fieldType}, {fieldName}");

    switch (fieldType)
    {
        case "list":
            while (xr.Read() && xr.Depth == 3)
            {
                ParseListField(xr);
            }
            break;

        default:
            break;
    }
}

private static void ParseListField(XmlReader xr)
{
    string fieldType = xr.Name.ToLower();
    string fieldName = xr["name"];

    Console.WriteLine($"    [{xr.Depth}] List Field : {fieldType}, {fieldName}");
}
```

`Depth`에 따라 `packet` 태그를 해석하는 `ParsePacket()`,

패킷 내의 필드를 해석하는 `ParseField()`,

필드가 `list`인 경우, 내부의 필드를 해석하는 `ParseListField()`로 이어진다.

<br>

## **파싱 테스트 출력 결과**

```
[1] Packet : EchoPacket

[1] Packet : StringPacket
  [2] Field : string, str

[1] Packet : Vector3Packet
  [2] Field : float, x
  [2] Field : float, y
  [2] Field : float, z

[1] Packet : Vector3ListPacket
  [2] Field : list, Vector3
    [3] List Field : float, x
    [3] List Field : float, y
    [3] List Field : float, z
```

<br>

# 패킷 포맷 스트링 작성
---

생성할 파일의 내용을 Bottom-Up 방식으로 조립하기 위한 포맷 스트링을 미리 정의한다.

예를 들어 `public float value;` 꼴은

`"public {0} {1}";` 처럼 정의한다.

<br>

- **포맷 종류**
  - FileFormat : 전체 파일
  - OnePacketFormat : 패킷 클래스 하나
  - FieldFormat : 필드 선언 한 줄
  - ListFieldFormat : 내부 클래스 정의 및 리스트 필드 정의
  - WriteSizeFormat : `Write()` 메소드 내의 크기 초기화 한 줄
  - WriteFormat : `Write()` 메소드 내의 버퍼 작성 한 줄
  - ReadFormat : `Read()` 메소드 내의 버퍼 읽기 한 줄

<br>

<details>
<summary markdown="span"> 
PacketFormat.cs
</summary>

```cs
/* static class PacketFormat */

        // 파일 기본 포맷
        public static readonly string FileFormat =
@"using System;
";

        // 0 : 패킷 이름(파스칼)
        // 1 : 필드 목록
        // 2 : WriteSizeCalculationFormat - 기본, string, list 타입에 따라 Write
        // 3 : WriteFormat - 기본, list 타입에 따라
        // 4 : ReadFormat - 기본, list 타입에 따라
        // - 보류 - 5 : 매개변수 있는 생성자
        public static readonly string OnePacketFormat =
@"
public class {0}Packet : Packet
{{  {1}

    public {0}Packet() : base(PacketType.{0}) {{ }}

    public override void WriteToSendBuffer()
    {{
        // 패킷 전체 크기 계산
        ushort size = HeaderSize; // Size + ID
        {2}

        // 버퍼에 차례대로 작성
        SendBuffer.Factory.Write(size);
        SendBuffer.Factory.Write(this.ID);
        {3}
    }}

    public override void ReadFromSegment(ArraySegment<byte> segment)
    {{
        int offset = HeaderSize;
        {4}
    }}
}}
";
        
        // 필드 하나(개행으로 연결)
        // 0 : 필드 타입
        // 1 : 필드 이름
        public static readonly string FieldFormat = 
@"
public {0} {1};";

        // 리스트 타입 - 내부 클래스 및 필드 정의
        // 0 : 리스트 타입 이름(파스칼)
        // 1 : 리스트 타입 내 필드들(개행으로 연결) - FieldFormat 사용
        // 2 : 리스트 타입 내 필드들 사이즈 합산(개행으로 연결) - WriteSizeCalcFormat def/str 사용
        // 3 : 리스트 타입 내 필드들 Write - WriteFormat_default 사용
        // 4 : 리스트 타입 내 필드들 Read - WriteFormat_default 사용
        public static readonly string ListFieldFormat =
@"
public class {0}
{{
    {1}

    public static ushort GetPacketSize()
    {{
        ushort size = 0;
        {2}
        return size;
    }}

    public void WriteToSendBuffer()
    {{
        {3}
    }}

    public void ReadFromSegment(ArraySegment<byte> segment, ref int offset)
    {{
        {4}
    }}
}}
";

        // Write() 메소드 내 사이즈 계산(개행으로 연결) - 기본 타입들
        // 0 : 필드 타입
        // 1 : 필드 이름
        public static readonly string WriteSizeFormat_default =
@"
size += sizeof({0}); // this.{1}";

        // Write() 메소드 내 사이즈 계산(개행으로 연결) - string
        // 0 : 필드 이름
        public static readonly string WriteSizeFormat_string =
@"
ushort {0}Len = (ushort)ByteSerializer.DefaultStringEncoding.GetByteCount(this.{0});
size += sizeof(ushort); // {0}Len
size += {0}Len; // this.{0}";

        // Write() 메소드 내 사이즈 계산(개행으로 연결) - list
        // 0 : 리스트 타입 이름(파스칼)
        // 1 : 리스트 타입 이름(카멜)
        public static readonly string WriteSizeFormat_list =
@"
ushort {1}ListCount = (ushort)this.{1}List.Count;
ushort {1}ListSize = (ushort)({0}.GetPacketSize() * {1}ListCount);
size += sizeof(ushort); // {1}ListCount
size += {1}ListSize; // this.{1}List";


        // Write() 메소드 내에서 Write 수행(개행으로 연결) - 기본 타입들, string 포함
        // 0 : 필드 이름
        public static readonly string WriteFormat_default =
@"
SendBuffer.Factory.Write(this.{0});";

        // Write() 메소드 내에서 Write 수행(개행으로 연결) - list
        // 0 : 리스트 타입 이름(카멜)
        public static readonly string WriteFormat_list =
@"
SendBuffer.Factory.Write(vector3ListCount);
for (int i = 0; i < vector3ListCount; i++)
{
    this.vector3List[i].WriteToSendBuffer();
}";

        // Read() 메소드 내에서 필드 하나 읽기(개행으로 연결) - 기본 타입들
        // 0 : 필드 타입
        // 1 : 필드 이름
        public static readonly string ReadFormat_default =
@"
this.{1} = ByteSerializer.Read_{0}(segment, ref offset);";

        // Read() 메소드 내에서 필드 하나 읽기(개행으로 연결) - string 타입
        // 0 : 필드 이름
        public static readonly string ReadFormat_string =
@"
ushort {0}Len = ByteSerializer.Read_ushort(segment, ref offset);
this.{0} = ByteSerializer.Read_string(segment, ref offset, {0}Len);";
        
        // Read() 메소드 내에서 필드 하나 읽기(개행으로 연결) - list 타입
        // 0 : 리스트 타입 이름(파스칼)
        // 1 : 리스트 타입 이름(카멜)
        public static readonly string ReadFormat_list =
@"
ushort {1}ListCount = ByteSerializer.Read_ushort(segment, ref offset);
this.{1}List = new List<{0}>({1}ListCount);

for (int i = 0; i < {1}ListCount; i++)
{
    Vector3 {1} = new {0}();
    {1}.ReadFromSegment(segment, ref offset);
    this.{1}List.Add({1});
}";
```

</details>

<br>

# 패킷 파싱 및 포맷 스트링 조립
---



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

  - 구조체 리스트를 사용하는 경우 패킷 클래스 내에서 중첩 정의로 구조체를 생성한다

- XML 데이터 이용해서 MaxSize 배열도 생성

<br>










# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







