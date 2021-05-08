---
title: 마우스 이벤트를 통과시킬 수 있는 컨트롤 만들기
author: Rito15
date: 2021-05-09 01:30:00 +09:00
categories: [Memo, Csharp Winform Memo]
tags: [csharp, winform]
math: true
mermaid: true
---

# 목표
---

- 마우스 이벤트를 모두 무시할 수 있는 컨트롤(버튼, 레이블 등) 만들기

<br>

# 방법
---

- 특정 컨트롤 클래스(Button, Label, ...)를 상속받는 클래스를 작성한다.

- 아래와 같이 프로퍼티와 메소드를 작성한다.

```cs
public bool Ignored { get; set; } = false;

protected override void WndProc(ref Message m)
{
    const int WM_NCHITTEST = 0x0084;
    const int HTTRANSPARENT = (-1);

    if (Ignored && m.Msg == WM_NCHITTEST)
    {
        m.Result = (IntPtr)HTTRANSPARENT;
    }
    else
    {
        base.WndProc(ref m);
    }
}
```

- 자신의 `Form` 클래스에서 직접 해당 컨트롤을 생성하고, 필요한 프로퍼티들을 지정해야 한다.

- 단점
  - 스크립트를 통해 직접 관리해야 하며, 디자인을 미리 확인할 수 없다.
  - 해결하려면 <https://www.youtube.com/watch?v=m07dQZWLBVM> 참고

<br>

# 예시 : 버튼 클래스
---

<details>
<summary markdown="span"> 
IgnorableButton.cs
</summary>

```cs
class IgnorableButton : Button
{
    public bool Ignored { get; set; } = false;

    protected override void WndProc(ref Message m)
    {
        const int WM_NCHITTEST = 0x0084;
        const int HTTRANSPARENT = (-1);

        if (Ignored && m.Msg == WM_NCHITTEST)
        {
            m.Result = (IntPtr)HTTRANSPARENT;
        }
        else
        {
            base.WndProc(ref m);
        }
    }

    public IgnorableButton(Form parentForm, string name, string text)
    {
        UseVisualStyleBackColor = true;

        this.Name = name;
        this.Text = text;

        parentForm.Controls.Add(this);
    }

    public void SetLocationAndSize(int locX, int locY, int width, int height)
    {
        this.Location = new System.Drawing.Point(locX, locY);
        this.Size = new System.Drawing.Size(width, height);
    }
}
```

</details>

<br>

<details>
<summary markdown="span"> 
Form1.cs
</summary>

```cs
public partial class Form1 : Form
{
    IgnorableButton _igbutton;

    public Form1()
    {
        InitializeComponent();
    }
    private void Form1_Load(object sender, EventArgs e)
    {
        _igbutton = new IgnorableButton(this, "iButton1", "IG-Button");
        _igbutton.SetLocationAndSize(250, 200, 200, 100);
        _igbutton.BringToFront();
    }

    private void checkBox1_CheckedChanged(object sender, EventArgs e)
    {
        _igbutton.Ignored = checkBox1.Checked;
    }
}
```

</details>

<br>

# Preview
---

![2021_0509_IgnorableButton](https://user-images.githubusercontent.com/42164422/117547133-f21ce780-b068-11eb-831e-c73a70a84e53.gif)

<br>

# References
---

- <https://stackoverflow.com/questions/547172/pass-through-mouse-events-to-parent-control>