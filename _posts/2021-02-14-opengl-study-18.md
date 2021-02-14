---
title: OpenGL 공부 - 18 - Specular, Rim Light
author: Rito15
date: 2021-02-14 15:38:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- Specular Lighting, Rim Lighting 적용

<br>

# 공부 내용
---

## 필요한 유니폼 변수 전달

World View 벡터가 필요하므로, 이를 구하기 위한 카메라 위치를 전달해준다.

```cpp
// main.cpp

glUniform3fv(glGetUniformLocation(shaderProgram, "cameraPos"), 1, glm::value_ptr(camPos));
```

<br>
## 프래그먼트 쉐이더

우선 라이팅 계산을 위한 벡터들을 만들어준다.

```glsl
uniform vec3 lightPos0; // Main Light World Position
uniform vec3 cameraPos; // Camera World Position

void main()
{
    vec3 worldNormal = normalize(vs_normal);
    vec3 worldLight  = normalize(lightPos0 - worldPos);
    vec3 worldView   = normalize(cameraPos - worldPos);
    vec3 worldLightRefl = reflect(-worldLight, worldNormal);
    //vec3 worldLightRefl = normalize(2. * worldNormal * dot(worldNormal, worldLight) - worldLight);
    vec3 worldHalf = normalize(worldLight + worldView);
}
```

![](https://user-images.githubusercontent.com/42164422/105632022-871e1b00-5e94-11eb-8a8a-06fa08406fa2.png)

- worldNormal(N) : 정점의 노멀 방향 벡터
- worldLight(L) : 정점에서 광원을 향하는 방향 벡터
- worldView(V) : 정점에서 카메라를 향하는 방향 벡터
- worldLightRefl(R) : 노멀 벡터를 법선으로 L 벡터와 대칭이 되는 방향벡터
- worldHalf(H) : V, L의 중간을 가로지르는 방향 벡터

<br>
## Phong Specular

스페큘러의 원리는 다음과 같다.

```
물체의 표면에 반사된 빛의 방향과 시선이 이루는 각도가 작을수록 반사광이 강하게 맺힌다.
```

따라서 표면에 반사된 빛의 방향벡터는 R 벡터, 시선의 방향벡터는 V 벡터이고

두 벡터의 사잇각은 내적을 통해 간접적으로 구할 수 있으므로, 이를 이용한다.

```glsl
vec3 specCol = vec3(1., 0., 0.);

float RdV = dot(worldLightRefl, worldView);
float specPhongPower = 30.;
float specPhong = pow(saturate(RdV), specPhongPower);
```

스페큘러를 강조하기 위해 스페큘러 색상은 붉은색으로 넣었다.

![2021_0214_PhongSpec](https://user-images.githubusercontent.com/42164422/107872251-5017b400-6eec-11eb-8e0f-a3a710348743.gif){:.normal}

<br>
## Blinn Phong Specular

퐁 스페큘러는 반사 벡터를 구하는 비용이 저렴하지 않다.

그래서 이걸 보완할 수 있는 대표적인 스페큘러 공식이 블린 퐁 스페큘러이다.

L 벡터와 V 벡터의 중간 벡터인 H를 구했을 때,

dot(H, N)의 결과가 dot(R, V)와 유사하다는 점을 이용한다.

```glsl
float NdH = dot(worldNormal, worldHalf);
float specBpPower = 500.;
float specBP = pow(saturate(NdH), specBpPower);
```

![2021_0214_BlinnPhongSpec](https://user-images.githubusercontent.com/42164422/107872252-5312a480-6eec-11eb-9817-2f03db366eba.gif){:.normal}

<br>
## Rim Light

림 라이트는 은은한 역광의 표현에 주로 사용되며, 프레넬 공식을 이용한다.

프레넬 공식은 시선 방향과 물체 표면이 이루는 각도의 관계를 다룬다.

이는 V 벡터와 N 벡터의 관계로 표현할 수 있고, 두 벡터의 사잇각이 직각에 가까울수록(dot(N, V)가 0에 가까울수록) 반사광이 강해짐을 나타낸다.

```glsl
float NdV = dot(worldNormal, worldView);
float rimPower = 1.;
float rim = pow(1. - saturate(NdV), rimPower) * 2.;
```

![2021_0214_RimLight](https://user-images.githubusercontent.com/42164422/107872253-5574fe80-6eec-11eb-9777-7c75efd6136b.gif){:.normal}

- 림라이트를 더 확실하게 확인할 수 있도록 임시로 정육면체를 구현하였다.

<br>

# Current Source Codes
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
uniform vec3 lightPos0; // Main Light World Position
uniform vec3 cameraPos; // Camera World Position

void main()
{
    vec3 worldPos = vs_position;

    // ====================== World Vectors =========================
    vec3 worldNormal = normalize(vs_normal);
    vec3 worldLight  = normalize(lightPos0 - worldPos);
    vec3 worldView   = normalize(cameraPos - worldPos);
    vec3 worldLightRefl = reflect(-worldLight, worldNormal);
    //vec3 worldLightRefl = normalize(2. * worldNormal * dot(worldNormal, worldLight) - worldLight);
    vec3 worldHalf = normalize(worldLight + worldView);
    
    // ====================== Colors ================================
    vec3 catColor = texture(catTex, vs_texcoord).xyz;
    vec3 wallColor = texture(wallTex, vs_texcoord).xyz;
    vec3 catMask = step(vec3(0.01), catColor);

    vec3 albedo = mix(wallColor, catColor * vs_color, catMask);
    vec3 lightCol = vec3(1., 1., 1.);
    vec3 specCol = vec3(1., 0., 0.);

    // ====================== Lighting ==============================
    // Ambient Light
    vec3 ambient = vec3(.2);

    // Diffuse Light
    float NdL = dot(worldNormal, worldLight);
    float diffuse = saturate(NdL);

    // Specular Light
    // 1. Phong
    float RdV = dot(worldLightRefl, worldView);
    float specPhongPower = 30.;
    float specPhong = pow(saturate(RdV), specPhongPower);

    // 2. Blinn Phong
    float NdH = dot(worldNormal, worldHalf);
    float specBpPower = 500.;
    float specBP = pow(saturate(NdH), specBpPower);

    // 3. Rim Light
    float NdV = dot(worldNormal, worldView);
    float rimPower = 1.;
    float rim = pow(1. - saturate(NdV), rimPower) * 2.;

    // +. Real Rim
    
    // ====================== Final Color ============================
    vec3 col = albedo * lightCol * (diffuse + ambient) + specPhong * specCol;
    col = albedo * ( ambient) + specBP * specCol;
    //col = vs_normal;
    //col = vec3(diffuse);
    //col = vec3(specBP) + ambient;
    //col = vec3(diffuse) *.5 + specPhong * specCol + ambient;
    
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
//Vertex vertices[] =
//{
//    // Position                    // Color                     // TexCoord            // Normal                                                
//    glm::vec3(-0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LT
//    glm::vec3(-0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // LB
//    glm::vec3( 0.5f, -0.5f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RB
//    glm::vec3( 0.5f,  0.5f, 0.0f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(0.0f, 0.0f, 1.0f), // RT
//};
//
//// NOTE : Counter Clockwise
//GLuint indices[] =
//{
//    0, 1, 2,
//    0, 2, 3
//};

// 2. 육면체 : 임시
Vertex vertices[] =
{
    // Position                    // Color                     // TexCoord            // Normal
    //glm::vec3(-0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 0
    //glm::vec3(-0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 1
    //glm::vec3(+0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 2
    //glm::vec3(+0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 3

    //glm::vec3(-0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 4
    //glm::vec3(-0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 5
    //glm::vec3(+0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 6
    //glm::vec3(+0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(.0f, .0f), glm::vec3(.0f, .0f, .0f), // 7


    glm::vec3(-0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(-1.0f, .0f, .0f), // 0  // 0
    glm::vec3(-0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(-1.0f, .0f, .0f), // 4  // 1
    glm::vec3(-0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(1.0f, 0.0f), glm::vec3(-1.0f, .0f, .0f), // 5  // 2
    glm::vec3(-0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(-1.0f, .0f, .0f), // 1  // 3
                                                                                                                          // 
    glm::vec3(-0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(.0f, .0f, +1.0f), // 1  // 4
    glm::vec3(-0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(.0f, .0f, +1.0f), // 5  // 5
    glm::vec3(+0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(.0f, .0f, +1.0f), // 6  // 6
    glm::vec3(+0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 1.0f), glm::vec3(.0f, .0f, +1.0f), // 2  // 7
                                                                                                                          // 
    glm::vec3(+0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(0.0f, 1.0f), glm::vec3(+1.0f, .0f, .0f), // 2  // 8
    glm::vec3(+0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(0.0f, 0.0f), glm::vec3(+1.0f, .0f, .0f), // 6  // 9
    glm::vec3(+0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 0.0f), glm::vec3(+1.0f, .0f, .0f), // 7  // 10
    glm::vec3(+0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(+1.0f, .0f, .0f), // 3  // 11
                                                                                                                          // 
    glm::vec3(+0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(.0f, .0f, -1.0f), // 3  // 12
    glm::vec3(+0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(.0f, .0f, -1.0f), // 7  // 13
    glm::vec3(-0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(1.0f, 0.0f), glm::vec3(.0f, .0f, -1.0f), // 4  // 14
    glm::vec3(-0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(.0f, .0f, -1.0f), // 0  // 15
                                                                                                                          // 
    glm::vec3(-0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(.0f, +1.0f, .0f), // 0  // 16
    glm::vec3(-0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(.0f, +1.0f, .0f), // 1  // 17
    glm::vec3(+0.5f,  0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 0.0f), glm::vec3(.0f, +1.0f, .0f), // 2  // 18
    glm::vec3(+0.5f,  0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 1.0f), glm::vec3(.0f, +1.0f, .0f), // 3  // 19
                                                                                                                          // 
    glm::vec3(-0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 1.0f, 0.0f), glm::vec2(0.0f, 1.0f), glm::vec3(.0f, -1.0f, .0f), // 5  // 20
    glm::vec3(-0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 0.0f, 0.0f), glm::vec2(0.0f, 0.0f), glm::vec3(.0f, -1.0f, .0f), // 4  // 21
    glm::vec3(+0.5f, -0.5f, -0.5f), glm::vec3(1.0f, 1.0f, 0.0f), glm::vec2(1.0f, 0.0f), glm::vec3(.0f, -1.0f, .0f), // 7  // 22
    glm::vec3(+0.5f, -0.5f,  0.5f), glm::vec3(0.0f, 0.0f, 1.0f), glm::vec2(1.0f, 1.0f), glm::vec3(.0f, -1.0f, .0f), // 6  // 23
};

// NOTE : Counter Clockwise
GLuint indices[] =
{
    0, 1, 2, 0, 2, 3,
    4, 5, 6, 4, 6, 7,
    8, 9, 10, 8, 10, 11,
    12, 13, 14, 12, 14, 15,
    16, 17, 18, 16, 18, 19,
    20, 21, 22, 20, 22, 23,
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

    // 3. Light Pos
    glUniform3fv(glGetUniformLocation(shaderProgram, "lightPos0"), 1, glm::value_ptr(lightPos0));

    // 4. Cam Pos
    glUniform3fv(glGetUniformLocation(shaderProgram, "cameraPos"), 1, glm::value_ptr(camPos));

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
- <https://www.youtube.com/watch?v=SXC4dbW4Vp8>
