// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "dingdianpianyichaoyin"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		_SubColor("SubColor", Color) = (0.04205233,0.2807611,0.4245283,1)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseXspeed("NoiseXspeed", Float) = 0
		_NoiseYspeed("NoiseYspeed", Float) = 0
		_Blur1("Blur 1", 2D) = "white" {}
		_LineSpeed("LineSpeed", Vector) = (0,0,0,0)
		_Height("Height", Float) = -0.8
		_Height2("Height2", Range( 1 , 3)) = 0
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
		ZWrite On
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
			#define ASE_NEEDS_VERT_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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

			uniform sampler2D _NoiseTex;
			uniform float _NoiseXspeed;
			uniform float _NoiseYspeed;
			uniform float4 _NoiseTex_ST;
			uniform float _Height2;
			uniform sampler2D _Blur1;
			uniform float2 _LineSpeed;
			uniform float _Height;
			uniform float4 _SubColor;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 appendResult13 = (float2(_NoiseXspeed , _NoiseYspeed));
				float2 uv2_NoiseTex = v.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner11 = ( 1.0 * _Time.y * appendResult13 + uv2_NoiseTex);
				float2 texCoord18 = v.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner19 = ( _SinTime.w * _LineSpeed + texCoord18);
				float4 appendResult25 = (float4(0.0 , 0.0 , ( v.color.a * ( ( (0.0 + (tex2Dlod( _NoiseTex, float4( panner11, 0, 0.0) ).r - 0.0) * (_Height2 - 0.0) / (1.0 - 0.0)) * tex2Dlod( _Blur1, float4( panner19, 0, 0.0) ).r ) + _Height ) ) , 0.0));
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = appendResult25.xyz;
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult4 = lerp( _SubColor , ( tex2DNode1.r * _MainColor ) , tex2DNode1.r);
				float4 appendResult6 = (float4(lerpResult4.rgb , i.ase_color.a));
				
				
				finalColor = appendResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
350;72.66667;1440;826;2875.826;503.9368;2.797437;True;False
Node;AmplifyShaderEditor.RangedFloatNode;14;-2152.633,794.145;Inherit;False;Property;_NoiseXspeed;NoiseXspeed;4;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2165.533,928.3105;Inherit;False;Property;_NoiseYspeed;NoiseYspeed;5;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-2123.939,599.3356;Inherit;False;1;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1871.4,816.0761;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-2092.356,1156.065;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;21;-1994.243,1548.523;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;20;-2014.171,1327.765;Inherit;False;Property;_LineSpeed;LineSpeed;7;0;Create;True;0;0;0;False;0;False;0,0;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;11;-1672.947,607.6711;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;19;-1649.308,1208.189;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1427.61,867.8995;Inherit;False;Property;_Height2;Height2;9;0;Create;True;0;0;0;False;0;False;0;1.509;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1366.208,580.0215;Inherit;True;Property;_NoiseTex;NoiseTex;3;0;Create;True;0;0;0;False;0;False;-1;None;93cbd21496dc7214485e61cd078d7fa7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-1376.302,1175.991;Inherit;True;Property;_Blur1;Blur 1;6;0;Create;True;0;0;0;False;0;False;-1;6fb7e943cac04a0498a9b7ba4df2d9c5;6fb7e943cac04a0498a9b7ba4df2d9c5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;26;-1038.804,631.9232;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-844.3538,884.4298;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1175.254,-273.5298;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;b1a02e8d1d22edf478ea51f863530d06;b1a02e8d1d22edf478ea51f863530d06;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-1028.411,27.18073;Inherit;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.7875229,1.397576,2.828427,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-719.1161,1150.321;Inherit;False;Property;_Height;Height;8;0;Create;True;0;0;0;False;0;False;-0.8;-0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;8;-405.7343,674.5499;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-686.2609,79.17651;Inherit;False;Property;_SubColor;SubColor;2;0;Create;True;0;0;0;False;0;False;0.04205233,0.2807611,0.4245283,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-636.3052,-216.9831;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-466.1649,981.6866;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;-273.5506,-95.14777;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-205.5485,1016.946;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;212.5482,116.5076;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;88.79449,901.9688;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;558.4238,-33.04745;Float;False;True;-1;2;ASEMaterialInspector;100;1;dingdianpianyichaoyin;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;13;0;14;0
WireConnection;13;1;15;0
WireConnection;11;0;9;0
WireConnection;11;2;13;0
WireConnection;19;0;18;0
WireConnection;19;2;20;0
WireConnection;19;1;21;4
WireConnection;10;1;11;0
WireConnection;17;1;19;0
WireConnection;26;0;10;1
WireConnection;26;4;27;0
WireConnection;16;0;26;0
WireConnection;16;1;17;1
WireConnection;2;0;1;1
WireConnection;2;1;3;0
WireConnection;22;0;16;0
WireConnection;22;1;23;0
WireConnection;4;0;5;0
WireConnection;4;1;2;0
WireConnection;4;2;1;1
WireConnection;24;0;8;4
WireConnection;24;1;22;0
WireConnection;6;0;4;0
WireConnection;6;3;8;4
WireConnection;25;2;24;0
WireConnection;0;0;6;0
WireConnection;0;1;25;0
ASEEND*/
//CHKSM=03AF39E37D01F407084ED78AD167C1200FACC274