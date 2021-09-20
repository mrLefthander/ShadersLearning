Shader "Tutorial/Light/Ambient"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass 
		{
			Tags { "LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Color;
			float4 _LightColor0;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};			

			v2f vert (appdata IN)
			{
				v2f OUT;

				float atten = 1.0;
				float3 normalDirection = UnityObjectToWorldNormal(IN.normal);
				
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.col = float4(lightFinal * _Color.rgb, 1.0);

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				return IN.col;
			}

			ENDCG
		}
	}


}