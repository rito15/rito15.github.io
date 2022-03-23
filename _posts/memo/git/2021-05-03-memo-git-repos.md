---
title: Git - 저장소 구조
author: Rito15
date: 2021-05-03 17:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---

# 1. 로컬 저장소
---

## [1] **Working Directory**
 - 작업 디렉토리 : 윈도우 내 폴더
 - `git add` 명령어를 통해 변경된 파일들을 `Staging Area`로 옮길 수 있다.

<br>

## [2] **Staging Area**
 - 커밋할 대상들을 저장하는 임시 저장소
 - 파일 변경사항 스냅샷을 안전하게 보관하지는 않는다.
 - `git commit` 명령어를 통해 스테이징 영역 내의 파일들을 `.git Directory`로 옮길 수 있다.

<br>

## [3] **.git Directory (History)**
 - 커밋 히스토리를 저장한다.
 - 커밋 버전별로 내용을 관리할 수 있다.
 - 원격 리포지토리에 push하기 전까지, 로컬 `.git` 폴더 내부에서 변경된 파일들의 스냅샷을 보관한다.

<br>

# 2. 원격 저장소
---
- 로컬 저장소와 원격 저장소는 1대 1로 연결된다.

- `git push` 명령어를 통해 `.git Dir`에서 `Remote`로 업로드할 수 있다.

- `git pull` 명령어를 통해 `Remote`에서 `.git Dir`로 다운로드할 수 있다.

<br>