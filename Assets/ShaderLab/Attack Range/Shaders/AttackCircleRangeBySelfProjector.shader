Shader "LSQ/Technology/ProjectorAndDecal/AttackCircleRangeBySelfProjector"
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
		Tags 
		{ 
			"RenderType"="Transparent" 
			"Queue"="Transparent" 
			"IgnoreProjector"="true" 
            "DisableBatching"="true"
		}

		Pass 
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
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
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 ray : TEXCOORD1;
            };
						
			fixed4 _MainColor;
			sampler2D _ShadowTex;
			sampler2D _CameraDepthTexture;
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.ray = mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos;
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
				fixed2 screenPos = i.screenPos.xy / i.screenPos.w;
                //视图空间的深度值
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, screenPos).r);
                //根据深度值重建世界坐标
                float3 worldRay = normalize(i.ray);
                //float3 worldPos = _WorldSpaceCameraPos + worldRay * depth;
                //裁剪空间的线性深度值和视图空间的不一致
                //解决方案一：需要一些数学头脑，看图说话！
				worldRay /= dot(worldRay, -UNITY_MATRIX_V[2].xyz);
                float3 worldPos = _WorldSpaceCameraPos + worldRay * depth;
                //转为相对于本物体的局部坐标(变换矩阵都被抵消了)
                float3 objectPos = mul(unity_WorldToObject, float4(worldPos,1)).xyz;
                //立方体本地坐标-0.5~0.5
                clip(0.5 - abs(objectPos));
                //本地坐标中心点为0，而UV为0.5
                objectPos += 0.5;

				float2 uv = objectPos.xy - 0.5f;
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
				fixed fullMask = tex2D(_ShadowTex, objectPos.xy).a;
				//去除边缘拉伸
				const float BORDER = 0.001;
				if (screenPos.x < BORDER
				|| screenPos.x > 1 - BORDER  
				|| screenPos.y < BORDER
				|| screenPos.y > 1 - BORDER)
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
