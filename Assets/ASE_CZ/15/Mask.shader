// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mask"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Fresnel("Fresnel", Vector) = (0,1,5,0)
		[HDR]_FrenselColor("FrenselColor", Color) = (1,1,1,0)
		_TextureSample0("BackTex", 2D) = "white" {}
		_BackUVSpeed("BackUV&Speed", Vector) = (4,4,0.2,0.2)
		_AddTex("AddTex", 2D) = "white" {}
		_AddUVSpeed("AddUV&Speed", Vector) = (1,1,0.2,0.2)
		[HDR]_AddColor("AddColor", Color) = (1,1,1,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseUVSpeed("NoiseUV&Speed", Vector) = (3,3,0.2,0.2)
		_NoiseIntensity("NoiseIntensity", Float) = 0.2
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
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float3 _Fresnel;
			uniform float4 _FrenselColor;
			uniform sampler2D _TextureSample0;
			uniform float4 _BackUVSpeed;
			uniform sampler2D _AddTex;
			uniform float4 _AddUVSpeed;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseUVSpeed;
			uniform float _NoiseIntensity;
			uniform float4 _AddColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
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
			
			fixed4 frag (v2f i , bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV5 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode5 = ( _Fresnel.x + _Fresnel.y * pow( 1.0 - fresnelNdotV5, _Fresnel.z ) );
				float2 appendResult15 = (float2(_BackUVSpeed.z , _BackUVSpeed.w));
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_10_0 = (ase_screenPosNorm).xy;
				float2 appendResult14 = (float2(_BackUVSpeed.x , _BackUVSpeed.y));
				float2 panner12 = ( 1.0 * _Time.y * appendResult15 + ( temp_output_10_0 * appendResult14 ));
				float2 appendResult19 = (float2(_AddUVSpeed.z , _AddUVSpeed.w));
				float2 appendResult18 = (float2(_AddUVSpeed.x , _AddUVSpeed.y));
				float2 panner17 = ( 1.0 * _Time.y * appendResult19 + ( temp_output_10_0 * appendResult18 ));
				float2 appendResult24 = (float2(_NoiseUVSpeed.z , _NoiseUVSpeed.w));
				float2 appendResult23 = (float2(_NoiseUVSpeed.x , _NoiseUVSpeed.y));
				float2 panner22 = ( 1.0 * _Time.y * appendResult24 + ( temp_output_10_0 * appendResult23 ));
				float2 temp_cast_0 = (tex2D( _NoiseTex, panner22 ).r).xx;
				float2 lerpResult29 = lerp( panner17 , temp_cast_0 , _NoiseIntensity);
				float4 switchResult1 = (((ase_vface>0)?(( tex2D( _MainTex, uv_MainTex ) + ( saturate( fresnelNode5 ) * _FrenselColor ) )):(( tex2D( _TextureSample0, panner12 ) + ( tex2D( _AddTex, lerpResult29 ) * _AddColor ) ))));
				
				
				finalColor = switchResult1;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.FresnelNode;5;-1293.401,23.59991;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;4;-1518.963,37.38099;Inherit;False;Property;_Fresnel;Fresnel;1;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;6;-891.8038,39.92239;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-639.7466,82.4017;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-276.7914,69.97988;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-711.022,-163.532;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;d7331457d3260604c8689ac2e0e8e2bd;d7331457d3260604c8689ac2e0e8e2bd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;129.3507,640.9039;Inherit;True;Property;_TextureSample0;BackTex;3;0;Create;False;0;0;0;False;0;False;-1;9c68272ca1b92d8478f8a438cb945e52;9c68272ca1b92d8478f8a438cb945e52;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;9;-1522.75,519.7034;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;10;-1298.75,556.5036;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;12;-131.449,696.9042;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-513.8494,776.9036;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-491.4492,997.7045;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;13;-753.8495,788.1035;Inherit;False;Property;_BackUVSpeed;BackUV&Speed;4;0;Create;True;0;0;0;False;0;False;4,4,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-413.0494,546.5032;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;-621.4271,2145.146;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1003.828,2225.145;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-981.4272,2445.946;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-903.0275,1994.745;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;25;-1243.828,2236.345;Inherit;False;Property;_NoiseUVSpeed;NoiseUV&Speed;9;0;Create;True;0;0;0;False;0;False;3,3,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;29;112.3343,1908.426;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-22.87418,2333.603;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;10;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;962.6069,1526.261;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;33;519.8871,1746.135;Inherit;False;Property;_AddColor;AddColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.7264151,0.7264151,0.7264151,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-907.1604,239.0985;Inherit;False;Property;_FrenselColor;FrenselColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;31;1075.642,1069.488;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1854.969,753.1964;Float;False;True;-1;2;ASEMaterialInspector;100;5;Mask;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;27;392.5927,1485.043;Inherit;True;Property;_AddTex;AddTex;5;0;Create;True;0;0;0;False;0;False;-1;40a57aa63ff8fa74b94d8f399fcb19c9;40a57aa63ff8fa74b94d8f399fcb19c9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;18;-670.1822,1448.537;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-647.7822,1669.338;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;20;-910.1823,1459.737;Inherit;False;Property;_AddUVSpeed;AddUV&Speed;6;0;Create;True;0;0;0;False;0;False;1,1,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-570.864,1218.137;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;17;-287.782,1368.538;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-349.4884,2145.279;Inherit;True;Property;_NoiseTex;NoiseTex;8;0;Create;True;0;0;0;False;0;False;-1;7943642216329c6409b9e28dcb196adb;7943642216329c6409b9e28dcb196adb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwitchByFaceNode;1;1482.092,741.1294;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;5;1;4;1
WireConnection;5;2;4;2
WireConnection;5;3;4;3
WireConnection;6;0;5;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;3;0;2;0
WireConnection;3;1;8;0
WireConnection;11;1;12;0
WireConnection;10;0;9;0
WireConnection;12;0;16;0
WireConnection;12;2;15;0
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;15;0;13;3
WireConnection;15;1;13;4
WireConnection;16;0;10;0
WireConnection;16;1;14;0
WireConnection;22;0;26;0
WireConnection;22;2;24;0
WireConnection;23;0;25;1
WireConnection;23;1;25;2
WireConnection;24;0;25;3
WireConnection;24;1;25;4
WireConnection;26;0;10;0
WireConnection;26;1;23;0
WireConnection;29;0;17;0
WireConnection;29;1;28;1
WireConnection;29;2;30;0
WireConnection;32;0;27;0
WireConnection;32;1;33;0
WireConnection;31;0;11;0
WireConnection;31;1;32;0
WireConnection;0;0;1;0
WireConnection;27;1;29;0
WireConnection;18;0;20;1
WireConnection;18;1;20;2
WireConnection;19;0;20;3
WireConnection;19;1;20;4
WireConnection;21;0;10;0
WireConnection;21;1;18;0
WireConnection;17;0;21;0
WireConnection;17;2;19;0
WireConnection;28;1;22;0
WireConnection;1;0;3;0
WireConnection;1;1;31;0
ASEEND*/
//CHKSM=A102375E83E57187C5220DE9CD1A95234050021E