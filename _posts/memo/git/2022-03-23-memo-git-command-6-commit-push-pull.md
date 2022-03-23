---
title: Git - 명령어 - 6. Commit, Push, Pull
author: Rito15
date: 2022-03-23 22:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---



# Commit
---

- `Staging Area` -> `.git Directory`
- 스테이징 된 데이터를 깃 히스토리 영역으로 이동시킨다.

<br>


## **[1] 코멘트와 함께 커밋하기**

```
git commit -m "comment"
```


<br>

## **[2] 워킹 디렉토리의 수정사항도 한번에 커밋하기**

```
git commit -am "comment"
```

- `git add .`, `git commit`을 동시에 하는 효과

- 커밋 기록이 없는 파일은 직접 `git add`를 해줘야 한다.

<br>



# Push
---

## **[1] 원격 리포지토리에 푸시하기**

- 로컬과 원격의 브랜치 이름이 같아야 한다.

```
git push {원격 리포지토리 이름} {브랜치 이름}
```

<br>

## **[2] 다음부터 간단히 푸시하도록 설정하기**

- 다음 푸시부터는 `git push`로 간단히 할 수 있도록,<br>
  현재의 로컬 브랜치와 대상 원격 리포지토리의 브랜치를 연결한다.

- `git pull`도 마찬가지로 간단히 할 수 있게 된다.

```
git push --set-upstream {원격 리포지토리 이름} {브랜치 이름}
```

```
# 동일
git push -u {원격 리포지토리 이름} {브랜치 이름}
```

<br>



# Pull
---

## **[1] 원격 리포지토리의 데이터 가져오기**

```
git pull {원격 리포지토리 이름} {브랜치 이름}
```

<br>



# PAT 사용하여 원격 리포지토리 접근하기
---


## **PAT ?** 
 - Personal Access Token

<br>


## **설명**

- 해당 리포지토리에 접근 권한이 있는 계정으로 로그인하지 않고도<br>
  접근 권한이 주어진 토큰을 사용하여 원격 리포지토리에 접근할 수 있다.

- 토큰 사용 대상 명령어
  - `clone`
  - `pull`
  - `push`

<br>


## **형식**

```
git {clone | pull | push} https://{토큰}@github.com/{사용자명}/{리포지토리명}.git
```

<br>


## **사용 예시**
 - 내가 가진 토큰(PAT) ID : `abcd1234`
 - 대상 리포지토리 소유자 ID : rito02
 - 대상 리포지토리 이름 : repo01

```
git push https://abcd1234@github.com/rito02/repo01.git
```

<br>


## **활용**
 - "refusing to allow an OAuth App to create or update workflow" 에러 발생 시, workflow 체크된 PAT를 이용하여 push


<br>
