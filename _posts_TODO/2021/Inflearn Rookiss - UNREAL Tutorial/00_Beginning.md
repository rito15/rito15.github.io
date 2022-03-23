# Study TODO
---
- 언리얼 라이프사이클
- 입력
- 이동, 점프

- Unity to Unreal 페이지의 연결 링크들 모두 숙지
  - <https://docs.unrealengine.com/4.27/ko/Basics/UnrealEngineForUnityDevs/>
  - <https://docs.unrealengine.com/4.27/ko/Basics/Actors/>
  - <https://docs.unrealengine.com/4.27/ko/InteractiveExperiences/Framework/Pawn/>


<br>

# Unity to Unreal
---

| Unity                | Unreal          |
|---                   |---              |
|Scene View & Game View|ViewPort         |
|Hierarchy             |World Outliner   |
|Inspector             |Details          |
|Project View          |Content Browser  |
|Shader                |Material         |
|Material              |Material Instance|
|Scene                 |Level/Map        |

<br>

## 기본 특징
 - 유니티는 텅 빈 밑바닥부터 입맛에 맞게 쌓아올리는 방식
 - 언리얼은 이미 타이트하게 기능들이 만들어져 있어서, 상대적으로 자유도가 떨어진다.
 - 언리얼은 애초에 FPS 용도로 제작되었던 엔진이다.

<br>

## 카메라와 기본 조작
 - 유니티는 씬에 직접 카메라를 배치하는데 반해, 언리얼은 그렇지 않다.
 - 언리얼은 따로 설정하지 않으면 게임 시작 시 자동으로 Default Pawn, Camera Actor 같은 것들이 생성되며 기본적인 FPS 조작을 제공해준다.
 - 툴바 - 세팅 - 월드 세팅 - 게임 모드 오버라이드를 통해 설정할 수 있다.

<br>




# Memo
---

<br>


# 프로젝트 디렉토리 구조
---

Root
  ㄴ프로젝트명.sln : 언리얼 C++ 솔루션 파일
  ㄴ프로젝트명.uproject : 언리얼 프로젝트 파일
  ㄴ.vs
  ㄴContent : 유니티의 Assets와 동일

<br>

# Viewport Window
---

## Toolbar
 - Settings
   - World Settings : 해당 월드(맵, 씬)의 설정들
   - Project Settings : 프로젝트 관련된 아주 많은 설정들
   
 - Play : 재생 모드 선택 가능
   - Selected Viewport : 뷰포트에서 바로 시작(조작 위임)
   - Simulate : 에디터 조작 유지한 채로 게임 시작(유니티와 비슷)
   - `F8` 버튼으로 두 모드 중에 변경 가능
   
## World Settings
  - Game Mode : 카메라, 사용자 컨트롤러 등의 기본 설정
   
## Project Settings

  ### Project
    - Maps `&` Modes : 에디터 시작 맵(씬)/게임 시작 맵 설정 가능

## 플레이 모드
 - ESC를 누르면 플레이 모드에서 빠져나온다.
 - Shift + F1을 누르면 마우스 커서가 표시된다.

## Lighting needs to be rebuilt
 - 씬에 존재하는 액터에 변경사항이 생겨서 라이트맵을 다시 구워야 할 때 표시된다.
 - Build - Lighting Quality를 Preview로 설정하고
 - Build - Build Lighting Only를 클릭하면 된다.
 - 라이트맵이 구워지는 동안 플레이할 수 없다.
 - 다 구워지면 에디터 우측 하단에 메시지가 뜨는데, Apply를 클릭하면 적용된다.

<br>



# World Outliner Window
---



<br>

# Material Window (ShaderGraph)
---

## 설명
  - 마테리얼 편집은 모두 별도의 창에서 노드그래프로 이루어진다.
  - 단축키는 앰플리파이와 유사하다.

## 노드 기능
  - 노드를 우클릭하고 Convert to Parameter 옵션을 통해 파라미터(프로퍼티)로 변경할 수 있다.
  - 파라미터인 노드를 우클릭하고 Convert to Constant 옵션을 통해 상수로 변경할 수 있다.

## 마테리얼 편집기 내 윈도우
  - Details : 현재 선택된 노드의 정보를 편집할 수 있다.
  - Parameter Defaults : 현재 마테리얼에 존재하는 파라미터를 편집할 수 있다.
  - Palette : 노드의 목록. 검색도 가능. Parameter를 검색하면 파라미터인 노드들이 나온다.
  
## 버튼들
  - Save : 변경사항을 저장한다.
  - Apply : 현재 해당 마테리얼이 적용된 오브젝트에 변경사항을 적용한다. 플레이모드일 때도 적용된다.

## Preview ViewPort
  - 현재 마테리얼이 입혀진 모습을 미리 볼 수 있다.
  - 좌클릭 드래그로 카메라를 회전할 수 있다.
  - 휠클릭 드래그로 카메라를 스크린에 평행하게 이동할 수 있다.
  - 우클릭 드래그로 카메라를 확대/축소할 수 있다.
  - L + 좌클릭 드래그로 라이트 방향을 변경할 수 있다.
  
  - 우하단 5개의 아이콘으로 각각 프리뷰 메시를 변경할 수 있다.
  - 5번째 아이콘은 현재 Content Browser에서 선택된 메시로 변경한다.

## 마테리얼과 마테리얼 인스턴스
  - 언리얼의 마테리얼 : 유니티의 쉐이더
  - 언리얼의 마테리얼 인스턴스 : 유니티의 마테리얼

<br>



# Static Mesh
---


- <https://docs.unrealengine.com/4.27/ko/WorkingWithContent/Types/StaticMeshes/>
- <https://docs.unrealengine.com/4.27/ko/Basics/Actors/StaticMeshActor/>

<br>




# References
---
- <https://docs.unrealengine.com/4.27/ko/Basics/UnrealEngineForUnityDevs/>
- <https://docs.unrealengine.com/4.27/ko/ProgrammingAndScripting/ProgrammingWithCPP/CPPProgrammingQuickStart/>