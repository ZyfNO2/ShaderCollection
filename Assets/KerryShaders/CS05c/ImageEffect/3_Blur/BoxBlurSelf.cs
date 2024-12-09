using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class BoxBlurSelf : MonoBehaviour {
    public Material material;
    [Range(0, 10)]
    public int _Iteration = 4;
    [Range(0, 15)]
    public float _BlurRadius = 5.0f;
    [Range(1, 10)]
    public float _DownSample = 2.0f;

    void Start () {
        if (material == null || SystemInfo.supportsImageEffects == false
            || material.shader == null || material.shader.isSupported == false)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //_DownSample降低尺寸，使得计算量下降
        int width = (int)(source.width / _DownSample);
        int height = (int)(source.height / _DownSample);
        //申请两张画布
        RenderTexture RT1 = RenderTexture.GetTemporary(width,height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        
        //先source输出到RT1
        Graphics.Blit(source, RT1);
        //传入Material参数 Vector4 从外部传入_MainTex_TexelSize  在脚本段测算偏移量
        material.SetVector("_BlurOffset", new Vector4(_BlurRadius / source.width, _BlurRadius / source.height, 0,0));
        //多次迭代
        for (int i = 0; i < _Iteration; i++)
        {
            //将RT1的内容输出到RT2
            Graphics.Blit(RT1, RT2, material, 0);
            Graphics.Blit(RT2, RT1, material, 0);
        }

        Graphics.Blit(RT1, destination);

        //release释放
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
