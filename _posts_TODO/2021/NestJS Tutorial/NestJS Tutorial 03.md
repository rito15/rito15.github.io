

# 구조 변경 및 Movies 모듈 생성
---

`app.module` 내부에는 `AppController`와 `AppService`만 가지고 있어야 한다.

그리고 필요한 것들은 모듈 단위로 `import`에 넣어주고,

각 모듈마다 `Controller`와 `Service`를 통해 구현하는 구조를 가지는 것이 합리적이다.

<br>

따라서 `Movies` 모듈을 생성한다.

```
nest g mo movies
```

<br>

이제 `App` 모듈과 `Movies` 모듈을 다음과 같이 수정한다.

```ts
// app.module.ts

import { Module } from '@nestjs/common';
import { MoviesModule } from './movies/movies.module';

@Module({
  imports: [MoviesModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
```

```ts
// movies.module.ts

import { Module } from '@nestjs/common';
import { MoviesController } from './movies.controller';
import { MoviesService } from './movies.service';

@Module({
  imports: [MoviesModule],
  controllers: [MoviesController],
  providers: [MoviesService],
})
export class MoviesModule {}
```

<br>


# App Controller, Service 생성
---

```
nest g co app
nest g s app
```

`App` 컨트롤러는 기본적으로 루트 경로에 대한 라우팅을 수행한다.

따라서 지금은 그냥 다음과 같이 작성해주면 된다.

```ts
import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {

    @Get()
    homepage(): string {
        return 'hello';
    }
}
```

그리고 이 경우, 서비스는 딱히 할 일이 없다.



<br>

# References
---
- <https://nomadcoders.co/nestjs-fundamentals/lobby>