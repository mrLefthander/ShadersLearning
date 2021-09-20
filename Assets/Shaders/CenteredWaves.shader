Shader "Tutorial/CenteredWaves"
{
    Properties
    {
        _WavesCount ("Waves Count", Float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _WavesCount;

            float GetWave(float2 uv)
            {
                float2 uvsCentered = uv * 2 - 1;
                float radialDistance = length(uvsCentered);
                float waves = cos((radialDistance - _Time.y * 0.1) * UNITY_TWO_PI * _WavesCount) * 0.5 + 0.5;
                waves *= 1 - radialDistance;
                return waves;
            }

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.y = GetWave(v.uv);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
