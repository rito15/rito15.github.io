---
title: Git - 명령어 - 1. 기본
author: Rito15
date: 2022-03-23 22:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---

## **특정 명령어의 도움말 확인하기**

```git
git {명령어} -h
```

<br>

## **임의 단축 명령어 만들기**

- 예시 : `git status`를 `git st`로 사용하도록 단축 명령어 등록

```git
git config --global alias.st status
```

<br>

<br>

# 자주 사용하는 명령어 모음
---
- 참고 : <https://velog.io/@simchodi/Git-초기세팅-기본명렁어>

<br>

### **[1] gitignore 재적용**
- <https://dev-jwblog.tistory.com/51>

```git
git rm -r --cached .
```


### **[2] 리모트**

```git
# 별칭은 대부분 origin
git remote -v                             # 원격 리포지토리 이름(별칭), URL 확인
git remote add {별칭} {리포지토리 URL}     # 해당 별칭으로 원격 리포지토리 등록
git remote remove {별칭}                  # 해당 별칭으로 등록된 원격 리포지토리 제거
git remote set-url {별칭} {리포지토리 URL} # 해당 별칭에 등록된 원격 리포지토리 주소 변경
```


### **[3] 태그**

```git
git tag          # 로컬에서 태그 목록 확인
git tag alpha    # 로컬에서 'alpha'라는 이름으로 태그 추가
git push --tag   # 태그 포함하여 원격에 푸시

git tag -d alpha                  # 로컬에서 'alpha` 태그 제거
git push origin --delete alpha    # 원격에서 'alpha' 태그 제거
git push origin :alpha            # 원격에서 'alpha' 태그 제거
```