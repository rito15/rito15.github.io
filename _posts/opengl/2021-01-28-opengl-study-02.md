---
title: OpenGL 공부 - 02 - 초기 세팅
author: Rito15
date: 2021-01-28 22:09:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- GLEW 설치 및 적용

<br>

# GLEW 설치
---
- GLEW : OpenGL Extension Wrangler Library
- <http://glew.sourceforge.net>
- Binary 다운로드

- 프로젝트의 Dependency 폴더 내로 GLEW 폴더 복사
  - glew-2.1.0 폴더를 통째로 가져와서 GLEW로 이름을 변경해준다.

![image](https://user-images.githubusercontent.com/42164422/106153141-90bfbf80-61c1-11eb-9c28-c451639e6a89.png)

- GLEW/doc/index.html - Usage 탭에 들어가면 초기 사용법이 있다.

<br>

# 참조 추가
---

- 헤더
  - 프로젝트 속성 - C/C++ - 일반 - 추가 포함 디렉터리
  - $(SolutionDir)OpenGL_Study\Dependencies\GLEW\include
  - 어제는 분명 C/C++ 탭이 없었는데..? 생겼다. 어쨌든 VC++ 디렉터리의 포함 디렉터리에 적는 것과 동일하므로 둘 중 어디에 적든 상관 없지만, 통일성을 위해 어제 VC++ include에 적었던 GLFW로 여기로 옮겨서 같이 적어준다.
  - 결과 :

```
$(SolutionDir)OpenGL_Study\Dependencies\GLFW\include;$(SolutionDir)OpenGL_Study\Dependencies\GLEW\include
```

- 정적 라이브러리
  - 프로젝트 속성 - 링커 - 일반 - 추가 라이브러리 디렉터리
  - $(SolutionDir)OpenGL_Study\Dependencies\GLEW\lib\Release\Win32
  - 결과 :

```
$(SolutionDir)OpenGL_Study\Dependencies\GLFW\lib-vc2019;$(SolutionDir)OpenGL_Study\Dependencies\GLEW\lib\Release\Win32
```

- 입력
  - 프로젝트 속성 - 링커 - 입력 - 추가 종속성
  - glew32s.lib
  - 결과 : 

```
glew32s.lib;glfw3.lib;opengl32.lib;User32.lib;Gdi32.lib;Shell32.lib
```

<br>

# 테스트 코드 작성
---

- 소스 상단 include 작성

![image](https://user-images.githubusercontent.com/42164422/106156672-2c9efa80-61c5-11eb-8afb-75b884b1e13b.png)

- 이렇게 glew가 glfw 아래에 include되면

![image](https://user-images.githubusercontent.com/42164422/106156870-6839c480-61c5-11eb-9cdd-61087eeec99e.png)

- 이런식으로 격렬히 거부하기 때문에, glew를 glfw 위쪽에 include 해준다.

- 그리고 메인에서 `glfwInit()` 하단에 `glewInit();`을 작성해주면

![image](https://user-images.githubusercontent.com/42164422/106158453-17c36680-61c7-11eb-97e2-3b5b0323ddd1.png)

- 자연스럽게 또 한번 거절당한다.
- 그래서 glew.h 헤더로 찾아가 glewInit을 들여다보면

![image](https://user-images.githubusercontent.com/42164422/106158770-72f55900-61c7-11eb-94b3-f20b9a0f7a26.png)

- 요걸 확인해볼 수 있다.
- 그리고 이번에는 GLEWAPI의 정의로 한번 타고 들어가보면

![image](https://user-images.githubusercontent.com/42164422/106159108-ccf61e80-61c7-11eb-8427-ab2c4e482a1b.png)

- 이런 아이가 반겨준다.
- 일단 지금 동적 라이브러리가 아니라 정적 라이브러리를 참조하고 있다.
- 그런데 GLEW_STATIC도 GLEW_BUILD도 선언해주지 않으니 GLEWAPI 매크로는 extern __declspec(dllimport)로 뿅하고 바뀌어서 dllimport를 기대하고 있는데, 동적 라이브러리를 참조하지 않으니 결국 참조가 없는 상황이다.

- 해결하려면 소스코드 최상단에 `#define GLEW_STATIC` 이라고 적어줘도 되지만,
- 프로젝트 속성 - C/C++ - 전처리기 - 전처리기 정의에 GLEW_STATIC를 추가해준다.
<br>
- 그리고 `glfwMakeContextCurrent(window);` 이후에 `glewInit();`을 넣어준다.
  - GLEW 문서의 Usage를 보면
```
First you need to create a valid OpenGL rendering context
and call glewInit() to initialize the extension entry points.
```
라고 써있기 때문이다. 이렇게 안하면 glewInit()의 결과가 에러를 뱉는다.

- 이제 간단히 `glGetString(GL_VERSION)`을 출력해서 버전을 체크해보고 마무리.

![image](https://user-images.githubusercontent.com/42164422/106168995-3b3fde80-61d2-11eb-861f-804114f245aa.png)

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
