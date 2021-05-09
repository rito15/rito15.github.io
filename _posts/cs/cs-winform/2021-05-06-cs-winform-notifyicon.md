---
title: Notify Icon 사용하기
author: Rito15
date: 2021-05-06 02:02:00 +09:00
categories: [C#, C# Winform]
tags: [csharp, winform]
math: true
mermaid: true
---

# Memo
---

## 1. 도구
 - NotifyIcon 추가
 - ContextMenuStrip 추가

<br>

## 2. 속성
 - Form - Icon에 .ico 아이콘 파일 등록
 - NotifyIcon - Icon에 아이콘 등록(안하면 컨텍스트 안생김)
 - NotifyIcon - ContextMenuStrip 연결

<br>

## 3. 필드, 메소드 추가

```cs
//FormClosing 이벤트로 종료 가능 여부
private bool closeAllowed = false;

private void ShowForm()
{
    // 폼 등장
    this.Show();

    //창의 속성을 최소화->보통으로 바꿔줌
    this.WindowState = FormWindowState.Normal;

    // 폼에 포커스
    this.Focus();

    // 잠깐 맨 위로 올려주기(Focus만으로는 잘 안먹어서 추가함)
    TopMost = true;
    TopMost = false;
}
```

<br>

## 4. 윈폼에 FormClosing 이벤트 추가

```cs
private void Form1_FormClosing(object sender, FormClosingEventArgs e)
{
    //폼 종료 허용 시 (트레이 아이콘 메뉴의 Exit 누를 경우만)
    if (closeAllowed == true)
    {
        e.Cancel = false;
    }
    //폼 종료 비허용 시
    else
    {
        e.Cancel = true;
        this.Hide();
    }
}
```

<br>

## 5. NotifyIcon
 - Text 변경 ( 노티파이 아이콘에 마우스 올리면 뜨는 텍스트 )
 - 더블클릭 이벤트 추가

```cs
private void notifyIcon1_DoubleClick(object sender, EventArgs e)
{
    ShowForm();
}
```

<br>

## 6. ContextMenuStrip
 - Show, Exit 메뉴 추가
 - 아이콘 더블클릭이랑 Show Exit 각각 클릭 이벤트 추가

```cs
private void showToolStripMenuItem_Click(object sender, EventArgs e)
{
    ShowForm();
}

private void exitToolStripMenuItem_Click(object sender, EventArgs e)
{
    // 폼 종료 허용
    closeAllowed = true;

    // 종료 요청(FormClosing 이벤트 호출)
    this.Close();
}
```


<br>

## + 추가사항

```
private void Form1_Resize(object sender, EventArgs e)
{
    //최소화 시 종료와 동일한 작업 수행
    if (this.WindowState == FormWindowState.Minimized)
        this.Close();
}


private void Form1_Shown(object sender, EventArgs e)
{
    //폼 숨기기
    this.Hide();
}
```



