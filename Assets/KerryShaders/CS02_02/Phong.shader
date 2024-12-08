// Upgrade NOTE: replaced 'defined half3' with 'defined (half3)'

Shader "lit/Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AoMap ("_AoMap", 2D) = "white" {}
        _SpecMask ("_SpecMask", 2D) = "white" {}
        _NormalMap ("_NormalMap", 2D) = "bump" {}
        _ParallaxMap ("_ParallaxMap", 2D) = "bump" {}
        
        _Shininess ("_Shininess", Range(0.01,100)) = 10
        _SpecIntensity ("_SpecIntensity", Range(0.01,5)) = 10
        _NormalIntensity ("_NormalIntensity", Range(-5,5)) = 1
        _parallax ("_parallax", Float) = 2
        //_AmbientColor ("_AmbientColor", Color) = (1,1,1,1)
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {   Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            
           
            //#include "Auto_light.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
			#include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;

                float3 normal_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;


                float3 tangent_dir : TEXCOORD3;
                float3 binormal_dir : TEXCOORD4;

                
                SHADOW_COORDS(5)
                
            };

            
            float4 _MainTex_ST;
            float _Shininess;
            float _SpecIntensity;
            float _NormalIntensity;
            float _parallax;
            float4 _AmbientColor;
            sampler2D _MainTex;
            sampler2D _AoMap;
            sampler2D _SpecMask;
            sampler2D _NormalMap;
            sampler2D _ParallaxMap;

            float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_dir = normalize(mul(float4(v.normal,0),unity_WorldToObject).xyz);
                o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz,0)).xyz);
                o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir))* v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o)
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half shadow = SHADOW_ATTENUATION(i);
                
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world.xyz);

                //normal map
                half3 normal_dir = normalize(i.normal_dir);
                half3 tangent_dir = normalize(i.tangent_dir);
                half3 binormal_dir = normalize(i.binormal_dir);
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                half2 uv_parallax = i.uv;
                half3 view_tangentspace = normalize(mul(view_dir, TBN));


                
                
                //循环UV偏移值 一般来说并不for，直接写两次
                for (int j = 0; j < 10; j++)
                {
                     //half height = tex2D(_ParallaxMap,i.uv);
                     half height = tex2D(_ParallaxMap,uv_parallax);
                    //视线转移到法线空间内,或许反了
                    //half3 view_tangentspace = normalize(mul(TBN,view_dir ));
                    //生成深度图
                    //uv_parallax = uv_parallax - (1.0 - height) * (view_tangentspace.xy) * _parallax * 0.01;
                    //只建议平面图上z
                    uv_parallax = uv_parallax - (0.5 - height) * (view_tangentspace.xy/view_tangentspace.z) * _parallax * 0.01;
                    //uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace * _parallax * 0.01;
                } 
               
                //float -> half
                half4 base_color = tex2D(_MainTex, uv_parallax);//切换采样形式
                //use to map
                base_color = pow(base_color, 2.2);

                half4 ao_color = tex2D(_AoMap, uv_parallax);
                half4 spec_mask = tex2D(_SpecMask, uv_parallax);
                half4 normal_map = tex2D(_NormalMap, uv_parallax);
                half3 normal_data = UnpackNormal(normal_map);
                
                
                //normal_dir = normalize(tangent_dir * normal_data.x * _NormalIntensity + binormal_dir * normal_data.y * _NormalIntensity + normal_dir * normal_data.z);
                normal_data.xy = normal_data.xy * _NormalIntensity;
                normal_dir = normalize(mul(normal_data, TBN));
                
                
                half3 light_dir =  normalize(_WorldSpaceLightPos0.xyz);
                //shadow map
                half3 diffterm = min(max(dot(normal_dir, light_dir),0),shadow);
                half3 diffues_color = diffterm * _LightColor0.xyz * base_color.xyz;
                //phong
                // half3 reflect_dir = reflect(-light_dir, normal_dir);
                // half RdotV = dot(reflect_dir, view_dir);
               
                //blinn phong
                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = dot(normal_dir, half_dir);

                

                
                //replace NdotH with RdotV
                half3 ambiend_color = UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.xyz;

                half3 specular_color = pow(max(0, NdotH), _Shininess)
                * diffterm * _LightColor0.xyz * _SpecIntensity * spec_mask;
                
                half3 final_color = (diffues_color + specular_color + ambiend_color) * ao_color.xyz;
                //tone 与 bloom无法共存，建议在平面上做
                half3 tone_color = ACESFilm(final_color);
                tone_color = pow(tone_color, 1/2.2);
                //return float4(shadow.xxx,1);
                return float4(tone_color,1);
                //return float4(normal_dir.xyz,1);
            }

            

            
            
            ENDCG
        }


        Pass
        {   Tags { "LightMode"="ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            
           
            //#include "Auto_light.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
			#include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;

                float3 normal_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;


                float3 tangent_dir : TEXCOORD3;
                float3 binormal_dir : TEXCOORD4;

                
                //SHADOW_COORDS(5)
                LIGHTING_COORDS(5,6)
            };

            
            float4 _MainTex_ST;
            float _Shininess;
            float _SpecIntensity;
            float _NormalIntensity;
            float _parallax;
            float4 _AmbientColor;
            sampler2D _MainTex;
            sampler2D _AoMap;
            sampler2D _SpecMask;
            sampler2D _NormalMap;
            sampler2D _ParallaxMap;

            float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_dir = normalize(mul(float4(v.normal,0),unity_WorldToObject).xyz);
                o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz,0)).xyz);
                o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir))* v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                //TRANSFER_SHADOW(o)
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //half shadow = SHADOW_ATTENUATION(i);
                //投影和衰减范围
                half atten = LIGHT_ATTENUATION(i);
                
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world.xyz);

                //normal map
                half3 normal_dir = normalize(i.normal_dir);
                half3 tangent_dir = normalize(i.tangent_dir);
                half3 binormal_dir = normalize(i.binormal_dir);
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                half2 uv_parallax = i.uv;
                half3 view_tangentspace = normalize(mul(view_dir, TBN));


                
                
                //循环UV偏移值 一般来说并不for，直接写两次
                for (int j = 0; j < 10; j++)
                {
                     //half height = tex2D(_ParallaxMap,i.uv);
                     half height = tex2D(_ParallaxMap,uv_parallax);
                    //视线转移到法线空间内,或许反了
                    //half3 view_tangentspace = normalize(mul(TBN,view_dir ));
                    //生成深度图
                    //uv_parallax = uv_parallax - (1.0 - height) * (view_tangentspace.xy) * _parallax * 0.01;
                    //只建议平面图上z
                    uv_parallax = uv_parallax - (0.5 - height) * (view_tangentspace.xy/view_tangentspace.z) * _parallax * 0.01;
                    //uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace * _parallax * 0.01;
                } 
               
                //float -> half
                half4 base_color = tex2D(_MainTex, uv_parallax);//切换采样形式
                //use to map
                //base_color = pow(base_color, 2.2);

                half4 ao_color = tex2D(_AoMap, uv_parallax);
                half4 spec_mask = tex2D(_SpecMask, uv_parallax);
                half4 normal_map = tex2D(_NormalMap, uv_parallax);
                half3 normal_data = UnpackNormal(normal_map);
                
                
                //normal_dir = normalize(tangent_dir * normal_data.x * _NormalIntensity + binormal_dir * normal_data.y * _NormalIntensity + normal_dir * normal_data.z);
                normal_data.xy = normal_data.xy * _NormalIntensity;
                normal_dir = normalize(mul(normal_data, TBN));
                
                
                half3 light_dir_point =  normalize(_WorldSpaceLightPos0.xyz - i.pos_world.xyz);
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                //w = 0平行光 
                light_dir = lerp(light_dir_point,light_dir,_WorldSpaceLightPos0.w);
                //shadow map
                half3 diffterm = min(max(dot(normal_dir, light_dir),0),atten);
                half3 diffues_color = diffterm * _LightColor0.xyz * base_color.xyz;
                //phong
                // half3 reflect_dir = reflect(-light_dir, normal_dir);
                // half RdotV = dot(reflect_dir, view_dir);
               
                //blinn phong
                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = dot(normal_dir, half_dir);

                

                
                //replace NdotH with RdotV
                //half3 ambiend_color = UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.xyz;
                //ambiend already done
                half3 specular_color = pow(max(0, NdotH), _Shininess)
                * diffterm * _LightColor0.xyz * _SpecIntensity * spec_mask;
                
                half3 final_color = (diffues_color + specular_color) * ao_color.xyz;
                //tone 与 bloom无法共存，建议在平面上做
                // half3 tone_color = ACESFilm(final_color);
                // tone_color = pow(tone_color, 1/2.2);
                //return float4(shadow.xxx,1);
                return float4(final_color,1);
                //return float4(normal_dir.xyz,1);
            }
            
            ENDCG
        }
        
    }
    Fallback "Diffuse"
}
