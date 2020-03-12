Shader "Fresnel/Fresnel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		[PowerSlider(4)]
		_FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1
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

		float _FresnelExponent;
		fixed4 _FresnelColor;

		half4 LightingBlinnPhongBRDF(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			float3 normalDir = normalize(s.Normal);
			viewDir = float3(0, 0, -1);

			float fresnel = dot(normalDir, viewDir);
			fresnel = saturate(1 - fresnel);
			fresnel = pow(fresnel, _FresnelExponent);
			float3 fresnelColor = fresnel * _FresnelColor;

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
