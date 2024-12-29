// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceField"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_HitRampTex("HitRampTex", 2D) = "white" {}
		_HitSpread("HitSpread", Float) = 0
		_HitNoise("HitNoise", 2D) = "white" {}
		_HitNoiseTilling("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoiseIntensity("HitNoiseIntensity", Float) = 0
		_HitFadePower("HitFadePower", Float) = 1
		_HitFadeDistance("HitFadeDistance", Float) = 6
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow noforwardadd 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float AffectorAmount;
		uniform float _CullMode;
		uniform float HitSize[20];
		uniform float4 HitPosition[20];
		uniform sampler2D _HitRampTex;
		uniform sampler2D _HitNoise;
		uniform float3 _HitNoiseTilling;
		uniform float _HitNoiseIntensity;
		uniform float _HitSpread;
		uniform float _HitFadeDistance;
		uniform float _HitFadePower;


		inline float4 TriplanarSampling42( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		float HitWaveFunction35( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
			c.a = 1;
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
			sampler2D RampTex35 = _HitRampTex;
			float3 ase_worldPos = i.worldPos;
			float3 WorldPos35 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar42 = TriplanarSampling42( _HitNoise, ( ase_worldPos * _HitNoiseTilling ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise123 = triplanar42.x;
			float HitNoise35 = ( WaveNoise123 * _HitNoiseIntensity );
			float HitSpread35 = _HitSpread;
			float HitFadeDistance35 = _HitFadeDistance;
			float HitFadePower35 = _HitFadePower;
			float localHitWaveFunction35 = HitWaveFunction35( RampTex35 , WorldPos35 , HitNoise35 , HitSpread35 , HitFadeDistance35 , HitFadePower35 );
			float HitWave47 = localHitWaveFunction35;
			float3 temp_cast_0 = (HitWave47).xxx;
			o.Emission = temp_cast_0 + 1E-5;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
7;188;1906;831;1709.342;400.2067;2.020801;True;False
Node;AmplifyShaderEditor.CommentaryNode;41;-3148.643,-294.2226;Inherit;False;2291.384;1279.597;HitWave;18;37;35;40;39;28;13;30;36;16;5;17;42;43;46;44;45;47;123;HitWave;0.489655,1,0,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;44;-3093.004,362.9435;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;45;-3066.004,530.9434;Inherit;False;Property;_HitNoiseTilling;HitNoiseTilling;4;0;Create;True;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2818.005,355.9434;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;43;-3092.004,128.9434;Inherit;True;Property;_HitNoise;HitNoise;3;0;Create;True;0;0;False;0;False;None;5a3a597430ec2c64a9d2003e0e8ed12d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TriplanarNode;42;-2653.765,326.4727;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-2250.359,355.5001;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2313.652,566.4393;Inherit;False;Property;_HitNoiseIntensity;HitNoiseIntensity;5;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-1962.659,219.8757;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;36;-1941.921,-5.445163;Inherit;True;Property;_HitRampTex;HitRampTex;1;0;Create;True;0;0;False;0;False;None;bfb5d11eb2154099bda5558461f45026;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;28;-1931.486,654.4937;Inherit;False;Property;_HitFadeDistance;HitFadeDistance;7;0;Create;True;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2030.821,478.9484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1888.486,804.4941;Inherit;False;Property;_HitFadePower;HitFadePower;6;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1893.352,544.2117;Inherit;False;Property;_HitSpread;HitSpread;2;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;35;-1586.767,173.5148;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1215.024,159.1205;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;131;-718.2159,-183.3618;Inherit;False;228;165;Properties;1;130;Properties;1,0,0,1;0;0
Node;AmplifyShaderEditor.GlobalArrayNode;37;-2393.205,-243.1586;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;214.0623,555.4351;Inherit;False;47;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1907.419,-234.9648;Inherit;False;Global;AffectorAmount;AffectorAmount;6;0;Create;False;0;0;True;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;39;-2134.987,-244.2226;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-668.2159,-133.3618;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;983.5447,380.6408;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ForceField;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;130;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;42;0;43;0
WireConnection;42;9;46;0
WireConnection;123;0;42;1
WireConnection;16;0;123;0
WireConnection;16;1;17;0
WireConnection;35;0;36;0
WireConnection;35;1;5;0
WireConnection;35;2;16;0
WireConnection;35;3;13;0
WireConnection;35;4;28;0
WireConnection;35;5;30;0
WireConnection;47;0;35;0
WireConnection;0;15;48;0
ASEEND*/
//CHKSM=89E91218DBA4723B1A255E8190CCE67179AA1136