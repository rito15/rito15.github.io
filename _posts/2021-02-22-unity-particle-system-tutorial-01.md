---
title: 파티클 시스템 기초 - 01 - 파티클 시스템 만들기
author: Rito15
date: 2021-02-22 15:04:00 +09:00
categories: [Unity, Unity Particle System]
tags: [unity, csharp, particle]
math: true
mermaid: true
---

# 1. 파티클 시스템 개요
---
- 주로 유니티 내에서 VFX(Visual Effect)를 표현하는데 사용한다.

- 이름이 '파티클'이 아니고 '파티클 시스템'인 이유는 마치 시스템처럼 하나의 파티클 시스템이 여러 개의 작은 파티클 오브젝트를 생성 및 관리하기 때문이다.

- 기본적으로 빈 게임오브젝트에 `Particle System` 컴포넌트가 추가된 형태로 사용된다.

<br>

# 2. 파티클 시스템 만들기
---

- 하이라키 - 우클릭 - Effects - Particle System을 통해 기본적인 파티클 시스템 게임오브젝트를 생성할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108668752-1879bf00-751f-11eb-8797-fe153c26c2c7.png){:.normal}

- 그럼 이렇게 기본적인 형태의 파티클 시스템이 생성된다.

![2021_0222_Particle01](https://user-images.githubusercontent.com/42164422/108669273-064c5080-7520-11eb-9867-ad81261fd0a1.gif){:.normal}

<br>

# 3. 파티클 시스템의 필수 요소
---

- 파티클 시스템을 통해 이펙트를 제작하려면 반드시 필요한 것들이 있다.

<br>

## [1] 텍스쳐

- 각각의 파티클의 모양은 지정한 텍스쳐의 형태를 띤다.

- 따라서 원하는 파티클의 모양에 알맞은 텍스쳐를 사용해야 한다.

![image](https://user-images.githubusercontent.com/42164422/108669567-a1452a80-7520-11eb-8527-f0a7614c92af.png){:.normal}

<br>

## [2] 마테리얼

- 다른 게임오브젝트들의 렌더링과 마찬가지로, 파티클을 원하는 텍스쳐를 지정하여 화면에 보여주기 위해서는 마테리얼을 사용해야 한다.

- 파티클 시스템 게임오브젝트를 생성한 직후, Particle System 컴포넌트의 [Renderer] 탭을 열어보면 마테리얼에 기본적으로 `Default-ParticleSystem` 마테리얼이 등록되어 있는 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108669850-2a5c6180-7521-11eb-9ace-d602f6dbf65d.png){:.normal}

<br>

# 4. 파티클 시스템의 마테리얼
---

## [1] 마테리얼 생성하기

- 같은 마테리얼을 서로 다른 파티클 시스템에 함께 사용하게 되면 마테리얼의 변경사항이 각각의 파티클 시스템에 모두 적용된다.

- 따라서 각각의 파티클 시스템이 서로 다른 텍스쳐, 혹은 서로 다른 쉐이더 기능으로 동작하게 하려면 마테리얼을 따로 만들어 적용해야 한다.

- Project 윈도우에서 우클릭 - Create - Material을 통해 새로운 마테리얼을 생성한다.

![image](https://user-images.githubusercontent.com/42164422/108670264-f33a8000-7521-11eb-998f-3b8bf34d3e6f.png){:.normal}

- 이름은 해당 이펙트(파티클 시스템)를 잘 설명할 수 있는 이름으로 지정하는 것이 좋다.

<br>

## [2] 마테리얼의 종류 지정하기

- 파티클 시스템의 마테리얼은 기본적으로 반투명(Transparent)을 사용한다.

- 그 중에서도 `Additive`, `Alpha Blended` 두가지를 주로 사용한다.

- Project 윈도우의 마테리얼을 클릭하고, 인스펙터 창에서 마테리얼의 종류(정확히는 쉐이더의 종류)를 선택할 수 있다.

- [Standard] 라고 지정되어 있는 부분을 클릭한다.

![image](https://user-images.githubusercontent.com/42164422/108670873-f6823b80-7522-11eb-835a-80f88b589abc.png){:.normal}

- 가장 하단에 있는 [Legacy Shaders]를 클릭한다.

![image](https://user-images.githubusercontent.com/42164422/108670974-1fa2cc00-7523-11eb-86dd-71673e910047.png){:.normal}

- [Particles]를 클릭한다.

![image](https://user-images.githubusercontent.com/42164422/108671031-3ea15e00-7523-11eb-9b25-a5f92f1cc175.png){:.normal}

- 이 중에서 주로 [Additive], [Alpha Blended]를 사용하게 되며, 그 중에서도 [Additive]를 가장 많이 사용한다.

![](https://user-images.githubusercontent.com/42164422/108671073-50830100-7523-11eb-959a-8b985d5b41eb.png){:.normal}

- [Additive]를 클릭한다.

<br>

## NOTE : Additive와 Alpha Blended의 차이

- 좌 : Additive / 우 : Alpha Blended

![image](https://user-images.githubusercontent.com/42164422/108671971-a2785680-7524-11eb-931a-2b7962e25974.png){:.normal}

- 각각의 파티클이 겹칠 경우, Additive는 색상이 서로 더해져 밝아지고 Alpha Blended는 중간 값으로 혼합된다.

<br>

## [3] 텍스쳐 지정하기

- 생성한 마테리얼의 인스펙터 창에서 우측 상단에 있는 텍스쳐 슬롯을 클릭하면 현재 프로젝트 내에 있는 텍스쳐들을 지정할 수 있다.

![image](https://user-images.githubusercontent.com/42164422/108672646-cdaf7580-7525-11eb-9cb4-53304c6e812e.png){:.normal}

- 드래그 앤 드롭으로 텍스쳐를 직접 끌어다 놓을 수도 있다.

![2021_0222_Particle02](https://user-images.githubusercontent.com/42164422/108672996-4282af80-7526-11eb-9c07-0bb00f36e80b.gif){:.normal}
