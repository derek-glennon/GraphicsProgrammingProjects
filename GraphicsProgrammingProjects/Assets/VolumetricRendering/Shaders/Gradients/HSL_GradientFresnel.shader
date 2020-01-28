Shader "Gradients/HSL_GradientFresnel"
{
	Properties
	{
		[Header(Normal Map)]
		[NoScaleOffset][Normal]_NormalTex("Normal Map", 2D) = "bump" {}

		//Start of Gradient
		[Header(Start of Gradient)]
		_Saturation1("Saturation 1", Range(0,1)) = 0
		_Lightness1("Lightness 1", Range(0,1)) = 0

		//End of Gradient
		[Header(End of Gradient)][Space(5)]
		_Saturation2("Saturation 2", Range(0,1)) = 0
		_Lightness2("Lightness 2", Range(0,1)) = 0

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
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldTangent : TEXCOORD3;
				float3 worldBiTangent : TEXCOORD4;
			};

			sampler2D _NormalTex;

			//Start of Gradient
			float _Saturation1;
			float _Lightness1;

			//End of Gradient
			float _Saturation2;
			float _Lightness2;

			//Scroll Parameters
			float _HueWidth;
			float _ScrollSpeed;

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

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBiTangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;

				o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Change Normal Map from Local Coords to World Coords
				half3 localNormal = UnpackNormal(tex2D(_NormalTex, i.uv));
				float3x3 local2World = float3x3(i.worldTangent, i.worldBiTangent, i.worldNormal);
				float3 normalDir = normalize(mul(localNormal, local2World));

				float fresnel = dot(normalDir, i.viewDir);
				fresnel = Remap(fresnel, -1, 1, 0, 1);

				//Create Sawtooth Hue Value
				float hue = SawtoothWave(_HueWidth * fresnel + _ScrollSpeed * _Time.x);
				hue = Remap(hue, -1, 1, 0, 1);

				//Lerp between constant values
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
