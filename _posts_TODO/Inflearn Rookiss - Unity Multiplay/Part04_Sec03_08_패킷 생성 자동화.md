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


        // Write() 메소드 내에서 Write 수행(개행으로 연결) - 기본 타입들
        // 0 : 필드 이름
        public static readonly string WriteFormat_default =
@"
SendBuffer.Factory.Write(this.{0});";

        // Write() 메소드 내에서 Write 수행(개행으로 연결) - string
        // 0 : 필드 이름
        public static readonly string WriteFormat_string =
@"
SendBuffer.Factory.Write({0}Len);
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

XML을 해석하며 포맷 스트링들을 Bottom-Up 방식으로 조립하고,

특히 list 타입의 경우에는 재귀적으로 다시 필드를 해석하는 방식으로 구현한다.

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
private static readonly string[] NewLineTabs = new string[]
{
    "\r\n",
    "\r\n    ",
    "\r\n        ",
    "\r\n            ",
    "\r\n                ",
    "\r\n                    ",
};
        
private class PacketStringSet
{
    public string fieldList = "";
    public string writeSizeList = "";
    public string writeList = "";
    public string readList = "";
}

// "packet" 태그 해석
private static void ParsePacket(XmlReader xr, ref string fileString)
{
    string packetName = xr["name"];

    // 필드 포맷팅 준비
    PacketStringSet packetStringSet = new PacketStringSet();

    while (xr.Read() && xr.Depth == 2)
    {
        ParseField(xr, xr.Depth, packetStringSet);
    }

    // 완성된 필드 데이터를 이용해서 패킷 스트링 포맷팅
    string packetString = string.Format(PacketFormat.OnePacketFormat,
        packetName,
        packetStringSet.fieldList,
        packetStringSet.writeSizeList,
        packetStringSet.writeList,
        packetStringSet.readList
    );

    fileString += packetString;
}

// packet 내의 필드 해석
private static void ParseField(XmlReader xr, int depth, PacketStringSet packetStringSet)
{
    if (xr.Depth != depth) return;

    string fieldType = xr.Name.ToLower();
    string fieldName = xr["name"];

    switch (fieldType)
    {
        default:
            packetStringSet.fieldList += 
                string.Format(PacketFormat.FieldFormat, fieldType, fieldName)
                .Replace("\n", NewLineTabs[1]);

            packetStringSet.writeSizeList +=
                string.Format(PacketFormat.WriteSizeFormat_default, fieldType, fieldName)
                .Replace("\n", NewLineTabs[2]);

            packetStringSet.writeList +=
                string.Format(PacketFormat.WriteFormat_default, fieldName)
                .Replace("\n", NewLineTabs[2]);

            packetStringSet.readList +=
                string.Format(PacketFormat.ReadFormat_default, fieldType, fieldName)
                .Replace("\n", NewLineTabs[2]);
            break;

        case "string":
            packetStringSet.fieldList +=
                string.Format(PacketFormat.FieldFormat, fieldType, fieldName)
                .Replace("\n", NewLineTabs[1]);

            packetStringSet.writeSizeList +=
                string.Format(PacketFormat.WriteSizeFormat_string, fieldName)
                .Replace("\n", NewLineTabs[2]);

            packetStringSet.writeList +=
                string.Format(PacketFormat.WriteFormat_string, fieldName)
                .Replace("\n", NewLineTabs[2]);

            packetStringSet.readList +=
                string.Format(PacketFormat.ReadFormat_string, fieldName)
                .Replace("\n", NewLineTabs[2]);
            break;

        case "list":
            PacketStringSet listFieldSet = new PacketStringSet();
            while (xr.Read() && xr.Depth == (depth + 1))
            {
                // 재귀적으로 수행
                ParseField(xr, xr.Depth, listFieldSet);
            }

            string lowerFieldName = FirstCharToLower(fieldName);

            packetStringSet.fieldList +=
                string.Format(PacketFormat.ListFieldFormat,
                    fieldName,
                    lowerFieldName,
                    listFieldSet.fieldList,
                    listFieldSet.writeSizeList,
                    listFieldSet.writeList,
                    listFieldSet.readList
                )
                .Replace("\n", NewLineTabs[depth - 1]);

            packetStringSet.writeSizeList +=
                string.Format(PacketFormat.WriteSizeFormat_list, fieldName, lowerFieldName)
                .Replace("\n", NewLineTabs[depth]);

            packetStringSet.writeList +=
                string.Format(PacketFormat.WriteFormat_list, lowerFieldName)
                .Replace("\n", NewLineTabs[depth]);

            packetStringSet.readList +=
                string.Format(PacketFormat.ReadFormat_list, fieldName, lowerFieldName)
                .Replace("\n", NewLineTabs[depth]);

            break;
    }
}
```

</details>

<br>

# 범용으로 사용할 수 있도록 구현
---

현재는 실행 파일의 경로를 기반으로 `PDL.xml`을 읽고 `GenPacket.cs`를 생성하도록 되어 있지만,

실행 시 읽어낼 `PDL.xml`의 절대 경로를 입력받고, 이를 통해 클래스 파일을 생성하며

`PDL.xml`의 폴더 경로에 `GenPacket.cs`를 저장하도록 구현한다.

```cs
/// <summary> 파일의 폴더 경로 또는 폴더의 상위 폴더 경로 구하기 </summary>
private static string GetParentDirPath(string fileOrFolderPath)
{
    int index = fileOrFolderPath.LastIndexOf('\\');
    if(index < 0) index = fileOrFolderPath.LastIndexOf('/');

    return fileOrFolderPath.Substring(0, index);
}

static void Main(string[] args)
{
    string xmlFilePath = args[0]; // 프로그램 매개변수로 입력받은 XML 파일 경로
    string xmlDirPath = GetParentDirPath(xmlFilePath); // 대상 폴더 경로
    string outputCsPath = $"{xmlDirPath}\\{OutputCsFileName}"; // 출력 파일 경로

    // 2. XML Reader 설정
    XmlReaderSettings settings = new XmlReaderSettings()
    {
        IgnoreComments = true,
        IgnoreWhitespace = true,
    };

    string fileString = PacketFormat.FileFormat;
    string fileContentString = "";
    string packetNameListString = "    Default,\r\n";

    // 3. XML 해석
    using (XmlReader xr = XmlReader.Create(xmlFilePath, settings))
    {
        xr.MoveToContent();

        while (xr.Read())
        {
            if (xr.Depth == 1 && xr.IsStartElement())
            {
                packetNameListString += $"    {xr["name"]},\r\n";
                ParsePacket(xr, ref fileContentString);
            }
        }
    }

    string packetTypeString = 
        string.Format(PacketFormat.PacketTypeFormat, packetNameListString);

    fileString += packetTypeString;
    fileString += fileContentString;

    // 파일로 결과 출력
    File.WriteAllText(outputCsPath, fileString);
}
```

<br>

## **배치 파일 작성**

`ServerCore` 프로젝트에 `Packets/Auto Generation` 폴더를 생성하고,

해당 폴더 경로에 `PDL.xml`을 위치시킨다.

그리고 `GeneratePacket.bat` 배치파일을 생성한다.

```cmd
@echo off

"..\..\..\PacketGenerator\bin\Debug\PacketGenerator.exe" "%cd%\PDL.xml"
```

배치 파일의 내용을 위와 같이 작성하여 원클릭으로 동일 경로에 `GenPacket.cs`를 생성하도록 한다.

<br>

기존에 작성해두었던 모든 패킷 클래스를 제거한다.

이제 패킷을 직접 작성하지 않고, `PDL.xml`을 통해 손쉽게 정의할 수 있게 되었다.

<br>










# References
---
- <https://www.inflearn.com/course/유니티-mmorpg-개발-part4>







