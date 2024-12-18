Shader "TShader/OcclusionClip"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Clip("Clip",Range(0,1)) = 0.4
        _Distance("DissolveDistance", Range(0, 20)) = 14
        _DistanceFactor("DistanceFactor", Range(0,3)) = 3
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        Pass
        {
            Blend SrcAlpha OneMinusDstAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            float _Distance;
            float _DistanceFactor;
            float _Clip;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float Remap(float x,float2 from,float2 to)
            {
                return ((x-from.x)/(from.y-from.x) * (to.y-to.x))+to.x;
            }
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                o.viewDir = ObjSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 screenPos = i.screenPos.xy / i.screenPos.w;
                screenPos.xy *= _ScreenParams.xy;
                float d = distance(float2(0.5,0.5) * _ScreenParams.xy, screenPos)/_ScreenParams.xy;
                float viewDistance = max(0, (_Distance - length(i.viewDir)) / _Distance) * _DistanceFactor;
                d /= viewDistance;
                d = clamp(d,0,1);
                if (d < _Clip)
                    clip(-1);
                return col;
            }
            ENDCG
        }
    }
}