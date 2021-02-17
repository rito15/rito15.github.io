---
title: OpenGL 공부 - 20 - Texture Class
author: Rito15
date: 2021-02-16 22:22:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- 텍스쳐 클래스화하기

<br>

# 텍스쳐 클래스 작성
---

기존에 메소드화하여 사용하던 텍스쳐를 클래스화하려고 한다.

function.hpp 파일에 `LoadTextureImage()` 메소드에 작성했던 내용을 클래스로 옮겨 작성한다.

```cpp
class Texture
{
private:
    GLuint id;
    GLenum type;
    int width;
    int height;

public:
    Texture(const char* fileName, GLenum type);
    ~Texture();

    inline const GLuint& GetID();
    void Bind(const GLint& index);
    void Release();
    void loadFromFile(const char* fileDir);
};
```

그래서 예전에는

```cpp
GLuint texture0 = LoadTextureImage("Images/MoonCat.png");
GLuint texture1 = LoadTextureImage("Images/Wall.png");
```

이렇게 메소드로 사용하던 부분을

```cpp
Texture texture0("Images/MoonCat.png");
Texture texture1("Images/Wall.png");
```

이렇게 객체로 변경하고,

메인 루프의

```cpp
glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, texture0);

glActiveTexture(GL_TEXTURE1);
glBindTexture(GL_TEXTURE_2D, texture1);
```

이 부분을

```cpp
texture0.Bind(0);
texture1.Bind(1);
```

요로코롬 바꾼다.

<br>

# Source Code
---

- [2021_0217_OpenGL_Study_20.zip](https://github.com/rito15/Images/files/5990171/2021_0217_OpenGL_Study_20.zip)

<br>

# References
---
- <https://www.youtube.com/watch?v=4tdy1izUv_Y>
