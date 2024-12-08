using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class VisualizeNormals : MonoBehaviour
{
    [Header("Normal Visualization Settings")]
    public float normalLength = 1.0f;       // 法线的长度
    public Color normalColor = Color.green; // 法线的颜色

    private Mesh mesh;
    private LineRenderer lineRenderer;

    void Start()
    {
        // 获取MeshFilter组件
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (meshFilter == null)
        {
            Debug.LogError("VisualizeNormals脚本需要一个带有MeshFilter组件的GameObject");
            return;
        }

        mesh = meshFilter.mesh;
        if (mesh == null)
        {
            Debug.LogError("MeshFilter没有关联的Mesh");
            return;
        }

        // 创建LineRenderer组件
        lineRenderer = gameObject.AddComponent<LineRenderer>();
        lineRenderer.material = new Material(Shader.Find("Sprites/Default"));
        lineRenderer.material.color = normalColor;
        lineRenderer.startWidth = 0.01f;
        lineRenderer.endWidth = 0.01f;
        lineRenderer.positionCount = mesh.vertices.Length * 2;
        lineRenderer.useWorldSpace = false;

        // 绘制法线
        for (int i = 0; i < mesh.vertices.Length; i++)
        {
            Vector3 vertex = mesh.vertices[i];
            Vector3 normal = mesh.normals[i].normalized;

            // 起点：顶点位置
            lineRenderer.SetPosition(i * 2, vertex);
            // 终点：顶点位置 + 法线 * 法线长度
            lineRenderer.SetPosition(i * 2 + 1, vertex + normal * normalLength);
        }
    }

    // 可选：在Inspector中修改法线长度或颜色后实时更新
    void Update()
    {
        // 检查是否需要更新法线
        bool updateNeeded = false;

        if (lineRenderer != null && mesh != null)
        {
            if (lineRenderer.material.color != normalColor)
            {
                lineRenderer.material.color = normalColor;
                updateNeeded = true;
            }

            if (lineRenderer.startWidth != 0.01f || lineRenderer.endWidth != 0.01f)
            {
                lineRenderer.startWidth = 0.01f;
                lineRenderer.endWidth = 0.01f;
                updateNeeded = true;
            }

            if (updateNeeded)
            {
                for (int i = 0; i < mesh.vertices.Length; i++)
                {
                    Vector3 vertex = mesh.vertices[i];
                    Vector3 normal = mesh.normals[i].normalized;

                    lineRenderer.SetPosition(i * 2, vertex);
                    lineRenderer.SetPosition(i * 2 + 1, vertex + normal * normalLength);
                }
            }
        }
    }
}