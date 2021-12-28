TITLE : React js Tutorial 2 - 컴포넌트와 JSX



# 컴포넌트(Component)
---

`index.js` 파일의 `import` 부분을 제외한 문장을 살펴보면

```js
ReactDOM.render(<App />, document.getElementById('root'));
```

이 문장이 전부다.

<br>

여기서 `<App />` 부분을 살펴본다.

`<이름 />` 꼴의 태그는 '컴포넌트'라고 부르며,

리액트는 기본적으로 컴포넌트 기반으로 동작한다.

항상 컴포넌트를 만들고, 사용하고, 공유하게 된다.

<br>



# 컴포넌트란?
---

`App.js` 파일의 내용을 살펴보면 다음과 같다.

```js
function App() {
  return (
    <div className="App">
      Hi
    </div>
  );
}
```

여기서 `App`이 바로 컴포넌트인데,

정의할 때는 `function App() {}`과 같이 정의하고

사용할 때는 `<App />`의 형태로 사용한다.

즉, 컴포넌트는 HTML을 반환하는 함수다.

<br>



# JSX
---

js 함수 내에 `HTML`이 포함된 형태를 `JSX`라고 하며,

리액트의 고유 개념이다.

<br>

`.js` 파일 내에 `JSX`가 사용된다는 것을 알리기 위해,

파일 상단에 다음과 같이 작성해야 한다.

```js
import React from "react";
```

<br>



# 컴포넌트 구성
---

`Potato`라는 이름의 새로운 컴포넌트를 작성한다.

```js
import React from "react";

function Potato() {
    return (
        <h3>
            I love Potato
        </h3>
    );
}

export default Potato;
```

이 때 `function`의 이름과 `export default`로 전달하는 이름은 일치해야 한다.

그리고 컴포넌트의 이름은 항상 대문자로 시작해야 한다.

<br>

그리고 다른 js 파일에서

```js
// App.js

import React from 'react';
import Potato from './Potato'; // 컴포넌트 임포트

function App() {
  return (
    <div className="App">
      Hi
      <Potato />               // 컴포넌트 사용
    </div>
  );
}

export default App;
```

이렇게 임포트하고 사용할 수 있는데,

이 때 `import Potato`와 `<Potato />`의 이름 역시 일치해야 한다.

<br>




# js 파일 작성 시 주의사항
---

소괄호는 반드시 K&R 스타일로 써야 한다.

```js
    return
    (
        <h3>
            I love Potato
        </h3>
    );
```

이렇게 사용하면 return 이후의 문장은 인식되지 않는다.

<br>




# index.js 파일 작성 시 주의사항
---

`index.js` 파일의 몸체 부분만 살펴보면 다음과 같다.

```js
ReactDOM.render(<App />, document.getElementById('root'));
```

여기서 꼭 지켜야 하는 것은,

`ReactDom.render()`의 첫 파라미터에는 단 하나의 컴포넌트만 넣을 수 있다는 것이다.


다시 말해, 아래와 같은 형태는 안된다.

```js
ReactDOM.render(<App /><Potato />, document.getElementById('root'));
```

<br>



# Props
---

**Props**는 **Properties**의 약어다.

컴포넌트를 정의하고 사용할 때, **Props**를 통해 데이터를 주고 받을 수 있다.

컴포넌트를 사용하는 부분에서 **Props**의 키(Key)와 값(Value)을 전달하고,

정의 부분에서 이름을 호출하여 값을 참조하게 된다.

대부분의 프로그래밍 언어에서 함수에 매개변수를 전달하는 것과 유사하다.

<br>



# Props 예제
---

```js
// App.js

import React from 'react';

function Food(props) {
  return <h3>I like {props.name}</h3>;
}

function App() {
  return (
    <div className="App">
      Hi, <Food name="banana" />
    </div>
  );
}

export default App;
```

<br>

## **[1] Key, Value 전달**

`Food` 컴포넌트를 사용하는 `App` 컴포넌트 내에서 다음과 같은 부분을 확인할 수 있다.

```js
<Food name="banana" />
```

여기서 **Props**의 **Key**는 `name`, **Value**는 `"banana"`가 된다.

<br>

## **[2] Props 사용**

```js
function Food(props) {
  return <h3>I like {props.name}</h3>;
}
```

`Food` 컴포넌트를 정의하는 부분에서 위와 같이 매개변수 부분에 `props`라는 변수를 정의한다.

이 때 변수 이름은 임의로 정해도 상관 없다.

그리고 함수 바디에서 `.key` 꼴로 **Props**의 **Key**를 참조하여, 해당하는 **Value**를 얻을 수 있다.

**JSX**의 HTML 태그 내에서 **Props**를 참조할 때는 `{}` 형태로 중괄호를 이용해 감싸주어야 한다.

<br>

## **[3] 여러 개의 Props**

```js
function Food(props) {
  return <h3>I like {props.color} {props.name}</h3>;
}

function App() {
  return (
    <div className="App">
      Hi, <Food name="banana" color="red" />
    </div>
  );
}
```

이렇게 **Key="Value"** 꼴을 병렬적으로 작성하여

여러 개의 **Props**를 전달하고 받아 사용할 수 있다.

각 **Prop**들은 공백으로 구분한다.

<br>

## **[4] Props 구조 분해**

비구조화 할당이라고도 불리며,

**Key-Value** 꼴의 **Props**를 하나로 묶어 받는 것이 아니라

```js
function Food({name, color}) {
  return <h3>I like {color} {name}</h3>;
}

function App() {
  return (
    <div className="App">
      Hi, <Food name="banana" color="red" />
    </div>
  );
}
```

이렇게 함수 시그니쳐의 매개변수 부분에 `{key1, key2, ...}` 꼴로

전달받을 **Props**를 펼쳐서 받아 사용할 수 있다.

전달하였으나 받지 않을 수도 있고, 전달하지 않았으나 받을 수도 있다.

후자의 경우에는 `defaultProps`를 통해 기본 값을 지정할 수 있다.

```js
function Food({name, color}) {
  return <h3>I like {color} {name}</h3>;
}

function App() {
  return (
    <div className="App">
      Hi, <Food name="banana" />
    </div>
  );
}

Food.defaultProps = {
  color: 'red'
}
```

<br>

## **다양한 타입의 Props**

지금까지의 예제와 같이 문자열 타입으로 전달할 수도 있고,

`object`, `array`, `boolean` 등 다양한 타입으로 전달하고 받을 수도 있다.

전달할 때 기본적으로 `key = {value}`꼴로 **Value**를 중괄호로 감싼다.

문자열은 중괄호를 생략할 수 있다.

```js
function Food({name, color, obj, arr}) {
  return (
    <div>
      <h3>I like {color} {name}</h3>
      <h3>{obj.a}</h3>
      <h3>{arr}</h3>
    </div>
  );
}

function App() {
  return (
    <div className="App">
      Hi, <Food 
            name="banana"               // 스트링
            obj={{a: "apple"}}          // 오브젝트
            arr={["A", "B", "C", true]} // 배열
          />
    </div>
  );
}
```

<br>



# References
---
- [Nomad Coder Youtube](https://www.youtube.com/playlist?list=PL7jH19IHhOLPp990qs8MbSsUlzKcTKuCf)
- <https://react.vlpt.us/basic/05-props.html>