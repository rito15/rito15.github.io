---
title: OpenGL 공부 - 17 - Ambient, Diffuse Lighting
author: Rito15
date: 2021-02-13 15:32:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- Ambient, Diffuse 라이팅 구현

<br>

# 공부 내용
---

## 버텍스에 노멀 정보 추가

```cpp
struct Vertex
{
    glm::vec3 position;
    glm::vec3 color;
    glm::vec2 texcoord;
    glm::vec3 normal;
};

Vertex vertices[] =
{
    // Position                    // Color                     // TexCoord            // Normal                                                
    glm::vec3(-0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LT
    glm::vec3(-0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LB
    glm::vec3( 0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RB
    glm::vec3( 0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RT
};


int main()
{
    // ...

    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, normal));
    glEnableVertexAttribArray(3);

    // ...
}
```

- 카메라를 향하는 방향이 +Z, 멀어지는 방향이 -Z이기 때문에 노멀은 +Z 방향으로 지정한다.


## 라이트 정보 추가, 쉐이더에 전달

- main.cpp

```cpp
int main()
{
    // ...

    glUseProgram(shaderProgram);

    glm::vec3 lightPos0(0.0f, 0.0f, 2.0f);
    glUniform3fv(glGetUniformLocation(shaderProgram, "lightPos0"), 1, glm::value_ptr(lightPos0));

    glUseProgram(0);

    // ...
}
```

## 버텍스 쉐이더

- 노멀 전달받고, 월드 노멀로 프래그먼트 쉐이더에 전달

```glsl
#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;
layout (location = 2) in vec3 vertex_texcoord;
layout (location = 3) in vec3 vertex_normal;

out vec3 vs_position;
out vec3 vs_color;
out vec2 vs_texcoord;
out vec3 vs_normal;

uniform mat4 ModelMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

void main()
{
    vec4 worldPos4 = ModelMatrix * vec4(vertex_position, 1.);
    vec4 clipPos4 = ProjectionMatrix * ViewMatrix * worldPos4;

    // 프래그먼트 쉐이더에는 월드 스페이스의 정점 데이터 전달
    vs_position = worldPos4.xyz;
    vs_color    = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.);
    vs_normal   = (ModelMatrix * vec4(vertex_normal, 1.)).xyz;

    // 정점 쉐이더의 최종 출력(정점 좌표)은 클립 좌표
    gl_Position = clipPos4;
}
```

## 프래그먼트 쉐이더에서 라이팅 수행

```glsl
#version 440

#define saturate(x) clamp(x, 0., 1.)

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;
in vec3 vs_normal;

out vec4 fs_color;

uniform sampler2D catTex;
uniform sampler2D wallTex;
uniform vec3 lightPos0; // Main Light

void main()
{
    vec3 catColor = texture(catTex, vs_texcoord).xyz;
    vec3 wallColor = texture(wallTex, vs_texcoord).xyz;
    vec3 catMask = step(vec3(0.01), catColor);

    // Colors
    vec3 albedo = mix(wallColor, catColor * vs_color, catMask);
    vec3 lightCol = vec3(1., 1., 1.);

    // ====================== Lighting ==============================
    // 월드 라이트 벡터(정점 -> 광원)
    vec3 lightDir = normalize(lightPos0 - vs_position);

    // Ambient Light
    vec3 ambient = vec3(.1);

    // Diffuse Light
    float NdL = dot(vs_normal, lightDir);
    vec3 diffuse = vec3(saturate(NdL));
    
    // ====================== Final Color ============================
    vec3 col = albedo * lightCol * (diffuse + ambient);
    fs_color = vec4(col, 1.);
}
```

## 결과

![2021_0213_lighting01](https://user-images.githubusercontent.com/42164422/107846645-aa4f4100-6e28-11eb-8b9e-a6d31fc70ba5.gif){:.normal}

회전했을 때의 모습을 보면 정상적인 것 같다.

그런데 거리가 멀어지면 감쇄가 일어나는 것처럼 점차 밝기가 감소한다.

그래서 NdL을 dot(N, L) 대신 dot(normalize(N), L)로 적용하면, 일정 거리까지는 밝기가 동일하고, 그 거리보다 멀어지면 바로 사라져버린다.

<br>

# 버그 수정
---

위의 결과에서 무언가 이상함을 느끼고 디퓨즈만 출력해봤다.

![2021_0213_Diffuse](https://user-images.githubusercontent.com/42164422/107846647-acb19b00-6e28-11eb-8cc0-899a90accbcd.gif){:.normal}

내가 멍청했음을 인정하고 이번에는 노멀만 출력해봤다.

![2021_0213_NormalValue](https://user-images.githubusercontent.com/42164422/107846652-af13f500-6e28-11eb-86c9-0e4ade22ab57.gif){:.normal}

정점의 위치만 이동해도 노멀 값이 바뀐다..?

그러니까 정점 위치가 (0., 0., 0.)에서 (1., 1. 0.)으로 바뀌면 노멀도 (0., 0., 1.)에서 (1., 1., 1)로 바뀐다.

생각해보니 모델 행렬을 그대로 노멀에도 곱해줘서 일어나는 현상이었다.


<br>

그래서 버텍스 쉐이더에서

```glsl
uniform mat4 ModelMatrixForNormal;
```

이걸 추가하고

```glsl
vs_normal = (ModelMatrixForNormal * vec4(vertex_normal, 1.)).xyz;
```

요렇게 계산해주고

메인 루프에서

```cpp
glm::mat4 modelMatrixForNormal(1.0f);
modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));

glUniformMatrix4fv
(
    glGetUniformLocation(shaderProgram, "ModelMatrixForNormal"),
    1, GL_FALSE, glm::value_ptr(modelMatrixForNormal)
);
```

이렇게 회전만 적용된 모델 행렬을 유니폼으로 넣어준다.

그다음 광원의 위치를 (0f, 0f, -1f) 로 바꿔주었다.

우선 노멀을 출력해봤다.

![2021_0213_NormalValue_Solved](https://user-images.githubusercontent.com/42164422/107846653-b20ee580-6e28-11eb-9a98-f4ce78dcbba4.gif){:.normal}

의도대로 회전에만 영향받고, 위치, 크기에는 영향받지 않는다.

그리고 최종 색상을 출력해보면

![2021_0213_Lighting_Solved2](https://user-images.githubusercontent.com/42164422/107846655-b3d8a900-6e28-11eb-83ec-51266854488e.gif){:.normal}

정확히 원하는대로 나온다.

<br>

# Source Code
---

## vertex_core.glsl

```glsl
#version 440

layout (location = 0) in vec3 vertex_position;
layout (location = 1) in vec3 vertex_color;
layout (location = 2) in vec3 vertex_texcoord;
layout (location = 3) in vec3 vertex_normal;

out vec3 vs_position;
out vec3 vs_color;
out vec2 vs_texcoord;
out vec3 vs_normal;

uniform mat4 ModelMatrix;
uniform mat4 ModelMatrixForNormal; // 노멀 변환용 행렬
uniform mat4 ViewMatrix;
uniform mat4 ProjectionMatrix;

void main()
{
    vec4 worldPos4 = ModelMatrix * vec4(vertex_position, 1.);
    vec4 clipPos4 = ProjectionMatrix * ViewMatrix * worldPos4;

    // 프래그먼트 쉐이더에는 월드 스페이스의 정점 데이터 전달
    vs_position = worldPos4.xyz;
    vs_color    = vertex_color;
    vs_texcoord = vec2(vertex_texcoord.x, vertex_texcoord.y * -1.);
    vs_normal   = (ModelMatrixForNormal * vec4(vertex_normal, 1.)).xyz;

    // 정점 쉐이더의 최종 출력(정점 좌표)은 클립 좌표
    gl_Position = clipPos4;
}
```

## fragment_core.glsl

```glsl
#version 440

#define saturate(x) clamp(x, 0., 1.)

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;
in vec3 vs_normal;

out vec4 fs_color;

uniform sampler2D catTex;
uniform sampler2D wallTex;
uniform vec3 lightPos0; // Main Light

void main()
{
    // 헷갈림 방지용 네이밍
    vec3 worldPos = vs_position;
    vec3 worldNormal = normalize(vs_normal);

    vec3 catColor = texture(catTex, vs_texcoord).xyz;
    vec3 wallColor = texture(wallTex, vs_texcoord).xyz;
    vec3 catMask = step(vec3(0.01), catColor);

    // Colors
    vec3 albedo = mix(wallColor, catColor * vs_color, catMask);
    vec3 lightCol = vec3(1., 1., 1.);

    // ====================== Lighting ==============================
    // 월드 라이트 벡터(정점 -> 광원)
    vec3 lightDir = normalize(lightPos0 - worldPos);

    // Ambient Light
    vec3 ambient = vec3(.2);

    // Diffuse Light
    float NdL = dot(worldNormal, lightDir);
    vec3 diffuse = vec3(saturate(NdL));
    
    // ====================== Final Color ============================
    vec3 col = albedo * lightCol * (diffuse + ambient);
    //col = vs_normal;
    //col = diffuse;
    
    fs_color = vec4(col, 1.);
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
    glm::vec3 normal;
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

// 1. 평면
Vertex vertices[] =
{
    // Position                    // Color                     // TexCoord            // Normal                                                
    glm::vec3(-0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LT
    glm::vec3(-0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LB
    glm::vec3( 0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RB
    glm::vec3( 0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RT
};

// NOTE : Counter Clockwise
GLuint indices[] =
{
    0, 1, 2,
    0, 2, 3
};

// 2. 육면체 : 보류
//Vertex vertices[] =
//{
//    // Position                    // Color                     // TexCoord            // Normal
//    glm::vec3(-0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LT
//    glm::vec3(-0.5f, -0.5f, -0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LB
//    glm::vec3( 0.5f, -0.5f, -0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RB
//    glm::vec3( 0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RT
//
//    glm::vec3(-0.5f,  0.5f, 0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f),
//    glm::vec3(-0.5f, -0.5f, 0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f),
//    glm::vec3( 0.5f, -0.5f, 0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f),
//    glm::vec3( 0.5f,  0.5f, 0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f),
//};
//
//// NOTE : Counter Clockwise
//GLuint indices[] =
//{
//    0, 1, 2, 0, 2, 3,
//    4, 5, 1, 4, 1, 0,
//    4, 0, 3, 4, 3, 7,
//    1, 5, 6, 1, 6, 2,
//    3, 2, 6, 3, 6, 7,
//    7, 6, 5, 7, 5, 4,
//};

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
    if (glfwGetKey(window, GLFW_KEY_Z) == GLFW_PRESS) position.z += moveSpeed;
    if (glfwGetKey(window, GLFW_KEY_C) == GLFW_PRESS) position.z -= moveSpeed;
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

    // 4. Normal
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, normal));
    glEnableVertexAttribArray(3);

    /*****************************************************************
                                   Textures
    ******************************************************************/
    GLuint texture0 = LoadTextureImage("Images/MoonCat.png");
    GLuint texture1 = LoadTextureImage("Images/Wall.png");

    /*****************************************************************
                                   Transformation
    ******************************************************************/
    // Object Transform Values
    glm::vec3 position(0.0f, 0.0f, 0.0f);
    glm::vec3 rotation(0.0f, 0.0f, 0.0f);
    glm::vec3 scale(1.0f, 1.0f, 1.0f);

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
    float farPlane = 1000.0f;

    projectionMatrix = glm::perspective
    (
        glm::radians(fov),
        static_cast<float>(framebufferWidth) / framebufferHeight,
        nearPlane,
        farPlane
    );

    /*****************************************************************
                                   Lights
    ******************************************************************/
    glm::vec3 lightPos0(0.0f, 0.0f, -1.0f);

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

    // 3. Light
    glUniform3fv(glGetUniformLocation(shaderProgram, "lightPos0"), 1, glm::value_ptr(lightPos0));

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
        UpdateTransformByInputs(window, position, rotation, scale, 0.04f, 5.0f, 0.04f);

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

        // 회전만 적용되는 노멀 변환용 행렬
        glm::mat4 modelMatrixForNormal(1.0f);
        modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
        modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
        modelMatrixForNormal = glm::rotate(modelMatrixForNormal, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));

        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "ModelMatrixForNormal"),
            1, GL_FALSE, glm::value_ptr(modelMatrixForNormal)
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
- <https://www.youtube.com/watch?v=Fw74_fKFowU>
