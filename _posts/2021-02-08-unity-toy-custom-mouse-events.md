---
title: Custom Mouse Events
author: Rito15
date: 2021-02-08 21:54:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin, mouse]
math: true
mermaid: true
---

# 구현 동기
---
유니티 모노비헤이비어는 `OnMouse`로 시작하는 이벤트 메소드들을 작성하여 사용할 수 있다.

이 이벤트 메소드들은 레이캐스트 기반으로 동작하며, 해당 마우스 동작이 발생하면 메소드가 호출된다.

하지만 여러가지 단점들이 있다.

- 마우스 좌클릭에 대해서만 동작한다.
- 이벤트 메소드 작성 시, 비워놓거나 해당 이벤트가 발생하지 않는 상황에도 성능을 소모한다.
- 컴포넌트를 비활성화하거나, 심지어 게임오브젝트를 비활성화해도 성능을 소모한다.
- 마우스가 닿은 정확한 위치를 알 수 없다.
- 대상을 레이어로 필터링할 수 없다.

이런 단점들을 극복하고자 새롭게 구현하였다.

<br>

# 동작 원리
---

- `MouseEventCaller` 컴포넌트가 매 프레임 마우스 위치에 레이캐스트하여 대상을 탐색한다.
- 마우스 위치에 대상이 존재할 경우, 대상에 작성된 메소드를 호출한다.
- 대상에는 콜라이더가 반드시 있어야 한다.

<br>

# 성능 비교
---

## [1] 기존 OnMouse~ 이벤트
  - 단일 레이캐스트를 기반으로 하기 때문에, 성능을 적게 소모한다.

![image](https://user-images.githubusercontent.com/42164422/107227317-94273680-6a5e-11eb-83b9-72370715bb35.png){:.normal}

<br>

## [2] 커스텀 이벤트
  - 기존 이벤트보다도 더 적은 성능을 소모한다.
  - 또한 `MouseEventCaller`를 비활성화할 경우, 최소한의 성능조차 소모하지 않는다.

![image](https://user-images.githubusercontent.com/42164422/107227396-ac975100-6a5e-11eb-9fd5-e3bbe256159f.png){:.normal}

  - 기존 이벤트를 사용하는 게임오브젝트들을 모두 비활성화 했음에도 불구하고, 기존 이벤트는 비활성화 상태에서도 성능을 소모한다는 것을 추가적으로 확인할 수 있다. (파란색 박스)
  - 반면에 커스텀 이벤트는 해당 이벤트가 발생하지 않으면 성능을 소모하지 않는다.

<br>

# 커스텀 이벤트의 장점
---

- 모든 마우스 버튼(왼쪽, 오른쪽, 중앙, 추가 버튼들)에 대해 동작한다.

- 기존의 마우스 이벤트에는 없는 마우스 클릭 이벤트가 존재한다.

- 마우스 이벤트가 발생하는 경우에만 해당 메소드가 호출된다.

- 비활성화될 경우, 성능을 소모하지 않는다.

- 레이어 마스크를 통해 이벤트 대상을 제한할 수 있다.

- 마우스 레이캐스트가 대상 게임오브젝트에 닿은 위치를 알 수 있다.

- 소스코드를 수정하여 더 많은 데이터를 가져오거나, 동작을 변경할 수 있다.

<br>

# 사용법
---

- 빈 게임오브젝트를 생성하고, `MouseEventCaller` 컴포넌트를 추가한다.
- 마우스 이벤트를 사용할 스크립트 상단에 `using Rito.MouseEvents;`를 작성한다.
- MonoBehaviour 클래스에 원하는 마우스 이벤트의 인터페이스를 상속받는다.
- 인터페이스의 메소드를 구현한다.

```cs
// 예시 : IMouseEnter, IMouseExit, IMouseDragData 인터페이스 상속

using UnityEngine;
using Rito.MouseEvents;

public class MouseEventReceiver
 : MonoBehaviour, IMouseEnter, IMouseExit, IMouseDragData
{
    void IMouseEnter.OnMouseEnterAction()
    {
        ChangeColor(Color.red);
    }

    void IMouseExit.OnMouseExitAction()
    {
        ChangeColor(Color.white);
    }

    void IMouseDragData.OnMouseDragAction(int mouseButton, Vector3 mousePoint)
    {
        transform.position
            = new Vector3(mousePoint.x, mousePoint.y, transform.position.z);
    }

    // ...
}
```

<br>

# 이벤트 종류
---

## [1] 기본 이벤트

|---|---|
|`IMouseEnter`|마우스가 대상의 위로 이동한 경우 호출|
|`IMouseExit`|마우스가 대상에서 벗어난 경우 호출|
|`IMouseOver`|마우스가 대상의 위에 위치한 경우 매 프레임 호출|
|`IMouseDown`|대상의 위에서 마우스 버튼을 누른 경우 호출<br> - int mouseButton으로 마우스 버튼 인덱스 참조 가능|
|`IMouseUp`|대상의 위에서 마우스 버튼을 뗀 경우 호출<br> - int mouseButton으로 마우스 버튼 인덱스 참조 가능|
|`IMouseClick`|대상의 위에서 마우스 버튼을 눌렀다가 뗀 경우 호출<br> - int mouseButton으로 마우스 버튼 인덱스 참조 가능|
|`IMouseDrag`|대상의 위에서부터 마우스를 누르고 있는 경우 호출<br> - int mouseButton으로 마우스 버튼 인덱스 참조 가능|

<br>
## [2] 마우스 위치 전달 이벤트
- 이벤트 동작은 위와 동일
- Vector3 mousePoint 매개변수를 통해 마우스로부터 대상에게 레이캐스트가 닿은 지점을 참조할 수 있다.

- 종류
  - `IMouseEnterData`
  - `IMouseExitData`
  - `IMouseOverData`
  - `IMouseDownData`
  - `IMouseUpData`
  - `IMouseClickData`
  - `IMouseDragData`


<br>

# Preview
---

![](https://user-images.githubusercontent.com/42164422/107228709-50cdc780-6a60-11eb-9ea8-8217f0a787d9.gif){:.normal}

<br>

# Download
---
- [2021_0208_CustomMouseEvent.zip](https://github.com/rito15/Images/files/5945387/2021_0208_CustomMouseEvent.zip)

<br>

# Source Code
---
- <https://github.com/rito15/Unity_Toys>