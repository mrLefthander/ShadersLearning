Shader "Tutorial/EmitMap"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse Texture gloss(A)", 2D) = "white" {}
		_BumpMap ("Normal Map Texture", 2D) = "bump" {}
		_EmitMap ("Emission Texture", 2D) = "black" {}
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", Range(0.5,25)) = 1
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
		_EmitStrenght ("Emission Strenght", Range(0, 2.0)) = 1.0
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
			float _EmitStrenght;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
            float4 _BumpMap_ST;
			sampler2D _EmitMap;
            float4 _EmitMap_ST;
			fixed4 _LightColor0;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
				
			};

			v2f vert (appdata IN)
			{
				v2f OUT;

				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, IN.vertex);
				OUT.normalWorld = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tangentWorld = normalize(mul(unity_ObjectToWorld, IN.tangent).xyz);
				OUT.binormalWorld = normalize(cross(OUT.normalWorld, OUT.tangentWorld) * IN.tangent.w);

				OUT.tex = IN.texcoord;

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				
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

				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, IN.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
				fixed4 texE = tex2D(_EmitMap, IN.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw);

				float3 localCoords = UnpackNormal(texN);

				float3x3 localToWorldTranspose = float3x3(
					IN.tangentWorld,
					IN.binormalWorld,
					IN.normalWorld
				);
				
				float3 normalDirection = normalize(mul(localCoords, localToWorldTranspose));


				float3 diffuseReflection = atten * _LightColor0.rgb * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				float3 lightFinal = (texE.xyz * _EmitStrenght) + rimLighting + diffuseReflection + (specularReflection * tex.a) + UNITY_LIGHTMODEL_AMBIENT.xyz;	

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
			sampler2D _BumpMap;
            float4 _BumpMap_ST;
			fixed4 _LightColor0;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
				
			};

			v2f vert (appdata IN)
			{
				v2f OUT;

				OUT.pos = UnityObjectToClipPos(IN.vertex);
				OUT.posWorld = mul(unity_ObjectToWorld, IN.vertex);
				OUT.normalWorld = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tangentWorld = normalize(mul(unity_ObjectToWorld, IN.tangent).xyz);
				OUT.binormalWorld = normalize(cross(OUT.normalWorld, OUT.tangentWorld) * IN.tangent.w);

				OUT.tex = IN.texcoord;

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				
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

				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, IN.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				float3 localCoords = UnpackNormal(texN);

				float3x3 localToWorldTranspose = float3x3(
					IN.tangentWorld,
					IN.binormalWorld,
					IN.normalWorld
				);
				
				float3 normalDirection = normalize(mul(localCoords, localToWorldTranspose));


				float3 diffuseReflection = atten * _LightColor0.rgb * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				float3 lightFinal = rimLighting + diffuseReflection + (specularReflection * tex.a);	

				return fixed4(tex * lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
	}
	//Fallback "Specular"
}