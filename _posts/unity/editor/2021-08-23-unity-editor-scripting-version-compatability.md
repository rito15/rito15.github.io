---
title: 유니티 에디터 스크립팅 - 버전 호환 시 고려사항들
author: Rito15
date: 2021-08-23 20:00:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, memo]
math: true
mermaid: true
---

# EditorGUILayout.Space(float)
---

<details>
<summary markdown="span"> 
.
</summary>

- `2019.3` 미만의 버전에서는 `.Space()`만 존재하고 `.Space(float)`가 존재하지 않는다.

- 따라서 `.Space()`를 통해서는 높이 `8`의 고정된 여백만 넣을 수 있다.

- 이에 대응하기 위해서는 다음과 같이 사용하면 된다.

```cs
private static void Space(float height)
{
#if UNITY_2019_3_OR_NEWER
    EditorGUILayout.Space(height);
#else
    GUILayoutUtility.GetRect(1f, height);
#endif
}
```

- `GUILayoutUtility.GetRect(width, height)`에서 `width`는 어떤 값을 넣든 상관없다.<br>
  `HorizontalLayout` 내에서만 `width`가 효력이 있으며,<br>
  그 외의 경우에는 우측 스크롤바를 제외한 `ViewWidth`로 지정된다.

</details>


<br>

# ShaderPropertyType
---

<details>
<summary markdown="span"> 
.
</summary>

- `2019.3` 버전에서부터 `ShaderPropertyType` 열거형의 네임스페이스가 바뀌었다.

- 따라서 다음과 같이 대응하면 된다.

- 구버전에서는 `UnityEditor`에 있으니, `UNITY_EDITOR` 조건도 지정해주는 것이 좋다.

```cs
#if UNITY_2019_3_OR_NEWER
using ShaderPropertyType = UnityEngine.Rendering.ShaderPropertyType;
#elif UNITY_EDITOR
using ShaderPropertyType = UnityEditor.ShaderUtil.ShaderPropertyType;
#endif
```

<br>

- 추가적으로, 열거형 내부의 값 개수나 순서는 바뀌지 않았지만 이름 하나가 바뀌었다.

```cs
// 구버전
public enum ShaderPropertyType
{
    Color  = 0,
    Vector = 1,
    Float  = 2,
    Range  = 3,
    TexEnv = 4
}

// 2019.3 버전 이상
public enum ShaderPropertyType
{
    Color   = 0,
    Vector  = 1,
    Float   = 2,
    Range   = 3,
    Texture = 4  // TexEnv -> Texture
}
```

<br>

## + 런타임에 접근해야 하는 경우

```cs
#if UNITY_2019_3_OR_NEWER
using ShaderPropertyType = UnityEngine.Rendering.ShaderPropertyType;
#else
public enum ShaderPropertyType
{
    Color = 0,
    Vector = 1,
    Float = 2,
    Range = 3,
    Texture = 4
}
#endif
```

- 이렇게 대응하고, `UnityEditor.ShaderUtil.ShaderPropertyType` 타입으로 결과를 받는 부분들은 `(ShaderPropertyType)`으로 명시적 캐스팅을 해주면 된다.

</details>

<br>

# Shader.GetProperty ~ 
---

<details>
<summary markdown="span"> 
.
</summary>

- `2019.3` 버전을 기점으로 `UnityEditor.ShaderUtil` 클래스의 기능들이 `UnityEngine.Shader` 클래스로 옮겨왔다.

- 따라서 구버전 호환을 위해서는 다음과 같이 확장 메소드를 만들어 사용해야 한다.

```cs
#if UNITY_EDITOR
internal static class EditorExtensions
{
#if !UNITY_2019_3_OR_NEWER
    public static int GetPropertyCount(this Shader shader)
    {
        return UnityEditor.ShaderUtil.GetPropertyCount(shader);
    }

    public static Vector2 GetPropertyRangeLimits(this Shader shader, int index)
    {
        Vector2 ret = new Vector2();
        ret.x = UnityEditor.ShaderUtil.GetRangeLimits(shader, index, 1);
        ret.y = UnityEditor.ShaderUtil.GetRangeLimits(shader, index, 2);
        return ret;
    }

    public static string GetPropertyName(this Shader shader, int index)
    {
        return UnityEditor.ShaderUtil.GetPropertyName(shader, index);
    }

    public static string GetPropertyDescription(this Shader shader, int index)
    {
        return UnityEditor.ShaderUtil.GetPropertyDescription(shader, index);
    }

    public static ShaderPropertyType GetPropertyType(this Shader shader, int index)
    {
        return UnityEditor.ShaderUtil.GetPropertyType(shader, index);
    }
#endif
}
#endif
```

<br>

## **추가 변동 사항 : Property Index**

- `2019.3`버전 이상의 `shader.FindPropertyIndex(string name)`에 대응되는 메소드가 구버전에서는 존재하지 않는다.

- 신버전에서는 `GetPropertyDescription()`, `GetPropertyRangeLimits()` 메소드의 매개변수 `index`에 별도의 `Property Index`를 넣어야 했으나, 구버전에서는 그냥 쉐이더 내 프로퍼티 순서 인덱스(0부터 시작)를 넣어주면 된다.

- 따라서 신버전에서 `Property Index`를 사용하던 부분은 다음과 같이 대응할 수 있다.

```cs
int propertyCount = shader.GetPropertyCount();

// 쉐이더 프로퍼티 목록 순회하면서 데이터 참조

for (int i = 0; i < propertyCount; i++)
{
    // 구,신버전 동일 : 단순 인덱스
    ShaderPropertyType propType = shader.GetPropertyType(i);

    if ((int)propType != 4) // 4 : Texture
    {

        // 구,신버전 동일 : 단순 인덱스
        string propName = shader.GetPropertyName(i);

#if UNITY_2019_3_OR_NEWER
        int propIndex = shader.FindPropertyIndex(propName);
#else
        int propIndex = i;
#endif

        // 구버전 : 단순 인덱스
        // 신버전 : 별도의 Property Index
        string dispName = shader.GetPropertyDescription(propIndex);
    }
}
```

</details>





