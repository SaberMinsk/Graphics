#ifndef CLOUDS_SAMPLER_INCLUDED
#define CLOUDS_SAMPLER_INCLUDED

#include "CloudsVariables.hlsl"
#include "CloudsShape.hlsl"

float3 _TextureOffset;
float3 _BaseTexOffset;
float3 _BaseTexScale;
float3 _OctaveTexScale;
float3 _OctaveTexOffset;
HorizontalRegion _HorizontalRegion;
float3 MassiveCloudsLightDirection;

inline float4 HorizontalSculpt(float3 pos)
{
    HorizontalRegion horizontalRegion = _HorizontalRegion;

    float2 softnessLength = float2(
        0.01 + horizontalRegion.softness[1],
        0.01 + horizontalRegion.softness[0]
    ) * horizontalRegion.thickness;

    float2 height = float2(
        horizontalRegion.height + horizontalRegion.thickness,
        horizontalRegion.height
    );

    float2 rate = saturate(float2(
        height.x - pos.y,
        pos.y -  height.y
    ) / softnessLength);

    float2 sculptFactor = float2(1, 1) - rate;
    float2 fade = saturate(rate.xy * 10);

    return float4(
        fade.xy,
        sculptFactor.xy
    );
}

inline float ClipHorizontalDensity(
    float3 pos,
    float  density)
{
    float4 sculpt       = HorizontalSculpt(pos);
    float  sculptFactor = pow(pow(density, 1.5), 4 * _HorizontalSoftnessFigure)
                        * max(sculpt.z, pow(sculpt.w, 2));
    return saturate(sculpt.x * sculpt.y * density - pow(sculptFactor, 1));
}

inline void PrepareSampler()
{
    _HorizontalRegion = CreateRegion();
    
    _BaseTexScale = _VolumeTex_ST.xyx / _Scale;
    _OctaveTexScale = _BaseTexScale * _Octave;

    _BaseTexOffset = _TextureOffset * _BaseTexScale;
    _OctaveTexOffset = _TextureOffset * (1 + _Phase) * _OctaveTexScale;

    MassiveCloudsLightDirection = -_DirectionalLightDatas[0].forward;
 
    _ShadingDist =  _Shading * _Shading * _Thickness;
}

inline float SampleDensity(float3 pos, float scale, float phase)
{
    float3 texScale = _VolumeTex_ST.xyx / scale;
    float3 texOffset = _TextureOffset * phase * texScale;
    float3 texPos =  pos * texScale + texOffset;
    
    return tex3Dlod(_VolumeTex, float4(texPos, 0)).a;
}

inline float4 SampleVolumeTexture(float3 pos)
{
    return tex3Dlod(_VolumeTex, float4(pos, 0));
}

inline float SampleBaseDensity(float3 pos)
{
    float3 texPos = pos * _BaseTexScale + _BaseTexOffset;
    return SampleVolumeTexture(texPos).a;
}
#endif