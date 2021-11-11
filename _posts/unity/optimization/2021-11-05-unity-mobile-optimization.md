---
title: 유니티 - 모바일 성능 최적화
author: Rito15
date: 2021-11-06 00:02:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization]
math: true
mermaid: true
---

# 프로젝트 설정
---

<details>
<summary markdown="span">
...
</summary>

## **공통**
- 프로젝트 설정에서 불필요해 보이는 옵션들은 웬만해서 끄는 것이 성능에 좋다.

## **물리 엔진을 사용하지 않는 경우**
- **Physics** - `Auto Simulation`, `Auto Sync Transforms` 비활성화

## **알맞은 Frame Rate 설정하기**
- `Application.targetFrameRate` 설정
- 액션 게임 : **60fps**
- 보드 게임 : **30fps**

## **Vsync 설정**
- 모바일 플랫폼에서 **Vsync** 설정을 끄는 것은 사실상 의미가 없을 수 있다.
- 웬만해서 이미 하드웨어 레벨에서 **Vsync**가 설정되기 때문이다.

<br>

</details>



# 파일 포맷(확장자)
---

<details>
<summary markdown="span">
...
</summary>

## **이미지 파일 포맷**
- <https://docs.unity3d.com/kr/current/Manual/class-TextureImporterOverride.html>
- 이미지를 동일하게 저장할 수만 있다면, 이미지 파일 포맷(`JPG`, `PNG`, `TGA`, `PSD`, `PSB`, ...)은 딱히 최종적인 이미지 품질에 영향을 미치지 않는다.
- 유니티에서 사용될 때 GPU 전용 압축 포맷(`ETC`, `ASTC`, `PVRTC`, ...)으로 변환되기 때문이다.

<br>

## **오디오 파일 포맷**
- <https://docs.unity3d.com/kr/current/Manual/AudioFiles.html>
- 오디오 파일 포맷 역시 유니티에서 사용될 때는 자체적인 압축 포맷으로 변환된다.
- 만약 원본이 `WAV` 같은 포맷이었다면, 굳이 `MP3`로 변환해서 사용할 경우 이중 손실이 발생할 수 있다.
- 따라서 원본 음악 파일 포맷을 그대로 사용하는 것도 괜찮다.

<br>

</details>



# 텍스쳐 압축 포맷
---

<details>
<summary markdown="span">
...
</summary>

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

</details>



# 텍스쳐 임포트 설정
---

<details>
<summary markdown="span">
...
</summary>

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

</details>



# 모델 임포트 설정
---

<details>
<summary markdown="span">
...
</summary>

- <https://docs.unity3d.com/kr/current/Manual/class-FBXImporter.html>
- <https://docs.unity3d.com/kr/current/Manual/FBXImporter-Model.html>

<br>

## **Import BlendShapes**
- BlendShape(예: 표정) 애니메이션을 필요로 하지 않으면 체크 해제한다.

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

## **Normals**
- 노멀 벡터를 전혀 필요로 하지 않는 경우(완벽한 Unlit), `None`으로 설정한다.

<br>

## **Tangents**
- 노멀 맵을 사용하지 않는 경우, `None`으로 설정하면 된다.

<br>

</details>


# 릭(Rig) 임포트 설정
---

<details>
<summary markdown="span">
...
</summary>

- <https://docs.unity3d.com/kr/current/Manual/FBXImporter-Rig.html>

<br>

## **Animation Type**
- `Humanoid` 타입은 `Generic` 타입에 비해 `30 ~ 50%`의 성능을 더 소모한다.
- 굳이 `Humanoid`로 설정할 필요가 없다면, `Generic`으로 사용하는 것이 성능 상 좋다.

- 리깅 데이터가 없다면 `None`으로 설정한다.

<br>

## **Optimize Game Objects**
- 모델에 리깅된 본(bone)은 각각 게임 오브젝트로 존재하며, 모델의 하위 계층 구조를 이룬다.
- 하지만 이렇게 하위 게임 오브젝트가 많으면 성능상 매우 좋지 않다.
- 따라서 이 설정에 체크하면 각각의 본을 게임오브젝트로 생성하지 않는다.
- 만약 특정 본을 직접 조작할 필요가 있다면, `Extra Transforms to Expose` 옵션을 통해 원하는 본을 게임오브젝트로 노출시킬 수 있다.

<br>

</details>



# 오디오 최적화
---

<details>
<summary markdown="span">
...
</summary>

- <https://docs.unity3d.com/kr/current/Manual/class-AudioClip.html>

<br>

## **모노로 설정하기**
- 사운드 리소스는 크게 **모노(Mono)**, **스테레오(Stereo)**로 분류할 수 있다.
- 모노 사운드는 소리를 단일 채널로 저장하여 여러 개의 출력 장치에서 같은 소리를 재생한다.
- 스테레오 사운드는 소리를 다중 채널로 저장하여 여러 개의 출력 장치에서 서로 다른 소리를 재생하여 공간감을 제공한다.

- PC를 대상으로 빌드하는 경우에는 스테레오가 필요할 수 있다.
- 그런데 모바일 기기는 딱히 공간 음향이 필요하지도 않으므로 모노로 설정하는 것이 메모리 최적화에 아주 좋다.
- 오디오 파일 임포트 설정 인스펙터에서 `Force To Mono`에 체크하면 된다.

<br>

## **원본 오디오 파일 그대로 사용하기**
- 원본은 `.wav`인 파일을 저장 공간 절약 등의 이유로 `.mp3`와 같은 확장자로 변경해서 사용하는 경우가 있다.
- 진짜로 작업 공간이 너무 부족해서 어쩔 수 없는 경우가 아니라면, 원본 확장자를 그대로 사용하는 것이 좋다.
- 어차피 유니티에서 별도의 압축 포맷으로 변경하므로, 압축 전에 포맷을 변경하여 괜히 데이터가 소실되는 것은 손해이다.

<br>

## **오디오 압축 포맷**
- 이전에는 안드로이드는 `.ogg`, iOS는 `.mp3`를 네이티브 포맷으로 지원했다.
- 하지만 이제는 모바일 기기 공통으로 `Vorbis`를 사용하는 것이 좋다.
- 아주 짧은 오디오는 `ADPCM` 포맷을 사용하는 것이 좋다.

<br>

## **Load Type 설정**
- 오디오 파일 임포트 설정 인스펙터에 `Load Type` 옵션이 있다.
- 오디오 파일을 메모리에 적재하는 방식을 결정한다.

- `Decompress on Load`
  - 압축을 모두 풀어서 메모리에 적재한다.
  - 메모리 용량을 많이 차지한다.
  - 총알 발사음, 타격음 같은 아주 짧은 오디오에 적합하다.

- `Compressed in Memory`
  - 압축된 상태로 메모리에 적재한다.
  - 중간 크기의 오디오에 적합하다.

- `Streaming`
  - 보조기억장치에 저장한 상태로 필요할 때만 꺼내 쓰는 방식.
  - 배경음 같이 용량이 큰 오디오에 적합하다.

<br>

## **볼륨 0인 상태로 재생하지 않기**
- UI 이미지를 투명도 0으로 설정하는 것과 같다.
- 재생되는 사운드의 볼륨이 0이라고 해도, 어쨌든 재생되므로 성능을 소모한다.
- 따라서 볼륨을 0으로 두지 말고 완전히 재생을 중지하는 것이 좋다.

<br>

</details>



# 물리 최적화
---

<details>
<summary markdown="span">
...
</summary>

## **Prebake Collision Meshes**
- **Player Settings - Player - Other Settings - Optimization**
- 빌드 시 충돌 데이터를 미리 연산한다.
- 물리 엔진을 사용하는 경우, 설정 해두면 좋다.

<br>

## **Layer Collision Matix**
- **Player Settings - Physics**
- 반드시 충돌할 레이어끼리만 체크한다.
- 체크된 레이어에 해당하는, 콜라이더가 있는 게임오브젝트는 모두 연산에 포함될 수 있으므로, 꼭 설정해주는 것이 좋다.
- 예를 들어 정적 배치된 건물들의 경우에는 서로 충돌할 일이 없으므로 체크 해제한다. 

<br>

## **기본 콜라이더 사용하기**
- **메시 콜라이더는 사용하지 않는 것이 좋다.**
- 메시 콜라이더는 폴리곤 단위로 충돌이 계산된다. 따라서 생각보다 성능이 많이 안좋다.
- 굳이 메시 콜라이더를 사용해야 한다면 `Convex`로 단순화시켜서 사용한다.
- **Sphere, Box, Capsule**과 같은 기본 콜라이더를 조합하여 사용하는 것이 성능 상 좋다.

<br>

## **물리 연산 주의사항**
- 리지드바디가 존재하는 오브젝트의 트랜스폼을 직접 이동시키면 물리 월드에서 동기화를 위한 재계산이 발생한다.
- 따라서 리지드바디가 존재하면 철저히 리지드바디를 이용해서 움직이는 것이 좋다.

- 그리고 리지드바디 API는 반드시 `Update()`가 아니라 `FixedUpdate()`에서 호출해야 한다.

<br>

</details>



# 렌더 파이프라인 선택
---

<details>
<summary markdown="span">
...
</summary>

- <https://docs.unity3d.com/kr/2019.3/Manual/render-pipelines.html>

- 모바일은 `URP`(Universal Render Pipeline)를 선택하는 것이 성능 상 좋다.

- 기본 파이프라인에 비해 여러 개의 동적 라이트에 대해 드로우 콜을 절약할 수 있다.

<br>

</details>



# 그래픽 최적화
---

<details>
<summary markdown="span">
...
</summary>

## **라이트(Light)**
- <https://docs.unity3d.com/kr/current/Manual/Lightmapping.html>
- <https://docs.unity3d.com/kr/current/Manual/LightProbes.html>
- 만약 `URP`를 사용한다고 해도 동적 라이트는 성능 영향이 큰 편이므로 최소화해야 한다.
- 정적인 오브젝트에는 라이트맵, 동적 오브젝트에는 라이트 프로브를 최대한 활용하는 것이 성능을 위해 좋다.

<br>

## **그림자(Shadow)**
- <https://docs.unity3d.com/kr/current/Manual/Shadows.html>
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
> 동적 배칭은 딱히 의미 없고, 동적 오브젝트에 대해서는 GPU Instancing을 알아보는 것이 좋다. <br>
> - <https://docs.unity3d.com/kr/current/Manual/GPUInstancing.html>

<br>

## **LOD(Level of Detail)**
- <https://docs.unity3d.com/kr/current/Manual/class-LODGroup.html>
- <https://chulin28ho.tistory.com/264>

- 같은 모델링에 대해, 원본 메시와 단순화된 버전의 메시를 준비한다.
- `LOD Group` 컴포넌트를 통해 거리가 가까우면 원본 메시, 멀리 떨어져 있으면 단순화된 메시를 보여줄 수 있다.

<br>

## **오클루전 컬링(Occlusion Culling)**
- <https://docs.unity3d.com/kr/current/Manual/OcclusionCulling.html>
- 정적 오브젝트에 해당하는 최적화 방법
- 오브젝트가 다른 오브젝트에 의해 완전히 가려질 경우 화면에 렌더링되지 않도록 컬링하는 기법

- 건물, 담벼락처럼 부피가 꽤 있어서 다른 오브젝트를 가릴 가능성이 많은 오브젝트는 `Occluder Static`으로 설정한다. <br>
  (`Occludee Static`도 함께 설정해도 된다.)
- 작은 프랍과 같이 가려질 가능성이 많은 오브젝트는 `Occludee Static`으로 설정한다.
- `Window` - `Rendering` - `Occlusion Culling` 창에서 베이크할 수 있다.

- 오브젝트끼리 서로 가리는 경우가 빈번하지 않은 야외의 씬에서는 오히려 오클루전 컬링이 비효율적일 수 있다.

<br>

## **카메라 사용 줄이기**
- 카메라는 현재 메인 카메라로 사용되지 않더라도 활성화가 되어 있으면 공간 변환, 컬링 등의 연산을 수행한다.
- 따라서 한 번에 하나의 카메라만 활성화하는 것이 좋다.
- 시네머신 애셋은 실제 카메라가 아닌 가상 카메라를 이용하므로 이런 걱정 없이 사용할 수 있다.

<br>

## **가벼운 쉐이더 사용하기**
- 그저 로직이 단순한 것은 의미가 없다.
- 실제로 연산의 부하가 적은 쉐이더를 사용하는 것이 좋다.

<br>

## **오버드로우(OverDraw), 알파 블렌딩(Alpha Blending) 최소화**
- 동일 픽셀에 여러 오브젝트가 그려지는 것을 오버드로우라고 한다.
- 마찬가지로 동일 픽셀에 여러 반투명(Transparent) 오브젝트의 픽셀 색상이 섞여 그려지는 연산을 알파 블렌딩이라고 한다.
- 쉽게 말해, 반투명 쉐이더의 사용을 최대한 줄이는 것이 좋다.

<br>

## **포스트 프로세싱 줄이기**
- <https://docs.unity3d.com/kr/2019.3/Manual/PostProcessingOverview.html>
- 포스트 프로세싱은 렌더링 결과 화면을 후처리하여 다양한 효과를 적용하는 것을 의미한다.
- 모든 스크린 픽셀에 대해 쉐이더를 적용하므로, 웬만해서 성능 상 좋지 않다.
- 따라서 반드시 필요한 포스트 프로세싱만 최소한으로 적용하는 것이 좋다.
- 또한, 포스트 프로세싱 효과마다 성능은 천차만별이므로 잘 알고 사용해야 한다.

<br>

## **리플렉션 프로브 사용 줄이기**
- <https://docs.unity3d.com/kr/current/Manual/ReflectionProbes.html>
- 리플렉션 프로브는 물체 표면의 반사 효과를 위해 사용된다.
- 성능을 많이 소모하기 때문에 최대한 사용을 줄이는 것이 좋다.
- 특히나 `Realtime` 모드로 사용하면 성능을 더 많이 소모하기 때문에 잘 고려해야 한다.

<br>

## **마테리얼 복사본 생성 주의하기**
- <https://docs.unity3d.com/ScriptReference/Renderer-material.html>
- <https://docs.unity3d.com/kr/current/Manual/GPUInstancing.html>
- `Renderer` 클래스의 `material` 프로퍼티를 직접 참조하면 해당 마테리얼의 복사본이 생성되고, 배칭이 깨져서 드로우 콜이 증가한다.
- 따라서 마테리얼의 프로퍼티에 접근하려면 `sharedMaterial` 프로퍼티를 통해 해당 마테리얼 전체의 프로퍼티에 접근하거나, <br>
  개별 마테리얼의 프로퍼티를 수정하려면 **GPU Instancing**을 적용하고 `MaterialPropertyBlock`을 사용하는 것이 좋다.

<br>

</details>



# UI 최적화
---

<details>
<summary markdown="span">
...
</summary>

## **캔버스 분할하기**
- UI의 드로우 콜 및 배칭은 캔버스 단위로 발생한다.
- 만약 하나의 UI에 변경사항이 발생하면 캔버스 전체가 다시 그려진다.
- 따라서 변경이 자주 발생하는 UI는 캔버스를 따로 분리하는 것이 좋다.

<br>

## **보이지 않는 UI 비활성화하기**
- UI를 화면 영역 밖으로 옮기거나, 투명도를 0으로 설정하는 경우가 있다.
- 이렇게 하면 보이지 않을 뿐이지, 모두 연산에 포함된다.
- 따라서 안보이게 하려면 비활성화하는 것이 좋다.

<br>

## **그래픽 레이캐스터 제거하기**
- 캔버스를 생성하면 `Graphic Raycaster` 컴포넌트도 함께 생성된다.
- `Graphic Raycaster` 컴포넌트는 해당 게임오브젝트의 모든 자식 UI 오브젝트에 대해 그래픽 레이캐스트 연산을 수행한다.
- 만약 해당 캔버스에 이미지와 텍스트처럼 사용자 입력이 필요 없는 UI만 존재한다면, 제거하는 것이 좋다.

- 하나의 캔버스 내에 이미지, 텍스트, 버튼 등 여러가지 UI가 존재할 수 있다.
- 여기서 사용자 입력이 필요한 UI는 버튼 뿐이다.
- 이런 경우에는 캔버스에서 `Graphic Raycaster` 컴포넌트를 제거하고, 버튼의 공통 부모 게임오브젝트에 옮겨주는 것이 좋다.

<br>

## **레이캐스트 타겟 설정 해제하기**
- `UnityEngine.UI.Graphic`을 상속받는 `UGUI` 컴포넌트들에는 `raycastTarget` 프로퍼티가 존재한다.
- 인스펙터에서 체크/해제할 수 있다.
- 체크된 경우 그래픽 레이캐스터의 연산 대상이 되므로, 사용자 입력을 받지 않는 UI의 경우에는 해제하는 것이 좋다.

<br>

## **레이아웃 그룹 사용하지 않기**
- `VerticalLayoutGroup`, `HorizontalLayoutGroup`, `GridLayoutGroup` 등의 컴포넌트들에 해당한다.
- 이런 컴포넌트는 실시간으로 UI를 재배치하고 조정하여 성능을 아주 맛있게 잡아먹는다.
- 따라서 에디터에서 UI 배치를 위해서 사용하고, 배포할 때는 제거하는 것이 좋다.
- 런타임에 이런 기능이 필요하다면 UI 요소 변경이 일어날 때만 재배치를 수행하는 기능을 직접 만들어 쓰는 것이 좋다.

<br>

## **UI 풀링하기**
- UI가 한 화면에 다 보이기에는 너무 많아서 스크롤이 필요한 경우가 있다.
- 이런 경우에는 동일한 종류의 수많은 UI가 배치된다.
- 화면에 그려지지 않더라도, 활성화 되어 있으면 성능을 소모하는데다가 메모리도 많이 잡아먹는다.
- 따라서 동일한 UI가 스크롤을 통해 반복되는 형태의 경우, 풀링을 통해 재사용하는 것이 좋다.

<br>

</details>



# 모바일 기기 최적화
---

<details>
<summary markdown="span">
...
</summary>

## **해상도 설정**
- 기기별로 해상도는 천차만별일 수 있다.
- 따라서 해상도가 너무 높은 경우에는 괜히 성능상 손해를 보게될 수 있으므로, <br>
  `Screen.SetResolution(width, height, false)` 메소드를 통해 적절한 수준으로 조절해야 한다.

- 해상도를 낮추면 UI 역시 해상도가 낮아지므로 품질이 떨어져 보일 수 있다.
- 따라서 이런 경우에는 오버레이 UI만 원래 해상도대로 그려줘야 하는데, <br>
  이를 업스케일 샘플링(**Upscale Sampling**)을 통해 해결할 수 있다.

- **URP**에서는 이런 기능을 기본적으로 제공한다.
- **URP**에서는 굳이 `SetResolution()` 메소드를 사용하지 않아도 <br>
  `URP Asset` - `Quality` - `Render Scale` 설정을 통해 <br>
  오버레이 UI를 제외한 게임 화면의 해상도를 낮출 수 있다.

- <https://github.com/ozlael/UpsamplingRenderingDemo>
- 레거시 파이프라인에서는 위의 예제처럼 카메라의 렌더 텍스쳐 해상도를 낮추는 방식을 사용하면 된다.

> 왠지 모르겠지만 위의 예제 코드에서는 굳이 RawImage 컴포넌트를 캔버스 아래에 넣고 그 이미지를 렌더 타겟으로 이용하는데, 그럴 필요는 없다. <br>
  거기다가 샘플링 스케일을 변경할 때마다 렌더 텍스쳐를 새로 생성하고 안지워주는데, 이러면 메모리에 계속 쌓이므로 반드시 이전 렌더 텍스쳐를 지워줘야 한다. (`.Release()`)

<br>

## **디바이스 시뮬레이터(Device Simulator) 사용하기**
- <https://docs.unity3d.com/Packages/com.unity.device-simulator@1.0/manual/index.html>
- 패키지 매니저를 통해 설치할 수 있다.
- 타겟 모바일 기기마다 해상도 등의 정보를 제공하여, 빌드 이전에 미리 다양한 환경에 대응할 수 있다.

<br>

</details>



# References
---
- <https://www.youtube.com/watch?v=1mJtoceqvro>
- <https://www.youtube.com/watch?v=RLcSRuZsZQU>
- <https://ozlael.tistory.com/category/Unity3D/Graphics>
- <http://egloos.zum.com/littles/v/3439290>
- <https://blog.unity.com/kr/technology/optimize-your-mobile-game-performance-expert-tips-on-graphics-and-assets>
- <https://blog.unity.com/kr/technology/artists-best-practices-for-mobile-game-development>
- <https://coderzero.tistory.com/entry/유니티-최적화-모바일용-최적화-실전-가이드>



