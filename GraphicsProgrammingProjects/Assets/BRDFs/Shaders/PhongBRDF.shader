Shader "BRDF/PhongBRDF"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularPower ("Specular Power", Range(0,128)) = 128
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf PhongBRDF fullforwardshadows
		#pragma target 3.0

		struct SurfaceOutputBRDF
		{
			fixed3 Albedo;
			fixed Alpha;
			fixed3 Normal;
			fixed3 Emission;
		};

		float _SpecularPower;
		fixed4 _SpecularColor;

		half4 LightingPhongBRDF(SurfaceOutputBRDF s, half3 lightDir, half3 viewDir, half atten)
		{
			float3 normalDir = normalize(s.Normal);

			half NdotL = max(0, saturate(dot(normalDir, lightDir)));
			half3 diffuse = s.Albedo * NdotL;

			float3 R = reflect(-lightDir, normalDir);
			float RdotV = max(0, dot(R, viewDir));
			float specularIntensity = pow(saturate(RdotV), _SpecularPower);
			float3 spec = specularIntensity * _SpecularColor.rgb;

			half4 c;
			c.rgb = (diffuse + spec) * _LightColor0.rgb;
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

        void surf (Input IN, inout SurfaceOutputBRDF o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
