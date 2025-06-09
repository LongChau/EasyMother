Shader "Unlit/BillboardCutOff"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _Cutoff("Cutoff", Float) = 0.5
    }
 
    SubShader
    {
        Tags{ "Queue" = "AlphaTest"  "IgnoreProjector" = "True" "RenderType" = "Opaque" "DisableBatching" = "True" }
        
        ZWrite On
        Blend One Zero
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
            };

            float _EditorOnly;
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy;

                if (_EditorOnly >= 0.5)
                {
                    return o;
                }
 
                // billboard mesh towards camera
                float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
                float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);

                o.pos = mul(UNITY_MATRIX_P, viewPos);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                //UNITY_APPLY_FOG(i.fogCoord, col);
                if(col.a < _Cutoff)
                    discard;
                
                return col;
            }
            ENDCG
        }
    }
}