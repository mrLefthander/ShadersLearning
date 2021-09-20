Shader "Tutorial/OptimizedEmitMap"
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
			half _Shininess;
			half _RimPower;
			fixed _EmitStrenght;
			sampler2D _MainTex;
            half4 _MainTex_ST;
			sampler2D _BumpMap;
            half4 _BumpMap_ST;
			sampler2D _EmitMap;
            half4 _EmitMap_ST;
			half4 _LightColor0;

			struct appdata 
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				fixed4 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;
				fixed3 normalWorld : TEXCOORD3;
				fixed3 tangentWorld : TEXCOORD4;
				fixed3 binormalWorld : TEXCOORD5;
				
			};

			v2f vert (appdata IN)
			{
				v2f OUT;

				OUT.pos = UnityObjectToClipPos(IN.vertex);				
				OUT.normalWorld = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tangentWorld = normalize(mul(unity_ObjectToWorld, IN.tangent).xyz);
				OUT.binormalWorld = normalize(cross(OUT.normalWorld, OUT.tangentWorld) * IN.tangent.w);
				OUT.tex = IN.texcoord;					

				half4 posWorld = mul(unity_ObjectToWorld, IN.vertex);
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;

				OUT.lightDirection = fixed4(
					normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)), 
					lerp(1.0, 1.0 / length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);

				OUT.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);	

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, IN.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);
				fixed4 texE = tex2D(_EmitMap, IN.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw);

				half3 localCoords = UnpackNormal(texN);

				fixed3x3 localToWorldTranspose = fixed3x3(
					IN.tangentWorld,
					IN.binormalWorld,
					IN.normalWorld
				);
				
				fixed3 normalDirection = normalize(mul(localCoords, localToWorldTranspose));

				fixed3 diffuseReflection = IN.lightDirection.w * _LightColor0.rgb * saturate(dot(normalDirection, IN.lightDirection.xyz));
				fixed3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-IN.lightDirection.xyz, normalDirection), IN.viewDirection)), _Shininess);
				
				fixed rim = 1 - saturate(dot(IN.viewDirection, normalDirection));
				fixed3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				fixed3 lightFinal = (texE.xyz * _EmitStrenght) + rimLighting + diffuseReflection + (specularReflection * tex.a) + UNITY_LIGHTMODEL_AMBIENT.xyz;	

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
			half _Shininess;
			half _RimPower;
			fixed _EmitStrenght;
			sampler2D _MainTex;
            half4 _MainTex_ST;
			sampler2D _BumpMap;
            half4 _BumpMap_ST;
			sampler2D _EmitMap;
            half4 _EmitMap_ST;
			half4 _LightColor0;

			struct appdata 
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				fixed4 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;
				fixed3 normalWorld : TEXCOORD3;
				fixed3 tangentWorld : TEXCOORD4;
				fixed3 binormalWorld : TEXCOORD5;
				
			};

			v2f vert (appdata IN)
			{
				v2f OUT;

				OUT.pos = UnityObjectToClipPos(IN.vertex);				
				OUT.normalWorld = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
				OUT.tangentWorld = normalize(mul(unity_ObjectToWorld, IN.tangent).xyz);
				OUT.binormalWorld = normalize(cross(OUT.normalWorld, OUT.tangentWorld) * IN.tangent.w);
				OUT.tex = IN.texcoord;					

				half4 posWorld = mul(unity_ObjectToWorld, IN.vertex);
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;

				OUT.lightDirection = fixed4(
					normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)), 
					lerp(1.0, 1.0 / length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);

				OUT.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);	

				return OUT;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 tex = tex2D(_MainTex, IN.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, IN.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				half3 localCoords = UnpackNormal(texN);

				fixed3x3 localToWorldTranspose = fixed3x3(
					IN.tangentWorld,
					IN.binormalWorld,
					IN.normalWorld
				);
				
				fixed3 normalDirection = normalize(mul(localCoords, localToWorldTranspose));

				fixed3 diffuseReflection = IN.lightDirection.w * _LightColor0.rgb * saturate(dot(normalDirection, IN.lightDirection.xyz));
				fixed3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-IN.lightDirection.xyz, normalDirection), IN.viewDirection)), _Shininess);
				
				fixed rim = 1 - saturate(dot(IN.viewDirection, normalDirection));
				fixed3 rimLighting = diffuseReflection * _RimColor.rgb * pow(rim, _RimPower);
				fixed3 lightFinal = rimLighting + diffuseReflection + (specularReflection * tex.a);	

				return fixed4(tex * lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
		
	}
	//Fallback "Specular"
}