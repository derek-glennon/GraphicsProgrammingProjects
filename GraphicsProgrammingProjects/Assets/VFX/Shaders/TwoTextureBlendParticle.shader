Shader "VFX/TwoTextureBlendParticle"
{
	Properties
	{
		[Header(Multiplier)]
		_AlphaMultiplier("Alpha Multiplier", float) = 5
		_ColorMultiplier("Color Multiplier", float) = 5

		[Space(5)]
		[Header(Outer Mask)]
		_OuterMaskTex("Outer Mask Texture", 2D) = "white" {}
		_OuterStepValue("Outer Step Value", Range(0,1)) = 0

		[Header(Layer 1)][Space(5)]
		_TextureLayer1("Texture", 2D) = "white" {}
		_AmountLayer1("Layer Amount", Range(0, 1)) = 1
		_ScrollSpeedULayer1("Scroll Speed U", float) = 0
		_ScrollSpeedVLayer1("Scroll Speed V", float) = 0
		_ScaleLayer1("Scale", float) = 1

		[Header(Texture 2)][Space(5)]
		_TextureLayer2("Texture", 2D) = "white" {}
		_AmountLayer2("Layer Amount", Range(0,1)) = 1
		_ScrollSpeedULayer2("Scroll Speed U", float) = 1
		_ScrollSpeedVLayer2("Scroll Speed V", float) = 1
		_ScaleLayer2("Scale", float) = 1

		[Space(5)]
		[Header(Soft Particles)]
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 1.0
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
					float2 uvMask : TEXCOORD0;
					float2 uvLayer1 : TEXCOORD1;
					float2 uvLayer2 : TEXCOORD2;
					float4 projPos : TEXCOORD3;
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
				};


				float _AlphaMultiplier;
				float _ColorMultiplier;

				//Outer Mask
				sampler2D _OuterMaskTex;
				float4 _OuterMaskTex_ST;
				float _OuterStepValue;

				//Layer 1
				sampler2D _TextureLayer1;
				float4 _TextureLayer1_ST;
				float _AmountLayer1;
				float _ScrollSpeedULayer1;
				float _ScrollSpeedVLayer1;
				float _ScaleLayer1;

				//Layer 2
				sampler2D _TextureLayer2;
				float4 _TextureLayer2_ST;
				float _AmountLayer2;
				float _ScrollSpeedULayer2;
				float _ScrollSpeedVLayer2;
				float _ScaleLayer2;

				//Soft Particles
				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uvMask = TRANSFORM_TEX(v.uv, _OuterMaskTex);
					o.uvLayer1 = TRANSFORM_TEX(v.uv, _TextureLayer1);
					o.uvLayer2 = TRANSFORM_TEX(v.uv, _TextureLayer2);

					//Soft Particles
					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);

					o.color = v.color;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//Outer Mask
					fixed outerMask = tex2D(_OuterMaskTex, i.uvMask).a;
					outerMask = smoothstep(0, _OuterStepValue, outerMask);

					//Noise Layer UVs
					float2 UVLayer1 = ((i.uvLayer1 + float2(i.color.r, i.color.r)) + (_Time.x * float2(_ScrollSpeedULayer1, _ScrollSpeedVLayer1) * i.color.g)) * _ScaleLayer1 * i.color.b;
					float2 UVLayer2 = ((i.uvLayer2 + float2(i.color.r, i.color.r)) + (_Time.x * float2(_ScrollSpeedULayer2, _ScrollSpeedVLayer2) * i.color.g)) * _ScaleLayer2 * i.color.b;

					//Texture Reads
					fixed4 TexLayer1 = tex2D(_TextureLayer1, UVLayer1);
					fixed4 TexLayer2 = tex2D(_TextureLayer2, UVLayer2);

					fixed3 colorLayer1 = TexLayer1.rgb;
					fixed3 colorLayer2 = TexLayer2.rgb;

					fixed alphaLayer1 = TexLayer1.a;
					fixed alphaLayer2 = TexLayer2.a;

					//Lerp Extra Layers
					colorLayer1 = lerp(1, colorLayer1, _AmountLayer1);
					colorLayer2 = lerp(1, colorLayer2 * lerp(1, _ColorMultiplier, _AmountLayer1), _AmountLayer2);

					alphaLayer1 = lerp(1, alphaLayer1, _AmountLayer1);
					alphaLayer2 = lerp(1, alphaLayer2 * lerp(1, _AlphaMultiplier, _AmountLayer1), _AmountLayer2);

					//Soft Particles
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.color.a *= fade;

					//Combine
					fixed4 col;
					col.rgb = (colorLayer1 * colorLayer2);
					col.a = (alphaLayer1 * alphaLayer2) * outerMask * i.color.a;
					
					col = saturate(col);
					return col;
				}
				ENDCG
			}

			//Shadow Pass to Write to Camera Depth Texture Used for Soft Particles
			Pass
			{
				Tags {"LightMode" = "ShadowCaster"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#include "UnityCG.cginc"

				struct v2f {
					V2F_SHADOW_CASTER;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}
		}
}
