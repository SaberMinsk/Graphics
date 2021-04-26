#ifndef MASSIVE_CLOUDS_SHADOW_INCLUDED
#define MASSIVE_CLOUDS_SHADOW_INCLUDED

#include "../Includes/CloudsScreenSpace.hlsl"
#include "MassiveCloudsShadowRaymarch.hlsl"

float ShadowAttn(float3 worldPos, ScreenSpace ss)
{
    float3 cameraPos = _WorldSpaceCameraPos;
    if (worldPos.y > (_HorizontalRegion.height + _HorizontalRegion.thickness/ 2)) return 0;
    float3 dCameraPos = float3(0, -(_RelativeHeight) * cameraPos.y, 0);
    float dist = length(worldPos - _WorldSpaceCameraPos);
    float worldDotLight = saturate(dot(float3(0, 1, 0), MassiveCloudsLightDirection));
    float bottomDist = max(0, _HorizontalRegion.height - worldPos.y - dCameraPos.y) / worldDotLight;
    float topDist = max(0, _HorizontalRegion.height + _HorizontalRegion.thickness - worldPos.y - dCameraPos.y) / worldDotLight;
    float thickness = topDist - bottomDist;
    float mid = bottomDist + 0.1 * thickness;
    bottomDist = mid - 0.1 * thickness * _ShadowQuality;
    topDist = mid + 0.9 * thickness * _ShadowQuality;
    float shadowIter = _ShadowQuality * 49 + 1;
    float shadow = ShadowRaymarch(float4(0,0,0,0),
                                    dCameraPos + worldPos + bottomDist * MassiveCloudsLightDirection,
                                    MassiveCloudsLightDirection,
                                    topDist,
                                    (topDist - bottomDist) / shadowIter,
                                    shadowIter);
    shadow *= pow(worldDotLight, 1);
    float att = shadow / ((0.01 + 2 * _ShadowSoftness)) * (1 - ss.isMaxPlane);
    return att * (2 * _ShadowStrength);
}

#if SHADEROPTIONS_PRE_EXPOSITION
float4 ShadowColor()
{
    float4 col = _ShadowColor;
    col.rgb *= GetCurrentExposureMultiplier();
    return col;
}
#else
float4 ShadowColor()
{
    return _ShadowColor;
}
#endif

float luminance(half3 col)
{
    const half3 w = half3(0.2125, 0.7154, 0.0721);
    return dot(col.rgb, w);
}

void ScreenSpaceShadow(inout half4 screenCol, float3 worldPos, ScreenSpace ss)
{
    float4 shadowColor = ShadowColor();
    float attn = ShadowAttn(worldPos, ss);
    float l = saturate(luminance(screenCol));
    float luminanceFactor = smoothstep(_ShadowThreshold/2, _ShadowThreshold, l);
    float3 col = half3(1,1,1) - lerp(normalize(screenCol.rgb) * shadowColor.rgb, shadowColor.rgb, shadowColor.a);
    attn = luminanceFactor * saturate(attn);
    screenCol.rgb *= saturate(1 - col * attn);
}

// float3 MixShadows(float3 inputColor, AtmosphereFactor atmosphereFactor, CloudFactor cloudFactor, ScreenSpace screenSpace)
// {
//     float shadowFactor = _Shadow * pow(1 - atmosphereFactor.scattering, 4) *
//      (1 - cloudFactor.density) *
//      (1 - screenSpace.isMaxPlane) *
//      saturate(30 * atmosphereFactor.shadow);
//     
//     float dstScattering = atmosphereFactor.scattering;
//     dstScattering *= saturate(1 - 0.5 * shadowFactor);
//     float3 dstCol = ComputeLight(screenSpace) * dstScattering;
//     
//     float3 outputColor = inputColor * (1 - 0.5 * shadowFactor);
//     outputColor += dstCol;
//
//     return outputColor;
// }
#endif