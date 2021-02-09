---
title: OpenGL 공부 - 10 - New Beginning
author: Rito15
date: 2021-02-06 15:20:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 다른 강좌로 새롭게 시작
- GLM, SOIL2 설치

<br>

# 새로운 시작
---

새로운 강좌를 선택한 김에 기존의 파일들을 날려버리고 구조 변경

<br>

# 공부 내용
---

## GLM ?
- OpenGL Mathematics, 수학 라이브러리.
- <http://glm.g-truc.net/0.9.8/index.html> 에서 받을 수 있다.
- 이제는 익숙하게 Dependencies 폴더에 넣고 GLM 포함경로 설정

- libs.h에 아래처럼 추가

```cpp
#include <GLM/glm.hpp>
#include <GLM/vec2.hpp>
#include <GLM/vec3.hpp>
#include <GLM/vec4.hpp>
#include <GLM/mat4x4.hpp>
#include <GLM/gtc/matrix_transform.hpp>
#include <GLM/gtc/type_ptr.hpp>
```
<br>
## SOIL2 ?
- Simple OpenGL Image Library. 이미지 파일을 처리해주는 라이브러리
- <https://bitbucket.org/SpartanJ/soil2/downloads/> 에서 받을 수 있지는..않고
- <https://github.com/SpartanJ/soil2> 여기로 가야 받을 수 있다.

<br>
## Premake
- SOIL2를 사용하기 위해 Premake를 다운받는다.
- <https://premake.github.io/download.html>
- premake[4,5].lua 파일이 있는 SOIL2-release-1.20 디렉토리에 premake[4,5].exe 응용프로그램을 집어넣고 cmd에서 해당 경로로 들어간다.
- premake5 버전을 받았고, vs2019를 사용하고 있으므로 `premake5 vs2019`라고 타이핑하면 SOIL2 솔루션이 `make` 폴더에 생긴다.
- soil2-static-lib를 누르고 [release]로 설정한 뒤 빌드한다.
- 그리고 다른 OpenGL 라이브러리들과 마찬가지로, 생성된 .lib 파일은 Dependency/SOIL2/lib에 넣어주고, 헤더와 소스파일들은 include에 넣어준다.
- 역시 라이브러리와 헤더는 각각 링크와 포함 경로로, 그리고 링커의 입력에 soil2.lib를 추가해준다.

<br>
## OpenGL 기본 세팅

- GLFW, GLEW 세팅과 메인 루프를 완성하고, 검은 화면을 띄울 정도까지만 마무리

<br>

# Current Source Codes
---

## libs.h

```cpp
#pragma once

#include <iostream>

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

## CustomFunctions.hpp

```cpp
#pragma once

void framebufferResizeCallback(GLFWwindow* window, int fbW, int fbH)
{
	glViewport(0, 0, fbW, fbH);
}
```

## main.cpp

```cpp
#include "libs.h"
#include "CustomFunctions.hpp"

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

    glfwSetFramebufferSizeCallback(window, framebufferResizeCallback);
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
    glfwTerminate();
    return 0;
}
```

# References
---
- <https://www.youtube.com/watch?v=15JS0kvHSSA>
- <https://www.youtube.com/watch?v=Bcs56Mm-FJY>
- <https://www.youtube.com/watch?v=bxov_ZhJoG4>
- <https://www.youtube.com/watch?v=iYZA1k8IKgM>