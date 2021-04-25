---
title: 브레즌햄(픽셀에 직선 그리기) 알고리즘
author: Rito15
date: 2021-04-25 17:32:00 +09:00
categories: [Algorithm]
tags: [algorithm, csharp]
math: true
mermaid: true
---

# Summary
---

직선을 그릴 때 직선 위의 점들은 실수 값을 가질 수밖에 없다.

그래서 불연속 정수 값만을 갖는 픽셀에 직선을 그릴 때는

실수 값의 소수점을 버리거나 반올림하여 정수로 변환해야 하는데,

브레즌햄 알고리즘은 실수 연산 없이 정수 연산만으로 직선을 그릴 수 있게 해준다.

<br>

# Details
---

2가지 경우로 나눈다.

![image](https://user-images.githubusercontent.com/42164422/115991489-96337700-a603-11eb-8e1d-d31f462e3b36.png)

1. 기울기 절댓값이 1 미만인 경우
2. 기울기 절댓값이 1 이상인 경우

<br>

1번의 경우에는 x 좌표를 1씩 증가 또는 감소시키며 해당하는 y 좌표를 구하고,

2번의 경우에는 y 좌표를 1씩 증가 또는 감소시키며 해당하는 x 좌표를 구한다.

<br>

1번을 예시로 했을 때

x 좌표를 1씩 증가 또는 감소시켰을 때 y좌표 역시 1 증가 또는 감소시킬지 여부를 결정해야 하는데,

이를 판별값을 통해 계산한다.

직선을 그리기 위한 두 점을 각각 `p1`, `p2`,

`w = p2.x - p1.x`, `h = p2.y - p1.y`라고 한다.

판별값을 `k`라고 했을 때 다음 판별값을 계산하기 위한 두 가지 값을 각각 `kA`, `kB`라고 하며

`k`의 초깃값은 `2|h| - |w|`, `kA`와 `kB`의 값은 각각 `2|h|`, `2(|h| - |w|)`이다.

`x`, `y`의 부호값(1, 0, -1)을 각각 `sx`, `sy`라고 한다.

<br>

## **Pseudo Code**

```
Point p1, p2

w = p2.x - p1.x
h = p2.y - p1.y

sx = Sign(w) // w의 부호값
sy = Sign(h) // h의 부호값

k  = 2 * |h| - |w|
kA = 2 * |h|
kB = 2 * (|h| - |w|)

y = p1.y

for x = p1.x ~ p2.x; x += sx
    DrawPoint(x, y)

    if k < 0
        k += kA
    else
        k += kB
        y += sy
```

<br>

2번의 경우에는 1번에서 `x`, `y`를 서로 바꾸고 판별값에서 `|h|`, `|w|`를 서로 바꾸어 계산한다.

```
Point p1, p2

w = p2.x - p1.x
h = p2.y - p1.y

sx = Sign(w) // w의 부호값
sy = Sign(h) // h의 부호값

k  = 2 * |w| - |h|
kA = 2 * |w|
kB = 2 * (|w| - |h|)

x = p1.x

for y = p1.y ~ p2.y; y += sy
    DrawPoint(x, y)

    if k < 0
        k += kA
    else
        k += kB
        x += sx
```

<br>

# Source Code
---

<details>
<summary markdown="span"> 
Source Code
</summary>

```cs
public struct Point
{
    public int x;
    public int y;
    public Point(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
    public static implicit operator Point((int x, int y) p) => new Point(p.x, p.y);
    public static bool operator ==(Point a, Point b) => a.x == b.x && a.y == b.y;
    public static bool operator !=(Point a, Point b) => !(a.x == b.x && a.y == b.y);
    public override string ToString() => $"({x}, {y})";
}

internal class Bresenham : IEnumerable
{
    private readonly List<Point> points;

    public int Count { get; private set; }

    public Point this[int index]
    {
        get => points[index];
    }

    public Bresenham(Point p1, Point p2)
    {
        int w = Math.Abs(p2.x - p1.x);
        int h = Math.Abs(p2.y - p1.y);
        points = new List<Point>(w + h);

        SetPoints(p1, p2);
        Count = points.Count;
    }

    private void SetPoints(in Point p1, in Point p2)
    {
        int W = p2.x - p1.x; // width
        int H = p2.y - p1.y; // height;
        int absW = Math.Abs(W);
        int absH = Math.Abs(H);

        int xSign = Math.Sign(W);
        int ySign = Math.Sign(H);

        // 기울기 절댓값
        float absM = (W == 0) ? float.MaxValue : (float)absH / absW;

        int k;  // 판별값
        int kA; // p가 0 이상일 때 p에 더할 값
        int kB; // p가 0 미만일 때 p에 더할 값

        int x = p1.x;
        int y = p1.y;

        // 1. 기울기 절댓값이 1 미만인 경우 => x 기준
        if (absM < 1f)
        {
            k = 2 * absH - absW; // p의 초깃값
            kA = 2 * absH;
            kB = 2 * (absH - absW);

            for (; W >= 0 ? x <= p2.x : x >= p2.x; x += xSign)
            {
                points.Add((x, y));

                if (k < 0)
                {
                    k += kA;
                }
                else
                {
                    k += kB;
                    y += ySign;
                }
            }
        }
        // 기울기 절댓값이 1 이상인 경우 => y 기준
        else
        {
            k = 2 * absW - absH; // p의 초깃값
            kA = 2 * absW;
            kB = 2 * (absW - absH);

            for (; H >= 0 ? y <= p2.y : y >= p2.y; y += ySign)
            {
                points.Add((x, y));

                if (k < 0)
                {
                    k += kA;
                }
                else
                {
                    k += kB;
                    x += xSign;
                }
            }
        }
    }

    public IEnumerator GetEnumerator()
    {
        return points.GetEnumerator();
    }
}
```

</details>

<br>

# Example - Unity
---

![2021_0425_Bresenham](https://user-images.githubusercontent.com/42164422/115993278-13afb500-a60d-11eb-9810-823d6344c847.gif)

<br>

# References
---
- <https://kukuta.tistory.com/186>