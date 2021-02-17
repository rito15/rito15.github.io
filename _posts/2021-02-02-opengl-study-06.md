---
title: OpenGL 공부 - 06 - Shaders With a File
author: Rito15
date: 2021-02-02 14:21:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 쉐이더를 파일로 분리하여, 파일로부터 읽어와 사용하기

<br>

# 공부 내용
---

## 쉐이더 파일 작성하기
 - 솔루션 디렉터리 - [Resources/Shaders] 폴더 생성
 - Shaders 폴더 내에 [Basic.shader] 파일 생성
 - 속성 - 디버깅 - 작업 디렉터리에 $(ProjectDir)가 포함되어 있으므로 상대경로에서 불러오기 가능
 - 기존의 쉐이더 코드를 옮겨와 약간 수정하여 내용 작성

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

<br>

## 함수와 소스 분리
 - 솔루션 디렉터리 - [Headers] 폴더 생성
 - Headers 폴더 내에 CustomFunctions.hpp 파일 생성
 - 기존의 정적 함수들을 여기로 모두 이동

<br>

## 새로운 함수 작성
```cpp
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
```

<br>

## Application.cpp 코드 수정 : 쉐이더 작성부분

```cpp
// 쉐이더 파일 읽어오기
ShaderProgramSource source = ParseShader("Resources/Shaders/Basic.shader");
string vertexShader = source.VertexSource;
string fragmentShader = source.FragmentSource;

cout << "\nVERTEX\n" + vertexShader +
        "\nFRAGMENT\n" + fragmentShader << endl;
```

<br>

## 실행 결과

![image](https://user-images.githubusercontent.com/42164422/106558445-17c8bb00-6567-11eb-8e47-b563c96377b7.png)

<br>

# Source Code
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
- <https://www.youtube.com/watch?v=2pv0Fbo-7ms>