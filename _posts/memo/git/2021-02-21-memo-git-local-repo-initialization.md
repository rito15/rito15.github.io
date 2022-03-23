---
title: Git - 로컬 리포지토리 초기 세팅하기
author: Rito15
date: 2021-02-21 00:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---

# 조건
---

- 깃헙 리포지토리를 새로 생성하는 경우

- 아무런 파일도 만들지 않고 순수한 상태로 리포지토리를 만든 경우 [1번](#1-깃헙에-빈-리포지토리를-생성한 경우)에 해당하며,

- Readme.md, LICENCE, .gitignore 등의 파일을 만들었다면 [2번](#2-깃헙-리포지토리에-파일이-하나라도-있는-경우)에 해당한다.

<br>



# 1. 깃헙에 빈 리포지토리를 생성한 경우
---

- 로컬 리포지토리로 사용할 디렉토리에는 다른 파일들 존재한다고 가정한다.

<br>

깃 로컬 리포지토리로 사용하겠다고 선언한다. (.git 폴더 생성)

```git
git init
```

<br>

업로드할 파일들을 등록한다.

```git
git add .
```

<br>

커밋을 등록한다.

```git
git commit -m "내용"
```

<br>

로컬 브랜치 이름을 명시적으로 main으로 지정한다.

```git
# -M이나 -m이나 똑같다.
git branch -M main
```

<br>

원격 리포지토리 이름을 origin으로 지정하면서 연결한다.

```git
git remote add origin [http://URL.git]
```

<br>

원격 리포지토리에 업로드 하는 동시에

다음부터 push할 때 `git push` 명령어만으로 간단히 업로드할 수 있도록 설정한다.

```git
# git push {원격 저장소 이름} {원격 브랜치 이름}
git push -u origin main
```

<br>



# 2. 깃헙 리포지토리에 파일이 하나라도 있는 경우
---

- git init 대신 git clone을 해야 한다.
- 명령 프롬프트에서 해당 로컬 경로로 이동한다.

<br>

로컬 리포지토리로 설정함과 동시에 원격 리포지토리에서 파일들을 받아온다.

```git
git clone [http://URL.git]
```

해당 로컬 경로에 원격 리포지토리의 디렉토리가 그대로 들어오는 것이 아니라,

리포지토리 이름으로 된 폴더가 생성되고 그 하위 디렉토리에 파일들이 들어온다.

<br>

원격 리포지토리 이름은 origin으로 자동으로 지정된다. 아래 명령어로 확인할 수 있다.

```git
git remote
```

<br>

현재 브랜치의 이름은 다음 명령어로 확인할 수 있다.

```git
git branch
```
<br>

Clone을 해왔으면 `push -u` 옵션을 사용하지 않아도 `git pull`, `git push` 만으로 바로 pull, push 가능하다.

<br>



# 3. Pull & Push
---

## Pull

```git
git pull {원격 리포지토리 이름} {원격 브랜치 이름}
```

<br>

## Push

```git
git add .

git commit -m "내용"

git push {원격 리포지토리 이름} {원격 브랜치 이름}
```

<br>

아래 명령어를 사용하여 푸시한 적 있다면 `git pull`, `git push` 명령어만으로 pull, push할 수 있다.

```git
git push -u {원격 리포지토리 이름} {원격 브랜치 이름}
```


<br>
# COPY & PASTE
---

- ## **URL 변경하여 사용**

<br>
## [1] Init

```git
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin [====URL====]
git push -u origin main
```

<br>
## [2] Clone

```git
git clone [====URL====]
```

<br>
# 원클릭 배치파일 모음
---

- [Unity_Local_Git_Repo_Set.zip](https://github.com/rito15/Images/files/6015691/Unity_Local_Git_Repo_Set.zip)

- 유니티용 .gitignore 포함