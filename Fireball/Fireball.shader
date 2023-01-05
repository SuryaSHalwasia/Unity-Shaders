Shader "FireBall"
{
    Properties
    {
        _Scale("Scale", Range(0.1, 3)) = 0.3
        _MainTex("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
     
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos: TEXCOORD2;
                float2 uv: TEXCOORD0;
                float4 noise: TEXCOORD1;
            };

            float _Scale;
            sampler2D _MainTex;
            
            float random( float3 pt, float seed ){
                float3 scale = float3( 12.9898, 78.233, 151.7182 );
                return frac( sin( dot( pt + seed, scale ) ) * 43758.5453 + seed ) ;
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                // add time to the noise for animating
                o.noise = 0;
                // get a turbulent 3d noise
                o.noise.x = 10.0 *  -0.10 * turbulence( 0.5 * v.normal + _Time.y );
                float3 size = 100;
                float b = _Scale * 0.5 * pnoise( 0.05 * v.vertex + _Time.y, size );
                float displacement = b - _Scale * o.noise.x;

                // move the position along the normal to transform it
                float3 newPosition = v.vertex + v.normal * displacement;
                o.pos = UnityObjectToClipPos(newPosition);
                o.screenPos = ComputeScreenPos(o.pos);
                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // offset
                float3 fragCoord = float3(i.screenPos.xy * _ScreenParams, 0);
                float r = .01 * random( fragCoord, 0.0 );
                // to get the right RGB colour
                float2 uv = float2( 0, 1.3 * i.noise.x + r );
                fixed3 color = tex2D( _MainTex, uv ).rgb;

                return fixed4( color, 1 );
            }
            ENDCG
        }
    }
}

