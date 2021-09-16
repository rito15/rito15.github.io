---
title: 유니티 - Obj Exporter(메시를 OBJ 파일로 저장하기)
author: Rito15
date: 2021-05-17 05:17:00 +09:00
categories: [Unity, Unity Memo]
tags: [unity, csharp]
math: true
mermaid: true
---

# Source Code
---

<details>
<summary markdown="span"> 
ObjExporter.cs
</summary>

```cs
#if UNITY_EDITOR

using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace Rito
{
    // http://wiki.unity3d.com/index.php?title=ObjExporter
    public static class ObjExporter
    {
        public static string MeshToString(Mesh mesh, MeshRenderer mr, string name)
        {
            Material[] mats = mr.sharedMaterials;
            StringBuilder sb = new StringBuilder();

            sb.Append($"# UnityEngine - Rito Mesh Editor\n");
            sb.Append($"# File Created : {DateTime.Now}\n");
            sb.Append("\n");

            sb.Append($"# {mesh.vertices.Length} Vertices\n");
            sb.Append($"# {mesh.normals.Length} Vertex Normals\n");
            sb.Append($"# {mesh.uv.Length} Texture Coordinates\n");
            sb.Append($"# {mesh.subMeshCount} Submeshes\n");
            sb.Append($"# {mesh.triangles.Length} Polygons\n");
            sb.Append("\n");

            // 1. Name
            sb.Append("g ").Append(name).Append("\n\n");

            // 2. Vertices
            foreach (Vector3 v in mesh.vertices)
            {
                // 유니티는 좌표계가 달라서 x 반전시켜야 함
                sb.Append(string.Format("v {0:F4} {1:F4} {2:F4}\n", -v.x, v.y, v.z));
            }
            sb.Append("\n");

            // 3. Normals
            foreach (Vector3 v in mesh.normals)
            {
                // x 반전
                sb.Append(string.Format("vn {0:F4} {1:F4} {2:F4}\n", -v.x, v.y, v.z));
            }
            sb.Append("\n");

            // 4. UVs
            foreach (Vector3 v in mesh.uv)
            {
                sb.Append(string.Format("vt {0:F4} {1:F4}\n", v.x, v.y));
            }

            // 5. Triangles
            for (int material = 0; material < mesh.subMeshCount; material++)
            {
                sb.Append("\n");
                sb.Append("usemtl ").Append(mats[material].name).Append("\n");
                sb.Append("usemap ").Append(mats[material].name).Append("\n");

                int[] triangles = mesh.GetTriangles(material);
                for (int i = 0; i < triangles.Length; i += 3)
                {
                    // x 반전
                    sb.Append(string.Format("f {1}/{1}/{1} {0}/{0}/{0} {2}/{2}/{2}\n",
                        triangles[i] + 1, triangles[i + 1] + 1, triangles[i + 2] + 1));
                }
            }
            return sb.ToString();
        }

        public static void SaveMeshToFile(Mesh mesh, MeshRenderer mr, string meshName, string path)
        {
            using (StreamWriter sw = new StreamWriter(path))
            {
                sw.Write(MeshToString(mesh, mr, meshName));
            }
        }
    }
}

#endif
```

</details>

<br>


<details>
<summary markdown="span"> 
MeshToObj.cs (테스트용 스크립트)
</summary>

```cs
#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

// 날짜 : 2021-05-17 PM 8:57:35
// 작성자 : Rito

namespace Rito.Tests.ExportObj
{
    public class MeshToObj : MonoBehaviour
    {
        [SerializeField]
        private string meshName;
        private MeshFilter mf;
        private MeshRenderer mr;

        [CustomEditor(typeof(MeshToObj))]
        private class Custom : UnityEditor.Editor
        {
            private MeshToObj m;

            private void OnEnable()
            {
                m = target as MeshToObj;
                if(m.mf == null) m.TryGetComponent(out m.mf);
                if(m.mr == null) m.TryGetComponent(out m.mr);
            }

            public override void OnInspectorGUI()
            {
                if (m.mf == null)
                {
                    EditorGUILayout.HelpBox("Mesh Filter Does not Exist", MessageType.Error);
                    return;
                }
                if (m.mr == null)
                {
                    EditorGUILayout.HelpBox("Mesh Renderer Does not Exist", MessageType.Error);
                    return;
                }

                Undo.RecordObject(m, "Change Mesh Name");
                m.meshName = EditorGUILayout.TextField("Mesh Name", m.meshName);

                if (!m.meshName.IsNotEmpty())
                {
                    EditorGUILayout.HelpBox("Please Input Mesh Name", MessageType.Warning);
                    return;
                }

                if (GUILayout.Button("Export To OBJ"))
                {
                    string path = EditorUtility.SaveFilePanelInProject("Save To OBJ", m.meshName, "obj", "");
                    
                    if (path.IsNotEmpty())
                    {
                        ObjExporter.SaveMeshToFile(m.mf.sharedMesh, m.mr, m.meshName, path);
                        AssetDatabase.Refresh();
                    }
                }
            }
        }
    }

    static class Extensions
    {
        public static bool IsNotEmpty(this string str)
            => !string.IsNullOrWhiteSpace(str);
    }
}

#endif
```

</details>

<br>


# References
---
- <http://wiki.unity3d.com/index.php?title=ObjExporter>