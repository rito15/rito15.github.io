---
title: OpenGL 공부 - 19 - Shader, Transform Class
author: Rito15
date: 2021-02-15 15:30:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 쉐이더, 트랜스폼 클래스화하기

<br>

# 1. 쉐이더의 클래스화
---

## shader.hpp 작성

shader.hpp 파일에 Shader 클래스를 작성한다.

기존에 functions.hpp와 main.cpp에서 사용하던 쉐이더 부분을 모두 Shader 클래스로 옮겨준다.

```cpp
// shader.hpp

class Shader
{
private:
    GLuint id;

    GLuint CompileShader(const GLenum& shaderType, const char* fileDir);
    void LinkProgram(const GLuint& vertexShader, const GLuint& fragmentShader, const GLuint& geometryShader);

public:
    Shader(const char* vertexSource, const char* fragmentSource, const char* geometrySource = "");
    ~Shader();

    bool IsValid();
    void Use();
    void Release();
    void SetInt(const GLchar* name, const GLint& value);
    void SetTexture(const GLchar* name, const GLint& textureID);
    void SetFloat(const GLchar* name, const GLfloat& value);
    void SetVec2f(const GLchar* name, const glm::fvec2& value);
    void SetVec3f(const GLchar* name, const glm::fvec3& value);
    void SetVec4f(const GLchar* name, const glm::fvec4& value);
    void SetMat3fv(const GLchar* name, const glm::mat3& value, const GLboolean& transpose = GL_FALSE);
    void SetMat4fv(const GLchar* name, const glm::mat4& value, const GLboolean& transpose = GL_FALSE);
}
```

- 구현부는 생략
- 강좌영상에서 보면 모든 Set 메소드에서 glUseProgram()을 두 번씩이나 호출하고 있는데, 불필요한 메소드 콜은 줄이는 게 좋지 않을까 하고 고민하다가 편의성을 조금 잡기 위해

```cpp
glUseProgram(this->id);
// uniform method call
glUseProgram(0);
```

에서

```cpp
glUseProgram(this->id);
// uniform method call
```

정도로 타협을 봤다.

솔직히 glUseProgram(0);을 매번 호출해주는 것은 실수를 방지하기 위함일텐데,

어차피 glUseProgram(id)를 항상 해주는 정도로도 충분하다고 생각한다.

그리고 렌더 루프 끝날 때 어차피 use(0) 호출해준다.

어느샌가 게임 루프 내에서의 성능 낭비에 대해 민감해진 것 같다.

<br>

## main.cpp 쉐이더 코드 수정

기존의 쉐이더 관련 코드를 모두 수정해준다.

```cpp
int main()
{
    // ...

    // Shader Init
    Shader shader("vertex_core.glsl", "fragment_core.glsl");
    if (!shader.IsValid())
    {
        glfwTerminate();
    }

    // ...

    // 1. Textures
    shader.SetTexture("catTex", 0);
    shader.SetTexture("wallTex", 1);

    // 2. Matrices
    shader.SetMat4fv("ModelMatrix", modelMatrix);
    shader.SetMat4fv("ViewMatrix", viewMatrix);
    shader.SetMat4fv("ProjectionMatrix", projectionMatrix);

    // 3. Light Pos
    shader.SetVec3f("shaderProgram", lightPos0);

    // 4. Cam Pos
    shader.SetVec3f("cameraPos", camPos);

    shader.Release();
}
```

루프 내의 모든 유니폼 호출도 동일하게 변경해준다.

그리고 실행해본 결과, 기존과 동일하게 실행된다.

<br>

# 2. 트랜스폼 클래스화
---

쉐이더를 클래스화 하고 보니, 

```cpp
// 트랜스폼 변경사항 적용
modelMatrix = glm::mat4(1.0f);
modelMatrix = glm::translate(modelMatrix, position);
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::scale(modelMatrix, scale);

shader.SetMat4fv("ModelMatrix", modelMatrix);
```

메인 루프 내의 위 부분이 눈에 밟혔다.

그래서 유니티엔진의 Transform 처럼 클래스화를 해주려고 한다.

```cpp
// transform.hpp

#pragma once

class Transform
{
private:
    glm::mat4 modelMatrix;
    glm::vec3 position;
    glm::vec3 rotation; // Euler Angles
    glm::vec3 scale;

    void UpdateModelMatrix()
    {
        modelMatrix = glm::mat4(1.0f);
        modelMatrix = glm::translate(modelMatrix, this->position);
        modelMatrix = glm::rotate(modelMatrix, glm::radians(this->rotation.x), glm::vec3(1.f, 0.f, 0.f));
        modelMatrix = glm::rotate(modelMatrix, glm::radians(this->rotation.y), glm::vec3(0.f, 1.f, 0.f));
        modelMatrix = glm::rotate(modelMatrix, glm::radians(this->rotation.z), glm::vec3(0.f, 0.f, 1.f));
        modelMatrix = glm::scale(modelMatrix, this->scale);
    }

public:
    Transform(
        const glm::vec3& position = glm::vec3(0.0f),
        const glm::vec3& rotation = glm::vec3(0.0f),
        const glm::vec3& scale = glm::vec3(1.0f)
    );

    glm::mat4 GetModelMatrix();
    glm::vec3 GetPosition();
    glm::vec3 GetRotation();
    glm::vec3 GetScale();

    void SetPosition(const glm::vec3& position);
    void SetRotation(const glm::vec3& rotation);
    void SetRotationX(const float& value);
    void SetRotationY(const float& value);
    void SetRotationZ(const float& value);
    void SetScale(const glm::vec3& scale);

    void Translate(const glm::vec3& value);
    void Rotate(const glm::vec3& value);
    void RotateX(const float& degree);
    void RotateY(const float& degree);
    void RotateZ(const float& degree);
    void AddScale(const glm::vec3& value);
    void MultiplyScale(const glm::vec3& value);
};
```

트랜스폼의 변경을 발생시키는 모든 메소드에서 UpdateModelMatrix()를 호출하는 방식으로 작성하였다.

그리고 이제 main.cpp를 수정한다.

```cpp
glm::vec3 position(0.0f, 0.0f, 0.0f);
glm::vec3 rotation(0.0f, 0.0f, 0.0f);
glm::vec3 scale(1.0f, 1.0f, 1.0f);
```

이런 부분은 단순하게

```cpp
Transform transform;
```

이렇게 변경시킬 수 있다.

입력을 받아 처리하는 함수에서도 모델 행렬을 받는 것이 아니라 Transform을 받아 처리하도록 한다.

그래서 기존의 메인 루프에서

```cpp
UpdateTransformByInputs(window, position, rotation, scale, 0.04f, 5.0f, 0.04f);

modelMatrix = glm::mat4(1.0f);
modelMatrix = glm::translate(modelMatrix, position);
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.x), glm::vec3(1.f, 0.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.y), glm::vec3(0.f, 1.f, 0.f));
modelMatrix = glm::rotate(modelMatrix, glm::radians(rotation.z), glm::vec3(0.f, 0.f, 1.f));
modelMatrix = glm::scale(modelMatrix, scale);

shader.SetMat4fv("ModelMatrix", modelMatrix);
```

이렇게 처리하던 부분도

```cpp
UpdateTransformByInputs(window, transform, 0.04f, 5.0f, 0.04f);
shader.SetMat4fv("ModelMatrix", transform.GetModelMatrix());
```

이렇게 간단히 바꿀 수 있다.

<br>

# Current Source Codes
---

- [2021_0215_OpenGL_Study_19.zip](https://github.com/rito15/Images/files/5980503/2021_0215_OpenGL_Study_19.zip)

<br>

# References
---
- <https://www.youtube.com/watch?v=3w9TuAkxhc8>
