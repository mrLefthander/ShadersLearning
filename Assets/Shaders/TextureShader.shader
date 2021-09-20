Shader "Tutorial/Texture"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", Range(0.5,25)) = 1
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
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

			fixed4 _Color;
			fixed4 _SpecColor;
			fixed4 _RimColor;
			float _Shininess;
			float _RimPower;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _LightColor0;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD3;
			};

			v2f vert (appdata IN)
			{
				v2f OUT;
				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, IN.vertex);
				OUT.normalDir = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tex = IN.texcoord;

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				float3 normalDirection = IN.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);	
				float3 lightDirection;
				float atten;

				if(_WorldSpaceLightPos0.w == 0.0)
				{
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - IN.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1 / distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				float3 diffuseReflection = atten * _LightColor0.rgb * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;		

				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);


				return fixed4(tex * lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
        Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _Color;
			fixed4 _SpecColor;
			fixed4 _RimColor;
			float _Shininess;
			float _RimPower;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _LightColor0;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD3;
			};

			v2f vert (appdata IN)
			{
				v2f OUT;
				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, IN.vertex);
				OUT.normalDir = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tex = IN.texcoord;

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				float3 normalDirection = IN.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);	
				float3 lightDirection;
				float atten;

				if(_WorldSpaceLightPos0.w == 0.0)
				{
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - IN.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1 / distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				float3 diffuseReflection = atten * _LightColor0.rgb * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;		

				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);


				return fixed4(tex * lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
	}
	//Fallback "Specular"
}