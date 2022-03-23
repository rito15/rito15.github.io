TITLE : React JS Tutorial 3



# Map
---

```js
const genshinCharacterList = [

    {
        id: 0,
        name: "라이덴 쇼군",
        image: "https://w.namu.la/s/f194cc47805d07a719f60d0b63bb92cc1b7a1e0196cb34a7f2f2cbdc61b491cd699565d6199d394c55d0dbc343f051ebd40fa82168c1cb0611237667665e7988d6e648c743a70e4e60d490ae87fe96e2"
    },
    {
        id: 1,
        name: "야에 미코",
        image: "https://img.onnada.com/2021/0822/thumb_991469724_3053070f_462_p0.png"
    },
    {
        id: 2,
        name: "각청",
        image: "https://primewikis.com/wp-content/uploads/ib8j809rqa2mz60e_1602159530.jpeg"
    }
];

// Component
function Character({name, image}){
    return (
        <div>
            <h3>{name}</h3>
            <img src={image} />
        </div>
    )
}

function renderCharacter(c){
    return <Character key={c.id} name={c.name} image={c.image} />;
}

function App(){
    return GenshinCharacterList.map(renderCharacter);
}
```



# Prop Types
---

프로퍼티의 타입 제약 추가

```
npm install prop-types
```

```js
// ...
import PropTypes from 'prop-types';

// Component
function Character({name, image}){
    return (
        <div>
            <h3>{name}</h3>
            <img src={image} />
        </div>
    )
}

Character.propTypes = {
    name: PropTypes.string.isRequired,
    image: PropTypes.string.isRequired
}
```

`컴포넌트명.propTypes = `를 작성할 때 반드시 `propTypes`의 첫글자를 소문자로 작성해야 한다.



# React Class Component
---

기존의 컴포넌트는 Function Component 방식

컴포넌트가 상태를 저장해야 할 경우, Class Component로 작성한다.

그렇지 않으면 그냥 Function Component로 작성하면 된다.

```js
class App extends React.Component{
    state = {
        count: 0
    };

    addFunc = () => {
        console.log("add");
        this.setState({count: this.state.count + 1});
    }

    subFunc = () => {
        console.log("sub");
        this.setState(current => ({count: current.count - 1}));
    }

    render(){
        return (
            <div>
                <h1>The number is : {this.state.count}</h1>
                <button onClick={this.addFunc}>Add</button>
                <button onClick={this.subFunc}>Sub</button>
            </div>
        )
    }
}
```


## NOTE : state 오브젝트

React.Component 클래스에는 state 오브젝트가 존재하며,

자식 클래스에서 재정의하여 사용할 수 있다.


## NOTE : 상태 변경

this.state.count를 바꾸고 싶을 때 값을 직접 바꾸면

일단 값은 바뀌기는 하지만, 화면 렌더 상태 변경 적용이 안된다.

따라서 setState() 함수를 통해 값을 바꿔야 하며,

함수 호출 직후 render()가 자동으로 호출되어 렌더 상태 변경이 수반된다.


## NOTE : 올바른 상태값 변경 방법

addFunc()처럼 `this.state.count`에 직접 접근하는 것은 좋지 않음

subFunc()처럼 현재 상태 오브젝트를 `current`로 받아와서 접근하는 것이 올바른 방법



# React.Component Lifecycle
---

- https://ko.reactjs.org/docs/react-component.html


## [1] Mount(시작)

- constructor()
- render()
- componentDidMount()

```js
class App extends React.Component{

    constructor(props){
        super(props);
        console.log("constructor");
    }

    render(){
        console.log("render");
        // ...
    }

    componentDidMount(){
        console.log("componentDidMount");
    }
}
```


## [2] Update

- render()
- componentDidUpdate()

```js
class App extends React.Component{

    render(){
        console.log("render");
        // ...
    }

    componentDidUpdate(){
        console.log("compoentDidUpdate");
    }
}
```



# 상태 관련 팁
---

```js
class App extends React.Component {
    state = {
        // ...
    };
}
```

`state` 프로퍼티에 미리 작성하지 않았던 값들이라도,

나중에 `this.setState({ isReady: true})` 처럼

내부 변수를 아예 새롭게 추가하여 넣어줄 수 있다.

그러니 미리 `state` 내에 변수들을 작성해놓을 필요는 없다.

하지만 어떤 변수들을 사용할 것인지 미리 작성해놓으면 좋기는 하다.



# 초기 데이터 로드
---

데이터 초깃값들을 로드하는 작업은 `componentDidMount()` 함수에 작성한다.

```js
class App extends React.Component {
    state = {
        isLoaded = false
    };
    
    componentDidMount() {
        this.setState({ isLoaded: true});
    }
}
```



# 비구조화 할당(분해)
---

```js
class App extends React.Component {
    state = {
        isLoaded = false
    };
    
    render() {
        return (
            <h1>
                {this.state.isLoaded ? "Load Completed" : "Loading..."}
            </h1>
        );
    }
}
```

위와 같이 매번 `this.state.isLoaded`처럼 쓰는 것은 번거로우니까

다음과 같이 함수 내에서 분해하여 간편히 사용할 수 있다.

```js
render() {
    
    const { isLoaded } = this.state;
    
    return (
        <h1>
            { isLoaded ? "Load Completed" : "Loading..." }
        </h1>
    );
}
```

만약 여러 변수를 가져올 경우, 이름을 맞춰서 작성하면 된다.

반드시 이름을 일치시켜야 한다.

```js
render() {
    
    const { isLoaded, count, number, id } = this.state;
    
    return (
        <h1>
            { isLoaded ? "Load Completed" : "Loading..." }
            { count }
            { number }
            { id }
        </h1>
    );
}
```




# 데이터 패치(Fetch) : Axios
---

fetch는 HTTP 요청을 하여 결과를 받아오는 JS 내장 함수다.

비슷하게 Axios가 있는데, 별도의 설치가 필요하다.

```
npm install axios
```

YTS 사이트에서 영화 목록을 가져오는 예제를 작성할 것이며,

https://github.com/serranoarevalo/yts-proxy

위 링크의 API를 사용한다.

예를 들어 영화 목록을 JSON 포맷으로 가져오는 api는 다음과 같다.

```
https://yts-proxy.now.sh/list_movies.json
```

<br>

별도의 함수를 만들고 async/await를 사용하여 다음과 같이 작성한다.

```js
getMovies = async () => {
    const movies = await axios.get("https://yts-proxy.now.sh/list_movies.json");
}

componentDidMount(){
    this.getMovies();
}
```

결과로 얻는 데이터는 `movies`로부터 `movies.data.data.movies`로 얻을 수 있는데,

```js
getMovies = async () => {
    const movies = await axios.get("https://yts-proxy.now.sh/list_movies.json");
    
    console.log(movies.data.data.movies);
}
```

이를 ES6 문법을 통해 변수에 예쁘게 얻어올 수 있다.

```js
getMovies = async () => {
    const { data: { data: { movies } } } = 
        await axios.get("https://yts-proxy.now.sh/list_movies.json");
    
    console.log(movies);
}
```

<br>

이제 이 `movies`를 `state` 내에 넣어준다.

```js
getMovies = async () => {
    const { data: { data: { movies } } } = 
        await axios.get("https://yts-proxy.now.sh/list_movies.json");
    
    this.setState({ movies });
}
```

`this.setState({ movies: movies })`는 위와 같이 간단히 `this.setState({ movies })`로 줄일 수 있다.



# Movie 컴포넌트
---

영화를 렌더링할 별도의 컴포넌트를 작성한다.

아예 새로운 파일을 작성하여 영화 관련 기능을 모두 작성한다.

상태는 필요 없으므로 Function Component로 만든다.

```js
import React from "react";
import PropTypes from "prop-types";
import axios from "axios";

// Component
function Movie({id, year, title, summary, poster}) {

    return (
        <div>
            <h4>
                {title}({year})
            </h4>
            <img src={poster} /> <br/>
            <h5>
                {summary}
            </h5>
        </div>
    );
}

Movie.propTypes = {
    id:      PropTypes.number.isRequired,
    year:    PropTypes.number.isRequired,
    title:   PropTypes.string.isRequired,
    summary: PropTypes.string.isRequired,
    poster:  PropTypes.string.isRequired
};

async function getMovies (callback) {
    const { data: { data: { movies } } } = 
        await axios.get("https://yts-proxy.now.sh/list_movies.json?sort_by=rating");

    callback(movies);
}

function renderMovie(movie) {
    return <Movie 
        id = {movie.id}
        key = {movie.id}
        year = {movie.year}
        title = {movie.title}
        summary = {movie.summary}
        poster = {movie.medium_cover_image}
    />;
}

export {getMovies, renderMovie};
```

이제 `Movie` 컴포넌트조차 아예 감출 수 있게 되었다.

`getMovies()` 함수도 `App` 컴포넌트에서 꺼내어 여기로 옮기고,

비동기 후속 동작은 콜백으로 호출할 수 있도록 매개변수도 넣어준다.

`App` 컴포넌트에서 필요한 것은 `getMovies()`, `renderMovie()` 함수이므로

이 두가지만 오브젝트에 담아 익스포트한다.

<br>

그리고 `App.js`에서는

```js
import React from 'react';
import {getMovies, renderMovie} from './Movie';

class App extends React.Component{
    state = {
        isReady: false,
        movies: []
    };

    componentDidMount(){
        getMovies(movies => {
                this.setState({ movies, isReady: true });
                console.log(movies);
            }
        );
    }

    render(){
        const { isReady, movies } = this.state;

        return (
            <div>
                <h4>{isReady ? movies.map(renderMovie) : "Loading..."}</h4>
            </div>
        )
    }
}

export default App;
```

이렇게 깔끔하게 작성할 수 있다.




# References
---
- [Nomad Coder Youtube](https://www.youtube.com/playlist?list=PL7jH19IHhOLPp990qs8MbSsUlzKcTKuCf)