---
title: Git - 명령어 - 5. 브랜치
author: Rito15
date: 2022-03-23 22:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---




# Branch
---

## **[1] 현재 브랜치 확인**

```
git branch
```

<br>


## **[2] 브랜치 전체(원격 포함) 목록 확인**

```
git branch -a
```

<br>



# Checkout
---

## **[1] 브랜치 이동**

```
git checkout {이동할 브랜치 이름}
```

<br>


## **[2] 새로운 브랜치 생성**

- 생성 후 해당 브랜치로 이동된다.

```
git checkout -b {새로운 브랜치 이름}
```

<br>



# 브랜치 생성/제거
---

## **[1] 새로운 원격 브랜치 생성**

- 로컬에서 새로운 브랜치를 생성한 상태

- 로컬의 현재 브랜치 이름과 {새로운 원격 브랜치 이름}은 일치해야 한다.

```
git push {원격 리포지토리 이름} {새로운 원격 브랜치 이름}
```

```
# 예시
git push origin dev-batch
```

<br>


## **[2] 로컬 브랜치 제거하기**

- 제거 대상이 아닌 브랜치로 이동한 상태

```
git branch --delete {제거할 브랜치 이름}
```

```
# 변경사항, 커밋 등이 있는 경우 무시하고 강제로 제거
git branch -D {제거할 브랜치명}
```

<br>


## **[3] 원격 브랜치 제거하기**

```
git push {원격 리포지토리 이름} :{제거할 원격 브랜치 이름}
```

```
# 예시
git push origin :dev-batch
```

<br>

