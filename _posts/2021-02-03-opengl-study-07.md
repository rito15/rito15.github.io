---
title: OpenGL 공부 - 07 - Index Buffer
author: Rito15
date: 2021-02-03 16:32:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 인덱스 버퍼의 사용과 이해

<br>

# 공부 내용
---

## 삼각형 그리기
 - 삼각형을 하나 그리려면, 버텍스 3개가 필요하다.

```cpp
float positions[6] =
{
    -0.5f, -0.5f,
     0.0f,  0.5f,
     0.5f, -0.5f,
};
```

- GPU는 전달받은 버텍스들을 순서대로 확인하여 3개씩 짝지어서 하나의 폴리곤을 그려준다.
- 이 때, 3개의 버텍스가 순서대로 시계 반대 방향으로 위치해야 폴리곤의 전면이 그려진다.

<br>
## 사각형 그리기
 - 사각형을 하나 그리려면 삼각형이 2개 필요하므로, 결국 버텍스 6개가 필요하다.

![](https://user-images.githubusercontent.com/42164422/106721396-f5f33500-6647-11eb-8897-9b388e783887.png)

- 그런데 두 삼각형이 두 개의 버텍스를 공유하므로, 여섯 개의 버텍스를 전달하는건 버텍스를 두 개만큼 손해보는 것과 같다.

- 따라서 버텍스는 네 개만 전달하고, 이를 인덱스 버퍼를 이용해 중복되는 버텍스를 재사용하게 된다.

![image](https://user-images.githubusercontent.com/42164422/106721942-b37e2800-6648-11eb-96fe-bb9ed9f11685.png)

<br>
## 인덱스 버퍼 사용

- Index 데이터 정의

```cpp
GLuint indices[] =
{
    0, 1, 2,
    0, 2, 3
};
```

- IBO(Index Buffer Object) 생성, 바인딩, 데이터 연결

```cpp
GLuint ibo;
glGenBuffers(1, &ibo);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
```

- Window Loop 내에서 그려주기

```
//glDrawArrays(GL_TRIANGLES, 0, 6); // 원래 코드
glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
```

<br>

- ## glDrawElements
  - 배열 데이터로부터 프리미티브를 렌더링한다.

|---|---|
|GLenum `mode`|어떤 프리미티브를 렌더링할지 결정|
|GLsizei `count`|렌더링할 버텍스의 개수 지정|
|Glenum `type` |indices 배열 엘리먼트의 타입 지정<br> - GL_UNSIGNED_BYTE<br> - GL_UNSIGNED_SHORT<br> - GL_UNSIGNED_INT|
|const GLvoid* `indices`|GL_ELEMENT_ARRAY_BUFFER로 바인딩되어<br>현재 버퍼 데이터를 저장하는 배열의 첫 번째 인덱스|
|return `void`|리턴 값 없음|


<br>

# 실행 결과
---

![image](https://user-images.githubusercontent.com/42164422/106723312-51262700-664a-11eb-973f-6b59e94c2a2f.png)

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
        glClear(GL_COLOR_BUFFER_BIT);

        // 폴리곤 그리기
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);

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
- <https://www.youtube.com/watch?v=MXNMC1YAxVQ>