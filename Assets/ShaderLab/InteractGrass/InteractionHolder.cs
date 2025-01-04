using UnityEngine;

// 允许脚本在编辑模式下运行
[ExecuteInEditMode]
public class InteractionHolder : MonoBehaviour
{
    [SerializeField]
    private GameObject[] objects; // 存储需要与 Shader 交互的对象数组

    private Vector4[] positions = new Vector4[100]; // 用于存储对象的位置，最大支持 100 个对象

    // 每帧更新交互点的位置并传递到 Shader
    void Update()
    {
        // 遍历所有对象，获取它们的世界坐标
        for (int i = 0; i < objects.Length; i++)
        {
            positions[i] = objects[i].transform.position; // 获取每个对象的世界位置
        }

        // 将对象数量传递到 Shader 的全局变量 "_PositionArray"
        Shader.SetGlobalFloat("_PositionArray", objects.Length); 

        // 将对象的位置数组传递到 Shader 的全局变量 "_Positions"
        Shader.SetGlobalVectorArray("_Positions", positions);
    }
}
