Shader "Gradients/HSL_Gradient"
{
	Properties
	{
		//Start of Gradient
		[Header(Start of Gradient)]
		_Hue1 ("Hue 1", Range(0, 1)) = 0
		_Saturation1("Saturation 1", Range(0,1)) = 0
		_Lightness1("Lightness 1", Range(0,1)) = 0

		//End of Gradient
		[Header(End of Gradient)][Space(5)]
		_Hue2("Hue 2", Range(0, 1)) = 0
		_Saturation2("Saturation 2", Range(0,1)) = 0
		_Lightness2("Lightness 2", Range(0,1)) = 0
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
			float _Lightness1;

			//End of Gradient
			float _Hue2;
			float _Saturation2;
			float _Lightness2;
			
			//Conversion Functions found at: http://www.chilliant.com/rgb2hsv.html
			float3 HUEtoRGB(in float H)
			{
				float R = abs(H * 6 - 3) - 1;
				float G = 2 - abs(H * 6 - 2);
				float B = 2 - abs(H * 6 - 4);
				return saturate(float3(R, G, B));
			}

			float3 HSLtoRGB(in float3 HSL)
			{
				float3 RGB = HUEtoRGB(HSL.x);
				float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
				return (RGB - 0.5) * C + HSL.z;
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
				float lightness = lerp(_Lightness1, _Lightness2, i.uv.x);
				float3 hsl = float3(hue, saturation, lightness);

				//Convet to RGB
				fixed3 rgb = HSLtoRGB(hsl);

				return float4(rgb, 1.0);
			}
			ENDCG
		}
	}
}
