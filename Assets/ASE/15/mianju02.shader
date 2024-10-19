// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cz_wang/mianju02"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Fresnel("Fresnel", Vector) = (0,1,5,0)
		[HDR]_FresnelColor("FresnelColor", Color) = (1,1,1,0)
		_BackTex("BackTex", 2D) = "white" {}
		_BackUV_Speed("BackUV_Speed", Vector) = (3,3,0.2,0.2)
		_AddTex("AddTex", 2D) = "white" {}
		_AddUV_Speed("AddUV_Speed", Vector) = (1,1,0.2,0.2)
		[HDR]_AddColor("AddColor", Color) = (1,1,1,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseUV_Speed("NoiseUV_Speed", Vector) = (3,3,0.2,0.2)
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
			uniform float4 _FresnelColor;
			uniform sampler2D _BackTex;
			uniform float4 _BackUV_Speed;
			uniform sampler2D _AddTex;
			uniform float4 _AddUV_Speed;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseUV_Speed;
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
			
			fixed4 frag (v2f i , half ase_vface : VFACE) : SV_Target
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
				float fresnelNdotV6 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode6 = ( _Fresnel.x + _Fresnel.y * pow( 1.0 - fresnelNdotV6, _Fresnel.z ) );
				float2 appendResult16 = (float2(_BackUV_Speed.z , _BackUV_Speed.w));
				float4 screenPos = i.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_11_0 = (ase_screenPosNorm).xy;
				float2 appendResult15 = (float2(_BackUV_Speed.x , _BackUV_Speed.y));
				float2 panner13 = ( 1.0 * _Time.y * appendResult16 + ( temp_output_11_0 * appendResult15 ));
				float2 appendResult24 = (float2(_AddUV_Speed.z , _AddUV_Speed.w));
				float2 appendResult23 = (float2(_AddUV_Speed.x , _AddUV_Speed.y));
				float2 panner22 = ( 1.0 * _Time.y * appendResult24 + ( temp_output_11_0 * appendResult23 ));
				float2 appendResult29 = (float2(_NoiseUV_Speed.z , _NoiseUV_Speed.w));
				float2 appendResult28 = (float2(_NoiseUV_Speed.x , _NoiseUV_Speed.y));
				float2 panner27 = ( 1.0 * _Time.y * appendResult29 + ( temp_output_11_0 * appendResult28 ));
				float2 temp_cast_0 = (tex2D( _NoiseTex, panner27 ).r).xx;
				float2 lerpResult34 = lerp( panner22 , temp_cast_0 , _NoiseIntensity);
				float4 switchResult1 = (((ase_vface>0)?(( tex2D( _MainTex, uv_MainTex ) + ( saturate( fresnelNode6 ) * _FresnelColor ) )):(( tex2D( _BackTex, panner13 ) + ( tex2D( _AddTex, lerpResult34 ) * _AddColor ) ))));
				
				
				finalColor = switchResult1;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
387;86;1666;1267;3860.941;-361.9814;1.965414;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;10;-2966.031,765.6976;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;31;-2828.546,2047.488;Inherit;False;Property;_NoiseUV_Speed;NoiseUV_Speed;9;0;Create;True;0;0;0;False;0;False;3,3,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;-2720.534,766.2156;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-2563.546,2016.488;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;26;-2381.856,1448.257;Inherit;False;Property;_AddUV_Speed;AddUV_Speed;6;0;Create;True;0;0;0;False;0;False;1,1,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2394.546,1896.488;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-2572.546,2146.488;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-2116.856,1417.257;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-2125.856,1547.257;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;27;-2172.199,1910.802;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;14;-2214.625,918.4343;Inherit;False;Property;_BackUV_Speed;BackUV_Speed;4;0;Create;True;0;0;0;False;0;False;3,3,0.2,0.2;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1947.856,1297.257;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;5;-2201.872,-0.2514038;Inherit;False;Property;_Fresnel;Fresnel;1;0;Create;True;0;0;0;False;0;False;0,1,5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;22;-1725.509,1311.572;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;32;-1855.991,1885.432;Inherit;True;Property;_NoiseTex;NoiseTex;8;0;Create;True;0;0;0;False;0;False;-1;72105e201951b3e4880cc3dd97797249;72105e201951b3e4880cc3dd97797249;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;15;-1949.625,887.4343;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1733.646,2148.719;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;10;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;6;-1925.872,-17.2514;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1780.625,767.4343;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1958.625,1017.434;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;34;-1417.646,1889.719;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;13;-1558.278,781.7488;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-1181.448,1859.617;Inherit;True;Property;_AddTex;AddTex;5;0;Create;True;0;0;0;False;0;False;-1;8bdbef44c4848774986e23b1f24bce72;8bdbef44c4848774986e23b1f24bce72;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-1549.872,160.7486;Inherit;False;Property;_FresnelColor;FresnelColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;38;-1003.636,2172.602;Inherit;False;Property;_AddColor;AddColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;7;-1584.872,-8.251404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1304.872,-4.251404;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1312.872,-385.2514;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;b4a955bd8224aca4385d11baac24d3eb;b4a955bd8224aca4385d11baac24d3eb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-1037.404,757.4005;Inherit;True;Property;_BackTex;BackTex;3;0;Create;True;0;0;0;False;0;False;-1;7dad2b8decbed5643a2502cc5d3a6cad;7dad2b8decbed5643a2502cc5d3a6cad;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-692.6357,1894.602;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-842.5724,-20.65142;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-400.2236,798.6062;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;1;39.48492,87.0499;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;533.9863,81.28445;Float;False;True;-1;2;ASEMaterialInspector;100;1;Cz_wang/mianju02;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;11;0;10;0
WireConnection;28;0;31;1
WireConnection;28;1;31;2
WireConnection;30;0;11;0
WireConnection;30;1;28;0
WireConnection;29;0;31;3
WireConnection;29;1;31;4
WireConnection;23;0;26;1
WireConnection;23;1;26;2
WireConnection;24;0;26;3
WireConnection;24;1;26;4
WireConnection;27;0;30;0
WireConnection;27;2;29;0
WireConnection;25;0;11;0
WireConnection;25;1;23;0
WireConnection;22;0;25;0
WireConnection;22;2;24;0
WireConnection;32;1;27;0
WireConnection;15;0;14;1
WireConnection;15;1;14;2
WireConnection;6;1;5;1
WireConnection;6;2;5;2
WireConnection;6;3;5;3
WireConnection;17;0;11;0
WireConnection;17;1;15;0
WireConnection;16;0;14;3
WireConnection;16;1;14;4
WireConnection;34;0;22;0
WireConnection;34;1;32;1
WireConnection;34;2;35;0
WireConnection;13;0;17;0
WireConnection;13;2;16;0
WireConnection;33;1;34;0
WireConnection;7;0;6;0
WireConnection;8;0;7;0
WireConnection;8;1;9;0
WireConnection;12;1;13;0
WireConnection;37;0;33;0
WireConnection;37;1;38;0
WireConnection;4;0;2;0
WireConnection;4;1;8;0
WireConnection;36;0;12;0
WireConnection;36;1;37;0
WireConnection;1;0;4;0
WireConnection;1;1;36;0
WireConnection;0;0;1;0
ASEEND*/
//CHKSM=9C2276673E34155562D80B8D430051097ED6A224