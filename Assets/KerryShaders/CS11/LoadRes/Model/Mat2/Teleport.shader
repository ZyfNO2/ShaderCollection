// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Teleport"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BaseMap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_CompMask("CompMask", 2D) = "white" {}
		_MetallicAdjust("MetallicAdjust", Range( -1 , 1)) = 0
		_SmoothnessAdjust("SmoothnessAdjust", Range( -1 , 1)) = 0
		_NoiseScale("NoiseScale", Vector) = (1,1,1,0)
		_DissloveAmount("DissloveAmount", Range( -3 , 3)) = 0
		_DissloveSpread("DissloveSpread", Float) = 0
		_DissloveOffset("DissloveOffset", Float) = -1
		_DissloveEdgeOffset("DissloveEdgeOffset", Float) = 0
		[HDR]_EdgeEmissColor("EdgeEmissColor", Color) = (0.2298861,0.2760032,0.7735849,0)
		_VertexEffectSpread("VertexEffectSpread", Float) = 0
		_OffsetIntensity("OffsetIntensity", Float) = 0
		_VertexEffectOffset("VertexEffectOffset", Float) = -1
		_VertexOffsetNoise("VertexOffsetNoise", Vector) = (0,1,0,0)
		_RimIntensity("RimIntensity", Float) = 0
		_RimCtrl("RimCtrl", Range( 0 , 1)) = 0
		[HDR]_RimColor("RimColor", Color) = (0,0,0,0)
		_EmissTex("EmissTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _DissloveAmount;
		uniform float _VertexEffectOffset;
		uniform float _VertexEffectSpread;
		uniform float _OffsetIntensity;
		uniform float3 _VertexOffsetNoise;
		uniform float _DissloveOffset;
		uniform float _DissloveSpread;
		uniform float3 _NoiseScale;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _MetallicAdjust;
		uniform sampler2D _CompMask;
		uniform float4 _CompMask_ST;
		uniform float _SmoothnessAdjust;
		uniform float _RimCtrl;
		uniform float _DissloveEdgeOffset;
		uniform float4 _EdgeEmissColor;
		uniform float _RimIntensity;
		uniform sampler2D _EmissTex;
		uniform float4 _EmissTex_ST;
		uniform float4 _RimColor;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld18 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_19_0 = ( ase_worldPos.y - objToWorld18.y );
			float temp_output_20_0 = ( ( 1.0 - temp_output_19_0 ) - _DissloveAmount );
			float simplePerlin3D110 = snoise( ( ase_worldPos * _VertexOffsetNoise ) );
			simplePerlin3D110 = simplePerlin3D110*0.5 + 0.5;
			float3 worldToObj96 = mul( unity_WorldToObject, float4( ( ( max( ( ( ( 1.0 - temp_output_20_0 ) - _VertexEffectOffset ) / _VertexEffectSpread ) , 0.0 ) * float3(0,1,0) * _OffsetIntensity * simplePerlin3D110 ) + ase_worldPos ), 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 FinalVertexOffset99 = ( worldToObj96 - ase_vertex3Pos );
			v.vertex.xyz += FinalVertexOffset99;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld18 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_19_0 = ( ase_worldPos.y - objToWorld18.y );
			float temp_output_20_0 = ( ( 1.0 - temp_output_19_0 ) - _DissloveAmount );
			float temp_output_25_0 = ( ( temp_output_20_0 - _DissloveOffset ) / _DissloveSpread );
			float smoothstepResult67 = smoothstep( 0.0 , 1.0 , temp_output_25_0);
			float simplePerlin3D40 = snoise( ( ase_worldPos * _NoiseScale )*_NoiseScale.x );
			simplePerlin3D40 = simplePerlin3D40*0.5 + 0.5;
			float clampResult27 = clamp( ( smoothstepResult67 + ( temp_output_25_0 - simplePerlin3D40 ) ) , 0.0 , 1.0 );
			float Disslove65 = clampResult27;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float3 gammaToLinear12 = GammaToLinearSpace( tex2D( _BaseMap, uv_BaseMap ).rgb );
			s1.Albedo = gammaToLinear12;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			s1.Normal = normalize( WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) ) );
			s1.Emission = float3( 0,0,0 );
			float2 uv_CompMask = i.uv_texcoord * _CompMask_ST.xy + _CompMask_ST.zw;
			float4 tex2DNode5 = tex2D( _CompMask, uv_CompMask );
			float clampResult8 = clamp( ( _MetallicAdjust + tex2DNode5.r ) , 0.0 , 1.0 );
			s1.Metallic = clampResult8;
			s1.Smoothness = ( _SmoothnessAdjust + ( 1.0 - tex2DNode5.g ) );
			s1.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1
			surfResult1 -= s1.Emission;
			#endif//1
			float3 linearToGamma13 = LinearToGammaSpace( surfResult1 );
			float3 pbrLighting14 = ( linearToGamma13 * _RimCtrl );
			float smoothstepResult50 = smoothstep( 0.0 , 1.0 , ( pow( ( 1.0 - distance( temp_output_25_0 , _DissloveEdgeOffset ) ) , 2.0 ) - temp_output_25_0 ));
			float4 DissloveEdgeColor53 = ( smoothstepResult50 * _EdgeEmissColor );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult116 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult119 = clamp( ( ( 1.0 - (dotResult116*1.0 + 0.0) ) - (_RimCtrl*2.0 + -1.0) ) , 0.0 , 1.0 );
			float2 uv_EmissTex = i.uv_texcoord * _EmissTex_ST.xy + _EmissTex_ST.zw;
			float4 RimEmiss122 = ( _RimIntensity * ( clampResult119 + ( clampResult119 * tex2D( _EmissTex, uv_EmissTex ).r ) ) * _RimColor );
			c.rgb = ( float4( pbrLighting14 , 0.0 ) + DissloveEdgeColor53 + RimEmiss122 ).rgb;
			c.a = 1;
			clip( ( Disslove65 + 0.4 ) - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				vertexDataFunc( v, customInputData );
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
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
Node;AmplifyShaderEditor.CommentaryNode;72;-3912.354,-2.859944;Inherit;False;3274.117;1137.771;Comment;22;46;42;60;52;50;61;23;26;25;24;47;44;43;45;40;59;65;68;67;27;53;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1936.127,-1065.728;Inherit;False;1295.262;1045.081;Comment;13;6;5;4;3;8;9;7;11;10;12;13;1;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1552.127,-461.7282;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1886.127,-466.7282;Inherit;True;Property;_CompMask;CompMask;3;0;Create;True;0;0;0;False;0;False;-1;None;a7f745220fb33f946a159d308f6c7308;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1876.127,-780.728;Inherit;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1868.127,-1015.728;Inherit;True;Property;_BaseMap;BaseMap;1;0;Create;True;0;0;0;False;0;False;-1;None;f7549f6cf82871c439168b7599da3968;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;8;-1409.619,-515.7087;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-1592.96,-131.647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1861.411,-545.5583;Inherit;False;Property;_MetallicAdjust;MetallicAdjust;4;0;Create;True;0;0;0;False;0;False;0;0.161;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1668.96,-279.6469;Inherit;False;Property;_SmoothnessAdjust;SmoothnessAdjust;5;0;Create;True;0;0;0;False;0;False;0;0.195;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1390.96,-237.6469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;12;-1530.451,-998.5959;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;13;-1166.774,-968.63;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-1396.058,-908.637;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;38;292.4951,-91.79857;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-382.9041,270.7429;Inherit;False;53;DissloveEdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;46;-2305.072,611.0704;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-2339.157,347.4011;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;60;-1843.234,652.1154;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;52;-1495.247,885.1268;Inherit;False;Property;_EdgeEmissColor;EdgeEmissColor;11;1;[HDR];Create;True;0;0;0;False;0;False;0.2298861,0.2760032,0.7735849,0;0.4896344,1.177255,1.596961,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;50;-1382.336,694.6849;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-1632.374,682.0151;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2560.45,888.0558;Inherit;False;Property;_DissloveEdgeOffset;DissloveEdgeOffset;10;0;Create;True;0;0;0;False;0;False;0;2.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;44;-3383.372,946.9091;Inherit;False;Property;_NoiseScale;NoiseScale;6;0;Create;True;0;0;0;False;0;False;1,1,1;15,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;43;-3413.372,764.9104;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-3189.554,886.285;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;40;-2930.851,897.2768;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-2090.017,718.7569;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1821.733,388.8588;Inherit;False;Disslove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-2140.64,275.0461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;27;-1969.566,337.6112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-885.2363,886.6964;Inherit;False;DissloveEdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1080.102,903.2205;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;67;-2370.457,169.0106;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;17;-4649.352,-72.85997;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;18;-4662.352,123.1401;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-4411.185,50.86513;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-3133.369,394.2335;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-3198.369,607.2336;Inherit;False;Property;_DissloveSpread;DissloveSpread;8;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-2906.27,517.7333;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3418.368,473.2335;Inherit;False;Property;_DissloveOffset;DissloveOffset;9;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;86;-3539.09,1447.196;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-4658.002,319.2208;Inherit;False;Property;_DissloveAmount;DissloveAmount;7;0;Create;True;0;0;0;False;0;False;0;-0.5;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-3831.188,1536.696;Inherit;False;Property;_VertexEffectSpread;VertexEffectSpread;12;0;Create;True;0;0;0;False;0;False;0;4.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;98;-2656.665,1973.363;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;66;-260.7314,-187.254;Inherit;False;65;Disslove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-58.57782,-131.9534;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-254.0407,-113.2871;Inherit;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;0;False;0;False;0.4;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-331.9706,137.5804;Inherit;False;14;pbrLighting;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-4081.917,1438.546;Inherit;False;Property;_VertexEffectOffset;VertexEffectOffset;14;0;Create;True;0;0;0;False;0;False;-1;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-80.88853,165.7472;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;18.24915,417.7274;Inherit;True;99;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-2376.394,1847.501;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1978.139,1846.951;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3381.075,1854.845;Inherit;False;Property;_OffsetIntensity;OffsetIntensity;13;0;Create;True;0;0;0;False;0;False;0;18.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;89;-3285.343,1480.04;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-3066.439,1594.336;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;95;-3092.375,1830.036;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;96;-2657.495,1673.425;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-2815.679,1681.288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-3681.721,1323.324;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-4163.514,46.0634;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-3957.78,100.9959;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-4076.536,1144.761;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;109;-3803.309,1078.619;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;111;-3395.94,2055.7;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;110;-3025.44,2075.2;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;92;-3319.051,1624.786;Inherit;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;113;-3424.04,2262.7;Inherit;False;Property;_VertexOffsetNoise;VertexOffsetNoise;15;0;Create;True;0;0;0;False;0;False;0,1,0;10,10,10;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-3198.04,2104.3;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;114;-1605.237,-1927.816;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;115;-1542.837,-1636.616;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;116;-1194.437,-1842.016;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-301.4932,430.3738;Inherit;False;122;RimEmiss;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;-665.992,-1782.255;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;117;-991.6372,-1826.416;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-1209.045,-1540.381;Inherit;False;Property;_RimCtrl;RimCtrl;17;0;Create;True;0;0;0;False;0;False;0;0.643;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;125;-792.7433,-1907.841;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;128;-785.7653,-1472.935;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-777.6148,-963.2096;Inherit;False;pbrLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-931.9269,-877.2286;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;129;-889.0984,-1605.097;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-447.7041,-1475.854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;173.8042,-2001.951;Inherit;False;RimEmiss;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;123;-169.5594,-1894.625;Inherit;False;Property;_RimColor;RimColor;18;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.5673727,0.6494382,1.603774,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-477.6627,-2045.552;Inherit;False;Property;_RimIntensity;RimIntensity;16;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;131;-863.2377,-1294.715;Inherit;True;Property;_EmissTex;EmissTex;19;0;Create;True;0;0;0;False;0;False;-1;None;668fcaed21c1ad143a5b2782b04ad025;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;119;-510.6361,-1795.216;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-140.2928,-2099.511;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-299.8054,-1814.85;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;6;0;7;0
WireConnection;6;1;5;1
WireConnection;8;0;6;0
WireConnection;9;0;5;2
WireConnection;10;0;11;0
WireConnection;10;1;9;0
WireConnection;12;0;3;0
WireConnection;13;0;1;0
WireConnection;1;0;12;0
WireConnection;1;1;4;0
WireConnection;1;3;8;0
WireConnection;1;4;10;0
WireConnection;38;10;70;0
WireConnection;38;13;54;0
WireConnection;38;11;100;0
WireConnection;46;0;25;0
WireConnection;46;1;47;0
WireConnection;42;0;25;0
WireConnection;42;1;40;0
WireConnection;60;0;59;0
WireConnection;50;0;61;0
WireConnection;61;0;60;0
WireConnection;61;1;25;0
WireConnection;45;0;43;0
WireConnection;45;1;44;0
WireConnection;40;0;45;0
WireConnection;40;1;44;0
WireConnection;59;0;46;0
WireConnection;65;0;27;0
WireConnection;68;0;67;0
WireConnection;68;1;42;0
WireConnection;27;0;68;0
WireConnection;53;0;51;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;67;0;25;0
WireConnection;19;0;17;2
WireConnection;19;1;18;2
WireConnection;23;0;20;0
WireConnection;23;1;24;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;86;0;84;0
WireConnection;86;1;85;0
WireConnection;70;0;66;0
WireConnection;70;1;71;0
WireConnection;54;0;16;0
WireConnection;54;1;55;0
WireConnection;54;2;124;0
WireConnection;97;0;96;0
WireConnection;97;1;98;0
WireConnection;99;0;97;0
WireConnection;89;0;86;0
WireConnection;91;0;89;0
WireConnection;91;1;92;0
WireConnection;91;2;93;0
WireConnection;91;3;110;0
WireConnection;96;0;105;0
WireConnection;105;0;91;0
WireConnection;105;1;95;0
WireConnection;84;0;109;0
WireConnection;84;1;87;0
WireConnection;56;0;19;0
WireConnection;20;0;56;0
WireConnection;20;1;21;0
WireConnection;103;0;19;0
WireConnection;103;1;21;0
WireConnection;109;0;20;0
WireConnection;110;0;112;0
WireConnection;112;0;111;0
WireConnection;112;1;113;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;126;0;125;0
WireConnection;126;1;128;0
WireConnection;117;0;116;0
WireConnection;125;0;117;0
WireConnection;128;0;127;0
WireConnection;14;0;130;0
WireConnection;130;0;13;0
WireConnection;130;1;127;0
WireConnection;129;0;127;0
WireConnection;133;0;119;0
WireConnection;133;1;131;1
WireConnection;122;0;120;0
WireConnection;119;0;126;0
WireConnection;120;0;121;0
WireConnection;120;1;132;0
WireConnection;120;2;123;0
WireConnection;132;0;119;0
WireConnection;132;1;133;0
ASEEND*/
//CHKSM=2787FEE83DC844DD696A2CE6C2C815A5A6787DEB