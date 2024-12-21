// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nyx_Body"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "white" {}
		_RimPower("RimPower", Float) = 5
		[HDR]_RimColor("RimColor", Color) = (0.9245283,0.7537616,0.1439124,0)
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_EmissMap("EmissMap", 2D) = "white" {}
		_TillingSpeed("TillingSpeed", Vector) = (1,1,0,0)
		_FlowLightColor("FlowLightColor", Color) = (0.7169812,0.5917394,0.1657174,0)
		_FlowRimScale("FlowRimScale", Float) = 2
		_FlowRimBias("FlowRimBias", Float) = 0
		_NebulaTex("NebulaTex", 2D) = "white" {}
		_NebulaTilling("NebulaTilling", Vector) = (1,1,0,0)
		_NebulaDistort("NebulaDistort", Float) = 0
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimPower;
		uniform float _RimScale;
		uniform float _RimBias;
		uniform float4 _RimColor;
		uniform sampler2D _EmissMap;
		uniform float4 _TillingSpeed;
		uniform float4 _FlowLightColor;
		uniform float _FlowRimScale;
		uniform float _FlowRimBias;
		uniform sampler2D _NebulaTex;
		uniform float _NebulaDistort;
		uniform float2 _NebulaTilling;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 WorldNormal6 = normalize( (WorldNormalVector( i , tex2D( _NormalMap, uv_NormalMap ).rgb )) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult3 = dot( WorldNormal6 , ase_worldViewDir );
			float NdotV4 = dotResult3;
			float clampResult11 = clamp( NdotV4 , 0.0 , 1.0 );
			float4 RimColor23 = ( ( ( pow( ( 1.0 - clampResult11 ) , _RimPower ) * _RimScale ) + _RimBias ) * _RimColor );
			float3 objToWorld28 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner34 = ( 1.0 * _Time.y * (_TillingSpeed).zw + ( ( (0.0 + (( 1.0 - NdotV4 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) + (( ase_worldPos - objToWorld28 )).xy ) * (_TillingSpeed).xy ));
			float4 tex2DNode36 = tex2D( _EmissMap, panner34 );
			float FlowLight37 = tex2DNode36.r;
			float4 FlowLightColor47 = ( FlowLight37 * _FlowLightColor * ( ( ( 1.0 - NdotV4 ) * _FlowRimScale ) + _FlowRimBias ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView65 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView67 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 worldToViewDir75 = normalize( mul( UNITY_MATRIX_V, float4( WorldNormal6, 0 ) ).xyz );
			float4 NebulaColor73 = tex2D( _NebulaTex, ( ( (( objToView65 - objToView67 )).xy + ( (worldToViewDir75).xy * _NebulaDistort ) ) * _NebulaTilling ) );
			float4 saferPower85 = abs( NebulaColor73 );
			o.Emission = ( ( RimColor23 + FlowLightColor47 + ( NebulaColor73 * FlowLight37 ) ) + ( pow( saferPower85 , 5.0 ) * pow( FlowLight37 , 1.0 ) * 10.0 ) ).rgb;
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
Node;AmplifyShaderEditor.CommentaryNode;80;-1425.78,1898.67;Inherit;False;1798.32;891.8096;NebulaColor;15;63;66;65;67;68;71;73;74;75;76;77;78;69;79;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-1417.47,1233.112;Inherit;False;1372.873;653.1056;Comment;10;45;46;44;49;51;53;50;52;55;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1430.994,415.9149;Inherit;False;1976.353;806.994;Comment;16;40;30;41;32;37;36;35;34;33;29;28;27;26;57;58;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-1412.386,-175.0447;Inherit;False;1767.034;579.5511;Comment;12;22;19;20;17;18;16;15;14;12;11;10;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;9;-1408.04,-601.7651;Inherit;False;749.5258;403.6017;NdotV;4;3;4;2;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;7;-678.0791,-488.4439;Inherit;False;838.327;280;NormalMap;3;5;1;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1105.514,-475.3861;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-1358.04,-386.1635;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;8;-1318.944,-551.7651;Inherit;False;6;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-882.5146,-456.3861;Inherit;True;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-1362.386,-125.0447;Inherit;False;4;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;11;-1146.026,-98.52319;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-460.5605,-28.32379;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-226.5605,15.67621;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-67.56055,89.67621;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;82.38583,61.78798;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;412.7646,-1022.899;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Nyx_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-464.5605,135.6762;Inherit;False;Property;_RimBias;RimBias;3;0;Create;True;0;0;0;False;0;False;0;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-13.05223,-396.0097;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-433.9931,559.1652;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-479.1517,1450.557;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;-904.5291,1415.535;Inherit;False;Property;_FlowLightColor;FlowLightColor;7;0;Create;True;0;0;0;False;0;False;0.7169812,0.5917394,0.1657174,0;0.3301886,0.2629408,0.1448469,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1367.47,1616.218;Inherit;False;4;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-945.4687,1666.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-762.4692,1699.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1202.47,1624.218;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1151.47,1718.218;Inherit;False;Property;_FlowRimScale;FlowRimScale;8;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-979.4686,1770.217;Inherit;False;Property;_FlowRimBias;FlowRimBias;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;-320.8228,202.4631;Inherit;False;Property;_RimColor;RimColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0.9245283,0.7537616,0.1439124,0;0.7169812,0.5786513,0.2130652,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-628.0791,-438.444;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;0;False;0;False;-1;None;ba90be7587624144993a093ab48b4f97;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;34;-256.4933,565.7661;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-269.5973,1469.979;Inherit;False;FlowLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-902.9514,1294.813;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-67.99282,568.3652;Inherit;True;Property;_EmissMap;EmissMap;5;0;Create;True;0;0;0;False;0;False;-1;None;8fb9e9053de2e2746a5a29ec8f128c39;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;393.5065,620.3649;Inherit;False;FlowLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-583.5605,96.67621;Inherit;False;Property;_RimScale;RimScale;4;0;Create;True;0;0;0;False;0;False;1;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-796.5605,58.67621;Inherit;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;0;False;0;False;5;8.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;14;-680.5605,-63.32379;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-233.5621,-409.843;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;63;-1375.78,1948.67;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-754.9803,2070.266;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;65;-1076.58,1966.269;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;67;-1067.98,2229.666;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;68;-565.67,2094.089;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;71;-168.4605,2071.785;Inherit;True;Property;_NebulaTex;NebulaTex;10;0;Create;True;0;0;0;False;0;False;-1;None;fdb40b351944e7640b0ad5183a13fb71;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;148.5396,2123.785;Inherit;False;NebulaColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1152.703,2511.18;Inherit;False;6;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;75;-847.2881,2521.971;Inherit;False;World;View;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;76;-594.0954,2557.476;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-415.0956,2578.476;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-643.0954,2674.476;Inherit;False;Property;_NebulaDistort;NebulaDistort;12;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-261.4398,2120.829;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-397.0956,2099.476;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;70;-346.4603,2236.785;Inherit;False;Property;_NebulaTilling;NebulaTilling;11;0;Create;True;0;0;0;False;0;False;1,1;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;61;210.8573,741.1951;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;33;-711.1657,965.712;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;35;-709.8658,1082.712;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;32;-900.9657,960.5121;Inherit;False;Property;_TillingSpeed;TillingSpeed;6;0;Create;True;0;0;0;False;0;False;1,1,0,0;0.5,0.5,0.1,0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;26;-1438.041,615.2586;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;-1149.541,697.1584;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;28;-1425.247,805.3088;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;29;-872.7578,774.4032;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;12;-941.2167,-100.2489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1253.773,503.4144;Inherit;False;4;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-1090.428,509.2647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;57;-939.3346,510.0143;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-686.9014,505.9045;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-64.81517,-1765.151;Inherit;False;47;FlowLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;173.8866,-1818.582;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-70.23187,-1925.692;Inherit;False;23;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;49.17708,-1525.8;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-164.2081,-1646.849;Inherit;True;73;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-165.0314,-1451.187;Inherit;True;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;87;-340.6364,-982.9076;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;85;-468.8118,-1175.371;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-684.9576,-1203.474;Inherit;True;73;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-640.8533,-1008.646;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-177.1448,-1026.627;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-145.7858,-870.6417;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;228.765,-1039.211;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;3;0;8;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;11;0;10;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;18;0;16;0
WireConnection;18;1;19;0
WireConnection;20;0;18;0
WireConnection;20;1;22;0
WireConnection;23;0;20;0
WireConnection;0;2;89;0
WireConnection;6;0;1;0
WireConnection;30;0;41;0
WireConnection;30;1;33;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;45;2;53;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;53;0;51;0
WireConnection;53;1;55;0
WireConnection;50;0;49;0
WireConnection;34;0;30;0
WireConnection;34;2;35;0
WireConnection;47;0;45;0
WireConnection;36;1;34;0
WireConnection;37;0;36;1
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;1;0;5;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;65;0;63;0
WireConnection;68;0;66;0
WireConnection;71;1;69;0
WireConnection;73;0;71;0
WireConnection;75;0;74;0
WireConnection;76;0;75;0
WireConnection;77;0;76;0
WireConnection;77;1;78;0
WireConnection;69;0;79;0
WireConnection;69;1;70;0
WireConnection;79;0;68;0
WireConnection;79;1;77;0
WireConnection;61;0;36;1
WireConnection;33;0;32;0
WireConnection;35;0;32;0
WireConnection;27;0;26;0
WireConnection;27;1;28;0
WireConnection;29;0;27;0
WireConnection;12;0;11;0
WireConnection;58;0;40;0
WireConnection;57;0;58;0
WireConnection;41;0;57;0
WireConnection;41;1;29;0
WireConnection;62;0;25;0
WireConnection;62;1;48;0
WireConnection;62;2;82;0
WireConnection;82;0;39;0
WireConnection;82;1;81;0
WireConnection;87;0;84;0
WireConnection;85;0;83;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;86;2;88;0
WireConnection;89;0;62;0
WireConnection;89;1;86;0
ASEEND*/
//CHKSM=814AC7A8A9252CD078D3DBA753D693A330DB0BAD