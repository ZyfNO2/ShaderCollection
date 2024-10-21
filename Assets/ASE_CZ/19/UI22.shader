// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UI22"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_AddTexture("AddTexture", 2D) = "black" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0.3
		_NoiseTexture("NoiseTexture", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0.2,0.1,0,0)
		[HDR]_AddColor("AddColor", Color) = (1,1,1,1)
		_YSpeed("YSpeed", Float) = 1
		_jiange3("jiange3", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _AddTexture;
			uniform float4 _AddTexture_ST;
			uniform float _YSpeed;
			uniform float _jiange3;
			uniform sampler2D _NoiseTexture;
			uniform float2 _NoiseSpeed;
			uniform float4 _NoiseTexture_ST;
			uniform float _NoiseIntensity;
			uniform float4 _AddColor;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
				float2 uv_AddTexture = IN.texcoord.xy * _AddTexture_ST.xy + _AddTexture_ST.zw;
				float2 appendResult66 = (float2(0.0 , _YSpeed));
				float4 _Vector1 = float4(0,1,-1,1);
				float2 temp_cast_0 = (_Vector1.x).xx;
				float2 temp_cast_1 = (_Vector1.y).xx;
				float2 temp_cast_2 = (_Vector1.z).xx;
				float2 temp_cast_3 = (_Vector1.w).xx;
				float2 temp_output_72_0 = (temp_cast_2 + (frac( ( _Time.y * appendResult66 ) ) - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0));
				float2 temp_cast_4 = (_Vector1.x).xx;
				float2 temp_cast_5 = (_Vector1.y).xx;
				float2 temp_cast_6 = (_Vector1.z).xx;
				float2 temp_cast_7 = (_Vector1.w).xx;
				float2 ifLocalVar63 = 0;
				if( fmod( _Time.y , ( ( 1.0 / _YSpeed ) + _jiange3 ) ) >= _jiange3 )
				ifLocalVar63 = temp_output_72_0;
				else
				ifLocalVar63 = float2( -1,-1 );
				float2 uv_NoiseTexture = IN.texcoord.xy * _NoiseTexture_ST.xy + _NoiseTexture_ST.zw;
				float2 panner12 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTexture);
				float2 temp_cast_8 = (tex2D( _NoiseTexture, panner12 ).r).xx;
				float2 lerpResult8 = lerp( ( uv_AddTexture + ifLocalVar63 ) , temp_cast_8 , _NoiseIntensity);
				
				fixed4 c = ( ( tex2DNode2 + ( tex2DNode2.a * tex2D( _AddTexture, lerpResult8 ) * _AddColor ) ) * IN.color );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
493.3333;72.66667;1656;962;3016.422;195.3846;1.05574;False;False
Node;AmplifyShaderEditor.RangedFloatNode;67;-2868.852,526.7014;Inherit;False;Property;_YSpeed;YSpeed;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-2859.753,62.40125;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;56;-2624.257,337.9852;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-2615.351,511.1013;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2376.735,338.7988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2558.153,201.7011;Inherit;False;Property;_jiange3;jiange3;6;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;-2630.953,69.10123;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-2341.853,71.60116;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;74;-2277.742,510.1757;Inherit;False;Constant;_Vector1;Vector 1;7;0;Create;True;0;0;0;False;0;False;0,1,-1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;62;-2194.451,342.3707;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-2366.134,872.3286;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;64;-1986.153,576.0011;Inherit;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;0;False;0;False;-1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FmodOpNode;71;-2074.053,57.30117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;72;-1979.742,360.1756;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;3;FLOAT2;0,0;False;4;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;13;-2326.134,1043.529;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;True;0;0;0;False;0;False;0.2,0.1;0.2,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-2062.678,-178.797;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;12;-2018.934,891.5284;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;63;-1679.354,286.201;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1249.57,761.1609;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;1;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1421.542,170.4641;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-1686.135,822.7286;Inherit;True;Property;_NoiseTexture;NoiseTexture;2;0;Create;True;0;0;0;False;0;False;-1;061eb21adf6997f4c8451d6001ee578a;061eb21adf6997f4c8451d6001ee578a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1046,-301.9286;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;8;-976.6611,317.3759;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-774.1879,272.8676;Inherit;True;Property;_AddTexture;AddTexture;0;0;Create;True;0;0;0;False;0;False;-1;99c7d5c01605dc04687c36229b37b3f1;99c7d5c01605dc04687c36229b37b3f1;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-648.2485,529.4865;Inherit;False;Property;_AddColor;AddColor;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-646.4974,-300.4181;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-300.0234,207.5763;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;17;6.016829,54.77448;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-85.03914,-213.253;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;258.2169,-162.3255;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;18;700.8867,-159.8144;Float;False;True;-1;2;ASEMaterialInspector;0;6;UI22;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;66;1;67;0
WireConnection;60;0;56;0
WireConnection;60;1;66;0
WireConnection;65;0;68;0
WireConnection;65;1;67;0
WireConnection;69;0;65;0
WireConnection;69;1;70;0
WireConnection;62;0;60;0
WireConnection;71;0;56;0
WireConnection;71;1;69;0
WireConnection;72;0;62;0
WireConnection;72;1;74;1
WireConnection;72;2;74;2
WireConnection;72;3;74;3
WireConnection;72;4;74;4
WireConnection;12;0;11;0
WireConnection;12;2;13;0
WireConnection;63;0;71;0
WireConnection;63;1;70;0
WireConnection;63;2;72;0
WireConnection;63;3;72;0
WireConnection;63;4;64;0
WireConnection;19;0;5;0
WireConnection;19;1;63;0
WireConnection;10;1;12;0
WireConnection;8;0;19;0
WireConnection;8;1;10;1
WireConnection;8;2;9;0
WireConnection;4;1;8;0
WireConnection;2;0;1;0
WireConnection;14;0;2;4
WireConnection;14;1;4;0
WireConnection;14;2;15;0
WireConnection;3;0;2;0
WireConnection;3;1;14;0
WireConnection;16;0;3;0
WireConnection;16;1;17;0
WireConnection;18;0;16;0
ASEEND*/
//CHKSM=5A7B663C00EC99D90FBF0EA50911C5B42AB75147