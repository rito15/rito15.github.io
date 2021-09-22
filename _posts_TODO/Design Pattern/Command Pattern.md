# 커맨드(Command) 패턴
---

- 행위 혹은 명령 자체를 캡슐화(객체화) 시키는 것

- 객체 내에 행동을 실행할 수 있는 최소한의 정보를 담아 저장한다.

- 대표적인 활용으로 Undo, Redo가 있다.

- `Action` 같은 메소드 핸들에 행동을 담을 수도 있지만 이건 커맨드 패턴과는 다르다.
  메소드 핸들에는 행동을 직접 담고, 커맨드 객체는 행동을 실행할 수 있는 최소한의 정보를 담는다.
  물론 커맨드 객체에 Action처럼 행동을 직접 담을 수도 있으니 더 상위의 개념

- 커맨드 패턴이 경제적인 이유는, 행동을 기록할 때
  그 행동 개시에 필요한 최소한의 정보만 담아 저장하기 때문

- 예를 들어 '불을 켜다', '불을 끄다'라는 두 가지 행동을 객체에 저장할 때
  누가 불을 켜고 끄는지, 불빛 색상은 어떤지, 불을 켜고 끌 때 환경은 어떤지
  그런 정보들을 하나도 저장할 필요가 없고, 필요한 것은 그저 켜고 끈다는 행위 뿐

<br>

## **활용 1 : Undo, Redo**

- 어떤 행동을 수행했을 때, 그 행동을 수행하기 위한 최소한의 정보를 객체로 저장하여
  차례대로 스택에 담아 놓고, 차례로 상태 전이하듯 실행할 수 있도록 한다.

- 객체 자체에 행동 정보를 담아 저장하여, 마치 하나의 커맨드 객체에 '상태 전이 정보'를 담는 것과 같다.

- 웹에서의 Undo, Redo 구현을 예시로 들어서 살펴보면
  페이지 1번, 2번, 3번으로 이동한 상태에서 Undo를 했을 때 2번으로 이동한다.
  이건 마치 '3번 상태'에서 '2번 상태'로 상태를 전이한 것과 일맥상통한다.

- 따라서 커맨드 패턴은 상태 패턴과는 다른 방식으로 유한 상태를 구현할 수도 있다.

- 유한 상태 중에서도 그저 일직선으로 이어지는 선형 상태를 구축하는 것과 같다.

- 연속적으로 저장되는 커맨드 객체들은 이중 연결 리스트에 담기는 것과 같다.

- Undo 또는 Redo로 이전 커맨드, 다음 커맨드로 넘어갈 때는
  인접한 커맨드를 반드시 거쳐야만 가능하며 건너뛸 수는 없다.

<br>

## **활용 2 : 게임 리플레이 저장**

- 게임 플레이를 재현하기 위해 모든 유닛의 매 프레임 상태를 저장할 수도 있으나,
  이는 극도로 비효율적이다.

- 커맨드 패턴을 통해 유닛들의 행동에 변화가 생길 때,
  즉 어떤 명령이 발생했을 때마다 그걸 객체화하여 저장하면 경제적으로 구현할 수 있다.

- 예를 들어 유닛 A가 100번 프레임에 좌표 (0, 0)에서 (1, 2)로 이동하라는 명령이 실행될 때,
  행동할 유닛이 A라는 것, 그 행동이 '이동'이라는 것, 행동할 프레임과 이동 목표 좌표를 객체로 저장하면 된다.
