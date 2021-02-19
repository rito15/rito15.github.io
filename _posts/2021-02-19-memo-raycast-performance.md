---
title: 레이캐스트 성능 체크
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