---
title: C# 파일 입출력
author: Rito15
date: 2021-01-28 21:10:00 +09:00
categories: [Csharp, Memo]
tags: [csharp, file, io]
math: true
mermaid: true
---

# Namespace
```cs
using System.IO;
```

<br>

# Path
---
```cs
// \ 대신 /를 써도 \로 자동 변환
string   filePath = @"C:\folder\fileName.txt"; 
FileInfo fi = new FileInfo(filePath);

fi.FullName;      // C:\folder\fileName.txt
fi.Directory;     // DirectoriInfo("C:\folder") 객체 반환
fi.DirectoryName; // C:\folder
fi.Name;          // fileName.txt
fi.Extension;     // .txt

Path.GetDirectoryName(filePath);            // C:\folder
Path.GetFileName(filePath);                 // fileName.txt
Path.GetFileNameWithoutExtension(filePath); // fileName
Path.GetExtension(filePath);                // .txt

Path.Combine(@"C:\folder", "fileName.txt"); // C:\folder\fileName.txt
```

<br>

# FileMode(Enum)
---
### 쓰기 : FileAccess.Write 권한 필요
  - `Create`    : 없으면 생성, 있으면 덮어쓰기
  - `CreateNew` : 없으면 생성, 있으면 IOException
  - `Append`    : 없으면 생성, 있으면 이어쓰기
  - `Truncate`  : 없으면 생성, 있으면 파일 내용 초기화

### 읽기 : FileAccess.Read 권한 필요
  - `Open` : 있으면 열기, 없으면 FileNotFoundException

### 읽기/쓰기 : FileAccess.ReadWrite 권한 필요
  - `OpenOrCreate` : 있으면 열기, 없으면 생성해서 열기

<br>

# FileAccess(Enum)
---
 - `Write` : 쓰기 권한만 부여
 - `Read`  : 읽기 권한만 부여
 - `ReadWrite` / 읽기/쓰기 권한 부여

<br>

# FileStream
---
```cs
string filePath = @"C:\folder\fileName.txt"; // 파일 전체 경로

// 쓰기 전용 스트림
FileStream writeStream;
writeStream = new FileStream(filePath, FileMode.Create);
writeStream = new FileStream(filePath, FileMode.Create, FileAccess.Write);

// 읽기 전용 스트림
FileStream readStream;
readStream = new FileStream(filePath, FileMode.Open);
readStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);

// 읽기/쓰기 스트림
FileStream wrfs;
wrfs = new FileStream(filePath, FileMode.OpenOrCreate);
wrfs = new FileStream(filePath, FileMode.OpenOrCreate, FileAccess.ReadWrite);
```

<br>

# StreamWriter
---
- 스레드 안전하지 않음
- 인코딩 지정하지 않을 경우 기본 인코딩 : UTF-8

```cs
// 파라미터 옵션들
System.Text.Encoding encoding = System.Text.Encoding.UTF8; // 인코딩
bool append    = true;  // 이어쓰기(true), 덮어쓰기(false)
bool leaveOpen = false; // 스트림 연채로 유지
int bufferSize = 100;   // 스트림 버퍼 크기

StreamWriter sw;

// 1. 스트림으로 생성
// * 해당 파일이 없을 경우 FileStream으로 지정한 옵션에 따라 동작
sw = new StreamWriter(writeStream);
sw = new StreamWriter(writeStream, encoding);
sw = new StreamWriter(writeStream, encoding, bufferSize);
sw = new StreamWriter(writeStream, encoding, bufferSize, leaveOpen);

// 2. 파일 경로로 생성
// * 해당 파일이 없으면 파일을 새로 생성
sw = new StreamWriter(filePath);
sw = new StreamWriter(filePath, append);
sw = new StreamWriter(filePath, append, encoding);
sw = new StreamWriter(filePath, append, encoding, bufferSize);
```

<br>

# StreamReader
---
- 스레드 안전하지 않음
- 인코딩 지정하지 않을 경우 기본 인코딩 : UTF-8

```cs
// 파라미터 옵션들
System.Text.Encoding encoding = System.Text.Encoding.UTF8; // 인코딩
int  bufferSize     = 100;   // 스트림 버퍼 크기
bool leaveOpen      = false; // 스트림 연채로 유지
bool detectEncoding = true;  // 파일 시작부분에서 인코딩 찾기

StreamReader sr;

// 1. 스트림으로 생성
// * 해당 파일이 없을 경우 FileStream으로 지정한 옵션에 따라 동작
sr = new StreamReader(readStream);
sr = new StreamReader(readStream, detectEncoding);
sr = new StreamReader(readStream, encoding);
sr = new StreamReader(readStream, encoding, detectEncoding);
sr = new StreamReader(readStream, encoding, detectEncoding, bufferSize);
sr = new StreamReader(readStream, encoding, detectEncoding, bufferSize, leaveOpen);

// 2. 파일 경로로 생성
sr = new StreamReader(filePath);
sr = new StreamReader(filePath, detectEncoding);
sr = new StreamReader(filePath, encoding);
sr = new StreamReader(filePath, encoding, detectEncoding);
sr = new StreamReader(filePath, encoding, detectEncoding, bufferSize);
```

<br>

# 파일에 쓰기
---
```cs
string filePath = @"C:\folder\fileName.txt"; // 파일 전체 경로

// 파일에 쓸 내용들(타입별)
string   strContents = "aa";
string[] strArrContents = {"abcdefg", "12345"};
byte[]   byteArrContents; // 어디선가 직렬화해서 가져오기

FileInfo      fi = new FileInfo(filePath);
DirectoryInfo di = fi.Directory;


// 1. 폴더 존재 확인, 미존재 시 생성
if (!di.Exists)
    di.Create();


// 2-1. 하나의 스트링으로 쓰기
File.WriteAllText(filePath, strContents);

// 2-2. 스트링 배열로 쓰기
File.WriteAllLines(filePath, strArrContents);

// 2-3. 바이트 배열로 쓰기
File.WriteAllBytes(filePath, byteArrContents);

// 2-4. StreamWriter 이용하여 한 줄씩 쓰기
using (StreamWriter sw = new StreamWriter(filePath))
{
    foreach (string line in strArrContents)
        sw.WriteLine(line);
}
```

<br>

# 파일에서 읽기
---
```cs
string filePath = @"C:\folder\fileName.txt"; // 파일 전체 경로

// 1. 전체를 하나의 스트링으로 읽어오기
string text = File.ReadAllText(filePath);

// 2. 한 줄 당 하나의 스트링으로, 전체를 스트링 배열로 읽어오기
string[] lines = File.ReadAllLines(filePath);

// 3. StreamReader 이용하여 한 줄씩 읽기
try
{
    using (StreamReader sr = new StreamReader(filePath))
    {
        string line;

        while ((line = sr.ReadLine()) != null)
        {
            // 한 줄씩 읽고 처리
        }
    }
}
catch (Exception e)
{
    // 에러 처리
}

```

<br>

# References
---
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.path>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.file>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.fileinfo>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.filemode>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.fileaccess>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.filestream>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.streamwriter>
- <https://docs.microsoft.com/ko-kr/dotnet/api/system.io.streamreader>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/io/how-to-write-text-to-a-file>
- <https://docs.microsoft.com/ko-kr/dotnet/csharp/programming-guide/file-system/how-to-read-from-a-text-file>