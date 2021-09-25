
# TITLE : Unity - Gamma Correction, Linear/Gamma Color Space




## Gamma Correction(감마 보정)이란?
- 리니어 -> 감마
- 하는 이유 ? 모든 모니터는 컴퓨터 내의 색상을 출력할 때 실제 색상보다 더 어둡게 출력하기 때문에, 모니터에 출력하기 전에 최종 출력 색상을 밝게 만들어야 진짜 원래 보여주려고 했던 색상을 제대로 모니터에 보여줄 수 있음

- `Pow(value, 1/2.2)` 연산 (`1/2.2는 0.4545....`)
- 더 밝아짐



## 감마 변환
- 감마 -> 리니어
- 감마 변환되어서 저장해놓은 텍스쳐를 리니어 공간에서 정확한 값으로 작업할 수 있도록 다시 변환
- 그러니까 이미 Linear로 만들어 놓은 텍스쳐에는 Gamma Correction 하면 안되고, Gamma로 저장해놓은 텍스쳐를 다시 되돌리기 위해 사용
- 왜냐? 포토샵 같은 툴에서는 애초에 감마 코렉션 해서 파일에 저장 해버리기 때문

- `Pow(value, 2.2)` 연산
- 더 어두워짐



## 유니티 파이프라인별 기본 컬러 공간
- Built-in : Gamma
- SRP : Linear



## 컬러 공간의 차이?
- 연산을 어디서(어떤 상태에서) 하느냐의 차이
- Gamma Space : 이미 Gamma로 변환된 상태의 색상을 갖고 연산 수행
- Linear Space : Gamma로 변환된 색상을 다시 Linear로 변환시켜서, 원래 색상을 갖고 연산을 수행



## sRGB 란?
- 머임?



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

- <https://smartits.tistory.com/130>
- <http://rapapa.net/?p=3406>
- <https://boysboy3.tistory.com/58>

- <https://docs.unity3d.com/kr/2019.3/Manual/LinearLighting.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearOrGammaWorkflow.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-LinearTextures.html>
- <https://docs.unity3d.com/kr/2019.3/Manual/LinearRendering-GammaTextures.html>