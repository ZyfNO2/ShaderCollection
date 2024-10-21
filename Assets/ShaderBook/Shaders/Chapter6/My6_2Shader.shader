Shader "Custom/My6_2"
{
    Properties
    {
      _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
      _Specular ("Specular", Color) = (1, 1, 1, 1)
      _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert//顶点
			#pragma fragment frag//片元

            #include "Lighting.cginc"

            fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

            
            //访问法线
			struct a2v {
				float4 vertex : POSITION;//顶点
				float3 normal : NORMAL;//法线
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
            
				v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);//模型空间->裁剪空间
				
				// // Get ambient term
				// fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//环境光信息
				//
				// // Transform the normal from object space to world space 物体朝向换到世界坐标
				// fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// // Get the light direction in world space
				// fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// // Compute diffuse term 计算反射 _LightColor0.rgb光源颜色 _Diffuse.rgb材质颜色
				// fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				// //saturate 填充0-1 dot(worldNormal, worldLight)光源方向和世界点乘 cos值
				// o.color = ambient + diffuse;//散射加上环境光



					// Transform the normal from object space to world space
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				// Transform the vertex from object spacet to world space
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					
				return o;
			}


            //v2f 的值赋给 SV_Target
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				// Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				// Get the reflect direction in world space
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				// Get the view direction in world space
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				// Compute specular term
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}
            
            
            


            
            ENDCG
        }
    }
    
    
    FallBack "Diffuse"
    
}
