

# Git 구성
---

## [1] Local

### [1-1] Working Directory
 - 작업 디렉토리 : 윈도우 내 폴더
 - `git add` 명령어를 통해 변경된 파일들을 `Staging Area`로 옮길 수 있다.

### [1-2] Staging Area
 - 커밋할 대상들을 저장하는 임시 저장소
 - 파일 변경사항 스냅샷을 안전하게 보관하지는 않는다.
 - `git commit` 명령어를 통해 스테이징 영역 내의 파일들을 `.git Directory`로 옮길 수 있다.

### [1-3] .git Directory (History)
 - 커밋 히스토리를 저장한다.
 - 커밋 버전별로 내용을 관리할 수 있다.
 - 원격 리포지토리에 push하기 전까지, 로컬 `.git` 폴더 내부에서 변경된 파일들의 스냅샷을 보관한다.

<br>

## [2] Remote
 - Git 원격 리포지토리
 - `git push` 명령어를 통해 `.git Dir`에서 `Remote`로 업로드
 - `git pull` 명령어를 통해 `Remote`에서 `.git Dir`로 다운로드

<br>

# 명령어
---

## **특정 명령어의 도움말 확인하기**

```
git 명령어 -h
```

<br>

## **임의 단축 명령어 만들기**

- 예시 : `git status`를 `git st`로 사용하도록 단축 명령어 등록

```
git config --global alias.st status
```

<br>


## **원격 리포지토리 이름 확인하기**

```
git remote
```

<br>

## **로컬 브랜치명 확인하기**

```
git branch
```

## **로컬, 원격 브랜치명 확인하기**

```
git branch -a
```

<br>

## **원격 리포지토리 주소 확인하기**

```
git remote -v
```

<br>

## **원격 리포지토리 주소 변경하기**

```
git remote set-url origin [https://~.git]
```

<br>


## **로컬 리포지토리로 만들기**

```
git init
```

- `.git` 폴더가 생성된다.

<br>



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



## **Restore**

### [1] 작업 중인 파일 상태 되돌리기

```
git restore abc.txt
```

- `modified` 상태인 파일의 변경사항을 마지막 커밋 상태로 되돌린다.

<br>

### [2] 스테이징 취소하기

```
git restore --staged abc.txt
```

- `Staging Area`에 있는 특정 파일을 `modified` 상태로 되돌린다.
- 파일 내용에 영향을 주지 않는다.


<br>

## **Commit**

### [1] 한 줄 코멘트와 함께 커밋하기

```
git commit -m "comment"
```

- `Staging Area` -> `.git Directory`

<br>

### [2] 워킹 디렉토리의 수정사항도 한번에 커밋하기

```
git commit -am "comment"
```

- `git add .`, `git commit`을 동시에 하는 효과


<br>

## **Push**

### **[1] 원격 리포지토리에 푸시하기**

- 로컬과 원격의 브랜치 이름이 같아야 한다.

```
git push {원격 리포지토리 이름} {브랜치 이름}
```

<br>

### **[2] 다음부터 간단히 푸시하도록 설정하기**

- 다음 푸시부터는 `git push`로 간단히 할 수 있도록,<br>
  현재의 로컬 브랜치와 대상 원격 리포지토리의 브랜치를 연결한다.

- `git pull`도 마찬가지로 간단히 할 수 있게 된다.

```
git push --set-upstream {원격 리포지토리 이름} {브랜치 이름}

## 동일

git push -u {원격 리포지토리 이름} {브랜치 이름}
```

<br>


## **Clone**

### **[1] 기본 클론**

```
git clone https://github.com/{사용자명}/{프로젝트명}.git
```

<br>

### **[2] 특정 브랜치만 클론**

```
git clone -b {브랜치명} https://github.com/{사용자명}/{프로젝트명}.git
```

<br>


## **Branch**

### **[1] 현재 브랜치 확인**

```
git branch
```

<br>

### **[2] 브랜치 전체(원격 포함) 목록 확인**

```
git branch -a
```

<br>

### **[3] 브랜치 이동**

```
git checkout {이동할 브랜치 이름}
```

<br>

### **[4] 새로운 브랜치 생성**

- 생성 후 해당 브랜치로 이동된다.

```
git checkout -b {새로운 브랜치 이름}
```

<br>

### **[5] 새로운 원격 브랜치 생성**

- 로컬에서 새로운 브랜치를 생성한 상태

```
# 로컬의 현재 브랜치와 {새로운 원격 브랜치 이름}은 일치해야 한다.
git push {원격 리포지토리 이름} {새로운 원격 브랜치 이름}
```

```
# 예시
git push origin dev-batch
```

<br>

### **[6] 브랜치 제거하기**

- 제거 대상이 아닌 브랜치로 이동한 상태

```
git branch --delete {제거할 브랜치명}
```

```
# 변경사항, 커밋 등이 있는 경우 무시하고 강제로 제거
git branch -D {제거할 브랜치명}
```

<br>

### **[7] 원격 브랜치 제거하기**

```
git push {원격 리포지토리 이름} :{제거할 원격 브랜치 이름}
```

```
# 예시
git push origin :dev-batch
```


<br>

# PAT 사용하여 Push하기
---

## **PAT** 
 - Personal Access Token

## **예시**
 - 내가 가진 토큰(PAT) ID : `abcd1234`
 - 대상 리포지토리 소유자 ID : rito02
 - 대상 리포지토리 이름 : repo01

```
git push https://abcd1234@github.com/rito02/repo01.git
```

## **활용**
 - "refusing to allow an OAuth App to create or update workflow" 에러 발생 시, workflow 체크된 PAT를 이용하여 push


<br>

# References
---
- <https://www.youtube.com/watch?v=Z9dvM7qgN9s>
- <https://blog.outsider.ne.kr/1505>

- <https://www.youtube.com/watch?v=FXDjmsiv8fI>
- <https://www.youtube.com/watch?v=GaKjTjwcKQo>