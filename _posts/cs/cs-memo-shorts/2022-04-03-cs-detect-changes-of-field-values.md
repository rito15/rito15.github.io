---
title: C# Shorts - 필드의 값 변화 감지하기
author: Rito15
date: 2022-04-03 15:40:00 +09:00
categories: [C#, C# Memo - Shorts]
tags: [csharp]
math: true
mermaid: true
---

# 소스 코드
---

```cs
private int _score; // 필요하다면 _score = 123; 꼴로 초깃값 직접 설정

public int Score
{
    // Getter에서는 단순히 대상 필드 값만 리턴
    get
    {
        return _score;
    }
    // Setter 블록
    set
    {
        // 저장된 값(_score), 현재 값(value)을 비교하여 변화 감지
        if(_score != value)
        {
            Console.WriteLine($"Value Changed : [{_score}] -> [{value}]");
        }

        // 새로운 값 할당
        _score = value;
    }
}
```

<br>


# 설명
---

필드와 프로퍼티를 한 쌍으로 작성한다.

프로퍼티를 사용하면 필드에 값이 초기화될 때 `Setter`를 통해 일련의 로직을 추가할 수 있다.

이 때 새롭게 초기화되는 값은 `Setter` 내에서 `value`라는 키워드를 통해 참조할 수 있다.

이를 활용하여 필드와 `value`의 값이 다른 경우,

즉 값이 변화하는 순간을 감지하여 반응형 프로그래밍을 구현할 수 있다.

<br>

