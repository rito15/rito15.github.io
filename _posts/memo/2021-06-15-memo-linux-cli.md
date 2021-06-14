---
title: LINUX CLI
author: Rito15
date: 2021-06-15 02:34:00 +09:00
categories: [Memo]
tags: [memo, linux, ubuntu]
math: true
mermaid: true
---

# 리눅스 설치
---

## 1. Virtual Box + Ubuntu Server(CLI)
 - CLI : Command Line Interface
 - <https://www.virtualbox.org/wiki/Downloads>
 - <https://ubuntu.com/download/server> - Option 2

## 2. 구름 IDE (10GB 무료)
 - <https://www.goorm.io/>
 - 대시보드 - 새 컨테이너 생성 - Blank
 - 대시보드 이동 - 터미널 실행

## 3. AWS Cloud9
 - <https://aws.amazon.com/ko/cloud9/>

## 4. Google Compute Engine
 - <https://cloud.google.com/compute>

## 5. Windows10 WSL
 - <https://docs.microsoft.com/ko-kr/windows/wsl/install-win10>
 - <https://www.yalco.kr/_01_install_wsl/>
 - WSL 설치 이후 MS Store에서 Ubuntu 설치

<br>


# 명령어 모음
---

|명령어|설명|
|---|---|
|`명령어 --help`|해당 명령어 설명 출력하기|
|`clear`|화면 지우기|
|`pwd`|현재 디렉토리 경로 확인하기|
|`ls`, `dir`|현재 디렉토리 내의 구성 확인하기|
|`cd`|디렉토리 이동하기|
|`mkdir folder1`|folder1 폴더 생성|
|`rm file1|file1 파일 지우기|
|`rm -r folder1|folder1 폴더 지우기|
|`cp file1 file2`|file1의 내용을 file2로 복사|
|`vi file.txt`|vi 에디터를 통해 파일 생성 또는 편집|
|`cat file.txt`|파일 내용 출력|
|`wget url`|웹으로부터 url 주소의 내용 다운로드|

<br>

## **ls**

### `ls -F`
 - 대상들을 구분하여 간략히 표시
 - 대상이 폴더인 경우에는 `name/` 꼴로 표현

### `ls -l`
 - 대상들의 정보도 표시

### `ls -lF`
 - 두가지 옵션을 합성

<br>

## **cd**

### `cd /`
 - 최상위 디렉토리로 이동

## `cd ..`
 - 상위 디렉토리로 이동

## `cd ~`
 - 기본 작업 디렉토리로 이동
 - 경로 : `/home/사용자ID`

<br>


# VI Editor
---

## **에디터 모드**
 - 명령 모드, ex명령 모드, 편집 모드 존재


<br>

## **1. 명령 모드**

### `i`, `a`
 - 편집 모드 진입

### `:q`
 - 저장하지 않고 에디터 종료
 - 변경사항 없을 경우만 가능

### `:q!`
 - 변경사항 있어도 저장하지 않고 에디터 종료

### `:wq`
 - 저장 및 에디터 종료


<br>

## 2. **편집 모드**

### **ESC 키**
 - 명령 모드로 전환

<br>


# 프로그램 설치
---

- 계열, 종류마다 설치 명령어가 다르다.

## **sudo**
 - 관리자 권한 사용

## **apd-get**
 - 데비안 계열(대표적으로 우분투)의 리눅스에서 소프트웨어들을 다운받아 설치하는 패키지 매니저

<br>


# References
---
- <https://www.youtube.com/watch?v=tPWBF13JIVk>
- <https://www.yalco.kr/35_linux/>
- <https://jhnyang.tistory.com/54>