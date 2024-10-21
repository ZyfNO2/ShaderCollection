// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LutDIsslove"
{
	Properties
	{
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_EdgeWith("EdgeWith", Range( 0 , 1)) = 0.6388178
		_RampTex("RampTex", 2D) = "white" {}
		[HDR]_EdgeColor("EdgeColor", Color) = (0.8018868,0.3517711,0.3517711,0.7372549)
		_MainTex("MainTex", 2D) = "white" {}
		_MainColor("MainColor", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _RampTex;
			uniform float _EdgeWith;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTex_ST;
			uniform float4 _EdgeColor;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_NoiseTex = i.ase_texcoord1.xyz.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float3 texCoord23 = i.ase_texcoord1.xyz;
				texCoord23.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult7 = smoothstep( 0.0 , _EdgeWith , ( tex2D( _NoiseTex, uv_NoiseTex ).r + 1.0 + ( -2.0 * texCoord23.z ) ));
				float2 appendResult10 = (float2(smoothstepResult7 , 0.0));
				float4 tex2DNode11 = tex2D( _RampTex, appendResult10 );
				float2 uv_MainTex = i.ase_texcoord1.xyz.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode14 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult20 = lerp( ( tex2DNode11 * _EdgeColor ) , ( tex2DNode14 * _MainColor * i.ase_color ) , tex2DNode11.a);
				float4 appendResult22 = (float4((lerpResult20).rgb , ( tex2DNode14.a * _MainColor.a * i.ase_color.a * saturate( smoothstepResult7 ) )));
				
				
				finalColor = appendResult22;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SamplerNode;1;-1304.888,-661.5035;Inherit;True;Property;_NoiseTex;NoiseTex;0;0;Create;True;0;0;0;False;0;False;-1;f373965fe8c960445a2dae81f7e749c0;f373965fe8c960445a2dae81f7e749c0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-1022.764,-445.8085;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1181.099,-302.2816;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-933.9136,-294.3078;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-806.0961,-188.7713;Inherit;False;Property;_EdgeWith;EdgeWith;2;0;Create;True;0;0;0;False;0;False;0.6388178;0.454;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2;-835.9511,-595.0313;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-124.9758,-508.4559;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;123.9199,-522.0497;Inherit;True;Property;_RampTex;RampTex;3;0;Create;True;0;0;0;False;0;False;-1;c93a7d05d600f2944ba5fe43bc04b71d;c93a7d05d600f2944ba5fe43bc04b71d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;213.6192,-262.0502;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;0;False;0;False;0.8018868,0.3517711,0.3517711,0.7372549;6.457122,6.457122,6.457122,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;809.201,-73.59999;Float;False;True;-1;2;ASEMaterialInspector;100;5;LutDIsslove;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-0.2923584,150.441;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;31.83953,598.8549;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;7;-582.3676,-570.3187;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;16;-374.2138,511.2168;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-445.7048,21.16946;Inherit;True;Property;_MainTex;MainTex;5;0;Create;True;0;0;0;False;0;False;-1;b0c08927fa33fdb43841949f0d1016d9;b0c08927fa33fdb43841949f0d1016d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;19;-426.3483,843.2718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;20;484.0392,371.3169;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;772.2905,393.5328;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;1015.125,520.1391;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;15;-403.4265,252.6851;Inherit;False;Property;_MainColor;MainColor;6;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;486.6195,-480.4497;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1225.077,-14.1723;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1325.895,-173.0617;Inherit;False;Property;_Disslovetime;Disslovetime;1;0;Create;True;0;0;0;False;0;False;0.4810768;0.4802117;0;1;0;1;FLOAT;0
WireConnection;6;0;4;0
WireConnection;6;1;23;3
WireConnection;2;0;1;1
WireConnection;2;1;3;0
WireConnection;2;2;6;0
WireConnection;10;0;7;0
WireConnection;11;1;10;0
WireConnection;0;0;22;0
WireConnection;17;0;14;0
WireConnection;17;1;15;0
WireConnection;17;2;16;0
WireConnection;18;0;14;4
WireConnection;18;1;15;4
WireConnection;18;2;16;4
WireConnection;18;3;19;0
WireConnection;7;0;2;0
WireConnection;7;2;8;0
WireConnection;19;0;7;0
WireConnection;20;0;12;0
WireConnection;20;1;17;0
WireConnection;20;2;11;4
WireConnection;21;0;20;0
WireConnection;22;0;21;0
WireConnection;22;3;18;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
ASEEND*/
//CHKSM=681339CFB9849973286E4156D3873543A56E482A