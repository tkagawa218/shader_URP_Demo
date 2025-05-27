Shader "Custom/FireWithEmission"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 0.5, 0.1, 1)
        _MainTex("Noise Texture", 2D) = "white" {}
        _EmissionMap("Emission Map", 2D) = "white" {}
        _EmissionColor("Emission Color", Color) = (1, 0.5, 0.1, 1)
        _EmissionIntensity("Emission Intensity", Float) = 3.0
        _AlphaClip("Alpha Clip", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Pass
        {
            Name "GBuffer"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _EmissionMap;
            float4 _MainTex_ST;
            float4 _EmissionMap_ST;
            float4 _BaseColor;
            float4 _EmissionColor;
            float _EmissionIntensity;
            float _AlphaClip;

            float Hash_LegacyMod(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

       
            float2 Unity_RadialShear_float(float2 UV, float2 Center, float2 Strength, float2 Offset)
            {
                float2 delta = UV - Center;
                float delta2 = dot(delta.xy, delta.xy);
                float2 delta_offset = delta2 * Strength;
                return UV + float2(delta.y, -delta.x) * delta_offset + Offset;
            }
        
            float2 Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset)
            {
                return UV * Tiling + Offset;
            }
        
            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
            {
                float x = Hash_LegacyMod(p);
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
        
            float Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale)
            {
                float2 p = UV * Scale.xy;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }
        
            float Unity_Lerp_float(float A, float B, float T)
            {
                return lerp(A, B, T);
            }
        
            float Unity_InvertColors_float(float In, float InvertColors)
            {
                return abs(InvertColors - In);
            }
        
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
        
            float Unity_Subtract_float(float A, float B)
            {
                return A - B;
            }
        
            float Unity_Step_float(float Edge, float In)
            {
                return step(Edge, In);
            }
        
            float4 Unity_Multiply_float4_float4(float4 A, float4 B)
            {
                return A * B;
            }
        
            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                
                float2 radial1 = Unity_RadialShear_float(uv, float2(0.5, 0.4), float2(1.0, 3.0), float2(_Time.y * 0.25, 0));
                float2 radial2 = Unity_RadialShear_float(uv, float2(0.5, 0.4), float2(1.0, 2.0), float2(0, _Time.y * 0.25));

                float2 tiling1 = Unity_TilingAndOffset_float(radial1, float2(0.7, 0.5), float2(0.0, 0.0));
                float2 tiling2 = Unity_TilingAndOffset_float(radial2, float2(0.7, 0.4), float2(0.0, 0.0));

                float noiseA = Unity_GradientNoise_LegacyMod_float(tiling1, float3(20,0,0));
                float noiseB = Unity_GradientNoise_LegacyMod_float(tiling2, float3(15,0,0));

                // UV distortion via time-based noise offset
                float noiseCombined = noiseA * noiseB;

                // Alpha based on noise and UV gradient
                float alpha = Unity_Lerp_float(0.0, 4.0, noiseCombined);

                float invertColors = Unity_InvertColors_float(i.uv.y, 1.0);
                float lerped = Unity_Lerp_float(0.0, 2.0, invertColors);

                alpha = alpha + lerped;

                float4 tex = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _EmissionMap));
 
                float toSubtract = alpha * tex.x;

                float subtract1 = Unity_Subtract_float(toSubtract, 1.0);
                float subtract2 = Unity_Subtract_float(toSubtract, 0.5);
                float subtract3 = Unity_Subtract_float(toSubtract, 0.0);

                float step1 = Unity_Step_float(1.28, subtract1);
                float step2 = Unity_Step_float(1.28, subtract2);
                float step3 = Unity_Step_float(1.28, subtract3);
                float3 base = Unity_Multiply_float4_float4(step1, float4(0.8,0.6,0.3,0.0)) + Unity_Multiply_float4_float4(step2, float4(0.7,0.4,0.0,0.0)) + Unity_Multiply_float4_float4(step3, float4(0.8,0.7,0.0,0.0));

                // Emission
                float3 emission = tex2D(_EmissionMap, TRANSFORM_TEX(i.uv, _EmissionMap)).rgb * _EmissionColor.rgb * _EmissionIntensity;

                return float4(base + emission, step3);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}
