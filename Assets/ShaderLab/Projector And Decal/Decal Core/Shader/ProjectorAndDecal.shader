Shader "LSQ/Technology/ProjectorAndDecal/0"
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
                float3 ray : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.ray = mul(unity_ObjectToWorld, v.vertex) - _WorldSpaceCameraPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                fixed2 screenPos = i.screenPos.xy / i.screenPos.w;
                //视图空间的深度值
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, screenPos).r);
                //根据深度值重建世界坐标
                float3 worldRay = normalize(i.ray);
                float3 worldPos = _WorldSpaceCameraPos + worldRay * depth;
                //转为相对于本物体的局部坐标(变换矩阵都被抵消了)
                float3 objectPos = mul(unity_WorldToObject, float4(worldPos,1)).xyz;
                //立方体本地坐标-0.5~0.5
                clip(0.5 - abs(objectPos));
                //本地坐标中心点为0，而UV为0.5
                objectPos += 0.5;

                fixed4 col = tex2D(_MainTex, objectPos.xy);

                return col;
            }
            ENDCG
        }
    }
}
