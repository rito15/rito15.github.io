---
title: C# - XmlReader
author: Rito15
date: 2021-09-21 21:52:00 +09:00
categories: [C#, C# Memo]
tags: [csharp]
math: true
mermaid: true
---

# XML
---

eXTensible Markup Language의 약자로, W3C에서 개발된 마크업 언어.

XML의 대표적인 파생 언어로 HTML이 있다.

기본적인 XML 파일의 확장자는 `.xml`이다.

<br>

# XML 문법
---

<details>
<summary markdown="span"> 
...
</summary>

## **예시**
 - 패킷 데이터 목록 정의

```xml
<?xml version="1.0" encoding="utf-8" ?>

<!-- Packet Data List -->
<packets> <!-- 루트 태그 -->
    <packet name="Echo">
    </packet>
    
    <packet name="Number">
        <int name="number"/>
    </packet>
    
    <packet name="Vector3">
        <float name="x"/>
        <float name="y"/>
        <float name="z"/>
    </packet>
</packets>
```

<br>

## **XML 파일의 첫 줄**

```xml
<?xml version="1.0" encoding="utf-8" ?>
```

첫 줄은 `<?xml ~ ?>` 태그를 작성하여 XML 문서라는 것을 명시해야 하며,

이를 XML 프롤로그(Prologue)라고 한다.

XML의 문서 버전과 인코딩 등 메타데이터를 작성한다.

<br>

## **태그의 종류**

### **[1] 여는 태그와 닫는 태그**

`<packet> ~ </packet>`처럼

여는 태그와 닫는 태그 한 쌍을 이루어 작성한다.

여는 태그와 닫는 태그 사이에 영역을 생성하는 용도로 사용할 수 있다.

### **[2] 단독 태그**

`<packet/>` 처럼 하나의 태그를 단독으로 작성한다.

굳이 열고 닫아서 영역을 생성할 필요가 없는 경우에 사용한다.

<br>

## **태그와 속성**

`<packet name="Echo">` 에서

`packet`은 태그의 이름이고, `name`은 속성 이름, `Echo`는 해당 속성의 값이다.

대표적인 마크업 언어인 HTML과 비교해봤을 때,

XML은 미리 정의된 태그나 속성의 이름이 없다.

각 XML 파일마다 원하는 대로 작성할 수 있다.

<br>

## **태그와 속성 규칙**

- 태그와 속성의 이름은 영문자 또는 `_`로 시작해야 하며, 공백을 포함할 수 없다.

- 태그와 속성의 이름은 대소문자를 구분한다.

- 속성의 이름은 하나의 태그 내에서 중복될 수 없다.

- 속성은 속성 값과 함께 `속성="속성값"` 형태로 작성해야 한다.

<br>

## **태그의 값**

```xml
<name>김개똥</name>
```

위와 같은 형태로 여는 태그와 닫는 태그 사이에 값을 작성할 수 있다.

하나의 값을 표현할 때 위와 같이 태그 값으로 표현할 수도 있고,

```xml
<name value="김개똥"/>
```

이렇게 속성값으로 표현할 수도 있으며

이건 원하는 대로 작성하면 된다.

<br>

## **주석 태그**

```xml
<!-- 주석 1 -->
<packet name="Some Packet"> <!-- 주석 2 -->
```

`<!--`로 열고 `-->`로 닫는 형태로 작성하며,

다른 태그 내에 작성할 수는 없다.

</details>

<br>



# C# XML
--- 

## **네임스페이스**

```cs
using System.Xml;
```

<br>

## **XmlReader 클래스**

<details>
<summary markdown="span"> 
...
</summary>

**Forward-only** 방식으로, XML 파일의 내용을 메모리에 올리지 않고  커서를 통해 순차적으로 읽어낸다.

크기가 큰 XMl 파일을 읽을 때 유리하다.

`XmlReader.Create()` 정적 메소드를 통해 XML 내용을 읽어들이고, 객체를 생성한다.

XML 내의 노드들을 순회하는 커서가 존재하고,

`xmlReader.Read()` 또는 `.ReadAsync()` 메소드를 통해 커서를 이동한다.

`<packet>text</packet>`를 예시로, `<packet>`, `text`, `</packet>`

각 요소가 하나의 노드로 취급된다.

</details>

<br>

## **XmlDocument 클래스**

<details>
<summary markdown="span"> 
...
</summary>

XML DOM 방식을 사용한다.

XMl 파일 내용을 메모리에 통째로 로드하고 계층 구조를 생성한다.

객체 생성 후, `XmlDocument.Load()` 인스턴스 메소드를 통해 XML 파일 내용을 읽어들인다.

`XmlDocument.LoadXml()` 메소드를 통해 XML 텍스트를 읽어올 수도 있다.

</details>

<br>



# C# XmlReader 클래스 API
---

## **[1] 생성자**
 - `XmlReader` 클래스는 추상 클래스이며, 대신 `.Create()` 메소드를 사용한다.
 - 구현 클래스인 `XmlTextReader`는 생성자를 통해 생성할 수 있다.


## **[2] 인덱서**

- **[string] : string**
  - `xmlReader["name"]` 꼴로 현재 태그의 속성 이름을 인덱서의 매개변수로 넣고 속성 값을 리턴한다.


## **[3] 프로퍼티**

<details>
<summary markdown="span"> 
...
</summary>

### **Name : string**
  - 현재 커서 위치의 노드 이름

### **Depth : int**
  - 노드의 계층 깊이
  - 루트 태그의 깊이 값은 0

### **NodeType : XmlNodeType**
  - 노드의 종류
  - `XmlDeclaration` : xml 최상단의 정의 노드(`<?xml ~ ?>`)
  - `Element` : 여는 태그 또는 단독 태그
  - `EndElement` : 닫는 태그
  - `Comment` : 주석 태그
  - `Text` : 단순 문자열. 

### **Value : string**
  - 해당 노드가 갖고 있는 값. 여는 태그와 닫는 태그 사이에 있는 태그 값을 참조할 수 있다.

### **ReadState : ReadState**
  - 현재 XmlReader 객체의 상태
  - `Initial` : 노드를 아직 한 번도 읽지 않은 초기 상태
  - `Interactive` : 노드를 읽고 있는 중
  - `EndOfFile` : 마지막 노드까지 읽음
  - `Closed` : 더이상 진행할 수 없음
  - `Error` : 에러

### **IsEmptyElement : bool**
  - 빈 노드(단독 태그)인지 여부

### **HasAttributes : bool**
  - 태그가 속성을 하나라도 갖고 있는지 여부

### **EOF : bool**
  - 커서가 마지막에 도달했는지(모든 노드를 읽었는지) 여부

</details>

<br>

## **[4] 메소드**

<details>
<summary markdown="span"> 
...
</summary>

### **Dispose() : void**
  - `XmlReader` 클래스는 `IDisopsable` 인터페이스를 구현한다. 작업이 모두 끝나면 반드시 직접 해제 해줘야 한다.

### **Read() : bool**
  - 커서를 이동하여 태그 하나를 읽는다. 읽는 데 성공하면 true, 실패하면 false를 반환한다.

### **Close() : void**
  - `ReadState`를 `Closed`로 설정한다.
  - 더이상 노드를 읽는 것이 불가능해진다.

### **MoveToContent() : XmlNodeType**
  - xml 정의 태그와 루트 태그를 건너뛰고 곧바로 내용 시작 부분으로 커서를 이동시킨다.
  - 커서가 도달한 부분의 태그 타입을 반환한다.

### **IsStartElement() : bool**
  - 현재 커서의 태그가 여는 태그 또는 단독 태그인지 여부

### **IsStartElement(string name) : bool**
  - 현재 커서의 태그가 여는 태그 또는 단독 태그인지, 그리고 해당 태그의 이름이 `name`과 일치하는지 여부

### **ReadInnerXml() : string**
  - `MoveToContent()` 호출 이후 연계할 수 있다.
  - 루트 태그를 제외한 내부 영역 전체를 읽고 하나의 문자열로 반환한다.

### **ReadOuterXml() : string**
  - `MoveToContent()` 호출 이후 연계할 수 있다.
  - 루트 태그를 포함한 영역 전체를 읽고 하나의 문자열로 반환한다.

</details>

<br>


# C# XmlReaderSettings API
---

<details>
<summary markdown="span"> 
...
</summary>

### **Async : bool**
  - 비동기 메소드를 사용할 수 있는지 여부를 결정한다.

### **IgnoreWhitespace : bool**
  - 유효하지 않은 공백, 개행 문자들을 무시할지 여부를 결정한다.

### **IgnoreComments : bool**
  - 주석을 무시할지 여부를 결정한다.

### **XmlResolver : XmlResolver**
  - xml 파일에 접근할 때 경로의 규칙, 자격 증명 등을 확인한다.

</details>

<br>


# C# XmlReader 생성 예제
---

## **Create(uri)**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
// [1] (string uri)
XmlReader xr = XmlReader.Create("packets.xml");


// [2] (string uri, XmlReaderSettings)
XmlReaderSettings settings = new XmlReaderSettings();
/* Settings */

XmlReader xr = XmlReader.Create("packets.xml", settings);
```

</details>

## **Create(reader)**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
// [1] (XmlReader, XmlReaderSettings)
XmlTextReader txtReader = new XmlTextReader("packets.xml");

XmlReaderSettings settings = new XmlReaderSettings();
/* Settings */

XmlReader xr = XmlReader.Create(txtReader, settings);
```

</details>

## **Create(StringReader)**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
// [1] (StringReader)
string xmlData =
    "<item productID='124390'>" +
    "<price>5.95</price>" +
    "</item>";

XmlReader xr = XmlReader.Create(new StringReader(xmlData));


// [2] (StringReader, XmlReaderSettings)
string xmlData =
    "<item productID='124390'>" +
    "<price>5.95</price>" +
    "</item>";

XmlReaderSettings settings = new XmlReaderSettings();
/* Settings */

XmlReader xr = XmlReader.Create(new StringReader(xmlData), settings);
```

</details>

## **Create(stream)**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
// [1] (Stream stream)
FileStream fs = new FileStream(@"C:\data\books.xml", 
    FileMode.OpenOrCreate, FileAccess.Read, FileShare.Read);

XmlReader reader = XmlReader.Create(fs);


// [2] (Stream stream)
FileStream fs = new FileStream(@"C:\data\books.xml", 
    FileMode.OpenOrCreate, FileAccess.Read, FileShare.Read);

XmlReaderSettings settings = new XmlReaderSettings();
/* Settings */

XmlReader reader = XmlReader.Create(fs, settings);
```

</details>

<br>

# C# XML 예제 데이터
---

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```xml
<?xml version="1.0" encoding="utf-8" ?>

<packets>
    <packet name="Echo">
    </packet>
    
    <packet name="Number">
        <int name="number"/>
    </packet>
    
    <packet name="String">
        <string name="str"/>
    </packet>
    
    <packet name="Vector3">
        <float name="x"/>
        <float name="y"/>
        <float name="z"/>
    </packet>
    
    <packet name="Vector3List">
        <int name="count"/>
        <list name="Vector3">
            <float name="x"/>
            <float name="y"/>
            <float name="z"/>
        </list>
    </packet>
</packets>
```

</details>

<br>

# C# XmlReader 예제 - 선형적 파싱
---

## **예제 소스코드**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
private static readonly string[] indents = { null, "", "  ", "    ", "      " };

private static void Main()
{
    XmlTextReader txtReader = new XmlTextReader("packets.xml");

    XmlReaderSettings settings = new XmlReaderSettings();
    settings.IgnoreWhitespace = true;
    settings.IgnoreComments = true;
            
    XmlReader xr = XmlReader.Create(txtReader, settings);
    xr.MoveToContent();

     while (xr.Read())
    {
        if (xr.IsStartElement())
        {
            int depth = xr.Depth;
            string nodeType = xr.Name;
            string nodeName = xr["name"];

            switch (nodeType)
            {
                case "packet":
                    Console.WriteLine($"\nPacket [{nodeName}]");
                    break;

                case "list":
                    Console.WriteLine($"{indents[depth]}{nodeType,-6} {nodeName}");
                    break;

                default:
                    Console.WriteLine($"{indents[depth]}{nodeType,-6} {nodeName}");
                    break;
            }
        }
    }

    xr.Dispose();
}
```

</details>

## **실행 결과(콘솔)**

<details>
<summary markdown="span"> 
...
</summary>

```
Packet [Echo]

Packet [Number]
  int    number

Packet [String]
  string str

Packet [Vector3]
  float  x
  float  y
  float  z

Packet [Vector3List]
  int    count
  list   Vector3
    float  x
    float  y
    float  z
```

</details>

<br>

# C# XmlReader 예제 - 계층적 파싱
--- 

## **예제 소스코드**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
private static readonly string[] indents = { null, "", "  ", "    ", "      " };

private static void Main()
{
    XmlTextReader txtReader = new XmlTextReader("packets.xml");

    XmlReaderSettings settings = new XmlReaderSettings();
    settings.IgnoreWhitespace = true;
    settings.IgnoreComments = true;

    XmlReader xr = XmlReader.Create(txtReader, settings);
    xr.MoveToContent();

    while (xr.Read())
    {
        if (xr.IsStartElement("packet"))
            ParsePacket(xr);
    }

    xr.Dispose();
}

// packet 파싱
private static void ParsePacket(XmlReader xr)
{
    int depth = xr.Depth;
    string packetName = xr["name"];

    Console.WriteLine($"\nPacket [{packetName}]");

    // 패킷 내 필드들 파싱
    while (xr.Read())
    {
        if (xr.Depth == depth || xr.NodeType == XmlNodeType.EndElement)
            break;

        if (xr.Name == "list")
            ParseListField(xr);
        else
            ParseField(xr);
    }
}

// list 필드 파싱
private static void ParseListField(XmlReader xr)
{
    string packetType = xr.Name;
    string packetName = xr["name"];
    int depth = xr.Depth;

    Console.WriteLine($"{indents[depth]}{packetType,-6} {packetName}");

    while (xr.Read())
    {
        if (xr.Depth == depth)
            break;

        ParseField(xr);
    }
}
        
// 필드 하나 파싱
private static void ParseField(XmlReader xr)
{
    string packetType = xr.Name;
    string packetName = xr["name"];
    int depth = xr.Depth;

    Console.WriteLine($"{indents[depth]}{packetType,-6} {packetName}");
}
```

</details>

<br>

# C# XmlReader 예제 - 비동기
--- 

## **특징**
 - `XmlTextReader` 객체에는 비동기 구현이 되어 있지 않으므로, 다른 방식으로 생성해야 한다.
 - `settings.Async = true` 설정을 반드시 해야 한다.

<br>

## **예제 소스코드**

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
private static readonly string[] indents = { null, "", "  ", "    ", "      " };

// async 선언
private static async void Main()
{
    FileStream fs = new FileStream("packets.xml", FileMode.Open, FileAccess.Read);

    XmlReaderSettings settings = new XmlReaderSettings();
    settings.IgnoreWhitespace = true;
    settings.IgnoreComments = true;
    settings.Async = true;

    // 파일 스트림 객체를 사용하거나 경로를 직접 지정하는 방식을 통해 생성
    XmlReader xr = XmlReader.Create(fs, settings);
    //XmlReader xr = XmlReader.Create("packets.xml", settings);

    xr.MoveToContent();

    while (await xr.ReadAsync()) // 비동기 대기
    {
        if (xr.IsStartElement())
        {
            int depth = xr.Depth;
            string nodeType = xr.Name;
            string nodeName = xr["name"];

            switch (nodeType)
            {
                case "packet":
                    Console.WriteLine($"\nPacket [{nodeName}]");
                    break;

                case "list":
                    Console.WriteLine($"{indents[depth]}{nodeType,-6} {nodeName}");
                    break;

                default:
                    Console.WriteLine($"{indents[depth]}{nodeType,-6} {nodeName}");
                    break;
            }
        }
    }

    fs.Dispose();
    xr.Dispose();
}
```

</details>

<br>

# 간단한 XmlDocument 클래스 예제
---

- 위의 예제와 동일한 데이터 해석

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
XmlDocument xd = new XmlDocument();
xd.Load("packets.xml");

XmlNodeList nodeList = xd.GetElementsByTagName("packet");

// Packets
foreach (XmlNode packetNode in nodeList)
{
    string packetName = packetNode.Attributes["name"].Value;

    Console.WriteLine($"\nPacket [{packetName}]");

    // Fields
    foreach (XmlNode fieldNode in packetNode.ChildNodes)
    {
        string fieldType = fieldNode.Name;
        string fieldName = fieldNode.Attributes["name"].Value;

        Console.WriteLine($"  {fieldType} {fieldName}");

        if (fieldType == "list")
        {
            // List Fields
            foreach (XmlNode listNode in fieldNode)
            {
                string listFieldType = listNode.Name;
                string listFieldName = listNode.Attributes["name"].Value;

                Console.WriteLine($"    {listFieldType} {listFieldName}");
            }
        }
    }
}
```

</details>

<br>

# References
---
- <https://webstudynote.tistory.com/110>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.xml.xmlreader?view=net-5.0>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.xml.xmldocument?view=net-5.0>
- <https://www.csharpstudy.com/Data/Xml-rw.aspx>