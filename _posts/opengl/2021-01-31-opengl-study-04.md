---
title: OpenGL 공부 - 04 - VAO, VBO, Attributes
author: Rito15
date: 2021-01-31 13:31:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- Vertex Attributes, Layout, VBO, VAO에 대한 이해

<br>

# Attributes, VAO, VBO
---
- 버텍스 버퍼에는 버텍스 좌표, 텍스쳐 좌표, 노멀 벡터 등 여러 데이터가 float 값으로 들어갈 수 있다.
- 하지만 그 자체로는 그저 메모리에 올라가는 값일 뿐이기 때문에 각각의 데이터가 어떤 역할을 하고, 길이는 얼마나 갖고 있고, 시작 위치는 어디인지 OpenGL에 알려줘야 한다.

<br>
- ## VAO(Vertex Array Object)
  - 하나 이상의 VBO를 담을 수 있는 객체
  - 개별 오브젝트의 모든 데이터를 담고 있다.
  - 고유 ID를 가진다.

```cpp
// 1. VAO ID 준비
GLuint vao;

// 2. VAO 객체 생성 및 ID에 바인딩
glGenVertexArrays(1, &vao);

// 3. 객체 타입 바인딩
glBindVertexArray(vao);
```

<br>
- ## VBO(Vertex Buffer Object)
  - 하나의 정점 속성을 갖고 있는 GPU 상의 메모리 버퍼
  - 예를 들어 위치 정보, 색상 정보, 노멀 정보 등
  - 고유 ID를 가진다.

```cpp
// 1. 버퍼 객체 ID 준비
GLuint vbo;

// 2. 버퍼 객체 생성 및 ID에 바인딩
glGenBuffers(1, &vbo);

// 3. 버퍼 객체에 타입 바인딩
glBindBuffer(GL_ARRAY_BUFFER, vbo);

// 4. 버퍼에 실질적 데이터 담기
// (미리 준비된 정점, 색상 등등의 배열 데이터(Attribute)를 vbo에 연결)
glBufferData(GL_ARRAY_BUFFER, size, attribute, GL_STATIC_DRAW);
```

<br>
- ## Vertex Attribute(정점 속성)
  - 버텍스 버퍼에 들어가는 입력 데이터
  - 각각의 속성은 배열로 이루어진다.
  - glVertexAttribPointer() 메소드를 통해 정점 속성을 어떻게 해석해야 하는지 지정해줄 수 있다.
  - 각각의 정점 속성은 VBO(Vertex Buffer Object)에 작성하며, 이를 하나의 VAO(Vertex Array Object)에 저장한다.

```cpp
// 1. 정점 속성의 레이아웃 지정
glVertexAttribPointer(index, size, type, normalized, stride, pointer);

// 2. 정점 속성 배열을 인덱스를 통해 등록
glEnableVertexAttribArray(index);
```

<br>
- ## VAO와 VBO의 관계
  - 출처 : <https://www.youtube.com/watch?v=WMiggUPst-Q>
![image](https://user-images.githubusercontent.com/42164422/106376782-b1636180-63db-11eb-9a79-756b3ab98715.png)

<br>

# 공부 내용
---

- ## glVertexAttribPointer()
  - 정점 속성 배열을 정의 : 레이아웃 지정

|---|---|
|`index`|해당 정점 속성의 순서(좌표, 색상, 노멀이 있다면 0, 1, 2 순서)|
|`size`|정점 속성의 구성 크기(벡터를 의미 : 1, 2, 3, 4 중 하나)|
|`type`|배열 내 데이터들의 타입|
|`normalized`|배열 내 데이터들이 정규화되어야 하는지 여부 전달|
|`stride`|배열 내 각각 데이터의 byte 오프셋 크기<br>(sizeof(float) * 2는 float 2개씩 구성되어 있음을 의미)|
|`pointer`|해당 정점 속성의 시작 byte 위치<br>(좌표가 12, 색상이 16, 노멀이 12를 갖는다면<br>좌표는 0, 색상은 12, 노멀은 28의 byte 위치를 가짐)|

```cpp
glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);
```

<br>
- ## glEnableVertexAttribArray()
  - 해당 인덱스에 위치한 정점 속성 배열을 활성화

|---|---|
|`index`|활성화시킬 정점 속성 배열이 위치한 인덱스|

```cpp
glEnableVertexAttribArray(0);
```

<br>

# Source Code
---
```cpp
#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <iostream>
using namespace std;

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

    glfwTerminate();
    return 0;
}
```

<br>

# References
---
- <https://www.youtube.com/watch?v=x0H--CL2tUI>
- <https://www.youtube.com/watch?v=WMiggUPst-Q>
- <https://heinleinsgame.tistory.com/7>
- <https://whilescape.tistory.com/entry/OpenGL-오픈지엘-데이터-관련-개념-정리1>