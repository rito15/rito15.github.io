---
title: 간단한 앰플리파이 쉐이더 예제 모음
author: Rito15
date: 2021-06-27 04:24:00 +09:00
categories: [Unity Shader, Amplify Shader]
tags: [unity, csharp, shader, amplify]
math: true
mermaid: true
pin: true
---

# Note
---

- 각 예제마다 있는 `Copy & Paste` 부분의 코드를 복사하고, <br>
  앰플리파이 쉐이더 에디터에 **Ctrl + V**로 붙여 넣어서 곧바로 해당 노드들을 생성할 수 있습니다.

<br>

# 1. Vertex
---

## **Scale Up and Down**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/a358e6ec
```

<!--
AMPLIFY_CLIPBOARD_ID;1016.475,568.8261,0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleTimeNode;100;925.7732,574.7208;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
WireConnection;100;0;99;0#CLIP_ITEM#Node;AmplifyShaderEditor.SinOpNode;101;1082.773,573.7208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;101;0;100;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;98;1057.206,499.0731;Inherit;False;Constant;_Amplitude;Amplitude;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;99;800.5505,569.0001;Inherit;False;Constant;_Speed;Speed;1;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NormalVertexDataNode;102;1029.773,646.7208;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;1202.773,549.7208;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;103;0;98;0
WireConnection;103;1;101;0
WireConnection;103;2;102;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123306240-00ad5880-d55c-11eb-847a-feeba45ffa89.gif)

<br>

## **Heartbeat**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/e6f80d1c
```

<!--
AMPLIFY_CLIPBOARD_ID;1267.711,953.8973,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;104;837.3104,911.7973;Inherit;False;Constant;_Frequency;Frequency;1;0;Create;True;0;0;0;False;0;False;10;0;0;20;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;105;960.3106,993.7974;Inherit;False;Constant;_Sensitivity;Sensitivity;1;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleTimeNode;108;1090.311,917.7973;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
WireConnection;108;0;104;0#CLIP_ITEM#Node;AmplifyShaderEditor.SinOpNode;110;1243.311,918.7974;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;110;0;108;0#CLIP_ITEM#Node;AmplifyShaderEditor.OneMinusNode;107;1215.311,997.7974;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;107;0;105;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMaxOpNode;111;1370.311,941.7973;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;111;0;110;0
WireConnection;111;1;107;0#CLIP_ITEM#Node;AmplifyShaderEditor.NormalVertexDataNode;114;1460.811,1070.297;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;1494.311,973.7974;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;112;0;111;0
WireConnection;112;1;107;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;106;1358.311,863.7973;Inherit;False;Constant;_Amplitude;Amplitude;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;2;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;1646.811,949.2974;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;113;0;106;0
WireConnection;113;1;112;0
WireConnection;113;2;114;0
-->

</details>

![2021_0627_Heartbeat](https://user-images.githubusercontent.com/42164422/123522819-e8c00b00-d6fa-11eb-8c09-c5bf9880efee.gif)

```
( max( sin(T * F), 1-S ) - (1-S) ) * A

T : Time
F : Frequency
S : Sensitivity
A : Amplitude
```

<br>

## **World Position Offset**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/a60cd49e
```

<!--
AMPLIFY_CLIPBOARD_ID;-182.12,293.5854,0#CLIP_ITEM#Node;AmplifyShaderEditor.Vector3Node;69;-565.8174,264.1153;Inherit;False;Constant;_TargetWorldPosition3;Target World Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;70;-619.8175,405.1156;Inherit;False;Constant;_T;T;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldPosInputsNode;71;-520.8173,127.1153;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3#CLIP_ITEM#Node;AmplifyShaderEditor.LerpOp;72;-317.8173,245.1153;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
WireConnection;72;0;71;0
WireConnection;72;1;69;0
WireConnection;72;2;70;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;73;-300.8173,363.1156;Inherit;False;Constant;_1;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;74;-151.8171,288.1155;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;74;0;72;0
WireConnection;74;3;73;0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldToObjectTransfNode;75;-18.81711,288.1155;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;75;0;74;0#CLIP_ITEM#Node;AmplifyShaderEditor.PosVertexDataNode;76;154.1521,359.6325;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;78;190.2121,289.0362;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
WireConnection;78;0;75;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;330.157,306.3773;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;77;0;78;0
WireConnection;77;1;76;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123471653-150f5500-d631-11eb-98f6-b6480c3d65d2.gif)


<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/9db1c8c7
```

<!--
AMPLIFY_CLIPBOARD_ID;-134.365,279.9271,0#CLIP_ITEM#Node;AmplifyShaderEditor.Vector3Node;66;-564.4139,223.134;Inherit;False;Constant;_TargetWorldPosition3;Target World Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;67;-484.414,365.134;Inherit;False;Constant;_3;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;60;-331.414,228.134;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;60;0;66;0
WireConnection;60;3;67;0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldToObjectTransfNode;61;-198.414,228.134;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;61;0;60;0#CLIP_ITEM#Node;AmplifyShaderEditor.PosVertexDataNode;62;-23.09393,303.9741;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;68;11.46461,228.1998;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
WireConnection;68;0;61;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;169.2175,259.3607;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;63;0;68;0
WireConnection;63;1;62;0#CLIP_ITEM#Node;AmplifyShaderEditor.LerpOp;65;326.5382,235.7003;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
WireConnection;65;1;63;0
WireConnection;65;2;64;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;64;-114.7553,447.5732;Inherit;False;Constant;_T;T;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/124704646-6112a180-df2f-11eb-900c-4b0ec3db65af.png)

- 두 가지 방식 모두 동일한 결과를 내므로, 상황에 따라 선택하여 사용하면 된다.

<br>

## **World Position Offset (Keep Scale)**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/424f7336
```

<!--
AMPLIFY_CLIPBOARD_ID;-290.8,134.8727,0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldToObjectTransfNode;7;-224.3226,120.2708;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;7;0;5;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;37;-50.02765,120.8138;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
WireConnection;37;0;7;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;5;-357.3226,120.2708;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;5;0;4;0
WireConnection;5;3;6;0#CLIP_ITEM#Node;AmplifyShaderEditor.LerpOp;4;-523.3226,77.27082;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;4;2;3;0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldPosInputsNode;1;-726.3226,-40.72919;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3#CLIP_ITEM#Node;AmplifyShaderEditor.PosVertexDataNode;8;-51.33924,188.7595;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;134.8607,120.0595;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;9;0;37;0
WireConnection;9;1;8;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;137.1868,218.7019;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
WireConnection;35;0;8;0
WireConnection;35;1;3;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;36;273.9783,164.2428;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;36;0;9;0
WireConnection;36;1;35;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;6;-506.3226,195.2708;Inherit;False;Constant;_1;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;3;-825.3226,237.2708;Inherit;False;Constant;_T;T;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.Vector3Node;2;-771.3226,96.27081;Inherit;False;Constant;_TargetWorldPosition;TargetWorldPosition;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123471661-16408200-d631-11eb-9092-fb65e96208d9.gif)


<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/8594ca25
```

<!--
AMPLIFY_CLIPBOARD_ID;-527.1435,532.8887,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;12;-774.0573,629.5144;Inherit;False;Constant;_1;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.LerpOp;17;-147.8219,469.9626;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
WireConnection;17;1;38;0
WireConnection;17;2;10;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;10;-490.9871,664.2351;Inherit;False;Constant;_T;T;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;38;-313.9662,493.9655;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
WireConnection;38;0;14;0#CLIP_ITEM#Node;AmplifyShaderEditor.WorldToObjectTransfNode;14;-488.0573,492.5144;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;14;0;13;0#CLIP_ITEM#Node;AmplifyShaderEditor.DynamicAppendNode;13;-621.0573,492.5144;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;13;0;11;0
WireConnection;13;3;12;0#CLIP_ITEM#Node;AmplifyShaderEditor.Vector3Node;11;-854.0573,487.5144;Inherit;False;Constant;_TargetWorldPosition;Target World Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/124704685-6cfe6380-df2f-11eb-8c77-a8e28db7b39b.png)

- 두 가지 방식 모두 동일한 결과를 내므로, 상황에 따라 선택하여 사용하면 된다.

<br>

## **Vertex Displacement**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/740c2b24
```

<!--
AMPLIFY_CLIPBOARD_ID;-152.2598,80.13084,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;117;-574.3978,131.5649;Inherit;False;Constant;_Speed;Speed;0;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleTimeNode;124;-315.4452,135.0642;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
WireConnection;124;0;117;0#CLIP_ITEM#Node;AmplifyShaderEditor.PosVertexDataNode;120;-327.6926,-18.90763;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;125;-133.4787,44.08084;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
WireConnection;125;0;120;0
WireConnection;125;1;124;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;118;-311.9459,213.7999;Inherit;False;Constant;_NoiseScale;Noise Scale;0;0;Create;True;0;0;0;False;0;False;4;0;1;12;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NoiseGeneratorNode;122;-3.202899,38.53186;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;122;0;125;0
WireConnection;122;1;118;0#CLIP_ITEM#Node;AmplifyShaderEditor.NormalVertexDataNode;121;57.43592,-101.7426;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;119;-40.55597,258.9453;Inherit;False;Constant;_Strength;Strength;0;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;278.9445,19.84082;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;123;2;119;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123921004-864c6080-d9c1-11eb-97b0-4b08b1ac58c7.png)

![2021_0630_VertexDisplacement](https://user-images.githubusercontent.com/42164422/123919002-6c118300-d9bf-11eb-94d2-e5ced763c5c7.gif)

- `Noise Generator` 노드에 `UV` 입력이 있다고 해서 진짜로 `UV`를 넣으면 안되고, 대신 `Vertex Position`을 넣어야 한다.

<br>

# 2. Color
---

## **UV Mask**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/aa65fd76
```

<!--
AMPLIFY_CLIPBOARD_ID;-204.0754,371.0261,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;228;-290.8422,344.1594;Inherit;False;Constant;_T;T;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;230;-32.14207,349.3593;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;230;0;228;0
WireConnection;230;1;229;1#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;229;-289.2421,419.5595;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123144900-2cb2d600-d497-11eb-9b17-cfa9f1a730fc.gif)

- `Step`의 `A`, `B` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## **Smooth UV Mask**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/3bb6c48c
```

<!--
AMPLIFY_CLIPBOARD_ID;-4.472116,173.1487,0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;138;48.52223,155.118;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;138;0;135;0
WireConnection;138;3;137;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;135;-238.4254,149.8689;Inherit;False;Constant;_Dissolve;Dissolve;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;137;-94.95158,227.354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;137;0;136;0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;139;35.86574,39.09132;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;140;230.1373,245.5444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;140;0;138;0
WireConnection;140;1;136;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;141;351.1996,130.7231;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;141;0;139;1
WireConnection;141;1;138;0
WireConnection;141;2;140;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;136;-363.6527,264.3413;Inherit;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
-->

</details>

![2021_0813_UV_SmoothMask](https://user-images.githubusercontent.com/42164422/129232319-beec9c51-e420-416f-a5bb-d80e0131ef87.gif)

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/7cdbac84
```

<!--
AMPLIFY_CLIPBOARD_ID;6.799366,188.7005,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;135;-238.4254,149.8689;Inherit;False;Constant;_Dissolve;Dissolve;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;139;-160.4343,35.19131;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;142;-101.6481,221.3199;Inherit;False;Constant;_1;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;143;19.25206,248.62;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;143;0;142;0
WireConnection;143;1;136;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;141;388.8995,132.0231;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;141;0;139;1
WireConnection;141;1;144;0
WireConnection;141;2;145;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;129.7519,156.3198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;144;0;135;0
WireConnection;144;1;143;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;136;-237.5528,292.9412;Inherit;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;145;254.552,273.3197;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;145;0;144;0
WireConnection;145;1;136;0
-->

</details>

![2021_0627_UV_Mask_Smooth](https://user-images.githubusercontent.com/42164422/123523596-8b7a8880-d6ff-11eb-887b-1f57f2fe7463.gif)

- `Smoothstep`의 `Min`, `Max` 입력을 서로 바꿀 경우, 마스크 색상 반전

<br>

## **UV Mask Dissolve**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/29a6c1c6
```

<!--
AMPLIFY_CLIPBOARD_ID;87.24186,117.4499,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;163;-395.8287,243.6125;Inherit;False;Constant;_Smoothness2;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;158;-270.6014,129.1401;Inherit;False;Constant;_Dissolve2;Dissolve;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;159;-127.1276,206.6252;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;159;0;163;0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;157;16.34621,134.3892;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;157;0;158;0
WireConnection;157;3;159;0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;160;3.689724,18.36248;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;161;197.9613,224.8156;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;161;0;157;0
WireConnection;161;1;163;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;164;214.2519,35.4199;Inherit;False;Constant;_NoiseScale;Noise Scale;0;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;162;319.0236,109.9943;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;162;0;160;1
WireConnection;162;1;157;0
WireConnection;162;2;161;0#CLIP_ITEM#Node;AmplifyShaderEditor.NoiseGeneratorNode;165;357.2518,12.01987;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;165;0;160;0
WireConnection;165;1;164;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;166;557.4519,60.11985;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;166;0;165;0
WireConnection;166;1;162;0
-->

</details>


![2021_0813_UV_NoiseMask](https://user-images.githubusercontent.com/42164422/129232329-6f362082-cc47-47c5-ade2-def581b4a935.gif)

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/110696fe
```

<!--
AMPLIFY_CLIPBOARD_ID;-107.5136,232.3421,0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;139;-390.5343,115.7913;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;142;-331.748,301.9199;Inherit;False;Constant;_1;1;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;143;-210.8479,329.2199;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;143;0;142;0
WireConnection;143;1;136;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;141;158.7995,212.6231;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;141;0;139;1
WireConnection;141;1;144;0
WireConnection;141;2;145;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-100.3481,236.9198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;144;0;135;0
WireConnection;144;1;143;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;136;-467.6528,373.5412;Inherit;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;145;24.45199,353.9197;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;145;0;144;0
WireConnection;145;1;136;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;135;-468.5254,230.4689;Inherit;False;Constant;_Dissolve;Dissolve;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NoiseGeneratorNode;147;192.152,112.1199;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;147;0;139;0
WireConnection;147;1;146;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;146;19.25184,136.8199;Inherit;False;Constant;_NoiseScale;Noise Scale;0;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;148;392.352,152.4199;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;148;0;147;0
WireConnection;148;1;141;0
-->

</details>

![2021_0627_UV_Mask_Dissolve](https://user-images.githubusercontent.com/42164422/123523888-ced5f680-d701-11eb-9c29-648de55c8476.gif)

<br>

## **Noise Dissolve**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/077b71e9
```

<!--
AMPLIFY_CLIPBOARD_ID;-256.5131,210.9782,0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;193;-304.8141,291.8995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;193;0;191;0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;194;-161.3403,219.6635;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;194;0;192;0
WireConnection;194;3;193;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;196;20.27475,310.0899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;196;0;194;0
WireConnection;196;1;191;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;198;141.337,195.2686;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;198;0;199;0
WireConnection;198;1;194;0
WireConnection;198;2;196;0#CLIP_ITEM#Node;AmplifyShaderEditor.TexCoordVertexDataNode;195;-498.9806,93.74599;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;197;-318.0908,134.824;Inherit;False;Constant;_NoiseScale;Noise Scale;0;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NoiseGeneratorNode;199;-172.265,110.0109;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;199;0;195;0
WireConnection;199;1;197;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;191;-566.4504,328.8868;Inherit;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;192;-448.288,214.4144;Inherit;False;Constant;_Dissolve;Dissolve;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/123069599-e2f1cd80-d44d-11eb-950e-2088585127ae.gif)

<br>

## **UV Circle**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/4ff3eee1
```

<!--
AMPLIFY_CLIPBOARD_ID;434.3605,550.6047,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;243;259.9364,589.4088;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;245;261.9364,519.4088;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TextureCoordinatesNode;244;394.9364,519.4088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;244;0;245;0
WireConnection;244;1;243;0#CLIP_ITEM#Node;AmplifyShaderEditor.LengthOpNode;246;589.9364,519.4088;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
WireConnection;246;0;244;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;240;395.4812,635.5846;Inherit;False;Constant;_Radius;Radius;0;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;247;703.9364,520.4088;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;247;0;246;0
WireConnection;247;1;240;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/133939994-2add4a1e-2ee5-4ecf-b42f-e5797a5057b0.png)

<br>

## Smooth UV Circle

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/2baa9e89
```

<!--
AMPLIFY_CLIPBOARD_ID;486.1296,607.3057,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;240;395.4812,635.5846;Inherit;False;Constant;_Radius;Radius;0;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;249;394.9364,707.4088;Inherit;False;Constant;_Smoothness;Smoothness;0;0;Create;True;0;0;0;False;0;False;0.5;0;0.01;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;250;677.9364,673.4088;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;250;0;240;0
WireConnection;250;1;249;0#CLIP_ITEM#Node;AmplifyShaderEditor.LengthOpNode;246;686.9364,607.4088;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
WireConnection;246;0;244;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;243;261.9364,585.4088;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;245;263.9364,515.4088;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TextureCoordinatesNode;244;396.9364,515.4088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;244;0;245;0
WireConnection;244;1;243;0#CLIP_ITEM#Node;AmplifyShaderEditor.SmoothstepOpNode;248;810.9364,618.4088;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;248;0;246;0
WireConnection;248;1;240;0
WireConnection;248;2;250;0
-->

</details>

![image](https://user-images.githubusercontent.com/42164422/133940106-f0da97ce-8223-4fd4-b425-46f7f2dd5f3d.png)

<br>

## **Clock Mask**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/e7eae5d7
```

<!--
AMPLIFY_CLIPBOARD_ID;575.8041,591.0611,0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;243;261.9364,585.4088;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;245;263.9364,515.4088;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TextureCoordinatesNode;244;396.9364,515.4088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;244;0;245;0
WireConnection;244;1;243;0#CLIP_ITEM#Node;AmplifyShaderEditor.BreakToComponentsNode;252;595.9364,515.4088;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
WireConnection;252;0;244;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;256;704.9364,568.4088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;256;0;252;1#CLIP_ITEM#Node;AmplifyShaderEditor.ATan2OpNode;257;819.9364,516.4088;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;257;0;252;0
WireConnection;257;1;256;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;240;503.4812,635.5846;Inherit;False;Constant;_T;T;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;254;762.9364,640.4088;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;254;0;240;0
WireConnection;254;3;253;0
WireConnection;254;4;255;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;255;625.9364,736.4088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;255;0;253;0#CLIP_ITEM#Node;AmplifyShaderEditor.PiNode;253;456.9364,711.4088;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;258;940.9364,561.4088;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;258;0;257;0
WireConnection;258;1;254;0
-->

</details>

![2021_0813_UV_ClockMask](https://user-images.githubusercontent.com/42164422/129238475-58d210c2-debb-44a0-9c03-bf6475ee23cd.gif)

<br>

## **Radar**

<details>

<summary markdown="span"> 
Copy & Paste
</summary>

{% include codeHeader.html %}
```
http://paste.amplify.pt/view/raw/ac8d6699
```

<!--
AMPLIFY_CLIPBOARD_ID;216.2561,817.9921,0#CLIP_ITEM#Node;AmplifyShaderEditor.TFHCRemapNode;254;308.6665,932.6782;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;254;0;240;0
WireConnection;254;3;253;0
WireConnection;254;4;255;0#CLIP_ITEM#Node;AmplifyShaderEditor.PiNode;253;2.666149,1003.678;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;240;49.21101,927.854;Inherit;False;Constant;_Start;Start;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;255;171.6664,1028.678;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;255;0;253;0#CLIP_ITEM#Node;AmplifyShaderEditor.BreakToComponentsNode;252;257.2921,699.3523;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
WireConnection;252;0;264;0#CLIP_ITEM#Node;AmplifyShaderEditor.RotatorNode;264;87.42511,699.8796;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
WireConnection;264;0;244;0
WireConnection;264;2;263;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;243;-249.6083,770.6523;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;245;-247.6083,700.6522;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.TextureCoordinatesNode;244;-114.6078,700.6522;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;244;0;245;0
WireConnection;244;1;243;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;260;-248.4081,847.1526;Inherit;False;Constant;_Rotation;Rotation;0;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RadiansOpNode;262;7.655346,851.7438;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;262;0;260;0#CLIP_ITEM#Node;AmplifyShaderEditor.NegateNode;263;123.5919,851.1526;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;263;0;262;0#CLIP_ITEM#Node;AmplifyShaderEditor.ATan2OpNode;257;369.4925,699.0522;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;257;0;252;0
WireConnection;257;1;252;1#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;266;635.2999,937.205;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;266;0;257;0
WireConnection;266;1;267;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleSubtractOpNode;269;793.463,811.2222;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;269;0;266;0
WireConnection;269;1;258;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;258;630.8924,699.8527;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;258;0;257;0
WireConnection;258;1;254;0#CLIP_ITEM#Node;AmplifyShaderEditor.LengthOpNode;268;127.8436,558.686;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
WireConnection;268;0;244;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;259;96.06866,1105.008;Inherit;False;Constant;_Angle;Angle;0;0;Create;True;0;0;0;False;0;False;45;0;0;360;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.RadiansOpNode;261;355.069,1110.008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;261;0;259;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleAddOpNode;267;498.7996,1028.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;267;0;254;0
WireConnection;267;1;261;0#CLIP_ITEM#Node;AmplifyShaderEditor.RangedFloatNode;271;121.3141,627.5998;Inherit;False;Constant;_1_;1_;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0#CLIP_ITEM#Node;AmplifyShaderEditor.StepOpNode;270;245.6346,608.243;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;270;0;268;0
WireConnection;270;1;271;0#CLIP_ITEM#Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;952.0715,614.7465;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;272;0;270;0
WireConnection;272;1;269;0
-->

</details>

![2021_0813_UV_Radar](https://user-images.githubusercontent.com/42164422/129238486-6b25a0db-8d99-4e3c-bbca-a3c77f6acfdf.gif)

<br>

## **Checkerboard**

![2021_0626_CheckerBoard](https://user-images.githubusercontent.com/42164422/123473821-0fffd500-d634-11eb-988c-3ed1c20f4130.gif)

<br>

## **Grid**

![image](https://user-images.githubusercontent.com/42164422/133794988-210be4f1-7757-4772-b372-5f9af969d4af.png)

<br>

## **Distortion**

![image](https://user-images.githubusercontent.com/42164422/123935349-1a70f480-d9cf-11eb-8e17-026c610e2009.png)

![2021_0630_Distortion](https://user-images.githubusercontent.com/42164422/123935354-1c3ab800-d9cf-11eb-8caa-dfdde3e4ee88.gif)

- 마스터 노드의 속성에서 `Blend Mode`를 `Transparent`로 지정한다.

- 마찬가지로 `General - Light Model`을 `Unlit`으로 변경한다.

<br>

## **World Position-Based Color Variation**

![image](https://user-images.githubusercontent.com/42164422/123928240-b1867e00-d9c8-11eb-8c35-fff6ee009084.png)

![image](https://user-images.githubusercontent.com/42164422/123928341-c9f69880-d9c8-11eb-936f-bddbe1abf096.png)

- 게임 오브젝트의 현재 월드 위치를 기반으로 색상을 지정한다.

- `Distribution`, `Seed` 프로퍼티를 이용해 다양한 연출이 가능하다.

<br>

## **World Position-Based Color Variation (From-To)**

![image](https://user-images.githubusercontent.com/42164422/123930182-75541d00-d9ca-11eb-9610-8830222c9000.png)

![image](https://user-images.githubusercontent.com/42164422/123930087-5fdef300-d9ca-11eb-9805-c92d664ebe57.png)

- 지정한 두 색상 사이에서만 월드 위치 기반으로 색상이 분포하도록 한다.

<br>

## **Depth Intersection**

![2021_0914_Depth Inter](https://user-images.githubusercontent.com/42164422/133133316-39f93228-9c47-4637-bccb-c0da755609f1.gif)

- 반투명 물체가 다른 불투명 물체와 접촉한 지점을 강조하여 표현한다.

- 대표적으로 쉴드 이펙트, 물 쉐이더 등에 사용된다.

- `Screen Position` 노드의 `Type`은 `Screen`으로 지정해야 한다.

- 반드시 `Blend Mode`를 `Transparent`로 설정해야 한다.

<details>
<summary markdown="span"> 
원리?
</summary>

![image](https://user-images.githubusercontent.com/42164422/133135813-8a4fbe0f-7943-4146-9c99-56bd24ae6edd.png)

`ScreenPosition.w`는 카메라로부터 해당 메시 표면까지의 거리를 나타낸다.

`ScreenDepth`는 카메라로부터 가장 가까운 '불투명' 물체 표면까지의 거리를 나타낸다.

따라서 같은 픽셀에서 반투명(Transparent), 불투명(Opaque) 물체가 겹쳐 있고,

반투명 물체의 표면이 카메라에 더 가까이 있는 경우

`ScreenDepth - ScreenPosition.w`의 값은 0보다 커진다.

<br>

이를 반대로 뒤집으면 `ScreenPosition.w - ScreenDepth`의 값은 0보다 작아지는데,

여기에 작은 양수 값 `T`(0 ~ 1 정도)를 더하면

`ScreenPosition.w - ScreenDepth`의 값이 얼마 차이 안나는 지점(-1 ~ 0 정도)에서만

`ScreenPosition.w - ScreenDepth + T`의 값이 0보다 커지게 된다.

`ScreenPosition.w - ScreenDepth`의 값이 얼마 차이 안나는 지점이라는 것은

접촉면에 가까운 지점을 의미한다. (0 : 완전히 맞닿는 지점)

<br>

예를 들어 `T`가 1일 때, 반투명과 불투명 물체가 완전히 맞닿는 부분은

`ScreenPosition.w - ScreenDepth + T` 값이 1이 되고,

완전히 맞닿는 부분에서 멀어질수록 위의 값은 점점 작아진다.

그리고 여기에 최종적으로 `Saturate`를 통해 음수를 0으로 바꿔버리면

접촉면을 강조 표현하는 쉐이더가 완성된다.

</details>

<br>

## **Texture Sheet Animation**

- 예제 텍스쳐 :

![TextureSheet_Debug_4x3](https://user-images.githubusercontent.com/42164422/126682133-a5d6ed34-9e5b-4cfc-90dd-a524fdc459be.png)

<br>

### **[1] 좌측 하단부터 시작**

![2021_0723_TextureSheet_01](https://user-images.githubusercontent.com/42164422/126683103-6c37c209-874b-409a-ace1-8a938eaff8f4.gif)

![2021_0723_TextureSheet_02](https://user-images.githubusercontent.com/42164422/126683106-ad6a15e7-45dd-4d1c-9bdf-3a0763b67394.gif)

- 좌측 하단 텍스쳐 영역을 `(0, 0)`, 우측 상단 영역을 `(3, 2)` 좌표로 가정한다.

- 인덱스의 진행에 따라 `(0, 0)`, `(1, 0)`, `(2, 0)`, `(3, 0)`, `(0, 1)`, `(1, 1)`, ... , `(3, 2)` 순서대로 해당되는 텍스쳐 영역을 보여준다.

- 첫 번째 사진처럼 인덱스를 직접 지정해줄 수도 있고, 두 번째 사진처럼 시간의 흐름에 따라 자동 재생되도록 해줄 수도 있다.

<br>

### **[2] 좌측 상단부터 시작**

![2021_0723_TextureSheet_03](https://user-images.githubusercontent.com/42164422/126684561-be4c5b79-2110-4ab0-8ac1-0f7de23208ec.gif)

![2021_0723_TextureSheet_04](https://user-images.githubusercontent.com/42164422/126684564-b6f168a4-1829-4e23-be5a-89ae8157e861.gif)

- 인덱스의 진행에 따라 좌상단부터 우하단 방향으로 이어진다.

- 파티클 시스템의 `Texture Sheet Animation`과 같은 방식

- 텍스쳐 시트 형태로 만들어지는 파티클 텍스쳐의 경우 이와 같이 좌상단부터 우하단 방향으로 재생된다.

- 예제 텍스쳐의 경우, 인덱스의 진행에 따라 `8` -> `9` -> `10` -> `11` -> `4` -> `5` -> `6` -> `7` -> `0` -> `1` -> `2` -> `3` 순서대로 이어진다.

<br>

- 그런데 `Amplify`, `Shadergraph`에 모두 간편하게 하나의 노드로 이미 구현되어 있으므로, 추가적인 응용이 필요한 것이 아니라면 `Flipbook` 노드를 사용하면 된다.

![2021_0722_TextureSheetAnimation_Flipbook](https://user-images.githubusercontent.com/42164422/126530621-a328afee-26b6-4a76-97a8-1ba12d61e081.gif)

<br>

# 3. Lighting
---

## **Lambert**

![image](https://user-images.githubusercontent.com/42164422/123553686-b32d2780-d7b7-11eb-883f-97094b9fc710.png)

- 마스터 노드 속성 - `General` - `Light Model` - `Custom Lighting` 선택

<br>

<!--

## **Half Lambert**

## **Blinn-Phong Specular**

<br>

-->

## **Diffuse Warping**

![image](https://user-images.githubusercontent.com/42164422/123554382-a78f3000-d7ba-11eb-8fd4-feb09a3fb9d3.png)

- [Ramp Texture](https://user-images.githubusercontent.com/42164422/123857489-50759080-d95d-11eb-8d1d-24215df18856.png)를 이용한 커스텀 라이팅 기법

- **Ramp Texture**는 반드시 `Wrap Mode : Clamp`, `Filter Mode : Point`로 설정해야 한다.

- 메인 텍스쳐 색상은 `Albedo`나 `Emission`이 아니라 **Custom Lighting** 입력 앞에 있는 `Multiply` 노드에 곱해주어야 한다.

<br>

![2021_0628_DiffuseWarping](https://user-images.githubusercontent.com/42164422/123554613-c80bba00-d7bb-11eb-8e4d-3bcc19cedac4.gif)

- `Scale And Offset` 노드를 통해 각 색상의 영역을 조절해줄 수 있다.

<br>

- 사용된 **Ramp Texture** :

![](https://user-images.githubusercontent.com/42164422/123857489-50759080-d95d-11eb-8d1d-24215df18856.png)

<br>



<!--

## **Toon(Cel) Shading**

<details>
<summary markdown="span"> 
TODO
</summary>

https://www.youtube.com/watch?v=dyiLJ1PFhM0
https://www.youtube.com/watch?v=MawzivWLCoo

</details>


<br>

-->



# 4. Graph
---

## **Basic Particle(Additive) Shader**

- [Rito_BasicParticle.zip](https://github.com/rito15/Images/files/7139411/Rito_BasicParticle.zip)

![image](https://user-images.githubusercontent.com/42164422/132753357-8e6285cb-5975-4646-9664-41b5be105fa8.png)

### **General**
  - Light Model : `Unlit`
  - Cull Mode : `Off`
  - Cast Shadows : `Off`
  - Receive Shadows : `Off`

### **Blend Mode**
  - Render Type : `Transparent`
  - Render Queue : `Transparent`
  - 우측 상단 : `Custom`
  - Blend RGB : `Particle Additive` <br>
    (Advanced options are.. 경고 문구가 뜨면 우측 상단을 `Custom`으로 바꾸고 설정한다.)

### **Depth**
  - ZWrite Mode : `Off`

### **Rendering Options**
  - 모두 체크 해제

<br>

## **Soft Particle(Additive) Shader**

- [Rito_SoftParticle.zip](https://github.com/rito15/Images/files/7139412/Rito_SoftParticle.zip)

- 불투명한 물체에 닿는 지점이 부드럽게 표현된다.

- **Screen Position** 노드의 **Type**을 `Screen`으로 설정해야 한다.

![image](https://user-images.githubusercontent.com/42164422/132753216-63f8274c-9197-4f98-be8d-609c2a67d2d6.png)

<br>

- **비교** - **상** : 기본 파티클 쉐이더 / **하** : Soft Particle 쉐이더

![image](https://user-images.githubusercontent.com/42164422/132750023-0b231965-6aa4-4be6-ad6a-29295fce5daf.png)

<br>

<details>
<summary markdown="span"> 
추가 : Soft Particle이 씬 뷰에서 제대로 보이지 않는 경우 해결하기
</summary>

- [Rito_SoftParticle2.zip](https://github.com/rito15/Images/files/7139541/Rito_SoftParticle2.zip)

게임 뷰에서는 제대로 보이지만, 씬 뷰에서는 다른 불투명 오브젝트에 무조건 가려지는 경우가 있다.

그럴 때는 다음과 같이 `Static Switch` 노드를 추가하고,

![image](https://user-images.githubusercontent.com/42164422/132756558-1ddaf5e1-6f79-4bda-bac1-dfe0826147c0.png)

`Static Switch` 노드는 아래처럼 설정하면 된다.

![image](https://user-images.githubusercontent.com/42164422/132756323-ae1667ce-3d56-4eec-91b7-7e035a59843a.png)

</details>

