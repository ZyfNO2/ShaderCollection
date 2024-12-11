// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire"
{
	Properties
	{
		[HDR]_TintColor("TintColor", Color) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0.5,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Sofness("Sofness", Range( 0 , 1)) = 0.1
		_GradientEndControl("GradientEndControl", Float) = 2
		_EmissIntensity("EmissIntensity", Float) = 10
		_EndMiss("EndMiss", Range( 0 , 1)) = 0
		_FireShape("FireShape", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0.1
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
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _TintColor;
		uniform float _EmissIntensity;
		uniform float _EndMiss;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _GradientEndControl;
		uniform sampler2D _Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _Sofness;
		uniform sampler2D _FireShape;
		uniform float _NoiseIntensity;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break27 = ( _TintColor * _EmissIntensity );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float4 tex2DNode10 = tex2D( _Gradient, uv_Gradient );
			float GradientEnd24 = ( ( 1.0 - tex2DNode10.r ) * _GradientEndControl );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner7 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float Noise16 = tex2D( _Noise, panner7 ).r;
			float4 appendResult28 = (float4(break27.r , ( break27.g + ( _EndMiss * GradientEnd24 * Noise16 ) ) , break27.b , break27.a));
			o.Emission = appendResult28.xyz;
			o.Alpha = 1;
			float Gradient15 = tex2DNode10.r;
			float smoothstepResult12 = smoothstep( ( Noise16 - _Sofness ) , Noise16 , Gradient15);
			float2 appendResult42 = (float2(( i.uv_texcoord.x + ( (Noise16*2.0 + -1.0) * _NoiseIntensity * GradientEnd24 ) ) , i.uv_texcoord.y));
			float4 tex2DNode34 = tex2D( _FireShape, appendResult42 );
			float clampResult52 = clamp( ( ( tex2DNode34.r * tex2DNode34.r ) * 3.0 ) , 0.0 , 1.0 );
			float Shape54 = clampResult52;
			clip( ( smoothstepResult12 * Shape54 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;53;-1616.799,866.7782;Inherit;False;2008.209;580.0464;Comment;16;39;41;38;42;37;47;44;46;35;34;48;49;50;52;40;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1837.354,-1237.239;Inherit;False;1136.565;635.9839;Comment;12;6;16;11;8;5;7;10;15;21;22;23;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1787.354,-940.4751;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-924.791,-950.6624;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1756.068,-1176.509;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;8;-1771.932,-765.2546;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;True;0;0;0;False;0;False;0,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;7;-1532.355,-927.475;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1039.96,-1191.228;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1460.963,-1187.239;Inherit;True;Property;_Gradient;Gradient;4;0;Create;True;0;0;0;False;0;False;-1;cda3212b473b3c84f9233f4eea2afa51;cda3212b473b3c84f9233f4eea2afa51;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1334.505,-801.6401;Inherit;True;Property;_Noise;Noise;2;0;Create;True;0;0;0;False;0;False;-1;3c6ccf6f19fbafc4c9078a642ec01714;3c6ccf6f19fbafc4c9078a642ec01714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;523,-583;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-337.7104,66.62109;Inherit;False;15;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-368.6565,381.8911;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-432.8371,542.4885;Inherit;False;16;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-586.5121,260.7201;Inherit;False;16;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-655.8257,444.2346;Inherit;False;Property;_Sofness;Sofness;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;35.49815,187.2584;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1018.015,-1061.583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-871.481,-1063.67;Inherit;False;GradientEnd;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-353.301,-567.8677;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-531.9713,-513.7253;Inherit;False;Property;_EmissIntensity;EmissIntensity;7;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;27;-155.3073,-690.2535;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;30;32.15001,-482.0729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-165.0437,-350.4198;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-495.2013,-403.4434;Inherit;False;Property;_EndMiss;EndMiss;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;175.334,-680.9782;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-435.8669,-125.9788;Inherit;False;16;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-480.6013,-254.7435;Inherit;False;24;GradientEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;21;-1175.035,-1080.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1258.696,-982.5457;Inherit;False;Property;_GradientEndControl;GradientEndControl;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-606.4228,-705.5151;Inherit;False;Property;_TintColor;TintColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;450.1505,392.9698;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-943.7987,1154.825;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1208.799,1330.825;Inherit;False;24;GradientEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1186.799,1207.825;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;10;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-661.7987,1009.825;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-1566.799,1050.825;Inherit;True;16;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;47;-1221.236,1054.642;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1386.236,1149.642;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1392.236,1264.642;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1176.471,916.7782;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-520.3538,984.047;Inherit;True;Property;_FireShape;FireShape;9;0;Create;True;0;0;0;False;0;False;-1;3373459282cb5864c922c17501118945;3373459282cb5864c922c17501118945;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-176.5186,1067.511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;16.4095,1132.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-205.5904,1223.218;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;52;220.4097,1145.218;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-824.7987,1000.825;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;168.76,1306.502;Inherit;False;Shape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;77.7218,639.7083;Inherit;False;54;Shape;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;16;0;5;1
WireConnection;7;0;6;0
WireConnection;7;2;8;0
WireConnection;15;0;10;1
WireConnection;10;1;11;0
WireConnection;5;1;7;0
WireConnection;0;2;28;0
WireConnection;0;10;36;0
WireConnection;13;0;17;0
WireConnection;13;1;14;0
WireConnection;12;0;18;0
WireConnection;12;1;13;0
WireConnection;12;2;19;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;24;0;22;0
WireConnection;25;0;9;0
WireConnection;25;1;26;0
WireConnection;27;0;25;0
WireConnection;30;0;27;1
WireConnection;30;1;32;0
WireConnection;32;0;29;0
WireConnection;32;1;31;0
WireConnection;32;2;33;0
WireConnection;28;0;27;0
WireConnection;28;1;30;0
WireConnection;28;2;27;2
WireConnection;28;3;27;3
WireConnection;21;0;10;1
WireConnection;36;0;12;0
WireConnection;36;1;55;0
WireConnection;39;0;47;0
WireConnection;39;1;38;0
WireConnection;39;2;41;0
WireConnection;42;0;40;0
WireConnection;42;1;35;2
WireConnection;47;0;37;0
WireConnection;47;1;44;0
WireConnection;47;2;46;0
WireConnection;34;1;42;0
WireConnection;48;0;34;1
WireConnection;48;1;34;1
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;52;0;49;0
WireConnection;40;0;35;1
WireConnection;40;1;39;0
WireConnection;54;0;52;0
ASEEND*/
//CHKSM=FE5F2F7A356101DFF01B8CB1F3842B5AF75C665F