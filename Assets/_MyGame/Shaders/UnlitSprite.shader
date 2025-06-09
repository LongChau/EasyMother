Shader "Universal Render Pipeline/Unlit Sprite"
{

    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}	//0
		_Color("Main Color", Color) = (1,1,1,1)		//1
		_Alpha("General Alpha",  Range(0,1)) = 1	//2
    }

    SubShader
    {
		Tags { "Queue" = "Transparent" "CanUseSpriteAtlas" = "True" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
		

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

			#if FOG_ON
			#pragma multi_compile_fog
			#endif

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				half4 color : COLOR;
            	UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				half4 color : COLOR;
				#if OUTTEX_ON
				half2 uvOutTex : TEXCOORD1;
				#endif
				#if OUTDIST_ON
				half2 uvOutDistTex : TEXCOORD2;
				#endif
				#if DISTORT_ON
				half2 uvDistTex : TEXCOORD3;
				#endif
				#if FOG_ON
				UNITY_FOG_COORDS(4)
				#endif
            	UNITY_VERTEX_OUTPUT_STEREO 
            };

            sampler2D _MainTex;
            half4 _MainTex_ST, _MainTex_TexelSize, _Color;
			half _Alpha;

            v2f vert (appdata v)
            {
                v2f o;
            	UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
            	
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
            	
                return o;
            }

			half3 GetPixel(in int offsetX, in int offsetY, half2 uv, sampler2D tex)
			{
				return tex2D(tex, (uv + half2(offsetX * _MainTex_TexelSize.x, offsetY * _MainTex_TexelSize.y))).rgb;
			}

            half4 frag (v2f i) : SV_Target
            {
				half4 col = tex2D(_MainTex, i.uv);
				col *= i.color;
				col *= _Color;
                return col;
            }
            ENDCG
        }
    }
    
}