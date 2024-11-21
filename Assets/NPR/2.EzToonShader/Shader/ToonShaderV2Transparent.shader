Shader "GSST/ToonTransparentV2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        //从贴图采样，需要另外的贴图、颜色
        _GradientMap ("Gradient Map", 2D) = "white" {}

        
        //_ShadowThreshold ("Shadow Threshold", Range(-1,1)) = 0
        //_ShadowColor ("Shadow Color", Color) = (0.5,0.5,0.5,1)
        
        //第一层阴影
        _ShadowColor1stTex ("1st Shadow Color Tex", 2D) = "white" {}
		_ShadowColor1st ("1st Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        //第二层阴影
		_ShadowColor2ndTex ("2nd Shadow Color Tex", 2D) = "white" {}
		_ShadowColor2nd ("2nd Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        
        
        _SpecularPower ("Specular Power", Float) = 20
        [HDR] _SpecularColor ("Specular Color", Color) = (0,0,0,1)
        //_SpecularThreshold ("Specular Threshold", Range(0,1)) = 0.5
        
        _OutlineWidth ("Outline Width", Range(0.0, 3.0)) = 1.0
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        
        
    }
    SubShader
    {
    Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
     
    Cull Back
    ZWrite Off
    //Source color * SourceAlpha * Dest Color * (1-SourceAlpha)
    Blend SrcAlpha OneMinusSrcAlpha
    
    Pass
    {
        ZWrite On
        ColorMask 0
        //深度值写到深度缓冲区中
    }
    
    
    

    Pass
        
    {
            Tags{"LightMode"="ForwardBase"}
            
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            
            #define  IS_TRANSPARENT
            #include "ToonShadingCommn.cginc"

            
            ENDCG
        }
        
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #define  IS_TRANSPARENT
            #include "ToonShadingOutlineCommn.cginc"
            
            
            ENDCG
        }


        
    }
}
 