// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HologramDepthMask"
{
	Properties
	{
		_RandomVertexOffset("RandomVertexOffset", Vector) = (0,0,0,0)
		_RandomTilling("RandomTilling", Float) = 0
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		_GlitchSpeed("Glitch Speed", Float) = 0
		_GlitchHardness("GlitchHardness", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		ColorMask 0
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float vertexToFrag162;
		};

		uniform float3 _RandomVertexOffset;
		uniform float _RandomTilling;
		uniform float3 _ScanlineVertexOffset;
		sampler2D _Sampler21160;
		uniform float _GlitchSpeed;
		uniform float _GlitchHardness;


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
			float3 objToWorld117 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime119 = _Time.y * -5.0;
			float mulTime122 = _Time.y * -1.0;
			float2 appendResult123 = (float2((( objToWorld117.x + objToWorld117.y + objToWorld117.z )*200.0 + mulTime119) , mulTime122));
			float simplePerlin2D124 = snoise( appendResult123 );
			simplePerlin2D124 = simplePerlin2D124*0.5 + 0.5;
			float clampResult130 = clamp( (simplePerlin2D124*2.0 + -1.0) , 0.0 , 1.0 );
			o.vertexToFrag162 = clampResult130;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 viewToObjDir116 = mul( UNITY_MATRIX_T_MV, float4( _RandomVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = i.worldPos;
			float mulTime105 = _Time.y * -2.5;
			float mulTime108 = _Time.y * -2.0;
			float2 appendResult106 = (float2((ase_worldPos.y*_RandomTilling + mulTime105) , mulTime108));
			float simplePerlin2D107 = snoise( appendResult106 );
			simplePerlin2D107 = simplePerlin2D107*0.5 + 0.5;
			float temp_output_131_0 = ( (simplePerlin2D107*2.0 + -1.0) * i.vertexToFrag162 );
			float2 break132 = appendResult106;
			float2 appendResult135 = (float2(( 20.0 * break132.x ) , break132.y));
			float simplePerlin2D136 = snoise( appendResult135 );
			simplePerlin2D136 = simplePerlin2D136*0.5 + 0.5;
			float clampResult138 = clamp( (simplePerlin2D136*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset114 = ( ( viewToObjDir116 * 0.01 ) * ( temp_output_131_0 + ( temp_output_131_0 * clampResult138 ) ) );
			float3 viewToObjDir150 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld3_g16 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult9_g16 = (float2(0.5 , (( ase_worldPos.y - objToWorld3_g16.y )*_GlitchSpeed + _Time.y)));
			float3 ScanlineGlitch154 = ( ( viewToObjDir150 * 0.01 ) * ( ( tex2D( _Sampler21160, appendResult9_g16 ).r - _GlitchHardness ) * 1.0 ) );
			o.Alpha = ( GlitchVertexOffset114 + ScanlineGlitch154 ).x;
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
				float1 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.x = customInputData.vertexToFrag162;
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
				surfIN.vertexToFrag162 = IN.customPack1.x;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
Node;AmplifyShaderEditor.CommentaryNode;141;-1454.728,2470.686;Inherit;False;3642.201;1540.254;RandomGlicth;35;105;104;102;117;103;108;106;120;118;119;132;134;122;121;123;133;135;124;136;107;129;109;137;130;111;131;113;116;139;112;140;110;114;138;162;RandomGlicth;0.07586217,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;105;-1324.728,2963.933;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;117;-936.635,3150.512;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;104;-1400.728,2813.933;Inherit;False;Property;_RandomTilling;RandomTilling;2;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;102;-1404.728,2649.933;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;120;-698.5827,3311.681;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;119;-646.6347,3405.512;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-658.6347,3176.512;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-1072.728,2981.933;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;103;-1111.729,2712.933;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;122;-443.5828,3510.681;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;121;-450.5828,3180.681;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;106;-817.7288,2744.933;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;132;-641.0099,3786.444;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;123;-175.5838,3236.681;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-533.2615,3689.772;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-340.9255,3705.884;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;124;-25.6998,3233.268;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;264.8739,3234.084;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-193.9044,3771.339;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;17.7717,3752.94;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;107;-475.1577,2745.742;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;130;521.8738,3240.084;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;137;289.1331,3751.441;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;162;666.3201,3237.333;Inherit;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;109;37.28129,2756.715;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;155;-1352.594,1778.356;Inherit;False;1579.867;677.9792;ScanlieGlitch;12;150;154;149;153;151;152;148;147;145;146;144;160;ScanlieGlitch;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;111;995.4727,2520.686;Inherit;False;Property;_RandomVertexOffset;RandomVertexOffset;1;0;Create;True;0;0;0;False;0;False;0,0,0;-2.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;827.9831,2784.188;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;138;580.1331,3750.441;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;149;-863.6311,1828.356;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;3;0;Create;True;0;0;0;False;0;False;0,0,0;3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;972.8409,3014.435;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1232.582,2349.135;Inherit;False;Property;_GlitchHardness;GlitchHardness;8;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;144;-1229.211,1875.065;Inherit;True;Property;_GlicthTex;GlicthTex;4;0;Create;True;0;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;113;1324.266,2725.81;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;116;1230.658,2527.651;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;151;-534.8378,2033.48;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1246.344,2065.927;Inherit;False;Property;_GlitchFreq;GlitchFreq;5;0;Create;True;0;0;0;False;0;False;2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1231.482,2265.334;Inherit;False;Property;_GlitchWidth;GlitchWidth;7;0;Create;True;0;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;150;-628.4458,1835.321;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-1246.694,2174.379;Inherit;False;Property;_GlitchSpeed;Glitch Speed;6;0;Create;True;0;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;1216.199,2825.076;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;1546.473,2622.686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;160;-808.9105,2149.965;Inherit;False;Scanline;-1;;16;47afd462729c0f846bae803d62931356;0;6;21;SAMPLER2D;_Sampler21160;False;16;FLOAT;0;False;19;FLOAT;1;False;20;FLOAT;0;False;22;FLOAT;1;False;23;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-367.5807,1929.319;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;1721.473,2782.686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-200.2382,2097.647;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-16.72649,2113.199;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;1915.473,2789.686;Inherit;False;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;283.0519,104.2823;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;HologramDepthMask;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;_ZWriteMode;0;False;;False;0;False;;0;False;;True;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;12;all;False;False;False;False;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-646.9158,307.0373;Inherit;False;114;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-618.6063,431.2659;Inherit;False;154;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-210.6065,351.266;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;118;0;117;1
WireConnection;118;1;117;2
WireConnection;118;2;117;3
WireConnection;103;0;102;2
WireConnection;103;1;104;0
WireConnection;103;2;105;0
WireConnection;121;0;118;0
WireConnection;121;1;120;0
WireConnection;121;2;119;0
WireConnection;106;0;103;0
WireConnection;106;1;108;0
WireConnection;132;0;106;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;133;0;134;0
WireConnection;133;1;132;0
WireConnection;124;0;123;0
WireConnection;129;0;124;0
WireConnection;135;0;133;0
WireConnection;135;1;132;1
WireConnection;136;0;135;0
WireConnection;107;0;106;0
WireConnection;130;0;129;0
WireConnection;137;0;136;0
WireConnection;162;0;130;0
WireConnection;109;0;107;0
WireConnection;131;0;109;0
WireConnection;131;1;162;0
WireConnection;138;0;137;0
WireConnection;139;0;131;0
WireConnection;139;1;138;0
WireConnection;116;0;111;0
WireConnection;150;0;149;0
WireConnection;140;0;131;0
WireConnection;140;1;139;0
WireConnection;112;0;116;0
WireConnection;112;1;113;0
WireConnection;160;19;148;0
WireConnection;160;22;146;0
WireConnection;152;0;150;0
WireConnection;152;1;151;0
WireConnection;110;0;112;0
WireConnection;110;1;140;0
WireConnection;153;0;152;0
WireConnection;153;1;160;0
WireConnection;154;0;153;0
WireConnection;114;0;110;0
WireConnection;0;9;156;0
WireConnection;156;0;115;0
WireConnection;156;1;157;0
ASEEND*/
//CHKSM=2E5C46E289B2935B0117E27088427E4E73E2F9FF