Shader "LSQ/Technology/ProjectorAndDecal/2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "IgnoreProjector"="true" 
            "DisableBatching"="true"
        }

		Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
		Cull Off

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
                float4 screenPos : TEXCOORD0;
            };

            sampler2D _MainTex;
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
                //视图空间的深度值
                float depth = tex2D(_CameraDepthTexture, screenPos).r;
                //根据深度值重建世界坐标：直接逆着流水线求世界坐标
                //裁剪空间
                fixed4 clipPos = fixed4(screenPos.x * 2 - 1, screenPos.y * 2 - 1, -depth * 2 + 1, 1) * LinearEyeDepth(depth);
                //还原回相机空间
				float4 viewPos = mul(unity_CameraInvProjection, clipPos);
				//还原回世界空间 unity_MatrixInvV = UNITY_MATRIX_I_V unity_CameraToWorld 
				float4 worldPos = mul(unity_MatrixInvV, viewPos);
                //转为相对于本物体的局部坐标(变换矩阵都被抵消了)
                float3 objectPos = mul(unity_WorldToObject, worldPos).xyz;
                //立方体本地坐标-0.5~0.5
                clip(0.5 - abs(objectPos));
                //本地坐标中心点为0，而UV为0.5
                objectPos += 0.5;

                fixed4 col = tex2D(_MainTex, objectPos.xy);

                return col;//fixed4(objectPos.xy, 0, 1);
            }
            ENDCG
        }
    }
}
