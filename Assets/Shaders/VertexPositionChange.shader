Shader "Tutorial/VertexPositionChange"
{
	Properties
	{
		_MainTexture("Texture", 2D) = "white" {}
		_Color("Colour", Color) = (1,1,1,1)
		_AnimationSpeed("Animation Speed", Range(0,3)) = 0
		_OffsetSize("Offset Size", Range(0, 10)) = 0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vertexFunc
			#pragma fragment fragmentFunc

			#include "UnityCG.cginc"

			struct appdata 
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};			
			
			sampler2D _MainTexture;
			fixed4 _Color;
			float _AnimationSpeed;
			float _OffsetSize;

			v2f vertexFunc(appdata IN)
			{
				v2f OUT;

				IN.vertex.x += sin(_Time.y * _AnimationSpeed + IN.vertex.y * _OffsetSize);
				OUT.position = UnityObjectToClipPos(IN.vertex);
				OUT.uv = IN.uv;
				return OUT;
			}

			fixed4 fragmentFunc(v2f IN) : SV_Target
			{
				fixed4 pixelColor = tex2D(_MainTexture, IN.uv);
				return pixelColor * _Color;
			}
			
			ENDCG
		}

	}


}
