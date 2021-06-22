---
title: OpenGL 공부 - 09 - uniform, VAO
author: Rito15
date: 2021-02-05 15:20:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- uniform 변수, VAO에 대한 이해 및 사용

<br>

# 1. uniform
---

## uniform이란?
 - OpenGL에서 쉐이더로 전달하는 글로벌 변수

<br>

## 쉐이더에서 uniform 변수 선언 및 사용

```glsl
#shader fragment
#version 330 core

layout(location = 0) out vec4 color;

uniform vec4 u_Color;

void main()
{
    color = u_Color;
};
```

- uniform 변수는 기본적으로 u_를 붙여 네이밍한다.

<br>

## OpenGL에서 uniform 변수 선언 및 전달

### **glGetUniformLocation**
  - 대상 프로그램(쉐이더)에 uniform 변수의 위치를 생성하고, 그 위치를 리턴한다.

|파라미터, 리턴|설명|
|---|---|
|GLuint `program`|uniform 변수가 사용될 프로그램 객체|
|const GLchar* `name`|uniform 변수의 이름|
|return `GLint`|생성된 uniform 변수의 위치값|

<br>

### **glUniform**
  - uniform 변수의 값을 초기화한다.
  - 변수의 차원에 따라 함수명 접미어로 우선 숫자가 1~4까지 붙는다.
  - 변수의ㅣ 타입에 따라 함수명 접미어로 f, i, ui 등이 붙는다.
  
|파라미터, 리턴|설명|
|---|---|
|GLint `location`|uniform 변수의 위치값|
|parameters|초기화할 값들|
|return `void`|리턴 값 없음|

```cpp
// 대상 쉐이더 프로그램 객체에 유니폼 변수 위치 생성
GLint uColorLocation = glGetUniformLocation(shaderProgram, "u_Color");

ASSERT(uColorLocation != -1);

// 유니폼 변수에 값 초기화
glUniform4f(uColorLocation, 0.2f, 0.3f, 0.8f, 1.0f);
```

<br>

## 실시간으로 변화하는 uniform 변수값 전달하기

```cpp
// 쉐이더에 유니폼 변수 생성
GLint uColorLocation = glGetUniformLocation(shaderProgram, "u_Color");
ASSERT(uColorLocation != -1);

// 유니폼 변수의 변화를 위한 변수들
float r = 0.0f;
float increment = 0.05f;
/******************************************************************
*                               Loop                             *
******************************************************************/
while (!glfwWindowShouldClose(window))
{
    glClear(GL_COLOR_BUFFER_BIT); /* Render here */

    // 유니폼 변수값 전달
    glUniform4f(uColorLocation, r, 0.3f, 0.8f, 1.0f);

    // 폴리곤 그리기
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
        
    // r값 변화
    if (r < 0.0f || r > 1.0f)
        increment *= -1.0f;
    r += increment;
        
    glfwSwapBuffers(window); /* Swap front and back buffers */
    glfwPollEvents(); /* Poll for and process events */
}
```

<br>

# 2. VAO
---

## VAO란?
 - Vertex Array Object
 - 각각의 VAO 인덱스에 VBO의 참조를 담을 수 있다.
 - 각각의 VBO에 바인딩된 버텍스 속성들은 VAO에서 참조될 수 있다.
 - 한 개의 VAO에 모든 오브젝트들의 정보를 담아 사용할 수도 있고, 각각의 VAO마다 하나의 오브젝트 정보를 담아 사용할 수도 있다.
 
<br>

## VAO 생성

```cpp
GLuint vao;
glGenVertexArrays(1, &vao);
glBindVertexArray(vao);
```

- VAO가 있으나 없으나 어차피 잘 실행이 된다.
- 차이점을 확인하기 위해 메인 코드 상단부에 이렇게 작성해본다.

```cpp
/* Initialize the library */
if (!glfwInit())
    return -1;

glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
```

- 이렇게 추가하자, VAO가 없으면 실행되지 않고 내부 에러가 발생한다.
- 그런데 어째 아주 기초적인 GLFW Hint 선언부를 이제서야 추가하는 느낌이 든다.
- 다음부터는 다른 강의를 들을 예정..

<br>

# Source Code
---

## Basic.shader

```glsl
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

uniform vec4 u_Color;

void main()
{
    color = u_Color;
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

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    /* Create a windowed mode window and its OpenGL context */
    window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    /* Make the window's context current */
    glfwMakeContextCurrent(window);

    // 프레임 진행 속도 설정
    glfwSwapInterval(1);

    // glewInit은 rendering context를 만들고 난 이후에 해야 함
    if (glewInit() != GLEW_OK)
    {
        cout << "GLEW INIT ERROR" << endl;
    }

    // 간단히 GLEW 버전 확인
    cout << glGetString(GL_VERSION) << endl;

    /******************************************************************
     *                                VAO                             *
     ******************************************************************/
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

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

    // 쉐이더에 유니폼 변수 생성
    GLint uColorLocation = glGetUniformLocation(shaderProgram, "u_Color");
    ASSERT(uColorLocation != -1);

    // 유니폼 변수의 변화를 위한 변수들
    float r = 0.0f;
    float increment = 0.05f;
    /******************************************************************
     *                               Loop                             *
     ******************************************************************/
    while (!glfwWindowShouldClose(window))
    {
        glClear(GL_COLOR_BUFFER_BIT); /* Render here */

        // 유니폼 변수값 전달
        glUniform4f(uColorLocation, r, 0.3f, 0.8f, 1.0f);

        // 폴리곤 그리기
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
        
        // r값 변화
        if (r < 0.0f || r > 1.0f)
            increment *= -1.0f;
        r += increment;
        
        glfwSwapBuffers(window); /* Swap front and back buffers */
        glfwPollEvents(); /* Poll for and process events */
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
- <https://www.youtube.com/watch?v=DE6Xlx_kbo0>
- <https://www.youtube.com/watch?v=Bcs56Mm-FJY>
- <https://heinleinsgame.tistory.com/7>
- <https://heinleinsgame.tistory.com/8>