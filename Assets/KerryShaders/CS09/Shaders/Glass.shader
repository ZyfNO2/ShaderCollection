// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Glass"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_Matcap1("Matcap", 2D) = "white" {}
		_RefractIntensity("RefractIntensity", Float) = 1
		_RefractColor("RefractColor", Color) = (0,0,0,0)
		_ObjectPivotOffset("ObjectPivotOffset", Range( 1 , 3)) = 0
		_ObjectHeight("ObjectHeight", Range( -1 , 1)) = 0
		_ThickMap("ThickMap", 2D) = "white" {}
		_DirtyMask("DirtyMask", 2D) = "black" {}
		_Max("Max", Float) = 1
		_Min("Min", Float) = 0
		_Decal("Decal", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
		};

		uniform sampler2D _Matcap;
		uniform float4 _RefractColor;
		uniform sampler2D _Matcap1;
		uniform float _Min;
		uniform float _Max;
		uniform sampler2D _ThickMap;
		uniform float _ObjectPivotOffset;
		uniform float _ObjectHeight;
		uniform sampler2D _DirtyMask;
		uniform float4 _DirtyMask_ST;
		uniform float _RefractIntensity;
		uniform sampler2D _Decal;
		uniform float4 _Decal_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView14 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult15 = normalize( objToView14 );
			float3 ase_worldNormal = i.worldNormal;
			float3 break17 = cross( normalizeResult15 , mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz );
			float2 appendResult18 = (float2(-break17.y , break17.x));
			float2 MatcapUVPro24 = ((appendResult18).xy*0.5 + 0.5);
			float4 tex2DNode1 = tex2D( _Matcap, MatcapUVPro24 );
			float dotResult28 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult31 = smoothstep( _Min , _Max , dotResult28);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld52 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult58 = (float2(0.5 , ( ( ( ase_worldPos.y - objToWorld52.y ) - _ObjectPivotOffset ) / _ObjectHeight )));
			float2 uv_DirtyMask = i.uv_texcoord * _DirtyMask_ST.xy + _DirtyMask_ST.zw;
			float clampResult62 = clamp( ( ( 1.0 - smoothstepResult31 ) + tex2D( _ThickMap, appendResult58 ).r + tex2D( _DirtyMask, uv_DirtyMask ).a ) , 0.0 , 1.0 );
			float Thickness43 = clampResult62;
			float temp_output_33_0 = ( Thickness43 * _RefractIntensity );
			float4 lerpResult42 = lerp( ( _RefractColor * 0.5 ) , ( _RefractColor * tex2D( _Matcap1, ( MatcapUVPro24 + temp_output_33_0 ) ) ) , temp_output_33_0);
			float2 uv_Decal = i.uv_texcoord * _Decal_ST.xy + _Decal_ST.zw;
			float4 tex2DNode65 = tex2D( _Decal, uv_Decal );
			float4 lerpResult66 = lerp( ( tex2DNode1 + lerpResult42 ) , tex2DNode65 , tex2DNode65.a);
			o.Emission = lerpResult66.rgb;
			float clampResult38 = clamp( ( tex2DNode65.a + max( tex2DNode1.r , Thickness43 ) ) , 0.0 , 1.0 );
			o.Alpha = clampResult38;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
Node;AmplifyShaderEditor.CommentaryNode;47;-1015.211,159.3719;Inherit;False;485.9995;279.137;reflcet;3;33;34;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2674.227,-230.7737;Inherit;False;1515.57;1066.609;Thickness;18;43;32;31;30;29;28;52;53;55;56;57;58;59;60;61;62;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2669.55,-869.1683;Inherit;False;1972.731;634.5211;BetterMatcapUV;13;10;12;14;13;15;16;17;18;20;19;21;11;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-2662.353,-1273.216;Inherit;False;1190.843;397.9998;MatcapUV;6;3;2;4;5;6;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;5;-2179.353,-1114.216;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-1982.354,-1110.216;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2347.353,-1122.216;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2647.552,-1151.015;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;4;-2592.951,-981.6168;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2354.551,-481.6473;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;15;-2053.924,-646.2419;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-1634.019,-522.7409;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1329.817,-509.7403;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;19;-1484.517,-453.8398;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1695.509,-1066.916;Inherit;False;MatcapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;20;-1177.302,-526.134;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;21;-1050.687,-541.6005;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-855.42,-522.2328;Inherit;False;MatcapUVPro;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;12;-2561.073,-509.2316;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-2619.87,-407.2036;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;16;-1891.194,-566.5374;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-2663.012,-828.3896;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;14;-2411.872,-714.3043;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;26;-846.9067,-51.84023;Inherit;False;24;MatcapUVPro;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-2228.227,-101.7741;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;29;-2624.227,-180.7741;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2617.227,-6.774183;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-2024.227,-68.77407;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1835.531,-40.88803;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-691.2112,243.5095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-965.2107,322.5089;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;0;False;0;False;1;0.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-861.7983,209.3719;Inherit;False;43;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-405.3782,-536.7935;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;0;False;0;False;-1;None;84499eff608172f47ae2e80b811b51a4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-603.7397,-62.20749;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;51;-2591.988,265.1487;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-2375.131,312.2915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-2135.378,416.005;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;56;-1903.706,483.3517;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;52;-2618.926,424.087;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;55;-2360.315,538.5758;Inherit;False;Property;_ObjectPivotOffset;ObjectPivotOffset;5;0;Create;True;0;0;0;False;0;False;0;2.657;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2136.726,605.9225;Inherit;False;Property;_ObjectHeight;ObjectHeight;6;0;Create;True;0;0;0;False;0;False;0;0.459;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1538.365,104.3004;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;58;-1994.247,290.8568;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;59;-1854.321,123.1287;Inherit;True;Property;_ThickMap;ThickMap;7;0;Create;True;0;0;0;False;0;False;-1;None;234a6578ffbcc0744b263e2c6bcb62ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1262.958,20.92477;Inherit;False;Thickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;62;-1366.187,161.9637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;-1642.368,540.6383;Inherit;True;Property;_DirtyMask;DirtyMask;8;0;Create;True;0;0;0;False;0;False;-1;3a507ea5b7fcce841b9f385795e736ad;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-2276.993,14.32916;Inherit;False;Property;_Min;Min;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2250.993,109.3292;Inherit;False;Property;_Max;Max;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1023.282,-256.1458;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ClampOpNode;38;748.0277,-168.8964;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;547.8526,-105.0709;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;66;729.7272,-577.194;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-361.3328,-313.9346;Inherit;False;Property;_RefractColor;RefractColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-123.2303,21.70387;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;25;-475.6535,-64.09171;Inherit;True;Property;_Matcap1;Matcap;2;0;Create;True;0;0;0;False;0;False;-1;None;40b0d30b9046e104e9ea6d60473eb274;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-73.10782,-212.0887;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;37;473.2809,-297.2137;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;278.351,-133.4;Inherit;False;43;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;264.3006,-637.9208;Inherit;True;Property;_Decal;Decal;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;50;-391.932,-139.3494;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;42;181.1301,82.75982;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;57.64862,-319.0501;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-659.2859,-370.1674;Inherit;False;24;MatcapUVPro;1;0;OBJECT;;False;1;FLOAT2;0
WireConnection;5;0;3;0
WireConnection;6;0;5;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;10;0;12;0
WireConnection;10;1;11;0
WireConnection;15;0;14;0
WireConnection;17;0;16;0
WireConnection;18;0;19;0
WireConnection;18;1;17;0
WireConnection;19;0;17;1
WireConnection;7;0;6;0
WireConnection;20;0;18;0
WireConnection;21;0;20;0
WireConnection;24;0;21;0
WireConnection;16;0;15;0
WireConnection;16;1;10;0
WireConnection;14;0;13;0
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;31;0;28;0
WireConnection;31;1;63;0
WireConnection;31;2;64;0
WireConnection;32;0;31;0
WireConnection;33;0;46;0
WireConnection;33;1;34;0
WireConnection;1;1;9;0
WireConnection;27;0;26;0
WireConnection;27;1;33;0
WireConnection;53;0;51;2
WireConnection;53;1;52;2
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;56;0;54;0
WireConnection;56;1;57;0
WireConnection;60;0;32;0
WireConnection;60;1;59;1
WireConnection;60;2;61;4
WireConnection;58;1;56;0
WireConnection;59;1;58;0
WireConnection;43;0;62;0
WireConnection;62;0;60;0
WireConnection;0;2;66;0
WireConnection;0;9;38;0
WireConnection;38;0;67;0
WireConnection;67;0;65;4
WireConnection;67;1;37;0
WireConnection;66;0;35;0
WireConnection;66;1;65;0
WireConnection;66;2;65;4
WireConnection;48;0;40;0
WireConnection;48;1;25;0
WireConnection;25;1;27;0
WireConnection;49;0;40;0
WireConnection;49;1;50;0
WireConnection;37;0;1;1
WireConnection;37;1;45;0
WireConnection;42;0;49;0
WireConnection;42;1;48;0
WireConnection;42;2;33;0
WireConnection;35;0;1;0
WireConnection;35;1;42;0
ASEEND*/
//CHKSM=10A0E4A2920BD085D20CFBDB96987C360E811F0E