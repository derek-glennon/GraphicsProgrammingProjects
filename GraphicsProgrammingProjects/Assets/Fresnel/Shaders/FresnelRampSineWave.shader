Shader "Fresnel/FresnelRampSineWave"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_RampTex("Toon Ramp Tex", 2D) = "white" {}
		_SpecularPower ("Specular Power", Range(0,128)) = 128
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		[PowerSlider(4)]
		_FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1
		_Amplitude("Amplitude", float) = 1
		_Frequency("Frequency", float) = 1
		_ScrollSpeed("Scroll Speed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf BlinnPhongBRDF fullforwardshadows
		#pragma target 3.0

		struct SurfaceOutputBRDF
		{
			fixed3 Albedo;
			fixed Alpha;
			fixed3 Normal;
			fixed3 Emission;
		};

		inline half SawtoothWave(float In)
		{
			return (2 * (In - floor(0.5 + In)));
		}

		inline half SinWave(half x, half Amplitude, half frequency, half speed, half time, half offset)
		{
			return Amplitude * sin(frequency * x + speed * time + offset);
		}

		//Remaps x from a-b to c-d
		inline float Remap(float x, float a, float b, float c, float d)
		{
			return (c + (x - a) * ((d - c) / (b - a)));
		}

		sampler2D _RampTex;
		float _SpecularPower;
		fixed4 _SpecularColor;
		float _FresnelExponent;
		fixed4 _FresnelColor;
		float _Amplitude;
		float _Frequency;
		float _ScrollSpeed;

		half4 LightingBlinnPhongBRDF(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			float3 normalDir = normalize(s.Normal);

			half NdotL = max(0, dot(normalDir, lightDir));

			half3 diffuse = s.Albedo * NdotL;

			half3 H = normalize(lightDir + viewDir);
			float NdotH = dot(normalDir, H);

			float specularIntensity = pow(saturate(NdotH), _SpecularPower);
			float3 spec = specularIntensity * _SpecularColor.rgb;

			//viewDir = float3(0, 0, -1);

			float fresnel = dot(normalDir, viewDir);
			fresnel = saturate(1 - fresnel);
			//fresnel = pow(fresnel, _FresnelExponent);

			half remappedFresnel = Remap(fresnel, -1, 1, 0, 1);
			half sineFresnel = SinWave(remappedFresnel, _Amplitude, _Frequency, _ScrollSpeed, _Time.x, 0);
			
			half finalFresnel = Remap(sineFresnel, -1, 1, 0, 1);

			half2 rampUV = half2(finalFresnel, 0.5);
			fixed3 rampSample = tex2D(_RampTex, rampUV);

			float3 fresnelColor = rampSample * _FresnelColor;

			half4 c;
			c.rgb = fresnelColor;
			c.a = s.Alpha;
			return c;
		}

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
