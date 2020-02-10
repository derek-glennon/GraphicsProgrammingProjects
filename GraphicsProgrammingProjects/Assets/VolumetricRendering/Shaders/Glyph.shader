Shader "Custom/Glyph"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_GlyphTex("Glyph Texture", 2D) = "black" {}
		_GlyphColor("Glyph Color", Color) = (1,1,1,1)
		_GlowIntensity("Glow Intensity", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _GlyphTex;

        struct Input
        {
			float2 uv_MainTex;
			float2 uv_GlyphTex;
		};

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		fixed4 _GlyphColor;
		float _GlowIntensity;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
			o.Emission = tex2D(_GlyphTex, IN.uv_MainTex) * _GlyphColor * _GlowIntensity;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
