


# Insomnia Rest 설치
---

RestAPI를 테스트할 Insomnia Rest를 설치한다.

그리고 Create - Request Collection을 통해 요청 목록을 생성한다.

<br>


# 설치
---

```
npm i -g @nestjs/cli
```

<br>


# 프로젝트 생성
---

생성할 경로로 이동하여 다음 명령어를 실행한다.

```
nest new {프로젝트 이름}
```

<br>


# 프로젝트 구동
---

`package.json` 내부의 `scripts`에 있는 명령어를 따른다.

```
npm run start:dev
```

그리고 Node.js 기본 포트가 **3000**이므로,

**Nest.js** 역시 기본적으로 **3000** 포트에서 동작한다.

따라서 <http://localhost:3000>에서 확인할 수 있다.

근데 사실 `main.ts` 내부에서 포트를 설정할 수 있다.

<br>



# 진입점
---

## **main.ts**

```ts
import { NestFactory } from '@nestjs/core';
import { AppModule }   from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
```

<br>



# NestJS의 기본 파일 구성
---

## **[1] Module**

- app.module.ts
- 모듈은 컨트롤러와 서비스를 관리하며, 의존성 주입을 통해 컨트롤러가 서비스를 자동적으로 사용할 수 있게 해준다.

```ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

<br>

## **[2] Controller**

- 주로 URL을 가져와서 서비스의 함수를 실행하는 역할을 담당한다.
- 컨트롤러 클래스 프로퍼티로 서비스의 객체를 갖는다.
- express의 라우터와 같은 역할을 한다.

- 컨트롤러 클래스의 상단 `@Controller()` 데코레이터를 통해 해당 컨트롤러의 베이스 url을 지정할 수 있다.
- `@Controller()`는 루트(`/`)에서 라우팅이 시작된다.
- `@Controller('/api')`는 `/api/`에서부터 라우팅이 시작된다.

- 컨트롤러 내 각 메소드의 상단에 데코레이터(`@Get()` 등)를 붙여 라우팅을 지정한다.
- `@Controller('/api')`, `@Get('/id')`는 `/api/id`로부터 호출된다.

```ts
import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('/hi')
  getHi(): string {
    return 'hi';
  }
}
```

<br>

`@Post()`가 필요할 경우, 다음과 같이 임포트를 해야 한다.

```ts
import { Controller, Get , Post} from '@nestjs/common';
```

브라우저를 통한 URL 접근은 언제나 Get이고,

Post는 HTTP 또는 REST API를 통해 요청해야 한다.


<br>

## **[3] Service**

사실 컨트롤러에서 라우팅도 수행하고, 기능도 모두 작성할 수 있다.

따라서 서비스는 반드시 필요하지 않다.

그렇지만 라우팅 기능과 비즈니스 로직을 독립시켜 분리하기 위해 서비스가 존재한다.

```ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }
}
```


<br>



# 기초 문법
---

## **데코레이터(@)**

- `@`를 데코레이터라고 부르며, 클래스에 함수 기능을 추가하는 역할을 수행한다.
- C#의 애트리뷰트와 유사하다.


<br>

# References
---
- <https://nomadcoders.co/nestjs-fundamentals/lobby>