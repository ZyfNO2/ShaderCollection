Shader "Unity Shaders Book/Chapter 7/Single Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// 将顶点位置从对象空间转换到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);

				// 将法线从对象空间转换到世界空间
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				// 将顶点位置从对象空间转换到世界空间，并只取xyz分量
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				// 根据纹理坐标和纹理的缩放和平移参数计算最终的uv坐标
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// Or just call the built-in function
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal); // 将世界空间法线归一化
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); // 获取并归一化世界空间到光源的方向

				// 使用纹理采样漫反射颜色，并乘以材质颜色
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				// 计算环境光贡献
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; 
				// 计算漫反射光贡献
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); // 获取并归一化世界空间到视图的方向
				fixed3 halfDir = normalize(worldLightDir + viewDir); // 计算半向量，用于镜面反射计算
				
				// 计算镜面反射光贡献，使用半向量和法线的点积的幂次来确定镜面高光的大小
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
