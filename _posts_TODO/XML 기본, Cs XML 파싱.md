

# XML
---

eXTensible Markup Language의 약자로, W3C에서 개발된 마크업 언어.

XML의 대표적인 파생 언어로 HTML이 있다.

기본적인 XML 파일의 확장자는 `.xml`이다.

<br>

# XML 문법
---

## **예시**
 - 패킷 데이터 목록 정의

```xml
<?xml version="1.0" encoding="utf-8" ?>

<!-- Packet Data List -->
<packets>
    <packet name="Echo">
    </packet>
    
    <packet name="Number">
        <int field="number"/>
    </packet>
    
    <packet name="String">
        <string field="str"/>
    </packet>
    
    <packet name="Vector3">
        <float field="x"/>
        <float field="y"/>
        <float field="z"/>
    </packet>
    
    <packet name="Vector3List">
        <list name="Vector3">
            <float field="x"/>
            <float field="y"/>
            <float field="z"/>
        </list>
    </packet>
</packets>
```

<br>

## **XML 파일의 첫 줄**

```xml
`<?xml version="1.0" encoding="utf-8" ?>
```

첫 줄은 `<?xml ~ ?>` 태그를 작성하여 XML 문서라는 것을 명시해야 하며,

이를 XML 프롤로그(Prologue)라고 한다.

XML의 문서 버전과 인코딩 등 메타데이터를 작성한다.

<br>

## **태그의 종류**

### **[1]여는 태그와 닫는 태그**

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

```
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

<br>



# C# XML 파싱
--- 

`System.Xml` 네임스페이스의 `XmlReader` 클래스를 사용한다.

`XmlReader.create(string URI)` 형태로 xml 파일의 경로를 지정하여

xml 파일 내의 태그들을 순회하며 해석할 수 있는 객체를 생성한다.

해당 객체에는 태그들을 순회하는 커서가 존재하고,

`xmlReader.Read()` 또는 `.ReadAsync()` 메소드를 통해 커서를 이동한다.

<br>



# C# XmlReader 클래스 API
---

## 생성자
 - 생성자에 접근할 수 없으며, 대신 `.Create()` 메소드를 사용한다.


## 인덱서

- **[string]**
  - `xmlReader["name"]` 꼴로 현재 태그의 속성 이름을 인덱서의 매개변수로 넣고 속성 값을 리턴한다.



## 프로퍼티

- **Name**
  - 

- **Depth**
  - 

- **NodeType**
  - 



## 메소드

- **Create(string path, setting)**
  - 

- **Read()**
  - 
  
- **MoveToContent()**


<br>



# C# XML 파싱 예제
--- 

```cs

```


<br>

# C# XML 비동기 파싱 예제
--- 


```cs
XmlReaderSettings settings = new XmlReaderSettings();
settings.Async = true;


```


<br>

# References
---
- <https://webstudynote.tistory.com/110>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.xml.xmlreader?view=net-5.0>
- <https://www.csharpstudy.com/Data/Xml-rw.aspx>