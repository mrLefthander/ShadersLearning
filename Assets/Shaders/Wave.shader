Shader "Tutorial/Wave"
{
    Properties
    {
        _Color("Color", Color) = (0,0,0,1)
        _Amplitude("Amplitude", Range(0,2)) = 1.0
        _Speed("Speed", Range(-200,200)) = 100
    }
    SubShader
    {
        Tags { "RenderType"="transparent" }

        Pass
        {
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float _Amplitude;
            float _Speed;

            struct vertexInput
            {
                float4 vertex : POSITION;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
            };

            vertexOutput vert(vertexInput IN)
            {
                vertexOutput OUT;
                float4 worldPos = mul(unity_ObjectToWorld, IN.vertex);
                float displacement = cos(worldPos.y) + cos(worldPos.x + _Speed * _Time);
                worldPos.y += (displacement * _Amplitude);
                OUT.pos = mul(UNITY_MATRIX_VP, worldPos);

                return OUT;            
            }

            float4 frag (vertexOutput IN) : COLOR 
            {
                return _Color;
            }


            ENDCG
        }
    }
}
