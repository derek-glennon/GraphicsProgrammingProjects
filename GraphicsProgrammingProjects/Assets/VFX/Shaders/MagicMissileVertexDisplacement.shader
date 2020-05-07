Shader "VFX/MagicMissileVertexDisplacement"
{
	Properties
	{
		[Header(Vertex Displacement)]
		_VertexDisplacement("Vertex Displacement", Range(-2, 2)) = 0

		[Header(Gradient)]
		_GradientPosition("Gradient Position", Range(-2, 2)) = 0
		_StartColor("Starting Particle Color", Color) = (0,0,0,1)
		_EndColor("Ending Particle Color", Color) = (1,1,1,1)

		[Header(Noise Texture)][Space(5)]
		_NoiseTex("Noise Texture", 2D) = "white" {}

		[Header(Base Noise Layer)][Space(5)]
		_ScrollSpeedU("Scroll Speed U", float) = 0
		_ScrollSpeedV("Scroll Speed V", float) = 0
		_OffsetU("Offset U", float) = 0
		_OffsetV("Offset V", float) = 0
		_Scale("Scale", float) = 1
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
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
					fixed4 color : COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 objectVertex : TEXCOORD1;
					fixed4 color : COLOR;
				};
				
				//Vertex Displacement
				float _VertexDisplacement;

				//Particle Gradient
				float _GradientPosition;
				fixed4 _StartColor;
				fixed4 _EndColor;

				//Noise Texture
				sampler2D _NoiseTex;
				float4 _NoiseTex_ST;

				//Base Noise Layer
				fixed4 _MainColor;
				float _ScrollSpeedU;
				float _ScrollSpeedV;
				float _OffsetU;
				float _OffsetV;
				float _Scale;

				//Remaps x from a-b to c-d
				inline float Remap(float x, float a, float b, float c, float d)
				{
					return (c + (x - a) * ((d - c) / (b - a)));
				}

				v2f vert(appdata v)
				{
					v2f o;
					o.objectVertex = v.vertex;

					float2 vertexUVs = ((v.uv + float2(_OffsetU, _OffsetV)) + (_Time.x * float2(_ScrollSpeedU, _ScrollSpeedV))) * _Scale;
					float vertexGradient = saturate(1 - (Remap(v.vertex.y, -1, 1, 0, 1) + _VertexDisplacement));
					v.vertex.y -= tex2Dlod(_NoiseTex, float4(vertexUVs, 0.0, 0.0)).rgb * vertexGradient;

					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
					o.color = lerp(_StartColor, _EndColor, saturate(1 - (Remap(v.vertex.y, -1, 1, 0, 1) + _GradientPosition)));
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col;
					col.rgb = i.color;
					col.a = 1;
					return col;
				}
				ENDCG
			}
		}
}
