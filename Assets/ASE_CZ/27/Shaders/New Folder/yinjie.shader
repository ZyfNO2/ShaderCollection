// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WRL/Model/yinjie"
{
	Properties
	{
		_MainTexture("主纹理", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,0)
		_NoiseTexture("燥波图_灰中白增黑减", 2D) = "white" {}
		_Amplitude("震动幅度", Range( 0 , 5)) = 1
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _NoiseTexture;
			uniform float2 _Vector0;
			uniform float4 _NoiseTexture_ST;
			uniform float _Amplitude;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform float4 _MainColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 uv_NoiseTexture = v.ase_texcoord.xy * _NoiseTexture_ST.xy + _NoiseTexture_ST.zw;
				float2 panner31 = ( 1.0 * _Time.y * _Vector0 + uv_NoiseTexture);
				float3 appendResult7 = (float3(0.0 , ( (-0.5 + (tex2Dlod( _NoiseTexture, float4( panner31, 0, 0.0) ).r - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) * _Amplitude ) , 0.0));
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = appendResult7;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTexture = i.ase_texcoord1.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				
				
				finalColor = ( tex2D( _MainTexture, uv_MainTexture ) * _MainColor );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
6.666667;6.666667;2547;1365;2177.705;714.5481;1.3;True;False
Node;AmplifyShaderEditor.Vector2Node;32;-1370.255,454.1892;Inherit;False;Property;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;0,0;0.3,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1461.192,315.4391;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;31;-1077.813,311.9128;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-678.3033,301.7862;Inherit;True;Property;_NoiseTexture;燥波图_灰中白增黑减;2;0;Create;False;0;0;0;False;0;False;-1;e5fec6a47b4bcfc418745a1cd4c08ade;8dbf1d6ff261e7e459d1ccaad91fc172;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-285.7786,666.3784;Inherit;False;Property;_Amplitude;震动幅度;3;0;Create;False;0;0;0;False;0;False;1;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;30;-337.4239,326.2375;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;38.99165,312.9638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-396.2999,85.5;Inherit;False;Property;_MainColor;主颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;2.81745,0.903486,3.031433,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-493.2999,-156.5;Inherit;True;Property;_MainTexture;主纹理;0;0;Create;False;0;0;0;False;0;False;-1;None;88eb97e78f86c604bb00864c0dbeffc1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;249.3033,65.96789;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;466.4074,1801.699;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;910.2889,2160.856;Inherit;False;Constant;_Float6;Float 6;6;0;Create;True;0;0;0;False;0;False;0.08;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;861.2819,1793.967;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;68;-829.9874,1848.596;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;1249.22,1964.071;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;1895.22,1953.071;Inherit;False;Property;_Color1;Color 1;8;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;77;1569.22,2136.071;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;75;1462.22,1864.071;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;82;1900.22,1769.071;Inherit;False;Property;_Color0;Color 0;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;80;2238.22,2069.071;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;1885.22,2135.071;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-278.5464,2158.663;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-54.94165,2060.802;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;1194.924,2137.019;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1934.971,1771.971;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1059.94,1960.407;Inherit;False;Property;_yanjing_Y;yanjing_Y;5;0;Create;True;0;0;0;False;0;False;5.75;2.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-811.1942,1578.736;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;-0.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;86;-2749.893,2618.647;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-82.30006,-93.49998;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;39;-502.653,1377.57;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;84;2608.852,2139.124;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;77.73645,1514.74;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1326.22,2354.071;Inherit;False;Constant;_Float8;Float 8;6;0;Create;True;0;0;0;False;0;False;0.21;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-2404.54,1878.853;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-2301.538,2247.849;Inherit;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;96;-1536.406,2668.515;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;97;-1531.406,2935.515;Inherit;True;ColorDodge;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;93;-1948.406,2895.515;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;35;-2132.816,1431.439;Inherit;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BlendOpsNode;87;-1958.995,2624.964;Inherit;True;Difference;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-2036.676,2074.668;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;-2162.406,2930.515;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-2474.445,1329.112;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;34;-1832.9,1332.128;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;66;-1605.167,1770.63;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;36;-1511.133,1344.046;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;63;-891.5493,2253.042;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;111;-684.0549,2813.847;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;61;-1763.89,2070.144;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1204.678,1503.929;Inherit;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;7.89;7.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;-1425.456,2082.594;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;67;-1270.826,1842.548;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-603.6509,2405.755;Inherit;False;Constant;_Float10;Float 10;9;0;Create;True;0;0;0;False;0;False;5.11;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-792.5944,1698.936;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;37;-956.3125,1353.404;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;-265.9751,2774.779;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-1102.406,2852.515;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;107;-2502.957,2960.281;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-2700.557,3125.081;Inherit;False;Constant;_Float9;Float 9;9;0;Create;True;0;0;0;False;0;False;0.81;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-2770.157,2968.281;Inherit;False;Constant;_Float5;Float 5;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;115;-466.0268,2287.792;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;108;-2251.757,2661.081;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;64;-1203.606,2249.977;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;0;False;0;False;16.79;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;478.3042,-95.86959;Float;False;True;-1;2;ASEMaterialInspector;100;1;WRL/Model/yinjie;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;31;0;12;0
WireConnection;31;2;32;0
WireConnection;5;1;31;0
WireConnection;30;0;5;1
WireConnection;22;0;30;0
WireConnection;22;1;23;0
WireConnection;7;1;22;0
WireConnection;70;0;42;0
WireConnection;70;1;116;0
WireConnection;71;0;70;0
WireConnection;68;0;67;0
WireConnection;68;1;69;0
WireConnection;77;0;78;0
WireConnection;77;1;73;0
WireConnection;75;0;76;0
WireConnection;75;1;71;0
WireConnection;80;0;82;0
WireConnection;80;1;83;0
WireConnection;80;2;79;0
WireConnection;79;0;75;0
WireConnection;79;1;77;0
WireConnection;113;0;68;0
WireConnection;113;1;115;0
WireConnection;116;0;68;0
WireConnection;116;1;115;0
WireConnection;73;0;71;0
WireConnection;73;1;74;0
WireConnection;65;0;58;1
WireConnection;65;1;60;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;39;0;37;0
WireConnection;39;3;40;0
WireConnection;39;4;41;0
WireConnection;84;0;80;0
WireConnection;84;3;75;0
WireConnection;42;0;39;0
WireConnection;42;1;63;0
WireConnection;96;0;87;0
WireConnection;96;1;93;0
WireConnection;97;0;93;0
WireConnection;97;1;87;0
WireConnection;93;0;108;0
WireConnection;93;1;94;0
WireConnection;87;0;108;0
WireConnection;87;1;108;1
WireConnection;59;0;58;2
WireConnection;59;1;60;0
WireConnection;94;0;108;1
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;66;0;65;0
WireConnection;36;0;34;0
WireConnection;63;0;112;0
WireConnection;63;1;64;0
WireConnection;111;0;98;0
WireConnection;61;0;59;0
WireConnection;62;0;61;0
WireConnection;67;0;66;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;112;0;111;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;107;0;86;0
WireConnection;107;1;109;0
WireConnection;107;2;110;0
WireConnection;115;0;62;0
WireConnection;115;1;117;0
WireConnection;108;0;107;0
WireConnection;0;0;2;0
WireConnection;0;1;7;0
ASEEND*/
//CHKSM=480BC0350B05F84458ED40632D1C7B1C320A2939