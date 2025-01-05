Shader "Unlit/Toon"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" {}
        _SSSMap ("SSSMap", 2D) = "balck" {}
        _ILMap ("ILMap", 2D) = "gray" {}
        _ToonThreshold ("ToonThreshold", Range(0, 1)) = 0.5
        _ToonHardness ("ToonHardness", Float) = 20
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
           
            #pragma multi_compile_forwardbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float3 normal: Normal;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 pos_world : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float4 vertex_color : TEXCOORD3;
            };

            sampler2D _BaseMap;
            sampler2D _SSSMap;
            sampler2D _ILMap;
            float _ToonThreshold;
            float _ToonHardness;
            
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.uv = float4(v.texcoord0,v.texcoord1);
                o.vertex_color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 uv1 = i.uv.xy;
                half2 uv2 = i.uv.zw;

                float3 normalDir = normalize(i.normal_world);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                // sample the texture
                half4  base_map = tex2D(_BaseMap, uv1);
                half3 base_color = base_map.rgb;//亮部颜色
                half4  sss_map = tex2D(_SSSMap, uv1);
                half3 sss_color = sss_map.rgb;//暗部颜色
                half4  ilm_map = tex2D(_ILMap, uv1);
                half3 ilm_color = ilm_map.rgb;
                float spec_intensity = ilm_map.r;//高光强度
                float diffuse_control = ilm_map.g * 2 - 1;//光照偏移
                float spec_size = ilm_map.b;//高光形状
                float inner_line = ilm_map.a;//内描线

                //Vertex Color
                float ao = i.vertex_color.r;
                
                //diffuse
                half NdotL = dot(normalDir, lightDir);
                half half_lambert = (NdotL + 1) * 0.5;
                half lambert_term = half_lambert * ao + diffuse_control;
                half toon_diffuse = saturate((lambert_term - _ToonThreshold) * _ToonHardness);
                half3 final_diffuse =lerp(sss_color,base_color,toon_diffuse);
    
                //spec

                
                return float4(final_diffuse,1);
            }
            ENDCG
        }
    }
}
