#ifndef CLOUDS_LIGHTING_INCLUDED
#define CLOUDS_LIGHTING_INCLUDED

#define HAS_LIGHTLOOP
#define SHADOW_HIGH
#define LIGHTLOOP_DISABLE_TILE_AND_CLUSTER

#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Lighting/LightLoop/CookieSampling.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/VolumeRendering.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Debug.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/AreaLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Material/Builtin/BuiltinData.cs.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Material/Material.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Lighting/Shadow/HDShadowContext.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Lighting/LightLoop/HDShadow.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Sky/PhysicallyBasedSky/ShaderVariablesPhysicallyBasedSky.cs.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Sky/PhysicallyBasedSky/PhysicallyBasedSkyCommon.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Material/Lit/Lit.hlsl"
#include "LocalPackages/com.unity.render-pipelines.high-definition@10.3.1/Runtime/Sky/SkyUtils.hlsl"

float3 ComputeLight()
{
    LightLoopContext context;
    const PositionInputs inputs = GetPositionInput(0, 0, 1, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

    float3 color;
        
    for (int i = 0; i < _DirectionalLightCount; ++i)
    {
        const DirectionalLightData directionalLightData = _DirectionalLightDatas[i];
            
        color += EvaluateLight_Directional(context, inputs, directionalLightData);
    }

    return color;
}
#endif