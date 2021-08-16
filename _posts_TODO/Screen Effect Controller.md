
# 만들 스크린 이펙트
- Damage (구현은 완료, 정리 필요)
- Shake
- Freezing
- Hexagonal Tiles



# 스크린 이펙트 쉐이더 설정

Shader Type : Legacy/Unlit

SubShader
  - Cull Mode : Off
  - Depth
    - ZWrite Mode : Off
    - ZTest Mode : Off
    - Offset 체크 해제

텍스쳐 프로퍼티 이름은 MainTex





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