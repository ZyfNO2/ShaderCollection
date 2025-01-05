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
                //��ͼ�ռ�����ֵ
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, screenPos).r);
                //�������ֵ�ؽ���������
                float3 worldRay = normalize(i.ray);
                float3 worldPos = _WorldSpaceCameraPos + worldRay * depth;
                //תΪ����ڱ�����ľֲ�����(�任���󶼱�������)
                float3 objectPos = mul(unity_WorldToObject, float4(worldPos,1)).xyz;
                //�����屾������-0.5~0.5
                clip(0.5 - abs(objectPos));
                //�����������ĵ�Ϊ0����UVΪ0.5
                objectPos += 0.5;

                fixed4 col = tex2D(_MainTex, objectPos.xy);

                return col;
            }
            ENDCG
        }
    }
}
