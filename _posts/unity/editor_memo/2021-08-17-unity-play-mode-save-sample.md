---
title: 유니티 - Play Mode Save Sample
author: Rito15
date: 2021-08-17 04:32:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Memo
---

- 플레이모드 -> 에디터모드 진입 시 플레이모드의 변경사항 유지

```cs
public class Sample_PlayModeSave : MonoBehaviour
{
    /***********************************************************************
    *                           Save Play Mode Changes
    ***********************************************************************/
    #region .
#if UNITY_EDITOR
    private class Inner_PlayModeSave
    {
        private static UnityEditor.SerializedObject[] targetSoArr;

        [UnityEditor.InitializeOnLoadMethod]
        private static void Run()
        {
            UnityEditor.EditorApplication.playModeStateChanged += state =>
            {
                switch (state)
                {
                    case UnityEditor.PlayModeStateChange.ExitingPlayMode:
                    //var targets = FindObjectsOfType(typeof(Inner_PlayModeSave).DeclaringType); // 비활성 오브젝트 제외
                    var targets = Resources.FindObjectsOfTypeAll(typeof(Inner_PlayModeSave).DeclaringType); // 비활성 오브젝트 포함
                        targetSoArr = new UnityEditor.SerializedObject[targets.Length];
                        for (int i = 0; i < targets.Length; i++)
                            targetSoArr[i] = new UnityEditor.SerializedObject(targets[i]);
                        break;

                    case UnityEditor.PlayModeStateChange.EnteredEditMode:
                        // NOTE : 플레이 도중/직후 컴파일 시 targetSoArr은 null로 초기화
                        if (targetSoArr == null) break;
                        foreach (var oldSO in targetSoArr)
                        {
                            if (oldSO.targetObject == null) continue;
                            var oldIter = oldSO.GetIterator();
                            var newSO = new UnityEditor.SerializedObject(oldSO.targetObject);
                            while (oldIter.NextVisible(true))
                                newSO.CopyFromSerializedProperty(oldIter);
                            newSO.ApplyModifiedProperties();
                        }
                        break;
                }
            };
        }
    }
#endif
    #endregion
}
```