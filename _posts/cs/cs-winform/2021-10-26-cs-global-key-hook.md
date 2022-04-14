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
            - 후킹 종료 : Stop()
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
        static extern IntPtr LoadLibrary(string IpFileName);

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
            Stop();
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
        public void Stop()
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

    // Ctrl + Q
    if (args.KeyCode == (Keys.Control | Keys.Q))
    {
        // Do Something
    }

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
    kHook.Start();
}
```

<br>

# 추가
---

- `System.Windows.Forms`를 사용할 수 없는 경우
- `Keys`, `KeyEventArgs`, `KeyEventHandler` 직접 정의

<details>
<summary markdown="span"> 
...
</summary>

{% include codeHeader.html %}
```cs
using System;

namespace Rito
{
    public class KeyEventArgs
    {
        public bool Handled { get; set; }
        public Keys KeyCode { get; private set; }

        public KeyEventArgs(Keys keyData)
        {
            Handled = false;
            KeyCode = keyData;
        }
    }
    
    public delegate void KeyEventHandler(object sender, KeyEventArgs e);

    [Flags]
    public enum Keys
    {
        /// <summary>키 값에서 키 코드를 추출하는 비트 마스크입니다.</summary>
        KeyCode = 0xFFFF,
        /// <summary>키 값에서 한정자를 추출하는 비트 마스크입니다.</summary>
        Modifiers = -65536,
        /// <summary>키를 누르지 않았습니다.</summary>
        None = 0x0,
        /// <summary>마우스 왼쪽 단추입니다.</summary>
        LButton = 0x1,
        /// <summary>마우스 오른쪽 단추입니다.</summary>
        RButton = 0x2,
        /// <summary>취소 키입니다.</summary>
        Cancel = 0x3,
        /// <summary>마우스 가운데 단추입니다(3단추 마우스).</summary>
        MButton = 0x4,
        /// <summary>첫 번째 x 마우스 단추입니다(5단추 마우스).</summary>
        XButton1 = 0x5,
        /// <summary>두 번째 x 마우스 단추입니다(5단추 마우스).</summary>
        XButton2 = 0x6,
        /// <summary>백스페이스 키입니다.</summary>
        Back = 0x8,
        /// <summary>&lt;Tab&gt; 키입니다.</summary>
        Tab = 0x9,
        /// <summary>줄 바꿈 키입니다.</summary>
        LineFeed = 0xA,
        /// <summary>지우기 키입니다.</summary>
        Clear = 0xC,
        /// <summary>리턴 키입니다.</summary>
        Return = 0xD,
        /// <summary>&lt;Enter&gt; 키입니다.</summary>
        Enter = 0xD,
        /// <summary>Shift 키입니다.</summary>
        ShiftKey = 0x10,
        /// <summary>CTRL 키입니다.</summary>
        ControlKey = 0x11,
        /// <summary>Alt 키입니다.</summary>
        Menu = 0x12,
        /// <summary>&lt;Pause&gt; 키입니다.</summary>
        Pause = 0x13,
        /// <summary>CAPS LOCK 키입니다.</summary>
        Capital = 0x14,
        /// <summary>CAPS LOCK 키입니다.</summary>
        CapsLock = 0x14,
        /// <summary>IME 가나 모드 키입니다.</summary>
        KanaMode = 0x15,
        /// <summary>입력기 한글 모드 키입니다. 호환성을 위해 유지됩니다. <see langword="HangulMode" />를 사용하십시오.</summary>
        HanguelMode = 0x15,
        /// <summary>IME 한글 모드 키입니다.</summary>
        HangulMode = 0x15,
        /// <summary>IME 전자 모드 키입니다.</summary>
        JunjaMode = 0x17,
        /// <summary>입력기 최종 모드 키입니다.</summary>
        FinalMode = 0x18,
        /// <summary>IME 한자 모드 키입니다.</summary>
        HanjaMode = 0x19,
        /// <summary>IME 간지 모드 키입니다.</summary>
        KanjiMode = 0x19,
        /// <summary>&lt;ESC&gt; 키입니다.</summary>
        Escape = 0x1B,
        /// <summary>입력기 변환 키입니다.</summary>
        IMEConvert = 0x1C,
        /// <summary>입력기 변환 안 함 키입니다.</summary>
        IMENonconvert = 0x1D,
        /// <summary>입력기 적용 키이며 <see cref="F:System.Windows.Forms.Keys.IMEAceept" />를 대신합니다.</summary>
        IMEAccept = 0x1E,
        /// <summary>입력기 적용 키입니다. 사용되지 않으며 <see cref="F:System.Windows.Forms.Keys.IMEAccept" />를 대신 사용합니다.</summary>
        IMEAceept = 0x1E,
        /// <summary>입력기 모드 변경 키입니다.</summary>
        IMEModeChange = 0x1F,
        /// <summary>스페이스바 키입니다.</summary>
        Space = 0x20,
        /// <summary>&lt;Page Up&gt; 키입니다.</summary>
        Prior = 0x21,
        /// <summary>&lt;Page Up&gt; 키입니다.</summary>
        PageUp = 0x21,
        /// <summary>&lt;Page Down&gt; 키입니다.</summary>
        Next = 0x22,
        /// <summary>&lt;Page Down&gt; 키입니다.</summary>
        PageDown = 0x22,
        /// <summary>&lt;End&gt; 키입니다.</summary>
        End = 0x23,
        /// <summary>HOME 키입니다.</summary>
        Home = 0x24,
        /// <summary>왼쪽 화살표 키입니다.</summary>
        Left = 0x25,
        /// <summary>위쪽 화살표 키입니다.</summary>
        Up = 0x26,
        /// <summary>오른쪽 화살표 키입니다.</summary>
        Right = 0x27,
        /// <summary>아래쪽 화살표 키입니다.</summary>
        Down = 0x28,
        /// <summary>선택 키입니다.</summary>
        Select = 0x29,
        /// <summary>인쇄 키입니다.</summary>
        Print = 0x2A,
        /// <summary>실행 키입니다.</summary>
        Execute = 0x2B,
        /// <summary>&lt;Print Screen&gt; 키입니다.</summary>
        Snapshot = 0x2C,
        /// <summary>&lt;Print Screen&gt; 키입니다.</summary>
        PrintScreen = 0x2C,
        /// <summary>INS 키입니다.</summary>
        Insert = 0x2D,
        /// <summary>DEL 키입니다.</summary>
        Delete = 0x2E,
        /// <summary>도움말 키입니다.</summary>
        Help = 0x2F,
        /// <summary>0 키입니다.</summary>
        D0 = 0x30,
        /// <summary>1 키입니다.</summary>
        D1 = 0x31,
        /// <summary>2 키입니다.</summary>
        D2 = 0x32,
        /// <summary>3 키입니다.</summary>
        D3 = 0x33,
        /// <summary>4 키입니다.</summary>
        D4 = 0x34,
        /// <summary>5 키입니다.</summary>
        D5 = 0x35,
        /// <summary>6 키입니다.</summary>
        D6 = 0x36,
        /// <summary>7 키입니다.</summary>
        D7 = 0x37,
        /// <summary>8 키입니다.</summary>
        D8 = 0x38,
        /// <summary>9 키입니다.</summary>
        D9 = 0x39,
        /// <summary>A 키입니다.</summary>
        A = 0x41,
        /// <summary>B 키입니다.</summary>
        B = 0x42,
        /// <summary>C 키입니다.</summary>
        C = 0x43,
        /// <summary>D 키입니다.</summary>
        D = 0x44,
        /// <summary>E 키입니다.</summary>
        E = 0x45,
        /// <summary>F 키입니다.</summary>
        F = 0x46,
        /// <summary>G 키입니다.</summary>
        G = 0x47,
        /// <summary>H 키입니다.</summary>
        H = 0x48,
        /// <summary>I 키입니다.</summary>
        I = 0x49,
        /// <summary>J 키입니다.</summary>
        J = 0x4A,
        /// <summary>K 키입니다.</summary>
        K = 0x4B,
        /// <summary>L 키입니다.</summary>
        L = 0x4C,
        /// <summary>M 키입니다.</summary>
        M = 0x4D,
        /// <summary>N 키입니다.</summary>
        N = 0x4E,
        /// <summary>O 키입니다.</summary>
        O = 0x4F,
        /// <summary>P 키입니다.</summary>
        P = 0x50,
        /// <summary>Q 키입니다.</summary>
        Q = 0x51,
        /// <summary>R 키입니다.</summary>
        R = 0x52,
        /// <summary>S 키입니다.</summary>
        S = 0x53,
        /// <summary>T 키입니다.</summary>
        T = 0x54,
        /// <summary>U 키입니다.</summary>
        U = 0x55,
        /// <summary>V 키입니다.</summary>
        V = 0x56,
        /// <summary>W 키입니다.</summary>
        W = 0x57,
        /// <summary>X 키입니다.</summary>
        X = 0x58,
        /// <summary>Y 키입니다.</summary>
        Y = 0x59,
        /// <summary>Z 키입니다.</summary>
        Z = 0x5A,
        /// <summary>왼쪽 Windows 로고 키(Microsoft Natural 키보드)입니다.</summary>
        LWin = 0x5B,
        /// <summary>오른쪽 Windows 로고 키(Microsoft Natural 키보드)입니다.</summary>
        RWin = 0x5C,
        /// <summary>애플리케이션 키(Microsoft Natural Keyboard)입니다.</summary>
        Apps = 0x5D,
        /// <summary>컴퓨터 절전 키입니다.</summary>
        Sleep = 0x5F,
        /// <summary>숫자 키패드의 0 키입니다.</summary>
        NumPad0 = 0x60,
        /// <summary>숫자 키패드의 1 키입니다.</summary>
        NumPad1 = 0x61,
        /// <summary>숫자 키패드의 2 키입니다.</summary>
        NumPad2 = 0x62,
        /// <summary>숫자 키패드의 3 키입니다.</summary>
        NumPad3 = 0x63,
        /// <summary>숫자 키패드의 4 키입니다.</summary>
        NumPad4 = 0x64,
        /// <summary>숫자 키패드의 5 키입니다.</summary>
        NumPad5 = 0x65,
        /// <summary>숫자 키패드의 6 키입니다.</summary>
        NumPad6 = 0x66,
        /// <summary>숫자 키패드의 7 키입니다.</summary>
        NumPad7 = 0x67,
        /// <summary>숫자 키패드의 8 키입니다.</summary>
        NumPad8 = 0x68,
        /// <summary>숫자 키패드의 9 키입니다.</summary>
        NumPad9 = 0x69,
        /// <summary>곱하기 키입니다.</summary>
        Multiply = 0x6A,
        /// <summary>추가 키입니다.</summary>
        Add = 0x6B,
        /// <summary>구분 키입니다.</summary>
        Separator = 0x6C,
        /// <summary>빼기 키입니다.</summary>
        Subtract = 0x6D,
        /// <summary>10진 키입니다.</summary>
        Decimal = 0x6E,
        /// <summary>나누기 키입니다.</summary>
        Divide = 0x6F,
        /// <summary>F1 키입니다.</summary>
        F1 = 0x70,
        /// <summary>F2 키입니다.</summary>
        F2 = 0x71,
        /// <summary>F3 키입니다.</summary>
        F3 = 0x72,
        /// <summary>F4 키입니다.</summary>
        F4 = 0x73,
        /// <summary>F5 키입니다.</summary>
        F5 = 0x74,
        /// <summary>F6 키입니다.</summary>
        F6 = 0x75,
        /// <summary>F7 키입니다.</summary>
        F7 = 0x76,
        /// <summary>F8 키입니다.</summary>
        F8 = 0x77,
        /// <summary>F9 키입니다.</summary>
        F9 = 0x78,
        /// <summary>F10 키입니다.</summary>
        F10 = 0x79,
        /// <summary>F11 키입니다.</summary>
        F11 = 0x7A,
        /// <summary>F12 키입니다.</summary>
        F12 = 0x7B,
        /// <summary>F13 키입니다.</summary>
        F13 = 0x7C,
        /// <summary>F14 키입니다.</summary>
        F14 = 0x7D,
        /// <summary>F15 키입니다.</summary>
        F15 = 0x7E,
        /// <summary>F16 키입니다.</summary>
        F16 = 0x7F,
        /// <summary>F17 키입니다.</summary>
        F17 = 0x80,
        /// <summary>F18 키입니다.</summary>
        F18 = 0x81,
        /// <summary>F19 키입니다.</summary>
        F19 = 0x82,
        /// <summary>F20 키입니다.</summary>
        F20 = 0x83,
        /// <summary>F21 키입니다.</summary>
        F21 = 0x84,
        /// <summary>F22 키입니다.</summary>
        F22 = 0x85,
        /// <summary>F23 키입니다.</summary>
        F23 = 0x86,
        /// <summary>F24 키입니다.</summary>
        F24 = 0x87,
        /// <summary>NUM LOCK 키입니다.</summary>
        NumLock = 0x90,
        /// <summary>Scroll Lock 키입니다.</summary>
        Scroll = 0x91,
        /// <summary>왼쪽 Shift 키입니다.</summary>
        LShiftKey = 0xA0,
        /// <summary>오른쪽 Shift 키입니다.</summary>
        RShiftKey = 0xA1,
        /// <summary>왼쪽 &lt;Ctrl&gt; 키입니다.</summary>
        LControlKey = 0xA2,
        /// <summary>오른쪽 &lt;Ctrl&gt; 키입니다.</summary>
        RControlKey = 0xA3,
        /// <summary>왼쪽 &lt;Alt&gt; 키입니다.</summary>
        LMenu = 0xA4,
        /// <summary>오른쪽 &lt;Alt&gt; 키입니다.</summary>
        RMenu = 0xA5,
        /// <summary>브라우저의 뒤로 키(Windows 2000 이상)입니다.</summary>
        BrowserBack = 0xA6,
        /// <summary>브라우저의 앞으로 키(Windows 2000 이상)입니다.</summary>
        BrowserForward = 0xA7,
        /// <summary>브라우저의 새로 고침 키(Windows 2000 이상)입니다.</summary>
        BrowserRefresh = 0xA8,
        /// <summary>브라우저의 중지 키(Windows 2000 이상)입니다.</summary>
        BrowserStop = 0xA9,
        /// <summary>브라우저의 검색 키(Windows 2000 이상)입니다.</summary>
        BrowserSearch = 0xAA,
        /// <summary>브라우저의 즐겨찾기 키(Windows 2000 이상)입니다.</summary>
        BrowserFavorites = 0xAB,
        /// <summary>브라우저의 홈 키(Windows 2000 이상)입니다.</summary>
        BrowserHome = 0xAC,
        /// <summary>볼륨 음소거 키(Windows 2000 이상)입니다.</summary>
        VolumeMute = 0xAD,
        /// <summary>볼륨 작게 키(Windows 2000 이상)입니다.</summary>
        VolumeDown = 0xAE,
        /// <summary>볼륨 크게 키(Windows 2000 이상)입니다.</summary>
        VolumeUp = 0xAF,
        /// <summary>미디어 다음 트랙 키(Windows 2000 이상)입니다.</summary>
        MediaNextTrack = 0xB0,
        /// <summary>미디어 이전 트랙 키(Windows 2000 이상)입니다.</summary>
        MediaPreviousTrack = 0xB1,
        /// <summary>미디어 중지 키(Windows 2000 이상)입니다.</summary>
        MediaStop = 0xB2,
        /// <summary>미디어 재생 일시 중지 키(Windows 2000 이상)입니다.</summary>
        MediaPlayPause = 0xB3,
        /// <summary>메일 시작 키(Windows 2000 이상)입니다.</summary>
        LaunchMail = 0xB4,
        /// <summary>미디어 선택 키(Windows 2000 이상)입니다.</summary>
        SelectMedia = 0xB5,
        /// <summary>애플리케이션 1 시작 키(Windows 2000 이상)입니다.</summary>
        LaunchApplication1 = 0xB6,
        /// <summary>애플리케이션 2 시작 키(Windows 2000 이상)입니다.</summary>
        LaunchApplication2 = 0xB7,
        /// <summary>US 표준 키보드에서 OEM 세미콜론 키입니다(Windows 2000 이상).</summary>
        OemSemicolon = 0xBA,
        /// <summary>OEM 1 키입니다.</summary>
        Oem1 = 0xBA,
        /// <summary>국가/지역별 키보드에서 OEM 더하기 키(Windows 2000 이상)입니다.</summary>
        Oemplus = 0xBB,
        /// <summary>국가/지역별 키보드에서 OEM 쉼표 키(Windows 2000 이상)입니다.</summary>
        Oemcomma = 0xBC,
        /// <summary>국가/지역별 키보드에서 OEM 빼기 키(Windows 2000 이상)입니다.</summary>
        OemMinus = 0xBD,
        /// <summary>국가/지역별 키보드에서 OEM 마침표 키(Windows 2000 이상)입니다.</summary>
        OemPeriod = 0xBE,
        /// <summary>US 표준 키보드에서 OEM 물음표 키(Windows 2000 이상)입니다.</summary>
        OemQuestion = 0xBF,
        /// <summary>OEM 2 키입니다.</summary>
        Oem2 = 0xBF,
        /// <summary>US 표준 키보드에서 OEM 물결표 키(Windows 2000 이상)입니다.</summary>
        Oemtilde = 0xC0,
        /// <summary>OEM 3 키입니다.</summary>
        Oem3 = 0xC0,
        /// <summary>US 표준 키보드에서 OEM 여는 괄호 키(Windows 2000 이상)입니다.</summary>
        OemOpenBrackets = 0xDB,
        /// <summary>OEM 4 키입니다.</summary>
        Oem4 = 0xDB,
        /// <summary>US 표준 키보드에서 OEM 파이프 키(Windows 2000 이상)입니다.</summary>
        OemPipe = 0xDC,
        /// <summary>OEM 5 키입니다.</summary>
        Oem5 = 0xDC,
        /// <summary>US 표준 키보드에서 OEM 닫는 괄호 키(Windows 2000 이상)입니다.</summary>
        OemCloseBrackets = 0xDD,
        /// <summary>OEM 6 키입니다.</summary>
        Oem6 = 0xDD,
        /// <summary>US 표준 키보드에서 OEM 작은/큰따옴표 키(Windows 2000 이상)입니다.</summary>
        OemQuotes = 0xDE,
        /// <summary>OEM 7 키입니다.</summary>
        Oem7 = 0xDE,
        /// <summary>OEM 8 키입니다.</summary>
        Oem8 = 0xDF,
        /// <summary>RT 102 키 키보드에서 OEM 꺾쇠괄호 또는 백슬래시 키(Windows 2000 이상)입니다.</summary>
        OemBackslash = 0xE2,
        /// <summary>OEM 102 키입니다.</summary>
        Oem102 = 0xE2,
        /// <summary>프로세스 키입니다.</summary>
        ProcessKey = 0xE5,
        /// <summary>유니코드 문자를 키 입력인 것처럼 전달할 때 사용합니다. 패킷 키 값은 키보드가 아닌 입력 방법에 사용되는 32비트 가상 키 값의 하위 워드입니다.</summary>
        Packet = 0xE7,
        /// <summary>ATTN 키입니다.</summary>
        Attn = 0xF6,
        /// <summary>CRSEL 키입니다.</summary>
        Crsel = 0xF7,
        /// <summary>EXSEL 키입니다.</summary>
        Exsel = 0xF8,
        /// <summary>ERASE EOF 키입니다.</summary>
        EraseEof = 0xF9,
        /// <summary>재생 키입니다.</summary>
        Play = 0xFA,
        /// <summary>확대/축소 키입니다.</summary>
        Zoom = 0xFB,
        /// <summary>나중에 사용하기 위해 예약된 상수입니다.</summary>
        NoName = 0xFC,
        /// <summary>PA1 키입니다.</summary>
        Pa1 = 0xFD,
        /// <summary>지우기 키입니다.</summary>
        OemClear = 0xFE,
        /// <summary>Shift 보조키입니다.</summary>
        Shift = 0x10000,
        /// <summary>Ctrl 보조키입니다.</summary>
        Control = 0x20000,
        /// <summary>Alt 보조키입니다.</summary>
        Alt = 0x40000
    }
}
```

</details>

<br>