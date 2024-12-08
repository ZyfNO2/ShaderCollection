Shader "CS01_03/Scan_Code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimMin("RimMin",Range(-1,1)) = 0
        _RimMax("RimMax",Range(0,2)) = 1.0
        _InnerColor("InnerColor",Color) = (0,0,0,0)
        _RimColor("RimColor",Color) = (1,1,1,1)
        _RimIntensity("RimIntensity",Float) = 1.0
        _FLowTilling("FLowTilling",Vector) = (1,1,0,0)
        _FLowSpeed("FLowSpeed",Vector) = (1,1,0,0)
        _FlowTex("FlowTex", 2D) = "white" {}
        _FlowIntensity("FlowIntensity",Float) = 0.5
        _InnerAlpha("Inner Alpha",Range(0.0,1.0)) = 0.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite off
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 pos_world : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float3 pivot_world : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RimMin;
            float _RimMax;
            float4 _InnerColor;
            float4 _RimColor;
            float  _RimIntensity;
            float4 _FLowTilling;
            float4 _FLowSpeed;
            sampler2D _FlowTex;
            float _FlowIntensity;
            float _InnerAlpha;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normal_world = mul(float4(v.normal,0.0),unity_WorldToObject).xyz;
                //unity_ObjectToWorld 向量补0
                float3 pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_world = normalize(normal_world);
                o.pos_world = pos_world;
                o.uv = v.texcoord;
                o.pivot_world = mul(unity_ObjectToWorld,float4(0,0,0,1));
                //unity_ObjectToWorld  点补1
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            { 
                half3 normal_world = normalize(i.normal_world);//片元阶段记得法线nor
                half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half NdotV = saturate(dot(normal_world,view_world));
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin,_RimMax,fresnel);
                half4 emiss = tex2D(_MainTex, i.uv).r;
                emiss = pow(emiss,5.0);
                half final_fresnel = saturate(fresnel + emiss) ;

                half3 final_rim_color = lerp(_InnerColor.xyz,_RimColor.xyz * _RimIntensity,final_fresnel) ;
                half final_rim_alpha = final_fresnel;
                //流光
                half uv_flow = (i.pos_world.xy - i.pivot_world.xy) * _FLowTilling;
                uv_flow = uv_flow + _Time.y * _FLowSpeed.xy;
                float4 flow_rgba = tex2D(_FlowTex,uv_flow) * _FlowIntensity;

                
                float final_alpha = saturate(final_rim_alpha + flow_rgba.a + _InnerAlpha);
                float3 final_col = final_rim_alpha + flow_rgba.xyz;
                return float4(final_col,final_alpha);
                //return flow_rgba;
            }
            ENDCG
        }
    }
}
