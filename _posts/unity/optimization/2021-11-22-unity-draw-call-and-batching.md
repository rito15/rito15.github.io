---
title: 유니티 - 드로우 콜과 배칭 개념 간단 정리
author: Rito15
date: 2021-11-22 20:13:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization]
math: true
mermaid: true
---

# 1. CPU와 GPU의 상호작용
---

## **CPU에서 GPU에 명령하기**
- 일반적으로 CPU에서 렌더링, 상태 변경 등의 명령을 GPU에 전달한다.
- 그런데 GPU가 바쁘게 작업하는 도중이라면, CPU는 GPU의 작업이 끝나기를 하염없이 기다리게 될 수 있다.
- 따라서 **커맨드 패턴(Command Pattern)**과 **메시지 큐(Message Queue)**에 의한 비동기 방식을 활용한다.
- CPU에서 GPU에 전달할 **명령(Command)**을 임시 공간에 담아 두고, GPU가 여유 될 때 명령을 하나씩 꺼내어 처리한다.

## **Command Buffer(커맨드 버퍼)**
- CPU의 각 스레드에서는 GPU에 전달할 렌더링 관련 명령을 모듈화하여 커맨드 버퍼에 차곡차곡 쌓아 임시로 저장한다.
- 그리고 GPU의 공유 커맨드 큐에 전송한 뒤, GPU를 기다리지 않고 다른 작업을 수행할 수 있다.
- 각 스레드마다 커맨드 버퍼를 갖고 공유 큐에 전송할 수 있으므로, 멀티스레드를 활용한 병렬 처리에도 용이한 방식이다.
- 명령을 곧장 커맨드 큐에 전송하는 것은 데이터 동기화 문제로 인한 성능 저하를 유발할 수 있으므로, 명령들을 모아 버퍼 단위로 전송하는 방식을 사용하는 것이다.

## **Command Queue(커맨드 큐)**
- GPU에는 CPU와 GPU가 함께 공유하는 커맨드 큐가 존재한다.
- GPU는 여유가 될 때마다 커맨드 큐에 담긴 커맨드 버퍼를 차례로 꺼내어, 그 안에 담긴 명령들을 처리한다.

<br>



# 2. 드로우 콜
---

## **Render States(렌더 상태)**
- GPU가 렌더링을 수행하기 위해 필요한 정보들
- 쉐이더, 메시, 텍스쳐, 알파 블렌딩 옵션, ZTest 및 스텐실 옵션 등이 있다.

## **Render State Changes(렌더 상태 변경)**
- GPU에서 렌더링할 대상의 상태가 변경될 경우 수행된다.
- CPU가 GPU에 렌더 상태 정보를 전송하며 상태 변경 명령을 보낸다.

## **SetPass Call**
- 쉐이더로 인한 렌더 상태 변경만을 의미한다.
- 쉐이더 내의 Pass 변경, 쉐이더(마테리얼) 자체의 변경, 쉐이더 내 파라미터들의 변경에 해당된다.
- 메시의 변경은 렌더 상태 변경이지만, **SetPass Call**에는 해당되지 않는다.
- 따라서 메시가 달라도 마테리얼이 같다면 **SetPass Call**은 딱 1번만 발생한다.

<br>

## **DP Call(Draw Primitive Call)**
- CPU가 GPU에 그리라는 명령을 직접적으로 호출하는 것(예 : glDrawElement())
- 그려야할 대상의 정보가 조금이라도 달라지는 경우, **DP Call**에 앞서 렌더 상태 변경이 동반된다.
- GPU는 현재 렌더 상태 정보를 기반으로 렌더링을 수행한다.

## **Draw Call**
- CPU에서 GPU에 렌더링 명령을 전송하는 것
- **Render State Changes + DP Call** 과정을 통칭한다.

<br>

# 3. 배칭
---

## **Batch**
- **SetPass Call + DP Call**
- **Render State Changes**가 아니라 **SetPass**를 포함하므로, **Draw Call**보다 좁은 의미를 가진다.
- **Batch**가 적다고 **Draw Call** 자체가 적은 것이 아닐 수 있다.
- **Batch**는 메시 상태 변경을 포함하지 않으므로, 배칭 처리가 되었더라도 메시가 다양하면 실제로 **Draw Call**은 훨씬 많을 수 있다.
- 다시 강조하지만, **Batch**는 메시의 변경을 포함하지 않는다. 메시가 달라도 마테리얼이 같으면 하나의 **Batch**로 통합할 수 있다.

<br>

## **Batching**
- 여러 개의 **Batch**를 하나로 묶는 최적화 기법

## **Static Batching**
- 배칭의 한 종류
- 런타임에 움직이지 않는 메시들에 대해서만 가능하다.
- 여러 개의 메시를 하나의 메시로 통합한다.
- 메시를 통합한 만큼, 하나의 배치로 그려줄 수 있다.
- 인스펙터에서 **Batching Static** 플래그를 설정하면 된다.
- **Static Batching**이 되더라도 컬링 연산은 원래의 메시 기준으로 이루어진다는 장점이 있다.

## **Dynamic Batching**
- 배칭의 한 종류
- 유니티에 의해 내부적으로 자동으로 수행된다.
- 플레이어 설정에서 **Dynamic Batching**만 켜주면 된다.
- 실제로는 제약이 너무 많으므로 **Dynamic Batching**에 의한 최적화를 기대하기는 힘들다.
- 예를 들어, 스킨 메시에 대해서는 적용되지 않으며 버텍스 300개 이상의 메시에 대해서도 적용되지 않는다.

## **GPU Instancing**
- 배칭의 한 종류
- 동일 메시, 동일 마테리얼인 경우에만 가능하다.
- 쉐이더에서 인스턴싱 사용 여부를 명시해주어야 한다.
- 쉐이더에서 **Instancing Buffer** 영역을 선언하여 인스턴싱을 적용할 쉐이더 파라미터를 설정할 수 있다.
- 마테리얼에서 **Enable GPU Instancing**에 체크하여 인스턴싱을 적용할 수 있다.
- 배칭이 적용됨에도 불구하고 **Material Property Block**을 통해서 마테리얼마다 파라미터를 변경할 수 있다는 장점이 있다.

## **SRP Batcher**
- 배칭의 한 종류
- 유니티의 **Scriptable Render Pipeline**에서만 동작한다.
- 동일 쉐이더, 다른 마테리얼에 대해서도 적용된다.
- 쉐이더 배리언트에 대해 특정한 규칙을 만족하는 경우에만 적용될 수 있다.

<br>

# References
---
- 오지헌, 유니티 그래픽스 최적화 스타트업, 비엘북스, 2019
- <https://docs.unity3d.com/kr/current/Manual/DrawCallBatching.html>
- <https://docs.unity3d.com/kr/current/Manual/GPUInstancing.html>
- <https://docs.unity3d.com/kr/current/Manual/SRPBatcher.html>




