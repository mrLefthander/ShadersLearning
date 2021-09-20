Shader "Tutorial/EnergyAura"
{
    Properties
    {
        _ColorA ("Bottom Color", Color) = (1,1,1,1)
        _ColorB ("Top Color", Color) = (1,1,1,1)
        _Waviness ("Waviness", Float) = 15
        _WavesCount ("Waves Count", Float) = 10
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Quenue" = "Transparent"
        }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 normal : TEXCOORD1;
            };

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _Waviness;
            float _WavesCount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float applyWaviness = ceil(_Waviness) * 2;
                float yOffset = cos(i.uv.x * UNITY_PI * applyWaviness)/100;
                float waves = cos((i.uv.y + yOffset - _Time.y * 0.1) * UNITY_TWO_PI * _WavesCount) * 0.5 + 0.5;
                float fade = 1 - i.uv.y;
                waves *= fade;
                float topBottomRemover = (abs(i.normal.y) <= 0.99);
                waves *= topBottomRemover;
                fixed4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                return waves * gradient;
            }
            ENDCG
        }
    }
}
