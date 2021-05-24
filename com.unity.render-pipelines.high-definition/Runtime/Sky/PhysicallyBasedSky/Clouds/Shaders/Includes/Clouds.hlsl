#ifndef CLOUDS_INCLUDED
#define CLOUDS_INCLUDED

#include "PipelineDependent/PipelineDependent.hlsl"
#include "CloudsSampling.hlsl"

sampler2D _MainTex;
half4     _MainTex_ST;
float4    _MainTex_TexelSize;

struct appdata
{
    float4 uv : TEXCOORD0;
    uint vertexID : SV_VertexID;
};

struct v2f
{
    float4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

v2f CloudsVert(appdata v)
{
    v2f o;
    o.vertex = GetFullScreenTriangleVertexPosition(v.vertexID, UNITY_RAW_FAR_CLIP_VALUE);
    o.uv = float4(GetFullScreenTriangleTexCoord(v.vertexID), 0, 1);
    return o;
}

float4 CloudsFrag(v2f i) : SV_Target
{
    PrepareSampler();
    const ScreenSpace ss = CreateScreenSpace(i.uv);
    const Ray ray = CalculateHorizontalRayRange(ss, _HorizontalRegion);

    const float far = lerp(ss.maxDist, _MaxDistance, ss.isMaxPlane);

    if (ray.to <= 0 || ray.from > far)
    {
        return 0;
    }

    const CloudFactor cloudFactor = PhysicsCloud(ray, ss);

    return PackCloud(cloudFactor);
}
#endif
