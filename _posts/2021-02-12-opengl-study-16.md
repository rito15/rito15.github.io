---
title: OpenGL 공부 - 16 - Transform, Input
author: Rito15
date: 2021-02-12 15:11:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 오브젝트 기본 트랜스폼 정의하기
- 키보드 입력 처리하기

<br>

# 트랜스폼 정의
---

트랜스폼의 3요소(위치, 회전, 크기)를 정의한다.

```cpp
glm::vec3 position(0.0f);
glm::vec3 rotation(0.0f);
glm::vec3 scale(1.0f);
```

그리고 모델 행렬에 트랜스폼 연산을 모두 넣어준다.

```cpp
modelMatrix = glm::translate(modelMatrix, position);
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::scale(modelMatrix, scale);
```

루프 내에서 트랜스폼 변경을 수행할 경우, 모델 매트릭스를 매번 초기화한 뒤 위의 연산을 동일하게 수행해준다.

```cpp
// in main loop

double time = glfwGetTime();

position.x = glm::sin(time) * 0.6f;
position.y = glm::cos(time) * 0.3f;
rotation.y += 3.0f;
scale.x = glm::sin(time) * 0.5f + 1.0f;
scale.z = glm::cos(time * 10.f) * 0.8f + 1.0f;

modelMatrix = glm::mat4(1.0f);
modelMatrix = glm::translate(modelMatrix, position);
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::scale(modelMatrix, scale);

glUniformMatrix4fv
(
    glGetUniformLocation(shaderProgram, "ModelMatrix"),
    1, GL_FALSE, glm::value_ptr(modelMatrix)
);
```

![2021_0212_Transform](https://user-images.githubusercontent.com/42164422/107738952-1b202b80-6d4b-11eb-8641-e170929fb533.gif){:.normal}

<br>

# 키보드 입력 처리
---

입력을 받아 트랜스폼 정보를 변경하기 위한 메소드를 작성한다.

```cpp
void UpdateTransformByInputs(
    GLFWwindow* window,
    glm::vec3& position, glm::vec3& rotation, glm::vec3& scale,
    float moveSpeed, float rotSpeed, float scaleSpeed)
{
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) position.y += moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) position.y -= moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) position.x -= moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) position.x += moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS) rotation.y -= rotSpeed;
    if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS) rotation.y += rotSpeed;
    if (glfwGetKey(window, GLFW_KEY_Z) == GLFW_PRESS) scale /= (1.0f + scaleSpeed);
    if (glfwGetKey(window, GLFW_KEY_C) == GLFW_PRESS) scale *= (1.0f + scaleSpeed);
}
```

메인 루프에서 호출한다.

```cpp
UpdateTransformByInputs(window, position, rotation, scale, 0.02f, 5.0f, 0.04f);
```

![2021_0212_Move](https://user-images.githubusercontent.com/42164422/107740413-68ea6300-6d4e-11eb-94cb-c31912be499b.gif){:.normal}

![2021_0212_Rot](https://user-images.githubusercontent.com/42164422/107740416-6b4cbd00-6d4e-11eb-83a5-17cf5ae74444.gif){:.normal}

![2021_0212_Scale](https://user-images.githubusercontent.com/42164422/107740420-6daf1700-6d4e-11eb-9f5d-202f775f2045.gif){:.normal}

<br>

# Current Source Codes
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

uniform mat4 ModelMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

void main()
{
    vec4 worldPos4 = ModelMatrix * vec4(vertex_position, 1.);
    vec4 clipPos4 = ProjectionMatrix * ViewMatrix * worldPos4;

    // 프래그먼트 쉐이더에서 사용할 월드 좌표 전달
    // 이 값은 카메라 이동의 영향을 받지 않음
    vs_position = worldPos4.xyz;
    vs_color    = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.);

    // 정점 쉐이더의 최종 출력(정점 좌표)은 클립 좌표
    gl_Position = clipPos4;
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

## errorHandler.hpp
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
        std::string errStr = "";
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

        std::cout << "[OpenGL Error] - " << errStr << std::endl
             << "Code : " << function << std::endl
             << "Line : " << file << " : " << line << std::endl << std::endl;
        return false;
    }
    return true;
}
```

## variables.hpp

```cpp
// Global Variables
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

void UpdateTransformByInputs(
    GLFWwindow* window,
    glm::vec3& position, glm::vec3& rotation, glm::vec3& scale,
    float moveSpeed, float rotSpeed, float scaleSpeed)
{
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) position.y += moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) position.y -= moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) position.x -= moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) position.x += moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_Q) == GLFW_PRESS) rotation.y -= rotSpeed;
    if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS) rotation.y += rotSpeed;
    if (glfwGetKey(window, GLFW_KEY_Z) == GLFW_PRESS) scale /= (1.0f + scaleSpeed);
    if (glfwGetKey(window, GLFW_KEY_C) == GLFW_PRESS) scale *= (1.0f + scaleSpeed);
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
#include "errorHandler.hpp"
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
    glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
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

    //glEnable(GL_CULL_FACE);
    //glCullFace(GL_BACK);
    //glFrontFace(GL_CCW); // 시계 반대 방향으로 구성된 폴리곤을 전면으로 설정

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
    // Object Transform Values
    glm::vec3 position(0.0f);
    glm::vec3 rotation(0.0f);
    glm::vec3 scale(1.0f);

    // MVP Matrices
    glm::mat4 modelMatrix(1.0f);
    glm::mat4 viewMatrix(1.0f);
    glm::mat4 projectionMatrix(1.0f);

    // 1. Model
    modelMatrix = glm::translate(modelMatrix, position);
    modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
    modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
    modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
    modelMatrix = glm::scale(modelMatrix, scale);

    // 2. View
    glm::vec3 camPos(0.0f, 0.0f, 1.0f);
    glm::vec3 camFrontDir(0.0f, 0.0f, -1.0f);
    glm::vec3 worldUpDir(0.0f, 1.0f, 0.0f);

    viewMatrix = glm::lookAt(camPos, camPos + camFrontDir, worldUpDir);

    // 3. Projection
    float fov = 90.0f; // Field of View Angle
    float nearPlane = 0.1f;
    float farPlane = 100.0f;

    projectionMatrix = glm::perspective
    (
        glm::radians(fov),
        static_cast<float>(framebufferWidth) / framebufferHeight,
        nearPlane,
        farPlane
    );

    /*****************************************************************
                                   Uniforms (Init)
    ******************************************************************/
    glUseProgram(shaderProgram);

    // 1. Textures
    glUniform1i(glGetUniformLocation(shaderProgram, "catTex"), 0);
    glUniform1i(glGetUniformLocation(shaderProgram, "wallTex"), 1);

    // 2. Matrices
    glUniformMatrix4fv
    (
        glGetUniformLocation(shaderProgram, "ModelMatrix"),
        1, GL_FALSE, glm::value_ptr(modelMatrix)
    );
    glUniformMatrix4fv
    (
        glGetUniformLocation(shaderProgram, "ViewMatrix"),
        1, GL_FALSE, glm::value_ptr(viewMatrix)
    );
    glUniformMatrix4fv
    (
        glGetUniformLocation(shaderProgram, "ProjectionMatrix"),
        1, GL_FALSE, glm::value_ptr(projectionMatrix)
    );

    glUseProgram(0);

    /*****************************************************************
                                   Main Loop
    ******************************************************************/
    while (!glfwWindowShouldClose(window))
    {
        // =========================== Init ============================ //
        GLCheck(
        // Update Input
        glfwPollEvents();
        UpdateInputs(window);

        // Clear
        glClearColor(0.f, 0.f, 0.f, 1.f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

        // Variables
        double time = glfwGetTime();
        );

        // ========================= Bindings ========================== //
        GLCheck(
        // Use a shader program
        glUseProgram(shaderProgram);

        // Bind VAO
        glBindVertexArray(vao);

        // Activate, Bind Textures
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture0);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture1);
        );

        // ========================= Update Uniforms ==================== //

        // ========================= Update Transform =================== //
        GLCheck(
        UpdateTransformByInputs(window, position, rotation, scale, 0.02f, 5.0f, 0.04f);

        modelMatrix = glm::mat4(1.0f);
        modelMatrix = glm::translate(modelMatrix, position);
        modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
        modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
        modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
        modelMatrix = glm::scale(modelMatrix, scale);

        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "ModelMatrix"),
            1, GL_FALSE, glm::value_ptr(modelMatrix)
        );
        );

        // ========================= Track Frame Size Change ============ //
        GLCheck(
        glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);

        projectionMatrix = glm::perspective
        (
            glm::radians(fov),
            static_cast<float>(framebufferWidth) / framebufferHeight,
            nearPlane,
            farPlane
        );
        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "ProjectionMatrix"),
            1, GL_FALSE, glm::value_ptr(projectionMatrix)
        );
        );

        // ========================== Draw ============================= //
        GLCheck(glDrawElements(GL_TRIANGLES, numOfIndices, GL_UNSIGNED_INT, 0));

        // ========================== End ============================== //
        
        // End Draw
        GLCheck(glfwSwapBuffers(window););
        GLCheck(glFlush(););

        // Reset bindings
        GLCheck(glBindVertexArray(0););
        GLCheck(glUseProgram(0););
        //GLCheck(glActiveTexture(0);) // error
        GLCheck(glBindTexture(GL_TEXTURE_2D, 0););
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
- <https://www.youtube.com/watch?v=uX3Iil0F51U>
