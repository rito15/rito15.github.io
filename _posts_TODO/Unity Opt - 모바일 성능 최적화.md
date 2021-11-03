TITLE : 유니티 - 모바일 성능 최적화



https://www.youtube.com/watch?v=RLcSRuZsZQU
13:40 보는중



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
- 이미지를 동일하게 저장할 수만 있다면, 이미지 파일 포맷(`JPG`, `PNG`, `TGA`, `PSD`, `PSB`, ...)은 딱히 최종적인 이미지 품질에 영향을 미치지 않는다.
- 유니티에서 사용될 때 GPU 전용 압축 포맷(`ETC`, `ASTC`, `PVRTC`, ...)으로 변환되기 때문이다.
- <https://docs.unity3d.com/kr/current/Manual/class-TextureImporterOverride.html>

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



<br>

# References
---
- <https://www.youtube.com/watch?v=1mJtoceqvro>
- <https://www.youtube.com/watch?v=RLcSRuZsZQU>
- <https://ozlael.tistory.com/category/Unity3D/Graphics>
- <http://egloos.zum.com/littles/v/3439290>
