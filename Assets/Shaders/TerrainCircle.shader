Shader "Tutorial/TerrainCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (0,1,0)
        _CircleColor("Circle Color", Color) = (1,0,0)
        _Center("Center", Vector) = (0,0,0,0)
        _Radius("Radius", Range(0,10)) = 3
        _Thickness("Thikness", Range(0,10)) = 5
    }

    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        fixed3 _MainColor;
        fixed3 _CircleColor;
        float3 _Center;
        float _Radius;
        float _Thickness;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void surf(Input IN, inout SurfaceOutput OUT)
        {
            OUT.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            float dist = distance(_Center, IN.worldPos);

            if(dist > _Radius && dist < (_Radius + _Thickness))
            {
                OUT.Albedo *= _CircleColor;
            }
            else
            {
                OUT.Albedo *= _MainColor;
            }
           // OUT.Alpha = c.a;
        }

        ENDCG
    }
 
}
