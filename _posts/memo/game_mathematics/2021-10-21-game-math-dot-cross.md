---
title: 게임 수학 - 벡터의 내적과 외적
author: Rito15
date: 2021-10-21 16:00:00 +09:00
categories: [Memo, Game Mathematics]
tags: [game, math]
math: true
mermaid: true
---

# 내적
---

<details>
<summary markdown="span"> 
...
</summary>

## **특징**

- 내적은 벡터의 차원에 관계 없이, 동일한 차원의 벡터끼리 가능하다.
- 내적의 결과는 스칼라 값이다.
- 벡터 `A`, `B`의 내적은 `A`를 `B`에(또는 `B`를 `A`에) 투영시킨 후 두 벡터의 길이를 곱한 것과 같다.
- 내적은 교환 법칙, 결합 법칙이 성립한다.

<br>

## **주어진 벡터**

$$
\begin{flalign*}
\quad A = (a_{x} \, , \,\, a_{y} \, , \,\, a_{z}) &&
\end{flalign*}
$$

$$
\begin{flalign*}
\quad B = (b_{x} \, , \,\, b_{y} \, , \,\, b_{z}) &&
\end{flalign*}
$$

<br>

## **내적 연산**

$$
\begin{flalign*}
\quad 

A \cdot B = a_{x} \cdot b_{x} + a_{y} \cdot b_{y} + a_{z} \cdot b_{z} &&

\end{flalign*}
$$

$$
\begin{flalign*}
\quad \,\,

A \cdot B = |A| |B| cos\theta &&

\end{flalign*}
$$

</details>

<br>

# 내적의 활용
---

## **[1] 두 벡터의 각도 관계 판별하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138238610-5f0f3724-cfe7-4c26-919f-939d713f077f.png)

- 두 벡터의 내적 결과가 0보다 크면 두 벡터가 이루는 각도는 예각이다.
- 두 벡터의 내적 결과가 0이면 두 벡터가 이루는 각도는 직각이다.
- 두 벡터의 내적 결과가 0보다 작으면 두 벡터가 이루는 각도는 둔각이다.

</details>

<br>

## **[2] 두 벡터의 사잇각 계산하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138241116-d813c357-3308-4040-bdbd-ae87dc764a56.png)

$$
\begin{flalign*}
\quad

A \cdot B = |A| |B| cos\theta &&

\end{flalign*}
$$

$$
\begin{flalign*}
\quad

\therefore \theta = cos^{-1}(\frac{A \cdot B}{|A| |B|}) &&

\end{flalign*}
$$

</details>

<br>

## **[3] 다른 벡터에 투영하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138245529-e56ad926-06ab-4d75-b90e-12ef30bd72cd.png)

<!--
\begin{matrix}
A' &=& |A| cos\theta \, \cdot \, \frac{B}{|B|} \\
   &=& |A||B| cos\theta \, \cdot \, \frac{B}{|B|^{2}} \\
   &=& \frac{A \cdot\ B}{|B|^{2}} B
\end{matrix}
-->

<!-- 중앙 정렬 시 사용

$$
A' = |A| cos\theta \, \cdot \, \frac{B}{|B|}
$$

$$
\qquad \, \, \,
= |A||B| cos\theta \, \cdot \, \frac{B}{|B|^{2}}
$$

$$
\!\!\!\!\!\!\!
= \frac{A \cdot\ B}{|B|^{2}} B
$$

-->

$$
\begin{flalign*}

A' = |A| cos\theta \, \cdot \, \frac{B}{|B|} &&

\end{flalign*}
$$

$$
\begin{flalign*}
\quad

= |A||B| cos\theta \, \cdot \, \frac{B}{|B|^{2}} &&

\end{flalign*}
$$

$$
\begin{flalign*}
\quad

= \frac{A \cdot\ B}{|B|^{2}} B &&

\end{flalign*}
$$

<br>


$$
\begin{flalign*}
|B|가 \, 1인 \, 경우, &&
\end{flalign*}
$$

$$
\begin{flalign*}
\quad
A' = (A \cdot B) \, B &&
\end{flalign*}
$$

</details>

<br>

## **[4] 평면에 투영하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138283878-82e1113f-f751-4367-9894-61f4f3e57a8a.png)

> **V** : 벡터 <br>
> **N** : 평면의 법선 벡터(크기 1) <br>
> **V'** : 법선 벡터(N)에 투영된 V 벡터<br>
> **P** : 평면에 투영된 V 벡터

<br>

벡터 `V`를 법선 벡터 `N`에 투영한다.

![image](https://user-images.githubusercontent.com/42164422/138284258-aca2c368-5311-4368-9792-e544885107c0.png)

$$
\begin{flalign*}
\qquad
V' = (V \cdot N) \, N &&
\end{flalign*}
$$

<br>

벡터 `V`에서 `V'`을 뺀다.

![image](https://user-images.githubusercontent.com/42164422/138285970-36b1933d-4519-4cba-a4e3-4983262a6a43.png)

$$
\begin{flalign*}
\qquad
P = V - V' &&
\end{flalign*}
$$

<br>

하나의 식으로 정리하면 다음과 같다.

$$
\begin{flalign*}
\qquad
P = V - (V \cdot N) \, N &&
\end{flalign*}
$$

</details>

<br>



# 외적
---

<details>
<summary markdown="span"> 
...
</summary>

## **특징**

- 벡터의 외적은 3차원 벡터끼리만 가능하다.
- 외적의 결과는 벡터 값이다.
- 두 벡터를 외적한 결과는 두 벡터 모두에 수직인 벡터와 같다.
- 외적은 교환 법칙, 결합 법칙이 성립하지 않는다.
- 좌표계 종류(왼손, 오른손)에 따라 외적 결과 벡터의 방향이 달라진다.

<br>

## **주어진 벡터**

$$
\begin{flalign*}
\quad A = (a_{x} \, , \,\, a_{y} \, , \,\, a_{z}) &&
\end{flalign*}
$$

$$
\begin{flalign*}
\quad B = (b_{x} \, , \,\, b_{y} \, , \,\, b_{z}) &&
\end{flalign*}
$$

<br>

## **외적 연산**

$$
\begin{flalign*}

\quad A \times B = 
\begin{vmatrix} 
i & j & k \\ 
a_{x} & a_{y} & a_{z} \\ 
b_{x} & b_{y} & b_{z} 
\end{vmatrix} \\ &&

\end{flalign*}
$$

$$
\begin{flalign*}

\qquad \qquad = 
i \begin{vmatrix} a_{y} & a_{z} \\ b_{y} & b_{z} \end{vmatrix} -
j \begin{vmatrix} a_{x} & a_{z} \\ b_{x} & b_{z} \end{vmatrix} +
k \begin{vmatrix} a_{x} & a_{y} \\ b_{x} & b_{y} \end{vmatrix} \\ &&

\end{flalign*}
$$

$$
\begin{flalign*}

\qquad \quad = 
(a_{y} \cdot b_{z} - a_{z} \cdot b_{y} \, , \, \, 
a_{z} \cdot b_{x} - a_{x} \cdot b_{z} \, , \, \, 
a_{y} \cdot b_{z} - a_{z} \cdot b_{y})&&

\end{flalign*}
$$

</details>

<br>

# 외적의 활용
---

## **[1] 두 벡터에 수직인 벡터 계산하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138288300-ee4cbdc2-33f4-4225-8bc8-bcf446b0c0a2.png)

두 벡터의 외적 결과는 두 벡터 모두에 수직인 벡터이며,

순서를 바꾸어 연산할 경우 반대 방향으로 수직인 벡터를 얻을 수 있다.

</details>

<br>



## **[2] 외적 결과 벡터의 길이 구하기**

<details>
<summary markdown="span"> 
...
</summary>

<br>

두 벡터 `A`, `B`를 외적한 벡터의 길이는 다음과 같이 계산할 수 있다.

$$
\begin{flalign*}
\quad 

|A×B| = |A| |B| sin\theta &&

\end{flalign*}
$$

</details>

<br>



## **[3] 평면의 법선 벡터 구하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138337569-f11de7de-21c4-4f60-ab85-f64b36dfbff7.png)

세 개의 점을 알고 있을 때,

![image](https://user-images.githubusercontent.com/42164422/138337999-895a557b-d0bb-4f1d-a3f5-16afcfeab724.png)

세 개의 점 중 두 개를 지나는 서로 다른 벡터를 외적하여 평면의 법선 벡터를 손쉽게 구할 수 있다.

</details>

<br>



## **[4] 벡터의 좌우 관계 판별하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138336477-dc81ce46-7de3-4bb0-a10f-c0cdf1873352.png)

> **F** : 전방(Forward) 벡터 <br>
> **U** : 상단(Up) 벡터 <br>
> **V** : 좌우 관계를 판별할 벡터

<br>

$$
\begin{flalign*}
\quad 

k = (F \times V) \cdot U &&

\end{flalign*}
$$

- `k > 0`이면 벡터 `V`는 좌측을 향한다.
- `k = 0`이면 벡터 `V`는 중앙을 향한다. (`F`와 `U`가 이루는 평면에 포함된다.)
- `k < 0`이면 벡터 `V`는 우측을 향한다.

</details>

<br>



## **[5] 오브젝트의 로컬 축 벡터 구성하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138340158-583e2d3a-306e-43c7-84e4-a37943bd9705.png)

> v : 정규화되지 않은 전방 벡터(주어진 벡터) <br>
> Y : 월드 Y 벡터(주어진 벡터) <br>

<br>

- `local Z` : `v` 벡터 정규화
- `local X` : **localZ × worldY**
- `local Y` : **localZ × localX**

</details>

<br>

## **[6] 삼각형의 내부, 외부 판별하기**

<details>
<summary markdown="span"> 
...
</summary>

![image](https://user-images.githubusercontent.com/42164422/138341888-48259671-d71b-4d8c-99e3-91570377476b.png)

벡터 `AB`, `BC`, `CA` 중 두 개의 벡터를 외적하여

점 `A`, `B`, `C`가 이루는 평면의 법선 벡터 `N`을 구한다.

<br>

위의 `[3]` 방법을 통해 판별하여,

점 `P`가 벡터 `AB`, `BC`, `CA`에 대해 각각 모두 좌측에 위치한 경우

점 `P`는 삼각형 `ABC`의 내부에 있다고 판단할 수 있다.

<br>

### **Note**

실제로 사용하기에는 성능이 매우 떨어지므로,

아핀 조합에 의한 방정식

$$
\begin{flalign*}
\quad 

P = aA + bB + (1 - a - b)C &&

\end{flalign*}
$$

에 대해

`a`, `b`, `a + b`가 모두 `[0, 1]` 범위 내에 있다면

점 `P`는 삼각형 내부에 있는 것으로 판정하는 방법을 사용한다.

</details>



<br>

# References
---
- <https://www.inflearn.com/course/게임-수학-이해/lecture/75048>
- <https://m.blog.naver.com/destiny9720/221411770100>