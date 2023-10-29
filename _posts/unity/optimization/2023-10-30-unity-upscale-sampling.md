---
title: 유니티 - 업스케일 샘플링(Upscale Sampling)
author: Rito15
date: 2023-10-30 00:58:00 +09:00
categories: [Unity, Unity Optimization]
tags: [unity, csharp, optimization]
math: true
mermaid: true
---

# 1. What is it?
---
모바일과 같은 환경에서는 종종 해상도를 낮춰서 최적화하는 방식을 사용할 때가 있다.

기기에서 최대로 사용 가능한 해상도보다 살짝 낮추면 생각보다 품질은 많이 떨어지지 않으면서, 상당한 성능 상의 여유를 얻을 수 있다.

그리고 라이팅이나 포스트 프로세싱 등 다른 영역에 리소스를 할당하여 전체적인 품질을 향상시킬 수 있다.

하지만 여기에 치명적인 단점이 존재한다.

바로 UI의 해상도를 낮추면 사용자가 해상도가 낮아졌다는 것을 보다 민감하게 받아들일 수 있다는 것이다.

이를 보완하기 위해, UI를 제외한 게임 화면은 해상도를 낮추고 UI의 해상도는 원본을 유지하는 방식을 선택할 수 있는데

이 트릭을 업스케일 샘플링(Upscale Sampling)이라고 한다.

<br>

# 2. How to
---

방법은 생각보다 간단하다.

1. UI를 제외한 모든 오브젝트를 렌더링하는 카메라를 씬에 배치한다.

2. UI만 렌더링하는 카메라를 씬에 배치한다.

3. 별도의 렌더 텍스쳐를 생성하는데, 이 때 렌더 텍스쳐의 해상도를 스크린의 해상도보다 낮춘다.

4. 렌더 텍스쳐를 1번 카메라의 렌더 타겟(Render Target)으로 지정한다.

<br>

# 3. Example
---

## [1] 원본 (해상도 100%)
- 1920 x 1080
- 약 75 FPS

![image](https://github.com/rito15/Images/assets/42164422/48a6ef5d-fe1a-47fc-b517-2b8b84a71c54)

## [2] 80% 샘플링
- 1536 x 864
- 약 90 FPS

![image](https://github.com/rito15/Images/assets/42164422/74598587-a4c6-4c7a-bd1c-57576ec6547d)

## [3] 50% 샘플링
- 960 x 540
- 약 110 FPS

![image](https://github.com/rito15/Images/assets/42164422/20cface9-026f-411c-a715-b1f7dce7a414)

## [4] 20% 샘플링
- 384 x 216
- 약 125 FPS

![image](https://github.com/rito15/Images/assets/42164422/f09f28f3-13a3-4ee5-9639-294934ddf56e)

## 해상도 변화
- 렌더 텍스쳐의 해상도를 낮춰도 UI의 해상도는 유지되는 것을 확인할 수 있다.
![2023_1030_UpscaleSampling](https://github.com/rito15/Images/assets/42164422/8e70cd30-239a-4cba-b38d-4d53e9bd8796)

<br>

# 4. Source Code Example
---
- 업스케일 샘플링을 간단히 적용할 수 있는 컨트롤러 컴포넌트 구현 예제
- 씬에 배치하면 알아서 동작하도록 작성하였다.

![image](https://github.com/rito15/Images/assets/42164422/2e321a7e-2bc7-4a72-90e7-1cc4a57d92ea)

<details>
<summary markdown="span"> 
Source Code
</summary>

{% include codeHeader.html %}
```cs
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Rito.CUT
{
    [DisallowMultipleComponent]
    public class UpscaleSampler : MonoBehaviour
    {
        #region Singleton 

        public static UpscaleSampler Instance
        {
            get
            {
                if (instance == null) CheckExsistence();
                return instance;
            }
        }
        public static UpscaleSampler I => Instance;
        private static UpscaleSampler instance;

        private static void CheckExsistence()
        {
            instance = FindObjectOfType<UpscaleSampler>();
            if (instance == null)
            {
                GameObject container = new GameObject("Upscale Sampler");
                instance = container.AddComponent<UpscaleSampler>();
            }
        }

        /// <summary> 
        /// [Awake()에서 호출]
        /// <para/> 싱글톤 스크립트를 미리 오브젝트에 담아 사용하는 경우를 위한 로직
        /// </summary>
        private void CheckInstance()
        {
            if (instance == null) instance = this;
            else if (instance != this)
            {
                Debug.Log("이미 UpscaleSampler 싱글톤이 존재하므로 오브젝트를 파괴합니다.");
                Destroy(this);
                var components = gameObject.GetComponents<Component>();
                if (components.Length <= 2) Destroy(gameObject);
            }
        }

        private void Awake()
        {
            CheckInstance();
        }

        #endregion // ==================================================================

        #region Upscale Sampler

        [Header("Options")]
        [SerializeField]
        [Tooltip("게임 시작 시 동작 여부")]
        private bool _runOnStart = true;

        [SerializeField, Range(0.1f, 1.0f)]
        [Tooltip("게임 시작 시 설정할 비율")]
        private float _targetRatio = 1.0f;

        [SerializeField]
        [Tooltip("UI만 제외하고 렌더링할 카메라")]
        private Camera _targetCamera;

        [SerializeField]
        [Tooltip("UI만 렌더링할 카메라")]
        private Camera _uiCamera;

        [SerializeField]
        [Tooltip("_targetCamera가 설정되지 않은 경우, 자동으로 현재 렌더링 카메라를 탐지할지 여부")]
        private bool _autoDetectMainCamera = true;

        [SerializeField]
        [Tooltip("메인 렌더링 카메라가 달라질 경우, 자동 탐지하여 적용")]
        private bool _autoDetectCameraChange = true;


        [Header("Target UI")]
        [SerializeField]
        [Tooltip("RawImage를 세팅할 대상 캔버스")]
        private Canvas _targetCanvas;

        [Header("Editor Options")]
        [SerializeField]
        [Tooltip("디버그 로그 출력 허용")]
        private bool _allowDebug = true;

        [SerializeField]
        [Tooltip("하이어라키에서 숨기기")]
        private bool _hideFromHiearchy = false;

        // Fields
        private int _currentWidth;
        private int _currentHeight;
        private float _currentRatio;
        private bool _initialized = false; // 한 번이라도 실행됐는지 여부
        private RenderTexture _currentRT;
        private UnityEngine.UI.RawImage _rawImage;

        [SerializeField, HideInInspector]
        private Shader _rawImageShader;

        private void Log(string msg)
        {
            if (!_allowDebug) return;
            Debug.Log($"[Upscale Sampler] {msg}", gameObject);
        }

        private void Reset()
        {
            _rawImageShader = Shader.Find("Unlit/Texture");
        }

        private void Start()
        {
            if (_runOnStart)
            {
                Run(_targetRatio);
            }
        }
        private void OnEnable()
        {
            StopCoroutine(nameof(DetectCameraChangeRoutine));
            StartCoroutine(nameof(DetectCameraChangeRoutine));
        }

        private IEnumerator DetectCameraChangeRoutine()
        {
            while (true)
            {
                if ((_initialized && _autoDetectCameraChange) && 
                    (_targetCamera == null || _targetCamera.enabled == false || _targetCamera.gameObject.activeInHierarchy == false))
                {
                    _targetCamera = null;
                    bool flag = Run(_currentRatio, forceRun: true);
                    if (flag)
                    {
                        Log("Camera Change Auto Detected");
                    }
                }
                yield return new WaitForSecondsRealtime(0.1f);
            }
        }

        private void OnDestroy()
        {
            ReleaseRT();
        }

        // forceRun : 이전 상태 관계 없이 강제 실행
        public bool Run(float ratio, bool forceRun = false)
        {
            if (ratio < 0.1f) ratio = 0.1f;
            if (ratio > 1.0f) ratio = 1.0f;

            int sourceW = Screen.width;
            int sourceH = Screen.height;
#if UNITY_EDITOR
            (sourceW, sourceH) = GetMainGameViewSize();
#endif
            int w = (int)(sourceW * ratio);
            int h = (int)(sourceH * ratio);

            if (!forceRun && _currentWidth == w && _currentHeight == h)
            {
                Log($"기존과 동일합니다. - {w}x{h} ({ratio})");
                return false;
            }

            ReleaseRT();
            if (!CreateRT(w, h)) return false;
            SetCamera();
            SetRawImage();
            HideFromHierarchy();

            _currentWidth  = w;
            _currentHeight = h;
            _currentRatio  = ratio;
            Log($"Screen: {sourceW}x{sourceH} / Sampled: {w}x{h} ({ratio * 100:F2}%)");

            _initialized = true;
            return true;
        }

        private bool CreateRT(int w, int h)
        {
            _currentRT = new RenderTexture(w, h, 24, RenderTextureFormat.DefaultHDR);
            _currentRT.Create();

            if (_autoDetectMainCamera)
            {
                if (_targetCamera == null) _targetCamera = Camera.main;
                NoUiCam();
                if (_targetCamera == null) _targetCamera = Camera.current;
                NoUiCam();
                if (_targetCamera == null) _targetCamera = FindObjectOfType<Camera>();
                NoUiCam();
            }
            if (_targetCamera == null)
            {
                Log("타겟 카메라를 찾을 수 없습니다.");
                return false;
            }

            return true;

            // --
            void NoUiCam()
            {
                if (_targetCamera != null && _targetCamera == _uiCamera)
                    _targetCamera = null;
            }
        }

        /// <summary> 타겟 카메라, UI 카메라 설정 </summary>
        private void SetCamera()
        {
            int uiLayerMask = 1 << LayerMask.NameToLayer("UI");

            _targetCamera.targetTexture = _currentRT;
            _targetCamera.cullingMask &= ~uiLayerMask; // UI 레이어만 제거

            if (_uiCamera == null)
            {
                GameObject uiCamGo = new GameObject("UI Only Camera");
                _uiCamera = uiCamGo.AddComponent<Camera>();
                _uiCamera.targetDisplay = _targetCamera.targetDisplay;
                _uiCamera.clearFlags = CameraClearFlags.Nothing;
                _uiCamera.cullingMask = uiLayerMask;
            }
        }

        /// <summary> 렌더 타겟을 RawImage에 세팅 </summary>
        private void SetRawImage()
        {
            if (_targetCanvas == null)
            {
                GameObject canvasGo = new GameObject("Upscale Sample Target Canvas");
                _targetCanvas = canvasGo.AddComponent<Canvas>();
                _targetCanvas.renderMode = RenderMode.ScreenSpaceOverlay;
                _targetCanvas.sortingOrder = -10000;
            }
            if (_rawImage == null)
            {
                GameObject rawImageGo = new GameObject("Upscale Sample Target RawImage");
                rawImageGo.transform.SetParent(_targetCanvas.transform);

                _rawImage = rawImageGo.AddComponent<UnityEngine.UI.RawImage>();
                _rawImage.raycastTarget = false;
                _rawImage.maskable = false;

                // 기본 마테리얼 할당
                _rawImage.material = new Material(_rawImageShader);

                RectTransform rect = _rawImage.rectTransform;
                rect.anchorMin = Vector2.zero;
                rect.anchorMax = Vector2.one;
                rect.offsetMin = Vector2.zero;
                rect.offsetMax = Vector2.zero;
#if UNITY_EDITOR
                ToggleSceneVisibility(_targetCanvas.gameObject);
#endif
            }
            _rawImage.texture = _currentRT;
        }

        private void ReleaseRT()
        {
            if (_currentRT != null)
            {
                _currentRT.Release();
            }
        }

        private void HideFromHierarchy()
        {
            if (_hideFromHiearchy == false) return;
            gameObject.hideFlags = 
            _targetCanvas.gameObject.hideFlags = 
            _uiCamera.gameObject.hideFlags = HideFlags.HideInHierarchy;
            Log("하이어라키에서 숨김처리 되었습니다.");
        }

#endregion

#region Editor Only
#if UNITY_EDITOR
        private static System.Reflection.MethodInfo GetSizeOfMainGameViewMi;

        // 커스텀 에디터에서 Screen.width, height를 참조하면 게임 뷰의 해상도를 가져오지 못하므로 에디터 스크립트 활용
        private static (int x, int y) GetMainGameViewSize()
        {
            if (GetSizeOfMainGameViewMi == null)
            {
                System.Type T = System.Type.GetType("UnityEditor.GameView,UnityEditor");
                GetSizeOfMainGameViewMi = T.GetMethod("GetSizeOfMainGameView", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
            }
            System.Object res = GetSizeOfMainGameViewMi.Invoke(null, null);
            Vector2 resVec = (Vector2)res;
            return ((int)resVec.x, (int)resVec.y);
        }
        [System.Diagnostics.Conditional("UNITY_EDITOR")]
        private static void ToggleSceneVisibility(GameObject target)
        {
            UnityEditor.SceneVisibilityManager.instance.DisablePicking(target, true);
            UnityEditor.SceneVisibilityManager.instance.Hide(target, true);
        }
#endif

#endregion

#region Custom Editor
#if UNITY_EDITOR
        [UnityEditor.CustomEditor(typeof(UpscaleSampler))]
        private class CE : UnityEditor.Editor
        {
            private UpscaleSampler t;

            private void OnEnable()
            {
                if (t == null) t = target as UpscaleSampler;
            }

            public override void OnInspectorGUI()
            {
                base.OnInspectorGUI();
                using (new UnityEditor.EditorGUI.DisabledGroupScope(true))
                {
                    t._rawImageShader = (Shader)UnityEditor.EditorGUILayout.ObjectField("Raw Image Shader", t._rawImageShader, typeof(Shader), allowSceneObjects: false);
                    if (t._rawImageShader == null)
                    {
                        t._rawImageShader = Shader.Find("Unlit/Texture");
                    }
                }
                UnityEditor.EditorGUILayout.Space(8f);

                if (Application.isPlaying == false) return;
                if (GUILayout.Button("Apply Now"))
                {
                    t.Run(t._targetRatio);
                }
                using (new UnityEditor.EditorGUILayout.HorizontalScope())
                {
                    DrawApplyButton(0.25f);
                    DrawApplyButton(0.50f);
                    DrawApplyButton(0.75f);
                    DrawApplyButton(1.00f);
                }
                using (new UnityEditor.EditorGUILayout.HorizontalScope())
                {
                    DrawApplyButton(0.2f);
                    DrawApplyButton(0.4f);
                    DrawApplyButton(0.6f);
                    DrawApplyButton(0.8f);
                    DrawApplyButton(1.0f);
                }
                using (new UnityEditor.EditorGUILayout.HorizontalScope())
                {
                    for(float f = 0.1f; f < 1.01f; f += 0.1f)
                        DrawApplyButton2(f);
                }
            }

            private void DrawApplyButton(float ratio)
            {
                if (GUILayout.Button($"{ratio:F2}"))
                {
                    t.Run(ratio);
                }
            }

            private void DrawApplyButton2(float ratio)
            {
                if (GUILayout.Button($"{ratio:F1}"))
                {
                    t.Run(ratio);
                }
            }
        }
#endif
#endregion
    }
}
```

</details>

<br>


# References
---
- <https://github.com/ozlael/UpsamplingRenderingDemo>


