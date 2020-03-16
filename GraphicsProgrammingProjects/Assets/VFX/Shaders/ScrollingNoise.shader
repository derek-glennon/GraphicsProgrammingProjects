Shader "VFX/ScrollingNoise"
{
    Properties
    {
		[Header(Outer Mask)]
		_OuterMaskTex("Outer Mask Texture", 2D) = "black" {}
		_OuterStepValue("Outer Step Value", Range(0,1)) = 0

		[Header(Noise Texture)][Space(5)]
        _NoiseTex ("Noise Texture", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1,1,1,1)

		[Header(Base Noise Layer)][Space(5)]
		_ScrollSpeedU("Scroll Speed U", float) = 0
		_ScrollSpeedV("Scroll Speed V", float) = 0
		_OffsetU("Offset U", float) = 0
		_OffsetV("Offset V", float) = 0
		_Scale("Scale", float) = 1
		_StepValue("Step Value", Range(0,1)) = 1
	}
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


			//Outer Mask
			sampler2D _OuterMaskTex;
			float4 _OuterMaskTex_ST;
			float _OuterStepValue;

			//Noise Texture
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

			//Base Noise Layer
			fixed4 _MainColor;
			float _ScrollSpeedU;
			float _ScrollSpeedV;
			float _OffsetU;
			float _OffsetV;
			float _Scale;
			float _StepValue;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 UVBaseLayer = ((i.uv + float2(_OffsetU, _OffsetV)) + (_Time.x * float2(_ScrollSpeedU, _ScrollSpeedV))) * _Scale;

				fixed3 Noise= tex2D(_NoiseTex, UVBaseLayer).r;

				fixed outerMask = tex2D(_OuterMaskTex, i.uv).r;
				outerMask = smoothstep(0, _OuterStepValue, outerMask);

                fixed4 col;
				col.rgb = Noise.rgb;
				col.a = 1.0;
				return col;
            }
            ENDCG
        }
    }
}
