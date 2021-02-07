---
title: OpenGL 공부 - 11 - New Beginning 2
author: Rito15
date: 2021-02-07 16:12:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 프로그램 및 쉐이더 객체 생성
- 파일에 쉐이더 작성, 불러와 컴파일

<br>

# 공부 내용
---

## <Graphics Pipeline>

![image](https://user-images.githubusercontent.com/42164422/107139731-bfc3f700-6960-11eb-855c-7a16f38fbe50.png){:.normal}

<br>

# Current Source Code
---

## vertex_core.glsl

```glsl
#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;
layout (location = 2) in vec3 vertex_texcoord;

out vec3 vs_position;
out vec3 vs_color;
out vec2 vs_texcoord;

void main()
{
    vs_position = vertex_position;
    vs_color = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.f);

    gl_Position = vec4(vertex_position, 1.f);
}
```

## fragment_core.glsl

```glsl
#version 440

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;

out vec4 fs_color;

void main()
{
    fs_color = vec4(vs_color, 1.f);
}
```

## libs.h

```cpp
#pragma once

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include <GL/glew.h> // Before GLFW
#include <GLFW/glfw3.h>

#include <GLM/glm.hpp>
#include <GLM/vec2.hpp>
#include <GLM/vec3.hpp>
#include <GLM/vec4.hpp>
#include <GLM/mat4x4.hpp>
#include <GLM/gtc/matrix_transform.hpp>
#include <GLM/gtc/type_ptr.hpp>

#include <SOIL2/SOIL2.h>
```

## data.hpp

```cpp
#pragma once

//Vertex vertices[] =
//{
//    // Position
//    glm::vec3(0.0f,  0.5f, 0.0f),  glm::vec3(1.0f, 0.0f, 0.0f),  glm::vec2(0.0f, 1.0f),
//    glm::vec3(-0.5f, -0.5f, 0.0f),  glm::vec3(0.0f, 1.0f, 0.0f),  glm::vec2(0.0f, 0.0f),
//    glm::vec3(0.5f, -0.5f, 0.0f),  glm::vec3(0.0f, 0.0f, 1.0f),  glm::vec2(1.0f, 0.0f)
//};
//
//GLuint numOfVertices = sizeof(vertices) / sizeof(Vertex);
//
//GLuint indices[] =
//{
//    0, 1, 2
//};
//
//unsinged numOfIndices = sizeof(indices) / sizeof(GLuint);

void FramebufferResizeCallback(GLFWwindow* window, int fbW, int fbH)
{
    glViewport(0, 0, fbW, fbH);
}

// 버텍스 또는 프래그먼트 쉐이더 파일에서 읽어와 컴파일
GLuint CompileShader(GLenum shaderType, const char* fileDir)
{
    std::string fileOpenErrorMsg = "ERROR::LOAD_SHADER::COULD_NOT_OPEN_";
    std::string compileErrorMsg = "ERROR::LOAD_SHADER::COULD_NOT_COMPILE_";

    switch (shaderType)
    {
        case GL_VERTEX_SHADER:
            fileOpenErrorMsg += "VERTEX_FILE";
            compileErrorMsg += "VERTEX_SHADER";
            break;

        default:
            fileOpenErrorMsg += "FRAGMENT_FILE";
            compileErrorMsg += "FRAGMENT_SHADER";
            break;
    }

    char infoLog[512];
    GLint success;

    std::string line = "";
    std::string src = "";

    std::ifstream in_file;

    // 쉐이더 파일 읽어오기
    in_file.open(fileDir);

    if (in_file.is_open())
    {
        while (std::getline(in_file, line))
        {
            src += line + "\n";
        }
    }
    else
    {
        std::cout << fileOpenErrorMsg << std::endl;
        in_file.close();
        return NULL;
    }

    in_file.close();

    // 쉐이더 객체 생성, 컴파일
    GLuint shader = glCreateShader(shaderType);
    const GLchar* vertSrc = src.c_str();
    glShaderSource(shader, 1, &vertSrc, NULL);
    glCompileShader(shader);

    // 컴파일 에러 검사
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(shader, 512, NULL, infoLog);
        std::cout << compileErrorMsg << std::endl;
        std::cout << infoLog << std::endl;
        return NULL;
    }

    return shader;
}

bool CreateShaders(GLuint& program)
{
    char infoLog[512];
    GLint success;
    const char* ProgramLinkErrorMsg = "ERROR::LOADSHADERS::COULD_NOT_LINK_PROGRAM";

    GLuint vertexShader = CompileShader(GL_VERTEX_SHADER, "vertex_core.glsl");
    GLuint fragmentShader = CompileShader(GL_FRAGMENT_SHADER, "fragment_core.glsl");

    // 프로그램 객체 생성 및 쉐이더 부착
    program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);

    glLinkProgram(program);

    // 링크 에러 검사
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success)
    {
        glGetProgramInfoLog(program, 512, NULL, infoLog);
        std::cout << ProgramLinkErrorMsg << std::endl;
        std::cout << infoLog << std::endl;
        return NULL;
    }

    // End
    glUseProgram(0);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
}
```

## main.cpp

```cpp
#include "libs.h"
#include "data.hpp"

int main()
{
    /*****************************************************************
                                   GLFW Init
    ******************************************************************/
    if (!glfwInit())
    {
        std::cout << "GLFW Init ERROR\n";
        return -1;
    }
    
    const int WINDOW_WIDTH  = 640;
    const int WINDOW_HEIGHT = 480;
    int framebufferWidth  = 0;
    int framebufferHeight = 0;

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GL_TRUE);

    GLFWwindow* window 
        = glfwCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "OpenGL", NULL, NULL);

    if (!window)
    {
        glfwTerminate();
        return -1;
    }

    glfwSetFramebufferSizeCallback(window, FramebufferResizeCallback);
    //glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
    //glViewport(0, 0, framebufferWidth, framebufferHeight);

    // 현재 컨텍스트에서 윈도우 생성
    glfwMakeContextCurrent(window);

    // 프레임 진행 속도 설정
    glfwSwapInterval(1);

    /*****************************************************************
                                   GLEW Init
    ******************************************************************/
    // glewInit은 rendering context를 만들고 난 이후에 해야 함
    if (glewInit() != GLEW_OK)
    {
        std::cout << "GLEW INIT ERROR\n";
        glfwTerminate();
    }

    // 간단히 GLEW 버전 확인
    std::cout << glGetString(GL_VERSION) << std::endl;

    /*****************************************************************
                                   Objects
    ******************************************************************/
    // Shader Init
    GLuint coreProgram;
    if (!CreateShaders(coreProgram))
    {
        glfwTerminate();
    }

    // Model

    // VAO, VBO, EBO

    // VAO Gen & Bind

    // VBO Gen & Bind & Send Data

    // EBO Gen & Bind & Send Data

    // Set VertexAttribPointers & Enable

    // Bind VAO 0

    /*****************************************************************
                                   Main Loop
    ******************************************************************/
    while (!glfwWindowShouldClose(window))
    {
        // Update Input
        glfwPollEvents();

        // Update

        // Clear
        glClearColor(0.f, 0.f, 0.f, 1.f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

        // Draw

        // End Draw
        glfwSwapBuffers(window);
        glFlush();
    }

    // End of Program
    glfwDestroyWindow(window);
    glfwTerminate();

    glDeleteProgram(coreProgram);

    return 0;
}
```

# References
---
- <https://www.youtube.com/watch?v=iU9bgHCaAPQ>
- <https://www.youtube.com/watch?v=oNNFazrxy6Q>