Shader "Hidden/BrokenGlassSelf"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_GlassMask("GlassMask",2D) = "black"{}
		//_GlassColor("GlassColor",Color) = (1,1,1,1)
		_GlassCrack("GlassCrack",Float) = 1
		_GlassNormal("GlassNormal",2D) = "bump"{}
		_Distort("Distort",Float) = 1
		
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
		
			sampler2D _MainTex;
			sampler2D _GlassMask;
			float4 _GlassMask_ST;
			//float4 _GlassColor;
			float _GlassCrack;
			sampler2D _GlassNormal;
			float _Distort;

			half4 frag (v2f_img i) : SV_Target
			{
				
				
				//重复改为Clamp
				half2 glass_uv = i.uv  * _GlassMask_ST.xy + _GlassMask_ST.zw;
				//解决屏幕拉伸问题
				// x = width y = height z = 1 + 1.0/width w = 1 + 1.0/height
				float aspect = _ScreenParams.x / _ScreenParams.y; 
				glass_uv *= aspect;
				//法线
				half3 glass_normal = UnpackNormal(tex2D(_GlassNormal,glass_uv));
				
				//偏移值与边缘拉伸值
				//1.边缘Mask防止扭曲 
				half2 d = 1 - smoothstep(0.95,1,abs(i.uv * 2.0 - 1.0));
				half vfactor = d.x * d.y;
				//2.扭曲源于噪点，将小于0.005的视为0
				half2 d_mask = step(0.005, abs(glass_normal.xy));
				half mask = d_mask.x * d_mask.y;

				half2 uv_distort = i.uv + glass_normal.xy * _Distort * vfactor * mask;
				
				half4 col = tex2D(_MainTex,uv_distort );
				half3 finalcolor = col.rgb;
				half glass_opacity = tex2D(_GlassMask,glass_uv).r; 
				finalcolor = lerp(finalcolor, _GlassCrack.xxx, glass_opacity);
				return float4(finalcolor,col.a);
			}
			ENDCG
		}
	}
}
