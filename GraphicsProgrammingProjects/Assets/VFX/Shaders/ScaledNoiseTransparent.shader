Shader "VFX/ScaledNoiseTransparent"
{
	Properties
	{
		_AlphaMultiplier("Alpha Multiplier", float) = 5
		_ColorMultiplier("Color Multiplier", float) = 5

		[Header(Outer Mask)]
		_OuterMaskTex("Outer Mask Texture", 2D) = "white" {}
		_OuterStepValue("Outer Step Value", Range(0,1)) = 0

		[Header(Noise Texture)][Space(5)]
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1,1,1,1)

		[Header(Base Noise Layer)][Space(5)]
		_NoiseAmountBaseLayer("Noise Amount", Range(0, 1)) = 1
		_ScrollSpeedU("Scroll Speed U", float) = 0
		_ScrollSpeedV("Scroll Speed V", float) = 0
		_OffsetU("Offset U", float) = 0
		_OffsetV("Offset V", float) = 0
		_Scale("Scale", float) = 1
		_StepValue("Step Value", Range(0,1)) = 1

		[Header(Noise Layer 2)][Sapce(5)]
		_NoiseAmountLayer2("Noise Amount", Range(0,1)) = 1
		_StepValueLayer2("Step Value 2", Range(0,1)) = 1
		_ScaleMultiplierLayer2("Scale Multiplier", float) = 1
		_ScrollSpeedULayer2("Scroll Speed U", float) = 1
		_ScrollSpeedVLayer2("Scroll Speed V", float) = 1
		_OffsetULayer2("Offset U", float) = 0
		_OffsetVLayer2("Offset V", float) = 0

		[Header(Noise Layer 3)][Sapce(5)]
		_NoiseAmountLayer3("Noise Amount", Range(0,1)) = 1
		_StepValueLayer3("Step Value", Range(0,1)) = 1
		_ScaleMultiplierLayer3("Scale Multiplier", float) = 1
		_ScrollSpeedULayer3("Scroll Speed U", float) = 1
		_ScrollSpeedVLayer3("Scroll Speed V", float) = 1
		_OffsetULayer3("Offset U", float) = 0
		_OffsetVLayer3("Offset V", float) = 0
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			LOD 100

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
					fixed4 color : COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
				};


				float _AlphaMultiplier;
				float _ColorMultiplier;

				//Outer Mask
				sampler2D _OuterMaskTex;
				float4 _OuterMaskTex_ST;
				float _OuterStepValue;

				//Noise Texture
				sampler2D _NoiseTex;
				float4 _NoiseTex_ST;

				//Base Noise Layer
				float _NoiseAmountBaseLayer;
				fixed4 _MainColor;
				float _ScrollSpeedU;
				float _ScrollSpeedV;
				float _OffsetU;
				float _OffsetV;
				float _Scale;
				float _StepValue;

				//Noise Layer 2
				float _NoiseAmountLayer2;
				float _StepValueLayer2;
				float _ScaleMultiplierLayer2;
				float _ScrollSpeedULayer2;
				float _ScrollSpeedVLayer2;
				float _OffsetULayer2;
				float _OffsetVLayer2;

				//Noise Layer 3
				float _NoiseAmountLayer3;
				float _StepValueLayer3;
				float _ScaleMultiplierLayer3;
				float _ScrollSpeedULayer3;
				float _ScrollSpeedVLayer3;
				float _OffsetULayer3;
				float _OffsetVLayer3;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
					o.color = v.color;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//Outer Mask
					fixed outerMask = tex2D(_OuterMaskTex, i.uv).a;
					outerMask = smoothstep(0, _OuterStepValue, outerMask);

					//Noise Layer UVs
					float2 UVBaseLayer = ((i.uv + float2(_OffsetU, _OffsetV)) + (_Time.x * float2(_ScrollSpeedU, _ScrollSpeedV))) * _Scale;
					float2 UVLayer2 = ((i.uv + float2(_OffsetULayer2, _OffsetVLayer2)) + (_Time.x * float2(_ScrollSpeedULayer2, _ScrollSpeedVLayer2))) * _ScaleMultiplierLayer2;
					float2 UVLayer3 = ((i.uv + float2(_OffsetULayer3, _OffsetVLayer3)) + (_Time.x * float2(_ScrollSpeedULayer3, _ScrollSpeedVLayer3))) * _ScaleMultiplierLayer3;

					//Texture Reads
					fixed4 noiseTex = tex2D(_NoiseTex, UVBaseLayer);
					fixed4 noiseTexLayer2 = tex2D(_NoiseTex, UVLayer2);
					fixed4 noiseTexLayer3 = tex2D(_NoiseTex, UVLayer3);

					fixed3 color = noiseTex.rgb;
					fixed3 colorLayer2 = noiseTexLayer2.rgb;
					fixed3 colorLayer3 = noiseTexLayer3.rgb;

					fixed noise = noiseTex.a;
					fixed noiseLayer2 = noiseTexLayer2.a;
					fixed noiseLayer3 = noiseTexLayer3.a;

					//Step
					//noise = step(noise, _StepValue);
					//noiseLayer2 = step(noiseLayer2, _StepValueLayer2);
					//noiseLayer3 = step(noiseLayer3, _StepValueLayer3);

					//Lerp Extra Layers
					color = lerp(1, color, _NoiseAmountBaseLayer);
					colorLayer2 = lerp(1, colorLayer2 * lerp(1, _ColorMultiplier, _NoiseAmountBaseLayer), _NoiseAmountLayer2);
					colorLayer3 = lerp(1, colorLayer3 * lerp(1, _ColorMultiplier, _NoiseAmountBaseLayer * _NoiseAmountLayer2), _NoiseAmountLayer3);

					noise = lerp(1, noise, _NoiseAmountBaseLayer);
					noiseLayer2 = lerp(1, noiseLayer2 * lerp(1, _AlphaMultiplier, _NoiseAmountBaseLayer), _NoiseAmountLayer2);
					noiseLayer3 = lerp(1, noiseLayer3 * lerp(1, _AlphaMultiplier, _NoiseAmountBaseLayer * _NoiseAmountLayer2), _NoiseAmountLayer3);

					//Combine
					fixed4 col;
					col.rgb = ((color * colorLayer2) * colorLayer3);
					col.a = ((noise * noiseLayer2) * noiseLayer3) * outerMask * i.color.a;
					col = saturate(col);
					return col;
				}
				ENDCG
			}
		}
}
