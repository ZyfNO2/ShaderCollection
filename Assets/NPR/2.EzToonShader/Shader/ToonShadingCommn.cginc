#ifndef TOONSHADING_COMMON_CGINC
#define TOONSHADING_COMMON_CGINC
//避免重复包含
            //#include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            half _CutOff;
            sampler2D _GradientMap;
             
            //half _ShadowThreshold;
            //half4 _ShadowColor;
            sampler2D _ShadowColor1stTex;
			half4 _ShadowColor1st;
			sampler2D _ShadowColor2ndTex;
			half4 _ShadowColor2nd;

            half4 _SpecularColor;
			half _SpecularPower;
			//half _SpecularThreshold;
             
            float4 _LightColor0;

            //a2v application to vertex
            //v2f vertex to fragment
            //v2f vert (a2v v) 用于填充v2f结构体
            //fixed4 frag (v2f i) : SV_Target 最总渲染
            
            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                
                
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir :TEXCOORD1;
                float3 worldPos :TEXCOORD2;
            };

            

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //将顶点的UV坐标通过_MainTex纹理矩阵进行变换，得到最终的UV坐标
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //物体空间的Normal需要转换
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                //顶点坐标到世界坐标
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //法线
                half3 normalDir = normalize(i.normalDir);
                //找光源方向
                half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //观察方向
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //观察方向 光照方向的均值
                half3 halfDir = normalize(lightDir + viewDir);


                
                //纹理采样
                half4 albedo = tex2D(_MainTex, i.uv) * _Color;

                #if defined (IS_ALPHATEST)
                clip(albedo.a - _CutOff);
                #endif

                
                //Ambient lighting
                //half3 ambient = ShadeSH9(half4(normalDir,1.0));
                //抹平normalDir
                half3 ambient = max(ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)), ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)));
                
                //Diffuse lighting
                //得到光线的强度
                half nl = dot(normalDir,lightDir);
                //diff阶梯，使得风格化
                //half3 diff = nl > _ShadowThreshold ? 1.0 : _ShadowColor.rgb;
                //控制漫反射得渐变
                //第一层阴影颜色   混合亮部颜色和阴影颜色   使得渐变变得平滑
                //混合第二层颜色
                half2 diffGradinent = tex2D(_GradientMap,float2(nl*0.5 + 0.5,0.5)).rg; 
                half3 diffalbedo = lerp(albedo.rgb,tex2D(_ShadowColor1stTex,i.uv) * _ShadowColor1st.rgb,diffGradinent.r);
                diffalbedo = lerp(diffalbedo,tex2D(_ShadowColor2ndTex,i.uv) * _ShadowColor2nd.rgb,diffGradinent.g);
                half3 diff = diffalbedo;
                
 
                
                // Specular lighting
                //采样渐变图得横坐标
				//half3 spec = pow(max(nh, 1e-5), _SpecularPower) > _SpecularThreshold ? _SpecularColor.rgb : 0.0;
                half nh = dot(normalDir, halfDir);//range[-1,1]
                half specGradient = tex2D(_GradientMap,float2(pow(max(nh, 1e-5), _SpecularPower),0.5).r).b;
                half3 spec = specGradient *albedo.rgb * _SpecularColor.rgb;
                

                
                half3 col = ambient * albedo.rgb + (diff + spec) * albedo.rgb * _LightColor0.rgb;
                #if defined (IS_TRANSPARENT)
                return half4(col,albedo.a);
                #else
                return half4(col,1.0);
                #endif
            }
#endif
