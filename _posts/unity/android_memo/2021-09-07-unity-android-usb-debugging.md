---
title: 유니티 안드로이드 USB 디버깅하기
author: Rito15
date: 2021-09-07 16:49:00 +09:00
categories: [Unity, Unity Android Memo]
tags: [unity, android, memo]
math: true
mermaid: true
---

# LogCat 패키지 설치
---

![image](https://user-images.githubusercontent.com/42164422/132323492-7c8affc2-e573-4ff5-8251-2271351988aa.png)

<br>

# USB 디버깅 허용
---

- 기기마다 방법이 다를 수 있다.
- <https://support-mirroring.mobizen.com/hc/ko/articles/216761537-USB-디버깅-모드-설정방법-안내>

- `설정`
- `휴대폰 정보`
- `소프트웨어 정보`
- `빌드 번호` 연속 7번 터치

- `설정`
- `개발자 옵션`
- `USB 디버깅` 체크

<br>

# USB 연결 및 앱 실행
---

- USB를 안드로이드 기기에 연결한다.

- 빌드된 앱을 기기에서 실행한다.

- `Build And Run`을 통해 빌드하자마자 기기에서 실행할 수도 있으며,<br>
  이를 이용하면 변경사항이 생겼을 때 `apk` 파일을 직접 교체하지 않고 변경사항을 적용할 수 있다.

<br>

# 로그캣 확인
---

- `Window` - `Analysis` - `Android Logcat`

- 상단 메뉴 중앙에서 `Filter`를 설정하여, 로그를 확인할 앱을 지정한다.

![image](https://user-images.githubusercontent.com/42164422/132324856-ca78654f-7877-4e05-9c39-73465bcfe99d.png)

