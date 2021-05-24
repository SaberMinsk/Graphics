#ifndef CLOUDS_SCREEN_SPACE_INCLUDED
#define CLOUDS_SCREEN_SPACE_INCLUDED

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

struct ScreenSpace
{
    float3           cameraPos;
    float3           worldPos;
    float            maxDist;
    float            isMaxPlane;
    float3           rayDir;
    float            depth;
    float4           uv;
};


float SampleCameraDepth(float4 uv)
{
    return Linear01Depth(LoadCameraDepth(uint2(uv.xy * _ScreenSize.xy)), _ZBufferParams);
}

float4 CalculateWorldPos(float4 uv, float depth)
{
    float4 posProjection = float4(- 1 + 2 * uv.xy, 1, 1);
    float3 view          = mul(unity_CameraInvProjection, posProjection).xyz * _ProjectionParams.z;
    view = view * depth;
    view.z *= -1; // revert z on all platform
    return mul(unity_CameraToWorld, float4(view, 1));
}

float CalculateDepth(float4 uv)
{
    return SampleCameraDepth(uv);
}

ScreenSpace CreateScreenSpace(float4 uv)
{
    ScreenSpace ss;
    float       depth          = CalculateDepth(uv);
    float3      cameraPos      = _WorldSpaceCameraPos;
    float3      world          = CalculateWorldPos(uv, depth).xyz;
    float3      rayDir         = normalize(world.xyz - cameraPos);
    float       isMaxPlane     = smoothstep(0.9, 0.999, depth);
    float       maxDist        = length(world.xyz - cameraPos);

    ss.cameraPos  = cameraPos;
    ss.worldPos   = world;
    ss.isMaxPlane = isMaxPlane;
    ss.maxDist    = maxDist;
    ss.rayDir     = rayDir;
    ss.depth      = depth;
    ss.uv         = uv;

    return ss;
}
#endif
