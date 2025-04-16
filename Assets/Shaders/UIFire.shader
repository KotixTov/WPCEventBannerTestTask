Shader "UI/FireFX"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		
		[PerRendererData] _MaskTex("Mask Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseScale("Noise Scale", float) = 1
		_TopAmplitude("Top Amplitude", Range(0,1)) = 1
		_BottomAmplitude("Bottom Amplitude", Range(0,1)) = 1
		_Speed("Speed", vector) = (1, 1, 0, 0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]


		Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
			
			#define TWO_PI 6.28318
			#define PI 3.14159

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				half2 uv  : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
			};
			
			sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

			sampler2D _MaskTex;
			sampler2D _NoiseTex;
			float _TopAmplitude;
			float _BottomAmplitude;
			float2 _Speed;
			float _NoiseScale;

			v2f vert(appdata_t v)
			{
				v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.vertex = UnityObjectToClipPos(v.vertex);
				OUT.uv = v.uv;

		#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw - 1.0)*float2(-1,1);
		#endif
				OUT.color = v.color * _Color;
				return OUT;
			}

			
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed mask = tex2D(_MaskTex, IN.uv).r;
				float2 noise = tex2D(_NoiseTex, IN.uv * _NoiseScale + _Time.y * _Speed).rg;
				noise = cos(noise.rg * PI);
				IN.uv += noise * lerp(_BottomAmplitude, _TopAmplitude, IN.uv.y) * mask;
				fixed4 col = (tex2D(_MainTex, IN.uv) + _TextureSampleAdd) * IN.color;
            	
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
				
				return col;
			}
			ENDCG
		}
	}
}