TITLE : React JS Tutorial 4



# CSS 사용하기
---

예를 들어 `Movie.js` 파일이 있다면

같은 경로에 `Movie.css` 파일을 만들고

`Movie.js` 파일 내부 상단에

```js
import './Movie.css';
```

이렇게만 해주면 바로 JSX 태그들에 CSS가 적용된다.

<br>




# 깃헙 페이지에 배포하기
---

## **모듈 다운로드**

`gh-pages` 모듈을 다운받는다.

```
npm install gh-pages
```

<br>

## **package.json 수정**

`package.json` 파일 마지막에 다음을 추가한다.

```json
"homepage": "https://rito15.github.io/React-Beginning"
```

`https://{깃 ID}.github.io/{프로젝트 이름}` 꼴로 작성하면 된다.

<br>

`package.json` 파일 중간의 `scripts` 내부에 다음과 같이 추가한다.

```json
"scripts": {

  // ...
  
  "deploy": "gh-pages -d build",
  "predeploy": "npm run build"
},
```

<br>

## **Github-Pages에 배포**

```
npm run deploy
```

위와 같이 명령어를 입력하면 해당 깃 원격 리포지토리의 `gh-pages` 브랜치에 `build` 폴더의 내용들이 업로드된다.

이 때 주의사항은 다음과 같다.

1. 리포지토리는 public으로 설정되어야 한다.
2. 리포지토리 Pages 설정에서 Source의 브랜치를 gh-pages /(root)로 설정해야 한다.

<br>



# 라우터
---

## **리액트 라우터 모듈 설치**

```
npm install react-router-dom
```

<br>


## **파일시스템 구조 변경**

`Movie.js`, `Movie.css`는 `src/components` 폴더로 옮긴다.

`App.js`, `App.css`의 내용은 각각 새로운 파일 `Home.js`, `Home.css`에 옮기고,

컴포넌트 이름을 `App`에서 `Home`으로 변경한다.

그리고 `Home.js`, `Home.css` 파일은 `src/routes` 폴더로 옮긴다.

`App.css`는 제거한다.

`src/routes` 폴더 내에 `About.js` 파일을 만든다.

<br>

## **HashRouter, BrowserRouter**

```js
import { BrowserRouter, Routes, Route } from "react-router-dom";
```

이렇게 임포트해서 사용하면 되고,

`HashRouter`를 사용할거면 그냥 `BrowserRouter` 대신 사용하면 된다.

`BrowserRouter`는 루트 경로로부터 `/someRoute` 이렇게 이어지고,

`HashRouter`는 `/#/someRoute` 이렇게 이어지게 된다.

<br>

`App.js`를 다음과 같이 작성하면 된다.

```js
import React from 'react'
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./routes/Home";
import About from "./routes/About";

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Home/>} />
                <Route path="/about" element={<About/>} />
            </Routes>
        </BrowserRouter>
    );
}

export default App;
```

`react-router-dom` 5버전까지는 `<Routes>` 태그를 쓰지 않아도 됐지만,

6버전부터는 저렇게 `<Routes></Routes>` 태그로 `<Route>` 태그들을 감싸야 한다.

그리고 `component={컴포넌트}` 대신 `element={<컴포넌트 />}`를 사용해야 한다.

<br>

강좌 버전이 5버전인 관계로, 버전을 변경하여 다시 설치한다.

```
npm install react-router-dom
```

그리고 `App.js`도 수정한다.

```js
import React from 'react'
import { HashRouter, Route } from "react-router-dom";
import Home       from "./routes/Home";
import About      from "./routes/About";

function App() {
    return (
        <HashRouter>
            <Route path="/" exact component={Home} />
            <Route path="/about" component={About} />
        </HashRouter>
    );
}

export default App;
```

<br>

`about` 페이지를 열었을 때 `/` 페이지의 내용이 함께 렌더링되는 경우가 있는데,

`/about` 라우트에 접근하면서 `/`, `/about`에 모두 매칭하게 되기 때문이다.

이럴 때는 `/` 라우트 태그에 `<Route exact={true}>` 이렇게 속성을 넣어주면 된다.

<br>

만약 깃헙 페이지로 배포할 경우, `BrowserRouter`를 사용하면 루트 설정이 굉장히 번거롭다.

루트를 `닉네임.github.io/프로젝트명/`으로 인식해야 하는데,

`닉네임.github.io/`로 인식하는 문제가 발생한다.

따라서 깃헙 페이지로 배포하려면 `HashRouter`를 사용하는 것이 간편하다.

<br>



# 네비게이션
---

`src/components` 폴더에 `Navigation.js`, `Navigation.css`를 만든다.

```js
// Navigation.js

import React from "react";
import { Link } from "react-router-dom";
import "./Navigation.css";

function Navigation() {
    return (
        <div className="nav">
            <Link to="/">Home</Link>
            <Link to="/about">About</Link>
        </div>
    );
}

export default Navigation;
```

`<a href="">` 대신 `<Link to="">` 태그를 사용한다.

`<a>` 태그는 이동할 때 리디렉션을 통해 아예 페이지를 새로 로드하지만,

`<Link>` 태그는 리디렉션을 하지 않는다는 장점이 있다.

대신, `<Link>` 태그는 반드시 라우터 종류의 태그 내부에 있어야만 한다.

<br>

그리고 `App` 컴포넌트에 `Navigation` 컴포넌트를 호출하는 부분을 추가한다.

```js
function App() {
    return (
        <HashRouter>
            <Navigation />
            <Route path="/" exact component={Home} />
            <Route path="/about" component={About} />
        </HashRouter>
    );
}
```

<br>



# 영화 상세 페이지로 이동하기
---

## **Detail.js**

홈에서 각 영화 카드를 클릭하면 상세 정보 페이지로 이동하는 라우트를 추가할 것이다.

우선, `source/routes` 폴더에 `Detail.js` 파일을 만든다.

그리고 다음과 같이 작성한다.

```js
import React from "react";

class Detail extends React.Component {
  componentDidMount() {
    const { location, history } = this.props;
    if (location.state === undefined) {
      history.push("/");
    }
  }
  render() {
    const { location } = this.props;
    if (location.state) {
      return <span>{location.state.title}</span>;
    } else {
      return null;
    }
  }
}
export default Detail;
```

홈에서 영화 카드 클릭을 통해 상세 페이지로 이동했을 때, 해당 정보를 `Detail` 페이지로 전달한다.

그리고 이 정보를 전달받고 기억하기 위해 `Detail` 컴포넌트는 함수가 아닌 클래스 컴포넌트여야 한다.

<br>

## **App.js**

`App` 컴포넌트에 라우트를 추가하여 다음과 같이 수정한다.

```js
function App() {
    return (
        <HashRouter>
            <Navigation />
            <Route path="/" exact component={Home} />
            <Route path="/about" component={About} />
            <Route path="/movie/:id" component={Detail} />
        </HashRouter>
    );
}
```

<br>

## **Movie.js**

이제 `Movie` 컴포넌트를 수정하여,

각각의 영화 카드 클릭 시 상세 페이지로 이동하도록 한다.

`<Link>` 태그로 영화 카드를 감싸고, `to` 프로퍼티 오브젝트의 `state` 프로퍼티에 필요한 내용들을 넣어준다.

```js
function Movie({ id, year, title, summary, poster, genres }) {
    const imgOnErr = "https://rito15.github.io/assets/img/favicons/android-icon-192x192.png";

    return (
        <div className="movie">
            <Link
                to={{
                    pathname: `/movie/${id}`,
                    state: {
                        year,
                        title,
                        summary,
                        poster,
                        genres
                    }
                }}
            >
                <img src={poster} alt={title} title={title} 
                onError={e => e.target.src=imgOnErr}/>
                <div className="movie__data">
                    <h3 className="movie__title">{title}</h3>
                    <h5 className="movie__year">{year}</h5>
                    <ul className="movie__genres">
                        {genres.map((genre, index) => (
                            <li className="genres__genre" key={index}>
                                {genre}
                            </li>
                        ))}
                    </ul>
                    <p className="movie__summary">{summary.slice(0, 180)}...</p>
                </div>
            </Link>
        </div>
    );
}
```

<br>

## **Detail.js 꾸미기**

위에서는 타이틀 텍스트만 간단히 보여줬지만, `Detail.css`도 추가하고

타이틀, 연도, 포스터 이미지, 요약 설명까지 보여주도록 꾸며준다.

```js
// Detail.js

import React from "react";
import "./Detail.css";

class Detail extends React.Component {
  componentDidMount() {
    const { location, history } = this.props;

    if (location.state === undefined) {
      history.push("/");
    }
  }
  render() {
    const { location } = this.props;

    //console.log(this);

    if (location.state) {
        const {title, year, summary, poster} = location.state;

      return (
          <div className="movie_details">
              <div className="movie_details__poster">
                <img src={poster}/>
              </div>
              <h2>&lt;{title}({year})&gt;</h2>
              <h4>{summary}</h4>
          </div>
      );
    } else {
      return null;
    }
  }
}
export default Detail;
```

```css
// Detail.css

.movie_details {
    display: block;
    width: 100%;
    margin-top: 100px;
    justify-content: center;
    align-items: center;
    text-align: center;
}

.movie_details h4 {
    width: 40%;
    margin-left: 30%;
    justify-content: center;
    align-items: center;
    text-align: left;
}
```



# References
---
- [Nomad Coder Youtube](https://www.youtube.com/playlist?list=PL7jH19IHhOLPp990qs8MbSsUlzKcTKuCf)