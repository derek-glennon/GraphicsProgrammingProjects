﻿Shader "VolumetricRendering/VolumetricRaymarching"
{
    Properties
    {
		[Header(Sphere Properties)]
		_Color("Color", Color) = (1,0,0,1)
		_Center("Center of Sphere", Vector) = (0,0,0,0)
		_Radius("Radius of Sphere", float) = 0.1

		[Header(Material Properties)][Space(5)]
		[ExponentSlider]
		_SpecularPower("Specular Power", Range(0, 256)) = 128
		_Gloss("Gloss", Range(0,1)) = 0.5
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "LightMode" = "ForwardBase"}
			LOD 100

			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "SDFs.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
            };

			fixed4 _Color;
			float3 _Center;
			float _Radius;

			//Material Properties
			float _SpecularPower;
			float _Gloss;

			#define STEPS 64
			#define MIN_DISTANCE 0.001

			float SDF_Blend(float d1, float d2, float a)
			{
				return a * d1 + (1 - a) * d2;
			}

			float SDF_SMin(float a, float b, float k = 32)
			{
				float res = exp(-k * a) + exp(-k * b);
				return -log(max(0.0001, res)) / k;
			}

			float3 map(float3 pos)
			{
				return SDF_HexPrism(pos, float2(1, 1));

				//float4 normal = float4(EstimateNormal(pos), 1.0);
				
				//return SDF_Plane(pos, normal);

				//return SDF_RoundBox(pos, 0, 1, .9);

				//return SDF_Blend
				//(
				//	SDF_Sphere(pos, 0, 1),
				//	SDF_Box(pos, 0, 1),
				//	(sin(_Time.y) + 1.) / 2.
				//);

				//return max
				//(
				//	SDF_Sphere(pos, -float3 (1.5, 0, 0), 2), // Left sphere
				//	SDF_Sphere(pos, +float3 (1.5, 0, 0), 2)  // Right sphere
				//);
			}

			fixed4 SimpleBlinnPhong(fixed3 normal, float3 viewDir)
			{
				//Due to weird definition of viewDir have to reverse the direction here
				viewDir = normalize(-viewDir);

				fixed3 lightDir = _WorldSpaceLightPos0;
				fixed3 lightCol = _LightColor0.rgb;

				//Diffuse
				fixed3 NdotL = max(dot(normal, lightDir), 0);
				fixed3 diffuse = NdotL * _Color.rgb * lightCol;

				//Specular
				fixed3 h = normalize(lightDir + viewDir);
				fixed spec = pow(max(dot(normal, h), 0), _SpecularPower) * _Gloss * lightCol;

				fixed4 c;
				c.rgb = diffuse + spec;
				c.a = 1;
				return c;
			}

			//Remaps x from a-b to c-d
			inline float Remap(float x, float a, float b, float c, float d)
			{
				return (c + (x - a) * ((d - c) / (b - a)));
			}

			float3 EstimateNormal(float3 pos)
			{
				const float eps = 0.01;

				float deltaX = map(pos + float3(eps, 0, 0)) - map(pos - float3(eps, 0, 0));
				float deltaY = map(pos + float3(0, eps, 0)) - map(pos - float3(0, eps, 0));
				float deltaZ = map(pos + float3(0, 0, eps)) - map(pos - float3(0, 0, eps));

				return normalize(float3(deltaX, deltaY, deltaZ));
			}

			fixed4 RenderSurface(float3 pos, float3 viewDir)
			{
				float3 normal = EstimateNormal(pos);
				return SimpleBlinnPhong(normal, viewDir);
			}

			fixed4 Raymarch(float3 pos, float3 dir)
			{
				for (int i = 0; i < STEPS; i++)
				{
					float distance = map(pos);
					if (distance < MIN_DISTANCE)
					{
						return RenderSurface(pos, dir);
					}

					//March along the ray
					pos += distance * dir;
				}

				//If nothing is hit
				return fixed4(1,1,1,0);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 viewDir = normalize((i.worldPos - _WorldSpaceCameraPos));
				return (Raymarch(i.worldPos, viewDir));
            }
            ENDCG
        }
    }
}
