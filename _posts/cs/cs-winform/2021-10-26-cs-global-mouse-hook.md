---
title: C# - Global Mouse Hook
author: Rito15
date: 2021-10-26 03:56:00 +09:00
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
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Threading;

namespace Rito
{
    /*
         [기능]
             - 마우스 누름, 뗌, 휠 올림/내림, 휠클릭 이벤트 글로벌 후킹

         [메소드]
            - 후킹 시작 : Begin()
            - 후킹 종료 : End()
            - 핸들러 추가 : Mouse~, Middle~, Left~, Right~ 이벤트 핸들러에 메소드 등록
            - 마우스 현재 위치 받아오기 : GetCursorPosition()
            - 마우스 이벤트 발생시키기  : Force~()
    */
    class GlobalMouseHook
    {
        /***********************************************************************
        *                               DLL Imports
        ***********************************************************************/
        #region .
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook, MouseHookProc lpfn, IntPtr hMod, uint dwThreadId);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        // 강제로 마우스 이벤트 발생
        [DllImport("user32.dll")] // 입력 제어
        static extern void mouse_event(uint dwFlags, uint dx, uint dy, int dwData, int dwExtraInfo);

        [DllImport("user32.dll")] // 커서 위치 제어
        static extern int SetCursorPos(int x, int y);

        [DllImport("user32")]
        public static extern int GetCursorPos(out MousePoint pt);

        #endregion
        /***********************************************************************
        *                               Definitions
        ***********************************************************************/
        #region .
        [StructLayout(LayoutKind.Sequential)]
        public struct Point
        {
            public int x;
            public int y;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct MouseHookInfo
        {
            public Point pt;
            public uint mouseData;
            public uint flags;
            public uint time;
            public IntPtr dwExtraInfo;
        }

        /// <summary> 마우스 이벤트 값 - 읽기용 </summary>
        private enum MouseEvent
        {
            MouseMove = 0x0200,

            LButtonDown = 0x0201,
            LButtonUp = 0x0202,
            //LButtonDoubleClick = 0x0203,

            RButtonDown = 0x0204,
            RButtonUp = 0x0205,
            //RButtonDoubleClick = 0x0206,

            MButtonDown = 0x0207,
            MButtonUp = 0x0208,

            MouseWheel = 0x020A,
        }

        /// <summary> 커서 좌표 </summary>
        public struct MousePoint
        {
            public int x;
            public int y;
        }

        #endregion
        /***********************************************************************
        *                               Const Variables
        ***********************************************************************/
        #region .
        // 마우스 입력용
        private const uint LB_DOWN = 0x00000002; // 왼쪽 마우스 버튼 누름
        private const uint LB_UP   = 0x00000004; // 왼쪽 마우스 버튼 뗌

        private const uint RB_DOWN = 0x00000008;  // 오른쪽 마우스 버튼 누름
        private const uint RB_UP   = 0x000000010; // 오른쪽 마우스 버튼 뗌

        private const uint MB_DOWN = 0x00000020;  // 휠 버튼 누름
        private const uint MB_UP   = 0x000000040; // 휠 버튼 뗌
        private const uint WHEEL   = 0x00000800;  // 휠 스크롤

        private const int WH_MOUSE_LL = 14;

        const int TRUE = 1;
        const int FALSE = 0;
        #endregion
        /***********************************************************************
        *                               Privates
        ***********************************************************************/
        #region .
        private delegate IntPtr MouseHookProc(int code, IntPtr wParam, IntPtr lParam);
        private MouseHookProc mouseHookProc;

        private IntPtr hookID = IntPtr.Zero;

        private int _isHooking = FALSE;

        ~GlobalMouseHook()
        {
            End();
        }

        private IntPtr SetHook(MouseHookProc proc)
        {
            using (ProcessModule module = Process.GetCurrentProcess().MainModule)
                return SetWindowsHookEx(WH_MOUSE_LL, proc, GetModuleHandle(module.ModuleName), 0);
        }

        private IntPtr HookProc(int code, IntPtr wParam, IntPtr lParam)
        {
            if (code >= 0)
            {
                MouseEvent mEvent = (MouseEvent)wParam;

                switch (mEvent)
                {
                    case MouseEvent.LButtonDown:
                        OnLeftButtonDown?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    case MouseEvent.LButtonUp:
                        OnLeftButtonUp?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    //case MouseEvent.LButtonDoubleClick:
                    //    LeftDoubleClick?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                    //    break;

                    case MouseEvent.RButtonDown:
                        OnRightButtonDown?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    case MouseEvent.RButtonUp:
                        OnRightButtonUp?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    //case MouseEvent.RButtonDoubleClick:
                    //    RightDoubleClick?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                    //    break;

                    case MouseEvent.MouseMove:
                        OnMouseMove?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    case MouseEvent.MButtonDown:
                        OnMiddleButtonDown?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    case MouseEvent.MButtonUp:
                        OnMiddleButtonUp?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;

                    case MouseEvent.MouseWheel:
                        OnMouseWheel?.Invoke((MouseHookInfo)Marshal.PtrToStructure(lParam, typeof(MouseHookInfo)));
                        break;
                }
            }
            return CallNextHookEx(hookID, code, wParam, lParam);
        }

        #endregion
        /***********************************************************************
        *                               Event Fields
        ***********************************************************************/
        #region .
        public delegate void MouseEventHandler(MouseHookInfo mouseStruct);

        public event MouseEventHandler OnMouseMove;
        public event MouseEventHandler OnMouseWheel;

        public event MouseEventHandler OnLeftButtonDown;
        public event MouseEventHandler OnLeftButtonUp;

        public event MouseEventHandler OnRightButtonDown;
        public event MouseEventHandler OnRightButtonUp;

        public event MouseEventHandler OnMiddleButtonDown;
        public event MouseEventHandler OnMiddleButtonUp;

        #endregion
        /***********************************************************************
        *                               Public Methods
        ***********************************************************************/
        #region .
        /// <summary> 마우스 후킹 시작 </summary>
        public void Begin()
        {
            // CAS
            if (System.Threading.Interlocked.CompareExchange(ref _isHooking, TRUE, FALSE) == TRUE)
                return;

            mouseHookProc = HookProc;
            hookID = SetHook(mouseHookProc);
        }
        /// <summary> 마우스 후킹 종료 </summary>
        public void End()
        {
            // CAS
            if (System.Threading.Interlocked.CompareExchange(ref _isHooking, FALSE, TRUE) == FALSE)
                return;

            UnhookWindowsHookEx(hookID);
            hookID = IntPtr.Zero;
        }
        #endregion
        /***********************************************************************
        *                               Force Event Methods
        ***********************************************************************/
        #region .
        /// <summary> x,y 위치에 커서 이동 </summary>
        public void ForceSetCursor(int x, int y)
        {
            SetCursorPos(x, y);
        }

        /// <summary> 현재 위치로부터 (xMove, yMove)만큼 커서 이동 </summary>
        public void ForceMoveCursorLocal(int xMove, int yMove)
        {
            var pos = GetCursorPosition();

            SetCursorPos(pos.x + xMove, pos.y + yMove);
        }

        // 작동 안함. 개선 필요
        /// <summary> (xBegin, yBegin) 좌표에서 (xEnd, yEnd) 좌표까지 좌클릭 드래그 </summary>
        public void ForceMouseDrag(int xBegin, int yBegin, int xEnd, int yEnd)
        {
            SetCursorPos(xBegin, yBegin);
            mouse_event(LB_DOWN, 0, 0, 0, 0);

            SetCursorPos(xEnd, yEnd);
            mouse_event(LB_UP, 0, 0, 0, 0);
        }

        /// <summary> 마우스 현재 위치 받아오기 </summary>
        public MousePoint GetCursorPosition()
        {
            GetCursorPos(out var point);
            return point;
        }

        /// <summary> 좌클릭 발생시키기 </summary>
        public void ForceLeftClick()
        {
            mouse_event(LB_DOWN, 0, 0, 0, 0);
            mouse_event(LB_UP, 0, 0, 0, 0);
        }

        /// <summary> 우클릭 발생시키기 </summary>
        public void ForceRightClick()
        {
            mouse_event(RB_DOWN, 0, 0, 0, 0);
            mouse_event(RB_UP, 0, 0, 0, 0);
        }

        /// <summary> 왼쪽 더블클릭 발생시키기 </summary>
        public void ForceLeftDoubleClick()
        {
            mouse_event(LB_DOWN, 0, 0, 0, 0);
            mouse_event(LB_UP, 0, 0, 0, 0);

            Thread.Sleep(150);

            mouse_event(LB_DOWN, 0, 0, 0, 0);
            mouse_event(LB_UP, 0, 0, 0, 0);
        }

        /// <summary> 오른쪽 더블클릭 발생시키기 </summary>
        public void ForceRightDoubleClick()
        {
            mouse_event(RB_DOWN, 0, 0, 0, 0);
            mouse_event(RB_UP, 0, 0, 0, 0);

            Thread.Sleep(150);

            mouse_event(RB_DOWN, 0, 0, 0, 0);
            mouse_event(RB_UP, 0, 0, 0, 0);
        }

        /// <summary> 휠클릭 발생시키기 </summary>
        public void ForceMiddleClick()
        {
            mouse_event(MB_DOWN, 0, 0, 0, 0);
            mouse_event(MB_UP, 0, 0, 0, 0);
        }

        /// <summary> 휠 더블클릭 발생시키기 </summary>
        public void ForceMiddleDobuleClick()
        {
            mouse_event(MB_DOWN, 0, 0, 0, 0);
            mouse_event(MB_UP, 0, 0, 0, 0);

            Thread.Sleep(150);

            mouse_event(MB_DOWN, 0, 0, 0, 0);
            mouse_event(MB_UP, 0, 0, 0, 0);
        }

        /// <summary> 휠 올리기 </summary>
        public void ForceWheelUp(int power)
        {
            if (power > 120) power = 120;
            else if (power < -120) power = -120;

            mouse_event(WHEEL, 0, 0, power, 0);
        }

        /// <summary> 휠 내리기 </summary>
        public void ForceWheelDown(int power)
        {
            if (power > 120) power = 120;
            else if (power < -120) power = -120;

            mouse_event(WHEEL, 0, 0, -power, 0);
        }

        #endregion
    }
}
```

<br>

