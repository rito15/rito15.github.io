TITLE : 유니티 - 모바일 성능 최적화



https://www.youtube.com/watch?v=RLcSRuZsZQU
29:17 보는중

# NOTE
---

- 꾸준히 내용 업데이트 예정

<br>




# 프로젝트 설정
---

## **공통**
- 프로젝트 설정에서 불필요해 보이는 옵션들은 꺼버리면 된다.

## **물리 엔진을 사용하지 않는 경우**
- Physics - Auto Simulation, Auto Sync Transforms 비활성화

## **알맞은 Frame Rate 설정하기**
- Application.targetFrameRate 설정
- 액션 게임 : 60fps
- 보드 게임 : 30fps

## **Vsync 설정**
- 모바일 플랫폼에서 Vsync 설정을 끄는 것은 사실상 의미가 없을 수 있다.
- 웬만해서 이미 하드웨어 레벨에서 Vsync가 설정되기 때문이다.

<br>



# 파일 포맷(확장자)
---

## **이미지 파일 포맷**
- <https://docs.unity3d.com/kr/current/Manual/class-TextureImporterOverride.html>
- 이미지를 동일하게 저장할 수만 있다면, 이미지 파일 포맷(`JPG`, `PNG`, `TGA`, `PSD`, `PSB`, ...)은 딱히 최종적인 이미지 품질에 영향을 미치지 않는다.
- 유니티에서 사용될 때 GPU 전용 압축 포맷(`ETC`, `ASTC`, `PVRTC`, ...)으로 변환되기 때문이다.

<br>

## **음악 파일 포맷**
- 음악 파일 포맷 역시 유니티에서 사용될 때는 자체적인 압축 포맷으로 변환된다.
- 만약 원본이 `WAV` 같은 포맷이었다면, 굳이 `MP3`로 변환해서 사용할 경우 이중 손실이 발생할 수 있다.
- 따라서 원본 음악 파일 포맷을 그대로 사용하는 것도 괜찮다.

<br>



# 텍스쳐 압축 포맷
---
- <https://docs.unity3d.com/kr/current/Manual/class-TextureImporterOverride.html>
- <https://mentum.tistory.com/583>

- 선요약 : 모바일은 안드로이드, iOS 공통으로 사용할 수 있으며 가성비 좋은 `ASTC`를 사용하면 좋다.
- 구형 기기도 대상으로 해야 하는 경우, 안드로이드는 `ETC2`, iOS는 `PVRTC`를 사용하면 된다.

<br>

## **[1] DXT**
- <https://mgun.tistory.com/1385>
- **D**irect**X** **T**exture

- 타겟 플랫폼이 스탠드얼론일 경우 기본적으로 사용하는 포맷
- 압축률이 높아 메모리를 적게 사용한다.
- 대부분의 그래픽카드가 하드웨어 레벨에서 지원하므로, 성능 저하가 거의 없다.

<br>

## **[2] ASTC**
- <https://ozlael.tistory.com/84?category=612211>
- **A**daptive **S**calable **T**exture **C**ompression

- 손실 블록 기반 텍스쳐 압축 알고리즘
- 블록 크기를 설정하여 용량 및 품질을 유연하게 설정할 수 있다.
- 블록 크기가 작을수록 용량이 크고, 품질이 좋아진다.

- 일반적으로 `ETC` 포맷보다 품질이 더 좋고, 압축 시간이 더 오래 걸린다.
- 안드로이드, iOS 모두 지원한다.
- 구형 기종에서는 지원하지 않을 수 있으므로 주의해야 한다.

- 최근 들어 모바일에서 `ASTC`를 사용하는 경우가 많다.

<br>

## **[3] ETC**
- **E**ricsson **T**exture **C**ompression

- 타겟 플랫폼이 안드로이드일 경우 기본적으로 사용되는 포맷
- OpenGLES 표준 포맷
- `ETC1` 포맷은 알파 채널이 없다.
- `ETC2` 포맷은 알파 채널이 있다.
- `ETC2` 포맷은 품질과 용량 사이에서 최고의 균형을 유지하므로 안드로이드에서 가장 효율적인 옵션이다.

<br>

## **[4] PVRTC**
- **P**ower**VR** **T**exture **C**ompression

- 타겟 플랫폼이 iOS일 경우 기본적으로 사용되는 포맷
- 텍스쳐의 해상도가 POT(2의 제곱수)여야 한다는 제약이 있으므로, 리소스 제작 시 신경써야 한다는 단점이 있다.

<br>



# 텍스쳐 임포트 설정
---
- <https://docs.unity3d.com/kr/current/Manual/class-TextureImporter.html>
- <https://docs.unity3d.com/kr/current/Manual/ImportingTextures.html>

<br>

## **Read/Write Enabled**
- <https://ozlael.tistory.com/82>
- 메모리에 적재된 텍스쳐를 실시간으로 수정할 수 있게 하는 설정
- 텍스쳐는 보조 기억 장치(HDD, SSD)에 저장되어 있다가 메모리(RAM)에 적재되고, 최종적으로는 그래픽 메모리(VRAM)에 적재된다.
- 텍스쳐는 굳이 RAM에 남아 있을 필요가 없기 때문에 RAM에서는 제거되고, VRAM에 상주하는 것이 일반적이다.
- 하지만 이 옵션을 켜면 API를 통해 접근할 수 있도록 RAM에도 남겨놓으므로, RAM과 VRAM 양측에 상주하게 된다.
- 따라서 메모리를 절약하기 위해서는 이 옵션을 끄는 것이 좋다.

<br>

## **Generate Mip Maps**
- <https://ozlael.tistory.com/45?category=612211>
- 체크하면 POT(2 제곱수)에 따른 해상도로, 작은 텍스쳐들이 생성된다.
- 예를 들어 512 크기의 텍스쳐는 256, 128, 64, ... 이렇게 생성된다.
- 메모리에 적재되는 텍스쳐 용량은 33% 정도 증가한다.
- 런타임에 거리에 따른 디테일(LOD) 표시 용도로 사용된다.
- 2D 게임에서는 사용할 필요가 없으므로 끄는 것이 좋다.

- 요약 : 3D 게임에서는 켜고, 2D 게임에서는 끄면 된다.

<br>



# 모델 임포트 설정
---
- <https://docs.unity3d.com/kr/current/Manual/class-FBXImporter.html>
- <https://docs.unity3d.com/kr/current/Manual/FBXImporter-Model.html>

<br>

## **Mesh Compression**
- 메시의 정밀도를 낮추고 메시 데이터를 압축한다.
- 타겟 디바이스에 저장되는 메시의 크기를 줄이지만, 런타임 메시 크기에는 영향을 주지 않는다.
- 압축비가 높을수록 부정확도가 높아져서 시각적 품질을 저하시킬 수 있다.

<br>

## **Read/Write Enabled**
- 텍스쳐와 마찬가지로, 메시 데이터 역시 GPU 메모리에 저장된다.
- 이 옵션을 설정하면 GPU 메모리뿐만 아니라 CPU 메모리에도 저장된다.
- CPU를 통해 실시간으로 메시를 수정할 필요가 없다면 해제하는 것이 좋다.

<br>

## **Disable rigs and BlendShapes**
- 메시가 Skeletal 또는 BlendShape(예: 표정) 애니메이션을 필요로 하지 않으면 설정한다.
- 리깅 되지 않은 건물, 배경 메시인 경우 해당된다.

<br>

## **Normals**
- 노멀 벡터를 전혀 필요로 하지 않는 경우(완벽한 Unlit), `None`으로 설정한다.

<br>

## **Tangents**
- 노멀 맵을 사용하지 않는 경우, `None`으로 설정하면 된다.

<br>



# 렌더 파이프라인 선택
---

- 모바일은 `URP`(Universal Render Pipeline)를 선택하는 것이 성능 상 좋다.

- 기본 파이프라인에 비해 여러 개의 동적 라이트에 대해 드로우 콜을 절약할 수 있다.

<br>



# 그래픽 최적화
---

## **라이트(Light)**
- 만약 `URP`를 사용한다고 해도 동적 라이트는 성능 영향이 큰 편이므로 최소화해야 한다.
- 정적인 오브젝트에는 라이트맵, 동적 오브젝트에는 라이트 프로브를 최대한 활용하는 것이 성능을 위해 좋다.

<br>

## **그림자(Shadow)**
- 유니티 엔진의 동적(실시간) 그림자는 쉐도우 맵(Shadow Map) 방식을 사용한다.
- 실시간 그림자를 사용하면 드로우 콜, GPU 성능 소모를 생각보다 많이 발생시킨다.
- 따라서 그림자는 웬만하면 최대한 줄이거나 안쓰는 것이 좋다.

<br>

## **정적 배칭(Static Batching)**
- <https://docs.unity3d.com/kr/current/Manual/DrawCallBatching.html>

- 게임 내에서 배경 프랍과 같이 항상 변하지 않는 오브젝트는 정적 배칭을 통해 최적화할 수 있다.
- 인스펙터의 우측 상단에서 `Batching Static`에 체크한다.
- 정적 배칭 대상 메시들은 하나의 메시로 합쳐지며, 그만큼 새로운 메시를 생성해야 하므로 메모리를 더 소모한다.
- 대신 하나의 메시로 합쳐진 만큼 한 번의 드로우 콜로 그려낼 수 있다. <br>
  (메시의 한계 수용량을 넘어설 경우, 여러 개의 메시로 각각 통합될 수 있다.)

> + 동적 배칭? <br>
> 동적 배칭은 딱히 의미 없고, 동적 오브젝트에 대해서는 GPU Instancing을 알아보는 것이 좋다.

<br>

## **LOD(Level of Detail)**
- <https://docs.unity3d.com/kr/current/Manual/class-LODGroup.html>
- <https://chulin28ho.tistory.com/264>

- 같은 모델링에 대해, 원본 메시와 단순화된 버전의 메시를 준비한다.
- `LOD Group` 컴포넌트를 통해 거리가 가까우면 원본 메시, 멀리 떨어져 있으면 단순화된 메시를 보여줄 수 있다.

<br>

## 오클루전 컬링(Occlusion Culling)**
- <https://docs.unity3d.com/kr/current/Manual/OcclusionCulling.html>
- 정적 오브젝트에 해당하는 최적화 방법
- 오브젝트가 다른 오브젝트에 의해 완전히 가려질 경우 화면에 렌더링되지 않도록 컬링하는 기법

- 건물, 담벼락처럼 부피가 꽤 있어서 다른 오브젝트를 가릴 가능성이 많은 오브젝트는 `Occluder Static`으로 설정한다. <br>
  (`Occludee Static`도 함께 설정해도 된다.)
- 작은 프랍과 같이 가려질 가능성이 많은 오브젝트는 `Occludee Static`으로 설정한다.
- `Window` - `Rendering` - `Occlusion Culling` 창에서 베이크할 수 있다.

- 오브젝트끼리 서로 가리는 경우가 빈번하지 않은 야외의 씬에서는 오히려 오클루전 컬링이 비효율적일 수 있다.


<br>

# 모바일 기기 최적화
---

## **해상도 설정**
- 기기별로 해상도는 천차만별일 수 있다.
- 따라서 해상도가 너무 높은 경우에는 괜히 성능상 손해를 보게될 수 있으므로, <br>
  `Screen.SetResolution(width, height, false)` 메소드를 통해 적절한 수준으로 조절해야 한다.

- 해상도를 낮추면 UI 역시 해상도가 낮아지므로 품질이 떨어져 보일 수 있다.
- 따라서 이런 경우에는 오버레이 UI만 원래 해상도대로 그려줘야 하는데, <br>
  이를 업스케일 샘플링(**Upscale Sampling**)을 통해 해결할 수 있다.

- `URP`에서는 이런 기능을 기본적으로 제공한다.
- `URP`에서는 굳이 `SetResolution()` 메소드를 사용하지 않아도 <br>
  `URP Asset` - `Quality` - `Render Scale` 설정을 통해 <br>
  오버레이 UI를 제외한 게임 화면의 해상도를 낮출 수 있다.

- <https://github.com/ozlael/UpsamplingRenderingDemo>
- 레거시 파이프라인에서는 위의 예제처럼 카메라의 렌더 텍스쳐 해상도를 낮추는 방식을 사용하면 된다.

- 그리고 왠지 모르겠지만 예제 코드에서는 굳이 RawImage 컴포넌트를 캔버스 아래에 넣고 그 이미지를 렌더 타겟으로 이용하는데, 그럴 필요는 없다. <br>
  거기다가 샘플링 스케일을 변경할 때마다 렌더 타겟을 새로 생성하고 안지워주는데, 이러면 메모리에 계속 쌓이므로 반드시 이전 렌더 타겟을 지워줘야 한다.

<br>



# References
---
- <https://www.youtube.com/watch?v=1mJtoceqvro>
- <https://www.youtube.com/watch?v=RLcSRuZsZQU>
- <https://ozlael.tistory.com/category/Unity3D/Graphics>
- <http://egloos.zum.com/littles/v/3439290>
