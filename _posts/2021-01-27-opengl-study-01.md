---
title: OpenGL 공부 - 01
author: Rito15
date: 2021-01-28 00:10:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 동기
---
- 그동안 유니티를 공부하면서 필요에 따라 쉐이더나 렌더링 파이프라인에 대한 단편적인 지식들을 익혀왔지만, DirectX나 OpenGL같은 그래픽스 라이브러리를 한 번쯤은 제대로 공부하는 게 나을 것이라는 생각이 들었다.

<br>

# 목표
---
- OpenGL의 완전 기초부터 쉐이더 적용까지 모든 과정 공부
- 그래픽스에 대한 전반적인 지식 습득

<br>

# OpenGL?
---
- OpenGL 자체는 API가 아닌, 각종 OpenGL 라이브러리를 개발하기 위해 Khronos Group이 개발 및 유지 관리하는 설명서이다.

- OpenGL은 각 함수의 출력과 수행 방법을 정의한다.

- 실제로 OpenGL 라이브러리를 개발하는 사람들은 일반적으로 그래픽카드 제조업체이다.

- OpenGL은 기본적으로 C언어로 작성되었으며, 각종 확장 라이브러리는 C++로 작성된 경우가 많다.

<br>

# OpenGL 라이브러리 종류
---
- GL(Graphics Library)
  - 저수준의 기본 그래픽스 라이브러리

- GLU(OpenGL Utility Library)
  - GL을 보완하여, 고수준의 함수와 기능들을 제공하는 라이브러리

- GLUT(OpenGL Utility Toolkit)
  - 다양한 플랫폼에서 사용할 수 있는 보조 라이브러리. 1998년에 버려졌다.

- FreeGLUT
  - GLUT는 라이센스 때문에 더이상 개발이 불가능하여 사람들이 자유롭게 개발할 수 있도록 새롭게 작성된 라이브러리

- SDL(Simple Directmedia Layer)
  - OpenGL, Direct3D를 통해 오디오, 키보드, 마우스, 그래픽 하드웨어에 대한 저수준 접근이 가능하도록 설계된 크로스플랫폼 개발 라이브러리
  - Windows, Linux, Mac OS X, Android, iOS 등 다양한 플랫폼을 지원한다.
  - 무료로 이용이 가능하지만, 기능이 너무 많아 프로그램이 무겁다.

- SFML(Simple and Fast Multimedia Library)
  - 다양한 멀티미디어에 걸쳐 API를 제공하기 위해 설계된 크로스플랫폼 개발 라이브러리
  - System, Window, Graphics, Audio, Network 이렇게 5가지 모듈로 구성되어 있다.
  - C, C++, Ruby, Java, Go, Pthon, Rust 등 다양한 언어를 지원한다.

- GLFW(Graphics Library Framework)
  - OpenGL과 함께 사용하기 위한 경량 유틸리티 라이브러리
  - OpenGL 환경에서 윈도우를 생성하고 마우스, 키보드, 조이스틱 등의 입력을 받아 처리할 수 있다.
  - C언어로 작성되었지만, Ada, C++, C#, Go, Java, Ruby, Rust 등 다양한 언어를 지원한다.

- GLEW(OpenGL Extension Wrangler Library)
  - 크로스플랫폼 C/C++ 확장 라이브러리
  - 하나의 헤더파일만 추가하면 사용할 수 있게 작성되었으며, 더 많은 기능들을 제공한다.
  - 쉐이더 프로그램을 작성할 때 주로 사용된다.

- GLM(OpenGL Mathematics)
  - GLSL 기반 그래픽 소프트웨어에 사용 가능한 C++ 수학 라이브러리

<br>

# GLFW 설치, 프로젝트 준비
---
- <https://www.glfw.org/> 에서 최신버전을 받을 수 있다.
- 그리고 이미 컴파일된 라이브러리 파일들을 <https://www.glfw.org/download.html> 에서 곧바로 받을 수 있으므로 이것을 사용하기로 한다.
- 32bit와 64bit로 나뉘어 있는데, VS에서 32bit로 실행할 것이므로 32bit로 받아온다.

- C++ 프로젝트 생성

![image](https://user-images.githubusercontent.com/42164422/106020566-437f1780-6107-11eb-919b-ae61f265fdbf.png)

- 필요한 라이브러리 파일들을 프로젝트 폴더로 가져오기

![image](https://user-images.githubusercontent.com/42164422/106020625-5396f700-6107-11eb-81af-092a6a1d99b8.png)

- 프로젝트 속성 설정 : 모든 플랫폼에 대해 설정하는 것이 좋다.

![image](https://user-images.githubusercontent.com/42164422/106022424-29463900-6109-11eb-9316-2aae3e549729.png)

![image](https://user-images.githubusercontent.com/42164422/106023330-0c5e3580-610a-11eb-9283-03ddcc22c095.png)

![image](https://user-images.githubusercontent.com/42164422/106023375-16803400-610a-11eb-919f-25c288b20ad4.png)

- 예제 코드를 통해 바인딩 확인
  - 예제 코드 : <https://www.glfw.org/documentation.html>

![image](https://user-images.githubusercontent.com/42164422/106023474-2dbf2180-610a-11eb-9612-78e3b10b23a6.png)

- 빌드(F7) 시도 후 발생하는 무수한 에러는

![image](https://user-images.githubusercontent.com/42164422/106025513-27ca4000-610c-11eb-9eb6-61cc56f338d6.png)

- 이렇게 해결한다.

![image](https://user-images.githubusercontent.com/42164422/106025642-4b8d8600-610c-11eb-8241-654f06dcb49c.png)

- 그리고 빌드 시, 유서깊은 Hello World 창을 만날 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106025780-6a8c1800-610c-11eb-90ae-dc83ecb0a789.png)

- 이제 간단한 삼각형을 그려보기 위해 glClear( .. ); 코드 하단에 다음과 같이 추가하고 실행한다.

```cpp
glBegin(GL_TRIANGLES);
glVertex2f(-0.5f, -0.5f); // Bottom Left
glVertex2f( 0.0f,  0.5f); // Top
glVertex2f( 0.5f, -0.5f); // Bottom Right
glEnd();
```

![image](https://user-images.githubusercontent.com/42164422/106026558-509f0500-610d-11eb-8e49-ab75f81f4c57.png)

- 뷰포트 좌표는 0.0 ~ 1.0 이라고 어디선가 주워들은 지식이 머릿속에 있는데.. 이건 뷰포트가 아닌가보다.

<br>

# Current Source Code
```cpp
#include <GLFW/glfw3.h>

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

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);

        glBegin(GL_TRIANGLES);
        glVertex2f(-0.5f, -0.5f); // Bottom Left
        glVertex2f(0.0f, 0.5f); // Top
        glVertex2f(0.5f, -0.5f); // Bottom Right
        glEnd();

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
- <https://www.youtube.com/playlist?list=PLlrATfBNZ98foTJPJ_Ev03o2oq3-GGOS2>
- <https://heinleinsgame.tistory.com/tag/OpenGL>
- <https://learnopengl.com/>

<br>

# Documents, APIs
---
- <http://docs.gl/>
- <http://glew.sourceforge.net/>