Shader "LSQ/Technology/ProjectorAndDecal/AttackRectRange"
{
    Properties 
	{
		_ShadowTex ("Cookie", 2D) = "" {}
		_MainColor ("ScanColor", Color) = (1,1,1,1)
		_Border ("Border", Range(0, 0.5)) = 0.2

		_ScanSpeed ("ScanSpeed", float) = 0.5
		_ScanSize ("ScanSize", Range(0, 0.5)) = 0.2
		_ScanInterval ("ScanInterval", float) = 3
	}
	
	Subshader 
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Pass 
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Offset -1, -1
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct a2v 
			{
				float4 vertex : POSITION;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 uvShadow : TEXCOORD1;
			};
			
			float4x4 unity_Projector;
						
			fixed4 _MainColor;
			sampler2D _ShadowTex;
			float _Border;
			float _ScanSize;
			float _ScanSpeed;
			float _ScanInterval;

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uvShadow = mul(unity_Projector, v.vertex);
				return o;
			}

			float Rectangle(float2 samplePos, float2 halfSize)
            {
	            float2 edgeDistance = abs(samplePos) - halfSize;
	            float2 outsideDistance = length(max(0, edgeDistance));
	            float2 insideDistance = min(0, max(edgeDistance.x, edgeDistance.y));
				float2 softRect = outsideDistance + insideDistance;
				float change = fwidth(softRect) * 0.5;
                float hardRect = smoothstep(-change, change, softRect);
                return hardRect;
            }

			fixed4 frag (v2f i) : SV_Target
			{
				//投影
				fixed fullMask = tex2Dproj (_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).a;
				//去除边缘拉伸
				const float BORDER = 0.001;
				if (i.uvShadow.x / i.uvShadow.w < BORDER
				|| i.uvShadow.x / i.uvShadow.w > 1 - BORDER  
				|| i.uvShadow.y / i.uvShadow.w < BORDER
				|| i.uvShadow.y / i.uvShadow.w > 1 - BORDER)
                {
                    fullMask = 0;
                }

				float2 uv = i.uvShadow - 0.5f;
				float len = length(uv);
				//正方形
				float borderRect = saturate(Rectangle(uv, 0.5 - _Border));
				//正方形波
				float dis = (abs(uv.x) + abs(uv.y)) + _Time.y * _ScanSpeed;
				dis *= _ScanInterval;
				dis = dis - floor(dis);
				float rectWave1 = Rectangle(uv, dis);
				float rectWave2 = Rectangle(uv, dis + _ScanSize);
				float rectWave = saturate(rectWave1 - rectWave2);

				float alpha = (borderRect + rectWave) * fullMask;

				return fixed4(_MainColor.rgb, alpha);
			}
			ENDCG
		}
	}
}
