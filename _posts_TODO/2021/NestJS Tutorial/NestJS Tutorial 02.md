

# 프로젝트 초기 세팅
---

- `app.controller.ts`, `app.service.ts`를 지운다.

- `app.module.ts`는 다음과 같이 수정해준다.

```ts
import { Module } from '@nestjs/common';

@Module({
  imports: [],
  controllers: [],
  providers: [],
})
export class AppModule {}
```

<br>


# 새로운 컨트롤러 Movies 생성
---

```
nest generate controller {컨트롤러 이름}
nest g co {컨트롤러 이름}
```

위 명령어를 통해 새로운 컨트롤러 파일을 생성할 수 있다.

다음과 같이 명령어를 입력하여 `Movies` 컨트롤러를 만든다.

```
nest g co movies
```

<br>

그럼 이제 다음과 같이 `movies.controller.ts` 파일이 생성되고,

```ts
import { Controller, Get } from '@nestjs/common';

@Controller('movies')
export class MoviesController {}
```

기본 경로는 `/movies`로 설정된 것을 확인할 수 있다.

<br>



# Movies 컨트롤러
---

기본적으로 <http://localhost:3000/movies/> 경로로부터 Movies 컨트롤러로 연결된다.

우선, 기본 경로에 대한 함수를 다음과 같이 작성한다.

```ts
import { Controller, Get, Param } from '@nestjs/common';

@Controller('movies')
export class MoviesController {

    @Get()
    getAll() {
        return 'All Movies';
    }
}
```

<br>

## **URL 파라미터 사용**

```ts
@Get(':id')
getOne(@Param('id') id:string) {
    return `Get Movie With ID ${id}`;
}
```

위와 같이 `@Get(':id')`를 통해 `/movies/123` 꼴의 URL로부터 `id` 파라미터를 가져올 수 있는데,

매개변수에 `@Param('id')` 데코레이터를 사용해야 한다.

그리고 URL로부터 들어오는 값은 기본적으로 스트링이다.

<br>

## **REST API**

Rest API에는 `GET`, `POST`, `PUT`, `PATCH`, `DELETE`가 있다.

각각 다음과 같다.

- `GET` : 요청을 URL에 담아서 보낸다.
- `POST` : 요청을 Request body에 담아서 보낸다. CRUD 중 C에 속한다.
- `PUT` : 지정 대상 전체를 수정한다. 전달하지 않은 내용은 `null` 값이 되어버리므로, 전체 수정에 사용된다. CRUD 중 U에 속한다.
- `PATCH` : 지정 대상 일부를 수정한다. 수정할 내용만 담아서 보내면 된다. CRUD 중 U에 속한다.
- `DELETE` : 지정 대상을 지운다. CRUD 중 D에 속한다.

<br>

## **REST API별 함수 작성**

```ts
import { Controller, Get, Post, Delete, Patch, Param } from '@nestjs/common';

@Controller('movies')
export class MoviesController {

    @Get()
    getAll() {
        return 'All Movies';
    }

    @Get(':id')
    getOne(@Param('id') id:string) {
        return `Get Movie With ID ${id}`;
    }

    @Post()
    create() {
        return 'Create New Movie';
    }

    @Patch(':id')
    modifyOne(@Param('id') id:string) {
        return `Modify Movie With ID ${id}`
    }

    @Delete(':id')
    deleteOne(@Param('id') id:string) {
        return `Delete Movie With ID ${id}`;
    }
}
```

<br>

## **Request Body 받아 처리하기**

매개변수 데코레이터 `@Body()`를 통해 Request Body를 받아 사용할 수 있다.

`URL/movies/123` 꼴로 요청할 수 있다.

```ts
@Post()
create(@Body() movieData) {
    return movieData;
}

@Patch(':id')
modifyOne(@Param('id') id:string, @Body() updateData) {
    return {
        updatedID: id,
        ...updateData
    };
}
```

<br>

## **URL Parameter 받아 처리하기**

Get 요청의 URL 내부의 파라미터 값을 받아 사용할 수 있다.

`URL/movies/search?year=2020` 꼴로 요청할 수 있다.

```ts
@Get('search')
search(@Query('year') seahrchingYear:string){
    return `Searching For Movie After ${seahrchingYear}`;
}
```

위 메소드가 클래스 내에서 `@Get(':id')` 하단이 있으면

`search` 자체가 `id`로 인식될 수 있으므로,

반드시 `@Get(':id')` 상단에 위치시킨다.

<br>



# Movies 서비스 생성
---

다음 명령어를 실행한다.

```
nest g s movies
```

그럼 `movies/movies.service.ts` 파일이 생성된다.

```ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class MoviesService {}
```

그리고 컨트롤러를 생성했을 때와 마찬가지로,

`app.module.ts`에 자동적으로 임포트된다.

<br>



# Movie 엔터티 생성
---

`movies` 폴더 내부에 `entities` 폴더를 만들고,

그 안에 `movie.entity.ts` 파일을 생성한다.

이 엔터티는 영화 데이터를 정의하는 역할을 수행한다.

```ts
export class Movie {
    id: number;
    title: string;
    year: number;
    genres: string[];
}
```

<br>


# Movie 서비스 작성
---

위에서 만든 엔터티를 기반으로, 다음 내용을 작성한다.

```ts
import { Injectable } from '@nestjs/common';
import { Movie } from './entities/movie.entity';

@Injectable()
export class MoviesService {

    private movies: Movie[] = [];
}
```

<br>


## **getAll(), getOne() 함수 작성**

GET을 통해 전체 영화 목록을 리턴하는 getAll(),

ID가 일치하는 영화 하나를 리턴하는 getOne() 함수를 작성한다.

```ts
import { Injectable } from '@nestjs/common';
import { Movie } from './entities/movie.entity';

@Injectable()
export class MoviesService {

    private movies: Movie[] = [];

    getAll() : Movie[] {
        return this.movies;
    }

    getOne(id: string) : Movie {
        return this.movies.find(movie => movie.id === +id);
    }
}
```

URL로부터 넘어오는 `id`가 스트링이므로, 매개변수의 `id`도 스트링으로 지정한다.

그리고 `+id`를 통해 `number` 타입으로 변환할 수 있다.

<br>

서비스에서 작성한 함수를 컨트롤러에서 사용하도록, 다음과 같이 작성한다.

```ts
import { Controller, Get, Post, Delete, Patch, Param, Body, Query } from '@nestjs/common';
import { Movie } from './entities/movie.entity';
import { MoviesService } from './movies.service';

@Controller('movies')
export class MoviesController {
    constructor(private readonly moviesServices: MoviesService) {}

    @Get()
    getAll(): Movie[] {
        return this.moviesServices.getAll();
    }

    @Get('search')
    search(@Query('year') seahrchingYear:string){
        return `Searching For Movie After ${seahrchingYear}`;
    }

    @Get(':id')
    getOne(@Param('id') id:string) {
        return this.moviesServices.getOne(id);
    }
    
    //...
}
```

<br>

## **함수들 작성**

같은 방식으로 기초적인 내용들을 작성하고 컨트롤러와 서비스를 연결한다.

```ts
// controller

import { Controller, Get, Post, Delete, Patch, Param, Body, Query } from '@nestjs/common';
import { Movie } from './entities/movie.entity';
import { MoviesService } from './movies.service';

@Controller('movies')
export class MoviesController {
    constructor(private readonly moviesServices: MoviesService) {}

    @Get()
    getAll(): Movie[] {
        return this.moviesServices.getAll();
    }

    @Get('search')
    search(@Query('year') seahrchingYear:string){
        return `Searching For Movie After ${seahrchingYear}`;
    }

    @Get(':id')
    getOne(@Param('id') id:string): Movie {
        return this.moviesServices.getOne(id);
    }

    @Post()
    create(@Body() movieData) {
        return this.moviesServices.create(movieData);
    }

    @Patch(':id')
    modifyOne(@Param('id') id:string, @Body() updateData) {
        return {
            updatedID: id,
            ...updateData
        };
    }

    @Delete(':id')
    deleteOne(@Param('id') id:string): boolean {
        return this.moviesServices.deleteOne(id);
    }
}
```

```ts
// Service

import { Injectable } from '@nestjs/common';
import { Movie } from './entities/movie.entity';

@Injectable()
export class MoviesService {

    private movies: Movie[] = [];

    getAll() : Movie[] {
        return this.movies;
    }

    getOne(id: string) : Movie {
        return this.movies.find(movie => movie.id === +id);
    }

    create(movieData) {
        this.movies.push({
            id: this.movies.length + 1,
            ...movieData
        });
    }

    deleteOne(id: string) : boolean {
        this.movies.filter(movie => movie.id !== +id);
        return true;
    }
}
```

<br>



## **CRUD 작성**

```ts
// Controller

import { Controller, Get, Post, Delete, Patch, Param, Body, Query } from '@nestjs/common';
import { Movie } from './entities/movie.entity';
import { MoviesService } from './movies.service';

@Controller('movies')
export class MoviesController {
    constructor(private readonly moviesServices: MoviesService) {}

    @Get()
    getAll(): Movie[] {
        return this.moviesServices.getAll();
    }

    @Get('search')
    search(@Query('year') seahrchingYear:string){
        return `Searching For Movie After ${seahrchingYear}`;
    }

    @Get(':id')
    getOne(@Param('id') id:string): Movie {
        return this.moviesServices.getOne(id);
    }

    @Post()
    create(@Body() movieData) {
        return this.moviesServices.create(movieData);
    }

    @Patch(':id')
    updateOne(@Param('id') id:string, @Body() updateData) {
        return this.moviesServices.update(id, updateData);
    }

    @Delete(':id')
    deleteOne(@Param('id') id:string) {
        this.moviesServices.deleteOne(id);
        return true;
    }
}
```

```ts
// Service

import { Injectable, NotFoundException } from '@nestjs/common';
import { Movie } from './entities/movie.entity';

@Injectable()
export class MoviesService {

    private movies: Movie[] = [];

    getAll() : Movie[] {
        return this.movies;
    }

    getOne(id: string) : Movie {
        const movie: Movie = this.movies.find(movie => movie.id === +id);
        if(!movie){
            throw new NotFoundException(`Movie with ID ${id} not found.`);
        }

        return movie;
    }

    create(movieData) {
        this.movies.push({
            id: this.movies.length + 1,
            ...movieData
        });
    }

    update(id:string, updateData){
        const movie = this.getOne(id);
        this.deleteOne(id);
        this.movies.push({ ...movie, ...updateData });
    }

    deleteOne(id: string) {
        this.getOne(id); // Check Exception(404 Error)
        this.movies = this.movies.filter(movie => movie.id !== +id);
    }
}
```

<br>



# Validation Check
---

## **DTO 생성**

DTO는 Data Transfer Object의 약자로,

전송되는 데이터 내부 타입을 제약하는 역할을 수행한다.

`src/movies/dto` 폴더를 만든다.

해당 폴더 내에 `create-movie.dto.ts` 파일을 만든다.

```ts
export class CreateMovieDto {
    readonly title: string;
    readonly year: number;
    readonly genres: string[];
}
```

<br>

## **DTO 적용**

이제 타입 없이 `movieData`를 받아 사용하던 부분들에 모두 타입을 적용한다.

```ts
// Controller

import { Controller, Get, Post, Delete, Patch, Param, Body, Query } from '@nestjs/common';
import { Movie } from './entities/movie.entity';
import { MoviesService } from './movies.service';

import { CreateMovieDto } from './dto/create-movie.dto'; // 자동 추가됨

@Controller('movies')
export class MoviesController {

    @Post()
    create(@Body() movieData: CreateMovieDto) {
        return this.moviesServices.create(movieData);
    }
}
```

```ts
// Service

import { Injectable, NotFoundException } from '@nestjs/common';
import { Movie } from './entities/movie.entity';

import { CreateMovieDto } from './dto/create-movie.dto'; // 자동 추가됨

@Injectable()
export class MoviesService {

    create(movieData: CreateMovieDto) {
        this.movies.push({
            id: this.movies.length + 1,
            ...movieData
        });
    }
}
```

<br>

## **모듈 설치**

필요한 모듈들을 설치한다.

```
npm i class-validator class-transformer
```

<br>

## **CreateMovieDto 수정**

```ts
import { IsNumber, IsString } from "class-validator";

export class CreateMovieDto {
    @IsString()
    readonly title: string;

    @IsNumber()
    readonly year: number;

    @IsString({ each: true })
    readonly genres: string[];
}
```

<br>

## **타입 제약을 위한 파이프 작성**

```ts
// main.ts

import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());         // 추가!
  await app.listen(3000);
}
bootstrap();
```

<br>

이제

```json
{
	"nyang": "012"
}
```

이런 식으로 타입이 불일치하는 정보를 보냈을 때

```json
{
	"statusCode": 400,
	"message": [
		"title must be a string",
		"year must be a number conforming to the specified constraints",
		"each value in genres must be a string"
	],
	"error": "Bad Request"
}
```

이렇게 반려된다.

<br>

## **ValidationPipe 옵션**

```ts
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
  }));
```

이렇게 작성하면

`whitelist`에 의해, `@IsString()`과 같은 데코레이터가 없는 프로퍼티를 가진 오브젝트의 경우

데코레이터가 없는 프로퍼티는 전달되지 않으며(제외된 상태로 오브젝트가 전달된다.),

`forbidNonWhitelisted`에 의해, 데코레이터가 없는 프로퍼티를 가진 오브젝트를 아예 거부해버린다.

<br>


# URL 파라미터 타입 자동 변경
---

```ts
// main.ts

import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));
  await app.listen(3000);
}
bootstrap();
```

위와 같이 `ValidationPipe`에 `transform:true` 조건을 추가할 경우,

URL의 파라미터로 넘어오는 값이 컨트롤러 함수의 파라미터에 지정한 타입으로 자동 변환되도록 한다.

따라서 이제 `id: string`을 모두 `id: number`로 바꿔주고,

`movie.id === +id`를 `movie.id === id`로 바꾸면 된다.

<br>



# UpdateData DTO
---

`create-movie.dto.ts`와 마찬가지로 `update-movie.dto.ts` 파일을 생성하고,

다음과 같이 작성한다.

```ts
import { IsNumber, IsString } from "class-validator";

export class UpdateMovieDto {
    @IsString()
    readonly title?: string;

    @IsNumber()
    readonly year?: number;

    @IsString({ each: true })
    readonly genres?: string[];
}
```

`?`는 필수가 아니라는 뜻이다.

<br>

그리고 타입 없이 `updateData`를 사용하던 모든 부분을 `udpateData:UpdateMovieDto`로 고친다.

<br>


## **Partial Type**

모듈을 설치한다.

```
npm i @nestjs/mapped-types
```

위에서는 똑같은 내용을 `CreateMovieDto`, `UpdateMovieDto`에 작성해놓고

`UpdateMovieDto`에서는 프로퍼티에 `?`만 추가했다.

확장성이 매우 안좋은 부분이다.

따라서 지금 설치한 모듈을 이용해, 클래스의 모든 프로퍼티를 Partial로 설정하면서 그대로 가져오도록 할 수 있다.

<br>

```ts
// update-movie.dto.ts

import { PartialType } from "@nestjs/mapped-types";
import { CreateMovieDto } from "./create-movie.dto";

export class UpdateMovieDto extends PartialType(CreateMovieDto) {}
```

<br>



## **Class Validator - Optional 제약**

```ts
// create-movie.dto.ts

import { IsNumber, IsOptional, IsString } from "class-validator";

export class CreateMovieDto {
    @IsString()
    readonly title: string;

    @IsNumber()
    readonly year: number;

    @IsOptional()
    @IsString({ each: true })
    readonly genres: string[];
}
```

위와 같이 `genres`에 `@IsOptional()` 데코레이터를 추가할 경우,

필수로 입력하지 않아도 되는 항목이 된다.

- <https://github.com/typestack/class-validator>

위 링크에서 더 많은 제약들을 확인할 수 있다.



<br>

# References
---
- <https://nomadcoders.co/nestjs-fundamentals/lobby>