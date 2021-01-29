---
title: OpenGL 공부 - 03
author: Rito15
date: 2021-01-29 22:07:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 버텍스, 버텍스 버퍼에 대한 이해

<br>

# 렌더링 파이프라인 요약
---
![image](https://user-images.githubusercontent.com/42164422/106298996-fb432f00-6297-11eb-80a8-41eeed261413.png)

### Vertex Shader
 - 입력 : 정점 목록
 - 정점들을 오브젝트 스페이스에서 MVP 변환을 통해 클립 스페이스까지 변환한다.

### Shape Assembly
 - 정점을 조립하여 렌더링을 할 수 있는 최소 단위(Primitive : 점, 선, 삼각형 등)로 만든다.

### Geometry Shader
 - 입력 : 프리미티브 목록
 - 프리미티브 당 한 번씩 수행한다.
 - 프리미티브를 없앨 수도, 더 만들 수도 있고 완전히 다른 프리미티브로 변환할 수도 있다.

### Rasterization
 - 입력 : 프리미티브 목록
 - 프리미티브를 최종 화면의 적절한 픽셀과 매핑하여, 프래그먼트 쉐이더에서 사용할 Fragment를 만든다.
 - 성능을 향상시키기 위해 뷰 프러스텀 밖의 Fragment를 폐기한다.

### Fragment Shader
 - 입력 : Fragment 목록
 - OpenGL의 모든 고급 효과들을 계산하는 단계
 - 화면에 렌더링할 모든 픽셀의 색상을 계산한다.

### Alpha Test, Alpha Blending
 - 뎁스와 스텐실을 체크
 - 알파 테스팅 : 알파값이 있으면 1, 없으면 0으로 판단하여 0인 픽셀 잘라내기
 - 알파 블렌딩 : 뎁스 버퍼를 이용해 깊이를 계산하여 모든 픽셀의 최종 색상 계산

<br>

# 내용
---
### Vertex
 - 3D 공간의 정점 좌표 데이터
 - float 배열

### NDC(Normalized Device Coordinates)
 - 모든 x, y, z 좌표가 -1.0 ~ 1.0 사이인 좌표
 - 정규화된 좌표를 사용함으로써, 좌표 계산과정을 줄일 수 있으며 화면 해상도 차이에 빠르게 대응할 수 있다.
 - 정점 쉐이더에서 4x4 Projection 행렬에 의해 직교투영(Orthographic Projection) 또는 원근 투영(Perspective Projection)을 통해 얻어지는 모든 좌표는 NDC 내로 들어온다.
 - 투영 행렬이 정의하는 Viewing Box는 절두체(Frustum)라고 하며, 지정한 범위에서 NDC로 변환하는 과정을 '투영한다'라고 한다.
 - NDC 좌표는 glViewport() 메소드를 통해 Viewport Transform을 거쳐 Screen-space Coordinates 좌표로 변환된다.
 - 스크린 좌표는 Fragment로 변환되어 Fragment Shader의 입력이 된다.

```cpp
float positions[6] = {
    -0.5f, -0.5f,
     0.0f,  0.5f,
     0.5f, -0.5f,
};
```

### Vertex Buffer
 - 정점들에 대한 정보를 갖고 있는 메모리 버퍼
 - 오브젝트(Vertex Buffer Object) 단위로 관리된다.

### VBO(Vertex Buffer Object)
 - OpenGL 객체 중 하나
 - 고유 ID를 가지고 있다. (OpenGL의 모든 오브젝트는 고유 ID를 가진다.)
 - OpenGL은 다양한 타입의 버퍼 객체를 갖고 있는데, VBO는 그 중 `GL_ARRAY_BUFFER`이다.
 - 많은 양의 정점들을 GPU 메모리 상에 저장할 수 있다.
 - CPU에서 GPU로 데이터를 전송하는 것은 비교적 느린데, VBO를 이용하면 비교적 빠르게 전송할 수 있다.

### 버퍼 ID 생성
```cpp
unsigned int buffer;
glGenBuffers(1, &buffer);
```
 - glGenBuffers() 메소드는 버퍼의 ID를 받아 해당 ID에 버퍼를 생성한다.
 - 파라미터 1 : 해당 ID에 생성할 버퍼 개수
 - 파라미터 2 : 버퍼를 생성할 ID

### 생성한 버퍼에 타입 바인딩
```cpp
glBindBuffer(GL_ARRAY_BUFFER, buffer);
```
 - glBindBuffer() 메소드는 버퍼 오브젝트에 타입을 바인딩한다.
 - 파라미터 2 : 바인딩할 버퍼의 종류
 - 파라미터 1 : 대상 버퍼 ID

### 미리 정의된 정점 데이터를 버퍼의 메모리에 복사
```cpp
glBufferData(GL_ARRAY_BUFFER, 6 * sizeof(float), positions, GL_STATIC_DRAW);
```
 - glBufferData() 메소드는 사용자가 정의한 데이터(지금의 경우에는 정점 데이터)를 현재 바인딩 버퍼에 복사한다.
 - 파라미터 1 : 데이터를 복사하여 집어넣을 버퍼의 타입
 - 파라미터 2 : 버퍼에 저장할 데이터 크기(바이트 단위), 주로 sizeof 사용
 - 파라미터 3 : 버퍼에 저장할 실제 데이터
 - 파라미터 4 : GPU가 주어진 데이터를 관리하는 방법
   - GL_STATIC_DRAW : 거의 변하지 않는 데이터
   - GL_DYNAMIC_DRAW : 자주 변경되는 데이터
   - GL_STREAM_DRAW : 그려질 때마다 변경되는 데이터
   - DYNAMIC, STREAM으로 전달할 경우 GPU는 빠르게 사용할 수 있는 메모리에 데이터를 저장한다.

### 버퍼의 데이터를 이용해 그려주기
```cpp
glDrawArrays(GL_TRIANGLES, 0, 3);
```
 - glDrawArrays() 메소드는 배열 데이터로부터 프리미티브를 렌더링한다. 드로우 콜 중 하나
 - 파라미터 1 : 렌더링할 프리미티브의 종류
 - 파라미터 2 : 배열에서 참조할 데이터의 시작 인덱스
 - 파라미터 3 : 렌더링할 인덱스의 개수(지금은 인덱스 2개씩을 모아 3개의 정점을 구성하므로 3)

- 하지만 아직 드로우콜만 했을 뿐, 그려지지는 않는다.

<br>

# Current Source Code

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

    // 정점 데이터
    float positions[6] = {
        -0.5f, -0.5f,
         0.0f,  0.5f,
         0.5f, -0.5f,
    };

    // VBO(Vertex Buffer Object)
    unsigned int buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, 6 * sizeof(float), positions, GL_STATIC_DRAW);

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
- <https://www.youtube.com/playlist?list=PLlrATfBNZ98foTJPJ_Ev03o2oq3-GGOS2>
- <https://heinleinsgame.tistory.com/7>
- <https://lalyns.tistory.com/14>
