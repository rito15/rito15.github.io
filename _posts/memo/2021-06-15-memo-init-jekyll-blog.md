---
title: Jekyll 블로그 만들기 간단 메모
author: Rito15
date: 2021-06-15 14:55:00 +09:00
categories: [Memo]
tags: [memo]
math: true
mermaid: true
---

# Start Jekyll Blog
---

## 1. Ruby 설치

- <https://rubyinstaller.org/downloads/>
- 2.7.3

<br>

## 2. Jekyll Bundler 설치

- cmd 켰을 때 나오는 사용자 기본 경로에 설치

```
gem install jekyll bundler
```

<br>

## 3. 블로그용 깃헙 원격 리포 준비

- 리포 이름은 `닉네임.github.io`

<br>

## 4. 로컬 리포 준비

- 원격 리포랑 연결

```
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin [깃헙 원격 리포 주소]
git push -u origin main
```

<br>

## 5. Jekyll 테마 다운로드

- <http://jekyllthemes.org/>

- 로컬 리포에 그대로 넣어주기

<br>

## 6. 번들 설치

- cmd로 해당 로컬 리포 경로에 이동 후

```
bundle install
```

<br>

간혹 에러를 띄우는 경우가 있는데, 에러 메시지에

```
To update to the latest version installed on your system, run `bundle update --bundler`
```

라던가

```
To install the missing version, run `gem install bundler:1.16.3`
```

같은게 써있다면,

그대로 잘 실행해주고 다시 `bundle install` 해주면 된다.

<br>

## 7. 로컬호스트로 실행

```
bundle exec jekyll serve
```

- <http://localhost:4000>

<br>

## 8. docs 폴더에 내용물 넣어주고 깃헙 업로드

```
echo Y| rmdir docs /s
mkdir docs
xcopy "_site\*.*" "docs\" /e /y

git pull
git add .
git commit -m "Upload"
git push
```

<br>

## 9. [최초 한번만] 깃헙 페이지 설정

- 원격 리포 - `Settings` - `Pages`
- `Source` - `Branch:main` - `/docs` - `Save`

<br>

# Themes
---

## 1. 깔끔한 블로그 테마

- <http://jekyllthemes.org/themes/lokmont/>
- <https://supunkavinda.github.io/jekyll-theme-leaf/>
- <http://jekyllthemes.org/themes/agency/>
- <http://jekyllthemes.org/themes/jekyll-for-everyone/>
- <http://jekyllthemes.org/themes/jekyll-theme-prologue/>
- <http://jekyllthemes.org/themes/business-jekyll-theme/>
- <http://jekyllthemes.org/themes/future-imperfect/>
- <http://jekyllthemes.org/themes/massively/>
- <http://jekyllthemes.org/themes/adam-blog/>
- <http://jekyllthemes.org/themes/panelcvagain/>
- <http://jekyllthemes.org/themes/bef/>
- <http://jekyllthemes.org/themes/hydeout/>
- <http://jekyllthemes.org/themes/millennial/>
- <http://jekyllthemes.org/themes/basically-basic/>
- <http://jekyllthemes.org/themes/fullit/>
- <http://jekyllthemes.org/themes/console/>
- <http://jekyllthemes.org/themes/sleek/>
- <http://jekyllthemes.org/themes/karna/>
- <http://jekyllthemes.org/themes/vyaasa/>

<br>

## 2. 개발 블로그용 테마

- <http://jekyllthemes.org/themes/jekyll-theme-chirpy/>
- <http://jekyllthemes.org/themes/alembic/>


<br>

## 3. 포트폴리오용 테마

- <http://jekyllthemes.org/themes/zolan/>
- <http://jekyllthemes.org/themes/slate-and-simple/>
- <http://jekyllthemes.org/themes/flexible-jekyll/>
- <http://jekyllthemes.org/themes/panelcv/>
- <http://jekyllthemes.org/themes/dactl/>
- <http://jekyllthemes.org/themes/particle/>
- <http://jekyllthemes.org/themes/materialbliss/>
- <http://jekyllthemes.org/themes/online-cv/>

## 4. 설명 문서용 테마

- <http://jekyllthemes.org/themes/edition/>
- <http://jekyllthemes.org/themes/papyrus-theme/>
