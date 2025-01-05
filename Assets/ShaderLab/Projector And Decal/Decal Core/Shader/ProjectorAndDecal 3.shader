Shader "LSQ/Technology/ProjectorAndDecal/3"
{
	Properties
	{
		_ProjectorTex ("ProjectorTex", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="true" "DisableBatching"="true" }
		LOD 100
		ZWrite Off
		Cull Off
		ColorMask RGB
		Blend SrcAlpha OneMinusSrcAlpha
		Offset -1, -1

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD1;
			};

			float4x4 _WorldToProjector;
			sampler2D _ProjectorTex;
			sampler2D _CameraDepthTexture;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 screenPos = i.screenPos.xy / i.screenPos.w;
				float depth = tex2D(_CameraDepthTexture, screenPos).r;
				//还原回-1 ,1 的clip控件坐标 inv ComputeScreenPos
				fixed4 clipPos = fixed4(screenPos.x * 2 - 1, screenPos.y * 2 - 1, -depth * 2 + 1, 1);
				//还原回相机空间
				fixed4 cameraSpacePos = mul(unity_CameraInvProjection, clipPos);
				//还原回世界空间
				fixed4 worldSpacePos = mul(unity_MatrixInvV, cameraSpacePos);
				//变换到自定义投影器投影空间
				fixed4 projectorPos = mul(_WorldToProjector, worldSpacePos);
				projectorPos /= projectorPos.w;
				//变换到uv坐标系
				fixed2 projUV = projectorPos.xy * 0.5 + 0.5;  
				if(projUV.x > 1 || projUV.y > 1 || projUV.x < 0 || projUV.y < 0)
					return 0;
				fixed4 col = tex2D(_ProjectorTex, projUV);
				return col;
			}

			ENDCG
		}
	}
}
