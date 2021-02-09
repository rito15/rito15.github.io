---
title: OpenGL 공부 - 08 - Debugging
author: Rito15
date: 2021-02-04 15:45:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- OpenGL 내에서 디버깅하기

<br>

# 공부 내용
---
- OpenGL 내에서 에러가 발생하거나 코드를 잘못 작성한 경우, 친절한 에러 메시지보다는 그저 검은 화면을 볼 가능성이 높다.

![image](https://user-images.githubusercontent.com/42164422/106857096-e38a0180-6702-11eb-9b83-30638b84cc77.png)

- 그래서 디버깅을 하려면, OpenGL에서 제공하는 몇몇 메소드와 매크로를 활용해야 한다.

<br>
- ## glGetError
  - 에러가 발생한 경우 에러 플래그를 리턴한다.

|---|---|
|return `GLenum`|에러 플래그<br> - GL_NO_ERROR<br> - GL_INVALID_ENUM<br> - GL_INVALID_VALUE<br> - GL_INVALID_OPERATION<br> - GL_INVALID_FRAMEBUFFER_OPERATION<br> - GL_OUT_OF_MEMORY<br> - GL_STACK_UNDERFLOW<br> - GL_STACK_OVERFLOW|

<br>
## 에러 핸들링을 위한 메소드 작성

```cpp
/// <summary>
/// 해당 지점까지 발생한 에러 메시지를 모두 비워준다.
/// </summary>
static void GLClearError()
{
    while (glGetError() != GL_NO_ERROR);
}

/// <summary>
/// 해당 지점까지 발생한 에러 메시지를 출력한다.
/// </summary>
static void GLCheckError()
{
    while (GLenum error = glGetError())
    {
        string errStr = "";
        switch (error)
        {
            case GL_NO_ERROR:          errStr = "No Errors"; break;
            case GL_INVALID_ENUM:      errStr = "Invalid Enum"; break;
            case GL_INVALID_VALUE:     errStr = "Invalid Value"; break;
            case GL_INVALID_OPERATION: errStr = "Invalid Operation"; break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: errStr = "Invalid Framebuffer Operation"; break;
            case GL_OUT_OF_MEMORY:   errStr = "Out of Memory"; break;
            case GL_STACK_UNDERFLOW: errStr = "Stack Underflow"; break;
            case GL_STACK_OVERFLOW:  errStr = "Stack Overflow"; break;

            default: errStr = "Unknown"; break;
        }

        cout << "[OpenGL Error] - " << errStr << endl;
    }
}
```

- 디버깅을 할 부분의 상단에 GLClearError();, 하단에 GLCheckError()를 호출하여 에러를 확인할 수 있다.

```cpp
GLClearError();
glDrawElements(GL_TRIANGLES, 6, GL_INT, nullptr); // error
GLCheckError();
```

![image](https://user-images.githubusercontent.com/42164422/106857297-319f0500-6703-11eb-8dc0-9bee5d00d483.png)

- 대신 루프 내내 에러 메시지가 출력되며, 에러를 확인할 부분마다 위아래에 Clear, Check로 감싸줘야 된다는 단점이 있다.

- 따라서 아래처럼 수정한다.

```cpp
// x가 false인 경우 브레이크 포인트를 걸고 중단한다.
#define ASSERT(x)  if(!(x)) __debugbreak();

// 해당 부분의 에러를 검사하여, 에러 발생 시 정보를 출력한다.
#define GLCheck(x) GLClearError();\
                   x;\
                   ASSERT(GLCheckError(#x, __FILE__, __LINE__))

/// <summary>
/// 해당 지점까지 발생한 에러 메시지를 모두 비워준다.
/// </summary>
static void GLClearError()
{
    while (glGetError() != GL_NO_ERROR);
}

/// <summary>
/// 해당 지점에서 발생한 에러 메시지와 메타 정보를 출력한다.
/// </summary>
static bool GLCheckError(const char* function, const char* file, int line)
{
    while (GLenum error = glGetError())
    {
        string errStr = "";
        switch (error)
        {
            case GL_NO_ERROR:          errStr = "No Errors"; break;
            case GL_INVALID_ENUM:      errStr = "Invalid Enum"; break;
            case GL_INVALID_VALUE:     errStr = "Invalid Value"; break;
            case GL_INVALID_OPERATION: errStr = "Invalid Operation"; break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: errStr = "Invalid Framebuffer Operation"; break;
            case GL_OUT_OF_MEMORY:   errStr = "Out of Memory"; break;
            case GL_STACK_UNDERFLOW: errStr = "Stack Underflow"; break;
            case GL_STACK_OVERFLOW:  errStr = "Stack Overflow"; break;

            default: errStr = "Unknown"; break;
        }

        cout << "[OpenGL Error] - " << errStr << endl
             << "Code : " << function << endl
             << "Line : " << file << " : " << line << endl;
        return false;
    }
    return true;
}
```

- 이제 에러를 확인하고 싶은 부분에

```cpp
GLCheck(glDrawElements(GL_TRIANGLES, 6, GL_INT, nullptr));
```

- 이렇게 GLCheck( )으로 감싸기만 하면 에러가 있을 경우 자동으로 중단점을 걸고 에러 내용, 에러가 발생한 위치 정보, 소스 코드 내용까지 출력하게 된다.

![image](https://user-images.githubusercontent.com/42164422/106859058-dd495480-6705-11eb-8892-bb460c86d654.png)

<br>

- 응용하여 아래처럼 소스 코드 여러 부분을 묶어 체크할 수도 있고,

![image](https://user-images.githubusercontent.com/42164422/106860095-42517a00-6707-11eb-86ab-547f325de492.png)

- 모든 라인을 각각 체크할 수도 있다.

![image](https://user-images.githubusercontent.com/42164422/106860276-7c228080-6707-11eb-8f50-1ee7ef156abd.png)

<br>

# Current Source Codes
---

## Basic.shader

```shader
#shader vertex
#version 330 core

layout(location = 0) in vec4 position;

void main()
{
   gl_Position = position;
};

#shader fragment
#version 330 core

layout(location = 0) out vec4 color;

void main()
{
   color = vec4(0.2, 0.3, 0.8, 1.0);
};
```

## ErrorHandler.hpp

```cpp
#pragma once

// x가 false인 경우 브레이크 포인트를 걸고 중단한다.
#define ASSERT(x)  if(!(x)) __debugbreak();

// 해당 부분의 에러를 검사하여, 에러 발생 시 정보를 출력한다.
#define GLCheck(x) GLClearError();\
                   x;\
                   ASSERT(GLCheckError(#x, __FILE__, __LINE__))

/// <summary>
/// 해당 지점까지 발생한 에러 메시지를 모두 비워준다.
/// </summary>
static void GLClearError()
{
    while (glGetError() != GL_NO_ERROR);
}

/// <summary>
/// 해당 지점에서 발생한 에러 메시지와 메타 정보를 출력한다.
/// </summary>
static bool GLCheckError(const char* function, const char* file, int line)
{
    while (GLenum error = glGetError())
    {
        string errStr = "";
        switch (error)
        {
            case GL_NO_ERROR:          errStr = "No Errors"; break;
            case GL_INVALID_ENUM:      errStr = "Invalid Enum"; break;
            case GL_INVALID_VALUE:     errStr = "Invalid Value"; break;
            case GL_INVALID_OPERATION: errStr = "Invalid Operation"; break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: errStr = "Invalid Framebuffer Operation"; break;
            case GL_OUT_OF_MEMORY:   errStr = "Out of Memory"; break;
            case GL_STACK_UNDERFLOW: errStr = "Stack Underflow"; break;
            case GL_STACK_OVERFLOW:  errStr = "Stack Overflow"; break;

            default: errStr = "Unknown"; break;
        }

        cout << "[OpenGL Error] - " << errStr << endl
             << "Code : " << function << endl
             << "Line : " << file << " : " << line << endl << endl;
        return false;
    }
    return true;
}

```

## CustomFunctions.hpp

```cpp
#pragma once

struct ShaderProgramSource
{
    string VertexSource;
    string FragmentSource;
};

/// <summary>
/// 쉐이더 파일을 읽어서 버텍스, 프래그먼트 쉐이더 스트링 가져오기
/// </summary>
/// <param name="filePath">쉐이더 파일 경로</param>
/// <returns>ShaderProgramSource { Vertex, Fragment }</returns>
static ShaderProgramSource ParseShader(const string& filePath)
{
    enum class ShaderType
    {
        NONE = -1, VERTEX = 0, FRAGMENT = 1
    };

    ifstream stream(filePath);
    string line;
    stringstream ss[2];
    ShaderType type = ShaderType::NONE;

    // 스트림에서 한 줄씩 읽어오기
    while (getline(stream, line))
    {
        // #shader 라인을 통해 버텍스, 프래그먼트 쉐이더 시작점 인식
        if (line.find("#shader") != string::npos)
        {
            if (line.find("vertex") != string::npos)
            {
                type = ShaderType::VERTEX;
            }
            else if (line.find("fragment") != string::npos)
            {
                type = ShaderType::FRAGMENT;
            }
        }
        // #shader가 없는 부분에서는 스트링 스트림에 라인 추가
        else
        {
            ss[(int)type] << line << '\n';
        }
    }

    return { ss[0].str(), ss[1].str() };
}

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
```

## Application.cpp

```cpp
#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

using namespace std;

#include "ErrorHandler.hpp"
#include "CustomFunctions.hpp"


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

    /******************************************************************
     *                         VBO - Vertex Position                  *
     ******************************************************************/
    // Vertex Attribute : 위치 데이터
    float positions[] =
    {
        -0.5f, -0.5f, // 0
         0.5f, -0.5f, // 1
         0.5f,  0.5f, // 2
        -0.5f,  0.5f, // 3
    };

    // VBO(Vertex Buffer Object) ID 생성
    GLuint vbo;

    // VBO 객체 생성
    glGenBuffers(1, &vbo);

    // VBO 타입 바인딩
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    // VBO에 위치 데이터 연결
    glBufferData(GL_ARRAY_BUFFER, sizeof(positions), positions, GL_STATIC_DRAW);

    // 정점 속성 정의
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);

    // 정점 속성 활성화
    glEnableVertexAttribArray(0);

    /******************************************************************
     *                         IBO - Vertex Indices                   *
     ******************************************************************/

    // Index Data
    GLuint indices[] =
    {
        0, 1, 2,
        0, 2, 3
    };

    // Index Buffer Object 생성, 바인딩, 데이터 연결
    GLuint ibo;
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    /******************************************************************
     *                              Shader                            *
     ******************************************************************/
    // 쉐이더 파일 읽어오기
    ShaderProgramSource source = ParseShader("Resources/Shaders/Basic.shader");
    string vertexShader = source.VertexSource;
    string fragmentShader = source.FragmentSource;

    cout << "\nVERTEX\n" + vertexShader +
            "\nFRAGMENT\n" + fragmentShader << endl;

    // 쉐이더 객체 생성 및 컴파일, 프로그램 객체 생성
    GLuint shaderProgram = CreateShader(vertexShader, fragmentShader);

    // 쉐이더 프로그램 객체 사용
    glUseProgram(shaderProgram);

    /******************************************************************
     *                               Loop                             *
     ******************************************************************/
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        GLCheck(glClear(GL_COLOR_BUFFER_BIT);)

        // 폴리곤 그리기
        //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
        GLCheck(glDrawElements(GL_TRIANGLES, 6, GL_INT, nullptr);)
        
        /* Swap front and back buffers */
        GLCheck(glfwSwapBuffers(window);)

        /* Poll for and process events */
        GLCheck(glfwPollEvents();)
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
- <https://www.youtube.com/watch?v=FBbPWSOQ0-w>