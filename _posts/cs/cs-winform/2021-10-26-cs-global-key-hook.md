---
title: C# - Global Key Hook
author: Rito15
date: 2021-10-26 03:55:00 +09:00
categories: [C#, C# Winform]
tags: [csharp, winform]
math: true
mermaid: true
---

# Source Code
---

{% include codeHeader.html %}
```cs
using System;
using System.Linq;
using System.Windows.Forms;

namespace Rito
{
    /* 
        [기능]
            - 키 누름, 키 뗌 이벤트 글로벌 후킹

        [프로퍼티]
            - bool Shift   : Shift 키 누른 상태인지 여부
            - bool Control : Control 키 누른 상태인지 여부
            - bool Alt     : Alt 키 누른 상태인지 여부

        [메소드]
            - 후킹 시작 : Begin()
            - 후킹 종료 : End()
            - 핸들러 추가 : AddKeyDownHandler(메소드), AddKeyUpHandler(메소드)
            - 이벤트 변수 비우기 : ResetKeyDownEvent(), ResetKeyUpEvent()
         
            - ForceKeyDown(Keys key)  : 키 누름 이벤트 발생시키기
            - ForceKeyUp(Keys key)    : 키 뗌 이벤트 발생시키기
            - ForceKeyPress(Keys key) : 키 입력 이벤트 발생시키기

            - Force_Cut()   : Ctrl + X 키 입력 이벤트 발생시키기
            - Force_Copy()  : Ctrl + C 키 입력 이벤트 발생시키기
            - Force_Paste() : Ctrl + V 키 입력 이벤트 발생시키기
         
        [참고]
            - KeyDown, KeyUp 이벤트 변수에 핸들러를 추가하여 사용
            - 후킹 중인 동안에도 핸들러 추가/제거 가능
            - UnHook() 호출해도 이벤트 변수들이 리셋되지는 않음
    */
    class GlobalKeyHook
    {
        /***********************************************************************
        *                               DLL Imports
        ***********************************************************************/
        #region .
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern IntPtr SetWindowsHookEx(int idHook, KeyboardHookProc callback, IntPtr hInstance, uint threadId);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern bool UnhookWindowsHookEx(IntPtr hInstance);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern int CallNextHookEx(IntPtr idHook, int nCode, int wParam, ref KeyboardHookInfo IParam);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern short GetKeyState(int nCode);
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        static extern IntPtr LoadLibrary(string IpFileName);   // 라이브러리 등록

        // 키 이벤트 호출하기
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern void keybd_event(byte vk, byte scan, int flags, ref int extrainfo);

        #endregion
        /***********************************************************************
        *                               Privates
        ***********************************************************************/
        #region .
        private delegate int KeyboardHookProc(int code, int wParam, ref KeyboardHookInfo IParam);

        private struct KeyboardHookInfo
        {
            public int vkCode;
            public int scanCode;
            public int flags;
            public int time;
            public int dwExtraInfo;
        }

        const int TRUE = 1;
        const int FALSE = 0;

        // 정의 되어 있는 상수 값
        const int VK_SHIFT = 0x10;
        const int VK_CONTROL = 0x11;
        const int VK_MENU = 0x12;

        const int WH_KEYBOARD_LL = 13;
        const int WM_KEYDOWN = 0x100;
        const int WM_KEYUP = 0x101;
        const int WM_SYSKEYDOWN = 0x104;
        const int WM_SYSKEYUP = 0x105;

        private KeyboardHookProc khp;
        private IntPtr hhook = IntPtr.Zero;

        private int _isHooking = FALSE;

        public GlobalKeyHook()
        {
            khp = new KeyboardHookProc(HookProc);
        }
        ~GlobalKeyHook()
        {
            End();
        }

        private int HookProc(int code, int wParam, ref KeyboardHookInfo IParam)
        {
            if (code >= 0)
            {
                Keys key = (Keys)IParam.vkCode;

                if ((GetKeyState(VK_CONTROL) & 0x80) != 0)
                {
                    key |= Keys.Control;
                    Control = true;
                }
                else
                    Control = false;

                if ((GetKeyState(VK_MENU) & 0x80) != 0)
                {
                    key |= Keys.Alt;
                    Alt = true;
                }
                else
                    Alt = false;

                if ((GetKeyState(VK_SHIFT) & 0x80) != 0)
                {
                    key |= Keys.Shift;
                    Shift = true;
                }
                else
                    Shift = false;

                KeyEventArgs kea = new KeyEventArgs(key);
                if ((wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) && (OnKeyDown != null))
                {
                    OnKeyDown(this, kea);
                }
                else if ((wParam == WM_KEYUP || wParam == WM_SYSKEYUP) && (OnKeyUp != null))
                {
                    OnKeyUp(this, kea);
                }
                if (kea.Handled)
                    return 1;
            }

            return CallNextHookEx(hhook, code, wParam, ref IParam);
        }
        #endregion
        /***********************************************************************
        *                               Key Events
        ***********************************************************************/
        #region .
        /// <summary> 키 누름 이벤트 함수 (+= 메소드로 핸들러 추가) </summary>
        public event KeyEventHandler OnKeyDown;

        /// <summary> 키 뗌 이벤트 함수 (+= 메소드로 핸들러 추가) </summary>
        public event KeyEventHandler OnKeyUp;

        #endregion
        /***********************************************************************
        *                               Public Properties
        ***********************************************************************/
        #region .
        public bool Shift { get; private set; }
        public bool Control { get; private set; }
        public bool Alt { get; private set; }
        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .
        /// <summary> 후킹 시작 </summary>
        public void Begin()
        {
            // CAS
            if (System.Threading.Interlocked.CompareExchange(ref _isHooking, TRUE, FALSE) == TRUE)
                return;

            IntPtr hInstance = LoadLibrary("User32");
            hhook = SetWindowsHookEx(WH_KEYBOARD_LL, khp, hInstance, 0);
        }

        /// <summary> 후킹 종료 </summary>
        public void End()
        {
            // CAS
            if (System.Threading.Interlocked.CompareExchange(ref _isHooking, FALSE, TRUE) == FALSE)
                return;

            UnhookWindowsHookEx(hhook);
        }

        /// <summary> KeyDown 이벤트에 중복되지 않게 핸들러 추가 </summary>
        public void AddKeyDownHandler(KeyEventHandler handler)
        {
            if (OnKeyDown != null && (OnKeyDown.GetInvocationList()?.Contains(handler) ?? false))
                return;

            OnKeyDown += handler;
        }

        /// <summary> KeyDown 이벤트에 중복되지 않게 핸들러 추가 </summary>
        public void AddKeyUpHandler(KeyEventHandler handler)
        {
            if (OnKeyUp != null && (OnKeyUp.GetInvocationList()?.Contains(handler) ?? false))
                return;

            OnKeyUp += handler;
        }

        /// <summary> 키 누름 이벤트 초기화 </summary>
        public void ResetKeyDownEvent()
        {
            OnKeyDown = null;
        }

        /// <summary> 키 뗌 이벤트 초기화 </summary>
        public void ResetKeyUpEvent()
        {
            OnKeyUp = null;
        }

        #endregion
        /***********************************************************************
        *                               Additional Functions
        ***********************************************************************/
        #region .
        /// <summary> Ctrl + X </summary>
        public void Force_Cut()
        {
            ForceKeyDown(Keys.LControlKey);
            ForceKeyPress(Keys.X);
            ForceKeyUp(Keys.LControlKey);
        }
        /// <summary> Ctrl + C </summary>
        public void Force_Copy()
        {
            ForceKeyDown(Keys.LControlKey);
            ForceKeyPress(Keys.C);
            ForceKeyUp(Keys.LControlKey);
        }
        /// <summary> Ctrl + V </summary>
        public void Force_Paste()
        {
            ForceKeyDown(Keys.LControlKey);
            ForceKeyPress(Keys.V);
            ForceKeyUp(Keys.LControlKey);
        }

        #endregion
        /***********************************************************************
        *                               Force Event Methods
        ***********************************************************************/
        #region .
        /// <summary> 강제로 키 누름(유지) 이벤트 호출하기 </summary>
        public void ForceKeyDown(Keys key)
        {
            int Info = 0;
            keybd_event((byte)key, 0, 0, ref Info);
        }

        /// <summary> 강제로 키 뗌 이벤트 호출하기 </summary>
        public void ForceKeyUp(Keys key)
        {
            int Info = 0;
            keybd_event((byte)key, 0, 0x02, ref Info);
        }

        /// <summary> 강제로 키입력(한 번 입력) 이벤트 호출하기 </summary>
        public void ForceKeyPress(Keys key)
        {
            int Info = 0;
            keybd_event((byte)key, 0, 0x00, ref Info);
            keybd_event((byte)key, 0, 0x02, ref Info);
        }

        #endregion
    }
}
```

<br>

# Example(Winform)
---

```cs
private GlobalKeyHook kHook;

private void KeyDownHandler(object sender, KeyEventArgs args)
{
    Keys key = args.KeyCode;
    
    // 입력한 키 코드 확인
    //MessageBox.Show(key.ToString());
    //return;

    switch (key)
    {
        // Ctrl + Shift + 1
        case Keys.D1 when kHook.Shift && kHook.Control:

            MessageBox.Show("Ctrl + Shift + 1");

            args.Handled = true; // 키 입력 무시
            break;
            
        // 문자열을 드래그하고 Shift + 1을 누르면 **문자열** 꼴로 만들어주기
        case Keys.D1 when kHook.Shift:
            // Ctrl + X
            kHook.Force_Cut();

            // **
            kHook.ForceKeyDown(Keys.LShiftKey);
            kHook.ForceKeyPress(Keys.D8);
            kHook.ForceKeyPress(Keys.D8);
            kHook.ForceKeyUp(Keys.LShiftKey);

            // Ctrl + V
            kHook.Force_Paste();

            // **
            kHook.ForceKeyDown(Keys.LShiftKey);
            kHook.ForceKeyPress(Keys.D8);
            kHook.ForceKeyPress(Keys.D8);
            kHook.ForceKeyUp(Keys.LShiftKey);

            args.Handled = true;
            break;
    }
}

private void Form1_Load(object sender, EventArgs e)
{
    kHook = new GlobalKeyHook();
    kHook.AddKeyDownHandler(KeyDownHandler);
    kHook.Begin();
}
```