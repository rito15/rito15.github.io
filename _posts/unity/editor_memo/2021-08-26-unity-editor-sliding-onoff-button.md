---
title: 유니티 에디터 GUI - 미끄러지는 On-Off 버튼
author: Rito15
date: 2021-08-26 03:45:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

![2021_0826_Sliding_Button](https://user-images.githubusercontent.com/42164422/130854524-c25b870a-97d8-4b60-9d72-eb9ecfef7254.gif)

```cs
bool onOff = true;
bool onOffMoving = false;
float onOffPos = 0f;
string onOffStr = "On";

private void DrawMovingOnOffButton()
{
    const float LEFT = 15f;
    const float RIGHT = 52f;
    const float WIDTH = 40f;
    const float HEIGHT = 20f;
    const float MOVE_SPEED = 1f;

    Rect rect = GUILayoutUtility.GetRect(1f, HEIGHT);

    Rect bgRect = new Rect(rect);
    bgRect.x = LEFT + 1f;
    bgRect.xMax = RIGHT + WIDTH - 2f;
    EditorGUI.DrawRect(bgRect, new Color(0.15f, 0.15f, 0.15f));

    rect.width = WIDTH;
    rect.x = onOffPos;

    Color col = GUI.backgroundColor;
    GUI.backgroundColor = Color.black;

    if (GUI.Button(rect, onOffStr))
    {
        onOffMoving = true;
    }

    if (!onOffMoving)
    {
        if (onOff)
        {
            onOffPos = LEFT;
            onOffStr = "On";
        }
        else
        {
            onOffPos = RIGHT;
            onOffStr = "Off";
        }
    }
    else
    {
        if (onOff)
        {
            if (onOffPos < RIGHT)
            {
                onOffPos += MOVE_SPEED;
                Repaint();

                if (onOffPos >= RIGHT)
                {
                    onOffMoving = false;
                    onOff = false;
                }
            }
        }
        else
        {
            if (onOffPos > LEFT)
            {
                onOffPos -= MOVE_SPEED;
                Repaint();

                if (onOffPos <= LEFT)
                {
                    onOffMoving = false;
                    onOff = true;
                }
            }
        }
    }

    GUI.backgroundColor = col;
}
```