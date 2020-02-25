Shader "RayTracing/RayTracingTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_T("t Parameter", Range(0,1)) = 0
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
			#include "Ray.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float _T;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;

				Ray testRay;

				testRay.origin = float3(0, 0, 0);
				testRay.direction = float3(1, 0, 0);

				col.rgb = testRay.point_at_parameter(_T);
				col.a = 1.0;

                return col;
            }
            ENDCG
        }
    }
}
