---
title: OpenGL 공부 - 15 - View Projection Matrix
author: Rito15
date: 2021-02-11 17:05:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- View, Projection 행렬 만들고 적용하기

<br>

# 공간 변환
---

![image](https://user-images.githubusercontent.com/42164422/107613437-ab973700-6c8b-11eb-99a8-d08c99fc0d73.png){:.normal}

공간 변환 과정을 간단히 설명하면 다음과 같다.

## 1. Model Transformation

* Model -> World

모델링의 피벗이 원점인 Local Space(Model Space 또는 Object Space)에 Model Matrix를 곱하면 월드의 특정 좌표가 원점인 World Space의 좌표로 변환된다.

<br>

## 2. View Transformation

* World -> View

카메라의 위치, 방향을 정의한 뒤 World Space에 View Matrix를 곱해주면 View Space로 변환된다.

View Space에서는 카메라의 좌표가 원점이며, 카메라를 통해 공간을 바라보는 형태가 된다.

<br>

## 3. Projection Transformation

* View -> Clip

View Space에서는 원근감의 존재 유무에 따라 Orthgraphic Projection 또는 Perspective Projection 행렬을 생성하여 View Space의 좌표에 곱해주게 된다.

<br>
### 3-1. Orthographic Projection

![image](https://user-images.githubusercontent.com/42164422/107614550-df735c00-6c8d-11eb-8135-fe98c8fd0e59.png){:.normal}

원근감이 필요하지 않은 경우, Orthographic Projection을 수행한다.

Near Plane, Far Plane, Width, Height 값을 통해 직육면체 형태의 Frustum(절두체)를 정의하여, 절두체 바깥의 모든 정점은 잘라내고(Clipping) 절두체 내의 정점들은 모든 좌표가 -1 ~ 1 사이에 위치한 NDC(Normalized Divice Coordinate) 좌표계로 매핑된다.

<br>
### 3-2. Perspective Projection

![image](https://user-images.githubusercontent.com/42164422/107614816-60325800-6c8e-11eb-8a9b-31e0c3df3878.png){:.normal}

원근감을 부여해야 하는 경우, Perspective Projection을 수행한다.

정점과 카메라 사이의 거리값을 각 정점의 좌표 중 w값에 넣고, Projection을 수행할 때 (x, y, z) 위치값을 w로 나누어준다.

따라서 오브젝트가 카메라에서 멀리 있을수록 더 작아보이게 된다.

Orthographic과는 달리 fov(Field of View) 각도가 추가적으로 필요하며, Projection의 결과로 역시 절두체 내 모든 정점이 NDC 내에 정의된다.

<br>

## 4. Viewport Transformation

* Clip(3D, -1~1) -> Screen(2D, 0~1)

Clip Space의 모든 정점은 스크린에 매핑하기 쉬운 NDC 좌표계에 위치하여, -1 ~ 1 사이의 값을 가진다. (3D)

이 정점들은 Viewport Transform을 통해 0 ~ 1 사이의 값을 갖는 스크린 좌표로 변환된다. (2D)

<br>

# 소스코드 작성
---

## 버텍스 쉐이더 수정

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

- 아직은 사용처를 알 수 없으나, 프래그먼트 쉐이더에서 사용할 vs_position은 월드 좌표를 전달한다.

- 버텍스 쉐이더의 최종 출력인 gl_Position은 클립 좌표로 전달한다.

<br>

## 메인 소스 코드 작성

### **Model Transformation**

- 보류, 기존의 Model Matrix 사용

<br>

### **View Transformation**

```cpp
glm::vec3 camPos(0.0f, 0.0f, 2.0f);
glm::vec3 worldUpDir(0.0f, 1.0f, 0.0f);
glm::vec3 camFrontDir(0.0f, 0.0f, -1.0f);

glm::mat4 viewMatrix(1.0f);
viewMatrix = glm::lookAt(camPos, camPos + camFrontDir, worldUpDir);
```

World Space에서는 카메라 위치, 카메라 전방 벡터, 월드 Y 방향 벡터를 정의하고

이를 이용하여 View Matrix를 생성한다.

<br>

### **Projection Transformation**

```cpp
float fov = 90.0f; // Field of View Angle
float nearPlane = 0.1f;
float farPlane = 100.0f;

glm::mat4 projectionMatrix =
    glm::perspective (
        glm::radians(fov),
        static_cast<float>(framebufferWidth / framebufferHeight),
        nearPlane,
        farPlane
    );
```

View Space에서는 fov 각도, 절두체의 너비와 높이, nearPlane과 farPlane을 정의하고

이를 이용하여 Projection Matrix를 생성한다.

<br>

### **Send Uniform Variables**

```cpp
glUseProgram(shaderProgram);

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
```

행렬에 변화가 없다면 메인 루프 위에서 한 번만 위처럼 유니폼 값을 전달해주면 된다.

하지만 지난 번 작성한 코드처럼 메인 루프 내에서 행렬에 변화를 주는 경우(모델 행렬),

변화한 행렬을 메인 루프의 드로우콜 이전에 유니폼 함수를 통해 전달해야 한다.

따라서 View Matrix와 Projection Matrix는 루프 내에서 변하지 않을 것이므로 메인 루프 위에서 전달한다.

<br>

![image](https://user-images.githubusercontent.com/42164422/107622707-90342800-6c9b-11eb-97ad-4f7b9103b8d9.png){:.normal}

모델 행렬에서 약간 회전을 줘서 위와 같은 결과를 얻었다.

```cpp
modelMatrix = glm::rotate(modelMatrix, glm::radians(45.f), glm::vec3(0.f, 1.f, 1.f));
```

그런데 프레임의 크기를 변경할 경우,

![image](https://user-images.githubusercontent.com/42164422/107622885-e1441c00-6c9b-11eb-88d2-8489facda252.png){:.normal}

이렇게 픽셀도 따라서 늘어나게 된다.

이를 방지하기 위해 메인 루프에서 드로우 콜 이전에

```cpp
glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);

projectionMatrix = glm::perspective
(
    glm::radians(fov),
    static_cast<float>(framebufferWidth / (float)framebufferHeight),
    nearPlane,
    farPlane
);
glUniformMatrix4fv
(
    glGetUniformLocation(shaderProgram, "ProjectionMatrix"),
    1, GL_FALSE, glm::value_ptr(projectionMatrix)
);
```

이렇게 작성하면

![image](https://user-images.githubusercontent.com/42164422/107622977-033d9e80-6c9c-11eb-867f-5d8d816a27d3.png){:.normal}

프레임의 크기가 변해도 픽셀이 출력되는 스크린의 비율을 동일하게 유지할 수 있다.


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
    // Matrices
    glm::mat4 modelMatrix(1.0f);
    glm::mat4 viewMatrix(1.0f);
    glm::mat4 projectionMatrix(1.0f);

    // 1. Model
    modelMatrix = glm::scale(modelMatrix, glm::vec3(1.5f));
    modelMatrix = glm::rotate(modelMatrix, glm::radians(45.f), glm::vec3(0.f, 1.f, 1.f));
    modelMatrix = glm::translate(modelMatrix, glm::vec3(0.f));

    // 2. View
    glm::vec3 camPos(0.0f, 0.0f, 2.0f);
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
        static_cast<float>(framebufferWidth / framebufferHeight),
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

        // ========================= Uniforms(Update) =================== //
        /*
        float scaleChange = glm::sin(glfwGetTime() * 2.f) * 0.02f + 1.f;
        modelMatrix = glm::rotate(modelMatrix, glm::radians(2.f), glm::vec3(0.f, 1.f, 1.f));
        modelMatrix = glm::scale (modelMatrix, glm::vec3(scaleChange));

        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "ModelMatrix"),
            1, GL_FALSE, glm::value_ptr(modelMatrix)
        );*/

        // ========================= Track Frame Size Change ============ //
        glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);

        projectionMatrix = glm::perspective
        (
            glm::radians(fov),
            static_cast<float>(framebufferWidth / (float)framebufferHeight),
            nearPlane,
            farPlane
        );
        glUniformMatrix4fv
        (
            glGetUniformLocation(shaderProgram, "ProjectionMatrix"),
            1, GL_FALSE, glm::value_ptr(projectionMatrix)
        );
        
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
- <https://www.youtube.com/watch?v=1yOVQv7wPm4>
- <https://heinleinsgame.tistory.com/11>
