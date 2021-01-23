---
title: "Behavior Tree"
author: Rito15
date: 2021-01-05 00:26:00 +08:00
categories: Unity, Study
tags: unity, csharp
---

## [1] 개념
---
- FSM (Finite State Machine)의 단점을 보완하기 위해 만들어진 기법
- FSM에서는 상태 전이 조건을 모두 각각의 상태에서 검사하지만, BT에서는 상태 동작 뿐만 아니라 전이 조건도 노드로 관리한다.
- 노드 그래프를 통해 시각화하거나 params, 빌더 패턴 등을 활용하여 스크립트 내에서도 가독성 좋게 구성할 수 있다.
- 기본적으로 Leaf, Decorator, Composite 노드를 기반으로 하며, 구현은 많이 다를 수 있다.
  - Leaf : 동작을 수행하는 노드. 대표적으로 Action 또는 Task 노드가 있다.
  - Decorator : 다른 노드에 조건을 붙여 수식하는 노드
  - Composite : 자식 노드들을 가지며, 자식들을 순회하거나 선택하는 역할을 수행하는 노드  


## [2] 노드 구성
---
- 모든 노드는 실행의 결과로 true 또는 false를 리턴한다.

- Decorator는 가독성의 이유로 Composite와 Leaf들의 구성으로 대체하였다.  

### [2-1] 인터페이스

- **INode**
  - 최상위 노드 클래스
  - bool Run(); 메소드를 가진다.

- **ILeafNode** : INode
  - 트리의 각 말단을 이루는 주요 수행 노드
  - Action 또는 Condition이 해당된다.

- **IDecoratorNode** : INode
  - 다른 노드들을 수식하여 동작 조건을 지정하는 노드

- **ICompositeNode** : INode
  - 자식들을 순회하기 위한 노드
  - 인터페이스 구현 시 List<INode> ChildList 멤버를 작성한다.  

### [2-2] 클래스

- **ActionNode** : ILeafNode
  - 주요 동작을 수행하는 역할을 하며, 무조건 true를 리턴한다.

- **ConditionNode** : ILeafNode
  - 조건식을 검사하여, 그 결과를 리턴한다.

- **NotConditionNode** : ILeafNode
  - 조건식의 결과를 반대로 리턴한다.

- **SelectorNode** : ICompositeNode
  - 자식들 중 true인 노드를 만날 때까지 차례대로 순회한다.
  - 자식이 false일 경우 계속해서 다음 자식 노드를 실행하고, true일 경우 순회를 중지한다.
  - 모든 자식 노드가 false일 경우 Selector 노드도 false를 리턴하며, true인 자식 노드를 만난 경우 즉시 true를 리턴하고 종료한다.

- **SequenceNode** : ICompositeNode
  - 자식들 중 false인 노드를 만날 때까지 차례대로 순회한다.
  - 자식이 true일 경우 계속해서 다음 자식 노드를 실행하고, false일 경우 순회를 중지한다.
  - 모든 자식 노드가 true인 경우 Sequence 노드도 true를 리턴하며, false인 자식이 존재하는 경우 즉시 false를 리턴하고 종료한다.

- **ParallelNode** : ICompositeNode
  - 자식 노드들의 실행 결과에 관계 없이 모든 자식 노드를 순회한다.  


## [3] 사용 예시
---

```cs
private INode _currentBehavior;

private void MakeBehaviorNodes()
{
    _currentBehavior =
        Selector
        (
            Condition(CharacterIsDead),
            Condition(CharacterIsStunned),
            Condition(CharacterIsRolling),
            // 위 조건 만족 시 모든 행동 불가

            // 1. 공격
            Sequence
            (
                Condition(CharacterIsBattleMode),
                Condition(CharacterIsGrounded),
                Condition(AttackKeyDown),
                Action(Attack),
                Action(PlayAttackAnimation)
            ),

            Condition(CharacterIsBinded),
            // 속박 시 아래 행동 불가

            // 2. 점프
            Sequence
            (
                NotCondition(OnAttackCooldown),
                Condition(JumpKeyDown),
                Action(Jump),
                Action(PlayJumpAnimation),
            ),

            // 3. 구르기
            Sequence
            (
                Condition(RollKeyDown),
                Action(Roll),
                Action(PlayRollAnimation)
            ),

            // 4. WASD 이동
            Action(KeyboardMove)
        );
}
```