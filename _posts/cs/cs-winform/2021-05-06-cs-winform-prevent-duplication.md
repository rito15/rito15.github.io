---
title: C# 윈폼 - 중복 실행 방지
author: Rito15
date: 2021-05-06 02:02:00 +09:00
categories: [Memo, Csharp Winform Memo]
categories: [C#, C# Winform]
math: true
mermaid: true
---

# Memo
---

- Program.cs에서 Main() 메소드 지우고 아래 내용 복붙하기

```cs
/// <summary>
/// 해당 응용 프로그램의 주 진입점입니다.
/// </summary>
[STAThread]
static void Main()
{
    if (!IsDuplicated())
        RunApplication();
}

// 이미 실행 중인 프로세스(중복 프로세스)가 있는지 확인
private static bool IsDuplicated()
{
    try
    {
        int processCount = 0;

        System.Diagnostics.Process[] processes = System.Diagnostics.Process.GetProcesses();

        foreach (System.Diagnostics.Process p in processes)
        {
            // 중복 프로세스 찾기
            // 주의 : 프로세스 이름은 응용프로그램 파일 이름(이름.exe)으로 실행됨!!
            if (AppDomain.CurrentDomain.FriendlyName.Equals(p.ProcessName + ".exe"))
                processCount++;

            // 중복 프로세스 탐지함
            if (processCount > 1)
            {
                MessageBox.Show("프로그램이 이미 실행중입니다.", "전지전능 개발자");
                return true;
            }
        }

        // 중복 프로세스 없음
        return false;
    }

    catch (Exception ex)
    {
        MessageBox.Show(ex.Message, "Exception");
        return true;
    }
}

// 윈폼 정상 실행
private static void RunApplication()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    Application.Run(new Form1());
}
```




