---
title: 레이캐스트 오버헤드 테스트
author: Rito15
date: 2021-02-19 16:18:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp, raycast, performance]
math: true
mermaid: true
---

# 조건
---
## 고정
  - 레이캐스트 시작점
  - 레이캐스트 방향
  - 반복 횟수 : 10만 회

## 변동
  - 레이캐스트 종류
  - 레이어마스크
  - 레이캐스트 거리
  - 레이캐스트 도형 크기(Sphere, Box)
  - 레이캐스트 히트 여부


# 결과
---

![image](https://user-images.githubusercontent.com/42164422/108470766-cb52de80-72cd-11eb-88f2-55af30973e97.png){:.normal}


# 결론
---
## 성능에 영향을 주는 것
  - 레이캐스트 종류
  - 레이캐스트 히트 여부

## 성능에 영향을 주지 않는 것
  - 레이어마스크
  - 레이캐스트 거리
  - 레이캐스트 도형 크기(Sphere, Box)

<br>

# 추가 - Rigidbody.SweepTest
---

## SweepTest ?
- 콜라이더 표면으로부터 지정한 방향으로 일정 거리 이내에 다른 콜라이더가 존재하는지 검사하는 것

## 검사 조건
- 검사 주체 콜라이더 : Sphere, Capsule, Box

  (검사 대상 콜라이더의 종류는 유의미한 영향을 주지 않음)

- 검사 대상 영역의 오브젝트 개수 : 100개

- 모든 검사에서 대상 검출 성공(단일 검사 : 결과 true, 다중 검사 : 결과 100개)

- 반복 횟수 : 각각 1만 회

<br>

## 결과

![image](https://user-images.githubusercontent.com/42164422/108606321-e07a5b00-73fc-11eb-8534-6391f9bbfd02.png){:.normal}

<br>

## 결론
- 검사를 위해 레이캐스트를 2~3개 이상 써야하는 경우 SweepTest로 대체할 수 있다면 이득