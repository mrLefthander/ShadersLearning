Shader "Tutorial/Light/Specular"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Range(0.5,25)) = 1
	}
	SubShader
	{
		Pass 
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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

			float4 _Color;
			float4 _SpecColor;
			float4 _LightColor0;
			float _Shininess;

			v2f vert (appdata IN)
			{
				v2f OUT;
				OUT.pos = UnityObjectToClipPos(IN.vertex);

				float atten = 1.0;
				float3 normalDirection = UnityObjectToWorldNormal(IN.normal);
				float3 viewDirection = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, IN.vertex).xyz));				
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 specularReflection = atten * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection))  *  pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;				

				OUT.col = float4(lightFinal * _Color.rgb, 1);

				return OUT;
			}

			fixed4 frag(v2f IN) : COLOR
			{
				return IN.col;
			}



			ENDCG
		}
	}
}