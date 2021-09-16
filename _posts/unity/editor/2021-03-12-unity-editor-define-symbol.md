---
title: 유니티 - Scripting Define Symbol 스크립트로 제어하기
author: Rito15
date: 2021-03-12 18:28:00 +09:00
categories: [Unity, Unity Editor]
tags: [unity, editor, csharp, define, symbol]
math: true
mermaid: true
---

# Scripting Define Symbol?
---

![image](https://user-images.githubusercontent.com/42164422/110923555-60447700-8364-11eb-96a6-845bf9b9096b.png)

- 스크립트에서 `#define`으로 정의하듯, 프로젝트 전체에서 정의하여 사용할 수 있는 심볼

- `Project Settings` - `Player` - `Other Settings` - `Scripting Define Symbols`

- 빌드 타겟마다 달라진다.

- 유니티 에디터 스크립팅을 통해 확인, 추가, 제거할 수 있다.

<br>

# Source Code
---

```cs
using System.Text.RegularExpressions;
using UnityEditor;

public static class DefineSymbolManager
{
    public struct DefineSymbolData
    {
        public BuildTargetGroup buildTargetGroup; // 현재 빌드 타겟 그룹
        public string fullSymbolString;           // 현재 빌드 타겟 그룹에서 정의된 심볼 문자열 전체
        public Regex symbolRegex;

        public DefineSymbolData(string symbol)
        {
            buildTargetGroup = EditorUserBuildSettings.selectedBuildTargetGroup;
            fullSymbolString = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup);
            symbolRegex = new Regex(@"\b" + symbol + @"\b(;|$)");
        }
    }

    /// <summary> 심볼이 이미 정의되어 있는지 검사 </summary>
    public static bool IsSymbolAlreadyDefined(string symbol)
    {
        DefineSymbolData dsd = new DefineSymbolData(symbol);

        return dsd.symbolRegex.IsMatch(dsd.fullSymbolString);
    }

    /// <summary> 심볼이 이미 정의되어 있는지 검사 </summary>
    public static bool IsSymbolAlreadyDefined(string symbol, out DefineSymbolData dsd)
    {
        dsd = new DefineSymbolData(symbol);

        return dsd.symbolRegex.IsMatch(dsd.fullSymbolString);
    }

    /// <summary> 특정 디파인 심볼 추가 </summary>
    public static void AddDefineSymbol(string symbol)
    {
        // 기존에 존재하지 않으면 끝에 추가
        if (!IsSymbolAlreadyDefined(symbol, out var dsd))
        {
            PlayerSettings.SetScriptingDefineSymbolsForGroup(dsd.buildTargetGroup, $"{dsd.fullSymbolString};{symbol}");
        }
    }

    /// <summary> 특정 디파인 심볼 제거 </summary>
    public static void RemoveDefineSymbol(string symbol)
    {
        // 기존에 존재하면 제거
        if (IsSymbolAlreadyDefined(symbol, out var dsd))
        {
            string strResult = dsd.symbolRegex.Replace(dsd.fullSymbolString, "");

            PlayerSettings.SetScriptingDefineSymbolsForGroup(dsd.buildTargetGroup, strResult);
        }
    }
}
```