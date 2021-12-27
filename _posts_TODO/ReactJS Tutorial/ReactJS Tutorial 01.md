TITLE : React JS Tutorial 01 - 설치


# 필수 요소 설치
---

리액트JS를 사용하기 위해서는 다음을 설치해야 한다.

- [NodeJS](https://nodejs.org/ko/)
- NPM(NodeJS와 함께 설치됨)
- NPX(`npm install npx -g` 명령어 입력)

<br>



# 설치 확인
---

NodeJS, NPM, NPX는 각각 다음 cmd 명령어들을 통해 설치 여부를 확인할 수 있다.

```
node -v
```

```
npm -v
```

```
npx -v
```

<br>



# Git 설치
---

- <https://git-scm.com/downloads>

- 설치 확인 : `git --version`

<br>



# Create React App
---
- 리액트 애플리케이션의 초기 환경 구축을 빠르게, 자동으로 해준다.
- <https://github.com/facebook/create-react-app>

<br>

## **리액트 프로그램 기본 환경 구축**
- CLI에서 프로그램 기본 디렉토리로 이동한다.
- 다음 명령어를 입력한다.

```
npx create-react-app {프로젝트 이름}
```

- 위에서 입력한 `프로젝트 이름`이 폴더명이 되어, 새로운 디렉토리 내에 리액트 초기 프로그램이 구축된다.
- `프로젝트 이름`에는 공백, 영문 대문자가 포함될 수 없다.

<br>

- 결과

![image](https://user-images.githubusercontent.com/42164422/147469352-74a46f3d-4bf8-4515-b1c4-0c8fa907c4c2.png)

<br>



# VS Code로 작업 영역 실행
---

```
code {디렉토리 이름}
```

위 명령어를 통해, VS Code에서 작업 영역을 곧바로 실행할 수 있다.

<br>



# 로컬 호스트로 실행
---

- 해당 프로젝트 디렉토리에서 다음 명령어를 실행하면 <http://localhost:3000/> 애플리케이션이 로컬 호스트에 호스팅된다.

```
npm start
```

<br>




# Git 리포지토리 구축
---

- 깃헙에서 원격 리포지토리를 생성한다.
- `Readme.md`, `.gitignore` 등은 생성하지 말고 날것의 상태로 생성한다.

<br>

- 만약 프로젝트 디렉토리에 `.git` 폴더가 존재하지 않으면, 우선 다음 명령어를 입력한다.

```
git init
```

<br>

- 프로젝트 디렉토리에서 CLI로 다음 명령어들을 입력한다.

```
git branch -M main      # 기본 master 브랜치명을 main으로 변경
git add .               # 디렉토리 내 모든 파일들을 업로드 대상으로 추가
git commit -m "Init"    # 커밋 내용 입력
git remote add origin {원격 리포지토리 주소}   # 원격 리포지토리를 origin이라는 이름으로 로컬 리포지토리에 등록
git push -u origin main                 # main 브랜치의 내용을 origin에 업로드하면서, push 기본 대상으로 설정
```

<br>

- 이제 변경사항을 원격 리포지토리에 적용할 때 다음 명령어들을 입력하면 된다.

```
git add .
git commit -m "{커밋 내용}"
git push
```

<br>


# 튜토리얼 초기 환경 구축하기
---

## **[1] 제거**

다음 파일들을 제거한다.

- `App.css`
- `App.test.js`
- `index.css`
- `reportWebVitals.js`
- `setupTests.js`
- `logo.svg`

<br>

## **[2] 수정**

다음 파일들의 내용을 수정한다.

<br>

### **[2-1] README.md**
- 싹다 비우고 다음과 같이 작성한다.

```md
# 프로젝트명

- 간단한 설명
```

<br>

### **[2-2] index.js**
- 다음과 같이 수정한다.

```js
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
```

<br>

### **[2-3] App.js**
- 다음과 같이 수정한다.

```js
import React from 'react';

function App() {
  return (
    <div className="App">
      Hi
    </div>
  );
}

export default App;
```

<br>

## **결과**

`src` 폴더 내에는 `index.js`, `App.js`만 남았다.

이 상태가 리액트의 최소 환경 상태이며,

`index.js`는 리액트의 진입점 역할로서 `App.js`의 `App()` 함수를 호출하고,

`App()` 함수에는 HTML 문서의 내용을 작성하게 된다.

<br>


# References
---
- [Nomad Coder Youtube](https://www.youtube.com/playlist?list=PL7jH19IHhOLPp990qs8MbSsUlzKcTKuCf)