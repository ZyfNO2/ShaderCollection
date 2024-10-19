// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FlowMap溶解"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_Dissolve("Dissolve", Range( 0 , 1)) = 0
		_DissolveTexture("DissolveTexture", 2D) = "white" {}
		_SoftDissolve("SoftDissolve", Range( 0.51 , 1)) = 1
		[Enum(on,0,off,1)]_UseDissOrCD("UseDissOrCD", Float) = 0
		_MaskSub("MaskSub", Range( 0 , 1)) = 1
		_MaskMul("MaskMul", Range( 1 , 5)) = 1.61
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
		Cull Back
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

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _FlowMap;
			uniform float4 _FlowMap_ST;
			uniform float _Dissolve;
			uniform float _UseDissOrCD;
			uniform float _SoftDissolve;
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
				float2 uv_MainTex = i.ase_texcoord1.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_FlowMap = i.ase_texcoord1.xyz.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
				float4 tex2DNode9 = tex2D( _FlowMap, uv_FlowMap );
				float2 appendResult11 = (float2(tex2DNode9.r , tex2DNode9.g));
				float3 texCoord27 = i.ase_texcoord1.xyz;
				texCoord27.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult26 = lerp( _Dissolve , texCoord27.z , _UseDissOrCD);
				float2 lerpResult7 = lerp( uv_MainTex , appendResult11 , lerpResult26);
				float4 tex2DNode1 = tex2D( _MainTex, lerpResult7 );
				float smoothstepResult21 = smoothstep( ( 1.0 - _SoftDissolve ) , _SoftDissolve , ( tex2D( _DissolveTexture, lerpResult7 ).r + 1.0 + ( lerpResult26 * -2.0 ) ));
				float2 texCoord29 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_32_0 = ( 1.0 - distance( texCoord29 , float2( 0.5,0.5 ) ) );
				float4 appendResult5 = (float4((( tex2DNode1 * i.ase_color )).rgb , ( i.ase_color.a * tex2DNode1.a * smoothstepResult21 * saturate( ( ( temp_output_32_0 - _MaskSub ) * _MaskMul ) ) )));
				
				
				finalColor = appendResult5;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
493.3333;72.66667;1656;962;1932.611;-1344.03;1;True;False
Node;AmplifyShaderEditor.SamplerNode;9;-2595.953,38.23481;Inherit;True;Property;_FlowMap;FlowMap;1;0;Create;True;0;0;0;False;0;False;-1;d1c4163019bd9f741880e92f8fd0c1d2;d1c4163019bd9f741880e92f8fd0c1d2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;31;-1127.217,1966.411;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-2808.94,924.0275;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1344.717,1643.711;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-2798.458,742.4601;Inherit;False;Property;_Dissolve;Dissolve;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2660.243,1187.442;Inherit;False;Property;_UseDissOrCD;UseDissOrCD;5;1;[Enum];Create;True;0;2;on;0;off;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;-2336.424,976.314;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-2305.946,-378.1873;Inherit;True;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;30;-833.4164,1776.611;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-2166.699,67.26727;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;32;-534.4165,1780.511;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-612.4166,2050.911;Inherit;False;Property;_MaskSub;MaskSub;6;0;Create;True;0;0;0;False;0;False;1;7.352941;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1571.806,1320.344;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;7;-1697.654,29.0306;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;13;-1464.297,704.3243;Inherit;True;Property;_DissolveTexture;DissolveTexture;3;0;Create;True;0;0;0;False;0;False;-1;82207ba87c96da64eadcaafdd08aa892;82207ba87c96da64eadcaafdd08aa892;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-262.9478,2194.808;Inherit;False;Property;_MaskMul;MaskMul;7;0;Create;True;0;0;0;False;0;False;1.61;1.61;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1014.848,1181.367;Inherit;False;Property;_SoftDissolve;SoftDissolve;4;0;Create;True;0;0;0;False;0;False;1;1;0.51;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-235.611,2029.03;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1339.81,1200.935;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1341.707,944.2318;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;71.05225,1785.808;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;3;-1078.404,259.8122;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-987.7516,730.8237;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1147.426,-22.86632;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;0dc5eba6db49a2d47945cb691deada74;0dc5eba6db49a2d47945cb691deada74;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;23;-706.0488,869.5789;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;38;300.6483,1801.827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-424.2081,814.6609;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-735.1573,-10.83772;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-125.3894,340.8485;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;4;-546.7208,-13.42447;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;37;-247.9478,1786.808;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;105.3009,12.8791;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;412.0626,17.67871;Float;False;True;-1;2;ASEMaterialInspector;100;1;FlowMap溶解;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;26;0;12;0
WireConnection;26;1;27;3
WireConnection;26;2;28;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;11;0;9;1
WireConnection;11;1;9;2
WireConnection;32;0;30;0
WireConnection;7;0;8;0
WireConnection;7;1;11;0
WireConnection;7;2;26;0
WireConnection;13;1;7;0
WireConnection;39;0;32;0
WireConnection;39;1;34;0
WireConnection;17;0;26;0
WireConnection;17;1;18;0
WireConnection;35;0;39;0
WireConnection;35;1;36;0
WireConnection;14;0;13;1
WireConnection;14;1;15;0
WireConnection;14;2;17;0
WireConnection;1;1;7;0
WireConnection;23;0;22;0
WireConnection;38;0;35;0
WireConnection;21;0;14;0
WireConnection;21;1;23;0
WireConnection;21;2;22;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;6;0;3;4
WireConnection;6;1;1;4
WireConnection;6;2;21;0
WireConnection;6;3;38;0
WireConnection;4;0;2;0
WireConnection;37;0;32;0
WireConnection;37;1;34;0
WireConnection;5;0;4;0
WireConnection;5;3;6;0
WireConnection;0;0;5;0
ASEEND*/
//CHKSM=9A21624CEE7F075DECF5DC5B464A30700E5421AB