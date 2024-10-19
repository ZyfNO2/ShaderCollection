Shader "Unlit/Match"
{
    Properties
    {
        _MainTex("MainTex",2D) = "black"{}
        _Color("Color",Color) = (0.5,0.5,0.51,0.5)
    }
    SubShader
    {
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;//tilling or sth


            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;//第一套uv max = 3
                //float3 normal : TEXCOORD1;
                //float4 color : COLOR;
                //float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;//储存器 插值器 max = 15
                //float3 normal : TEXCOORD1;
            };
            
            v2f vert(appdata v)//顶点着色器
            {
                v2f o;// Ins
                // float4 pos_world = mul(unity_ObjectToWorld,v.vertex);
                // //通过mul 模型空间->世界空间
                // float4 pos_view = mul(UNITY_MATRIX_V,pos_world);
                // //通过mul 世界空间->相机空间
                // float4 pos_clip = mul(UNITY_MATRIX_P,pos_view);
                //通过mul 相机空间->裁剪空间
                //o.pos = pos_clip;

                o.pos = mul(unity_MatrixMVP,v.vertex);
                
                o.uv = v.uv * _MainTex_ST.xy;
                return o;
                
            }
            

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex,i.uv);
                return col;
            }

            
            
            ENDCG
        }
    }
}
