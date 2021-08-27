---
title: Animator Event Controller(애니메이터 이벤트 관리 컴포넌트)
author: Rito15
date: 2021-07-17 15:15:00 +09:00
categories: [Unity, Unity Editor Utilities]
tags: [unity, editor, csharp, utility]
math: true
mermaid: true
---

# Summary
---
- 애니메이터 내의 각 애니메이션에 대한 이벤트를 생성, 관리할 수 있는 컴포넌트

- 애니메이션의 프레임마다 이벤트를 추가할 수 있습니다.

- 플레이모드의 변경 사항은 플레이모드가 종료되어도 유지됩니다.

- 테스트 버전 : `2018.3.14f1`, `2019.4.9f1`, `2020.3.14f1`

<br>



# Usage Example
---

- 캐릭터가 칼을 휘두르는 순간에 검기 이펙트 생성하기

- 캐릭터가 걸을 때, 발이 땅에 닿는 순간마다 발소리 재생하기

<br>



# Preview
---

![2021_0717_AnimatorEventController_Demo](https://user-images.githubusercontent.com/42164422/126031259-8b185bad-ca67-4364-acd0-09893531e0c4.gif)

![image](https://user-images.githubusercontent.com/42164422/126031210-a72f06a4-a5de-470e-806d-ecfcc41cf698.png)

![image](https://user-images.githubusercontent.com/42164422/126031285-7ba0d0ed-dff0-475b-8090-937f2a0f33ba.png)

<br>



# 0. Download & Import
---
- [Animator Event Controller.unitypackage](https://github.com/rito15/Unity-Useful-Editor-Assets/releases/download/1.01/Animator-Event-Controller.unitypackage)

- 첨부 파일을 다운로드하고, 유니티 프로젝트가 켜져 있는 상태에서 실행합니다.

- 임포트 창이 나타나면 `Import` 버튼을 클릭하여 프로젝트에 임포트합니다.

<br>



# 1. Animator 컴포넌트 준비
---

![image](https://user-images.githubusercontent.com/42164422/126029162-e2729cdf-ba2a-4ecf-b324-521a791ef204.png)

- `Animator` 컴포넌트를 게임오브젝트에 추가합니다.

- `Animator` 컴포넌트에는 `Controller` 부분에 `Animator Controller` 애셋이 등록되어 있어야 합니다.

- `Animator Controller` 내에는 반드시 하나 이상의 애니메이션이 존재해야 합니다.

<br>



# 2. Animator Event Controller 컴포넌트 추가
---

![image](https://user-images.githubusercontent.com/42164422/126029258-5a1411ba-fc80-4b4b-9b6a-f71a91803cd5.png)

- `Animator` 컴포넌트의 이름 부분을 우클릭하고 `Add Animator Event Controller`를 클릭하여 `AnimatorEventController` 컴포넌트를 추가합니다.

<br>



# 3. 영문, 한글 전환
---

![2021_0717_AnimatorEventController_EngHan](https://user-images.githubusercontent.com/42164422/126031353-9b163f00-91a0-441e-982f-6fb9c54ed706.gif)

- 우측 상단의 `Eng/한글` 버튼을 클릭하여 영문, 한글 모드를 전환할 수 있습니다.

<br>



# 4. 이벤트 목록 확인
---

![image](https://user-images.githubusercontent.com/42164422/126032198-74bd2ae9-2274-4e3e-9dbc-bd16328b8ac7.png)

- 애니메이터에 등록된 이벤트를 모두 확인할 수 있습니다.

- 이벤트는 애니메이션 클립별로 구분되어 표시됩니다.

- 각 이벤트는 프레임 순서로 정렬되어 표시됩니다.

<br>



# 5. 재생 모드, 편집 모드 전환
---

![2021_0717_AnimatorEventController_ModeChange](https://user-images.githubusercontent.com/42164422/126031428-f5e6af8a-73f2-4cba-a62e-1e29af86fa70.gif)

- `편집 모드` 토글을 클릭하여 재생 모드와 편집 모드를 전환할 수 있습니다.

- 두 개의 슬라이더를 조절하여 각 모드별 게임 진행 속도를 조절할 수 있습니다.

- 재생 모드에서는 속도가 `0`이 아닌 경우, 애니메이션이 시간에 따라 재생됩니다.

- 편집 모드에서는 애니메이션이 항상 정지합니다.

- 애니메이션 편집은 편집 모드에서만 가능합니다.

<br>

## **주의사항**

- 원활한 이벤트 편집을 위해서는 유니티 에디터가 플레이모드에 진입해야 합니다.

<br>



# 6. 이벤트 추가/제거
---

![image](https://user-images.githubusercontent.com/42164422/126031467-ae86fabb-8da9-42d8-b041-c9bf9a8f37f2.png)

- `[+]` 버튼을 클릭하여 새로운 이벤트를 추가할 수 있습니다.

- 각 이벤트 우측에 존재하는 `[-]` 버튼을 클릭하여 해당 이벤트를 제거할 수 있습니다.

<br>



# 7. 이벤트 속성
---

## **[1] 활성화/비활성화**

![2021_0717_AnimatorEventController_enabled](https://user-images.githubusercontent.com/42164422/126032859-625a2fbe-6772-46e9-b608-25cf99707bc5.gif)

- 각 이벤트 좌측의 체크박스를 체크/해제하여 활성화/비활성화할 수 있습니다.

- 비활성화된 이벤트는 무시됩니다.

<br>

## **[2] 프리팹 오브젝트**

![2021_0717_AnimatorEventController_Prefab](https://user-images.githubusercontent.com/42164422/126031575-ce3ee71a-bf57-439b-82e3-036e87da23f3.gif)

- 이벤트를 통해 생성하기를 원하는 프리팹을 `프리팹 오브젝트` 부분에 등록할 수 있습니다.

- 프리팹 오브젝트가 등록될 경우 이름이 자동으로 지정되며, 이름을 직접 수정할 수도 있습니다.

- 등록된 프리팹 오브젝트가 존재하지 않는 경우, 해당 이벤트는 무시됩니다.

<br>

## **[3] 애니메이션**

![image](https://user-images.githubusercontent.com/42164422/126032883-f4382f9e-c5d0-40fb-8437-1121e933c803.png)

- 이벤트 등록을 원하는 애니메이션 클립을 지정합니다.

- 애니메이터 내에 등록된 애니메이션 목록이 드롭다운 형태로 제공됩니다.

- 애니메이터 내에 애니메이션이 단 하나만 존재하는 경우, 자동으로 해당 애니메이션으로 선택되며 이 옵션이 나타나지 않습니다.

<br>

## **[4] 생성 프레임**

![image](https://user-images.githubusercontent.com/42164422/126032907-490e2634-3a68-4ae9-916a-cb1372f49ad1.png)

- 이벤트 발생 타이밍으로 등록할 프레임을 지정합니다.

- 슬라이더의 범위는 해당 애니메이션의 프레임 범위로 자동 설정됩니다.

- 애니메이션이 해당 프레임에 도달할 경우, 등록된 프리팹이 복제되어 생성됩니다.

- 현재 재생 중인 애니메이션 프레임이 생성 프레임과 일치하는 경우, 슬라이더가 하늘색으로 강조 표시됩니다.

<br>

## **[5] 부모 트랜스폼**

![2021_0717_AnimatorEventController_ParentTransform](https://user-images.githubusercontent.com/42164422/126032969-26053db8-0ce5-4027-89d5-2c788260f267.gif)

- 이벤트를 통해 생성된 오브젝트가 소속될 부모 게임 오브젝트를 지정합니다.

- 오브젝트가 생성되면 해당 게임 오브젝트의 자식으로 포함됩니다.

- 우측의 `[M]` 버튼을 클릭하면 `AnimatorEventController`가 존재하는 게임 오브젝트가 등록됩니다.

- 부모 트랜스폼이 등록된 상태에서 우측의 `[X]` 버튼을 클릭하면 부모 트랜스폼이 해제됩니다.

- 부모 트랜스폼이 등록된 상태에서 `부모-자식 관계 유지`에 체크 해제할 경우, 이벤트 오브젝트의 위치, 회전, 크기 속성은 부모 트랜스폼을 따르지만, 자식으로 소속되지 않고 개별 오브젝트로 생성됩니다.

<br>

## **[6] 위치, 회전, 크기**

![image](https://user-images.githubusercontent.com/42164422/126034407-6081e9a5-0485-47c3-b77a-031a5dc47ab3.png)

- 이벤트를 통해 생성되는 오브젝트의 위치, 회전, 크기를 지정합니다.

- 부모 오브젝트가 등록되지 않은 경우, 월드 속성을 따릅니다.

- 부모 오브젝트가 등록된 경우, 해당 부모 트랜스폼에 종속되어 로컬 값으로 지정됩니다.

<br>

## **[7] 추가 옵션**

![2021_0717_AnimatorEventController_CopyTransform](https://user-images.githubusercontent.com/42164422/126031684-67b6b62a-0b67-426a-b3ad-bf3d1983d2f1.gif)

- 하단의 `>...` 버튼을 클릭하여 추가 옵션을 확인할 수 있습니다.

- `위치, 회전, 크기 초기화` 버튼
  - 위치와 회전을 `(0, 0, 0)`, 크기를 `(1, 1, 1)`로 초기화합니다.

- `로컬 트랜스폼 복제`
  - 트랜스폼 속성을 복제하기를 원하는 다른 게임오브젝트를 드래그하여 끌어다 넣습니다.
  - 해당 게임오브젝트의 트랜스폼이 갖고 있던 로컬 위치, 회전, 크기값을 이 이벤트에 적용합니다.

- `월드 트랜스폼 복제`
  - 트랜스폼 속성을 복제하기를 원하는 다른 게임오브젝트를 드래그하여 끌어다 넣습니다.
  - 해당 게임오브젝트의 트랜스폼이 갖고 있던 월드 위치, 회전, 크기값을 이 이벤트에 적용합니다.

<br>



# 8. 플레이모드 기능
---

![image](https://user-images.githubusercontent.com/42164422/126031785-d1f0ea74-4ad7-48cc-84a9-f2c3f72e437a.png)

<br>

## **[1] 처음부터 다시 재생 버튼**

- 현재 재생 중인 애니메이션을 0프레임부터 다시 재생합니다.

<br>

## **[2] 복제된 모든 오브젝트 제거 버튼**

- 이벤트로 인해 씬에 생성된 모든 오브젝트들을 제거합니다.

<br>

## **[3] 생성된 오브젝트 확인**

![image](https://user-images.githubusercontent.com/42164422/126032397-5c89133a-459b-412a-a570-42a7ce0f2b05.png)

- 이벤트로 인해 복제되어 씬에 생성된 오브젝트를 확인할 수 있습니다.

- 더블클릭 시 해당 오브젝트를 즉시 선택할 수 있습니다.

<br>

# 9. 편집모드 기능
---

## **[1] 프레임 이동 버튼**

![image](https://user-images.githubusercontent.com/42164422/126031810-9d872e22-7fb6-4cf9-8766-e944aafdfdc0.png)

- `<<` : 프레임을 앞으로 2만큼 이동합니다.
- `<` : 프레임을 앞으로 1만큼 이동합니다.
- `>` : 프레임을 뒤로 1만큼 이동합니다.
- `>>` : 프레임을 뒤로 2만큼 이동합니다.

<br>

## **[2] 프레임 기능 버튼**

![image](https://user-images.githubusercontent.com/42164422/126034449-9fe9f849-5be5-433c-892f-f83dfe0db2ea.png)

- `생성 프레임으로 이동`
  - 해당 이벤트에 지정한 애니메이션과 현재 재생 중인 애니메이션이 일치하는 경우에만 활성화됩니다.
  - 해당 이벤트에 지정한 생성 프레임으로 현재 프레임을 이동합니다.

- `현재 프레임 지정`
  - 해당 이벤트에 지정한 애니메이션과 현재 재생 중인 애니메이션이 일치하는 경우에만 활성화됩니다.
  - 현재 재생 중인 프레임을 생성 프레임에 지정합니다.

<br>

## **[3] 오브젝트 생성/제거 버튼**

![image](https://user-images.githubusercontent.com/42164422/126032426-82c41441-e97d-42dd-aaae-991fac72b667.png)

- `오브젝트 생성`
  - 현재 재생 중인 프레임이 해당 이벤트의 생성 프레임과 일치하는 경우에만 활성화됩니다.
  - 클릭 시 프리팹을 즉시 복제하여 씬에 생성합니다.
  - 기존에 생성된 오브젝트가 존재할 경우, 제거하고 새로 생성합니다.

- `오브젝트 제거`
  - 이미 생성된 오브젝트가 존재할 경우에만 활성화됩니다.
  - 생성된 오브젝트를 제거합니다.

<br>

# 10. 이벤트 편집 시 유의사항
---

![image](https://user-images.githubusercontent.com/42164422/126031932-0061aee5-e778-41ae-856a-ed14bcbf07ef.png)

- 현재 재생 중인 애니메이션과 이벤트에 지정된 애니메이션이 일치하는 경우에만 해당 이벤트를 편집할 수 있습니다.

<br>

## **위치, 회전, 크기 수정**

- 이벤트 속성에서 `위치, 회전, 크기`를 수정하는 경우, `생성된 오브젝트`가 존재하면 해당 오브젝트에 수정사항이 실시간으로 적용됩니다.

- 편집 모드일 때, `생성된 오브젝트`의 트랜스폼을 직접 수정하는 경우, 이벤트의 `위치, 회전, 크기`에 수정사항이 실시간으로 적용됩니다.
  - `생성된 오브젝트`가 파괴되지 않도록, 편집 모드의 `게임 진행 속도`를 `0`으로 고정하고 수정하는 것을 권장합니다.

<br>

- 예외사항 : `부모 트랜스폼`이 존재하고 `부모-자식 관계 유지`가 체크 해제된 경우, `위치, 회전, 크기`의 수정사항이 `생성된 오브젝트`에 적용되지만, 반대로 `생성된 오브젝트`의 수정사항은 `위치, 회전, 크기`에 적용되지 않습니다.

<br>



# Download
---
- [Animator Event Controller.unitypackage](https://github.com/rito15/Unity-Useful-Editor-Assets/releases/download/1.01/Animator.Event.Controller.unitypackage)

<br>



# Github
---
- <https://github.com/rito15/Unity-Useful-Editor-Assets>

<br>



# Future Works
---
- 이벤트 종류 추가
  - 게임오브젝트 활성화 이벤트
  - 메소드 실행 이벤트


