Shader "LSQ/Technology/ProjectorAndDecal/AttackCircleRange"
{
    Properties 
	{
		_ShadowTex ("Cookie", 2D) = "" {}
		_MainColor ("ScanColor", Color) = (1,1,1,1)
		_Forward ("Forward", Range(0, 360)) = 0
		_MinRange ("MinRange", Range(0, 0.25)) = 0
		_AttackAngle ("AttackAngle", Range(0, 360)) = 60

		_Power ("Power", float) = 5
		_Strength ("Strength", float) = 1

		_ScanSpeed ("ScanSpeed", float) = 0.5
		_ScanInterval ("ScanInterval", float) = 3
		_ScanStrength ("ScanStrength", float) = 1
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
			float _Forward;
			float _MinRange;
			float _AttackAngle;
			float _Power;
			float _Strength;
			float _ScanSpeed;
			float _ScanInterval;
			float _ScanStrength;

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uvShadow = mul(unity_Projector, v.vertex);
				return o;
			}

			float2 Rotate(float2 samplePosition, float rotation)
			{
				const float PI = 3.14159;
				float angle = rotation / 180 * PI;
				float sine, cosine;
				sincos(angle, sine, cosine);
				return float2(cosine * samplePosition.x + sine * samplePosition.y, 
							cosine * samplePosition.y - sine * samplePosition.x);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uvShadow - 0.5f;
				uv = Rotate(uv, _Forward);
				float len = length(uv);
				float len2 = uv.x * uv.x + uv.y * uv.y;
				float range;

				//最小范围			
				if (len2 < _MinRange)
				{
					range = 0;
				}
				else
				{
					//角度
					const float PI = 3.14159;
					float angle = atan2(uv.y, uv.x) / PI * 180;
					range = 1 - step(smoothstep(_AttackAngle * 0.5, 0, angle) - smoothstep(0, -_AttackAngle * 0.5, angle), 0);
				}

				//投影
				fixed fullMask = tex2D(_ShadowTex, i.uvShadow.xy / i.uvShadow.w).a;
				//fixed fullMask = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).a;
				//去除边缘拉伸
				const float BORDER = 1e-5;
				if (i.uvShadow.x / i.uvShadow.w < BORDER
				|| i.uvShadow.x / i.uvShadow.w > 1 - BORDER  
				|| i.uvShadow.y / i.uvShadow.w < BORDER
				|| i.uvShadow.y / i.uvShadow.w > 1 - BORDER)
                {
                    fullMask = 0;
                }

				//最外圈
				float alpha = pow(len, _Power) * fullMask * _Strength;

				//中心波
				float centerWave = 0;
				if(alpha > 0)
				{
					float dis = len + _Time.y * _ScanSpeed;
					dis *= _ScanInterval;
					float wave = dis - floor(dis);
					wave = pow(wave, _Power) * _ScanStrength;
					alpha = clamp(alpha + wave, 0, _Strength);
				}

				return fixed4(_MainColor.rgb, alpha * range);
			}
			ENDCG
		}
	}
}
