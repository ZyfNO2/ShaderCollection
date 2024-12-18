// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Diamond"
{
	Properties
	{
		_Color0("Color 0", Color) = (0,0,0,0)
		_RefractTex("RefractTex", CUBE) = "white" {}
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_ReflectIntensity("ReflectIntensity", Float) = 0
		_ReflectStrength("ReflectStrength", Float) = 0
		_RimPower("RimPower", Float) = 0
		_RimScale("RimScale", Float) = 0
		_RimBias("RimBias", Float) = 0
		_RimeColor("RimeColor", Color) = (0,0,0,0)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
	LOD 100
		
		
		Pass
		{
			Name "Unlit"
			Blend DstColor Zero
			ZWrite On
			ZTest LEqual
			Cull Front
			CGPROGRAM
			

			
			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color0;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _ReflectIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float3 normalizedWorldRefl = normalize( ase_worldReflection );
				float4 texCUBENode7 = texCUBE( _ReflectTex, normalizedWorldRefl );
				float4 temp_output_12_0 = ( _Color0 * texCUBE( _RefractTex, normalizedWorldRefl ) * texCUBENode7 * _ReflectIntensity );
				
				
				finalColor = temp_output_12_0;
				return finalColor;
			}
			ENDCG
		}
		
		Pass
		 {
			Name "Second"
			Blend One One
			ZWrite On
			ZTest LEqual
			Cull Back
			CGPROGRAM
		
			
		
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color0;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _ReflectIntensity;
			uniform float _ReflectStrength;
			uniform float _RimPower;
			uniform float _RimScale;
			uniform float _RimBias;
			uniform float4 _RimeColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float3 normalizedWorldRefl = normalize( ase_worldReflection );
				float4 texCUBENode7 = texCUBE( _ReflectTex, normalizedWorldRefl );
				float4 temp_output_12_0 = ( _Color0 * texCUBE( _RefractTex, normalizedWorldRefl ) * texCUBENode7 * _ReflectIntensity );
				float dotResult20 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult22 = clamp( dotResult20 , 0.0 , 1.0 );
				float saferPower24 = abs( ( 1.0 - clampResult22 ) );
				
				
				finalColor = ( temp_output_12_0 + ( texCUBENode7 * _ReflectStrength * ( ( ( pow( saferPower24 , _RimPower ) * _RimScale ) + _RimBias ) * _RimeColor ) ) );
				return finalColor;
			}
			ENDCG
		}
		/*ase_endpass*/
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-310.3805,-572.9005;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-193.7022,35.92107;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-466.7024,68.42101;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-875.8016,122.8208;Inherit;False;Property;_ReflectStrength;ReflectStrength;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;-38.23367,-568.4167;Float;False;True;-1;2;ASEMaterialInspector;100;18;Diamond;48f96a7520efa5d438ba0cd616b8deb2;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Transparent=RenderType;False;False;0;True;True;1;2;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;True;0;False;;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;-32.29767,-462.9905;Float;False;False;-1;2;ASEMaterialInspector;100;18;New Amplify Shader;48f96a7520efa5d438ba0cd616b8deb2;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;False;False;0;False;True;4;1;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;True;0;False;;False;False;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.OneMinusNode;23;-2122.146,121.9524;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-1888.548,171.5527;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1657.619,226.7523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2062.948,333.1522;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;0;False;0;False;0;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1487.951,298.9087;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1849.319,325.252;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;0;False;0;False;0;40.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1687.951,397.9086;Inherit;False;Property;_RimBias;RimBias;7;0;Create;True;0;0;0;False;0;False;0;14.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;18;-2977.47,-143.1338;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;20;-2651.169,46.66622;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;21;-2995.669,192.2659;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;22;-2388.569,55.76632;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-1575.951,495.9088;Inherit;False;Property;_RimeColor;RimeColor;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6037736,0.5827157,0.4300463,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1293.273,369.2221;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldReflectionVector;13;-1363.837,-697.6502;Inherit;True;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;6;-1080.145,-760.6506;Inherit;True;Property;_RefractTex;RefractTex;1;0;Create;True;0;0;0;False;0;False;-1;None;a9f053d430424adb925523ba78342596;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1082.677,-524.7164;Inherit;True;Property;_ReflectTex;ReflectTex;2;0;Create;True;0;0;0;False;0;False;-1;None;5e6d2cc25beb34a998784c5dc7e8fe9c;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-692.7309,-891.0557;Inherit;False;Property;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9528302,0.9528302,0.9528302,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-670.3192,-404.5233;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;3;0;Create;True;0;0;0;False;0;False;0;1.02;0;0;0;1;FLOAT;0
WireConnection;12;0;4;0
WireConnection;12;1;6;0
WireConnection;12;2;7;0
WireConnection;12;3;14;0
WireConnection;15;0;12;0
WireConnection;15;1;16;0
WireConnection;16;0;7;0
WireConnection;16;1;17;0
WireConnection;16;2;30;0
WireConnection;2;0;12;0
WireConnection;3;0;15;0
WireConnection;23;0;22;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
WireConnection;26;1;27;0
WireConnection;28;0;26;0
WireConnection;28;1;29;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;22;0;20;0
WireConnection;30;0;28;0
WireConnection;30;1;31;0
WireConnection;6;1;13;0
WireConnection;7;1;13;0
ASEEND*/
//CHKSM=13972F0709A6F1E914F8EE53DD97F4E9D0A53282