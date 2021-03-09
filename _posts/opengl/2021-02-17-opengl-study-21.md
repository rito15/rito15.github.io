---
title: OpenGL 공부 - 21 - Material Class
author: Rito15
date: 2021-02-17 22:43:00 +09:00
categories: [OpenGL, OpenGL Study]
tags: [graphics, opengl]
math: true
mermaid: true
---

# 목표
---
- Material 클래스 작성

<br>

# 공부 내용
---

- 오브젝트에 적용할 색상과 텍스쳐들을 Material 클래스로 래핑하여 쉐이더에 전달한다.

## Fragment 쉐이더 수정

```glsl
#version 440

#define saturate(x) clamp(x, 0., 1.)

struct Material
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    sampler2D diffuseMap;
};

in vec3 vs_position;
in vec3 vs_color;
in vec2 vs_texcoord;
in vec3 vs_normal;

out vec4 fs_color;

// ====================== Uniforms =========================
uniform Material material;
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
    vec3 worldHalf = normalize(worldLight + worldView);

    // ====================== Lighting ==============================
    // Ambient Light
    vec3 ambient = vec3(1.);

    // Diffuse Light
    float NdL = dot(worldNormal, worldLight);
    float diffuse = saturate(NdL);

    // Specular Light - Blinn Phong
    float NdH = dot(worldNormal, worldHalf);
    float specBpPower = 500.;
    float specBP = pow(saturate(NdH), specBpPower);

    // Rim Light
    //float NdV = dot(worldNormal, worldView);
    //float rimPower = 1.;
    //float rim = pow(1. - saturate(NdV), rimPower) * 2.;
    
    // ====================== Textures ==============================
    vec3 diffMapCol = texture(material.diffuseMap, vs_texcoord).xyz;
    vec3 diffMapMask = step(vec3(0.01), diffMapCol);
    vec3 wallMapCol = texture(wallTex, vs_texcoord).xyz;
    
    // ====================== Colors ================================
    vec3 ambientCol = material.ambient;
    vec3 diffCol = mix(wallMapCol, diffMapCol * material.diffuse, diffMapMask);
    vec3 specCol = material.specular;
    vec3 lightCol = vec3(1., 1., 1.);
    
    // ====================== Final Colors ==========================
    ambientCol = ambient * ambientCol;
    diffCol = diffuse * diffCol;
    specCol = specBP * specCol;


    vec3 col = (diffCol + specCol) * lightCol + ambientCol;

    fs_color = vec4(col, 1.);
}
```

## Material 클래스 작성

```cpp
#pragma once

class Material
{
private:
    glm::vec3 ambient;
    glm::vec3 diffuse;
    glm::vec3 specular;
    GLint diffuseMapID;

public:
    Material(const glm::vec3& ambient, const glm::vec3& diffuse, const glm::vec3& specular,
        Texture& diffuseMap)
    {
        this->ambient = ambient;
        this->diffuse = diffuse;
        this->specular = specular;
        this->diffuseMapID = diffuseMap.GetID();
    }
    ~Material() {}

    // 쉐이더에 전달
    void SendToShader(Shader& shader)
    {
        shader.SetVec3f("material.ambient", this->ambient);
        shader.SetVec3f("material.diffuse", this->diffuse);
        shader.SetVec3f("material.specular", this->specular);
        shader.SetTexture("material.diffuseMap", this->diffuseMapID);
    }
};
```

## main.cpp 수정

```cpp
Texture texture0("Images/MoonCat.png");
Texture texture1("Images/Wall.png");

// 마테리얼 선언
Material material(
    glm::vec3(0.1f), glm::vec3(1.0f, 1.0f, 1.0f), glm::vec3(1.0f, 0.0f, 1.0f),
    texture0
);

// 쉐이더에 마테리얼 전달
material.SendToShader(shader);
```

<br>

# 실행 결과
---

![2021_0218_Opengl](https://user-images.githubusercontent.com/42164422/108246171-79f30400-7194-11eb-88b8-90577c82299c.gif){:.normal}

<br>

# Source Code
---

- [2021_0217_OpenGL_Study_21.zip](https://github.com/rito15/Images/files/5997649/2021_0217_OpenGL_Study_21.zip)

<br>

# References
---
- <https://www.youtube.com/watch?v=7mDSWwS9cFs>
- <https://heinleinsgame.tistory.com/16>