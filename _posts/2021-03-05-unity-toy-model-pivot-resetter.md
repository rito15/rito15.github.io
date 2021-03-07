---
title: Model Pivot Resetter (모델 임포트 시 피벗 자동 초기화)
author: Rito15
date: 2021-03-05 22:22:00 +09:00
categories: [Unity, Unity Toys]
tags: [unity, csharp, plugin, model, pivot, postprocessor]
math: true
mermaid: true
---

# Note
---
- 모델링 파일을 유니티로 가져올 때 동작하는 애셋포스트프로세서
- 모델의 회전과 위치를 리셋한다.
- 모델의 정점 위치를 모두 계산하여, 피벗이 모델의 중심 하단으로 오게 한다.

<br>

# How To Use
---
- 스크립트를 유니티 프로젝트 내에 넣는다.

- [Window] - [Rito] - [Model Pivot Resetter] - [Activated]를 체크한다.
  - 체크 해제되어 있을 경우 동작하지 않는다.

![image](https://user-images.githubusercontent.com/42164422/110126112-6dfb7900-7e07-11eb-8145-eb635f7b8761.png)

- 임포트 할 때마다 대화상자를 통해 선택하게 하려면<br>
  [Window] - [Rito] - [Model Pivot Resetter] - [Show Dialog]에 체크한다.

![image](https://user-images.githubusercontent.com/42164422/110122641-3559a080-7e03-11eb-8db9-4d3247738a35.png)

<br>

# Preview
---

## 기본


- 모델 임포트, 하이라키로 가져왔을 때
  - 트랜스폼 위치, 회전, 크기, 피벗 모두 제각각이다.

![image](https://user-images.githubusercontent.com/42164422/110127359-e282e780-7e08-11eb-8fbc-9c7fe9debc58.png)


- 이 상태에서 트랜스폼을 리셋한 경우
  - (0, 0, 0) 위치로 와서 드러누워 버린다. (기존 rotation.x 값 : 270)

![image](https://user-images.githubusercontent.com/42164422/110122836-7a7dd280-7e03-11eb-96e0-ad1baf381101.png)


<br>

## Pivot Resetter 사용

- 트랜스폼 위치, 회전, 크기 모두 기본 값으로 정상 리셋된다.

- 피벗 위치는 모델의 중앙 하단으로 변경된다.

![image](https://user-images.githubusercontent.com/42164422/110123018-bd3faa80-7e03-11eb-9c25-25f4d8e3fe58.png)

<br>

# Download
---
- [ModelPivotResetter.zip](https://github.com/rito15/Images/files/6090997/ModelPivotResetter.zip)

<br>

# Source Code
---
- <https://github.com/rito15/Unity_Toys>

<details>
<summary markdown="span"> 
.
</summary>

```cs

#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;

// 날짜 : 2021-03-05 PM 9:38:46
// 작성자 : Rito

// 기능
//  - 임포트되는 모델의 트랜스폼을 자동 리셋한다.
//  - 피벗을 모델의 중심 하단 좌표로 위치시킨다.

// 옵션
//  - [Window] - [Rito] - [Model Pivot Resetter] - [Activated]를 통해 동작 여부를 결정할 수 있다.
//  - [Window] - [Rito] - [Model Pivot Resetter] - [Show Dialog]를 체크할 경우,
//    모델을 임포트할 때마다 기능 적용 여부를 다이얼로그를 통해 선택할 수 있다.

namespace Rito
{
    public class ModelPivotResetter : AssetPostprocessor
    {
        private void OnPostprocessModel(GameObject go)
        {
            if(!Activated) return;

            if(!ShowDialog)
                ResetModelPivot(go);

            else if (EditorUtility.DisplayDialog("Model Pivot Resetter", $"Reset Pivot of {go.name}", "Yes", "No"))
                ResetModelPivot(go);
        }

        private void ResetModelPivot(GameObject go)
        {
            var meshes = go.GetComponentsInChildren<MeshFilter>();

            foreach (var meshFilter in meshes)
            {
                Mesh m = meshFilter.sharedMesh;
                Vector3[] vertices = m.vertices;

                // 1. 로컬 트랜스폼 초기화하면서 정점 돌려놓기
                for (int i = 0; i < m.vertexCount; i++)
                {
                    vertices[i] = go.transform.TransformPoint(m.vertices[i]);
                }

                go.transform.localRotation = Quaternion.identity;
                go.transform.localPosition = Vector3.zero;
                go.transform.localScale = Vector3.one;

                // 2. 피벗을 모델 중심 하단으로 변경
                Vector3 modelToPivotDist = -GetBottomCenterPosition(vertices);

                for (int i = 0; i < m.vertexCount; i++)
                {
                    vertices[i] += modelToPivotDist;
                }

                // 3. 메시에 적용
                m.vertices = vertices;
                m.RecalculateBounds();
                m.RecalculateNormals();

                Debug.Log($"Pivot Reset - {go.name}::{meshFilter.gameObject.name}");
            }
        }

        /// <summary> 모델의 XZ 중심, Y 하단 위치 구하기 </summary>
        private Vector3 GetBottomCenterPosition(Vector3[] vertices)
        {
            float minX = float.MaxValue, minZ = float.MaxValue, minY = float.MaxValue;
            float maxX = float.MinValue, maxZ = float.MinValue;

            foreach (var vert in vertices)
            {
                if(minX > vert.x) minX = vert.x;
                if(minZ > vert.z) minZ = vert.z;
                if(minY > vert.y) minY = vert.y;

                if(maxX < vert.x) maxX = vert.x;
                if(maxZ < vert.z) maxZ = vert.z;
            }
            float x = (minX + maxX) * 0.5f;
            float z = (minZ + maxZ) * 0.5f;
            float y = minY;

            return new Vector3(x, y, z);
        }

        /***********************************************************************
        *                               Menu Item
        ***********************************************************************/
        #region .
        // 1. On/Off
        private const string ActivationMenuName = "Window/Rito/Model Pivot Resetter/Activated";
        private const string ActivationSettingName = "ModelPivotResetterActivated";

        public static bool Activated
        {
            get { return EditorPrefs.GetBool(ActivationSettingName, true); }
            set { EditorPrefs.SetBool(ActivationSettingName, value); }
        }

        [MenuItem(ActivationMenuName)]
        private static void ActivationToggle() => Activated = !Activated;

        [MenuItem(ActivationMenuName, true)]
        private static bool ActivationToggleValidate()
        {
            Menu.SetChecked(ActivationMenuName, Activated);
            return true;
        }

        // 2. Show Dialog
        private const string ShowDialogMenuName = "Window/Rito/Model Pivot Resetter/Show Dialog";
        private const string ShowDialogSettingName = "ModelPivotResetterShowDialog";

        public static bool ShowDialog
        {
            get { return EditorPrefs.GetBool(ShowDialogSettingName, true); }
            set { EditorPrefs.SetBool(ShowDialogSettingName, value); }
        }

        [MenuItem(ShowDialogMenuName)]
        private static void ShowDialogToggle() => ShowDialog = !ShowDialog;

        [MenuItem(ShowDialogMenuName, true)]
        private static bool ShowDialogToggleValidate()
        {
            Menu.SetChecked(ShowDialogMenuName, ShowDialog);
            return true;
        }

        #endregion
    }
}

#endif
```

</details>


# References
---
- <https://alqu.tistory.com/?page=4>