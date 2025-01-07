Shader "Unlit/Toon"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" {}
        _SSSMap ("SSSMap", 2D) = "balck" {}
        _ILMap ("ILMap", 2D) = "gray" {}
        _DetialMap ("DetialMap", 2D) = "white" {}
        _ToonThreshold ("ToonThreshold", Range(0, 1)) = 0.5
        _ToonHardness ("ToonHardness", Float) = 20
        
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _SpecSize ("SpecSize(Range)）", Range(0,1)) = 0.1
        _SpecCtrl("SpecCtrl(Intensity)", Float) = 2
        
        _RimLightDir ("RimLightDir", Vector) = (1,0,-1,0)
        _RimLightColor ( "RimLightColor", Color) = (1,1,1,1)
        
        
        _OutlineWidth ("OutlineWidth", Float) = 5
        _OutlineZbias ("OutlineZbias", Float) = 0
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="ForwardBase" }
        LOD 100
        //toon shader
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
                //SHADOW_COORDS(4)
            };

            sampler2D _BaseMap;
            sampler2D _SSSMap;
            sampler2D _ILMap;
            sampler2D _DetialMap;
            float _ToonThreshold;
            float _ToonHardness;
            float4 _SpecColor;
            float _SpecSize;
            float _SpecCtrl;
            float4 _RimLightDir;
            float4 _RimLightColor;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.uv = float4(v.texcoord0,v.texcoord1);
                o.vertex_color = v.color;
                TRANSFER_SHADOW(o)
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 uv1 = i.uv.xy;
                half2 uv2 = i.uv.zw;

                float3 normalDir = normalize(i.normal_world);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.pos_world);
                
                // sample the texture
                half4 base_map = tex2D(_BaseMap, uv1);
                half3 base_color = base_map.rgb;//亮部颜色
                half base_mask = base_map.a;//亮部遮罩

                
                half4  sss_map = tex2D(_SSSMap, uv1);
                half3 sss_color = sss_map.rgb;//暗部颜色
                half sss_alpha = sss_map.a;//边缘光强度的控制

                
                half4  ilm_map = tex2D(_ILMap, uv1);
                //half3 ilm_color = ilm_map.rgb;
                float spec_intensity = ilm_map.r;//高光强度
                float diffuse_control = (ilm_map.g * 2) - 1;//光照偏移
                float spec_size = ilm_map.b;//高光形状
                float inner_line = ilm_map.a;//内描线


                
                //Vertex Color
                float ao = i.vertex_color.r;

                //shadow
                //float atten = SHADOW_ATTENUATION(i);
                float atten = lerp(1,SHADOW_ATTENUATION(i),i.vertex_color.g) ;

                
                //diffuse
                half NdotL = dot(normalDir, lightDir);
                half half_lambert = (NdotL + 1) * 0.5;
                half lambert_term = half_lambert * ao * atten + diffuse_control;
                half toon_diffuse = saturate((lambert_term - _ToonThreshold) * _ToonHardness);
                half3 final_diffuse =lerp(sss_color,base_color,toon_diffuse);

                
                //spec Not NdotH
                half NdotV = (dot(normalDir,viewDir) + 1.0) * 0.5;
               
                half spec_term = NdotV * 0.5 + 0.5;
                spec_term = (half_lambert * 0.2 + spec_term * 0.2) ;//高光来源
                half toon_spec = saturate(spec_term - (_SpecCtrl * -0.05 - spec_size * _SpecSize)) * 500;//这里放个参数好点捏
                half3 spec_color = (_SpecColor.rgb + base_color) * 0.5;
                half3 final_spec = (toon_spec * spec_color * spec_intensity);
                
                //outline
                half3 inner_line_color = lerp(base_color*0.2,float3(1,1,1),inner_line);
                half3 detial_color = tex2D(_DetialMap, uv2).rgb;//uv2 是干啥的来着
                detial_color = lerp(base_color*0.2,float3(1,1,1),detial_color);
                half3 final_line = inner_line_color * inner_line_color * detial_color   ;
                
                //fersnel color
                half3 lightDir_rim = normalize(mul((float3x3)unity_MatrixInvV,_RimLightDir.xyz));
                half NdotL_rim = (dot(normalDir,lightDir_rim) + 1) * 0.5;
                half rimlight_term = NdotL_rim + diffuse_control;
                half toon_rim = saturate((rimlight_term - _ToonThreshold) * 20);
                half3 rim_color = (_RimLightColor.rgb +  base_color) * 0.5  * sss_alpha;
                half3 final_rimlight = toon_rim * rim_color * base_mask * toon_diffuse;
                    
                half3 final_color = (final_diffuse + final_spec + final_rimlight) * final_line;
                final_color = sqrt(max(exp2(log2(max(final_color,0))*2.2),0));//color adjust
                return half4(final_color,1);
                 
            }
            ENDCG
        }

        //out line
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #pragma multi_compile_forwardbase
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
    
                float3 normal: Normal;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
         
                float4 vertex_color : TEXCOORD3;
            };

            sampler2D _BaseMap;
            sampler2D _SSSMap;
            sampler2D _ILMap;
           
            float _OutlineWidth ;
            float _OutlineZbias ;
            float4 _OutlineColor;
            
            

            v2f vert (appdata v)
            {
                v2f o;
               
                float3 pos_view = mul(UNITY_MATRIX_MV, v.vertex);
                //float normal_world = UnityObjectToWorldNormal(v.normal);
                float3 outline_dir = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
              
                outline_dir.z += _OutlineZbias * (1 - v.color.b);
                
                pos_view += outline_dir *  _OutlineWidth  * 0.001 ;
                //pos_view += outline_dir *  _OutlineWidth  * 0.001 * v.color.a;
                o.pos = mul(UNITY_MATRIX_P, float4(pos_view,1));
                
                o.uv = v.texcoord0;
                o.vertex_color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 baseColor = tex2D(_BaseMap, i.uv).rgb;
                half maxComponent = max(max(baseColor.r, baseColor.g), baseColor.b)-0.004;
                half3 saturatedColor = step(maxComponent.rrr,baseColor) * baseColor;
                saturatedColor = lerp(baseColor.rgb, saturatedColor, 0.6);
                half3 outlineColor = 0.8 * saturatedColor * baseColor * _OutlineColor.xyz;

                
                return half4(outlineColor,1);
                
            }
            ENDCG
        }

    }

    Fallback "Diffuse"

}
