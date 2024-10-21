// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MHU3D/Particles/FlowMapDissolve"
{
	Properties
	{
		_MainTexture("主纹理", 2D) = "white" {}
		_FlowMapTexture("FlowMap", 2D) = "white" {}
		_Dissolve("溶解进程", Range( 0 , 1)) = 0
		_DissolveTexture("溶解图", 2D) = "white" {}
		[HDR]_MainColor("主颜色", Color) = (1,1,1,1)
		_Soft("溶解软边强度", Range( 0.5 , 1)) = 1
		[Enum(OFF,0,ON,1)]_Customusedisuv2X("Custom use dis uv2X", Float) = 0
		_MaskSub("MaskSub", Range( 0 , 1)) = 0.5176471
		_MaskMul("MaskMul", Range( 1 , 5)) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
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
			#define ASE_NEEDS_FRAG_COLOR


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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainColor;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform sampler2D _FlowMapTexture;
			uniform float4 _FlowMapTexture_ST;
			uniform float _Dissolve;
			uniform float _Customusedisuv2X;
			uniform float _Soft;
			uniform sampler2D _DissolveTexture;
			uniform float _MaskSub;
			uniform float _MaskMul;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
				float2 uv_MainTexture = i.ase_texcoord1.xyz.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				float2 uv_FlowMapTexture = i.ase_texcoord1.xyz.xy * _FlowMapTexture_ST.xy + _FlowMapTexture_ST.zw;
				float4 tex2DNode3 = tex2D( _FlowMapTexture, uv_FlowMapTexture );
				float2 appendResult4 = (float2(tex2DNode3.r , tex2DNode3.g));
				float3 texCoord27 = i.ase_texcoord1.xyz;
				texCoord27.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult28 = lerp( _Dissolve , texCoord27.z , _Customusedisuv2X);
				float2 lerpResult5 = lerp( uv_MainTexture , appendResult4 , lerpResult28);
				float4 tex2DNode1 = tex2D( _MainTexture, lerpResult5 );
				float smoothstepResult19 = smoothstep( ( 1.0 - _Soft ) , _Soft , saturate( ( ( tex2D( _DissolveTexture, lerpResult5 ).r + 1.0 ) - ( lerpResult28 * 2.0 ) ) ));
				float2 texCoord29 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult22 = (float4((( _MainColor * tex2DNode1 * i.ase_color )).rgb , ( tex2DNode1.a * i.ase_color.a * smoothstepResult19 * _MainColor.a * saturate( ( saturate( ( ( 1.0 - distance( texCoord29 , float2( 0.5,0.5 ) ) ) - _MaskSub ) ) * _MaskMul ) ) )));
				
				
				finalColor = appendResult22;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;12;2560;1367;2538.355;567.3375;1.704886;True;False
Node;AmplifyShaderEditor.SamplerNode;3;-1964.639,147.7142;Inherit;True;Property;_FlowMapTexture;FlowMap;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1791.324,555.3852;Inherit;False;Property;_Dissolve;溶解进程;2;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1770.996,695.8774;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1764.638,881.4674;Inherit;False;Property;_Customusedisuv2X;Custom use dis uv2X;6;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1616.984,184.9636;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;32;-840.2156,1122.011;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;28;-1326.137,739.3508;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1936.734,-300.0399;Inherit;True;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-983.8123,971.3941;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;30;-594.4128,969.1942;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-1204.984,-101.7838;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;33;-337.2157,981.0113;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-827.5722,379.5665;Inherit;True;Property;_DissolveTexture;溶解图;3;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-704.2155,841.4501;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-696.9671,582.0361;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-429.2155,1241.011;Inherit;False;Property;_MaskSub;MaskSub;7;0;Create;True;0;0;0;False;0;False;0.5176471;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-407.9676,469.1362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-477.8183,709.4186;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;-130.2159,1011.011;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-234.5963,465.6924;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;43.78409,1276.011;Inherit;False;Property;_MaskMul;MaskMul;8;0;Create;True;0;0;0;False;0;False;5;1.7;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;112.784,1014.011;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;38.05722,770.5735;Inherit;False;Property;_Soft;溶解软边强度;5;0;Create;False;0;0;0;False;0;False;1;1;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;17;-422.9677,69.68479;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;388.7838,1040.011;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-535.8931,-164.1825;Inherit;True;Property;_MainTexture;主纹理;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;21;308.9973,589.6011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;18;51.39507,465.5121;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;-466.9485,-348.1332;Inherit;False;Property;_MainColor;主颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-104.1063,-139.2243;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;39;659.1679,1099.738;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;574.4528,509.493;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;1024.29,130.3008;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;24;951.0174,-41.17837;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;1297.016,26.82162;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1532.827,26.90994;Float;False;True;-1;2;ASEMaterialInspector;100;1;MHU3D/Particles/FlowMapDissolve;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;43;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;4;0;3;1
WireConnection;4;1;3;2
WireConnection;28;0;6;0
WireConnection;28;1;27;3
WireConnection;28;2;26;0
WireConnection;30;0;29;0
WireConnection;30;1;32;0
WireConnection;5;0;2;0
WireConnection;5;1;4;0
WireConnection;5;2;28;0
WireConnection;33;0;30;0
WireConnection;7;1;5;0
WireConnection;8;0;7;1
WireConnection;8;1;9;0
WireConnection;11;0;28;0
WireConnection;11;1;13;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;10;0;8;0
WireConnection;10;1;11;0
WireConnection;36;0;34;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;1;1;5;0
WireConnection;21;0;20;0
WireConnection;18;0;10;0
WireConnection;15;0;14;0
WireConnection;15;1;1;0
WireConnection;15;2;17;0
WireConnection;39;0;37;0
WireConnection;19;0;18;0
WireConnection;19;1;21;0
WireConnection;19;2;20;0
WireConnection;25;0;1;4
WireConnection;25;1;17;4
WireConnection;25;2;19;0
WireConnection;25;3;14;4
WireConnection;25;4;39;0
WireConnection;24;0;15;0
WireConnection;22;0;24;0
WireConnection;22;3;25;0
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=973C7AC996FE24F181D5182E0F63C0BF1D84B5F1