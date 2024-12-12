// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FloatUV"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_MaskSpeed("MaskSpeed", Vector) = (0,0,0,0)
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_Clamp("Clamp", Float) = 1
		_Noise("Noise", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 1
		_Texture0("Texture 0", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float2 _Speed;
		uniform float _Clamp;
		uniform sampler2D _Texture0;
		uniform float2 _MaskSpeed;
		uniform sampler2D _Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _NoiseIntensity;
		uniform float4 _Color0;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 panner32 = ( 1.0 * _Time.y * _Speed + ( (ase_screenPosNorm).xy * _Clamp ));
			float3 objToWorld38 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner42 = ( 1.0 * _Time.y * _MaskSpeed + i.uv_texcoord);
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner49 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float4 tex2DNode30 = tex2D( _Texture0, ( float4( panner42, 0.0 , 0.0 ) + ( tex2D( _Noise, panner49 ) * _NoiseIntensity ) ).rg );
			float temp_output_31_0 = ( tex2DNode30.r * tex2DNode30.a );
			float4 tex2DNode52 = tex2D( _Texture0, panner42 );
			float temp_output_53_0 = ( tex2DNode52.r * tex2DNode52.a );
			o.Albedo = ( tex2D( _MainTex, ( panner32 * distance( _WorldSpaceCameraPos , objToWorld38 ) ) ) + ( ( saturate( ( temp_output_31_0 - temp_output_53_0 ) ) + saturate( ( temp_output_53_0 - temp_output_31_0 ) ) ) * _Color0 ) ).rgb;
			o.Alpha = 1;
			clip( temp_output_31_0 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SamplerNode;11;-408.2988,-194.3589;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;9c68272ca1b92d8478f8a438cb945e52;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-145.6473,215.9792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;32;-717.6473,-146.0208;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;34;-1293.647,-200.0208;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;10;-1548.722,-205.9638;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1194.647,98.97919;Inherit;False;Property;_Clamp;Clamp;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-528.0411,35.67688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;38;-1793.647,289.9792;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;39;-1392.647,142.9792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;37;-1772.647,40.97919;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;33;-845.9854,-77.24678;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;44;-1164.669,595.0193;Inherit;True;Property;_Noise;Noise;6;0;Create;True;0;0;0;False;0;False;-1;a09ba19e93c4f3040899276c260fda8b;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-777.5956,625.1981;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-755.9463,412.6992;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1202.285,835.9435;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1452.927,331.113;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;42;-1198.783,321.6825;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-1418.011,658.2294;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1672.155,667.6599;Inherit;False;0;44;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;43;-1422.307,484.0914;Inherit;False;Property;_MaskSpeed;MaskSpeed;3;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;50;-1603.67,824.3162;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;4;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;51;-821.4684,181.2051;Inherit;True;Property;_Texture0;Texture 0;8;0;Create;True;0;0;0;False;0;False;f7adc1e326b944fa1b141a1f4d7e12f8;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;30;-447.7923,284.8369;Inherit;True;Property;_Mask;Mask;2;0;Create;True;0;0;0;False;0;False;-1;3043bdd9c69ec674f9dd01742b742f69;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;-446.9393,632.9874;Inherit;True;Property;_TextureSample0;Texture Sample 0;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1029.647,-165.0208;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-124.7409,650.3022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;84.06885,261.9714;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;55;90.6828,545.1409;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;304.0178,362.0096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;312.5298,591.8391;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;426.0762,393.2109;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;29;490.2126,-267.738;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FloatUV;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;664.5908,364.4093;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;61;584.2358,685.8295;Inherit;False;Property;_Color0;Color 0;9;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;59;143.7929,-161.1112;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;11;1;40;0
WireConnection;31;0;30;1
WireConnection;31;1;30;4
WireConnection;32;0;35;0
WireConnection;32;2;33;0
WireConnection;34;0;10;0
WireConnection;40;0;32;0
WireConnection;40;1;39;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;44;1;49;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;47;0;42;0
WireConnection;47;1;46;0
WireConnection;42;0;41;0
WireConnection;42;2;43;0
WireConnection;49;0;48;0
WireConnection;49;2;50;0
WireConnection;30;0;51;0
WireConnection;30;1;47;0
WireConnection;52;0;51;0
WireConnection;52;1;42;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;53;0;52;1
WireConnection;53;1;52;4
WireConnection;54;0;31;0
WireConnection;54;1;53;0
WireConnection;55;0;53;0
WireConnection;55;1;31;0
WireConnection;57;0;54;0
WireConnection;58;0;55;0
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;29;0;59;0
WireConnection;29;10;31;0
WireConnection;60;0;56;0
WireConnection;60;1;61;0
WireConnection;59;0;11;0
WireConnection;59;1;60;0
ASEEND*/
//CHKSM=070E044A3A315C9A4840EBC6E5E273920112DB6B