Shader "Custom/Self6-5_Shader"
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
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// // Get ambient term
				// fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//
				// // Transform the normal from object space to world space
				// fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// // Get the light direction in world space
				// fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//
				// // Compute diffuse term
				//
				// fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				//
				// // Get the reflect direction in world space
				// // 入射光线方向相对于法线的反射方向		-worldLightDir（CG要求于光源指向交点）
				// fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));//这里要负数，因为cg规定
				// // Get the view direction in world space
				// fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//
				// // Compute specular term
				// fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				//
				// o.color = ambient + diffuse + specular;

				o.worldNormal = mul((float3x3)unity_WorldToObject,v.normal);

				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

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
    
    
    
    FallBack "Specular"
    
}