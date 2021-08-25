

TODO

Hex 쉐이더
- 육각형 Vector2타입 크기 프로퍼티로 변경 가능하게 변경




# 스크린 이펙트 쉐이더 설정

Shader Type : Legacy/Unlit

SubShader
  - Cull Mode : Off
  - Depth
    - ZWrite Mode : Off
    - ZTest Mode : Off
    - Offset 체크 해제

텍스쳐 프로퍼티 이름은 MainTex
 - Attribute : Hide In Inspector





# 플러그인 요구사항

- 타임라인에 이식될 수 있어야 함

- 에디트 모드에서 미리보기 기능 제공
  - Game View Auto Updater랑 함께 써야 함


# Screen Effect Controller
- 카메라에 부착되는 싱글톤
- HashSet으로 ScreenEffect들을 목록으로 보유
- 순회하며 차례대로 Blit
- 따로 추가하지 않아도 Screen Effect에서 싱글톤 호출 시 Camera.main이 있는 GO에 추가

# Screen Effect
- ★구현할 기능들 다 정해지면 구현 로드맵 만들기
- 개별 게임오브젝트의 컴포넌트로 존재
- 마테리얼을 하나 넣을 수 있음
- 게임오브젝트 활성화 시, Controller의 해시셋에 자신을 추가
- 하이라키 우클릭 - Effects - Screen Effect로 생성
- 에디터에서 현재 시간 진행도 보여주기 : Float slider
- 에디트 모드에서 미리보기, 시간 진행도 워프 가능(Slider)

- 옵션
  - 수명
  - 쉐이더 프로퍼티 드롭다운으로 가져와서 값 변화 설정 : Property Event
  - Property Event 하나 당 원하는 대로 수명 내에서 값 변화 이벤트 추가 가능(내부적으로 선형보간)
  - 
  
  
# Screen Effect Implementation Roadmap

## 마테리얼 프로퍼티 목록 로드
 - 쉐이더로부터 프로퍼티 목록 받아오기
 - string[]을 만들어서 드롭다운 표시
 
## 프로퍼티 이벤트 구현
 - 현재 드롭다운으로 선택된 프로퍼티에 대해, 우측 [+] 버튼 누르면 이벤트 추가
 - lifespan이 0이면 + 버튼 비활성화?
 - 이벤트 추가 시 기본적으로 lifespan:0 (Start) 이벤트, lifespan:Max (End) 이벤트 추가
 - 추가할 때 값은 현재 마테리얼에서 지정된 값 순간적으로 가져와 등록
 - 이벤트 사이사이에 [+] 버튼 존재
 - [+] 버튼 클릭하면 time은 바로 이전 인덱스의 이벤트 time, value도 이전 인덱스의 값 복제