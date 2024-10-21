Shader "Unity Shaders Book/Chapter 5/5-2"
{
    Properties
    {
       
    }
    SubShader
    {
       Pass
       {
           CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

        float4 vert(float4 v:POSITION):SV_POSITION
        {
            return UnityObjectToClipPos(v);
        }

        fixed4 frag():SV_Target
        {
            return fixed4(0.5,1,1,1);
        }
            

           ENDCG
            
       }
    }
    FallBack "Diffuse"
}
