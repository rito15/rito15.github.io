---
title: 유니티 에디터 - 벡터 필드의 X,Y,Z,W 레이블 변경하기
author: Rito15
date: 2021-08-27 22:33:00 +09:00
categories: [Unity, Unity Editor Memo]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# Note
---

![image](https://user-images.githubusercontent.com/42164422/131136622-f8e3a7c4-c6bc-4a66-94f7-1ee599618029.png)

- `Vector2`, `Vector3`, `Vector4` 필드에는 `X`, `Y`, `Z`, `W` 레이블이 표시되며, 일반적인 방법으로는 변경할 수 없다.

- 리플렉션을 이용하면 이를 변경할 수 있다.

<br>

![image](https://user-images.githubusercontent.com/42164422/131138206-fb6e1944-2cd0-4f0b-a289-e376cf7efd49.png)

```cs
// using System.Reflection;
// 커스텀 에디터 클래스 내에서 작성

private Vector2 vec2;
private Vector3 vec3;
private Vector4 vec4;

private static FieldInfo  fiVector4FieldLables;
private static GUIContent[] vector4FieldLables;

public override void OnInspectorGUI()
{
    BindingFlags privateStatic = BindingFlags.Static | BindingFlags.NonPublic;

    // Vector4 필드의 XYZW 레이블
    if (fiVector4FieldLables == null)
    {
        fiVector4FieldLables = typeof(EditorGUI).GetField("s_XYZWLabels", privateStatic);
        vector4FieldLables = fiVector4FieldLables.GetValue(null) as GUIContent[];
    }


    // [1] Vector2 : X, Y -> A, B로 변경
    vector4FieldLables[0].text = "A";
    vector4FieldLables[1].text = "B";

    vec2 = EditorGUILayout.Vector2Field("Vec2", vec2);


    // [2] Vector3 : X, Y, Z -> ㄴ ㅇ ㄱ 으로 변경
    vector4FieldLables[0].text = "ㄴ";
    vector4FieldLables[1].text = "ㅇ";
    vector4FieldLables[2].text = "ㄱ";

    vec3 = EditorGUILayout.Vector3Field("Vec3", vec3);


    // [3] Vector4 : X, Y, Z, W -> R, G, B, A로 변경
    vector4FieldLables[0].text = "R";
    vector4FieldLables[1].text = "G";
    vector4FieldLables[2].text = "B";
    vector4FieldLables[3].text = "A";

    vec4 = EditorGUILayout.Vector4Field("Vec4", vec4);


    // X, Y, Z, W 레이블 복원
    vector4FieldLables[0].text = "X";
    vector4FieldLables[1].text = "Y";
    vector4FieldLables[2].text = "Z";
    vector4FieldLables[3].text = "W";
}
```