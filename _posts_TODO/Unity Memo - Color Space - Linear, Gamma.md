
# TITLE : Unity - Gamma Correction, Linear/Gamma Color Space


# 모니터의 색상 변환
---
- 모니터는 디스크에 저장된 이미지를 화면에 출력할 때 `Pow(color, 2.2)` 연산을 적용해서 더 어둡게 출력한다.

- 이유?
  - 베버의 법칙(Weber's law)
  - 사람의 시각은 어두운 부분의 밝기 변화를 부드럽지 않고 단절되게 감지한다.
  - 그래서 어두운 부분의 화질이 떨어져 보이는 현상이 발생한다.
  - 따라서 이를 부드럽게 감지하도록 하려면 어두운 부분을 더 풍부하게 표현할 필요가 있다.
  - 따라서 모니터 하드웨어적으로 이런 변환을 해준다.

- `Pow(color, 2.2)`이면 감마(Gamma)가 `2.2`라고 한다.

<br>

# Gamma Correction(감마 보정)이란?
---
- 이미지를 디스크에 저장할 때 `Pow(value, 1/2.2)` 연산을 적용해서 더 밝게 저장한다.
- 모니터의 색상 변환에 대응하여, 원본 색상을 화면에 제대로 출력하기 위해 수행한다.


<br>

# sRGB란?
---

- 모니터, 카메라 등의 표준 RGB 색 공간
- 감마 값이 `2.2`인 색 공간
- 감마 보정(`Pow(value, 2.2)`)을 통해 밝게 저장된 이미지의 색 공간을 의미한다.

<br>


# 유니티의 색 공간
---

## 유니티 파이프라인별 기본 색 공간
- Built-in : Gamma
  - Linear 파이프라인을 지원하지 못하는 구형 기기들을 모두 호환하기 위해서 기본 색공간이 Gamma Space로 설정된다.

- SRP : Linear



## 색 공간의 차이?
- 연산을 어디서(어떤 상태에서) 하느냐의 차이
- Gamma Space : 이미 Gamma로 변환된 상태의 색상을 갖고 연산 수행
- Linear Space : Gamma로 변환된 색상을 다시 Linear로 변환시켜서, 원래 색상을 갖고 연산을 수행



## 유니티 텍스쳐의 sRGB 토글 체크 여부의 차이
- sRGB 체크 안하면 원래 색상 그대로 저장된다.(Linear)
- 정확한 값이 요구되는, 데이터 텍스쳐의 경우 Linear로 사용한다.

- sRGB 체크하면 해당 텍스쳐가 Gamma Correction 적용(`^0.45`)된 텍스쳐라고 생각하고, `^2.2` 해서 실제 색상으로 복원해서 연산할 수 있게 한다.







# References
---
- <https://www.youtube.com/watch?v=Xwlm5V-bnBc>
- <https://blog.naver.com/PostView.nhn?blogId=cdw0424&logNo=221827528747>
- <https://www.slideshare.net/agebreak/color-space-gamma-correction>
- <https://chulin28ho.tistory.com/241>
- <https://chulin28ho.tistory.com/456>
- <https://chulin28ho.tistory.com/472>
- <https://www.cambridgeincolour.com/tutorials/gamma-correction.htm>

- <https://smartits.tistory.com/130>
- <http://rapapa.net/?p=3406>
- <https://boysboy3.tistory.com/58>

- <https://docs.unity3d.com/kr/2019.3/Manual/LinearLighting.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearOrGammaWorkflow.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearTextures.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-GammaTextures.html>