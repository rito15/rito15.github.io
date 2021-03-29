---
title: Static Readonly vs. Const
author: Rito15
date: 2021-03-30 00:50:00 +09:00
categories: [Memo, Csharp Memo]
tags: [csharp]
math: true
mermaid: true
---

# 공통점
---
- 런타임에 값을 변경할 수 없다.

<br>

# 차이점
---

## **Static Readonly**

- 필드 선언문 또는 정적 생성자에서만 값을 초기화할 수 있다.

- 값을 초기화하지 않으면 해당 타입의 기본값으로 초기화된다.

- 런타임 초기에 값이 고정된다.

- 값이 정해지면 변하지 않지만, 결국 변수이기 때문에 참조 오버헤드가 발생한다.

<br>

## **Const**

- 필드 선언문에서만 값을 초기화할 수 있다.

- 값을 초기화해야만 한다.

- 컴파일 타임에 값이 고정된다.

- 리터럴처럼 사용될 수 있다.(예 : switch문의 case 값)

- 어셈블리가 나뉘었을 때(const 필드가 존재하는 `provider.dll`, 이를 참조하는 `consumer.dll`),<br>
  `provider`에서의 const 필드 값이 변경되고 재컴파일되어도 `consumer`에서 참조하는 필드 값은 변경되지 않는다.<br>
  이는 `consumer`의 컴파일 타임에 이미 해당 값이 고정되었기 때문이며, 변경사항을 적용하려면 `consumer` 역시 다시 컴파일해야만 한다.

<br>

# References
---
- <https://stackoverflow.com/questions/755685/static-readonly-vs-const/755693>
- <https://www.stum.de/2009/01/14/const-strings-a-very-convenient-way-to-shoot-yourself-in-the-foot/>
