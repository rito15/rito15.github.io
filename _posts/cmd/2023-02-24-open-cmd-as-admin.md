--- 
title: 관리자 권한으로 CMD 열기(배치파일)
author: rito15 
date: 2023-02-24 22:31:23 +09:00 
categories: [cmd] 
tags: [] 
math: false 
mermaid: false 
--- 

# 관리자 권한으로 CMD 여는 배치파일 만들기
--- 

## cmdcmd.bat

```bat
@echo off

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    rem del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin

start cmd

:: cmd로 무언가 실행하기
:: cmd /c "무언가1 & 무언가2 & pause>nul"
```

<!------------------------------------------------------------------> 

