Shader "Unity Shaders Book/Chapter 5/Self5-2"
{
    Properties
    {
        
    }
    SubShader
    {
        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert//顶点着色器
            #pragma fragment frag//片元着色器



         ///v:POSITION -> Position模型顶点填充 
         ///SV_POSITION -> 顶点着色器的输出为裁剪空间中的顶点坐标
         ///UnityObjectToClipPos(v); -> 顶点坐标到裁剪空间
        float4 vert(float4 v:POSITION):SV_POSITION
        {
            return UnityObjectToClipPos(v);
        }


            ///此处顶点着色器于片元着色器相互独立，不会输入到片元
            ///
            ///输出fixed4(0.1,1,1,1);这个颜色
        fixed4 frag():SV_Target
        {
            return fixed4(0.1,1,1,1);
        }



            ENDCG
        }
    }
    FallBack "Diffuse"
}
