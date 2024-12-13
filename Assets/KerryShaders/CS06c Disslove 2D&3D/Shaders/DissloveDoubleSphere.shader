// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DissloveDoubleSphere"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_EdgeIntensity("EdgeIntensity", Float) = 2
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 0
		_Spread("Spread", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_MainColor("MainColor", Color) = (0,0,0,0)
		_ObjectScale("ObjectScale", Float) = 1
		[Toggle(_DIR_DISSLOVE_ON)] _DIR_DISSLOVE("DIR_DISSLOVE", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _DIR_DISSLOVE_ON
		#pragma shader_feature_local _MANNULCONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _MainColor;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform float _ObjectScale;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( _MainColor * tex2D( _MainTex, uv_MainTex ) ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld41 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_48_0 = (0.0 + (( length( ( ase_worldPos - objToWorld41 ) ) / _ObjectScale ) - 0.0) * (1.0 - 0.0) / (0.6 - 0.0));
			#ifdef _DIR_DISSLOVE_ON
				float staticSwitch51 = temp_output_48_0;
			#else
				float staticSwitch51 = ( 1.0 - temp_output_48_0 );
			#endif
			float mulTime22 = _Time.y * 0.2;
			#ifdef _MANNULCONTROL_ON
				float staticSwitch24 = _ChangeAmount;
			#else
				float staticSwitch24 = frac( mulTime22 );
			#endif
			float Gradient19 = ( ( ( staticSwitch51 - (-_Spread + (staticSwitch24 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner30 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float Noise32 = ( 1.0 - tex2D( _Noise, panner30 ).r );
			float temp_output_34_0 = ( Gradient19 - Noise32 );
			float clampResult13 = clamp( ( 1.0 - ( distance( temp_output_34_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			o.Emission = ( _EdgeColor * _EdgeIntensity * clampResult13 ).rgb;
			o.Alpha = 1;
			clip( ( 1.0 - step( 0.5 , temp_output_34_0 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;18;-2444.444,437.6536;Inherit;False;1571.091;844.8211;Gradient;21;41;40;39;36;35;22;4;27;19;26;25;24;7;5;23;44;45;48;50;51;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-847.0306,661.8078;Inherit;False;1466.075;460.2865;EdgeColor;6;8;9;10;11;12;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DistanceOpNode;8;-584.101,711.8078;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-797.0306,807.2245;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-221.5171,793.1646;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-621.262,1006.094;Inherit;False;Property;_EdgeWidth;EdgeWidth;3;0;Create;True;0;0;0;False;0;False;0.1;0.146;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;102.8998,807.2256;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;13;365.0442,805.2164;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;430.639,-150.7237;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;DissloveDoubleSphere;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;28;-1769.929,1346.141;Inherit;True;Property;_Noise;Noise;8;0;Create;True;0;0;0;False;0;False;-1;None;c9a10d53f9ef84c47a947772bc9f4446;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2345.929,1307.141;Inherit;False;0;28;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;30;-2042.93,1390.342;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;31;-2253.23,1499.541;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;9;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;33;-848.6249,525.3361;Inherit;False;32;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-843.3558,419.7109;Inherit;False;19;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;-644.1241,431.0352;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1027.778,-292.3678;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;30e5e49362d5aae4d91ba0ae634a707f;77c0052bfe0214fb5ae5bfe242913675;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-614.5511,-420.5898;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;38;-943.9861,-484.6032;Inherit;False;Property;_MainColor;MainColor;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-666.4683,119.535;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;5;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-2381.027,482.3523;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;41;-2392.41,641.898;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FractNode;23;-2041.011,927.1484;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2225.588,1059.058;Inherit;False;Property;_ChangeAmount;ChangeAmount;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;7;-1644.523,954.4468;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;24;-1920.557,996.7338;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;6;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2037.599,1172.295;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;27;-1776.492,1112.468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-2222.89,924.4882;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1061.782,557.587;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;26;-1385.444,1012.232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1224.593,1025.329;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1309.13,1174.051;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2119.479,731.2947;Inherit;False;Property;_ObjectScale;ObjectScale;11;0;Create;True;0;0;0;False;0;False;1;2.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-2137.564,482.0042;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;48;-1712.592,615.6818;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.6;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-1875.71,622.7964;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-22.72576,-199.8074;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;14;-668.1469,-124.775;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.2889349,0.7830189,0.2696244,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1096.732,1386.218;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-1404.203,1404.821;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1186.275,630.9667;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1540.93,567.3724;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;51;-1398.951,623.2444;Inherit;False;Property;_DIR_DISSLOVE;DIR_DISSLOVE;12;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;52;-1950.499,507.7942;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;6;-359.937,395.9133;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-72.3775,406.3719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;8;0;34;0
WireConnection;8;1;9;0
WireConnection;10;0;8;0
WireConnection;10;1;11;0
WireConnection;12;0;10;0
WireConnection;13;0;12;0
WireConnection;0;0;37;0
WireConnection;0;2;16;0
WireConnection;0;10;53;0
WireConnection;28;1;30;0
WireConnection;30;0;29;0
WireConnection;30;2;31;0
WireConnection;34;0;20;0
WireConnection;34;1;33;0
WireConnection;37;0;38;0
WireConnection;37;1;1;0
WireConnection;23;0;22;0
WireConnection;7;0;24;0
WireConnection;7;3;27;0
WireConnection;24;1;23;0
WireConnection;24;0;5;0
WireConnection;27;0;25;0
WireConnection;19;0;35;0
WireConnection;26;0;4;0
WireConnection;26;1;25;0
WireConnection;35;0;26;0
WireConnection;35;1;36;0
WireConnection;40;0;39;0
WireConnection;40;1;41;0
WireConnection;48;0;44;0
WireConnection;44;0;52;0
WireConnection;44;1;45;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;16;2;13;0
WireConnection;32;0;49;0
WireConnection;49;0;28;1
WireConnection;4;0;51;0
WireConnection;4;1;7;0
WireConnection;50;0;48;0
WireConnection;51;1;50;0
WireConnection;51;0;48;0
WireConnection;52;0;40;0
WireConnection;6;1;34;0
WireConnection;53;0;6;0
ASEEND*/
//CHKSM=514CE1CE206A2244243A892E7504CA9D7860A916