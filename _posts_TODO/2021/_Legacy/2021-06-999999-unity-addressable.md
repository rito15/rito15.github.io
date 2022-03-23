T O D O

LoadResourceLocationsAsync ??

폴더째로 불러오기 대신 레이블로 불러오기 ?

★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
★★★ 현 재 진 행 :::::

 https://youtu.be/EP3pvPAcHSo?t=680

 보는중

 코딩으로 어드레서블 사용하는법 총정리 할 예정

 그리고 이거 유튜브 다 보면 아래 써있는 Learn부터 진행 ㄱㄱ

★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

0. 유튜브 다 보기

- https://www.youtube.com/watch?v=Z9LrkQUDzJw - 애셋이 번들번들
- https://www.youtube.com/watch?v=yoBzTpJYN44
- https://www.youtube.com/watch?v=EP3pvPAcHSo

0.1. Learn
- https://learn.unity.com/project/getting-started-with-addressables

0.2. Manual
- https://docs.unity3d.com/Packages/com.unity.addressables@1.18/manual/index.html

1. 깃헙 페이지에서 예제 설명 모두 읽기
- https://github.com/Unity-Technologies/Addressables-Sample

2. 모든 예제 열어보고 사용법 모두 익히기

3. 원하는대로 구현하기

- 로비 씬에 입장
- 로비 씬에는 2가지 버튼이 있음
  - Load Game Data : 게임 씬의 모든 데이터 로드
  - Start Game : 게임 씬으로 진입

- 서버에 올려야 함(AWS S3)

- 게임 씬 자체를 통째로 바꾸는 패치 해보기


4. 예제와 구현을 토대로 포스팅

--------------------------------------------------------------------
--------------------------------------------------------------------

 메 모

에디터
- 에디터에서 애셋번들 써봐야 메모리에 싹다 올리니까 에디터 테스트 의미 없음
- 타겟 기기에서 테스트 해야 함


모바일
- 메모리에 번들에 대한 직렬화된 헤더 정보를 로드한다.
- 헤더 정보는 딱히 크지는 않지만, 쌓이면 무시할 수 없을 수도 있다.
- 필요 시 메모리에 실제 데이터를 로드한다.




# [최적화]

- 씬 전환의 이점
- 씬 A -> 씬 B로 갈때 내부적으로 Resources.UnloadUnusedAssets()를 호출하는데,
  이는 씬 B 로드가 모두 된 이후에 호출된다.
- 따라서 씬 A, B가 모두 로드된 순간이 존재하게 되는데,
  이 순간에 메모리를 과도하게 잡아먹을 수 있다.

- 이를 방지하려면 가벼운 로딩 씬을 사이에 넣으면 된다.
- 씬 A -> 로딩 씬 -> 씬 B 구조



# [어드레서블 내부 구조와 동작]

## [1] 초기화

- 프로그래머가 관여하지 않고, 내부적으로 동작하는 부분

### Addressables
 - 애셋 관리
 - 로드, 생성, 해제 등의 API 제공

### Content Catalog
 - 애셋과 주소의 매핑 정보를 JSON 파일로 직렬화하여 관리
 - 앱을 시작하면 이 정보를 읽어서 Resource Locator에게 제공

### Resource Locator
 - 주소와 애셋의 매핑 정보를 실시간으로 관리

### Resource Manager
 - 실제로 애셋들을 메모리에 로드/언로드하는 내부 동작 수행

### Providers
 - 애셋의 타입마다 실제로 로드하는 동작을 수행

![image](https://user-images.githubusercontent.com/42164422/123542529-118ce280-d785-11eb-85e4-e7ccb2ab4de6.png)



## [2] 애셋 로드

- 로드 과정의 모든 작업은 비동기적으로 처리된다.

- 사용자는 로드 시작/완료 처리만 해주면 된다.


### 로드 과정

- 로드 시작 시 프로그래머가 Addressable에 애셋 주소를 전달한다.

- Addressable 내의 Resource Locator가 실제 애셋 위치를 Resource Manager에 전달한다.

- Resource Manager는 애셋 종류에 따라 알맞은 Provider를 찾아 로드하고, AsyncOperation을 반환한다.

- 비동기 로드 작업이 모두 수행되면 프로그래머가 등록했던 완료 콜백이 수행된다.

![image](https://user-images.githubusercontent.com/42164422/123542546-223d5880-d785-11eb-94e5-600941554908.png)



# [사용법]

## 로드와 생성
 - 로드 : 참조하여 사용할 수 있도록 메모리에 적재
 - 생성 : 씬 내에 생성(대표적으로 게임오브젝트)

## [1] Address(string) 이용

- 로드 : Addressables.LoadAsset<TObject>("Address")
- 바로 생성 : Addressables.Instantiate<TObject>("Address")

## [2] AssetReference 이용

- 로드 : assRef.LoadAsset<TObject();
- 생성 : assRef.Instantiate<TObject>(pos, rot);


## [비동기 콜백 등록]

Addressables.LoadAsset<TObject>(address).Completed += CALLBACK;


## [해제]
- LoadAsset -> Addressables.ReleaseAsset<TObject>(target);
- Instantiate -> Addressables.ReleaseInstance<TObject>(target);





# [어드레서블 윈도우]


## [Group]

### Build
 - New Build - Default Build Script : 에디터에서 컨텐츠를 빌드한다.
 - AddressableAssetSettings.BuildPlayerContent()를 호출하는 것과 같다.


### Play Mode Script(Build Mode)
 - Use Asset Database : 에디터에서 테스트용으로 사용하며, 실제 런타임 동작과는 다르다.
 - Simulate Groups : Address를 이용하지만, 실제로 번들을 빌드하지는 않는다. 주소 지정 방식 시뮬레이션용
 - Use Existing Build : 빌드 환경과 동일하게 작동한다. CDN 등을 사용하여 리모트 환경에 대한 테스트도 가능하다.

### Labels
 - 각 애셋에는 하나 이상의 레이블을 붙여줄 수 있다.
 - 애셋을 로드할 때 레이블로 필터링하여 그 레이블에 해당되는 애셋들만 로드할 수 있다.


## [Analyze]
 - 종속성 문제 등등 다양한 문제들을 확인해볼 수 있다.


--------------------------------------------------------------------


---
title: Addressables(어드레서블)
author: Rito15
date: 2021-06-26 15:15:00 +09:00
categories: [Unity, Unity Study]
tags: [unity, csharp]
math: true
mermaid: true
---

# 애셋 번들(Asset Bundle)
---

- 애셋 번들(Asset Bundle)을 이용하면 게임 내 컨텐츠를 초기 애플리케이션에 모두 포함하지 않고, 게임 시작 이후 동적으로 다운로드할 수 있게 하여 초기 다운로드 크기를 줄일 수 있다.

<br>

## **장점**

- 애플리케이션의 초기 용량이 줄어든다.

- 업데이트 시 서버의 파일(예 : 텍스쳐, 프리팹)만 변경하여 재빌드 없이 업데이트를 진행할 수 있다.

<br>

## **문제점**

- 애셋 번들을 사용하려면 대부분 추가적인 커스터마이징이 필요하다.

- 여러 번들에 공통적으로 사용되는 애셋이 중복 로드 되는 등, 종속성 문제가 발생할 수 있다.

- 애셋의 위치를 직접 참조해야만 하는 불편함이 있다.

- 초기 개발 시에는 바로 사용하기 번거로우므로, 개발 진행에 따라 코드 변경이 불가피하다.

<br>

# 어드레서블 애셋 시스템(Addressable Asset System)
---

- 애셋 번들의 불편함을 해소하고 더욱 편리하게 사용할 수 있도록 제작되었다.

- 어드레서블 = 리소스 폴더 장점 + 애셋 번들 장점 + 개발 편의성

<br>

## **장점**

- 애셋의 종속성과 메모리 현황을 손쉽게 파악할 수 있다.

- 애셋의 실제 위치가 로컬, 서버 어디에 있든 관계 없이 주소(Address)만 알고 있으면 참조하여 로드할 수 있다.

- 개발 단계 언제든 바로 사용할 수 있다.

- 개발 중에도 Play Mode 설정을 통해 실제와 같은 테스트가 가능하다.

<br>

## **단점**

- 애셋 번들과 마찬가지로, 초보자에게는 다소 생소한 개념일 수 있으며 러닝 커브(Learning Curve)가 존재한다.

- 간혹 버그가 있다.

<br>


# 어드레서블 워크플로우
---

- 게임 로드 시, 지정된 서버 경로에 요청하여 번들을 확인한다.

- 필요한 번들이 이미 로컬에 모두 받아져 있지 않은 경우, 서버로부터 다운받아 로컬에 캐싱(저장)한다.

- 로컬에 저장된 번들을 메모리에 로드하여 사용한다.


<br>

# 사용 준비
---

## **[1] 설치**

- 패키지 매니저에서 찾아 임포트한다.

![image](https://user-images.githubusercontent.com/42164422/123504012-939bdf00-d691-11eb-9191-5656e9f9449f.png)

<br>

## **[2] 주소 등록**

![image](https://user-images.githubusercontent.com/42164422/123506938-c4841000-d6a1-11eb-894e-ba7126f966d1.png)

- 애셋을 선택하고, 인스펙터 창에서 `Addressable`에 체크한다.

- 주소로 사용할 문자열을 입력한다.

<br>

## **[3] 애셋 관리**

![image](https://user-images.githubusercontent.com/42164422/123506989-1036b980-d6a2-11eb-9511-7ff657844dca.png)

- `Window` - `Asset Management` - `Addressables` - `Groups`를 통해 등록된 애셋들을 확인할 수 있다.

- 새로운 그룹을 만들거나 제거하고, 애셋들을 원하는 그룹으로 설정할 수 있다.

<br>


# 생성 및 해제
---

## **네임스페이스**

```cs
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
```

<br>

## **[1] 애셋 레퍼런스 기반**


- `AssetReference~` 타입을 통해 애셋을 미리 인스펙터에서 지정하고, 이를 이용해 로드한다.

- `AssetReferenceT<TObject>` 제네릭 타입을 통해 원하는 타입의 애셋을 지정할 수 있다.

- 로드 시 핸들을 반환하며, 핸들을 이용해 애셋을 해제할 수 있다.

```cs
public AssetReferenceGameObject redCubeReference;
private AsyncOperationHandle redCubeHandle;
private GameObject redCubePrefab;

private void Method()
{
    // * Valid 검사를 수행하지 않으면
    // 이미 로드되었는데도 중복 로드될 수 있다.

    // 1-1. 애셋 레퍼런스로부터 메모리에 로드 및 핸들 참조
    if (!redCubeReference.IsValid())
        redCubeHandle = redCubeReference.LoadAssetAsync();

    // 1-2. 메모리에 로드 + 성공 시 수행할 동작 지정
    if (!redCubeReference.IsValid())
    {
        redCubeReference.LoadAssetAsync().Completed +=
            (AsyncOperationHandle<GameObject> handle) =>
            {
                // 핸들 참조 등록
                redCubeHandle = handle;

                // 로드 완료 시 수행할 동작들
                redCubePrefab = handle.Result;
            };
    }


    // 2. 메모리에 적재된 애셋을 실제로 사용
    Instantiate(redCubePrefab);


    // 3-1. 애셋 레퍼런스를 기반으로 메모리에서 해제
    if (redCubeReference.IsValid())
        redCubeReference.ReleaseAsset();

    // 3-2. 핸들을 기반으로 메모리에서 해제
    if (redCubeHandle.IsValid())
    {
        Addressables.Release(redCubeHandle);
        redCubePrefab = null;
    }
}
```

<br>

## **[2] 스트링 주소 기반**

- 스트링으로 이루어진 주소를 참조하여 애셋을 로드한다.

- 로드 시 핸들을 반환하며, 핸들을 이용해 애셋을 해제할 수 있다.

```cs
private static readonly string RedCubeAddress = "Group01/Red Cube";
private AsyncOperationHandle redCubeHandle;
private GameObject redCubePrefab;

private void Method()
{
    // * Valid 검사를 수행하지 않으면
    // 이미 로드되었는데도 중복 로드될 수 있다.

    // 1-1. 주소를 기반으로 메모리에 로드
    if (!redCubeHandle.IsValid())
    {
        redCubeHandle =
            Addressables.LoadAssetAsync<GameObject>(RedCubeAddress);
    }

    // 1-2. 메모리에 로드 + 성공 시 수행할 동작 지정
    if (!redCubeHandle.IsValid())
    {
        Addressables.LoadAssetAsync<GameObject>(RedCubeAddress).Completed +=
        (AsyncOperationHandle<GameObject> handle) =>
        {
            // 핸들 참조 등록
            redCubeHandle = handle;

            // 로드 완료 시 수행할 동작들
            redCubePrefab = handle.Result;
        };
    }

    // 2. 메모리에 적재된 애셋을 실제로 사용
    Instantiate(redCubePrefab);


    // 3. 핸들을 기반으로 메모리에서 해제
    if (redCubeHandle.IsValid())
    {
        Addressables.Release(redCubeHandle);
        redCubePrefab = null;
    }
}
```

<br>

# 
---



<br>

# 
---



# References
---
- <https://blog.unity.com/kr/games/addressable-asset-system>
- <https://github.com/Unity-Technologies/Addressables-Sample>
- <https://drive.google.com/file/d/1gwOkEKJ3q-Pcco9ZxMqm9ZdqCcVLOfG4/view>
- <https://blog.naver.com/cdw0424/221755856111>
- <https://kupaprogramming.tistory.com/129>

- <https://www.youtube.com/playlist?list=PLmRK0lH8TNCo7K4xmLpEov4llbVTwf29s>
- <https://www.youtube.com/watch?v=Z9LrkQUDzJw>
- <https://www.youtube.com/watch?v=yoBzTpJYN44>
- <https://www.youtube.com/watch?v=EP3pvPAcHSo>
