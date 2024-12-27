// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HoloGram"
{
	Properties
	{
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		[Toggle]_ZWriteMode("ZWriteMode", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_FliclCtrl2("FliclCtrl", Range( 0 , 1)) = 1
		_FliclCtrl1("FliclCtrl", Range( 0 , 1)) = 1
		_WireFrame("WireFrame", 2D) = "white" {}
		_WireFrameIntensity("WireFrameIntensity", Float) = 1
		_Alpha("Alpha", Range( 0 , 1)) = 1
		_GlitchWidth("GlitchWidth", Float) = 1
		_Line2Width("Line2Width", Float) = 1
		_Line1Width("Line1Width", Float) = 1
		_GlitchFreq("GlitchFreq", Float) = 1
		_Line2Freq("Line2Freq", Float) = 1
		_Line1Freq("Line1Freq", Float) = 1
		_GlitchSpeed("GlitchSpeed", Float) = 1
		_Line2Speed("Line2Speed", Float) = 1
		_Line1Speed("Line1Speed", Float) = 1
		_Line2Hardmess("Line2Hardmess", Float) = 1
		_GlitchHardmess("GlitchHardmess", Float) = 1
		_Line1Hardmess("Line1Hardmess", Float) = 1
		_Line1Alpha("Line1Alpha", Float) = 1
		_Line2Alpha("Line2Alpha", Float) = 1
		_Scanline1("Scanline1", 2D) = "white" {}
		_Scanline2("Scanline1", 2D) = "white" {}
		[HDR]_Line1Color("Line1Color", Color) = (0,0,0,0)
		_GlicthTilling("GlicthTilling", Float) = 0
		_VertexOffset("VertexOffset", Vector) = (0,0,0,0)
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		_GlitchTex("GlitchTex", 2D) = "white" {}
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

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite [_ZWriteMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
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
			float3 worldPos;
			float vertexToFrag174;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float _ZWriteMode;
		uniform float3 _VertexOffset;
		uniform float _GlicthTilling;
		uniform float _FliclCtrl2;
		uniform float3 _ScanlineVertexOffset;
		uniform sampler2D _GlitchTex;
		uniform float _GlitchFreq;
		uniform float _GlitchSpeed;
		uniform float _GlitchWidth;
		uniform float _GlitchHardmess;
		uniform float _FliclCtrl1;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _MainColor;
		uniform sampler2D _Scanline1;
		uniform float _Line1Freq;
		uniform float _Line1Speed;
		uniform float _Line1Width;
		uniform float _Line1Hardmess;
		uniform sampler2D _Scanline2;
		uniform float _Line2Freq;
		uniform float _Line2Speed;
		uniform float _Line2Width;
		uniform float _Line2Hardmess;
		uniform float4 _Line1Color;
		uniform float _Line1Alpha;
		uniform float _Line2Alpha;
		uniform sampler2D _WireFrame;
		uniform float4 _WireFrame_ST;
		uniform float _WireFrameIntensity;
		uniform float _Alpha;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 viewToObjDir129 = mul( UNITY_MATRIX_T_MV, float4( _VertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult119 = (float2((ase_worldPos.y*_GlicthTilling + _Time.y) , _Time.y));
			float simplePerlin2D118 = snoise( appendResult119 );
			simplePerlin2D118 = simplePerlin2D118*0.5 + 0.5;
			float3 objToWorld131 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime134 = _Time.y * -1.0;
			float mulTime135 = _Time.y * -1.0;
			float2 appendResult133 = (float2((( objToWorld131.x + objToWorld131.y + objToWorld131.z )*200.0 + mulTime134) , mulTime135));
			float simplePerlin2D136 = snoise( appendResult133 );
			simplePerlin2D136 = simplePerlin2D136*0.5 + 0.5;
			float clampResult138 = clamp( (-0.5 + (simplePerlin2D136 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult141 = lerp( 1.0 , clampResult138 , _FliclCtrl2);
			float clampResult143 = clamp( (lerpResult141*2.0 + -1.0) , 0.0 , 1.0 );
			float vertexToFrag175 = clampResult143;
			float temp_output_144_0 = ( (simplePerlin2D118*2.0 + -1.0) * vertexToFrag175 );
			float2 break145 = appendResult119;
			float2 appendResult149 = (float2(( 20.0 * break145.x ) , break145.y));
			float simplePerlin2D150 = snoise( appendResult149 );
			simplePerlin2D150 = simplePerlin2D150*0.5 + 0.5;
			float clampResult152 = clamp( (simplePerlin2D150*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset127 = ( ( viewToObjDir129 * 0.01 ) * ( temp_output_144_0 + ( temp_output_144_0 * clampResult152 ) ) );
			float3 viewToObjDir166 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld3_g5 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult9_g5 = (float2(0.5 , (( ase_worldPos.y - objToWorld3_g5.y )*_GlitchFreq + _GlitchSpeed)));
			float3 ScanlineGlitch168 = ( ( viewToObjDir166 * 0.01 ) * ( ( tex2Dlod( _GlitchTex, float4( appendResult9_g5, 0, 0.0) ).r - _GlitchWidth ) * _GlitchHardmess ) );
			v.vertex.xyz += ( GlitchVertexOffset127 + ScanlineGlitch168 );
			v.vertex.w = 1;
			float3 objToWorld7 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime6 = _Time.y * 3.0;
			float2 appendResult13 = (float2((( objToWorld7.x + objToWorld7.y + objToWorld7.z )*200.0 + mulTime6) , _Time.y));
			float simplePerlin2D9 = snoise( appendResult13 );
			simplePerlin2D9 = simplePerlin2D9*0.5 + 0.5;
			float clampResult19 = clamp( (-0.5 + (simplePerlin2D9 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult51 = lerp( 1.0 , clampResult19 , _FliclCtrl1);
			o.vertexToFrag174 = lerpResult51;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float Flicking15 = i.vertexToFrag174;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV22 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) ), ase_worldViewDir );
			float fresnelNode22 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV22 , 0.0001 ), _RimPower ) );
			float clampResult54 = clamp( fresnelNode22 , 0.0 , 1.0 );
			float FresnelFactor30 = clampResult54;
			float3 objToWorld2_g7 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g7 = _Time.y * _Line1Speed;
			float2 appendResult9_g7 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g7.y )*( _Line1Freq / 100.0 ) + mulTime7_g7)));
			float clampResult23_g7 = clamp( ( ( tex2D( _Scanline1, appendResult9_g7 ).r - ( _Line1Width * 0.001 ) ) * _Line1Hardmess ) , 0.0 , 1.0 );
			float clampResult29_g7 = clamp( clampResult23_g7 , 0.0 , 1.0 );
			float temp_output_173_0 = clampResult29_g7;
			float3 objToWorld2_g6 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g6 = _Time.y * _Line2Speed;
			float2 appendResult9_g6 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g6.y )*( _Line2Freq / 100.0 ) + mulTime7_g6)));
			float clampResult23_g6 = clamp( ( ( tex2D( _Scanline2, appendResult9_g6 ).r - ( _Line2Width * 0.001 ) ) * _Line2Hardmess ) , 0.0 , 1.0 );
			float clampResult29_g6 = clamp( clampResult23_g6 , 0.0 , 1.0 );
			float temp_output_172_0 = clampResult29_g6;
			float4 ScanlineColor66 = ( ( temp_output_173_0 * temp_output_172_0 ) * _Line1Color );
			o.Emission = ( Flicking15 * ( ( FresnelFactor30 * _MainColor ) + _MainColor + max( ScanlineColor66 , float4( 0,0,0,0 ) ) ) ).rgb;
			float temp_output_105_0 = ( temp_output_172_0 * _Line2Alpha );
			float ScanlineAlpha93 = ( ( temp_output_173_0 * _Line1Alpha * temp_output_105_0 ) + temp_output_105_0 );
			float clampResult44 = clamp( ( _MainColor.a + FresnelFactor30 + ScanlineAlpha93 ) , 0.0 , 1.0 );
			float2 uv_WireFrame = i.uv_texcoord * _WireFrame_ST.xy + _WireFrame_ST.zw;
			float WireFrame36 = ( tex2D( _WireFrame, uv_WireFrame ).r * _WireFrameIntensity );
			o.Alpha = ( clampResult44 * WireFrame36 * _Alpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 customPack1 : TEXCOORD1;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.x = customInputData.vertexToFrag174;
				o.customPack1.yz = customInputData.uv_texcoord;
				o.customPack1.yz = v.texcoord;
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
				surfIN.vertexToFrag174 = IN.customPack1.x;
				surfIN.uv_texcoord = IN.customPack1.yz;
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
Node;AmplifyShaderEditor.CommentaryNode;169;-185.0607,327.688;Inherit;False;1263.655;968.1798;Comment;12;156;158;159;160;161;162;163;164;165;166;167;168;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;155;-2529.565,1558.264;Inherit;False;2649.018;1674.707;Comment;39;121;124;125;122;115;114;116;119;117;120;127;123;129;130;131;132;133;136;137;138;139;140;141;135;134;145;147;148;149;118;150;142;151;143;152;153;154;144;175;RandomGlitch;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;109;-2471.747,206.8191;Inherit;False;1453.767;1326.706;Comment;20;89;92;90;66;84;85;87;86;88;100;102;101;103;105;91;106;93;107;108;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2470.008,-466.1688;Inherit;False;1890.145;668.5984;Comment;14;73;71;70;61;63;62;59;58;57;56;55;75;76;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;37;-1949.229,-899.4907;Inherit;False;947.1171;421.9308;Comment;4;32;33;34;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1939.062,-2220.655;Inherit;False;1502.749;604.4656;Comment;8;23;24;25;26;27;22;30;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1914.807,-2399.549;Inherit;False;240;166;Comment;1;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1946.941,-1605.505;Inherit;False;1929.035;669.2525;Comment;14;52;51;19;18;9;12;14;6;13;11;7;8;15;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1864.807,-2349.549;Inherit;False;Property;_ZWriteMode;ZWriteMode;2;1;[Toggle];Create;True;0;0;1;;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-1518.348,-2136.953;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;24;-1889.062,-2170.655;Inherit;True;Property;_NormalMap;NormalMap;3;0;Create;True;0;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1456.46,-1950.826;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1445.418,-1855.863;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;22;-1165.889,-2093.423;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1899.229,-849.4907;Inherit;True;Property;_WireFrame;WireFrame;9;0;Create;True;0;0;0;False;0;False;-1;None;668fcaed21c1ad143a5b2782b04ad025;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1504.112,-709.5599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1897.112,-593.5599;Inherit;False;Property;_WireFrameIntensity;WireFrameIntensity;10;0;Create;True;0;0;0;False;0;False;1;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1226.112,-611.5599;Inherit;False;WireFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1437.687,-1732.19;Inherit;False;Property;_RimPower;RimPower;6;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-641.6538,-2090.924;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;54;-867.49,-2016.665;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;55;-2398.521,-416.1687;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-2091.381,-270.814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;57;-2420.008,-210.1443;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1865.133,-221.5198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2108.136,41.42981;Inherit;False;Property;_ScanSpeed;ScanSpeed;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1718.535,-143.3703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-1546.942,-133.5118;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;71;-1345.942,-193.5118;Inherit;True;Property;_ScanlineTex;ScanlineTex;28;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-1033.942,-34.51184;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1309.808,65.49799;Inherit;False;Property;_ScanlineInvert;ScanlineInvert;30;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-847.3402,-12.25491;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1131.078,137.4047;Inherit;False;Property;_ScanlinePower;ScanlinePower;29;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2157.142,-102.3886;Inherit;False;Property;_ScanTilling;ScanTilling;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;714.3371,-1089.692;Inherit;False;15;Flicking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;1027.631,-896.949;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;820.6307,-919.9489;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1212.631,-1051.949;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;865.8107,-667.629;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;44;1079.811,-701.629;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;1244.811,-636.629;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;610.8109,-569.629;Inherit;False;30;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;965.2198,-263.6029;Inherit;False;Property;_Alpha;Alpha;11;0;Create;True;0;0;0;False;0;False;1;0.92;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;1027.111,-327.6292;Inherit;False;36;WireFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;682.2635,-448.3505;Inherit;False;93;ScanlineAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;475.7549,-801.9498;Inherit;False;Property;_MainColor;MainColor;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.2247059,0.5243137,1.498039,0.05490196;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;591.6309,-937.9487;Inherit;False;30;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;782.5535,-759.8123;Inherit;False;66;ScanlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;98;995.8873,-733.3474;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1503.446,421.7295;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1794.98,810.9987;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;90;-1751.446,513.7299;Inherit;False;Property;_Line1Color;Line1Color;33;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;1.361854,1.064525,3.091499,0.05490196;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1342.818,433.7269;Inherit;False;ScanlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;84;-2392.673,256.8189;Inherit;True;Property;_Scanline1;Scanline1;31;0;Create;True;0;0;0;False;0;False;4bbf045a9f687084ea4bc84d53c39623;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;85;-2386.716,478.544;Inherit;False;Property;_Line1Freq;Line1Freq;18;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2388.662,617.8809;Inherit;False;Property;_Line1Width;Line1Width;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2387.682,547.6076;Inherit;False;Property;_Line1Speed;Line1Speed;21;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2421.748,681.7921;Inherit;False;Property;_Line1Hardmess;Line1Hardmess;24;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1533.871,1063.256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2005.98,773.9987;Inherit;False;Property;_Line1Alpha;Line1Alpha;25;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1637.871,1308.956;Inherit;False;Property;_Line2Alpha;Line2Alpha;26;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-1241.98,873.9981;Inherit;False;ScanlineAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-1436.371,816.2567;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1731.726,414.3765;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;99;-2221.441,984.5524;Inherit;True;Property;_Scanline2;Scanline1;32;0;Create;True;0;0;0;False;0;False;4bbf045a9f687084ea4bc84d53c39623;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1679.341,-1441.906;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;7;-1896.941,-1461.106;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;11;-1500.141,-1489.906;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1225.738,-1510.608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;14;-1415.537,-1277.909;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;9;-1033.942,-1555.505;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-818.1174,-1274.002;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;19;-528.7867,-1428.74;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-745.9644,-1112.267;Inherit;False;Property;_FliclCtrl1;FliclCtrl;8;0;Create;True;0;0;0;False;0;False;1;0.888;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1811.742,-1237.707;Inherit;False;Constant;_Tilling;Tilling;2;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;62;-1885.937,-43.07018;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1813.483,-1144.44;Inherit;False;1;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;121;-1315.957,1905.981;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-832.3578,1821.48;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;115;-2140.01,1903.723;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;114;-2479.565,1782.898;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;116;-2394.862,1978.349;Inherit;False;Property;_GlicthTilling;GlicthTilling;34;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;119;-1886.861,1911.349;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;117;-2404.862,2068.351;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;120;-2143.421,2147.326;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-2060.458,2417.135;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;131;-2278.058,2397.935;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;132;-1881.257,2369.135;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;133;-1606.854,2348.433;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;-1415.058,2303.536;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;137;-1199.233,2585.039;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;138;-909.9028,2430.301;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-1127.08,2746.774;Inherit;False;Property;_FliclCtrl2;FliclCtrl;7;0;Create;True;0;0;0;False;0;False;1;0.888;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-2192.859,2621.334;Inherit;False;Constant;_Tilling1;Tilling;2;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;141;-706.2032,2418.864;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;135;-1796.653,2581.132;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;134;-1986.857,2802.735;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;145;-1687.358,2999.092;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;147;-1669.627,2871.933;Inherit;False;Constant;_Float2;Float 2;32;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1507.627,2929.933;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;149;-1258.627,2988.933;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;118;-1620.861,1885.349;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;150;-1064.384,2973.974;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;142;-356.9171,2445.857;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;151;-602.4219,2901.323;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;143;-51.54613,2393.203;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;152;-319.084,2934.317;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-468.9007,2083.87;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-188.4832,1983.366;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2215.484,1206.277;Inherit;False;Property;_Line2Freq;Line2Freq;17;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2216.45,1275.34;Inherit;False;Property;_Line2Speed;Line2Speed;20;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-2217.43,1345.613;Inherit;False;Property;_Line2Width;Line2Width;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2234.516,1417.525;Inherit;False;Property;_Line2Hardmess;Line2Hardmess;22;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1183.357,1795.481;Inherit;False;Constant;_Float0;Float 0;31;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1009.157,1717.481;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;123;-1598.779,1608.264;Inherit;False;Property;_VertexOffset;VertexOffset;35;0;Create;True;0;0;0;False;0;False;0,0,0;2,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;129;-1307.853,1632.688;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;156;375.8682,755.6108;Inherit;False;Scanline;-1;;5;47afd462729c0f846bae803d62931356;0;6;21;SAMPLER2D;0;False;16;FLOAT;0;False;19;FLOAT;0;False;20;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;158;-49.96686,631.2571;Inherit;True;Property;_GlitchTex;GlitchTex;37;0;Create;True;0;0;0;False;0;False;None;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;159;34.33552,968.6199;Inherit;False;Property;_GlitchFreq;GlitchFreq;16;0;Create;True;0;0;0;False;0;False;1;47.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;33.36945,1037.683;Inherit;False;Property;_GlitchSpeed;GlitchSpeed;19;0;Create;True;0;0;0;False;0;False;1;-15.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;161;32.38947,1107.956;Inherit;False;Property;_GlitchWidth;GlitchWidth;12;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;15.30331,1179.868;Inherit;False;Property;_GlitchHardmess;GlitchHardmess;23;0;Create;True;0;0;0;False;0;False;1;0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;280.3613,564.9049;Inherit;False;Constant;_Float3;Float 0;31;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;454.5614,486.9049;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;166;155.8654,402.1119;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;669.5947,626.4351;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;165;-135.0607,377.688;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;36;0;Create;True;0;0;0;False;0;False;0,0,0;2,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;128;1313.904,-337.9641;Inherit;False;127;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;854.5947,667.4351;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-545.0576,1834.182;Inherit;False;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;1382.287,-236.0146;Inherit;False;168;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;1591.507,-321.8536;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1850.594,-866.683;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;HoloGram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;True;_ZWriteMode;0;False;;False;0;False;;0;False;;True;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.FunctionNode;172;-1927.74,1049.438;Inherit;False;Scanline;-1;;6;5281802037d7b204082e30d4321e0580;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;173;-2084.573,361.7047;Inherit;False;Scanline;-1;;7;5281802037d7b204082e30d4321e0580;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;-401.087,-1302.826;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-236.3513,-1114.893;Inherit;False;Flicking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;174;-306.6017,-1505.043;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-854.0306,2003.778;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;175;-893.473,2202.448;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;23;0;24;0
WireConnection;22;0;23;0
WireConnection;22;1;25;0
WireConnection;22;2;26;0
WireConnection;22;3;27;0
WireConnection;33;0;32;1
WireConnection;33;1;34;0
WireConnection;36;0;33;0
WireConnection;30;0;54;0
WireConnection;54;0;22;0
WireConnection;56;0;55;2
WireConnection;56;1;57;2
WireConnection;58;0;56;0
WireConnection;58;1;59;0
WireConnection;61;0;58;0
WireConnection;61;1;62;0
WireConnection;70;1;61;0
WireConnection;71;1;70;0
WireConnection;73;0;71;1
WireConnection;73;1;76;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;40;0;39;0
WireConnection;40;1;1;0
WireConnection;40;2;98;0
WireConnection;39;0;38;0
WireConnection;39;1;1;0
WireConnection;41;0;16;0
WireConnection;41;1;40;0
WireConnection;42;0;1;4
WireConnection;42;1;43;0
WireConnection;42;2;94;0
WireConnection;44;0;42;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;46;2;49;0
WireConnection;98;0;95;0
WireConnection;89;0;108;0
WireConnection;89;1;90;0
WireConnection;92;0;173;0
WireConnection;92;1;91;0
WireConnection;92;2;105;0
WireConnection;66;0;89;0
WireConnection;105;0;172;0
WireConnection;105;1;106;0
WireConnection;93;0;107;0
WireConnection;107;0;92;0
WireConnection;107;1;105;0
WireConnection;108;0;173;0
WireConnection;108;1;172;0
WireConnection;8;0;7;1
WireConnection;8;1;7;2
WireConnection;8;2;7;3
WireConnection;11;0;8;0
WireConnection;11;1;12;0
WireConnection;11;2;6;0
WireConnection;13;0;11;0
WireConnection;13;1;14;0
WireConnection;9;0;13;0
WireConnection;18;0;9;0
WireConnection;19;0;18;0
WireConnection;62;0;63;0
WireConnection;121;0;118;0
WireConnection;122;0;125;0
WireConnection;122;1;154;0
WireConnection;115;0;114;2
WireConnection;115;1;116;0
WireConnection;115;2;117;0
WireConnection;119;0;115;0
WireConnection;119;1;120;0
WireConnection;130;0;131;1
WireConnection;130;1;131;2
WireConnection;130;2;131;3
WireConnection;132;0;130;0
WireConnection;132;1;140;0
WireConnection;132;2;134;0
WireConnection;133;0;132;0
WireConnection;133;1;135;0
WireConnection;136;0;133;0
WireConnection;137;0;136;0
WireConnection;138;0;137;0
WireConnection;141;1;138;0
WireConnection;141;2;139;0
WireConnection;145;0;119;0
WireConnection;148;0;147;0
WireConnection;148;1;145;0
WireConnection;149;0;148;0
WireConnection;149;1;145;1
WireConnection;118;0;119;0
WireConnection;150;0;149;0
WireConnection;142;0;141;0
WireConnection;151;0;150;0
WireConnection;143;0;142;0
WireConnection;152;0;151;0
WireConnection;153;0;144;0
WireConnection;153;1;152;0
WireConnection;154;0;144;0
WireConnection;154;1;153;0
WireConnection;125;0;129;0
WireConnection;125;1;124;0
WireConnection;129;0;123;0
WireConnection;156;21;158;0
WireConnection;156;19;159;0
WireConnection;156;20;160;0
WireConnection;156;22;161;0
WireConnection;156;23;162;0
WireConnection;164;0;166;0
WireConnection;164;1;163;0
WireConnection;166;0;165;0
WireConnection;167;0;164;0
WireConnection;167;1;156;0
WireConnection;168;0;167;0
WireConnection;127;0;122;0
WireConnection;171;0;128;0
WireConnection;171;1;170;0
WireConnection;0;2;41;0
WireConnection;0;9;46;0
WireConnection;0;11;171;0
WireConnection;172;20;99;0
WireConnection;172;18;100;0
WireConnection;172;19;102;0
WireConnection;172;21;101;0
WireConnection;172;22;103;0
WireConnection;173;20;84;0
WireConnection;173;18;85;0
WireConnection;173;19;86;0
WireConnection;173;21;87;0
WireConnection;173;22;88;0
WireConnection;51;1;19;0
WireConnection;51;2;52;0
WireConnection;15;0;174;0
WireConnection;174;0;51;0
WireConnection;144;0;121;0
WireConnection;144;1;175;0
WireConnection;175;0;143;0
ASEEND*/
//CHKSM=5829661AC54FC1CCC0AE54FDF85EFE5D6B8BBF56