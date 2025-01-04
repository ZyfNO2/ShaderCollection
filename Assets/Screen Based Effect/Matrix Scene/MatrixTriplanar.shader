Shader "LSQ/Screen Effect/MatrixTriplanar"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _FontTex ("Font Texture", 2D) = "white" {}
        _Sharpness ("Blend sharpness", Range(1, 64)) = 1
        _TextScale ("TextScale", float) = 0.1
        _TextColor ("TextColor", color) = (0,1,0,1)
        _Tiling ("Tiling", float) = 5
        _RainSpeed ("RainSpeed", float) = 3
        _RainPower ("RainPower", float) = 10
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture;
            float4x4 _ViewToWorld;

            sampler2D _FontTex;
            float _Sharpness;
            fixed4  _TextColor;
            float _TextScale;
            float _Tiling;
            float _RainSpeed;
            float _RainPower;

            float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
            }

            fixed Rain(float2 uv)
            {
                uv.x = uv.x * _Tiling;
                float x = unity_noise_randomValue(floor(uv.x));
                float y = frac(uv.y + x * _Time.y * _RainSpeed);
                return saturate(1 / (y * _RainPower));
            }

            fixed4 Triplanar(sampler2D tex, float3 worldPos, float3 worldNormal)
            {
                //calculate UV coordinates for three projections
				float2 uv_front = worldPos.xy * _TextScale;
				float2 uv_side = worldPos.zy * _TextScale;
				float2 uv_top = worldPos.xz * _TextScale;
				
				//read texture at uv position of the three projections
				fixed4 col_front = tex2D(tex, uv_front);
				fixed4 col_side = tex2D(tex, uv_side);
				fixed4 col_top = tex2D(tex, uv_top);

				//generate weights from world normals
				float3 weights = worldNormal;
				//show texture on both sides of the object (positive and negative)
				weights = abs(weights);
				//make the transition sharper
				weights = pow(weights, _Sharpness);
				//make it so the sum of all components is 1
				weights = weights / (weights.x + weights.y + weights.z);

				//combine weights with projected colors
				col_front *= weights.z;
				col_side *= weights.x;
				col_top *= weights.y;

				//combine the projected colors
				fixed4 col = col_front + col_side + col_top;
                return col;
            }

            fixed TriplanarRain(float3 worldPos, float3 worldNormal)
            {
                //calculate UV coordinates for three projections
				float2 uv_front = worldPos.xy;
				float2 uv_side = worldPos.zy;
				float2 uv_top = worldPos.xz;
				
				//read texture at uv position of the three projections
				fixed col_front = Rain(uv_front);
				fixed col_side = Rain(uv_side);
				fixed col_top = Rain(uv_top);

				//generate weights from world normals
				float3 weights = worldNormal;
				//show texture on both sides of the object (positive and negative)
				weights = abs(weights);
				//make the transition sharper
				weights = pow(weights, _Sharpness);
				//make it so the sum of all components is 1
				weights = weights / (weights.x + weights.y + weights.z);

				//combine weights with projected colors
				col_front *= weights.z;
				col_side *= weights.x;
				col_top *= weights.y;

				//combine the projected colors
				fixed col = col_front + col_side + col_top;
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                float3 normal; 
                float depth; 
                DecodeDepthNormal(depthNormal, depth, normal);
                if(depth < 1)
                {
                    float3 worldNormal = mul(_ViewToWorld, fixed4(normal,0)).xyz;
				    // view depth
                    float z = depth * _ProjectionParams.z;
                    // convert to world space position
                    float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
                    float3 viewPos= float3((i.uv * 2 - 1) / p11_22, -1) * z;
                    float3 worldPos = mul(_ViewToWorld, float4(viewPos, 1)).xyz;
                    //Triplanar
                    fixed font = Triplanar(_FontTex, worldPos, worldNormal).r;
                    fixed rain = TriplanarRain(worldPos, worldNormal);
                    col = lerp(col, _TextColor, rain * font);
                }

                return col;
            }

            ENDCG
        }
    }
}
