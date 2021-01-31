---
title: Popup UI Management System
author: Rito15
date: 2021-01-31 20:23:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp, ui, stack]
math: true
mermaid: true
---

# 목표
---
- 팝업 UI 관리 시스템 구현

<br>

# 게임의 UI
---
- 온라인 PC게임을 예로 들었을 때, 다양한 형태의 UI들이 존재한다.
- 화면 예시 : Smilegate RPG 'LostARK'

## 1. 전체화면 UI
  - 크기가 화면 전체에 해당하는 UI
  - 예 : 상점, 캐시 샵

![Screenshot_210131_210227](https://user-images.githubusercontent.com/42164422/106383242-395f6080-6408-11eb-9e7e-2667a6ef85bf.jpg)

## 2. 고정형 UI
  - 고정된 위치에 항상 존재하는 UI
  - 예 : 하단 바, 퀵슬롯, 미니맵, 채팅창

![image](https://user-images.githubusercontent.com/42164422/106383370-d28e7700-6408-11eb-8c0f-26fc538cbf64.png)

## 3. 추적형 UI
  - 게임 내 요소들(캐릭터, 몬스터, 건물 등)의 위치를 실시간으로 추적하여 따라다니는 UI
  - 예 : 체력 바, 이름, 말풍선

![image](https://user-images.githubusercontent.com/42164422/106383331-a246d880-6408-11eb-9c9b-919bbc8394da.png)

## 4. 안내형 UI
  - 화면 한켠에 잠시 나타났다가 사라지는 형태의 UI
  - 게임의 진행사항, 공지사항 등을 안내하는 용도로 주로 사용된다.

![image](https://user-images.githubusercontent.com/42164422/106383348-b8549900-6408-11eb-807f-8b02ad7d2d7e.png)

## 5. 팝업형 UI
  - 자유롭게 열고, 닫고, 움직일 수 있는 UI
  - 예 : 캐릭터 정보, 인벤토리, 스킬, 퀘스트 목록

![image](https://user-images.githubusercontent.com/42164422/106383290-77f51b00-6408-11eb-9040-c7905a2b7b66.png)

<br>

# 팝업형 UI
---
- 위에 소개한 UI들 중, 팝업형 UI를 관리하기 위한 방법으로 스택을 생각할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106383438-4c266500-6409-11eb-910a-0f920f463360.png)

![image](https://user-images.githubusercontent.com/42164422/106383444-56486380-6409-11eb-9b99-421a310ee6c0.png)

- 위의 경우들이라면 스택을 통해서 충분히 구현할 수 있으나, 아래와 같은 경우도 존재할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/106383565-29488080-640a-11eb-8b6d-8fa9ffc20ca9.png)

- 스택의 중간이나 하단에 위치한 UI를 선택하여, 해당 UI가 스택의 상단에 올라오고 다른 UI보다 앞쪽으로 보이게 되는 경우

- 해당 UI의 단축키를 누르거나 닫기 버튼을 눌러 스택의 중간이나 하단에 위치한 UI를 스택에서 제거하고 닫는 경우

- 이렇게 되면 스택으로는 위의 동작들을 구현할 수 없다.

- 대체 방안으로 가변 배열(C#에서는 List)을 생각해볼 수 있으나, 중간에서 요소를 제거할 경우 인덱스를 전부 재조정해야 하는 비효율성이 존재한다.

- 따라서 링크드리스트(Linked List)가 가장 적합하다고 생각하여, 링크드리스트를 통한 팝업형 UI 관리 시스템을 구현해보고자 한다.

<br>

# 구현
---
## 1. 팝업형 UI의 구성

![image](https://user-images.githubusercontent.com/42164422/106384032-56962e00-640c-11eb-9a30-75d20ab180dd.png)

- 팝업형 UI는 크게 3가지 요소로 구분될 수 있다.
  - 타이틀 바 : 해당 UI의 타이틀을 작성하며, 드래그 앤 드롭을 통해 UI를 옮길 수 있다.
  - 닫기 버튼 : 누를 경우 해당 UI를 닫는다.
  - 내용 : 해당 UI를 구성하는 내용물이 위치한다.

<br>
## 2. UI 생성

![image](https://user-images.githubusercontent.com/42164422/106385271-cc9d9380-6412-11eb-9d20-ccd28e724cc1.png)

- 이렇게 하이어라키를 구성하고,

![2021_0131_Inventory](https://user-images.githubusercontent.com/42164422/106384941-e8a03580-6410-11eb-9e6f-16dcfb47651c.gif)

- 다양한 크기에 유연하게 대응할 수 있도록 피벗과 앵커를 지정한다.

<br>
## 3. Popup UI 스크립트 작성

- 각각의 팝업 UI마다 컴포넌트로 넣어줄 스크립트를 작성한다.



// 작성 중...

## 4. Popup Header UI 스크립트 작성



// 작성 중...





<br>

# References
---
- 

# Source Code
---
- <https://github.com/rito15/UnityStudy2>

# Download
---
- 