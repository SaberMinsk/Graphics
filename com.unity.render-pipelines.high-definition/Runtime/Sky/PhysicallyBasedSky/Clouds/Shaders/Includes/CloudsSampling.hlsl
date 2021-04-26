#ifndef CLOUDS_SAMPLING_INCLUDED
#define CLOUDS_SAMPLING_INCLUDED

#include "CloudsScreenSpace.hlsl"
#include "CloudsSampler.hlsl"

struct CloudFactor
{
    float scattering;
    float density;
    float coloring;
    float depth;
};

CloudFactor UnpackCloud(float4 col)
{
    CloudFactor cloudFactor;
    cloudFactor.scattering = col.r;
    cloudFactor.density = col.g;
    cloudFactor.coloring = col.b;
    cloudFactor.depth = col.a;
    return cloudFactor;
}

float4 PackCloud(CloudFactor cloudFactor)
{
    return float4(
        cloudFactor.scattering,
        cloudFactor.density,
        cloudFactor.coloring,
        cloudFactor.depth);
}

float Sample(float3 position)
{
    const float3 texturePosition = position * _Octave + _OctaveTexOffset;
    float4 dtex = SampleVolumeTexture(texturePosition) - 0.5;

    float3 wpos = position + _Warp * dtex.aaa;

    float base = ClipHorizontalDensity(position, SampleBaseDensity(wpos));

    float4 s = base.xxxx * _Sculptures * dtex;
    base += dot(s, 1);

    // Softness
    float densityScale = 1 - ClipHorizontalDensity(position, _Density);

    float density = pow(base, _Softness) * _Softness;
    density = saturate(density - _Softness * densityScale);
    density = pow(density, 1.1 - _Softness);

    base = density * _Softness;

    return base;
}

inline float CalculateLightOcclusion(
    float baseDensity,
    float3 pos,
    float3 forward)
{
    float progression = _ShadingDistance * 100;
    float step = max(1, progression) * 2;
    step /= 1 + 2 * baseDensity;
    float density = baseDensity;

    float i = 0;

    #if defined(UNITY_COMPILER_HLSL)
    [loop]
    #endif
    for (; i < _LightingQuality; ++i)
    {
        float3 rayPos = pos + progression * forward;
        
        if (rayPos.y >= _FromHeight + _Thickness || rayPos.y <= _FromHeight)
        {
            break;
        }
        
        float scattering = pow(1 - _LightScattering, 4);
        density += saturate(Sample(rayPos) * scattering) * step;
        if (density >= 1) break;
        step *= 2 / (1 + 2 * density);
        progression += step;
    }
    
    return pow(saturate(density), 2);
}

inline float PhysicsCloudStep(float progression)
{
    float baseStep = 5;
    return baseStep + max(0, 0.01 * progression);
}

CloudFactor PhysicsCloud(Ray ray, ScreenSpace screenSpace)
{
    float progression = ray.from;
    float step = PhysicsCloudStep(progression);
    float skip = 0;
    float skipProgression = 50;

    float scattering = 0;
    float density = 0;
    float occludedTo = min(ray.to, lerp(screenSpace.maxDist, _MaxDistance, screenSpace.isMaxPlane));
    float mie = saturate(dot(MassiveCloudsLightDirection, screenSpace.rayDir));
    float totalDensity = 0;
    bool done = progression > ray.to || progression > _MaxDistance;

    #if defined(UNITY_COMPILER_HLSL)
    [loop]
    #endif
    for (float i = 0; !done; ++i)
    {
        done = progression > ray.to || progression > _MaxDistance || totalDensity >= 1;

        float3 rayPos = screenSpace.cameraPos + progression * screenSpace.rayDir;
        float currentDensity = Sample(rayPos);

        if (currentDensity <= 0.00001)
        {
            skip = 1;
            float nscale = 1 + lerp(0.5, 0, saturate(progression / 5000));
            step = nscale * min(ray.length / 2, PhysicsCloudStep(progression));
            progression += step;
        }
        else
        {
            if (skip >= 1)
            {
                progression -= step;
                currentDensity = 0;
                rayPos = screenSpace.cameraPos + progression * screenSpace.rayDir;
                skipProgression = 50;
                skip = 0;
            }

            if (currentDensity > 0)
            {
                float lightOcclusion = CalculateLightOcclusion(totalDensity, rayPos, MassiveCloudsLightDirection);

                const float shadingInv = max(0.0001, 1 - _Shading);
                lightOcclusion = 1 - pow(lightOcclusion, shadingInv);

                const float lighting = lightOcclusion * exp(-currentDensity)
                    * lerp(lightOcclusion * (1 - exp(-2 * currentDensity)), 0.1, _Shading);
                
                if (progression < occludedTo)
                {
                    scattering += (1 - scattering) * saturate(lighting * currentDensity);
                    density += saturate((1.01 - density) * saturate(currentDensity));
                }
                
                totalDensity += currentDensity;
            }

            step = min(PhysicsCloudStep(skipProgression), 200);
            progression += step;
            skipProgression += step;
        }
    }

    scattering = saturate(_Lighting * scattering);
    scattering = scattering + _Mie * pow(mie, 2) * density / 10;

    CloudFactor cloudFactor;
    
    cloudFactor.scattering = scattering;
    cloudFactor.density = density;
    cloudFactor.coloring = _Coloring;

    return cloudFactor;
}
#endif