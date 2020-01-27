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

		[Header(Scrolling Parameters)][Space(5)]
		_TimeValue("Time", Range(0,1)) = 0
		_Offset("Offset", Range(0,1)) = 0.5
		_Speed("Speed", float) = 1
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

			#pragma target 4.0

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

			//Scrolling Parameters
			float _TimeValue;
			float _Offset;
			float _Speed;

			//Array Parameters
			#define ARRAY_SIZE 10
			float _BlendArray[ARRAY_SIZE];

			#define STEPS 64
			#define MIN_DISTANCE 0.001

			//Remaps x from a-b to c-d
			inline float Remap(float x, float a, float b, float c, float d)
			{
				return (c + (x - a) * ((d - c) / (b - a)));
			}

			float SawtoothWave(float x)
			{
				return 2 * (x - floor(0.5 + x));
			}

			float SDF_Blend(float d1, float d2, float a)
			{
				return a * d1 + (1 - a) * d2;
			}

			float SDF_Blend3(float d1, float d2, float d3, float a)
			{
				if (a <= 0.333)
				{
					float t1 = Remap(a, 0, 0.333, 0, 1);
					return lerp(d1, d2, t1);
					//return t1 * d1 + (1 - t1) * d2;
				}
				else if (a > 0.333 && a <= 0.666)
				{
					float t2 = Remap(a, 0.333, 0.666, 0, 1);
					return lerp(d2, d3, t2);
					//return t2 * d3 + (1 - t2) * d2;
				}
				else if (a > 0.666)
				{
					float t3 = Remap(a, 0.666, 1, 0, 1);
					return lerp(d3, d1, t3);
				}
				else return 0;
			}

			void SetUpBlendArray(float3 pos)
			{
				_BlendArray[0] = SDF_Sphere(pos, 0, 1);
				_BlendArray[1] = SDF_Box(pos, 0, 1);
				_BlendArray[2] = SDF_TriPrism(pos, float2(1, 1));
				_BlendArray[3] = SDF_Capsule(pos, 0, .25, .5);
				_BlendArray[4] = SDF_RoundedCylinder(pos, .5, .5, .5);
				_BlendArray[5] = SDF_CappedCone(pos, 1, 1, 0);
				_BlendArray[6] = SDF_Ellipsoid(pos, float3(1.5, .5, 1.5));
				_BlendArray[7] = SDF_Torus(pos, float2(1.5, .1));
				_BlendArray[8] = SDF_Octahedron(pos, 1.5);
				_BlendArray[9] = SDF_Pyramid(pos, 1);
			}

			float SDF_BlendN(float3 pos, float t)
			{
				float deltaT = 1.0 / ARRAY_SIZE;
				float returnValue = 0.0;

				int blendIndex = floor(Remap(t, 0, 1, 0, ARRAY_SIZE));
				float2 tRange = float2(0,0);
				float tRemap = 0;

				if (t < 1.0 - deltaT)
				{
					tRange = float2((blendIndex)* deltaT, (blendIndex + 1) * deltaT);
					tRemap = Remap(t, tRange.x, tRange.y, 0, 1);
					return lerp(_BlendArray[blendIndex], _BlendArray[blendIndex + 1], tRemap);
				}
				else
				{
					tRange = float2(1.0 - deltaT, 1.0);
					tRemap = Remap(t, tRange.x, tRange.y, 0, 1);
					return lerp(_BlendArray[blendIndex], _BlendArray[0], tRemap);
				}

				return 0;
			}

			float SDF_SMin(float a, float b, float k = 32)
			{
				float res = exp(-k * a) + exp(-k * b);
				return -log(max(0.0001, res)) / k;
			}

			float3 map(float3 pos)
			{
				//return SDF_Quad(pos, float3(1, 0, 0), float3(0, 1, 0), float3(0, 0, 1), float3(0, 0, 1));

				//return SDF_Triangle(pos, float3(1, 0, 0), float3(0, 1, 0), float3(0, 0, 1));

				//return SDF_Pyramid(pos, 1);

				//return SDF_Octahedron(pos, 2);

				//return SDF_Link(pos, .5, 1.5, .5);

				//return SDF_CappedTorus(pos, float2(.5, .5), .5, .5);

				//return SDF_Torus(pos, float2(1.5, .1));

				//return SDF_Ellipsoid(pos, float3(1.5, .5, 1.5));

				//return SDF_RoundCone(pos, .5, .2, 1);

				//return SDF_SolidAngle(pos, float2(1, 1), 1);
				
				//return SDF_CappedCone(pos, 1, 1, 0);

				//return SDF_Cone(pos, float2(0, 1));

				//return SDF_RoundedCylinder(pos, 1, 1, 1);

				//return SDF_CappedCylinder(pos, 1, 1);

				//return SDF_InfCylinder(pos, float3(0,0,1));

				//return SDF_VerticalCapsule(pos, 1, 1);

				//return SDF_Capsule(pos, 1, .5, 1);
				
				//return SDF_TriPrism(pos, float2(1, 1));

				//float4 normal = float4(EstimateNormal(pos), 1.0);
				
				//return SDF_Plane(pos, normal);

				//return SDF_RoundBox(pos, 0, 1, .9);

				//return SDF_Blend
				//(
				//	SDF_Sphere(pos, 0, 1),
				//	SDF_Box(pos, 0, 1),
				//	(sin(_Time.y) + 1.) / 2.
				//);
				//return SDF_Sphere(pos, 0, 1);
				SetUpBlendArray(pos);
				//return SDF_BlendN(pos, _TimeValue);
				return SDF_BlendN(pos, Remap(SawtoothWave(_Speed * _Time.y + _Offset), -1, 1, 0, 1));

				//return SDF_Blend3
				//(
				//	SDF_Sphere(pos, 0, 1),
				//	SDF_Box(pos, 0, 1),
				//	SDF_TriPrism(pos, float2(1, 1)),
				//	Remap(SawtoothWave(_Speed * _Time.y + _Offset), -1, 1, 0, 1)
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
