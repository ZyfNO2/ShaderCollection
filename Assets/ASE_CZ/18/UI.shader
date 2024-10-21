// Upgrade NOTE: upgraded instancing buffer 'UI' to new syntax.

// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UI"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        _AddTex("AddTex", 2D) = "black" {}
        _AddTexSpeed("AddTexSpeed", Vector) = (0,0.2,0,0)
        _NoiseIntensity("NoiseIntensity", Float) = 0.2
        _NoiseTex("NoiseTex", 2D) = "white" {}
        [HDR]_Color0("Color 0", Color) = (1,1,1,1)
        _NoiseSpeed("NoiseSpeed", Vector) = (0.2,0,0,0)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

    }

    SubShader
    {
		LOD 0

        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

        Stencil
        {
        	Ref [_Stencil]
        	ReadMask [_StencilReadMask]
        	WriteMask [_StencilWriteMask]
        	Comp [_StencilComp]
        	Pass [_StencilOp]
        }


        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        
        Pass
        {
            Name "Default"
        CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

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
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            uniform sampler2D _AddTex;
            uniform sampler2D _NoiseTex;
            uniform float _NoiseIntensity;
            uniform float4 _Color0;
            UNITY_INSTANCING_BUFFER_START(UI)
            	UNITY_DEFINE_INSTANCED_PROP(float4, _AddTex_ST)
#define _AddTex_ST_arr UI
            	UNITY_DEFINE_INSTANCED_PROP(float4, _NoiseTex_ST)
#define _NoiseTex_ST_arr UI
            	UNITY_DEFINE_INSTANCED_PROP(float2, _AddTexSpeed)
#define _AddTexSpeed_arr UI
            	UNITY_DEFINE_INSTANCED_PROP(float2, _NoiseSpeed)
#define _NoiseSpeed_arr UI
            UNITY_INSTANCING_BUFFER_END(UI)

            
            v2f vert(appdata_t v )
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                

                v.vertex.xyz +=  float3( 0, 0, 0 ) ;

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = v.texcoord;
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN ) : SV_Target
            {
                //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
                //The incoming alpha could have numerical instability, which makes it very sensible to
                //HDR color transparency blend, when it blends with the world's texture.
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

                float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_MainTex_ST_arr, _MainTex_ST);
                float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
                float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
                float2 _AddTexSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_AddTexSpeed_arr, _AddTexSpeed);
                float4 _AddTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_AddTex_ST_arr, _AddTex_ST);
                float2 uv_AddTex = IN.texcoord.xy * _AddTex_ST_Instance.xy + _AddTex_ST_Instance.zw;
                float2 panner6 = ( 1.0 * _Time.y * _AddTexSpeed_Instance + uv_AddTex);
                float2 _NoiseSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseSpeed_arr, _NoiseSpeed);
                float4 _NoiseTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseTex_ST_arr, _NoiseTex_ST);
                float2 uv_NoiseTex = IN.texcoord.xy * _NoiseTex_ST_Instance.xy + _NoiseTex_ST_Instance.zw;
                float2 panner13 = ( 1.0 * _Time.y * _NoiseSpeed_Instance + uv_NoiseTex);
                float2 temp_cast_0 = (tex2D( _NoiseTex, panner13 ).r).xx;
                float2 lerpResult9 = lerp( panner6 , temp_cast_0 , _NoiseIntensity);
                

                half4 color = ( tex2DNode2 + ( tex2DNode2.a * tex2D( _AddTex, lerpResult9 ) * _Color0 ) );

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.rgb *= color.a;

                return color;
            }
        ENDCG
        }
    }
    CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-459,-37;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-245,34;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;9;-352.7708,662.9396;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;6;-656.7708,433.9396;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;-1179.681,877.4844;Inherit;True;Property;_NoiseTex;NoiseTex;3;0;Create;True;0;0;0;False;0;False;-1;0df7a0b61c9dfa6408ae01459c10ffec;0df7a0b61c9dfa6408ae01459c10ffec;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;13;-1473.181,956.7844;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1809.379,873.785;Inherit;False;0;11;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-528.3812,854.084;Inherit;True;Property;_NoiseIntensity;NoiseIntensity;2;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-974.7708,265.9396;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;922.9313,187.7411;Float;False;True;-1;2;ASEMaterialInspector;0;3;UI;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;4;-154.8407,493.6032;Inherit;True;Property;_AddTex;AddTex;0;0;Create;True;0;0;0;False;0;False;-1;40eb2a83423fa9740a87cb379e0ed959;40eb2a83423fa9740a87cb379e0ed959;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;107.7897,956.7972;Inherit;False;Property;_Color0;Color 0;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.3867925,0.3667231,0.3667231,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;3;542.1089,133.667;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;371.0147,570.2429;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;8;-964.7708,559.9396;Inherit;False;InstancedProperty;_AddTexSpeed;AddTexSpeed;1;0;Create;True;0;0;0;False;0;False;0,0.2;0,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;14;-1842.78,1269.785;Inherit;False;InstancedProperty;_NoiseSpeed;NoiseSpeed;5;0;Create;True;0;0;0;False;0;False;0.2,0;0.2,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;2;0;1;0
WireConnection;9;0;6;0
WireConnection;9;1;11;1
WireConnection;9;2;10;0
WireConnection;6;0;5;0
WireConnection;6;2;8;0
WireConnection;11;1;13;0
WireConnection;13;0;12;0
WireConnection;13;2;14;0
WireConnection;0;0;3;0
WireConnection;4;1;9;0
WireConnection;3;0;2;0
WireConnection;3;1;15;0
WireConnection;15;0;2;4
WireConnection;15;1;4;0
WireConnection;15;2;16;0
ASEEND*/
//CHKSM=B4527EF0832ADB93701C20BEB818F36E3D1F7183