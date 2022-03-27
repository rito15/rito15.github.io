
# References
---
- <https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@7.1/manual/GraphLogicAndPhilosophy.html>


<br>


# VFX Graph 기본 구조
---

## **Spawn**
- 파티클 시스템 단위로, 매 프레임 한 번씩 호출된다.
- 

<br>

## **Initalize Particle**
- 파티클 단위로, 파티클이 생성되는 순간만 호출된다.

<br>

## **Update**
- 파티클 단위로, 매 프레임 한 번씩 호출된다.
- 파티클 움직임 시뮬레이션 관련 기능들에 해당된다.
- 예 : 속도, 힘, 충돌

<br>

## **Output**
- 파티클 단위로, 매 프레임 한 번씩 호출된다.
- 파티클의 형태를 결정한다.
- 예 : 크기, 색상

