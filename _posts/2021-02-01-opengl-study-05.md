---
title: OpenGL 공부 - 05
author: Rito15
date: 2021-02-01 17:42:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- OpenGL의 쉐이더에 대한 이해
- 간단한 vertex, fragment 쉐이더 작성, 컴파일 및 실행

<br>

# OpenGL의 쉐이더
---

- ## Vertex&Fragment Shader
  - OpenGL에서 거의 90%의 비중을 차지

- ## Vertex Shader
  - 하나의 정점 당 한 번씩 실행된다.
  - layout을 통해 정점 속성의 위치를 입력받는다.
  - 입력 : 정점 데이터
  - 출력 : 클립 스페이스의 정점 데이터

- ## Fragment Shader
  - 하나의 픽셀 당 한 번씩 실행된다.
  - 입력 : 프래그먼트 데이터(래스터라이저가 만들어줌)
  - 출력 : 모든 픽셀의 최종 색상

<br>

# OpenGL 메소드 명세
---

- ## glCreateProgram
  - 빈 프로그램 객체를 생성하고 프로그램 ID 값 리턴

|---|---|
|`return` GLuint|프로그램의 ID(1, 2, ...)<br> - 에러 발생 시 0|

<br>
- ## glCreateShader
  - 지정한 타입의 빈 쉐이더 객체를 생성하고 쉐이더 ID 값 리턴

|---|---|
|Glenum `shaderType`|생성할 쉐이더의 타입 지정<br> - GL_VERTEX_SHADER<br> - GL_FRAGMENT_SHADER<br> - GL_COMPUTE_SHADER<br> - GL_GEOMETRY_SHADER<br> - GL_TESS_CONTROL_SHADER<br> - GL_TESS_EVALUATION_SHADER|
|`return` GLuint|생성한 쉐이더의 ID(1, 2, ...)<br> - 에러 발생 시 0|

<br>
- ## glShaderSource
  - 쉐이더 소스 코드를 입력받아 쉐이더 객체로 변환
  - 생성한 쉐이더 객체를 입력한 쉐이더 객체 ID에 바인딩

|---|---|
|GLuint `shader`|생성한 쉐이더 객체를 바인딩할 ID|
|GLsizei `count`|string, length에 전달하는 요소의 개수|
|const GLchar** `string`|쉐이더 소스 코드 스트링의 포인터|
|const GLint* `length`|스트링 길이 배열의 포인터|
|`return` void|리턴 값 없음|

<br>

- ## glCompileShader
  - 지정한 ID에 위치한 쉐이더 객체를 컴파일

|---|---|
|Gluint `shader`|컴파일할 쉐이더 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glAttachShader
  - 지정한 프로그램 객체에 쉐이더 객체 부착

|---|---|
|GLuint `program`|프로그램 객체 ID|
|GLuint `shader`|쉐이더 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glLinkProgram
  - 지정한 프로그램 객체가 executable(실행 가능한 상태)이 되도록 링크

|---|---|
|GLuint `program`|프로그램 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glVaidateProgram
  - 지정한 프로그램 객체의 유효성 검증
  - 해당 프로그램의 executable이 현재 OpenGL에서 실행될 수 있는지 검증

|---|---|
|GLuint `program`|프로그램 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glDeleteShader
  - 지정한 쉐이더 객체를 메모리에서 해제

|---|---|
|GLuint `shader`|쉐이더 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glGetShaderiv
  - 지정한 쉐이더 객체의 정수형 정보(파라미터) 가져오기

|---|---|
|GLuint `shader`|쉐이더 객체 ID|
|GLenum `pname`|쉐이더 객체에서 가져올 파라미터<br> - GL_SHADER_TYPE<br> - GL_DELETE_STATUS<br> - GL_COMPILE_STATUS<br> - GL_INFO_LOG_LENGTH<br> - GL_SHADER_SOURCE_LENGTH|
|GLint* `params`|파라미터를 받아올 정수형 변수 포인터|
|`return` void|리턴 값 없음|

<br>

- ## glGetShaderInfoLog
  - 지정한 쉐이더 객체의 로그 가져오기

|---|---|
|GLuint `shader`|쉐이더 객체 ID|
|GLsizei `maxLength`|로그를 저장할 캐릭터 버퍼의 크기|
|GLsizei* `length`|infoLog에 전달받은 길이를 저장할 정수형 변수 포인터|
|GLchar* `infoLog`|로그를 받아올 문자 배열 포인터|
|`return` void|리턴 값 없음|

<br>

- ## glDeleteShader
  - 지정한 쉐이더 객체의 메모리 해제
  - 해당 쉐이더 객체의 ID도 제거됨
  - 메모리에 등록된 쉐이더 객체 ID가 1, 2, 3이 있을 때 1을 제거할 경우,<br>
    다음에 생성한 쉐이더 객체 ID는 1로 할당

|---|---|
|GLuint `shader`|쉐이더 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glUseProgram
  - 현재 렌더링 환경에서 프로그램 객체 설치(실행)

|---|---|
|GLuint `program`|프로그램 객체 ID|
|`return` void|리턴 값 없음|

<br>

- ## glDeleteProgram
  - 지정한 프로그램 객체의 메모리 해제

|---|---|
|GLuint `program`|프로그램 객체 ID|
|`return` void|리턴 값 없음|

<br>

# Vertex, Fragment Shader
---
## 1. Vertex Shader

```glsl
// 사용할 glsl 버전 설정(330 -> 3.3버전)
#version 330 core

// 정점 좌표 애트리뷰트의 인덱스를 location에 전달
// 지금 정점 좌표는 vec2이지만, 어쨌든 좌표는 항상 vec4로 사용
layout(location = 0) in vec4 position;

void main()
{
    gl_Position = position;
}
```

## 2. Fragment Shader

```glsl
#version 330 core

layout(location = 0) out vec4 color;

void main()
{
    color = vec4(0.2, 0.3, 0.8, 1.0);
}

```

<br>
# 실행 결과
---
- ## 1. 쉐이더 컴파일 에러 발생
  - 원인 : color에 알파 값을 지정하지 않음

![image](https://user-images.githubusercontent.com/42164422/106450912-2cef0c80-64c9-11eb-8ce7-1235841cc3b8.png)

- ## 2. 쉐이더 컴파일 성공

![image](https://user-images.githubusercontent.com/42164422/106450944-38423800-64c9-11eb-876c-4bbf0788cb49.png)

<br>

# Current Source Code
---
```cpp
#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <iostream>
using namespace std;

/// <summary>
/// 쉐이더 소스 코드를 입력받아 쉐이더 객체 생성하고 컴파일
/// </summary>
/// <param name="source">쉐이더 소스 코드</param>
/// <param name="type">GL_VERTEX_SHADER 또는 GL_FRAGMENT_SHADER</param>
/// <returns>컴파일된 쉐이더 객체의 ID 또는 0(에러)</returns>
static GLuint CompileShader(GLenum type, const string& source)
{
    // 빈 쉐이더 객체 생성
    GLuint shaderID = glCreateShader(type);
    const char* src = source.c_str();

    // 쉐이더 코드를 쉐이더 객체로 변환하여 위의 쉐이더 객체 id에 바인딩
    glShaderSource(shaderID, 1, &src, nullptr);

    // 쉐이더 컴파일
    glCompileShader(shaderID);

    // 쉐이더 컴파일 결과 검증
    GLint result;
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &result);

    // 컴파일이 실패한 경우
    if (result == GL_FALSE)
    {
        int length;

        // 로그의 길이값을 length에 받아오기
        glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &length);

        // 스택에 배열 동적 할당
        char* message = (char*)_malloca(length * sizeof(char));

        // 로그 메시지 받아오기
        glGetShaderInfoLog(shaderID, length, &length, message);

        // 에러 메시지 출력
        cout << "Failed to Compile "
            << ((type == GL_VERTEX_SHADER) ? "Vertex" : "Fragment")
            << " Shader"
            << endl;

        cout << "\nError Message :" << endl;
        cout << message << endl;

        // 쉐이더 메모리 해제
        glDeleteShader(shaderID);

        _freea(message);
        return 0;
    }

    return shaderID;
}

/// <summary>
/// 프로그램, 쉐이더 객체 생성
/// </summary>
/// <param name="vertexShader">버텍스 쉐이더 소스 코드</param>
/// <param name="fragmentShader">프래그먼트 쉐이더 소스 코드</param>
/// <returns>생성된 프로그램 객체의 ID</returns>
static GLuint CreateShader(const string& vertexShader, const string& fragmentShader)
{
    // 빈 프로그램 객체 생성
    GLuint programID = glCreateProgram();

    // 쉐이더 컴파일
    GLuint vs = CompileShader(GL_VERTEX_SHADER, vertexShader);
    GLuint fs = CompileShader(GL_FRAGMENT_SHADER, fragmentShader);

    // 프로그램에 쉐이더 장착, 프로그램 링킹, 검증
    glAttachShader(programID, vs);
    glAttachShader(programID, fs);
    glLinkProgram(programID);
    glValidateProgram(programID);

    // 쉐이더 메모리 해제
    glDeleteShader(vs);
    glDeleteShader(fs);

    return programID;
}

int main(void)
{
    GLFWwindow* window;

    /* Initialize the library */
    if (!glfwInit())
        return -1;

    /* Create a windowed mode window and its OpenGL context */
    window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    glfwMakeContextCurrent(window);

    // glewInit은 rendering context를 만들고 난 이후에 해야 함
    if (glewInit() != GLEW_OK)
    {
        cout << "GLEW INIT ERROR" << endl;
    }

    // 간단히 GLEW 버전 확인
    cout << glGetString(GL_VERSION) << endl;

    // Vertex Attribute : 위치 데이터
    float positions[6] = {
        -0.5f, -0.5f,
         0.0f,  0.5f,
         0.5f, -0.5f,
    };

    // VBO(Vertex Buffer Object) ID 생성
    GLuint buffer;

    // VBO 객체 생성
    glGenBuffers(1, &buffer);

    // VBO 타입 바인딩
    glBindBuffer(GL_ARRAY_BUFFER, buffer);

    // VBO에 위치 데이터 연결
    glBufferData(GL_ARRAY_BUFFER, 6 * sizeof(float), positions, GL_STATIC_DRAW);

    // 정점 속성 정의
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);

    // 정점 속성 활성화
    glEnableVertexAttribArray(0);

    // 쉐이더 작성
    string vertexShader =
        "#version 330 core\n"
        "\n"
        "layout(location = 0) in vec4 position;\n"
        "\n"
        "void main()\n"
        "{\n"
        "   gl_Position = position;\n"
        "}\n";

    string fragmentShader =
        "#version 330 core\n"
        "\n"
        "layout(location = 0) out vec4 color;\n"
        "\n"
        "void main()\n"
        "{\n"
        "   color = vec4(0.2, 0.3, 0.8, 1.0);\n"
        "}\n";

    // 쉐이더 객체 생성 및 컴파일, 프로그램 객체 생성
    GLuint shaderProgram = CreateShader(vertexShader, fragmentShader);

    // 쉐이더 프로그램 객체 사용
    glUseProgram(shaderProgram);

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);

        glDrawArrays(GL_TRIANGLES, 0, 3);

        /* Swap front and back buffers */
        glfwSwapBuffers(window);

        /* Poll for and process events */
        glfwPollEvents();
    }

    // 프로그램 객체 메모리 해제
    glDeleteProgram(shaderProgram);
    
    glfwTerminate();
    return 0;
}
```

<br>

# References
---
- <https://www.youtube.com/watch?v=5W7JLgFCkwI>
- <https://www.youtube.com/watch?v=71BLZwRGUJE>
- <https://heinleinsgame.tistory.com/7>