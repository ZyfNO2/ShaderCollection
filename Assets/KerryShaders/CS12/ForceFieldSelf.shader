// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceFieldSelf"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_HitSpread1("HitSpread", Float) = 1
		_HitFadeDistance1("HitFadeDistance", Float) = 6
		_HitFadePower1("HitFadePower", Float) = 1
		_HitNoiseIntensity1("HitNoiseIntensity", Float) = 1
		_HitRamp("HitRamp", 2D) = "white" {}
		_HitNoiseTilling("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoise("HitNoise", 2D) = "white" {}
		_HitWaveIntensity("HitWaveIntensity", Float) = 0.5
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_EmissColor("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 1
		_Size("Size", Range( 0 , 10)) = 1
		_FlowLight("FlowLight", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_DepthFadePower1("DepthFadePower", Float) = 1
		_DissloveRampMap("DissloveRampMap", 2D) = "white" {}
		_DepthFadeDistance1("DepthFadeDistance", Float) = 1
		_DissloveSpread("DissloveSpread", Float) = 1
		_DissloveEdgeIntensity("DissloveEdgeIntensity", Float) = 1
		_DisslovePoint("DisslovePoint", Vector) = (0,0,0,0)
		_DissloveAmount("DissloveAmount", Float) = 0
		_DissloveNoise("DissloveNoise", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEIsFrontFacing : VFACE;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float AffectorAmount;
		uniform float _CullMode;
		uniform float HitSize[20];
		uniform float4 HitPosition[20];
		uniform float4 _EmissColor;
		uniform float _EmissIntensity;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeDistance1;
		uniform float _DepthFadePower1;
		uniform sampler2D _FlowLight;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform sampler2D _HitRamp;
		uniform sampler2D _HitNoise;
		uniform float3 _HitNoiseTilling;
		uniform float _HitNoiseIntensity1;
		uniform float _HitSpread1;
		uniform float _HitFadeDistance1;
		uniform float _HitFadePower1;
		uniform float _HitWaveIntensity;
		uniform sampler2D _DissloveRampMap;
		uniform float3 _DisslovePoint;
		uniform float _DissloveAmount;
		uniform float _DissloveNoise;
		uniform float _DissloveSpread;
		uniform float _DissloveEdgeIntensity;


		inline float4 TriplanarSampling45( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float HitWaveFunction18( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
		{
			float hit_result;
			for(int j = 0;j < AffectorAmount;j++)
			{
			float distance_mask = distance(HitPosition[j].xyz,WorldPos);
			float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0);
			float2 ramp_uv = float2(hit_range,0.5);
			float hit_wave = tex2D(RampTex,ramp_uv).r; 
			float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower);
			hit_result = hit_result + hit_fade * hit_wave;
			}
			return saturate(hit_result);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 switchResult141 = (((i.ASEIsFrontFacing>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV53 = dot( switchResult141, ase_worldViewDir );
			float fresnelNode53 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV53, _RimPower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth99 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth99 = abs( ( screenDepth99 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance1 ) );
			float clampResult97 = clamp( distanceDepth99 , 0.0 , 1.0 );
			float RimFactor57 = ( fresnelNode53 + ( 1.0 - ( clampResult97 * _DepthFadePower1 ) ) );
			float2 temp_output_4_0_g1 = (( i.uv_texcoord / _Size )).xy;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float2 temp_cast_0 = (0.5).xx;
			sampler2D RampTex18 = _HitRamp;
			float3 WorldPos18 = ase_worldPos;
			float4 triplanar45 = TriplanarSampling45( _HitNoise, ( ase_worldPos * _HitNoiseTilling ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float HitNoise18 = ( triplanar45.x * _HitNoiseIntensity1 );
			float HitSpread18 = _HitSpread1;
			float HitFadeDistance18 = _HitFadeDistance1;
			float HitFadePower18 = _HitFadePower1;
			float localHitWaveFunction18 = HitWaveFunction18( RampTex18 , WorldPos18 , HitNoise18 , HitSpread18 , HitFadeDistance18 , HitFadePower18 );
			float HitWave51 = localHitWaveFunction18;
			float2 temp_output_17_0_g1 = float2( 0.2,0.2 );
			float mulTime22_g1 = _Time.y * 0.2;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( -(( ( (tex2D( _FlowMap, uv_FlowMap )).rg - temp_cast_0 ) + HitWave51 )*2.0 + -1.0) * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( -(( ( (tex2D( _FlowMap, uv_FlowMap )).rg - temp_cast_0 ) + HitWave51 )*2.0 + -1.0) * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _FlowLight, temp_output_11_0_g1 ) , tex2D( _FlowLight, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float4 temp_cast_1 = (RimFactor57).xxxx;
			float smoothstepResult83 = smoothstep( 0.8 , 1.0 , i.uv_texcoord.y);
			float4 lerpResult81 = lerp( lerpResult9_g1 , temp_cast_1 , smoothstepResult83);
			float4 FlowColor77 = lerpResult81;
			float4 temp_output_85_0 = ( RimFactor57 * FlowColor77 );
			float3 objToWorld114 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float WaveNoise131 = triplanar45.r;
			float clampResult122 = clamp( ( ( ( distance( _DisslovePoint , ( ase_worldPos - objToWorld114 ) ) - _DissloveAmount ) - ( WaveNoise131 * _DissloveNoise ) ) / _DissloveSpread ) , 0.0 , 1.0 );
			float2 appendResult124 = (float2(clampResult122 , 0.5));
			float DissloveEdge116 = ( tex2D( _DissloveRampMap, appendResult124 ).r * _DissloveEdgeIntensity );
			float4 temp_output_105_0 = ( temp_output_85_0 + ( ( temp_output_85_0 + _HitWaveIntensity ) * HitWave51 ) + DissloveEdge116 );
			o.Emission = ( ( _EmissColor * _EmissIntensity ) * temp_output_105_0 ).rgb;
			float grayscale87 = Luminance(temp_output_105_0.rgb);
			float smoothstepResult125 = smoothstep( 0.0 , 0.1 , ( 1.0 - clampResult122 ));
			float DissloveAlpha126 = smoothstepResult125;
			float clampResult64 = clamp( ( grayscale87 * DissloveAlpha126 ) , 0.0 , 1.0 );
			o.Alpha = clampResult64;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;139;709.1877,-845.6083;Inherit;False;222;166;Comment;1;138;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;137;-1460.149,2033.997;Inherit;False;2468.789;795.823;Comment;22;110;111;112;113;114;118;121;123;124;126;125;127;122;130;132;133;119;134;116;135;120;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1454.621,-851.0196;Inherit;False;2098.386;1019.115;Comment;17;67;75;74;83;84;82;81;65;80;79;76;68;72;71;77;109;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1457.548,1279.605;Inherit;False;2114.8;751.9683;Comment;15;100;101;99;98;97;96;57;56;55;54;53;102;140;141;142;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1459.903,175.6343;Inherit;False;2180.677;1086.155;Comment;18;51;47;45;50;49;48;28;34;38;18;36;37;35;29;43;42;39;131;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-656.8372,429.5121;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-488.933,687.8094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-276.7411,1098.309;Inherit;False;Property;_HitFadePower1;HitFadePower;3;0;Create;True;0;0;0;False;0;False;1;2.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-254.6003,786.3397;Inherit;False;Property;_HitSpread1;HitSpread;1;0;Create;True;0;0;0;False;0;False;1;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-277.0419,976.2088;Inherit;False;Property;_HitFadeDistance1;HitFadeDistance;2;0;Create;True;0;0;0;False;0;False;6;5.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-853.9899,925.6338;Inherit;False;Property;_HitNoiseIntensity1;HitNoiseIntensity;4;0;Create;True;0;0;0;False;0;False;1;2.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-588.982,225.6343;Inherit;True;Property;_HitRamp;HitRamp;5;0;Create;True;0;0;0;False;0;False;256d86d8496a4e0f947100121f1fafb2;256d86d8496a4e0f947100121f1fafb2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldPosInputsNode;48;-1375.62,572.6498;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;49;-1338.62,748.65;Inherit;False;Property;_HitNoiseTilling;HitNoiseTilling;6;0;Create;True;0;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1135.62,625.6498;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;45;-967.6954,580.6961;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;47;-1375.62,369.6499;Inherit;True;Property;_HitNoise;HitNoise;7;0;Create;True;0;0;0;False;0;False;8fb9e9053de2e2746a5a29ec8f128c39;3c6ccf6f19fbafc4c9078a642ec01714;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;416.9167,732.9805;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-811.3349,1329.605;Inherit;False;Property;_RimBias;RimBias;9;0;Create;True;0;0;0;False;0;False;0;5.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-881.5483,1397.441;Inherit;False;Property;_RimScale;RimScale;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-822.5483,1482.441;Inherit;False;Property;_RimPower;RimPower;11;0;Create;True;0;0;0;False;0;False;2;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;332.8905,308.8661;Inherit;False;Global;AffectorAmount;AffectorAmount;6;0;Create;True;0;0;0;True;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;42;117.8362,300.1536;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;39;-96.33105,301.724;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;59;1176.35,417.0992;Inherit;False;Property;_EmissColor;EmissColor;12;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.621796,0.6360021,0.8396226,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;1237.45,636.7993;Inherit;False;Property;_EmissIntensity;EmissIntensity;13;0;Create;True;0;0;0;False;0;False;1;26.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;1531.25,489.8993;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1719.749,657.5995;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;419.765,-367.0401;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-681.6195,-44.32744;Inherit;False;Constant;_FlowSpeed;FlowSpeed;14;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;68;-860.5078,-801.0196;Inherit;True;Property;_FlowLight;FlowLight;17;0;Create;True;0;0;0;False;0;False;None;d98257ad2e6737e4b826d83fb9bda1b1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;65;-157.1243,-520.7816;Inherit;False;Flow;14;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;6;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;55;FLOAT;1;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;81;219.9317,-376.8383;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-154.8997,-34.36783;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;84;-112.4588,-204.3516;Inherit;False;57;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;83;52.02193,15.29497;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-22.24928,1703.57;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;97;-450.2624,1645.115;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-248.2926,1695.417;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;99;-757.687,1599.646;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-548.594,1835.817;Inherit;False;Property;_DepthFadePower1;DepthFadePower;19;0;Create;True;0;0;0;False;0;False;1;6.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1277.453,1681.481;Inherit;False;Property;_DepthFadeDistance1;DepthFadeDistance;21;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-324.5327,1576.188;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;419.3957,1500.367;Inherit;False;RimFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;87;1546.759,1186.725;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;692.0496,938.0993;Inherit;False;57;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;681.4617,1050.616;Inherit;False;77;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;1349.103,797.1424;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LuminanceNode;86;1549.861,1114.52;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-1093.621,-596.327;Inherit;True;Property;_FlowMap;FlowMap;18;0;Create;True;0;0;0;False;0;False;-1;None;00fdafc17a6844f581c4da67dc9bfe8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;75;-1363.579,-583.5117;Inherit;False;0;74;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-645.7491,-607.9981;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;76;-776.1132,-441.4009;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-473.0879,-473.4331;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-320.8174,-466.0801;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-782.0899,-367.8337;Inherit;False;Constant;_Float1;Float 1;15;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-790.1175,-298.3802;Inherit;False;51;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;71;-683.5162,-160.1919;Inherit;False;Constant;_FlowStrength;FlowStrength;14;0;Create;True;0;0;0;False;0;False;0.2,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;64;1892.28,1258.544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;1770.359,1278.036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;1545.765,1405.751;Inherit;False;126;DissloveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2305.339,1117.552;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ForceFieldSelf;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;_CullMode;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;1116.103,1297.79;Inherit;False;116;DissloveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;1074.621,921.6635;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;1151.235,1017.609;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-502.7075,621.6591;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;918.7585,898.7247;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;107;903.3676,1043.869;Inherit;False;Property;_HitWaveIntensity;HitWaveIntensity;8;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;936.7305,1115.681;Inherit;False;51;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;110;-1349.781,2123.478;Inherit;False;Property;_DisslovePoint;DisslovePoint;24;0;Create;True;0;0;0;False;0;False;0,0,0;0,9.7,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;111;-1095.149,2199.312;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;112;-1408.149,2316.312;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-1187.149,2417.312;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;114;-1410.149,2515.312;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;118;-880.4471,2255.457;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;-442.161,2376.598;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;123;80.3458,2294.017;Inherit;True;Property;_DissloveRampMap;DissloveRampMap;20;0;Create;True;0;0;0;False;0;False;-1;None;c3a152efe6270e5488f4c603ecbff83e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;124;-86.65429,2427.017;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;262.2105,2087.997;Inherit;False;DissloveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;125;16.21041,2083.997;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;127;-150.4183,2184.98;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;122;-261.5728,2368.176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;130;-680.0328,2309.51;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;-1084.158,2507.82;Inherit;False;131;WaveNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-848.1575,2530.82;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1022.069,2366.429;Inherit;False;Property;_DissloveAmount;DissloveAmount;25;0;Create;True;0;0;0;False;0;False;0;19.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1190.158,2713.82;Inherit;False;Property;_DissloveNoise;DissloveNoise;26;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;784.6401,2376.32;Inherit;False;DissloveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;510.0013,2497.925;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-669.2103,2497.434;Inherit;False;Property;_DissloveSpread;DissloveSpread;22;0;Create;True;0;0;0;False;0;False;1;0.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;197.639,2651.07;Inherit;False;Property;_DissloveEdgeIntensity;DissloveEdgeIntensity;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;759.1877,-795.6083;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;140;-1304.96,1349.119;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwitchByFaceNode;141;-1050.96,1330.119;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;142;-1087.96,1469.119;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;53;-526.6711,1394.673;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;18;61.9468,696.8222;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;Create;6;True;RampTex;SAMPLER2D;0;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;;False;6;0;SAMPLER2D;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
WireConnection;35;0;45;1
WireConnection;35;1;34;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;45;0;47;0
WireConnection;45;9;50;0
WireConnection;51;0;18;0
WireConnection;60;0;59;0
WireConnection;60;1;61;0
WireConnection;63;0;60;0
WireConnection;63;1;105;0
WireConnection;77;0;81;0
WireConnection;65;5;68;0
WireConnection;65;2;67;0
WireConnection;65;18;109;0
WireConnection;65;17;71;0
WireConnection;65;24;72;0
WireConnection;81;0;65;0
WireConnection;81;1;84;0
WireConnection;81;2;83;0
WireConnection;83;0;82;2
WireConnection;96;0;98;0
WireConnection;97;0;99;0
WireConnection;98;0;97;0
WireConnection;98;1;101;0
WireConnection;99;0;100;0
WireConnection;102;0;53;0
WireConnection;102;1;96;0
WireConnection;57;0;102;0
WireConnection;87;0;105;0
WireConnection;105;0;85;0
WireConnection;105;1;104;0
WireConnection;105;2;129;0
WireConnection;74;1;75;0
WireConnection;76;0;74;0
WireConnection;79;0;76;0
WireConnection;79;1;80;0
WireConnection;109;0;79;0
WireConnection;109;1;108;0
WireConnection;64;0;128;0
WireConnection;128;0;87;0
WireConnection;128;1;117;0
WireConnection;0;2;63;0
WireConnection;0;9;64;0
WireConnection;106;0;85;0
WireConnection;106;1;107;0
WireConnection;104;0;106;0
WireConnection;104;1;52;0
WireConnection;131;0;45;1
WireConnection;85;0;62;0
WireConnection;85;1;78;0
WireConnection;111;0;110;0
WireConnection;111;1;113;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;118;0;111;0
WireConnection;118;1;119;0
WireConnection;121;0;130;0
WireConnection;121;1;120;0
WireConnection;123;1;124;0
WireConnection;124;0;122;0
WireConnection;126;0;125;0
WireConnection;125;0;127;0
WireConnection;127;0;122;0
WireConnection;122;0;121;0
WireConnection;130;0;118;0
WireConnection;130;1;133;0
WireConnection;133;0;132;0
WireConnection;133;1;134;0
WireConnection;116;0;135;0
WireConnection;135;0;123;1
WireConnection;135;1;136;0
WireConnection;141;0;140;0
WireConnection;141;1;142;0
WireConnection;142;0;140;0
WireConnection;53;0;141;0
WireConnection;53;1;54;0
WireConnection;53;2;55;0
WireConnection;53;3;56;0
WireConnection;18;0;28;0
WireConnection;18;1;29;0
WireConnection;18;2;35;0
WireConnection;18;3;36;0
WireConnection;18;4;38;0
WireConnection;18;5;37;0
ASEEND*/
//CHKSM=9B6EC165E6A00D8FB378F3C70AC005D9426C8648