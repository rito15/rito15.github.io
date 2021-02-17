---
title: OpenGL 공부 - 14 - Model Matrix
author: Rito15
date: 2021-02-10 15:20:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- Model Matrix에 대한 이해
- 이동, 회전, 크기 변경

<br>

# 공부 내용
---

## 공통

glm의 모델 매트릭스를 선언하는 것으로 시작한다.

```cpp
glm::mat modelMatrix(1.0f);
```

openGL의 Transformation은 기본적으로 4x4 행렬과 vec3로 이루어진다.

4x4 행렬과 곱해지려면 벡터 또한 vec4여야 하므로, vec3를 전달하면 내부적으로 vec4(vec3, 1.)을 만들어 연산한다.

변환행렬은 서로 곱하여 하나의 변환행렬로 사용할 수 있다.

그런데 만약 이동행렬 뒤에 크기행렬을 곱하면 이동값 또한 크기가 변하기 때문에

이동, 회전, 크기 행렬을 곱하여 사용할 때는 크기, 회전, 이동 순서로 행렬을 곱하여 사용한다.

<br>

## 크기(Scale)

![image](https://user-images.githubusercontent.com/42164422/107480242-a076d500-6bbf-11eb-9d92-569d640de33e.png){:.normal}

스케일 행렬은 위와 같은 형태를 갖고 있다.

openGL에서는

```cpp
modelMatrix = glm::scale(modelMatrix, glm::vec3(1.f, 2.f, 3.f));
```

처럼 사용한다.

<br>

## 회전(Rotate)

![image](https://user-images.githubusercontent.com/42164422/107481116-06b02780-6bc1-11eb-916e-4304572dd25e.png){:.normal}

회전은 삼각함수를 이용하며, 다른 변환행렬들보다 훨씬 복잡한 형태를 지닌다.

```cpp
modelMatrix = glm::rotate(modelMatrix, glm::radians(45.f), glm::vec3(1.f, 0.f, 0.f));
```

glm::rotate 함수는 두 번째 파라미터로 라디안 값을 사용하기 때문에 Degree 값으로 회전시키려면 glm::radians()를 통해 전달한다.

세 번째 파라미터에는 회전축을 vector3로 전달한다.

<br>

## 이동(Translate)

![image](https://user-images.githubusercontent.com/42164422/107482465-116bbc00-6bc3-11eb-926c-ffe1accd675a.png){:.normal}

```cpp
modelMatrix = glm::translate(modelMatrix, glm::vec3(0.f));
```

<br>

## 버텍스 쉐이더에서 행렬 사용

```glsl
//vertex_core.glsl

#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;
layout (location = 2) in vec3 vertex_texcoord;

out vec3 vs_position;
out vec3 vs_color;
out vec2 vs_texcoord;

uniform mat4 modelMatrix;

void main()
{
    vec4 pos4 = modelMatrix * vec4(vertex_position, 1.);

    vs_position = pos4.xyz;
    vs_color    = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.);

    gl_Position = pos4;
}
```

먼저 버텍스 쉐이더를 위처럼 수정한다.

유니폼 행렬 변수를 선언하여 쉐이더 프로그램으로부터 행렬을 받을 수 있게 하였고,

행렬곱 연산을 통해 버텍스 위치를 변경시킨다.

<br>

```cpp
// Main Loop in main.cpp

glUniformMatrix4fv
(
    glGetUniformLocation(shaderProgram, "modelMatrix"), 
    1, GL_FALSE, glm::value_ptr(modelMatrix)
);
```

메인 루프에서는 위와 같이 유니폼 함수를 통해 전달한다.

glUniformMatrix4fv 함수는 파라미터로
 - 유니폼 변수의 위치
 - 전달할 유니폼 변수 개수
 - 전치(Transpose) 여부
 - 전달할 행렬 변수의 포인터

를 받는다.

<br>

## 실행 결과

![image](https://user-images.githubusercontent.com/42164422/107484761-3c0b4400-6bc6-11eb-8e75-3851c69f3507.png){:.normal}

변환 정보 :

```cpp
modelMatrix = glm::scale(modelMatrix, glm::vec3(1.5f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(45.f), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::translate(modelMatrix, glm::vec3(0.f)); // Do nothing
```

<br>

루프 내내 지속적인 변화를 주려면,

루프 내에서 모델 행렬에 행렬 연산을 해주면 된다.

### 예시 : 회전

```cpp
modelMatrix = glm::rotate(modelMatrix, glm::radians(5.f), glm::vec3(0.f, 0.f, 1.f));
```

![2021_0210_transformation_1](https://user-images.githubusercontent.com/42164422/107488474-bfc72f80-6bca-11eb-8378-33ddaab65904.gif){:.normal}

<br>

### 회전 + 스케일

```cpp
float scaleChange = glm::sin(glfwGetTime() * 10.f) * 0.05f + 1.f;
modelMatrix = glm::rotate(modelMatrix, glm::radians(5.f), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::scale (modelMatrix, glm::vec3(scaleChange));
```

![2021_0210_transformation_3](https://user-images.githubusercontent.com/42164422/107488505-c9e92e00-6bca-11eb-8c85-dda8b2509fe7.gif){:.normal}

<br>

# Source Code
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

uniform mat4 modelMatrix;

void main()
{
    vec4 pos4 = modelMatrix * vec4(vertex_position, 1.);

    vs_position = pos4.xyz;
    vs_color    = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.);

    gl_Position = pos4;
}
```

## fragment_core.glsl

```glsl
#version 440

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;

out vec4 fs_color;

uniform sampler2D catTex;
uniform sampler2D wallTex;

void main()
{
    vec4 vertColor = vec4(vs_color, 1.);
    vec4 catColor = texture(catTex, vs_texcoord);
    vec4 wallColor = texture(wallTex, vs_texcoord);
    vec4 catMask = step(vec4(0.01), catColor);

    // Final Color
    fs_color = mix(wallColor, catColor * vertColor, catMask);
}
```

## libs.h

```cpp
#pragma once

#include <iostream>
#include <fstream>
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

struct Vertex
{
    glm::vec3 position;
    glm::vec3 color;
    glm::vec2 texcoord;
};
```

## variables.hpp

```cpp
#pragma once

Vertex vertices[] =
{
    // Position                     // Color                      // TexCoord
    glm::vec3(-0.5f,  0.5f, 0.0f),  glm::vec3(1.0f, 0.0f, 0.0f),  glm::vec2(0.0f, 1.0f), // LT
    glm::vec3(-0.5f, -0.5f, 0.0f),  glm::vec3(0.0f, 1.0f, 0.0f),  glm::vec2(0.0f, 0.0f), // LB
    glm::vec3( 0.5f, -0.5f, 0.0f),  glm::vec3(0.0f, 0.0f, 1.0f),  glm::vec2(1.0f, 0.0f), // RB
    glm::vec3( 0.5f,  0.5f, 0.0f),  glm::vec3(1.0f, 1.0f, 0.0f),  glm::vec2(1.0f, 1.0f)  // RT
};

// NOTE : Counter Clockwise
GLuint indices[] =
{
    0, 1, 2,
    0, 2, 3
};

unsigned int numOfVertices = sizeof(vertices) / sizeof(Vertex);
unsigned int numOfIndices  = sizeof(indices) / sizeof(GLuint);

```

## functions.hpp

```cpp
#pragma once

// 키보드 입력받아 처리
void UpdateInputs(GLFWwindow* window)
{
    // ESC 누르면 윈도우 종료
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
    {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

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

// 버텍스, 프래그먼트 쉐이더, 프로그램 생성
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

// 이미지 파일로부터 텍스쳐 로드
GLuint LoadTextureImage(const char* imageDir)
{
    // 1. Load Image
    int imageWidth, imageHeight;
    unsigned char* image = SOIL_load_image(imageDir,
        &imageWidth, &imageHeight, NULL, SOIL_LOAD_RGBA);

    // 2. Texture Object Gen & Bind
    GLuint textureID; // Texture ID
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);

    // 3. Setup Options
    // UV 벗어날 경우 텍스쳐 반복
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // 텍스쳐 축소/확대 필터 설정
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    // 4. Generate Texture2D
    if (image)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
            GL_RGBA, GL_UNSIGNED_BYTE, image);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        std::cout << "ERROR::TEXTURE_LOAD_FAILED - " << imageDir << std::endl;
    }

    SOIL_free_image_data(image); // Release image

    return textureID;
}
```

## main.cpp

```cpp
#include "libs.h"
#include "variables.hpp"
#include "functions.hpp"

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
                                   Options
    ******************************************************************/
    glEnable(GL_DEPTH_TEST);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW); // 시계 반대 방향으로 구성된 폴리곤을 전면으로 설정

    // 픽셀 블렌딩 연산 지정
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // GL_LINE : 폴리곤을 선으로 그리기 (Wireframe Mode)
    // GL_FILL : 폴리곤을 색상으로 채우기
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    /*****************************************************************
                                   Objects
    ******************************************************************/
    // Shader Init
    GLuint shaderProgram;
    if (!CreateShaders(shaderProgram))
    {
        glfwTerminate();
    }

    // Model


    // VAO : Vertex Array Object
    // VAO Gen & Bind
    GLuint vao;
    glCreateVertexArrays(1, &vao);
    glBindVertexArray(vao);

    // VBO : Vertex Buffer Object
    // VBO Gen & Bind & Send Data
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // EBO : Element Buffer Object
    // EBO Gen & Bind & Send Data
    GLuint ebo;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);


    // Set VertexAttribPointers & Enable
    // 1. Position
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, position));
    glEnableVertexAttribArray(0);

    // 2. Color
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, color));
    glEnableVertexAttribArray(1);

    // 3. TexCoord
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, texcoord));
    glEnableVertexAttribArray(2);

    /*****************************************************************
                                   Textures
    ******************************************************************/
    GLuint texture0 = LoadTextureImage("Images/MoonCat.png");
    GLuint texture1 = LoadTextureImage("Images/Wall.png");

    /*****************************************************************
                                   Transformation
    ******************************************************************/
    glm::mat4 modelMatrix(1.0f);

    modelMatrix = glm::scale(modelMatrix, glm::vec3(1.5f));
    modelMatrix = glm::rotate(modelMatrix, glm::radians(45.f), glm::vec3(0.f, 0.f, 1.f));
    modelMatrix = glm::translate(modelMatrix, glm::vec3(0.f));

    /*****************************************************************
                                   Main Loop
    ******************************************************************/
    while (!glfwWindowShouldClose(window))
    {
        // =========================== Init ============================ //
        // Update Input
        glfwPollEvents();
        UpdateInputs(window);

        // Clear
        glClearColor(0.f, 0.f, 0.f, 1.f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

        // ========================= Bindings ========================== //
        // Use a shader program
        glUseProgram(shaderProgram);

        // Bind VAO
        glBindVertexArray(vao);

        // Activate, Bind Textures
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture0);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture1);

        // ========================= Uniforms ========================== //
        glUniform1i(glGetUniformLocation(shaderProgram, "catTex"), 0);
        glUniform1i(glGetUniformLocation(shaderProgram, "wallTex"), 1);
        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "modelMatrix"), 
            1, GL_FALSE, glm::value_ptr(modelMatrix)
        );

        float scaleChange = glm::sin(glfwGetTime() * 10.f) * 0.05f + 1.f;
        modelMatrix = glm::rotate(modelMatrix, glm::radians(5.f), glm::vec3(0.f, 0.f, 1.f));
        modelMatrix = glm::scale (modelMatrix, glm::vec3(scaleChange));
        

        // ========================== Draw ============================= //
        glDrawElements(GL_TRIANGLES, numOfIndices, GL_UNSIGNED_INT, 0);

        // ========================== End ============================== //
        // End Draw
        glfwSwapBuffers(window);
        glFlush();

        // Reset bindings
        glBindVertexArray(0);
        glUseProgram(0);
        glActiveTexture(0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    // End of Program
    glfwDestroyWindow(window);
    glfwTerminate();

    glDeleteProgram(shaderProgram);

    return 0;
}
```

<br>

# References
---
- <https://www.youtube.com/watch?v=xwP2XCtfGv8>
- <https://heinleinsgame.tistory.com/10>