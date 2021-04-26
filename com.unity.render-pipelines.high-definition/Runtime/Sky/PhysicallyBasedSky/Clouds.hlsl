#include "Clouds/Shaders/Includes/CloudsLighting.hlsl"
#include "Clouds/Shaders/Includes/Clouds.hlsl"

sampler2D _CloudsTextureMain;
sampler2D _CloudsTextureAdditional;
    

float3 EvaluateClouds(const float3 inputColor, const CloudFactor cloudFactor)
{
    //HACK
    float density = saturate(cloudFactor.density * 2);
    
    float3 outputColor = lerp(inputColor, inputColor * cloudFactor.coloring, density);
        
    const float3 lightColor = ComputeLight() * cloudFactor.scattering;

    outputColor += lightColor;

    return outputColor;
}

float3 EvaluateClouds(const float3 inputColor, const float2 uv)
{    
    const CloudFactor mainCloud = UnpackCloud(tex2D(_CloudsTextureMain, uv));

    const float3 mainCloudColor = EvaluateClouds(inputColor, mainCloud);

    return mainCloudColor;
}

float3 EvaluateClouds2(const float3 inputColor, const float2 uv, const float4 vertex)
{
    v2f v;
    v.uv = float4(uv, 0, 1);
    v.vertex = vertex;
    
    const CloudFactor mainCloud = UnpackCloud(CloudsFrag(v));

    const float3 mainCloudColor = EvaluateClouds(inputColor, mainCloud);

    return mainCloudColor;
}