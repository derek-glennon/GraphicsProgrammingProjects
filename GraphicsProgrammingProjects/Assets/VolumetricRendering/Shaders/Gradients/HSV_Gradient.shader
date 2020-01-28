Shader "Gradients/HSV_Gradient"
{
	Properties
	{
		//Start of Gradient
		[Header(Start of Gradient)]
		_Hue1 ("Hue 1", Range(0, 1)) = 0
		_Saturation1("Saturation 1", Range(0,1)) = 0
		_Value1("Value 1", Range(0,1)) = 0

		//End of Gradient
		[Header(End of Gradient)][Space(5)]
		_Hue2("Hue 2", Range(0, 1)) = 0
		_Saturation2("Saturation 2", Range(0,1)) = 0
		_Value2("Value 2", Range(0,1)) = 0
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
			float _Hue1;
			float _Saturation1;
			float _Value1;

			//End of Gradient
			float _Hue2;
			float _Saturation2;
			float _Value2;
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Lerp between values
				float hue = lerp(_Hue1, _Hue2, i.uv.x);
				float saturation = lerp(_Saturation1, _Saturation2, i.uv.x);
				float value = lerp(_Value1, _Value2, i.uv.x);
				float3 hsl = float3(hue, saturation, value);

				//Convet to RGB
				fixed3 rgb = hsv2rgb(hsl);

				return float4(rgb, 1.0);
			}
			ENDCG
		}
	}
}
