Shader "Gradients/HSV_GradientScroll"
{
	Properties
	{
		//Start of Gradient
		[Header(Start of Gradient)]
		_Saturation1("Saturation 1", Range(0,1)) = 0
		_Value1("Value 1", Range(0,1)) = 0

		//End of Gradient
		[Header(End of Gradient)][Space(5)]
		_Saturation2("Saturation 2", Range(0,1)) = 0
		_Value2("Value 2", Range(0,1)) = 0

		[Header(Scroll Parameters)][Space(5)]
		_HueWidth("Hue Width", Range(0, 1)) = 0
		_ScrollSpeed("Scroll Speed", float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//Start of Gradient
			float _Saturation1;
			float _Value1;

			//End of Gradient
			float _Saturation2;
			float _Value2;

			//Scroll Parameters
			float _HueWidth;
			float _ScrollSpeed;

			//Conversion Functions found at: http://www.chilliant.com/rgb2hsv.html
			float3 rgb2hsv(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
				float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			float3 hsv2rgb(float3 c)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}

			inline half SawtoothWave(float In)
			{
				return (2 * (In - floor(0.5 + In)));
			}

			//Remaps x from a-b to c-d
			inline float Remap(float x, float a, float b, float c, float d)
			{
				return (c + (x - a) * ((d - c) / (b - a)));
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Create Sawtooth Hue Value
				float hue = SawtoothWave(_HueWidth * i.uv.x + _ScrollSpeed * _Time.x);
				hue = Remap(hue, -1, 1, 0, 1);

				//Lerp between constant values
				float saturation = lerp(_Saturation1, _Saturation2, i.uv.x);
				float value = lerp(_Value1, _Value2, i.uv.x);
				float3 hsv = float3(hue, saturation, value);

				//Convet to RGB
				fixed3 rgb = hsv2rgb(hsv);

				return float4(rgb, 1.0);
			}
			ENDCG
		}
	}
}
