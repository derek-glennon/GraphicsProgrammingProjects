Shader "Unlit/BlinnPhongBRDF_VertFrag"
{
    Properties
    {
		_MainColor("Main Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		[ExpoentialSlider]
		_SpecularPower("SpecularPower", Range(0, 128)) = 48
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
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
			#include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
            };

			fixed4 _MainColor;

			float _SpecularPower;
			fixed4 _SpecularColor;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				//o.viewDir = WorldSpaceViewDir(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * _MainColor;

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //- i.posWorld.xyz * _WorldSpaceLightPos0.w;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
				float3 normalDir = normalize(i.worldNormal);
				
				half NdotL = max(0, saturate(dot(normalDir, lightDir)));
				half3 diffuse = albedo * NdotL;

				half3 H = normalize(lightDir + viewDir);
				float NdotH = max(0, dot(normalDir, H));
				float specularIntensity = pow(saturate(NdotH), _SpecularPower);
				float3 spec = specularIntensity * _SpecularColor.rgb;

				half4 c;
				c.rgb = (diffuse + spec) * _LightColor0.rgb;
				return c;
            }
            ENDCG
        }
    }
}
