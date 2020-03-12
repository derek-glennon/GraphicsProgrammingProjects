Shader "BRDF/WardAnisoBRDF_VertFrag"
{
	Properties
	{
		[Header(Main Texture)]
		_Color("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white" {}

		[NoScaleOffset][Space(10)][Header(Normal Map)]
		_BumpMap("Normal Map", 2D) = "bump" {}

		[Space(10)][Header(Anisometric Specular)]
		_SpecularMap("Specular Map", 2D) = "white" {}
		_GlossMap("Gloss Map", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_AlphaX("Alpha X", Range(0,1)) = 0
		_AlphaY("Alpha Y", Range(0,1)) = 0

		[Space(10)][Header(Material Properties)]
		_Reflectivity("Reflectivity", Range(0,1)) = 0.5
		_Gloss("Gloss", Range(0,1)) = 0.5
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
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
		float4 tangent : TANGENT;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 worldNormal : TEXCOORD1;
		float3 worldTangent : TEXCOORD2;
		float3 worldBiNormal : TEXCOORD3;
		float3 worldPos : TEXCOORD4;
		float3 viewDir : TEXCOORD6;
	};

#pragma target 3.0

	//Main Texture
	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;

	//Normal Map
	sampler2D _BumpMap;

	//Anisometric Specular
	sampler2D _SpecularMap;
	sampler2D _GlossMap;
	fixed4 _SpecularColor;
	float _AlphaX;
	float _AlphaY;

	//Material Properties
	float _Reflectivity;
	float _Gloss;

	half3 RotateCoordinates(half3 coords, half3 rotation)
	{
		//Rotate Around X
		float theta = rotation.x;
		float c = cos(theta * (2.0 * UNITY_PI));
		float s = sin(theta * (2.0 * UNITY_PI));

		float3x3 rotationMatrix = float3x3 (float3(1, 0, 0), float3(0, c, -s), float3(0, s, c));
		coords = mul(coords, rotationMatrix);

		//Rotate Around Y
		theta = rotation.y;
		c = cos(theta * (2.0 * UNITY_PI));
		s = sin(theta * (2.0 * UNITY_PI));

		rotationMatrix = float3x3 (float3(c, 0, s), float3(0, 1, 0), float3(-s, 0, c));
		coords = mul(coords, rotationMatrix);

		//Rotate Around Z
		theta = rotation.z;
		c = cos(theta * (2.0 * UNITY_PI));
		s = sin(theta * (2.0 * UNITY_PI));

		rotationMatrix = float3x3 (float3(c, -s, 0), float3(s, c, 0), float3(0, 0, 1));
		coords = mul(coords, rotationMatrix);

		return coords;
	}

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldTangent = UnityObjectToWorldNormal(v.tangent.xyz);
		o.worldBiNormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;

		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

		o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//Material Properties
		fixed4 mainTex = tex2D(_MainTex, i.uv) * _Color;
		fixed3 Albedo = mainTex.rgb;
		fixed Alpha = mainTex.a;
		half Specular = tex2D(_SpecularMap, i.uv);
		fixed Gloss = tex2D(_GlossMap, i.uv) * _Gloss;
		fixed3 Normal = UnpackNormal(tex2D(_BumpMap, i.uv));
		half3 worldNormal = normalize(i.worldTangent * Normal.r + i.worldBiNormal * Normal.g + i.worldNormal * Normal.b);

		//////////////////////////////////////////////////////////
		//Direct Light
		//////////////////////////////////////////////////////////

		//Main Light
		//float3 toLight = i.worldPos - _WorldSpaceLightPos0.xyz;
		half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

		fixed NdotL = max(0, saturate(dot(lightDir, worldNormal)));
		fixed3 diffuse = Albedo * NdotL * _LightColor0.rgb;

		//Anisometric Specular
		fixed3 H = normalize(lightDir + i.viewDir);
		fixed3 tangentDir = cross(i.worldBiNormal, worldNormal);
		fixed3 binormalDir = cross(i.worldTangent, worldNormal);

		float HdotN = dot(H, worldNormal);
		float VdotN = dot(i.viewDir, worldNormal);
		float HdotTAlphaX = dot(H, tangentDir) / _AlphaX;
		float HdotBAlphaY = dot(H, binormalDir) / _AlphaY;
		float3 spec = _SpecularColor * sqrt(max(0, NdotL / VdotN)) * (1 / (4 * 3.141592653589793238462 * _AlphaX * _AlphaY))
			* exp(-2.0 * (HdotTAlphaX * HdotTAlphaX + HdotBAlphaY * HdotBAlphaY) / (1.0 + HdotN))
			* _LightColor0.rgb;

		//////////////////////////////////////////////////////////
		//Combine Direct and Indirect
		//////////////////////////////////////////////////////////
		float4 col;
		col.rgb = diffuse + spec;
		col.a = Alpha;

		return col;
		}
			ENDCG
		}
	}
}
