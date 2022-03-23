---
title: Git - 명령어 - 7. Restore
author: Rito15
date: 2022-03-23 22:00:00 +09:00
categories: [Memo, Git]
tags: [memo, git, github]
math: true
mermaid: true
---



# Restore
---

## **[1] 작업 중인 파일 상태 되돌리기**

```
git restore abc.txt
```

- `modified` 상태인 파일의 변경사항을 마지막 커밋 상태로 되돌린다.

<br>


## **[2] 스테이징 취소하기**

```
git restore --staged abc.txt
```

- `Staging Area`에 있는 특정 파일을 `modified` 상태로 되돌린다.
- 파일 내용에 영향을 주지 않는다.

<br>