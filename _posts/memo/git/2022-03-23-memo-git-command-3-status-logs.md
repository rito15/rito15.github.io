---
title: Git - 명령어 - 3. 상태, 기록
author: Rito15
date: 2022-03-23 22:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---



# Status
---

## **변경된 파일들 상태 확인하기**

```
git status
```

![image](https://user-images.githubusercontent.com/42164422/116910243-4cd8cc80-ac80-11eb-91bf-80f15dd05538.png)

- **Changes to be committed:**
  - `git add`를 통해 `Staging Area`로 이동된 파일들 목록

- **Changes not staged for commit:**
  - 변경되었지만 아직 스테이징 되지 않은 파일들 목록

<br>



# Diff
---

## **파일 변경 내용 확인하기**

```
git diff [파일명]
```

- 스테이징 되지 않은, 변경된 파일들의 내용 변경사항을 보여준다.

- `git diff 파일명`으로 특정 파일만 변경사항을 확인할 수 있다.

<br>

```
git diff --cached [파일명]
```

- 스테이징 된 파일들의 변경사항을 최근 커밋과 비교하여 보여준다.

<br>



# Log
---

## **커밋 히스토리 확인하기**

```
git log
```

![image](https://user-images.githubusercontent.com/42164422/116913266-359bde00-ac84-11eb-8836-30e91070beba.png)

- `git log -2` 처럼 뒤에 `-숫자`를 붙여서 확인할 커밋 개수를 지정할 수 있다.

- `git log -p` : 구체적인 변경사항을 직접 보여준다.

<br>

```
git log --stat
```

![image](https://user-images.githubusercontent.com/42164422/116913673-bb1f8e00-ac84-11eb-8cbe-8d48908ad6bb.png)

- 각 커밋마다 변경된 파일 정보를 확인할 수 있다.

<br>


