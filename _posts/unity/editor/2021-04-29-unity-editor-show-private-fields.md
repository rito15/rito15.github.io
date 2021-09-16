---
title: 유니티 - 커스텀 에디터로 인스펙터에 Private 필드 나타내기
author: Rito15
date: 2021-04-29 20:30:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp]
math: true
mermaid: true
---

# Memo
---

커스텀 에디터를 통해서 private 필드를 인스펙터에 표시하려면 일단 두 가지 방법이 있다.

<br>

## **1. 내부 클래스로 작성**

커스텀 에디터 클래스를 대상 모노비헤이비어 클래스의 내부에 작성하면 private 필드에도 접근할 수 있다.

```cs
public partial class RadialMenu : MonoBehaviour
{
    [CustomEditor(typeof(RadialMenu))]
    public class RadialMenuEditor : UnityEditor.Editor
    {
        private RadialMenu rm;

        private void OnEnable()
        {
            rm = target as RadialMenu;
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("Selected Index", rm._selectedIndex.ToString());
            rm._pieceCount = EditorGUILayout.IntSlider(rm._pieceCount, 2, 16);
        }
    }
}
```

<br>

## **2. SerializedProperty**

커스텀 에디터 클래스 내에서 `serializedObject.FindProperty()`를 이용하여 내부적으로 리플렉션을 통해 해당하는 필드의 `SerializedProperty`를 가져와 사용한다.

이 때, 대상 필드는 반드시 `[SerializeField]`를 적용해야 한다.

```cs
[CustomEditor(typeof(RadialMenu))]
public class RadialMenuEditor : UnityEditor.Editor
{
    private RadialMenu rm;

    private SerializedProperty _selectedIndex;
    private SerializedProperty _pieceCount;

    private void OnEnable()
    {
        rm = target as RadialMenu;

        _selectedIndex = serializedObject.FindProperty(nameof(_selectedIndex));
        _pieceCount = serializedObject.FindProperty(nameof(_pieceCount));
    }

    public override void OnInspectorGUI()
    {
        //EditorGUILayout.PropertyField(_selectedIndex);
        EditorGUILayout.LabelField("Selected Index", _selectedIndex.intValue.ToString());
        EditorGUILayout.IntSlider(_pieceCount, 2, 16, "Piece Count");

        serializedObject.ApplyModifiedProperties();
    }
}
```

`EditorGUILayout.PropertyField()`를 통해 나타내는 것이 제일 간편하지만,

`[Header]`, `[Space]` 등 해당 필드에 적용된 애트리뷰트의 효과가 모두 인스펙터에 나타나므로 주의해야 한다.

그리고 반드시 `serializedObject.ApplyModifiedProperties()`를 호출해야 인스펙터에서 값을 변경할 수 있다.

