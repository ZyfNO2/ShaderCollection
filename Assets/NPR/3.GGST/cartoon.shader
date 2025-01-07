Shader "custom/cartoon"
{
    Properties
    {
        _MainTex ("BaseTex", 2D) = "white" {}
        _ILMTex("ILMTex",2D) = "white"{}
        _SssTex("SssTex",2D) = "white"{}
        _DetailTex("DetailTex",2D) = "white"{}

        _ToonThesHold("光照阈值", float) = 0.2
        _ToonHardness("阴影边缘软硬度",float) = 0.2
        
        _RimLightIntens("边缘光强度",float) = 0.2
        _RimWidth("边缘光粗细",float) = 0.2
        _SpecSize("高光大小",float) = 0.2
        _DetailIntensity("细节",float) = 0.2

        _OutlineWidth("描边宽度",float) = 0.2
        _OutlineColor("描边颜色", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 vertexColor : Color;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float4 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertexColor : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                LIGHTING_COORDS(4, 5)
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ILMTex;
            sampler2D _SssTex;
            sampler2D _DetailTex;

            float _ToonHardness;
            float _ToonThesHold;
            float _RimLightIntens;
            float _RimWidth;
            float _SpecSize;
            float _DetailIntensity;

            float3 _RimLightDir;



            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertexColor = v.vertexColor;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                half4 base_map =  tex2D(_MainTex, i.uv);
                //亮部的颜色
                
                //皮肤和非皮肤区域
                half base_mask = base_map.a;

                //阴影贴图
                half4 sss_map = tex2D(_SssTex,i.uv);
                //暗部颜色
                half3 sss_color = sss_map.rgb;
                //边缘光强度控制
                half sss_alpha = sss_map.a;
                
                //高光贴图
                half4 ilm_map = tex2D(_ILMTex,i.uv);
                float spec_intens = ilm_map.r;
                float diffuse_ramp = ilm_map.g;
                float spec_size = ilm_map.b;
                float inner_line = ilm_map.a;

                half4 detail_map = tex2D(_DetailTex,i.uv);

                base_map *= inner_line ; // 磨损线条
                base_map = lerp(base_map, base_map * detail_map, _DetailIntensity);//控制磨损线条强度

                half3 base_color = base_map.rgb;
                
                //环境光遮蔽色
                float ao = i.vertexColor.r;

                //数据准备
                
                //归一化光方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                //再次归一化worldNorml
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                half NdL = dot(worldNormal, worldLight);
                half NdV = dot(worldNormal, viewDir);
                half half_lambert = 0.5 * NdL + 0.5;
                
                
                
                //漫反射：
                float threshold = saturate(step(_ToonThesHold,((0.5+0.5 * NdL + diffuse_ramp))));
                float3 diffuse_color = lerp(lerp(sss_map, base_map,(1 - _ToonHardness)),
                base_map, threshold) * _LightColor0.rgb * _LightColor0.rgb;

                //边缘光
                
                float3 rim = step(1 - _RimWidth,(1 - NdV)) * _RimLightIntens * base_color;
                rim = lerp(0,rim,threshold);
                half3 rim_color = max(0,rim) * lightColor;



                half3 final_color = rim_color+diffuse_color;
                //高光

                float linearMask = pow(spec_intens, 1/2.2);
                float layerMask = linearMask * 255;
                
                if(layerMask > 145){
                    
                    half3 spec_color = (_LightColor0.rgb * base_color);
                    float spec_term = NdV * ao + diffuse_ramp;
                    spec_term = half_lambert * 0.9 + spec_term * 0.11;
                    half Toon_spec = saturate((spec_term-(1.0-spec_size * _SpecSize)) * 500);

                    spec_color = Toon_spec * spec_color * spec_intens;
                    final_color += spec_color;
                }

                

                //final_color *= tex2D(_DetailTex,i.uv);
                return half4(final_color,1);
            }
            ENDCG
        }


        Pass
        {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 vertexColor : Color;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };
            
            float _OutlineWidth;
            float4 _OutlineColor;
            // float4 _LightColor0;
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                float4 pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间，保证描边没有近大远小的情况
                float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1,1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));//将近裁剪面右上角位置的顶点变换到观察空间 https://www.cnblogs.com/wbaoqing/p/5433193.html
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);//求得屏幕宽高比
                ndcNormal.x *= aspect;
                pos.xy += _OutlineWidth * 0.01 * ndcNormal;
                o.pos = pos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            
            ENDCG
        }
    }
    
	Fallback"Specular"
}