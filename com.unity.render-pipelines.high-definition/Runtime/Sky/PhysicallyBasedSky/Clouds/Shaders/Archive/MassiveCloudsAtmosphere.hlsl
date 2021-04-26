#ifndef MASSIVE_CLOUDS_ATMOSPHERE_INCLUDED
#define MASSIVE_CLOUDS_ATMOSPHERE_INCLUDED

#include "../Includes/Clouds.hlsl"
#include "../Includes/CloudsScreenSpace.hlsl"
#include "MassiveCloudsPhysics.hlsl"

sampler2D _CloudsTexture;
half4     _CloudsTexture_ST;
float4    _CloudsTexture_TexelSize;

sampler2D _CameraGBufferTexture2;

inline float Raymarch(
    half3 screnCol,
    float3 from,
    float3 forward,
    float  far,
    float  rayLength,
    int    iteration)
{
    float3 ray;
    float4 col          = half4(screnCol.rgb, 0);

    float  totalDensity = 0;
    float  totalLight   = 0;

    // pre fade
    float cameraDist = length(from - _WorldSpaceCameraPos);
    float fade = 1 - smoothstep(_FromDistance, _MaxDistance, _Fade * cameraDist);
    #if defined(UNITY_COMPILER_HLSL)
    [loop]
    #endif
    for (int i = 0; i < iteration; ++i)
    {
        ray = rayLength * i * forward + from;
        
        #if defined(_HORIZONTAL_OsN)
        float isClip = step(horizontalRegion.height - 0.001, ray.y);
        #else
        float isClip = 1;
        #endif

    
        if (isClip == 0) continue;

        float  density = isClip * Sample(ray);
        totalDensity = totalDensity + 0.001 * density * rayLength;
    }

    return saturate(totalDensity);
}

float VolumetricShadowAttn(float3 worldPos, ScreenSpace ss, HorizontalRegion horizontalRegion, int iter)
{
    float3 lightDir = normalize(MassiveCloudsLightDirection);
    if (worldPos.y > (horizontalRegion.height + horizontalRegion.thickness/ 2)) return 0;
    float3 dCameraPos = float3(0, -(_RelativeHeight) * ss.cameraPos.y, 0);
    float upDotLight = saturate(dot(float3(0,1,0), lightDir));
    float bottomDist = max(0, horizontalRegion.height - worldPos.y - dCameraPos.y) / upDotLight;
    float topDist = max(0, horizontalRegion.height + horizontalRegion.thickness - worldPos.y - dCameraPos.y) / upDotLight;
    float thickness = topDist - bottomDist;
    float mid = bottomDist + (0.05 + 0.2 * horizontalRegion.softness[0]) * thickness;
    bottomDist = mid - 0.2 * thickness * 0;
    topDist = mid + 0.8 * thickness * 1 + 1;
    float shadowIter = iter;
    float shadow = Raymarch(float4(0,0,0,0),
                                    dCameraPos + worldPos + bottomDist * lightDir,
                                    lightDir,
                                    topDist,
                                    (topDist - bottomDist) / shadowIter,
                                    shadowIter);
    float att = shadow;
    return att;
}

inline float SceneLightOcclusion(ScreenSpace ss)
{
    float3 normal = tex2Dproj(_CameraGBufferTexture2, ss.uv).xyz;
    normal = 2 * (normal - (0.5, 0.5, 0.5));
    return saturate(dot(normalize(MassiveCloudsLightDirection), normalize(normal)));
}

float SunSet()
{
    return smoothstep(0.2, 0.3, MassiveCloudsLightDirection.y);
}

float Shadow(const ScreenSpace screenSpace)
{
    if (_Shadow <= 0)
    {
        return 0;
    }

    return SceneLightOcclusion(screenSpace) * SunSet() * VolumetricShadowAttn(screenSpace.worldPos, screenSpace, _HorizontalRegion, 3);
}
            
float4 AtmosphereFragment(ScreenSpace ss)
{
    AtmosphereFactor atmosphereFactor;
    
    float shadow = Shadow(ss);
    shadow = pow(shadow, 0.8);
    
    atmosphereFactor.scattering = 0;
    atmosphereFactor.depth  = ss.depth;
    atmosphereFactor.shadow = shadow;
    atmosphereFactor.shaft  = 0;

    return PackAtmosphere(atmosphereFactor);
}
#endif