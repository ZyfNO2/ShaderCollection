// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Slime"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_BaseMap("BaseMap", 2D) = "white" {}
		_EmissMap("EmissMap", 2D) = "white" {}
		_Contrast("Contrast", Float) = 5
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_Float0("Float 0", Float) = 1
		_RimColor("RimColor", Color) = (1,1,1,1)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_SlimeNormalNoise1("SlimeNormalNoise", 2D) = "bump" {}
		_NoiseVertexTilling("NoiseVertexTilling", Vector) = (1,1,1,0)
		_NoiseTilling("NoiseTilling", Vector) = (1,1,1,0)
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_VertexNoiseSpeed("VertexNoiseSpeed", Vector) = (0,0,0,0)
		_VertexNoise("VertexNoise", 2D) = "bump" {}
		_VertexIntensity("VertexIntensity", Float) = 0.01
		_VertexBais("VertexBais", Vector) = (0,-1,0,0)
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform sampler2D _VertexNoise;
		uniform float3 _NoiseVertexTilling;
		uniform float3 _VertexNoiseSpeed;
		uniform float3 _VertexBais;
		uniform float _VertexIntensity;
		uniform sampler2D _Matcap;
		uniform float _Contrast;
		uniform sampler2D _SlimeNormalNoise1;
		uniform float3 _NoiseTilling;
		uniform float3 _NoiseSpeed;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform sampler2D _EmissMap;
		uniform float4 _EmissMap_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _Float0;
		uniform float4 _RimColor;


		inline float3 TriplanarSampling121( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 objToWorld125 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_130_0 = ( _Time.y * _VertexNoiseSpeed );
			float3 triplanar121 = TriplanarSampling121( _VertexNoise, ( ( ( ase_worldPos - objToWorld125 ) * _NoiseVertexTilling ) + temp_output_130_0 ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float3 VertexNoise133 = triplanar121;
			float dotResult150 = dot( ase_worldNormal , _VertexBais );
			float clampResult151 = clamp( dotResult150 , 0.0 , 1.0 );
			float3 worldToObj146 = mul( unity_WorldToObject, float4( ( ( ( VertexNoise133 * ( ase_worldNormal + _VertexBais ) * v.color.r * ( clampResult151 + 1.0 ) ) * _VertexIntensity * 0.01 ) + ase_worldPos ), 1 ) ).xyz;
			float3 Anim140 = worldToObj146;
			v.vertex.xyz = Anim140;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView52 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult41 = normalize( objToView52 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 saferPower88 = abs( abs( ase_worldNormal ) );
			float3 temp_cast_0 = (_Contrast).xxx;
			float3 temp_output_88_0 = pow( saferPower88 , temp_cast_0 );
			float3 break91 = temp_output_88_0;
			float3 break90 = ( temp_output_88_0 / ( break91.x + break91.y + break91.z ) );
			float3 objToWorld93 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_108_0 = ( _Time.y * _NoiseSpeed );
			float3 temp_output_115_0 = ( ( ( ase_worldPos - objToWorld93 ) * _NoiseTilling ) + temp_output_108_0 );
			float3 normalizeResult97 = normalize( ( ( break90.z * UnpackNormal( tex2D( _SlimeNormalNoise1, (temp_output_115_0).xy ) ) ) + ( break90.x * UnpackNormal( tex2D( _SlimeNormalNoise1, (temp_output_115_0).yz ) ) ) + ( break90.y * UnpackNormal( tex2D( _SlimeNormalNoise1, (temp_output_115_0).xz ) ) ) ) );
			float3 break98 = normalizeResult97;
			float4 appendResult101 = (float4(( ase_worldPos.x + break98.x ) , ( ase_worldPos.y + break98.y ) , 0.0 , ase_worldPos.z));
			float4 normalizeResult103 = normalize( appendResult101 );
			float4 TriNormalWorld105 = normalizeResult103;
			float3 break42 = cross( normalizeResult41 , mul( UNITY_MATRIX_V, TriNormalWorld105 ).xyz );
			float2 appendResult43 = (float2(-break42.y , break42.x));
			float2 MatcapUVPro47 = ((appendResult43).xy*0.5 + 0.5);
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV15 = dot( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )), ase_worldViewDir );
			float fresnelNode15 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV15 , 0.0001 ), _Float0 ) );
			float4 clampResult29 = clamp( ( fresnelNode15 * _RimColor ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
			float4 RimColor23 = clampResult29;
			o.Emission = ( ( tex2D( _Matcap, MatcapUVPro47 ) * tex2D( _BaseMap, uv_BaseMap ) ) + ( tex2D( _EmissMap, uv_EmissMap ) * RimColor23 ) ).rgb;
			o.Alpha = 1;
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
Node;AmplifyShaderEditor.CommentaryNode;141;-5334.611,2580.545;Inherit;False;1742.058;727.1514;Comment;10;139;140;146;145;144;143;138;137;136;147;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;134;-5375.502,1544.749;Inherit;False;1834.11;988.9664;Comment;13;124;125;127;128;129;130;132;126;131;122;121;133;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;119;-4611.936,939.6926;Inherit;False;819.5005;275.0001;EZTri;2;117;118;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;106;-5587.512,-764.8433;Inherit;False;4229.33;1581.216;Comment;37;101;100;99;104;103;115;114;73;72;71;96;110;109;108;107;105;98;97;95;80;79;78;93;92;91;90;89;88;87;86;85;84;83;82;81;70;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-3664.686,-2211.77;Inherit;False;2317.121;1104.143;TriPanner;19;59;60;58;57;30;53;55;56;54;31;33;37;35;32;34;38;67;61;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-1166.063,-1039.423;Inherit;False;1534.5;644.7787;Comment;10;15;23;29;22;21;19;18;17;16;27;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;12;-857.9674,-1382.456;Inherit;False;1631.208;323.6674;Comment;7;65;3;2;5;7;28;6;;1,0,0.6176958,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;16;-769.6953,-989.4229;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-762.4776,-823.4122;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;18;-701.1255,-624.9217;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;0;False;0;False;0;1.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-669.8481,-547.9314;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;0;False;0;False;1;0.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-650.6006,-449.2876;Inherit;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-112.8655,-806.5705;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;22;-351.75,-646.4236;Inherit;False;Property;_RimColor;RimColor;7;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.9811321,0.3748658,0.7231468,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;29;42.3739,-834.754;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;179.0775,-838.1847;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;15;-400.788,-919.8839;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-1103.689,-979.4238;Inherit;True;Property;_NormalMap;NormalMap;8;0;Create;True;0;0;0;False;0;False;-1;None;3862882999314ba499d178feca7869c0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;39;-858.0717,-2160.437;Inherit;False;2415.987;774.4199;BetterMatcapUV;14;47;52;51;50;49;48;46;45;44;43;42;41;40;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;5;-456.5361,-1253.65;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-507.9463,-1766.861;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;41;-207.3193,-1931.456;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;42;212.5857,-1807.955;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;44;362.0878,-1739.053;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;48;-714.4683,-1794.445;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CrossProductOpNode;50;-44.58923,-1851.751;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;51;-816.4072,-2113.603;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;52;-565.2673,-1999.518;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;1252.734,-1732.428;Inherit;False;MatcapUVPro;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;46;954.0641,-1798.429;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;593.8337,-1829.421;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;45;746.3487,-1845.815;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;49;-568.1992,-1591.291;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-3037.198,-1420.599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2857.749,-1630.318;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-3392.851,-1616.264;Inherit;False;Property;_SlimeTilling;SlimeTilling;9;0;Create;True;0;0;0;False;0;False;0;1.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-3313.182,-1391;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;37;-3320.748,-1323.977;Inherit;False;Property;_SlimeNoiseSpeed;SlimeNoiseSpeed;10;0;Create;True;0;0;0;False;0;False;0,0;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3027.718,-1658.224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-3428.778,-1857.7;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-3360.685,-2054.254;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;56;-3191.988,-2011.406;Inherit;True;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;55;-3614.686,-1990.254;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-3601.324,-2161.77;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;2;-856.4746,-1323.493;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-601.9395,-1258.603;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;320.2049,-1250.96;Inherit;False;Matcap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;28;1.638216,-1248.216;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-228.8359,-1224.25;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-2892.806,-1921.188;Inherit;True;Property;_SlimeNormalNoise;SlimeNormalNoise;11;0;Create;True;0;0;0;False;0;False;None;c33df331279fd444da15047ceafe5c50;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;30;-2648.884,-1723.408;Inherit;True;Property;_SlimeNoise;SlimeNoise;8;0;Create;True;0;0;0;False;0;False;-1;None;c33df331279fd444da15047ceafe5c50;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-1972.789,-2006.696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1980.146,-1896.24;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1890.476,-1821.928;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;61;-1744.041,-1826.445;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;57;-2324.957,-2108.121;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-3470.325,180.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-3485.234,-275.5661;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3444.833,-94.46588;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-3161.034,-148.7014;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;85;-5022.323,-714.8432;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;86;-4812.468,-649.5178;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;88;-4589.731,-605.1016;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;89;-4080.768,-601.5165;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;90;-3902.179,-605.1863;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;91;-4431.58,-529.2197;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-4227.154,-521.7971;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;78;-4438.075,-249.6347;Inherit;True;Property;_TextureSample1;Texture Sample 1;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;79;-4443.125,47.50126;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;80;-4461.935,353.9765;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;95;-4971.032,-387.1153;Inherit;True;Property;_SlimeNormalNoise1;SlimeNormalNoise;12;0;Create;True;0;0;0;False;0;False;None;34ddbd1f7f4b083429b383fe1e2de587;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.NormalizeNode;97;-2963.795,-128.284;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;98;-2750.09,-113.2236;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1588.638,-1838.505;Inherit;False;NormalWorld;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-771.8114,-1638.699;Inherit;False;105;TriNormalWorld;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;71;-4981.807,98.64831;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;72;-4975.167,254.0623;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;73;-4988.562,-165.237;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;103;-1920.823,173.8868;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;104;-2501.739,-107.7903;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2186.614,-67.67757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-2156.929,59.38444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-2048.097,216.7241;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-4815.245,-508.4228;Inherit;False;Property;_Contrast;Contrast;3;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-1631.52,147.8439;Inherit;False;TriNormalWorld;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-851.6558,-1201.283;Inherit;False;118;TriNormalWorldEZ;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-4034.435,1077.167;Inherit;False;TriNormalWorldEZ;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;117;-4561.936,989.6926;Inherit;True;Spherical;World;True;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;69;-5515.776,-217.6313;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-5275.771,-174.6313;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;93;-5537.512,-52.499;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-5190.193,-3.435542;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-5139.257,176.0247;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;107;-5562.47,341.5066;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-5295.5,451.8078;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;109;-5528.9,533.335;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;15;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.01,0.01;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;110;-5111.663,466.1948;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;124;-5038.803,1637.749;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;125;-5300.544,1759.881;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-4953.225,1808.945;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-4902.289,1988.405;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;129;-5325.502,2153.886;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-5058.532,2264.187;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;132;-4874.695,2278.574;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector3Node;131;-5291.932,2345.714;Inherit;False;Property;_VertexNoiseSpeed;VertexNoiseSpeed;16;0;Create;True;0;0;0;False;0;False;0,0,0;0.25,0.25,0.25;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;121;-4191.909,2069.274;Inherit;True;Spherical;World;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;123;-5322.808,1594.749;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-3755.392,2079.542;Inherit;False;VertexNoise;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-5025.91,2743.645;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-5222.21,2630.545;Inherit;False;133;VertexNoise;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-4799.711,2811.244;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;49.35361,203.3813;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-773.374,-353.9353;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;0;False;0;False;-1;None;6e28fee97da5d3246aa165b56421e0dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-770.198,-115.3754;Inherit;True;Property;_BaseMap;BaseMap;1;0;Create;True;0;0;0;False;0;False;-1;None;7d7fe099dd75fec45978283ad3f5d558;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-425.8992,-237.7757;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;14;-909.9502,208.7746;Inherit;True;Property;_EmissMap;EmissMap;2;0;Create;True;0;0;0;False;0;False;-1;None;7be9194c3d2525a40a5f223e91482a8c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-439.1692,247.5334;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-792.8866,437.8178;Inherit;False;23;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-1076.083,-261.1379;Inherit;False;47;MatcapUVPro;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-4999.839,3017.931;Inherit;False;Constant;_Float1;Float 1;19;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;96;-5497.641,180.2799;Inherit;False;Property;_NoiseTilling;NoiseTilling;14;0;Create;True;0;0;0;False;0;False;1,1,1;0.25,0.25,0.25;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;122;-4601.708,1782.586;Inherit;True;Property;_VertexNoise;VertexNoise;17;0;Create;True;0;0;0;False;0;False;None;1df0ae464403ce74199acb2dbbfdccbe;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-4572.361,2828.742;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;145;-4755.361,3013.742;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;146;-4393.361,2792.742;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-4158.111,2824.644;Inherit;False;Anim;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-5047.012,2908.744;Inherit;False;Property;_VertexIntensity;VertexIntensity;18;0;Create;True;0;0;0;False;0;False;0.01;1.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-7.575562,558.6567;Inherit;False;140;Anim;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;339.3922,223.1379;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.Vector3Node;126;-5319.673,1982.66;Inherit;False;Property;_NoiseVertexTilling;NoiseVertexTilling;13;0;Create;True;0;0;0;False;0;False;1,1,1;4.86,5.23,6.56;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;135;-5752.056,2770.944;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-5382.438,2837.471;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;149;-5775.907,3006.563;Inherit;False;Property;_VertexBais;VertexBais;19;0;Create;True;0;0;0;False;0;False;0,-1,0;0,-1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;150;-5533.103,3015.234;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;151;-5400.864,3077.019;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-5224.184,3185.411;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-5380.27,3250.447;Inherit;False;Constant;_Float2;Float 2;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;147;-5270.555,2903.782;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;16;0;27;0
WireConnection;21;0;15;0
WireConnection;21;1;22;0
WireConnection;29;0;21;0
WireConnection;23;0;29;0
WireConnection;15;0;16;0
WireConnection;15;4;17;0
WireConnection;15;1;18;0
WireConnection;15;2;19;0
WireConnection;15;3;20;0
WireConnection;5;0;3;0
WireConnection;40;0;48;0
WireConnection;40;1;64;0
WireConnection;41;0;52;0
WireConnection;42;0;50;0
WireConnection;44;0;42;1
WireConnection;50;0;41;0
WireConnection;50;1;40;0
WireConnection;52;0;51;0
WireConnection;47;0;46;0
WireConnection;46;0;45;0
WireConnection;43;0;44;0
WireConnection;43;1;42;0
WireConnection;45;0;43;0
WireConnection;38;0;35;0
WireConnection;38;1;37;0
WireConnection;34;0;33;0
WireConnection;34;1;38;0
WireConnection;33;0;56;0
WireConnection;33;1;32;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;56;0;54;0
WireConnection;3;0;2;0
WireConnection;3;1;65;0
WireConnection;7;0;28;0
WireConnection;28;0;6;0
WireConnection;6;0;5;0
WireConnection;30;0;67;0
WireConnection;30;1;34;0
WireConnection;58;0;57;1
WireConnection;58;1;30;1
WireConnection;60;0;57;2
WireConnection;60;1;30;2
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;59;3;57;3
WireConnection;61;0;59;0
WireConnection;81;0;90;1
WireConnection;81;1;80;0
WireConnection;82;0;90;2
WireConnection;82;1;78;0
WireConnection;83;0;90;0
WireConnection;83;1;79;0
WireConnection;84;0;82;0
WireConnection;84;1;83;0
WireConnection;84;2;81;0
WireConnection;86;0;85;0
WireConnection;88;0;86;0
WireConnection;88;1;87;0
WireConnection;89;0;88;0
WireConnection;89;1;92;0
WireConnection;90;0;89;0
WireConnection;91;0;88;0
WireConnection;92;0;91;0
WireConnection;92;1;91;1
WireConnection;92;2;91;2
WireConnection;78;0;95;0
WireConnection;78;1;73;0
WireConnection;79;0;95;0
WireConnection;79;1;71;0
WireConnection;80;0;95;0
WireConnection;80;1;72;0
WireConnection;97;0;84;0
WireConnection;98;0;97;0
WireConnection;63;0;61;0
WireConnection;71;0;115;0
WireConnection;72;0;115;0
WireConnection;73;0;115;0
WireConnection;103;0;101;0
WireConnection;99;0;104;1
WireConnection;99;1;98;0
WireConnection;100;0;104;2
WireConnection;100;1;98;1
WireConnection;101;0;99;0
WireConnection;101;1;100;0
WireConnection;101;3;104;3
WireConnection;105;0;103;0
WireConnection;118;0;117;0
WireConnection;117;0;95;0
WireConnection;117;9;115;0
WireConnection;117;4;87;0
WireConnection;70;0;69;0
WireConnection;70;1;93;0
WireConnection;114;0;70;0
WireConnection;114;1;96;0
WireConnection;115;0;114;0
WireConnection;115;1;108;0
WireConnection;108;0;107;0
WireConnection;108;1;109;0
WireConnection;110;0;108;0
WireConnection;124;0;123;0
WireConnection;124;1;125;0
WireConnection;127;0;124;0
WireConnection;127;1;126;0
WireConnection;128;0;127;0
WireConnection;128;1;130;0
WireConnection;130;0;129;0
WireConnection;130;1;131;0
WireConnection;132;0;130;0
WireConnection;121;0;122;0
WireConnection;121;9;128;0
WireConnection;133;0;121;0
WireConnection;136;0;137;0
WireConnection;136;1;148;0
WireConnection;136;2;147;1
WireConnection;136;3;152;0
WireConnection;138;0;136;0
WireConnection;138;1;139;0
WireConnection;138;2;143;0
WireConnection;13;0;11;0
WireConnection;13;1;25;0
WireConnection;9;1;8;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;25;0;14;0
WireConnection;25;1;26;0
WireConnection;144;0;138;0
WireConnection;144;1;145;0
WireConnection;146;0;144;0
WireConnection;140;0;146;0
WireConnection;0;2;13;0
WireConnection;0;11;142;0
WireConnection;148;0;135;0
WireConnection;148;1;149;0
WireConnection;150;0;135;0
WireConnection;150;1;149;0
WireConnection;151;0;150;0
WireConnection;152;0;151;0
WireConnection;152;1;153;0
ASEEND*/
//CHKSM=70DA5CB9578EE35F4B4D70B6B2FE4D48D15F3390