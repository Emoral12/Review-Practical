Shader "Custom/PunchOutlineEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline Width", Range(0.00000005, 0.1)) = 0.005
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        ZWrite Off
        CGPROGRAM
            #pragma surface surf Lambert vertex:vert
            struct Input
            {
                float2 uv_MainTex;
            };

            float _Outline;
            float4 _OutlineColor;
            void vert (inout appdata_full v)
            {
                v.vertex.xyz += v.normal * _Outline; 
            }

            sampler2D _MainTex;
            void surf (Input IN, inout SurfaceOutput o)
            {
                o.Emission = _OutlineColor.rgb;
            }
        ENDCG

        Pass
        {
            Cull Front
            
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
                float4 pos : POSITION;
                fixed4 color : COLOR;
            };

            float _Outline;
            float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 norm =  normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                float2 offset = TransformViewToProjection(norm.xy);

                o.pos.xy += offset * o.pos.z * _Outline;
                o.pos = _OutlineColor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        ZWrite On
        
        CGPROGRAM
            #pragma surface surf Lambert
            struct Input
            {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            void surf (Input IN, inout SurfaceOutput o)
            {
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
