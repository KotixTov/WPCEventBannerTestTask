Shader "UI/ShineFX"
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
		
        _ShineColor("Shine Color", Color) = (1,1,1,1)
		_ShineWidth("Shine Width", Range(0,1)) = 0.1
		_ShinePeriod("Shine Period", Float) = 1
		_ShineSpeed("Shine Speed", Float) = 1
		_ShineRotation("Shine Rotation", Float) = 0 
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
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
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
        
			#define PI 3.14159
			#define TWO_PI 6.28318

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
                fixed4 color    : COLOR;
                float2 uv  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

			fixed4 _ShineColor;
			float _ShineWidth;
			float _ShinePeriod;
			float _ShineSpeed;
			float _ShineRotation;
        
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.uv = TRANSFORM_TEX(v.uv, _MainTex);

                OUT.color = v.color * _Color;
                return OUT;
            }

			float Shine(float2 uv)
			{
				float2x2 rot = float2x2(cos(_ShineRotation), sin(_ShineRotation), -sin(_ShineRotation), cos(_ShineRotation));
				uv.x += _Time.y * _ShineSpeed;
				uv = mul(rot, uv);
				uv = frac(uv / _ShinePeriod.xx);
				float shine = (step(uv.x, _ShineWidth)) * ((-cos(uv.x * TWO_PI / _ShineWidth) + 1) * 0.5);
				return saturate(shine);
			}
        
            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.uv) + _TextureSampleAdd) * IN.color;
				color = saturate(color + fixed4(_ShineColor.rgb * Shine(IN.worldPosition) * _ShineColor.a, 0) * color.a);
            	
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}