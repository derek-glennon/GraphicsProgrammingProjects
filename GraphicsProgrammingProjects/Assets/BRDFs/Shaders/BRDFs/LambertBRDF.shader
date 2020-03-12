Shader "BRDF/LambertBRDF"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf LambertBRDF fullforwardshadows

		struct SurfaceOutputBRDF
		{
			half3 Albedo;
			half Alpha;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
		};

		half4 LightingLambertBRDF(SurfaceOutputBRDF s, half3 lightDir, half atten)
		{
			half NdotL = max(0, dot(s.Normal, lightDir));
			half4 c;
			c.rgb = s.Albedo * NdotL;
			c.a = s.Alpha;
			return c;
		}

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputBRDF o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
