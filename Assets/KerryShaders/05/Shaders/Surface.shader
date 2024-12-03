// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Surface"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0
		_Expand("Expand", Float) = 0
		_Grow("Grow", Range( -1 , 1)) = 0.2
		_GrowMin("GrowMin", Range( 0 , 1)) = 0
		_GrowMax("GrowMax", Range( 0 , 1)) = 0
		_EndMin("EndMin", Range( 0 , 1)) = 0
		_EndMax("EndMax", Range( 0 , 1.5)) = 0
		_Scale("Scale", Float) = 0
		_Diffuse("Diffuse", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Roughness("Roughness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _GrowMin;
		uniform float _GrowMax;
		uniform float _Grow;
		uniform float _EndMin;
		uniform float _EndMax;
		uniform float _Expand;
		uniform float _Scale;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform sampler2D _Roughness;
		uniform float4 _Roughness_ST;
		uniform float _Cutoff = 0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float temp_output_6_0 = ( v.texcoord.xy.y - _Grow );
			float smoothstepResult9 = smoothstep( _GrowMin , _GrowMax , temp_output_6_0);
			float smoothstepResult12 = smoothstep( _EndMin , _EndMax , v.texcoord.xy.y);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz = ( ase_vertex3Pos + ( ( max( smoothstepResult9 , smoothstepResult12 ) * ase_vertexNormal * _Expand * 0.005 ) + ( ase_vertexNormal * _Scale * 0.01 ) ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			o.Albedo = tex2D( _Diffuse, uv_Diffuse ).rgb;
			float2 uv_Roughness = i.uv_texcoord * _Roughness_ST.xy + _Roughness_ST.zw;
			o.Smoothness = ( 1.0 - tex2D( _Roughness, uv_Roughness ).r );
			o.Alpha = 1;
			float temp_output_6_0 = ( i.uv_texcoord.y - _Grow );
			clip( ( 1.0 - temp_output_6_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;141,31;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Surface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-500.955,869.8377;Inherit;False;Property;_Expand;Expand;1;0;Create;True;0;0;0;False;0;False;0;-5.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-512.955,962.8378;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;0.005;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-104.6969,92.09515;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;17;-489.5308,508.1068;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-147.8368,658.6175;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;77.4632,871.0286;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;19;-215.6002,921.3096;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-33.15391,1018.994;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-179.6855,1136.796;Inherit;False;Property;_Scale;Scale;7;0;Create;True;0;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-125.0953,1297.694;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-334.719,-658.6694;Inherit;True;Property;_Diffuse;Diffuse;8;0;Create;True;0;0;0;False;0;False;-1;None;af42bface2e2f5a4cbff1e6bada59ab0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;24;-365.1538,-376.3541;Inherit;True;Property;_Normal;Normal;9;0;Create;True;0;0;0;False;0;False;-1;None;8e0b8dd8a1fb4cd4784b58ca8409871e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-456.4537,-140.1154;Inherit;True;Property;_Roughness;Roughness;10;0;Create;True;0;0;0;False;0;False;-1;None;79722df8209c0d8419cec564ccf46330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;26;-102.6666,-56.80444;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;1;-505.0962,697.9788;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;8.913055,455.1056;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;29;-136.5856,402.56;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-446.9828,50.24622;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-758.744,-28.57248;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-874.7438,123.4276;Inherit;False;Property;_Grow;Grow;2;0;Create;True;0;0;0;False;0;False;0.2;-0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-295.4529,247.6765;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-662.6825,281.1792;Inherit;False;Property;_GrowMin;GrowMin;3;0;Create;True;0;0;0;False;0;False;0;0.507;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-682.1824,366.9792;Inherit;False;Property;_GrowMax;GrowMax;4;0;Create;True;0;0;0;False;0;False;0;0.917;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-687.9189,569.2552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-994.7188,587.4552;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1079.219,759.0554;Inherit;False;Property;_EndMin;EndMin;5;0;Create;True;0;0;0;False;0;False;0;0.604;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1051.919,830.5551;Inherit;False;Property;_EndMax;EndMax;6;0;Create;True;0;0;0;False;0;False;0;1.359;0;1.5;0;1;FLOAT;0
WireConnection;0;0;23;0
WireConnection;0;1;24;0
WireConnection;0;4;26;0
WireConnection;0;10;8;0
WireConnection;0;11;28;0
WireConnection;8;0;6;0
WireConnection;17;0;9;0
WireConnection;17;1;12;0
WireConnection;2;0;17;0
WireConnection;2;1;1;0
WireConnection;2;2;3;0
WireConnection;2;3;4;0
WireConnection;18;0;2;0
WireConnection;18;1;20;0
WireConnection;20;0;19;0
WireConnection;20;1;21;0
WireConnection;20;2;22;0
WireConnection;26;0;25;1
WireConnection;28;0;29;0
WireConnection;28;1;18;0
WireConnection;6;0;5;2
WireConnection;6;1;7;0
WireConnection;9;0;6;0
WireConnection;9;1;10;0
WireConnection;9;2;11;0
WireConnection;12;0;13;2
WireConnection;12;1;14;0
WireConnection;12;2;16;0
ASEEND*/
//CHKSM=737F56B35A96D07C6BF291AE594CE8BE83674042