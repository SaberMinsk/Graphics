#include "Clouds/Shaders/Includes/CloudsLighting.hlsl"
#include "Clouds/Shaders/Includes/Clouds.hlsl"

sampler2D _CloudsTexture;

float3 EvaluateClouds(const float3 inputColor, const float2 uv, const float3 radiance)
{
    const CloudFactor cloudFactor = UnpackCloud(tex2D(_CloudsTexture, uv));

    const float density = saturate(cloudFactor.density * 2);

    float3 outputColor = lerp(inputColor + radiance, inputColor * cloudFactor.coloring, density);

    const float3 lightColor = ComputeLight() * cloudFactor.scattering;

    outputColor += lightColor;

    return outputColor;
}
