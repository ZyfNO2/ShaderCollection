Shader "Custom/Self6-4Shader"
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
    		///规定顶点着色器，片元着色器名称
    		#pragma vertex vert
			#pragma fragment frag
			//为了使用光照
			#include "Lighting.cginc"
    		//使用Properties
    		fixed4 _Diffuse;
			///顶点着色器输入
    		struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			///顶点着色器输出
			struct v2f {
				float4 pos : SV_POSITION; 
				//逐顶点计算过程
				//fixed3 color : COLOR;
				//逐像素计算需要法线作为输出
				float3 worldNormal : TEXCOORD0;

				
			};

    		v2f vert(a2v v)
    		{
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Get ambient term 环境光信息
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Transform the normal from object space to world space
    			//物体自身空间转化为世界空间
				//fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
    			//世界空间光源标准化
				// worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// Compute diffuse term
    			//aturate(dot(worldNormal, worldLight));光源点乘法线 -> cos0 -> 颜色强度
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				//ambient 环境光
				//o.color = ambient + diffuse;

				// Transform the normal from object space to world space
    			//法线 物体自身空间转化为世界空间
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
    			
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
    		{
    			// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Get the normal in world space
				fixed3 worldNormal = normalize(i.worldNormal);
				// Get the light direction in world space
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				// Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				fixed3 color = ambient + diffuse;

    			return fixed4(color, 1.0);
    			
				//return fixed4(i.color, 1.0);
			}


    		
    		ENDCG
    	}
    	
    	
    }
    
    
    
    
    
    
    Fallback "Diffuse"
}
