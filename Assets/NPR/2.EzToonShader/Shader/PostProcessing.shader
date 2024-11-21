Shader "Hidden/GSST/PostProcessing"
{
   HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        //当前屏幕颜色
        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float _Exposure;
        float _Saturation;
        float _Contrast;

		// Converts color to luminance (grayscale)
		float Luminance(float3 rgb)
		{
			return dot(rgb, float3(0.2126729, 0.7151522, 0.0721750));
		}

		// Reference: https://github.com/EpicGames/UnrealEngine/blob/release/Engine/Shaders/Private/PostProcessCombineLUTs.usf
		float3 ColorCorrect(float3 color, float saturation, float contrast, float exposture)
		{
			float luma = Luminance(color);
			color = max(0, lerp(luma, color, saturation));
			color = pow(color * (1.0 / 0.18), contrast) * 0.18;
			color = color * pow(2.0, exposture);
			return color;
		}
        //映射
		// ACES tone mapping curve fit to go from HDR to LDR
		// Reference: https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
		float3 ACESFilm(float3 x)
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
		}

        float4 Frag(VaryingsDefault i) : SV_Target
        {
        	//采样
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        	//处理曝光度、饱和度
            color.rgb = ColorCorrect(color.rgb, _Saturation, _Contrast, _Exposure);
			//映射
        	color.rgb = ACESFilm(color.rgb);    
            return color;
        }

    ENDHLSL
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
				//使用内置的Shader变量
                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
