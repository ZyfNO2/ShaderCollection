 Shader "Kerry/Unlit/Matcap_Code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Matcap ("Matcap", 2D) = "white" {}
        _RampTex ("RampTex", 2D) = "white" {}
        _MatcapAdd ("MatcapAdd", 2D) = "white" {}
        _MatcapIntensity ("_MatcapIntensity", Float) = 1.0
        _MatcapAddIntensity ("_MatcapAddIntensity", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
   
                float4 vertex : SV_POSITION;

                float3 normal_world : TEXCOORD1;

                float3 pos_world : TEXCOORD2;
                
            };

            sampler2D _MainTex;
            sampler2D _Matcap;
            sampler2D _RampTex;
            sampler2D _MatcapAdd;
            float4 _MainTex_ST;
            float _MatcapIntensity;
            float _MatcapAddIntensity;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //法线转移到世界空间
                float3 normal_world = UnityObjectToWorldNormal(v.normal);
                o.normal_world = normal_world;

                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal_worlad = normalize(i.normal_world);

                //mapcap base
                // 将世界空间中的法线转换到视图空间，并进行归一化处理
                // UNITY_MATRIX_V: 视图矩阵，用于将世界坐标转换为视图坐标
                half3 normal_viewspace = normalize(mul(normal_worlad, (float3x3)UNITY_MATRIX_V));
                //float2 uv_matcap = normalize(normal_viewspace.xy)*0.5 + float2(0.5,0.5);
                half2 uv_matcap = (normal_viewspace.xy + float2(1.0,1.0)) * 0.5;
                half4 maptcap_color = tex2D(_Matcap, uv_matcap) * _MatcapIntensity;
                
                half4 diffuse_color = tex2D(_MainTex, i.uv);

                //ramp
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half NdotV = saturate(dot(normal_worlad, view_dir));
                half fresnel = 1 - NdotV;
                half uv_ramp = half2(fresnel,0.5);
                half4 ramp_oolor = tex2D(_RampTex, uv_ramp);

                //add matcap
                half4 maptcap_add_color = tex2D(_MatcapAdd, uv_matcap) * _MatcapAddIntensity;
                
                half4 combined_color =  diffuse_color * maptcap_color  * ramp_oolor + maptcap_add_color; 
                return combined_color;
            }  
            ENDCG
        }
    }
}
