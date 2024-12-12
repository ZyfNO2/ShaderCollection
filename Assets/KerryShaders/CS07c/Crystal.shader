// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Crystal"
{
	Properties
	{
		[HDR]_RimColor("RimColor", Color) = (0,0,0,0)
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 1
		_NormalMap("NormalMap", 2D) = "white" {}
		_EmissMask("EmissMask", 2D) = "black" {}
		_TextureSample0("Texture Sample 0", CUBE) = "black" {}
		_InsideTex("InsideTex", 2D) = "white" {}
		_RefelctIntensity(" RefelctIntensity", Float) = 1
		_TillingOffset("TillingOffset", Vector) = (1.65,1.75,0.66,-1.63)
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_UVDistort("UVDistort", Float) = 0
		[HDR]_InsideOffset("InsideOffset", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldRefl;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform samplerCUBE _TextureSample0;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RefelctIntensity;
		uniform sampler2D _EmissMask;
		uniform float4 _EmissMask_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform sampler2D _InsideTex;
		uniform float3 _Vector0;
		uniform float4 _TillingOffset;
		uniform float _UVDistort;
		uniform float4 _InsideOffset;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 NormalMap23 = tex2D( _NormalMap, uv_NormalMap );
			float3 WorldNormal26 = (WorldNormalVector( i , NormalMap23.rgb ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult32 = dot( WorldNormal26 , ase_worldViewDir );
			float clampResult34 = clamp( ( 1.0 - dotResult32 ) , 0.0 , 1.0 );
			float FresnelFactor35 = clampResult34;
			float4 ReflectColor21 = ( texCUBE( _TextureSample0, WorldReflectionVector( i , NormalMap23.rgb ) ) * _RefelctIntensity * ( FresnelFactor35 * FresnelFactor35 ) );
			float2 uv_EmissMask = i.uv_texcoord * _EmissMask_ST.xy + _EmissMask_ST.zw;
			float fresnelNdotV1 = dot( WorldNormal26, ase_worldViewDir );
			float fresnelNode1 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV1, _RimPower ) );
			float clampResult77 = clamp( ( tex2D( _EmissMask, uv_EmissMask ).r + fresnelNode1 ) , 0.0 , 1.0 );
			float4 RimColor13 = ( clampResult77 * _RimColor );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView57 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView58 = mul( UNITY_MATRIX_MV, float4( _Vector0, 1 ) ).xyz;
			float3 worldToViewDir66 = mul( UNITY_MATRIX_V, float4( WorldNormal26, 0 ) ).xyz;
			float4 lerpResult68 = lerp( tex2D( _InsideTex, ( ( ( (( objToView57 - objToView58 )).xy * (_TillingOffset).xy ) + (_TillingOffset).zw ) + ( (worldToViewDir66).xy * _UVDistort ) ) ) , _InsideOffset , FresnelFactor35);
			float4 InsideColor45 = lerpResult68;
			o.Emission = ( ReflectColor21 + RimColor13 + InsideColor45 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;40;1163.364,-840.6909;Inherit;False;708.5483;494.0763;Comment;5;10;24;2;23;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-986.924,-1205.832;Inherit;False;2129.196;853.6173;InsideColor;22;51;50;52;49;55;57;58;59;48;60;42;45;53;63;64;62;65;61;66;68;69;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-971.0775,583.1578;Inherit;False;1448.302;685.077;RefectCOlor;14;37;36;35;19;34;28;33;32;31;25;17;22;18;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1005.801,-332.2409;Inherit;False;1454.223;864.8344;RimColor;12;1;3;9;4;6;7;12;8;11;13;27;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-624.272,211.171;Inherit;False;Property;_RimBias;RimBias;1;0;Create;True;0;0;0;False;0;False;0;-0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-651.2719,296.1711;Inherit;False;Property;_RimScale;RimScale;2;0;Create;True;0;0;0;False;0;False;1;1.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-665.2719,375.1711;Inherit;False;Property;_RimPower;RimPower;3;0;Create;True;0;0;0;False;0;False;1;3.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;129.5668,777.5548;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;22;-252.9556,619.0242;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;076c902df4c87d4438d2b9d02ad9471a;True;0;False;black;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldReflectionVector;17;-492.7787,636.3422;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;27;-621.2329,-27.5296;Inherit;False;26;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;33;-491.2031,1041.271;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-229.6311,845.0613;Inherit;False;Property;_RefelctIntensity; RefelctIntensity;8;0;Create;True;0;0;0;False;0;False;1;2.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;1222.67,-523.6134;Inherit;False;23;NormalMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;273.7577,717.8597;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1133.182,49.403;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Crystal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;921.6245,577.8538;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;696.7533,662.8052;Inherit;False;13;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;707.851,410.7189;Inherit;False;21;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;667.6315,163.7076;Inherit;False;45;InsideColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;10;1213.364,-790.6909;Inherit;True;Property;_NormalMap;NormalMap;4;0;Create;True;0;0;0;False;0;False;-1;None;36e7fa286bfb1dd419b7fb7ffdcb4539;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;51;-633.7004,-831.2755;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-275.5662,-860.0651;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;52;-410.9148,-664.7667;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;49;-928.9313,-761.8143;Inherit;False;Property;_TillingOffset;TillingOffset;9;0;Create;True;0;0;0;False;0;False;1.65,1.75,0.66,-1.63;1.26,0.59,0.59,0.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;55;-900.9641,-1155.832;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;57;-666.9639,-1151.832;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;58;-676.9233,-989.5471;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;59;-936.9235,-976.5472;Inherit;False;Property;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;0,0,0;-0.05,0.12,0.08;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;48;-259.5662,-1037.064;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-432.9224,-1000.547;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;918.2717,-712.2869;Inherit;False;InsideColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;51.48394,-838.0454;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;254.6156,-729.6362;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;135.0481,-468.2151;Inherit;False;Property;_UVDistort;UVDistort;11;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;62;115.6156,-575.6357;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;279.048,-552.2155;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-366.384,-578.6357;Inherit;False;26;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;66;-136.8574,-566.1364;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;42;473.1342,-761.297;Inherit;True;Property;_InsideTex;InsideTex;7;0;Create;True;0;0;0;False;0;False;-1;None;fc1cc1e499b8a764b8210bad1910bde3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;68;802.303,-614.4794;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;833.0002,-416.2287;Inherit;False;35;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;1675.281,-536.0025;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;1670.384,-737.8647;Inherit;False;NormalMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;2;1447.138,-523.7068;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;11;-423.7549,-282.241;Inherit;True;Property;_EmissMask;EmissMask;5;0;Create;True;0;0;0;False;0;False;-1;None;552850bf9edd62946b8f963827752293;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-375.4664,320.593;Inherit;False;Property;_RimColor;RimColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.1509434,0.03061588,0.1195896,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;69;534.9852,-563.3176;Inherit;False;Property;_InsideOffset;InsideOffset;12;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.9056599,0.3374864,0.3374864,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;31;-900.3931,1082.631;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;32;-695.8023,991.9699;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;34;-279.9226,1096.928;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-258.9355,992.4976;Inherit;False;35;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-965.8685,864.4365;Inherit;True;26;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-728.5498,634.1006;Inherit;True;23;NormalMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-29.68034,970.2104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-12.90714,1110.835;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-682.2719,54.17084;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;348.4215,104.8009;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;149.2589,88.74243;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;1;-425.2719,-4.828899;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-162.4766,-68.29621;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;77;89.48169,-86.68823;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;18;0;22;0
WireConnection;18;1;19;0
WireConnection;18;2;37;0
WireConnection;22;1;17;0
WireConnection;17;0;25;0
WireConnection;33;0;32;0
WireConnection;21;0;18;0
WireConnection;0;2;39;0
WireConnection;39;0;15;0
WireConnection;39;1;38;0
WireConnection;39;2;46;0
WireConnection;51;0;49;0
WireConnection;50;0;48;0
WireConnection;50;1;51;0
WireConnection;52;0;49;0
WireConnection;57;0;55;0
WireConnection;58;0;59;0
WireConnection;48;0;60;0
WireConnection;60;0;57;0
WireConnection;60;1;58;0
WireConnection;45;0;68;0
WireConnection;53;0;50;0
WireConnection;53;1;52;0
WireConnection;63;0;53;0
WireConnection;63;1;65;0
WireConnection;62;0;66;0
WireConnection;65;0;62;0
WireConnection;65;1;64;0
WireConnection;66;0;61;0
WireConnection;42;1;63;0
WireConnection;68;0;42;0
WireConnection;68;1;69;0
WireConnection;68;2;70;0
WireConnection;26;0;2;0
WireConnection;23;0;10;0
WireConnection;2;0;24;0
WireConnection;32;0;28;0
WireConnection;32;1;31;0
WireConnection;34;0;33;0
WireConnection;37;0;36;0
WireConnection;37;1;36;0
WireConnection;35;0;34;0
WireConnection;13;0;8;0
WireConnection;8;0;77;0
WireConnection;8;1;9;0
WireConnection;1;0;27;0
WireConnection;1;4;3;0
WireConnection;1;1;4;0
WireConnection;1;2;6;0
WireConnection;1;3;7;0
WireConnection;12;0;11;1
WireConnection;12;1;1;0
WireConnection;77;0;12;0
ASEEND*/
//CHKSM=C83C48B3F8A12F00EA57D9AD60AACF4145D8E30F