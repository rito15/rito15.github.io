---
title: Singleton MonoBehavior
author: Rito15
date: 2020-07-08 15:30:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin]
math: true
mermaid: true
---

# Note
---
- 단순한 상속만으로 모노비헤이비어 클래스를 싱글톤으로 만들어주는 클래스입니다.

# How To Use
---
- 클래스명이 Apple일 때 예시로, 다음과 같이 상속받아 사용합니다.

```cs
public class Apple : Rito.SingletonMonoBehavior<Apple>
{
    // Awake 메소드는 반드시 이렇게 작성해야 합니다.
    protected override void Awake()
    {
        base.Awake();

        // .. 기타 코드
    }
}
```

# Preview
---
- 게임 시작 시 싱글톤 오브젝트의 존재와 게임오브젝트명을 콘솔 로그를 통해 알려줍니다.
- 싱글톤 컴포넌트가 두 개 이상 존재할 경우 자동으로 파괴하며, 콘솔 로그를 통해 알려줍니다.

![image](https://user-images.githubusercontent.com/42164422/105669964-9b5d2900-5f23-11eb-89c1-346ff0863840.png)

# Source Code
---
- <https://github.com/rito15/Unity_Toys>

# Download
---
- [SingletonMonoBehavior.zip](https://github.com/rito15/Images/files/5864626/SingletonMonoBehavior.zip)